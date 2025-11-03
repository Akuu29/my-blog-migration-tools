CREATE TABLE article_tags (
    article_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (article_id, tag_id),

    CONSTRAINT fk_article_id
        FOREIGN KEY (article_id)
        REFERENCES articles (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_tag_id
        FOREIGN KEY (tag_id)
        REFERENCES tags (id)
        ON DELETE CASCADE
);

CREATE INDEX idx_article_tags_tag_article
    ON article_tags (tag_id, article_id);

CREATE INDEX idx_article_tags_article_tags
    ON article_tags (article_id, tag_id);

CREATE TRIGGER trg_article_tags_updated_at
    BEFORE UPDATE ON article_tags
    FOR EACH ROW
    EXECUTE FUNCTION updated_at_trigger();
