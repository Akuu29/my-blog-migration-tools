CREATE TYPE article_status AS ENUM ('draft', 'private','published', 'deleted');

CREATE TABLE IF NOT EXISTS articles (
  id SERIAL PRIMARY KEY,
  public_id UUID UNIQUE DEFAULT uuid_generate_v4(),
  title VARCHAR,
  slug VARCHAR,
  body TEXT,
  status article_status DEFAULT 'draft',
  user_id INTEGER NOT NULL,
  category_id INTEGER DEFAULT NULL,
  first_published_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_user_id
    FOREIGN KEY (user_id)
    REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_category_id
    FOREIGN KEY (category_id)
    REFERENCES categories (id)
    ON DELETE SET NULL
);

CREATE INDEX idx_articles_user_status_updated_at_desc
  ON articles (user_id, status, updated_at DESC);

CREATE UNIQUE INDEX uq_articles_user_title_active
  ON articles (user_id, title)
  WHERE title IS NOT NULL AND status IN ('draft', 'published', 'private');

CREATE UNIQUE INDEX uq_articles_user_slug_active
  ON articles (user_id, slug)
  WHERE slug IS NOT NULL AND status IN ('draft', 'published', 'private');

CREATE TRIGGER trg_articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW
  EXECUTE FUNCTION updated_at_trigger();
