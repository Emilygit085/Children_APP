from pydantic import BaseModel, Field


class ActivityCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    max_participants: int = Field(default=10, ge=2, le=500)


class ActivityOut(BaseModel):
    id: str
    title: str
    description: str | None
    organizer_user_id: str
    max_participants: int
    created_at: str

    model_config = {"from_attributes": True}


class JoinRequestOut(BaseModel):
    id: str
    activity_id: str
    child_user_id: str
    status: str
    created_at: str
    resolved_at: str | None = None

    model_config = {"from_attributes": True}
