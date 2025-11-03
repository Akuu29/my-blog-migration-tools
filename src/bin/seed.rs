use anyhow::{Context, Result};
use clap::Parser;
use sqlx::postgres::PgPoolOptions;
use sqlx::{PgPool, QueryBuilder};

use my_blog_migration_tools::models::seed::SeedData;

#[derive(Parser, Debug)]
#[command(name = "seed")]
#[command(about = "Insert seed data into the database", long_about = None)]
struct Args {
    /// Environment to seed (dev, stg, prd)
    #[arg(short, long)]
    env: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    if !["dev", "stg", "prd"].contains(&args.env.as_str()) {
        anyhow::bail!(
            "Invalid environment: {}. Must be one of: dev, stg, prd",
            args.env
        );
    }

    println!("🌱 Starting seed process for environment: {}", args.env);

    let env_file = format!(".env.{}", args.env);
    let database_url = load_database_url(&env_file)?;

    // Load seed data from JSON file
    let seed_file = format!("seeds/{}.json", args.env);
    println!("📖 Loading seed data from: {}", seed_file);
    let seed_data = SeedData::from_file(&seed_file)
        .context(format!("Failed to load seed data from {}", seed_file))?;

    seed_data
        .validate()
        .context("Seed data validation failed")?;

    // Connect to database
    println!("🔌 Connecting to database...");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .context("Failed to connect to database")?;

    // Insert seed data
    println!("📝 Inserting seed data...");
    insert_seed_data(&pool, &seed_data).await?;

    println!("✅ Seed data inserted successfully!");

    Ok(())
}

fn load_database_url(env_file: &str) -> Result<String> {
    let content =
        std::fs::read_to_string(env_file).context(format!("Failed to read {}", env_file))?;

    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("DATABASE_URL=") {
            return Ok(line.replace("DATABASE_URL=", ""));
        }
    }

    anyhow::bail!("DATABASE_URL not found in {}", env_file)
}

async fn insert_seed_data(pool: &PgPool, seed_data: &SeedData) -> Result<()> {
    // Start a transaction
    let mut tx = pool.begin().await?;

    // identity_providers
    let mut ip_qb = QueryBuilder::new("INSERT INTO identity_providers (name)");
    ip_qb.push_values(&seed_data.identity_providers, |mut b, ip| {
        b.push_bind(&ip.name);
    });
    ip_qb.push("ON CONFLICT DO NOTHING");

    let result = ip_qb.build().execute(&mut *tx).await?;
    println!(
        "  ✓ identity_providers: {} rows affected",
        result.rows_affected()
    );

    // storage_types
    let mut st_qb = QueryBuilder::new("INSERT INTO storage_types (name)");
    st_qb.push_values(&seed_data.storage_types, |mut b, st| {
        b.push_bind(&st.name);
    });
    st_qb.push("ON CONFLICT DO NOTHING");

    let result = st_qb.build().execute(&mut *tx).await?;
    println!(
        "  ✓ storage_types: {} rows affected",
        result.rows_affected()
    );

    tx.commit().await?;

    Ok(())
}
