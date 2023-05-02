// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Crowdfunding {
    address payable public owner;
    address payable public entrepreneur;
    uint256 public goal;
    uint256 public deadline;
    bool public closed;

    constructor() {
        owner = payable(msg.sender);
    }

    // Functions
    function createCampaign(uint256 _goal, uint256 _durationInMonths) public {
        require(
            owner != msg.sender,
            "The entrepreneur cannot be the contract owner"
        );
        require(
            _durationInMonths >= 1 && _durationInMonths <= 6,
            "The duration of the campaign should be 1 to 6 months"
        );
        require(_goal > 0, "The goal must be greater than zero");

        entrepreneur = payable(msg.sender);
        goal = _goal;
        deadline = block.timestamp + (_durationInMonths * 30 days);
    }

    function extendDeadline() public {
        require(
            entrepreneur != address(0),
            "The campaign must first be created"
        );
        require(
            msg.sender == entrepreneur,
            "Only the enterepreneur can extend the deadline"
        );
        require(!closed, "The campaign has been closed");
        require(
            block.timestamp >= deadline - 1 days,
            "The campaign can only be extended in the last day"
        );

        deadline += 15 days;
    }
}
