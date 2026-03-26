import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, require_child, require_parent
from app.db.session import get_db
from app.models.activity import Activity, ActivityJoinRequest
from app.models.child_profile import ChildProfile
from app.models.user import User
from app.schemas.activity import ActivityCreate, ActivityOut, JoinRequestOut
from app.services.redis_client import publish_user_event

router = APIRouter(prefix="/activities", tags=["activities"])


def _activity_out(a: Activity) -> ActivityOut:
    return ActivityOut(
        id=a.id,
        title=a.title,
        description=a.description,
        organizer_user_id=a.organizer_user_id,
        max_participants=a.max_participants,
        created_at=a.created_at.isoformat(),
    )


def _join_out(r: ActivityJoinRequest) -> JoinRequestOut:
    return JoinRequestOut(
        id=r.id,
        activity_id=r.activity_id,
        child_user_id=r.child_user_id,
        status=r.status,
        created_at=r.created_at.isoformat(),
        resolved_at=r.resolved_at.isoformat() if r.resolved_at else None,
    )


@router.post("", response_model=ActivityOut)
def create_activity(
    body: ActivityCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ActivityOut:
    now = datetime.now(timezone.utc)
    a = Activity(
        id=str(uuid.uuid4()),
        title=body.title,
        description=body.description,
        organizer_user_id=user.id,
        max_participants=body.max_participants,
        created_at=now,
    )
    db.add(a)
    db.commit()
    db.refresh(a)
    return _activity_out(a)


@router.get("", response_model=list[ActivityOut])
def list_activities(db: Session = Depends(get_db)) -> list[ActivityOut]:
    rows = db.execute(select(Activity).order_by(Activity.created_at.desc())).scalars().all()
    return [_activity_out(x) for x in rows]


@router.post("/{activity_id}/join-request", response_model=JoinRequestOut)
def request_join(
    activity_id: str,
    child: User = Depends(require_child),
    db: Session = Depends(get_db),
) -> JoinRequestOut:
    act = db.get(Activity, activity_id)
    if not act:
        raise HTTPException(404, "Activity not found")
    cp = db.get(ChildProfile, child.id)
    if not cp or not cp.parent_user_id:
        raise HTTPException(400, "Child must be bound to a parent first")

    dup = db.scalars(
        select(ActivityJoinRequest).where(
            ActivityJoinRequest.activity_id == activity_id,
            ActivityJoinRequest.child_user_id == child.id,
            ActivityJoinRequest.status == "pending",
        )
    ).first()
    if dup:
        raise HTTPException(400, "Already pending")

    now = datetime.now(timezone.utc)
    r = ActivityJoinRequest(
        id=str(uuid.uuid4()),
        activity_id=activity_id,
        child_user_id=child.id,
        status="pending",
        created_at=now,
        resolved_at=None,
    )
    db.add(r)
    db.commit()
    db.refresh(r)
    publish_user_event(cp.parent_user_id, {"type": "activity_request_updated", "request_id": r.id, "status": "pending"})
    return _join_out(r)


@router.get("/parent/join-requests", response_model=list[JoinRequestOut])
def list_join_requests(
    parent: User = Depends(require_parent),
    status_filter: str | None = None,
    db: Session = Depends(get_db),
) -> list[JoinRequestOut]:
    children = db.scalars(select(ChildProfile).where(ChildProfile.parent_user_id == parent.id)).all()
    child_ids = [c.user_id for c in children]
    if not child_ids:
        return []
    st = status_filter or "pending"
    rows = db.scalars(
        select(ActivityJoinRequest).where(
            ActivityJoinRequest.child_user_id.in_(child_ids),
            ActivityJoinRequest.status == st,
        )
    ).all()
    return [_join_out(x) for x in rows]


@router.post("/join-requests/{request_id}/approve", response_model=JoinRequestOut)
def approve_join(
    request_id: str,
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> JoinRequestOut:
    r = db.get(ActivityJoinRequest, request_id)
    if not r or r.status != "pending":
        raise HTTPException(404, "Not found")
    cp = db.get(ChildProfile, r.child_user_id)
    if not cp or cp.parent_user_id != parent.id:
        raise HTTPException(403, "Not your child")
    now = datetime.now(timezone.utc)
    r.status = "approved"
    r.resolved_at = now
    db.commit()
    db.refresh(r)
    publish_user_event(r.child_user_id, {"type": "activity_request_updated", "request_id": r.id, "status": "approved"})
    return _join_out(r)


@router.post("/join-requests/{request_id}/reject", response_model=JoinRequestOut)
def reject_join(
    request_id: str,
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> JoinRequestOut:
    r = db.get(ActivityJoinRequest, request_id)
    if not r or r.status != "pending":
        raise HTTPException(404, "Not found")
    cp = db.get(ChildProfile, r.child_user_id)
    if not cp or cp.parent_user_id != parent.id:
        raise HTTPException(403, "Not your child")
    now = datetime.now(timezone.utc)
    r.status = "rejected"
    r.resolved_at = now
    db.commit()
    db.refresh(r)
    publish_user_event(r.child_user_id, {"type": "activity_request_updated", "request_id": r.id, "status": "rejected"})
    return _join_out(r)
