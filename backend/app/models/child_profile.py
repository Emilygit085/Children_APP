from sqlalchemy import ForeignKey, Integer, JSON, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class ChildProfile(Base):
    __tablename__ = "child_profiles"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    child_name: Mapped[str] = mapped_column(String(128), nullable=False)
    age: Mapped[int] = mapped_column(Integer, nullable=False)
    interests_json: Mapped[list | None] = mapped_column(JSON, nullable=True)
    personality_json: Mapped[list | None] = mapped_column(JSON, nullable=True)
    parent_user_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)

    user = relationship("User", back_populates="child_profile", foreign_keys="ChildProfile.user_id")
