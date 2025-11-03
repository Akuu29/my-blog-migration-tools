CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4(),
    name varchar NOT NULL,
    mime_type varchar NOT NULL,
    data BYTEA,
    url TEXT,
    storage_type_id INTEGER NOT NULL DEFAULT 1,
    article_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_article_id
        FOREIGN KEY (article_id)
        REFERENCES articles (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_storage_type_id
        FOREIGN KEY (storage_type_id)
        REFERENCES storage_types (id)
        ON DELETE SET NULL,

    CHECK (
        (data IS NOT NULL AND url IS NULL)
        OR
        (data IS NULL AND url IS NOT NULL)
    )
);

CREATE TRIGGER trg_images_updated_at
  BEFORE UPDATE ON images
  FOR EACH ROW
  EXECUTE FUNCTION updated_at_trigger();
