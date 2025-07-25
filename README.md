# DECENTRALISED CROWDFUNDING PLATFORM 

This is a comprehensive decentralized crowdfunding platform with the following key features:
Main Features:
## 1. Campaign Creation

Create campaigns with goals, deadlines, and milestone-based funding
Milestones must add up to 100% of funding
Each milestone has a description and funding percentage

## 2. Contribution System

Contributors can fund campaigns with ETH
Tracks individual contributions and timestamps
Automatically checks if funding goals are reached

## 3. Milestone-Based Fund Release

Creators submit milestone completions for voting
Contributors vote on milestone completion (7-day voting period)
Funds are released only after milestone approval
Platform takes a small fee (default 2.5%)

## 4. Refund Mechanism

Automatic refunds if campaign fails to reach goal by deadline
Refunds available if milestones are consistently rejected

## 5. Security Features

ReentrancyGuard prevents reentrancy attacks
SafeMath prevents overflow/underflow
Proper access controls and modifiers

## Key Functions:

createCampaign() - Create new campaigns with milestones
contribute() - Fund campaigns
submitMilestoneCompletion() - Submit milestones for voting
voteOnMilestone() - Vote on milestone completion
finalizeMilestone() - Release funds after successful voting
requestRefund() - Get refunds for failed campaigns

## Usage Notes:

Dependencies: Requires OpenZeppelin contracts for security
Deployment: Deploy with proper constructor parameters
Testing: Test thoroughly on testnet before mainnet deployment
Gas Optimization: Consider gas costs for large contributor lists

The contract includes comprehensive error handling, events for frontend integration, and getter functions for retrieving campaign and milestone data. You can extend it further with features like campaign categories, reward tiers, or integration with ERC-20 tokens.

## Contract address: 
0x32AF8a58a38A3248c427c2d5e450C1A2BA69c110

<img width="1363" height="598" alt="image" src="https://github.com/user-attachments/assets/8e86fcba-bb77-4134-a978-ed7fd26d95c8" />

