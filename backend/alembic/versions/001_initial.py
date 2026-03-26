"""initial schema

Revision ID: 001
Revises:
Create Date: 2025-03-26

"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("username", sa.String(64), nullable=False, unique=True),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("role", sa.String(16), nullable=False),
        sa.Column("avatar_url", sa.String(512), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        mysql_charset="utf8mb4",
    )
    op.create_index("ix_users_username", "users", ["username"])

    op.create_table(
        "parent_profiles",
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("display_name", sa.String(128), nullable=False),
        sa.Column("phone", sa.String(32), nullable=True),
        mysql_charset="utf8mb4",
    )
    op.create_table(
        "child_profiles",
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("child_name", sa.String(128), nullable=False),
        sa.Column("age", sa.Integer(), nullable=False),
        sa.Column("interests_json", sa.JSON(), nullable=True),
        sa.Column("personality_json", sa.JSON(), nullable=True),
        sa.Column("parent_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        mysql_charset="utf8mb4",
    )

    op.create_table(
        "bind_codes",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("code", sa.String(6), nullable=False, unique=True),
        sa.Column("parent_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="1"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        mysql_charset="utf8mb4",
    )
    op.create_index("ix_bind_codes_code", "bind_codes", ["code"])

    op.create_table(
        "bindings",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("parent_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("child_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("bind_code", sa.String(6), nullable=False),
        sa.Column("status", sa.String(16), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        mysql_charset="utf8mb4",
    )
    op.create_index("ix_bindings_parent", "bindings", ["parent_user_id", "status"])
    op.create_index("ix_bindings_child", "bindings", ["child_user_id", "status"])

    op.create_table(
        "activities",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("organizer_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("max_participants", sa.Integer(), nullable=False, server_default="10"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        mysql_charset="utf8mb4",
    )

    op.create_table(
        "activity_join_requests",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("activity_id", sa.String(36), sa.ForeignKey("activities.id", ondelete="CASCADE"), nullable=False),
        sa.Column("child_user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("status", sa.String(16), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        mysql_charset="utf8mb4",
    )
    op.create_index("ix_ajr_activity", "activity_join_requests", ["activity_id", "status"])
    op.create_index("ix_ajr_child", "activity_join_requests", ["child_user_id"])

    op.create_table(
        "conversations",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("user_a_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_b_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("user_a_id", "user_b_id", name="uq_conversation_pair"),
        mysql_charset="utf8mb4",
    )

    op.create_table(
        "messages",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column("conversation_id", sa.String(36), sa.ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("sender_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("body", sa.String(4000), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        mysql_charset="utf8mb4",
    )
    op.create_index("ix_messages_conv_time", "messages", ["conversation_id", "created_at"])


def downgrade() -> None:
    op.drop_table("messages")
    op.drop_table("conversations")
    op.drop_table("activity_join_requests")
    op.drop_table("activities")
    op.drop_table("bindings")
    op.drop_table("bind_codes")
    op.drop_table("child_profiles")
    op.drop_table("parent_profiles")
    op.drop_table("users")
