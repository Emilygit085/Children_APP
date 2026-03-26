from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.core.security import create_access_token, hash_password, verify_password
from app.db.session import get_db
from app.models.child_profile import ChildProfile
from app.models.parent_profile import ParentProfile
from app.models.user import User
from app.schemas.auth import LoginRequest, MeResponse, RegisterChild, RegisterParent, TokenResponse, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register/parent", response_model=TokenResponse)
def register_parent(body: RegisterParent, db: Session = Depends(get_db)) -> TokenResponse:
    if db.scalars(select(User).where(User.username == body.username)).first():
        raise HTTPException(status_code=400, detail="Username already exists")
    now = datetime.now(timezone.utc)
    user = User(
        username=body.username,
        password_hash=hash_password(body.password),
        role="parent",
        created_at=now,
    )
    db.add(user)
    db.flush()
    db.add(
        ParentProfile(
            user_id=user.id,
            display_name=body.display_name,
            phone=body.phone,
        )
    )
    db.commit()
    db.refresh(user)
    token = create_access_token(user.id, {"role": user.role})
    return TokenResponse(
        access_token=token,
        user=UserOut.model_validate(user),
    )


@router.post("/register/child", response_model=TokenResponse)
def register_child(body: RegisterChild, db: Session = Depends(get_db)) -> TokenResponse:
    if db.scalars(select(User).where(User.username == body.username)).first():
        raise HTTPException(status_code=400, detail="Username already exists")
    now = datetime.now(timezone.utc)
    user = User(
        username=body.username,
        password_hash=hash_password(body.password),
        role="child",
        created_at=now,
    )
    db.add(user)
    db.flush()
    db.add(
        ChildProfile(
            user_id=user.id,
            child_name=body.child_name,
            age=body.age,
        )
    )
    db.commit()
    db.refresh(user)
    token = create_access_token(user.id, {"role": user.role})
    return TokenResponse(
        access_token=token,
        user=UserOut.model_validate(user),
    )


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    user = db.scalars(select(User).where(User.username == body.username)).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(user.id, {"role": user.role})
    return TokenResponse(
        access_token=token,
        user=UserOut.model_validate(user),
    )


@router.get("/me", response_model=MeResponse)
def me(user: User = Depends(get_current_user), db: Session = Depends(get_db)) -> MeResponse:
    parent = db.get(ParentProfile, user.id)
    child = db.get(ChildProfile, user.id)
    return MeResponse(
        user=UserOut.model_validate(user),
        parent_profile={
            "display_name": parent.display_name,
            "phone": parent.phone,
        }
        if parent
        else None,
        child_profile={
            "child_name": child.child_name,
            "age": child.age,
            "parent_user_id": child.parent_user_id,
            "interests": child.interests_json,
            "personality": child.personality_json,
        }
        if child
        else None,
    )
