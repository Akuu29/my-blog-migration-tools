# my-blog-migration-tools
Database migration tools for blog platform written in Rust

## 📝 Project Overview
This project provides database management tools for a multi-user blogging platform using PostgreSQL. It offers migration management with SQLx and initial data seeding functionality for lookup tables.

### Key Features
- **User Management**: Multi-provider authentication support (Firebase, Auth0, Cognito, GitHub, etc.)
- **Content Management**: Articles, categories, tags, and comments functionality
- **Security**: Email encryption (AES-256-GCM), refresh token management
- **Image Management**: Database storage, S3, and custom storage support
- **Environment Separation**: Development, staging, and production environment management

## Tech Stack
- **Language**: Rust
- **Database**: PostgreSQL 13.1
- **Key Libraries**:
  - SQLx 0.7.4 (PostgreSQL, async support)

## Prerequisites
- Rust 1.70 or higher
- Docker & Docker Compose
- PostgreSQL client (psql)
- SQLx CLI (for running migrations)

### Installing SQLx CLI
```bash
cargo install sqlx-cli --no-default-features --features postgres
```

## Setup
### 1. Create Environment Configuration Files
Create `.env` files for each environment:
```bash
# .env.dev
DATABASE_URL=postgres://admin:admin@localhost:5432/my-blog-db
```
**Note**: `.env.*` files are excluded by `.gitignore` and will not be committed.

### 2. Start Local Database
```bash
make run-local-container
```
This command performs the following:
- Creates Docker network `my-blog-network`
- Starts PostgreSQL 13.1 container (port 5432)
- Credentials: `admin/admin`, database name: `my-blog-db`

### 3. Run Migrations
```bash
make migrate-dev
```

### 4. Insert Seed Data
```bash
make insert-seed-dev
```

## 📖 Makefile Commands

### Database Management Commands

#### `make run-local-container`
Starts a PostgreSQL container for local development.

```bash
make run-local-container
```
- Creates Docker network
- Builds and starts with Docker Compose
- PostgreSQL 13.1 (user: admin, password: admin, DB: my-blog-db)

#### `make run-container-bash`
Opens a bash shell inside the running PostgreSQL container.

```bash
make run-container-bash
```

#### `make migrate-{environment}`
Runs migrations for the specified environment.

```bash
make migrate-dev    # Or stg/prd
```

Loads `DATABASE_URL` from the corresponding `.env.{environment}` file and executes `sqlx migrate run`.

#### `make revert-{environment}`
Reverts the latest migration.

```bash
make revert-dev     # Or stg/prd
```

#### `make info-{environment}`
Displays the status of applied migrations.

```bash
make info-dev       # Or stg/prd
```

Shows which migrations have been applied and which are pending.

#### `make connect-db-{environment}`
Connects to the database using psql client.

```bash
make connect-db-dev    # Or stg/prd
```

#### `make insert-seed-{environment}`
Inserts initial data into lookup tables.

```bash
make insert-seed-dev    # Or stg/prd
```

Loads data from `seeds/{environment}.json` file and inserts into the following tables:
- `identity_providers` - Authentication providers (firebase, auth0, etc.)
- `storage_types` - Storage types (database, s3, custom)

Uses `ON CONFLICT DO NOTHING`, making it safe to run multiple times.

## Database Structure

### Migration Order

1. `00000000000000_database_setup` - Extensions and functions
2. `20240827133130_users` - Users table
3. `20241006065205_tags` - Tags
4. `20241006065226_categories` - Categories
5. `20241006163338_articles` - Articles
6. `20241006163529_article_tags` - Article-tag relationships
7. `20241006163628_comments` - Comments
8. `20241006163723_storage_types` - Storage types
9. `20241006163823_images` - Images
10. `20250720061153_identity_providers` - Identity providers
11. `20250720061223_user_identities` - User identities
12. `20250720061244_refresh_tokens` - Refresh tokens

### Key Tables

- **users**: User basic information (roles, active status)
- **user_identities**: Multi-provider authentication (encrypted emails)
- **articles**: Articles (draft/private/published/deleted status workflow)
- **categories/tags**: Content classification
- **comments**: Support for both authenticated and anonymous users
- **images**: Flexible storage backend support

See `db_diagram.dbml` for detailed schema diagrams.

## Development Workflow

### Initial Setup

```bash
# 1. Start container
make run-local-container

# 2. Run migrations (in another terminal)
make migrate-dev

# 3. Insert seed data
make insert-seed-dev

# 4. Verify database connection
make connect-db-dev
```

### Adding New Migrations

```bash
# Create new migration
sqlx migrate add -r <migration_name>

# Run migration
make migrate-dev

# Verify
make info-dev
```

### Reverting Migrations

```bash
# Revert the latest migration
make revert-dev

# Check status
make info-dev
```

## References

- [SQLx Documentation](https://docs.rs/sqlx/)
- [DBML Documentation](https://www.dbml.org/docs/)
- `CLAUDE.md` file in this repository (detailed documentation for AI development assistance)
