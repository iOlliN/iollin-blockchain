// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract Crowdfunding {
    address public owner;
    address public entrepreneur;
    uint256 public goal;
    uint256 public deadline;
    uint256 public collectedAmount;
    bool public closed;
    mapping(address => uint256) public backers;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    constructor(
        address _entrepreneur,
        uint256 _goal,
        uint256 _durationInMonths
    ) {
        require(
            _durationInMonths >= 1 && _durationInMonths <= 6, // min. 1 months or max. 6 months
            "The duration of the campaign should be 1 to 6 months"
        );
        owner = msg.sender;
        entrepreneur = _entrepreneur;
        goal = _goal;
        deadline = block.timestamp + (_durationInMonths * 30 days);
    }

    // Functions
    function contribute(uint256 amountInEther) public payable {
        require(!closed, "The campaign has been closed");
        require(
            block.timestamp < deadline,
            "The campaign deadline has expired"
        );
        uint256 amountInWei = amountInEther * 1 ether;
        require(
            amountInWei <= address(msg.sender).balance,
            "Insufficient balance"
        );
        backers[msg.sender] += amountInWei;
        collectedAmount += amountInEther;
        emit FundTransfer(msg.sender, amountInWei, true);
        if (collectedAmount >= goal) {
            closed = true;
            emit GoalReached(entrepreneur, collectedAmount);
        }
    }

    function checkGoalReached() public {
        require(!closed, "The campaign is already closed");
        if (collectedAmount >= goal) {
            uint256 amount = collectedAmount;
            collectedAmount = 0;
            uint256 commission = (amount * 3) / 100; // 3% commission
            payable(owner).transfer(commission);
            payable(entrepreneur).transfer(amount - commission);
            emit GoalReached(owner, collectedAmount);
        } else if (block.timestamp >= deadline) {
            // Allow extension of the campaign
        } else {
            // Campaign is still ongoing
            return;
        }
        closed = true;
    }

    function extendDeadline() public {
        require(msg.sender == owner, "Only the owner can extend the deadline");
        require(!closed, "The campaign has been closed");
        require(
            block.timestamp >= deadline - 1 days,
            "The campaign can only be extended in the last day"
        );

        deadline += 15 days;
    }

    function withdraw() public {
        require(
            msg.sender == entrepreneur,
            "Only the entrepreneur can withdraw funds"
        );
        require(closed, "The campaign is still ongoing");

        uint256 amount = collectedAmount;
        collectedAmount = 0;

        uint256 commission = (amount * 3) / 100; // 3% commission for the owner
        payable(owner).transfer(commission);
        payable(msg.sender).transfer(amount - commission);
    }

    function timeLeft() public view returns (string memory) {
        if (closed) {
            return "The campaign is closed";
        } else {
            uint256 timeLeftInSeconds = deadline - block.timestamp;
            uint256 monthsLeft = timeLeftInSeconds / 30 days;
            uint256 daysLeft = (timeLeftInSeconds % 30 days) / 1 days;

            return
                string(
                    abi.encodePacked(
                        "There are ",
                        toString(monthsLeft),
                        " months and ",
                        toString(daysLeft),
                        " days to the end of the campaign"
                    )
                );
        }
    }

    function toString(uint256 _num) internal pure returns (string memory) {
        if (_num == 0) {
            return "0";
        }
        uint256 i = _num;
        uint256 j = _num;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (i != 0) {
            bstr[k--] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }
}