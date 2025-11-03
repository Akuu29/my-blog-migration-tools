CREATE TABLE IF NOT EXISTS tags (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4(),
    name VARCHAR(30) NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX uq_tags_user_name
    ON tags (user_id, name);

CREATE TRIGGER trg_tags_updated_at
    BEFORE UPDATE ON tags
    FOR EACH ROW
    EXECUTE FUNCTION updated_at_trigger();
