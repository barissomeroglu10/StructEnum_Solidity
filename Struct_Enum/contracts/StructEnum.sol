// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract StructEnum {

    // Enum to represent the status of an order
    enum Status {Taken, Preparing, Boxed, Shipped} // Enum values mapped to 0, 1, 2, 3

    // Struct to represent an order
    struct Order {
        address customer; // Address of the customer who placed the order
        string ZipCode;   // Zip code of the delivery address
        uint256[] products; // List of product IDs in the order
        Status status;    // Current status of the order
    }

    Order[] public orders; // Array to store all orders

    address public owner; // Address of the contract owner (administrator)

    // Constructor to set the owner of the contract
    constructor() {
        owner = msg.sender; // Initialize the owner as the deployer of the contract
    }

    /**
     * @dev Function to create a new order
     * @param _zipCode Delivery zip code for the order
     * @param _products List of product IDs in the order
     * @return Returns the ID of the created order
     */
    function CreateOrder(string memory _zipCode, uint256[] memory _products) external returns (uint256) {

        require(_products.length > 0, "No products."); // Ensure the order has at least one product

        Order memory order; // Create a new order in memory
        
        // Populate the order details
        order.customer = msg.sender;
        order.ZipCode = _zipCode;
        order.products = _products;
        order.status = Status.Taken; // Set initial status to 'Taken'

        orders.push(order); // Add the new order to the orders array

        // Return the index of the created order (order ID)
        return orders.length - 1; // 0-based indexing
    }

    /**
     * @dev Function to advance the status of an order
     * @param _orderId ID of the order to be advanced
     */
    function AdvanceOrder(uint256 _orderId) public  {
        require(owner == msg.sender, "You are not authorized"); // Only the owner can advance an order
        require(_orderId < orders.length, "Not a valid order id"); // Ensure the order ID is valid

        Order storage order = orders[_orderId]; // Fetch the order using storage reference

        require(order.status != Status.Shipped, "Order is already shipped."); // Ensure the order is not already shipped

        // Transition to the next status
        if (order.status == Status.Taken) {
            order.status = Status.Preparing;
        }
        else if (order.status == Status.Preparing) {
            order.status = Status.Boxed;
        }
        else if (order.status == Status.Boxed) {
            order.status = Status.Shipped;
        }
    }

    /**
     * @dev Function to fetch the details of a specific order
     * @param _orderId ID of the order to fetch
     * @return The Order struct for the specified order
     */
    function GetOrder(uint256 _orderId) external view returns (Order memory) {
        require(_orderId < orders.length, "Not a valid order id."); // Ensure the order ID is valid

        return orders[_orderId]; // Return the order details
    }

    /**
     * @dev Function to update the zip code of an existing order
     * @param _orderId ID of the order to update
     * @param _zip New zip code for the order
     */
    function UpdateZip(uint256 _orderId, string memory _zip) external  {
        require(_orderId < orders.length, "Not a valid order id."); // Ensure the order ID is valid

        Order storage order = orders[_orderId]; // Fetch the order using storage reference
        
        require(order.customer == msg.sender, "You are not owner of the order."); // Ensure only the customer can update their order

        order.ZipCode = _zip; // Update the zip code
    }
}