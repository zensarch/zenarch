// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedCrowdfunding {
    struct RewardTier {
        uint minContribution;
        string rewardDescription;
    }

    struct Milestone {
        string description;
        uint releaseAmount;
        bool isReleased;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    struct Campaign {
        address payable creator;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool goalReached;
        bool isClosed;
        mapping(address => uint) contributions;
        RewardTier[] rewardTiers;
        Milestone[] milestones;
        address[] contributors;
    }

    uint public campaignCount;
    mapping(uint => Campaign) public campaigns;

    modifier onlyCreator(uint _id) {
        require(msg.sender == campaigns[_id].creator, "Not campaign creator");
        _;
    }

    modifier campaignExists(uint _id) {
        require(_id < campaignCount, "Campaign does not exist");
        _;
    }

    event CampaignCreated(uint indexed id, address creator, uint goal, uint deadline);
    event ContributionMade(uint indexed id, address contributor, uint amount);
    event RefundClaimed(uint indexed id, address contributor);
    event MilestoneProposed(uint indexed id, uint index, string description, uint amount);
    event MilestoneApproved(uint indexed id, uint index, address voter);
    event FundsReleased(uint indexed id, uint index);

    function createCampaign(
        uint _goal, 
        uint _durationInDays, 
        RewardTier[] memory _rewardTiers
    ) public {
        Campaign storage c = campaigns[campaignCount];
        c.creator = payable(msg.sender);
        c.goal = _goal;
        c.deadline = block.timestamp + (_durationInDays * 1 days);
        
        for (uint i = 0; i < _rewardTiers.length; i++) {
            c.rewardTiers.push(_rewardTiers[i]);
        }
        
        emit CampaignCreated(campaignCount, msg.sender, _goal, c.deadline);
        campaignCount++;
    }

    function contribute(uint _id) public payable campaignExists(_id) {
        Campaign storage c = campaigns[_id];
        require(block.timestamp < c.deadline, "Campaign ended");
        require(msg.value > 0, "Zero contribution");
        require(!c.isClosed, "Campaign is closed");
        
        if (c.contributions[msg.sender] == 0) {
            c.contributors.push(msg.sender);
        }
        
        c.contributions[msg.sender] += msg.value;
        c.amountRaised += msg.value;
        
        // Check if goal is reached
        if (c.amountRaised >= c.goal && !c.goalReached) {
            c.goalReached = true;
        }
        
        emit ContributionMade(_id, msg.sender, msg.value);
    }

    function claimRefund(uint _id) public campaignExists(_id) {
        Campaign storage c = campaigns[_id];
        require(block.timestamp >= c.deadline, "Campaign still active");
        require(c.amountRaised < c.goal, "Goal was reached");
        
        uint amount = c.contributions[msg.sender];
        require(amount > 0, "No contributions to refund");
        
        c.contributions[msg.sender] = 0;
        c.amountRaised -= amount; // Update total raised amount
        
        payable(msg.sender).transfer(amount);
        emit RefundClaimed(_id, msg.sender);
    }

    function proposeMilestone(
        uint _id, 
        string memory _desc, 
        uint _amount
    ) public onlyCreator(_id) campaignExists(_id) {
        Campaign storage c = campaigns[_id];
        require(c.amountRaised >= c.goal, "Goal not reached yet");
        require(!c.isClosed, "Campaign is closed");
        
        // Create new milestone
        c.milestones.push();
        uint newIndex = c.milestones.length - 1;
        
        Milestone storage m = c.milestones[newIndex];
        m.description = _desc;
        m.releaseAmount = _amount;
        
        emit MilestoneProposed(_id, newIndex, _desc, _amount);
    }

    function approveMilestone(uint _id, uint _milestoneIndex) public campaignExists(_id) {
        Campaign storage c = campaigns[_id];
        require(_milestoneIndex < c.milestones.length, "Milestone does not exist");
        
        Milestone storage m = c.milestones[_milestoneIndex];
        require(c.contributions[msg.sender] > 0, "Not a contributor");
        require(!m.approvals[msg.sender], "Already approved");
        require(!m.isReleased, "Milestone already released");
        
        m.approvals[msg.sender] = true;
        m.approvalCount++;
        
        emit MilestoneApproved(_id, _milestoneIndex, msg.sender);
    }

    function releaseFunds(uint _id, uint _milestoneIndex) public onlyCreator(_id) campaignExists(_id) {
        Campaign storage c = campaigns[_id];
        require(_milestoneIndex < c.milestones.length, "Milestone does not exist");
        
        Milestone storage m = c.milestones[_milestoneIndex];
        require(!m.isReleased, "Already released");
        require(m.approvalCount > c.contributors.length / 2, "Not enough approvals");
        require(address(this).balance >= m.releaseAmount, "Insufficient contract balance");
        
        m.isReleased = true;
        c.creator.transfer(m.releaseAmount);
        
        emit FundsReleased(_id, _milestoneIndex);
    }

    // Additional utility functions
    function getCampaignDetails(uint _id) public view campaignExists(_id) returns (
        address creator,
        uint goal,
        uint deadline,
        uint amountRaised,
        bool goalReached,
        bool isClosed,
        uint contributorCount,
        uint milestoneCount
    ) {
        Campaign storage c = campaigns[_id];
        return (
            c.creator,
            c.goal,
            c.deadline,
            c.amountRaised,
            c.goalReached,
            c.isClosed,
            c.contributors.length,
            c.milestones.length
        );
    }

    function getContribution(uint _id, address _contributor) public view campaignExists(_id) returns (uint) {
        return campaigns[_id].contributions[_contributor];
    }

    function getMilestoneDetails(uint _id, uint _milestoneIndex) public view campaignExists(_id) returns (
        string memory description,
        uint releaseAmount,
        bool isReleased,
        uint approvalCount
    ) {
        require(_milestoneIndex < campaigns[_id].milestones.length, "Milestone does not exist");
        Milestone storage m = campaigns[_id].milestones[_milestoneIndex];
        return (m.description, m.releaseAmount, m.isReleased, m.approvalCount);
    }

    function getRewardTier(uint _id, uint _tierIndex) public view campaignExists(_id) returns (
        uint minContribution,
        string memory rewardDescription
    ) {
        require(_tierIndex < campaigns[_id].rewardTiers.length, "Reward tier does not exist");
        RewardTier storage tier = campaigns[_id].rewardTiers[_tierIndex];
        return (tier.minContribution, tier.rewardDescription);
    }

    function closeCampaign(uint _id) public onlyCreator(_id) campaignExists(_id) {
        campaigns[_id].isClosed = true;
    }
}
