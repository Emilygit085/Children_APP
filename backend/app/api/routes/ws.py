import asyncio
import json
import logging

import redis.asyncio as aioredis
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query

from app.core.config import settings
from app.core.security import decode_token
from app.db.session import SessionLocal
from app.models.user import User

logger = logging.getLogger(__name__)
router = APIRouter(tags=["websocket"])


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...),
) -> None:
    payload = decode_token(token)
    if not payload or "sub" not in payload:
        await websocket.close(code=4401)
        return
    db = SessionLocal()
    try:
        user = db.get(User, payload["sub"])
        if not user:
            await websocket.close(code=4401)
            return
    finally:
        db.close()

    user_id = user.id
    await websocket.accept()
    try:
        r = aioredis.from_url(settings.redis_url, decode_responses=True)
        pubsub = r.pubsub()
        await pubsub.subscribe(f"user:{user_id}")
    except Exception as e:
        logger.exception("Redis subscribe failed: %s", e)
        await websocket.close(code=1011)
        return

    listen_task = asyncio.create_task(_relay_pubsub(websocket, pubsub))
    try:
        while True:
            data = await websocket.receive_text()
            try:
                msg = json.loads(data)
                if msg.get("type") == "ping":
                    await websocket.send_text(json.dumps({"type": "pong"}))
            except json.JSONDecodeError:
                pass
    except WebSocketDisconnect:
        pass
    finally:
        listen_task.cancel()
        try:
            await pubsub.unsubscribe(f"user:{user_id}")
            await pubsub.close()
            await r.close()
        except Exception:
            pass


async def _relay_pubsub(websocket: WebSocket, pubsub) -> None:
    try:
        async for message in pubsub.listen():
            if message["type"] != "message":
                continue
            data = message.get("data")
            if data:
                await websocket.send_text(data)
    except asyncio.CancelledError:
        pass
    except Exception as e:
        logger.exception("relay: %s", e)
