CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    public_id UUID UNIQUE DEFAULT uuid_generate_v4(),
    name VARCHAR(60) NOT NULL,
    slug VARCHAR NULL,
    user_id int NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX uq_categories_user_name
    ON categories (user_id, name);

CREATE UNIQUE INDEX uq_categories_user_slug
    ON categories (user_id, slug);

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION updated_at_trigger();
