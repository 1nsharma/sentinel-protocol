// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AuthorityLedger
 * @dev Sentinel Protocol - Authority Ledger for Digital Truth
 * This contract stores verified Content Proof-of-Origin (CPO) hashes
 * and Unified Human Identities (UHI).
 */
contract AuthorityLedger {
    struct Asset {
        string c2paHash;
        address creator;
        uint256 timestamp;
        bool isVerified;
    }

    struct Identity {
        string did; // Decentralized Identifier
        bool isHumanVerified; // Verified via ZK-Proof off-chain
    }

    mapping(string => Asset) public verifiedAssets;
    mapping(address => Identity) public identities;

    event AssetRegistered(string c2paHash, address indexed creator, uint256 timestamp);
    event IdentityVerified(address indexed user, string did);

    // Register a user identity (UHI)
    function registerIdentity(string memory _did, bool _isHuman) public {
        identities[msg.sender] = Identity(_did, _isHuman);
        emit IdentityVerified(msg.sender, _did);
    }

    // Register an asset with CPO (Content Proof-of-Origin)
    function registerAsset(string memory _c2paHash) public {
        require(bytes(verifiedAssets[_c2paHash].c2paHash).length == 0, "Asset already registered");
        require(identities[msg.sender].isHumanVerified, "Creator must be a verified human");

        verifiedAssets[_c2paHash] = Asset({
            c2paHash: _c2paHash,
            creator: msg.sender,
            timestamp: block.timestamp,
            isVerified: true
        });

        emit AssetRegistered(_c2paHash, msg.sender, block.timestamp);
    }

    // Verify if an asset exists and is authentic
    function verifyAsset(string memory _c2paHash) public view returns (bool, address, uint256) {
        Asset memory asset = verifiedAssets[_c2paHash];
        return (asset.isVerified, asset.creator, asset.timestamp);
    }
}
