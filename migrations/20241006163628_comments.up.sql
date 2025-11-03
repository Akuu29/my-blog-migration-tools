CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4(),
    body TEXT NOT NULL,
    user_id INTEGER DEFAULT NULL,
    user_name VARCHAR DEFAULT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    article_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE SET NULL,

    CONSTRAINT fk_article_id
        FOREIGN KEY (article_id)
        REFERENCES articles (id)
        ON DELETE CASCADE
);

CREATE INDEX idx_comments_article_id
  ON comments (article_id);

CREATE TRIGGER trg_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW
  EXECUTE FUNCTION updated_at_trigger();
