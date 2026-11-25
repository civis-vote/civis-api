class UpgradeUsersDeviseInvitations < ActiveRecord::Migration[8.1]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS pgcrypto'

    execute <<~SQL
      CREATE TABLE IF NOT EXISTS devise_invitations (
        id bigserial PRIMARY KEY,
        invitation_token character varying,
        invitation_created_at timestamp(6) without time zone,
        invitation_sent_at timestamp(6) without time zone,
        invitation_accepted_at timestamp(6) without time zone,
        superseded_at timestamp(6) without time zone,
        superseded_reason character varying,
        revoked_at timestamp(6) without time zone,
        resource_created_at timestamp(6) without time zone,
        invite_key json NOT NULL DEFAULT '{}'::json,
        invite_key_digest character varying NOT NULL,
        invitable_type character varying,
        invitable_id bigint,
        invited_by_type character varying,
        invited_by_id bigint,
        created_at timestamp(6) without time zone NOT NULL,
        updated_at timestamp(6) without time zone NOT NULL
      )
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_devise_invitations_on_invitable
        ON devise_invitations (invitable_type, invitable_id)
    SQL

    execute <<~SQL
      CREATE UNIQUE INDEX IF NOT EXISTS index_devise_invitations_on_invitation_token
        ON devise_invitations (invitation_token)
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_devise_invitations_on_invited_by
        ON devise_invitations (invited_by_type, invited_by_id)
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_devise_invitations_on_type_and_invite_key
        ON devise_invitations (invitable_type, invite_key_digest)
    SQL

    # Copy the legacy per-model invitation data. The invite_key_digest must
    # match DeviseInvitable::Invitation.digest_for('User', email: <email>),
    # i.e. SHA-256 of "User\0email\0<email>". PostgreSQL cannot store NUL
    # bytes in UTF-8 text, so the digest input is built as bytea.
    execute <<~SQL
      INSERT INTO devise_invitations (
        invitation_token,
        invitation_created_at,
        invitation_sent_at,
        invitation_accepted_at,
        resource_created_at,
        invite_key,
        invite_key_digest,
        invitable_type,
        invitable_id,
        invited_by_type,
        invited_by_id,
        created_at,
        updated_at
      )
      SELECT
        invitation_token,
        invitation_created_at,
        invitation_sent_at,
        invitation_accepted_at,
        invitation_created_at,
        json_build_object('email', email),
        encode(
          digest(
            convert_to('User', 'UTF8') || decode('00', 'hex') ||
            convert_to('email', 'UTF8') || decode('00', 'hex') ||
            convert_to(email, 'UTF8'),
            'sha256'
          ),
          'hex'
        ),
        'User',
        id,
        invited_by_type,
        invited_by_id,
        invitation_created_at,
        COALESCE(invitation_accepted_at, invitation_sent_at, invitation_created_at)
      FROM users
      WHERE invitation_created_at IS NOT NULL
    SQL

    # invitation_limit and invitations_count describe inviters rather than
    # individual invitations, so they stay on users.
    execute <<~SQL
      ALTER TABLE users
        DROP COLUMN IF EXISTS invitation_token,
        DROP COLUMN IF EXISTS invitation_created_at,
        DROP COLUMN IF EXISTS invitation_sent_at,
        DROP COLUMN IF EXISTS invitation_accepted_at,
        DROP COLUMN IF EXISTS invited_by_id,
        DROP COLUMN IF EXISTS invited_by_type
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      'Multiple invitation records cannot be losslessly moved back onto users'
  end
end
