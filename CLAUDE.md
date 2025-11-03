# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust-based blog migration tool that manages a PostgreSQL database for a multi-user blogging platform. The project is primarily focused on database schema management using SQLx migrations.

**Technology Stack:**
- Rust 2021 edition
- SQLx 0.7.4 with PostgreSQL support, Tokio runtime, and Chrono for timestamps
- PostgreSQL 13.1 (containerized)
- Docker and Docker Compose for local development

## Database Architecture

The database schema supports a complete blogging platform with the following key features:

**User Management:**
- Multi-provider authentication system (Firebase, Auth0, Cognito, GitHub, etc.)
- User identities with encrypted email storage (AES-256-GCM)
- Refresh token management with revocation support
- Role-based access control (admin/user)

**Content Management:**
- Articles with draft/private/published/deleted status workflow
- Categories and tags (many-to-many relationship with articles)
- Comments with support for both authenticated and anonymous users
- Image storage supporting both database (bytea) and external storage (S3, custom)

**Key Design Patterns:**
- All user-facing tables use UUID-based `public_id` for external references (internal `id` is serial)
- Automatic `updated_at` timestamp management via triggers
- Email encryption with cipher metadata for key rotation support
- Partial unique indexes for active records only (e.g., articles with non-null titles)

## Development Commands

### Database Management

**Start local PostgreSQL container:**
```bash
make run-local-container
```
This creates a `my-blog-network` Docker network and starts PostgreSQL on port 5432 with credentials: `admin/admin`, database: `my-blog-db`.

**Run migrations:**
```bash
make migrate-dev    # Development environment
make migrate-stg    # Staging environment
make migrate-prd    # Production environment
```
These commands source environment files (`.env.dev`, `.env.stg`, `.env.prd`) and run SQLx migrations.

**Revert migrations:**
```bash
make revert-dev
make revert-stg
make revert-prd
```

**View migration status:**
```bash
make info-dev
make info-stg
make info-prd
```

**Connect to database:**
```bash
make connect-db-dev    # Connects via psql
make connect-db-stg
make connect-db-prd
```

**Access container shell:**
```bash
make run-container-bash
```

**Insert seed data:**
```bash
make insert-seed-dev    # Development environment
make insert-seed-stg    # Staging environment
make insert-seed-prd    # Production environment
```
Seeds lookup tables (`identity_providers`, `storage_types`) from JSON files in `seeds/` directory.

### Rust Development

**Build the project:**
```bash
cargo build
```

**Run the application:**
```bash
cargo run
```

**Run the seed binary:**
```bash
cargo run --bin seed -- --env dev    # Or stg/prd
```

**Run tests:**
```bash
cargo test
```

**Check code without building:**
```bash
cargo check
```

## Migration Structure

Migrations are located in `migrations/` and follow SQLx naming conventions:
- Format: `{timestamp}_{description}.{up|down}.sql`
- Initial setup: `00000000000000_database_setup.{up|down}.sql`

**Migration Order (by timestamp):**
1. `00000000000000_database_setup` - Extensions and utility functions (uuid-ossp, updated_at_trigger)
2. `20240827133130_users` - Core user table
3. `20241006065205_tags` - Tag system
4. `20241006065226_categories` - Category system
5. `20241006163338_articles` - Article content with status workflow
6. `20241006163529_article_tags` - Many-to-many article/tag relationship
7. `20241006163628_comments` - Comment system
8. `20241006163723_storage_types` - Storage backend configuration
9. `20241006163823_images` - Image storage with flexible backends
10. `20250720061153_identity_providers` - Authentication provider registry
11. `20250720061223_user_identities` - Multi-provider user authentication
12. `20250720061244_refresh_tokens` - Token-based session management

## Environment Configuration

Create environment files for each stage:
- `.env.dev` - Development database connection
- `.env.stg` - Staging database connection
- `.env.prd` - Production database connection

Each file should contain:
```bash
DATABASE_URL=postgres://username:password@host:port/database
```

**Note:** `.env.dev` is untracked (in `.gitignore`). Never commit database credentials.

## Code Architecture

**Project Structure:**
- `src/main.rs` - Simple "Hello World" entry point (currently unused)
- `src/lib.rs` - Library root exposing the `models` module
- `src/models/` - Data models for seed operations
  - `seed.rs` - `SeedData` struct with JSON deserialization and validation
- `src/bin/seed.rs` - Standalone CLI binary for inserting seed data

**Seed Data System:**

The project includes a dedicated seeding system to populate lookup tables with initial data. This is separate from SQLx migrations.

**Architecture Pattern:**
1. JSON files in `seeds/` directory define environment-specific seed data (dev.json, stg.json, prd.json)
2. `SeedData` struct in `src/models/seed.rs` provides:
   - JSON deserialization from seed files
   - Validation to ensure required data exists
   - Type-safe representation of lookup table records
3. Binary in `src/bin/seed.rs` handles:
   - CLI argument parsing (environment selection)
   - Database URL loading from `.env.{env}` files
   - Transaction-based bulk inserts with `ON CONFLICT DO NOTHING`
   - Progress reporting with emoji indicators

**Usage Flow:**
```bash
# After running migrations
make insert-seed-dev    # Internally calls: cargo run --bin seed -- --env dev
```

**Seed Data Format:**
```json
{
  "identity_providers": [{"name": "firebase"}, {"name": "auth0"}],
  "storage_types": [{"name": "database"}, {"name": "s3"}]
}
```

**Key Design Decisions:**
- Idempotent inserts using `ON CONFLICT DO NOTHING` - safe to run multiple times
- Separate binary (`bin/seed.rs`) rather than migration to allow reseeding without version conflicts
- QueryBuilder for bulk inserts within a transaction for atomicity
- Environment-specific seed files allow different data per deployment stage

## Database Schema Reference

See `db_diagram.dbml` for the complete database schema diagram with relationships, constraints, and indexes. This DBML file documents:
- All table structures and relationships
- Enum types and their values
- Seed data requirements for lookup tables
- Trigger configurations
- Index strategies (including partial unique indexes)
- Email encryption metadata format
