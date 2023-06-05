// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlphaCoin {
    string public name = "AlphaCoin";
    string public symbol = "ALPHA";
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    uint256 public buyTaxPercent = 4;
    uint256 public sellTaxPercent = 4;
    address public taxAddress = 0x5Ae0af2560c731eBF15FB95A0789E1fA527e90fd;
    address public owner;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than zero.");
        require(balances[msg.sender] >= amount, "Insufficient balance.");

        uint256 buyTaxAmount = (amount * buyTaxPercent) / 100;
        uint256 sellTaxAmount = (amount * sellTaxPercent) / 100;
        uint256 transferAmount = amount;

        if (msg.sender == address(this)) {
            // Excludes tax for contract-to-contract transfers
            transferAmount = amount;
        } else if (to == address(this)) {
            // Sell tax
            require(amount > sellTaxAmount, "Amount must be greater than the sell tax.");
            transferAmount = amount - sellTaxAmount;

            // Send sell tax to taxAddress
            balances[taxAddress] += sellTaxAmount;
        } else {
            // Buy tax
            transferAmount = amount - buyTaxAmount;

            // Send buy tax to taxAddress
            balances[taxAddress] += buyTaxAmount;
        }

        balances[msg.sender] -= amount;
        balances[to] += transferAmount;

        return true;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address.");
        owner = newOwner;
    }
}
