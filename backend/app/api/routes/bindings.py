import random
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, require_child, require_parent
from app.db.session import get_db
from app.models.bind_code import BindCode
from app.models.binding import Binding
from app.models.child_profile import ChildProfile
from app.models.parent_profile import ParentProfile
from app.models.user import User
from app.schemas.binding import BindCodeResponse, BindRequestBody, BindingOut
from app.services.redis_client import check_rate_limit, publish_user_event

router = APIRouter(prefix="/bindings", tags=["bindings"])


def _binding_to_out(b: Binding) -> BindingOut:
    return BindingOut(
        id=b.id,
        parent_user_id=b.parent_user_id,
        child_user_id=b.child_user_id,
        bind_code=b.bind_code,
        status=b.status,
        created_at=b.created_at.isoformat(),
        resolved_at=b.resolved_at.isoformat() if b.resolved_at else None,
    )


@router.post("/parent/bind-code", response_model=BindCodeResponse)
def create_or_refresh_bind_code(
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> BindCodeResponse:
    if not check_rate_limit("bind_code", parent.id, limit=10, window_sec=3600):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Too many requests")
    profile = db.get(ParentProfile, parent.id)
    if not profile:
        raise HTTPException(400, "Parent profile missing")

    for old in db.execute(
        select(BindCode).where(BindCode.parent_user_id == parent.id, BindCode.is_active.is_(True))
    ).scalars():
        old.is_active = False

    code = "".join(str(random.randint(0, 9)) for _ in range(6))
    while db.scalars(select(BindCode).where(BindCode.code == code)).first():
        code = "".join(str(random.randint(0, 9)) for _ in range(6))

    now = datetime.now(timezone.utc)
    expires = now + timedelta(hours=24)
    bc = BindCode(
        id=str(uuid.uuid4()),
        code=code,
        parent_user_id=parent.id,
        expires_at=expires,
        is_active=True,
        created_at=now,
    )
    db.add(bc)
    db.commit()
    return BindCodeResponse(code=code, expires_at=expires.isoformat())


@router.post("/child/request", response_model=BindingOut)
def child_bind_request(
    body: BindRequestBody,
    child: User = Depends(require_child),
    db: Session = Depends(get_db),
) -> BindingOut:
    if not check_rate_limit("bind_req", child.id, limit=20, window_sec=3600):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Too many requests")

    bc = db.scalars(
        select(BindCode).where(
            BindCode.code == body.bind_code.strip(),
            BindCode.is_active.is_(True),
        )
    ).first()
    if not bc:
        raise HTTPException(400, "Invalid bind code")
    now = datetime.now(timezone.utc)
    if bc.expires_at and bc.expires_at < now:
        raise HTTPException(400, "Bind code expired")

    existing = db.scalars(
        select(Binding).where(Binding.child_user_id == child.id, Binding.status.in_(["pending", "approved"]))
    ).first()
    if existing:
        raise HTTPException(400, "Already has pending or approved binding")

    b = Binding(
        id=str(uuid.uuid4()),
        parent_user_id=bc.parent_user_id,
        child_user_id=child.id,
        bind_code=bc.code,
        status="pending",
        created_at=now,
        resolved_at=None,
    )
    db.add(b)
    db.commit()
    db.refresh(b)
    publish_user_event(bc.parent_user_id, {"type": "binding_updated", "binding_id": b.id, "status": "pending"})
    return _binding_to_out(b)


@router.get("/parent/pending", response_model=list[BindingOut])
def list_pending_bindings(
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> list[BindingOut]:
    rows = db.execute(
        select(Binding).where(Binding.parent_user_id == parent.id, Binding.status == "pending")
    ).scalars().all()
    return [_binding_to_out(x) for x in rows]


@router.post("/{binding_id}/approve", response_model=BindingOut)
def approve_binding(
    binding_id: str,
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> BindingOut:
    b = db.get(Binding, binding_id)
    if not b or b.parent_user_id != parent.id:
        raise HTTPException(404, "Not found")
    if b.status != "pending":
        raise HTTPException(400, "Not pending")
    now = datetime.now(timezone.utc)
    b.status = "approved"
    b.resolved_at = now
    child_profile = db.get(ChildProfile, b.child_user_id)
    if child_profile:
        child_profile.parent_user_id = b.parent_user_id
    db.commit()
    db.refresh(b)
    publish_user_event(b.child_user_id, {"type": "binding_updated", "binding_id": b.id, "status": "approved"})
    return _binding_to_out(b)


@router.post("/{binding_id}/reject", response_model=BindingOut)
def reject_binding(
    binding_id: str,
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> BindingOut:
    b = db.get(Binding, binding_id)
    if not b or b.parent_user_id != parent.id:
        raise HTTPException(404, "Not found")
    if b.status != "pending":
        raise HTTPException(400, "Not pending")
    now = datetime.now(timezone.utc)
    b.status = "rejected"
    b.resolved_at = now
    db.commit()
    db.refresh(b)
    publish_user_event(b.child_user_id, {"type": "binding_updated", "binding_id": b.id, "status": "rejected"})
    return _binding_to_out(b)
