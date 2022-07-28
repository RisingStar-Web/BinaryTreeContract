// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Funding is Ownable {
    using Counters for Counters.Counter;
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 startTime;
        uint256 endTime;
        uint256 totalPledged;
        uint256 totalClaimed;
        bool status;
    }

    struct Pledged {
        address owner;
        uint256 amount;
    }

    mapping(uint256 => Campaign) campaigns;
    mapping(uint256 => Pledged) pledgeds;

    Counters.Counter private _campaignIds;

    event LaunchCampaign(uint256 goal, uint256 startTime, uint256 endTime);
    event CancelCampaign(uint256 campaignId);
    event PledgedTokens(uint256 campaignId);
    event ClaimTokens(uint256 campaignId);
    event RefundTokens(uint256 campaignId);

    constructor() {

    }

    function launchCampaign(uint256 goal, uint256 startTime, uint256 endTime) external {
        uint256 campaignId = _campaignIds.current();
        campaigns[campaignId] = Campaign({
            creator: msg.sender,
            goal: goal,
            startTime: startTime,
            endTime: endTime,
            totalPledged: 0,
            totalClaimed: 0,
            status: true
        });
        _campaignIds.increment();
        emit LaunchCampaign(goal, startTime, endTime);
    }

    function cancelCampaign(uint256 campaignId) external {
        require(msg.sender == campaigns[campaignId].creator);
        require(block.timestamp < campaigns[campaignId].startTime);
        campaigns[campaignId].status = false;
        emit CancelCampaign(campaignId);
    }

    function pledgeTokens(uint256 campaignId) external payable {
        require(campaigns[campaignId].creator != address(0), "Campaign is not exist");
        require(campaigns[campaignId].startTime < block.timestamp, "Campaign is not started");
        require(campaigns[campaignId].status == true, "Campaign is not active");
        pledgeds[campaignId] = Pledged({
            owner: msg.sender,
            amount: msg.value
        });
        campaigns[campaignId].totalPledged += msg.value;
        emit PledgedTokens(campaignId);
    }

    function claimTokens(uint256 campaignId) external {
        require(campaigns[campaignId].creator == msg.sender);
        campaigns[campaignId].totalPledged = 0;
        payable(msg.sender).transfer(campaigns[campaignId].totalPledged);
        emit ClaimTokens(campaignId);
    }

    function refundToken(uint256 campaignId) external {
        require(pledgeds[campaignId].owner == msg.sender);
        require(pledgeds[campaignId].amount > 0);
        uint256 amount = pledgeds[campaignId].amount;
        pledgeds[campaignId].amount = 0;
        campaigns[campaignId].totalClaimed += amount;
        campaigns[campaignId].totalPledged -= amount;
        payable(msg.sender).transfer(amount);
        emit RefundTokens(campaignId);
    }
}