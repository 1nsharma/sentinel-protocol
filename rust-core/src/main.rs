use sha2::{Sha512, Digest};
use chrono::Utc;
use serde::{Serialize, Deserialize};
use ed25519_dalek::{Keypair, Signer, Verifier, Signature, PublicKey, SecretKey};
use rand::rngs::OsRng;

#[derive(Serialize, Deserialize, Debug)]
struct SentinelManifest {
    creator_id: String,
    did: String,
    content_hash: String,
    timestamp: i64,
    entropy_score: f64,
    sra_hardware_id: String,
}

struct TruthEngine {
    keypair: Keypair,
}

impl TruthEngine {
    fn new() -> Self {
        let mut csprng = OsRng;
        let keypair = Keypair::generate(&mut csprng);
        Self { keypair }
    }

    /// [SRA] Sign Content Right Away (Inside TEE simulation)
    fn anchor_content(&self, data: &[u8], creator_id: &str, did: &str) -> (SentinelManifest, String) {
        // Calculate Real Shannon Entropy
        let entropy = self.calculate_entropy(data);
        
        // Quantum-Resistant Hash (SHA-512)
        let mut hasher = Sha512::new();
        hasher.update(data);
        let content_hash = format!("{:x}", hasher.finalize());

        let manifest = SentinelManifest {
            creator_id: creator_id.to_string(),
            did: did.to_string(),
            content_hash,
            timestamp: Utc::now().timestamp(),
            entropy_score: entropy,
            sra_hardware_id: "TEE_SECURE_ENCLAVE_v4".to_string(),
        };

        let manifest_json = serde_json::to_string(&manifest).unwrap();
        let signature = self.keypair.sign(manifest_json.as_bytes());
        
        (manifest, base64::encode(signature.to_bytes()))
    }

    fn calculate_entropy(&self, data: &[u8]) -> f64 {
        let mut counts = [0u64; 256];
        for &byte in data {
            counts[byte as usize] += 1;
        }
        let len = data.len() as f64;
        let mut entropy = 0.0;
        for &count in counts.iter() {
            if count > 0 {
                let p = count as f64 / len;
                entropy -= p * p.log2();
            }
        }
        entropy
    }
}

fn main() {
    println!("--- SENTINEL CORE v4.0 (RUST PROTOTYPE) ---");
    println!("Initializing Distributed Authority System...");

    let engine = TruthEngine::new();
    
    // Simulation: Virasat Chai captures a photo of his organic tea
    let virasat_chai_photo = b"REAL_PHYSICS_BASED_ORGANIC_IMAGE_DATA_123456789";
    
    let (manifest, signature) = engine.anchor_content(
        virasat_chai_photo, 
        "Virasat_Chai_Kanpur", 
        "did:sentinel:human_0099"
    );

    println!("\n✅ CONTENT ANCHORED SUCCESSFULLY");
    println!("-----------------------------------");
    println!("Creator:   {}", manifest.creator_id);
    println!("DID:       {}", manifest.did);
    println!("Entropy:   {:.6} (Organic: {})", manifest.entropy_score, manifest.entropy_score > 7.4);
    println!("Hash:      {}...", &manifest.content_hash[0..24]);
    println!("Signature: {}...", &signature[0..32]);
    println!("-----------------------------------");
    println!("Status: READY FOR L2 LEDGER ANCHORING");
}
