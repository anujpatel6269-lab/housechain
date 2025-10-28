// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HOUSECHAIN
 * @dev A decentralized platform for property listing and ownership tracking.
 */
contract HOUSECHAIN {
    struct Property {
        uint256 id;
        address owner;
        string location;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => Property) public properties;
    uint256 public propertyCount;

    event PropertyListed(uint256 indexed id, address indexed owner, string location, uint256 price);
    event PropertyTransferred(uint256 indexed id, address indexed oldOwner, address indexed newOwner, uint256 price);
    event PropertyStatusChanged(uint256 indexed id, bool forSale);

    /**
     * @dev List a new property on the blockchain.
     * @param _location The physical or descriptive location of the property.
     * @param _price The sale price of the property in wei.
     */
    function listProperty(string memory _location, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");

        propertyCount++;
        properties[propertyCount] = Property(propertyCount, msg.sender, _location, _price, true);

        emit PropertyListed(propertyCount, msg.sender, _location, _price);
    }

    /**
     * @dev Purchase a listed property.
     * @param _id The property ID to purchase.
     */
    function buyProperty(uint256 _id) external payable {
        Property storage prop = properties[_id];
        require(prop.forSale, "Property not for sale");
        require(msg.value == prop.price, "Incorrect payment amount");
        require(prop.owner != msg.sender, "Cannot buy your own property");

        address previousOwner = prop.owner;
        prop.owner = msg.sender;
        prop.forSale = false;

        payable(previousOwner).transfer(msg.value);

        emit PropertyTransferred(_id, previousOwner, msg.sender, msg.value);
    }

    /**
     * @dev Change the sale status of a property (only the owner can do this).
     * @param _id The property ID.
     * @param _forSale The new sale status.
     */
    function toggleForSale(uint256 _id, bool _forSale) external {
        Property storage prop = properties[_id];
        require(msg.sender == prop.owner, "Only owner can change sale status");
        prop.forSale = _forSale;

        emit PropertyStatusChanged(_id, _forSale);
    }
}
