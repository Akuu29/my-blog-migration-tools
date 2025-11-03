CREATE TABLE IF NOT EXISTS user_identities (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  provider_id INTEGER NOT NULL,
  provider_user_id VARCHAR NOT NULL,
  provider_email_ciphertext BYTEA NOT NULL,
  provider_email_cipher_nonce BYTEA NOT NULL,
  provider_email_cipher_meta JSONB NOT NULL,
  provider_email_hash VARCHAR(128) NOT NULL,
  provider_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_user_id
    FOREIGN KEY (user_id)
    REFERENCES users (id)
    ON DELETE CASCADE,

  CONSTRAINT fk_provider
    FOREIGN KEY (provider_id)
    REFERENCES identity_providers (id)
    ON DELETE CASCADE,

  CONSTRAINT provider_user_id_unique UNIQUE (provider_id, provider_user_id),

  CONSTRAINT user_provider_unique UNIQUE (user_id, provider_id)
);

CREATE UNIQUE INDEX idx_user_identities_user_id
  ON user_identities (user_id)
  WHERE is_primary;

CREATE UNIQUE INDEX uq_user_identities_provider_user_id
  ON user_identities (provider_id, provider_user_id);

CREATE INDEX idx_user_identities_provider_email_hash
  ON user_identities (provider_email_hash);

CREATE TRIGGER trg_user_identities_updated_at
  BEFORE UPDATE ON user_identities
  FOR EACH ROW
  EXECUTE FUNCTION updated_at_trigger();
