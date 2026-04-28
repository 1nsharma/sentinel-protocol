const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Sentinel Protocol: AuthorityLedger", function () {
  let AuthorityLedger;
  let ledger;
  let owner;
  let addr1;

  beforeEach(async function () {
    AuthorityLedger = await ethers.getContractFactory("AuthorityLedger");
    [owner, addr1] = await ethers.getSigners();
    ledger = await AuthorityLedger.deploy();
  });

  it("Should register a human identity correctly", async function () {
    await ledger.connect(addr1).registerIdentity("did:sentinel:test", true);
    const identity = await ledger.identities(addr1.address);
    expect(identity.did).to.equal("did:sentinel:test");
    expect(identity.isHumanVerified).to.equal(true);
  });

  it("Should register an asset for a verified human", async function () {
    await ledger.connect(addr1).registerIdentity("did:sentinel:test", true);
    const assetHash = "0xhash123";
    await ledger.connect(addr1).registerAsset(assetHash);
    
    const [isVerified, creator, timestamp] = await ledger.verifyAsset(assetHash);
    expect(isVerified).to.equal(true);
    expect(creator).to.equal(addr1.address);
  });

  it("Should fail if a non-verified user registers an asset", async function () {
    const assetHash = "0xhash123";
    await expect(ledger.connect(addr1).registerAsset(assetHash)).to.be.revertedWith(
      "Creator must be a verified human"
    );
  });
});
