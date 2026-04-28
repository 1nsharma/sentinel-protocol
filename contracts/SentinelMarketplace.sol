// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SentinelMarketplace
 * @dev The world's first "Provable Content Economy".
 * AI Companies deposit funds here to buy training licenses for Neural-Verified Organic Data.
 * 1nsharma (Platform) takes a 2.5% cut. Creators get 97.5%.
 */
contract SentinelMarketplace {
    address payable public platformOwner; // 1nsharma's Wallet
    uint256 public platformFeePercentage = 25; // 2.5% (Basis points: 25 / 1000)

    struct DataLicense {
        address payable creator;
        uint256 price; // Price in Wei to train AI on this data
        bool isActive;
        uint256 totalSales;
    }

    // Mapping from C2PA Asset Hash to its License details
    mapping(string => DataLicense) public licenses;

    event LicenseListed(string c2paHash, address creator, uint256 price);
    event LicensePurchased(string c2paHash, address buyer, uint256 amountPaid);

    constructor() {
        platformOwner = payable(msg.sender); // The deployer (1nsharma) gets the fees
    }

    // Creator lists their verified organic asset for sale to AI companies
    function listDataForAI(string memory _c2paHash, uint256 _price) public {
        require(_price > 0, "Price must be greater than 0");
        licenses[_c2paHash] = DataLicense({
            creator: payable(msg.sender),
            price: _price,
            isActive: true,
            totalSales: 0
        });
        emit LicenseListed(_c2paHash, msg.sender, _price);
    }

    // AI Company (Google/OpenAI) buys the right to train on this specific hash
    function buyTrainingLicense(string memory _c2paHash) public payable {
        DataLicense storage license = licenses[_c2paHash];
        require(license.isActive, "License not available");
        require(msg.value >= license.price, "Insufficient funds sent");

        // Calculate 2.5% Platform Fee for 1nsharma
        uint256 platformFee = (msg.value * platformFeePercentage) / 1000;
        uint256 creatorShare = msg.value - platformFee;

        // Route the money instantly
        platformOwner.transfer(platformFee);
        license.creator.transfer(creatorShare);

        license.totalSales += 1;

        emit LicensePurchased(_c2paHash, msg.sender, msg.value);
    }
}
