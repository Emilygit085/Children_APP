from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, require_child, require_parent
from app.core.config import settings
from app.db.session import get_db
from app.models.child_profile import ChildProfile
from app.models.user import User

router = APIRouter(prefix="/users", tags=["users"])


class AvatarPatch(BaseModel):
    object_key: str = Field(min_length=1, max_length=512)


@router.patch("/me/avatar")
def patch_avatar(
    body: AvatarPatch,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict:
    if settings.cos_domain:
        base = settings.cos_domain.rstrip("/")
        user.avatar_url = f"{base}/{body.object_key.lstrip('/')}"
    else:
        user.avatar_url = body.object_key
    db.commit()
    db.refresh(user)
    return {"avatar_url": user.avatar_url}


class ChildProfileUpdate(BaseModel):
    interests: list[str] | None = None
    personality: list[str] | None = None


@router.patch("/me/child-profile")
def patch_child_profile(
    body: ChildProfileUpdate,
    user: User = Depends(require_child),
    db: Session = Depends(get_db),
) -> dict:
    cp = db.get(ChildProfile, user.id)
    if not cp:
        raise HTTPException(404, "Child profile not found")
    if body.interests is not None:
        cp.interests_json = body.interests
    if body.personality is not None:
        cp.personality_json = body.personality
    db.commit()
    db.refresh(cp)
    return {
        "interests": cp.interests_json,
        "personality": cp.personality_json,
    }


@router.get("/parent/children")
def list_parent_children(
    parent: User = Depends(require_parent),
    db: Session = Depends(get_db),
) -> list[dict]:
    rows = db.scalars(select(ChildProfile).where(ChildProfile.parent_user_id == parent.id)).all()
    return [
        {
            "user_id": r.user_id,
            "child_name": r.child_name,
            "age": r.age,
            "interests": r.interests_json or [],
            "personality": r.personality_json or [],
        }
        for r in rows
    ]
