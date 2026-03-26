import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.conversation import Conversation, Message
from app.models.user import User
from app.schemas.chat import ConversationOut, MessageCreate, MessageOut
from app.services.redis_client import publish_user_event

router = APIRouter(prefix="/chat", tags=["chat"])


def _ordered_pair(u1: str, u2: str) -> tuple[str, str]:
    return (u1, u2) if u1 < u2 else (u2, u1)


def get_or_create_conversation(db: Session, user_id: str, peer_id: str) -> Conversation:
    a, b = _ordered_pair(user_id, peer_id)
    conv = db.scalars(
        select(Conversation).where(Conversation.user_a_id == a, Conversation.user_b_id == b)
    ).first()
    if conv:
        return conv
    now = datetime.now(timezone.utc)
    conv = Conversation(
        id=str(uuid.uuid4()),
        user_a_id=a,
        user_b_id=b,
        created_at=now,
        updated_at=now,
    )
    db.add(conv)
    db.commit()
    db.refresh(conv)
    return conv


@router.get("/conversations", response_model=list[ConversationOut])
def list_conversations(user: User = Depends(get_current_user), db: Session = Depends(get_db)) -> list[ConversationOut]:
    rows = db.scalars(
        select(Conversation).where(
            (Conversation.user_a_id == user.id) | (Conversation.user_b_id == user.id)
        ).order_by(Conversation.updated_at.desc())
    ).all()
    out: list[ConversationOut] = []
    for c in rows:
        peer = c.user_b_id if c.user_a_id == user.id else c.user_a_id
        out.append(
            ConversationOut(
                id=c.id,
                peer_user_id=peer,
                updated_at=c.updated_at.isoformat(),
            )
        )
    return out


@router.get("/conversations/{conversation_id}/messages", response_model=list[MessageOut])
def list_messages(
    conversation_id: str,
    cursor: str | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[MessageOut]:
    conv = db.get(Conversation, conversation_id)
    if not conv or user.id not in (conv.user_a_id, conv.user_b_id):
        raise HTTPException(404, "Not found")
    q = select(Message).where(Message.conversation_id == conversation_id).order_by(Message.created_at.desc()).limit(limit)
    rows = db.scalars(q).all()
    rows = list(reversed(rows))
    return [
        MessageOut(
            id=m.id,
            conversation_id=m.conversation_id,
            sender_id=m.sender_id,
            body=m.body,
            created_at=m.created_at.isoformat(),
        )
        for m in rows
    ]


@router.post("/conversations/with/{peer_user_id}/messages", response_model=MessageOut)
def send_message(
    peer_user_id: str,
    body: MessageCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MessageOut:
    if peer_user_id == user.id:
        raise HTTPException(400, "Invalid peer")
    peer = db.get(User, peer_user_id)
    if not peer:
        raise HTTPException(404, "Peer not found")
    conv = get_or_create_conversation(db, user.id, peer_user_id)
    now = datetime.now(timezone.utc)
    msg = Message(
        id=str(uuid.uuid4()),
        conversation_id=conv.id,
        sender_id=user.id,
        body=body.body,
        created_at=now,
    )
    conv.updated_at = now
    db.add(msg)
    db.commit()
    db.refresh(msg)
    publish_user_event(peer_user_id, {"type": "chat_message", "conversation_id": conv.id, "message_id": msg.id})
    return MessageOut(
        id=msg.id,
        conversation_id=msg.conversation_id,
        sender_id=msg.sender_id,
        body=msg.body,
        created_at=msg.created_at.isoformat(),
    )
