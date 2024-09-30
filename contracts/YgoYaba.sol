// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract YgoYabaContract {
    uint256 public itemCount;
    IERC20 public platformToken;
    uint8 public maxFreePurchases = 2;
    uint8 public maxPaidPurchases = 4;
    uint public freeListingReward = 2;

    event ItemListed(uint256 indexed itemId, address seller, uint256 indexed price, string indexed _itemName, string _itemImage);
    event ItemBought(uint256 indexed itemId, address buyer, uint256 indexed price, string indexed _itemName, string _itemImage);

    constructor(address tokenAddress) {
        platformToken = IERC20(tokenAddress);
    }

    struct Item {
        uint256 id;
        string itemName;
        string itemImage;
        address payable seller;
        uint256 price;
        bool isFree;
        bool sold;
    }

    Item[] public allItems;
    // track item by ID
    mapping(uint256 => Item) public items;
    // track user by purchase type
    mapping(address => uint256) public freePurchases;
    mapping(address => uint256) public paidPurchases;
    mapping(address => mapping(uint => bool)) public claimedReward;

    function listItem(string memory _itemName, uint _price, string memory _itemImage) external {
        require(msg.sender != address(0), "Invalid address");
        itemCount++;
        Item storage newItem = items[itemCount];

        newItem.id = itemCount;
        newItem.seller = payable(msg.sender);
        newItem.itemName = _itemName;
        newItem.itemImage = _itemImage;
        newItem.price = _price;
        newItem.isFree = (_price == 0);
        if (_price == 0) {
            newItem.isFree = true;
        }

        allItems.push(newItem);
        emit ItemListed(itemCount, msg.sender, _price, _itemName, _itemImage);
    }

    function buyItem(uint _itemId) external {
        require(msg.sender != address(0), "Invalid address");
        Item storage targetItem = items[_itemId];
        require(targetItem.id != 0, "item doesnt exist");
        require(!targetItem.sold, "Item already sold");
        require(msg.sender != targetItem.seller, "Seller cant buy their own item");

        if (targetItem.isFree) {
            require(freePurchases[msg.sender] < maxFreePurchases, "Free purchase limit reached");
            freePurchases[msg.sender]++;
        } else {
            require(paidPurchases[msg.sender] < maxPaidPurchases, "Paid purchase limit reached");
            require(platformToken.transferFrom(msg.sender, address(this), targetItem.price), "Token transfer failed");
            paidPurchases[msg.sender]++;
        }

        targetItem.sold = true;
        emit ItemBought(_itemId, msg.sender, targetItem.price, targetItem.itemName, targetItem.itemImage);
    }

    function withdrawFunds(uint _itemId) external {
        require(msg.sender != address(0), "Invalid address");
        Item storage targetItem = items[_itemId];
        require(targetItem.id != 0, "item doesnt exist");
        require(targetItem.sold, "Item has not been sold");
        require(msg.sender == targetItem.seller, "You are not the seller");
        require(msg.sender != targetItem.seller, "Seller cant buy their own item");

        if (!targetItem.isFree) {
            platformToken.transfer(targetItem.seller, targetItem.price);
        }
    }

    function claimRewards(uint _itemId) external {
        require(msg.sender != address(0), "Invalid address");
        Item storage targetItem = items[_itemId];
        require(targetItem.id != 0, "item doesnt exist");
        require(msg.sender == targetItem.seller, "You are not the seller");
        require(targetItem.isFree, "You ony claim reward for free listings");
        require(!claimedReward[msg.sender][_itemId], "reward already claimed");
        require(targetItem.sold, "Item has no been purchased yet");
        require(platformToken.balanceOf(address(this)) > freeListingReward, "Please try again later");

        platformToken.transfer(targetItem.seller, freeListingReward);

        claimedReward[msg.sender][_itemId] = true;
    }

    function getAllItems() external view returns (Item[] memory) {
        return allItems;
    }
}
