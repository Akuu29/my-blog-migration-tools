use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct IdentityProvider {
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct StorageType {
    pub name: String,
}

/// Represents the complete seed data structure for all lookup tables
#[derive(Debug, Deserialize)]
pub struct SeedData {
    /// List of identity provider names (e.g., "Firebase", "Auth0")
    pub identity_providers: Vec<IdentityProvider>,
    /// List of storage type names (e.g., "database", "s3")
    pub storage_types: Vec<StorageType>,
}

impl SeedData {
    /// Load seed data from a JSON file
    pub fn from_file(path: &str) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        let seed_data: SeedData = serde_json::from_str(&content)?;
        Ok(seed_data)
    }

    /// Validate that seed data is not empty
    pub fn validate(&self) -> anyhow::Result<()> {
        if self.identity_providers.is_empty() {
            anyhow::bail!("identity_providers cannot be empty");
        }
        if self.storage_types.is_empty() {
            anyhow::bail!("storage_types cannot be empty");
        }
        Ok(())
    }
}
