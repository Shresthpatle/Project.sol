// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// MultiChainLearningRewards.sol

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MultiChainLearningRewards {

    address public owner;
    mapping(address => uint256) public rewardsBalance;
    mapping(address => mapping(string => bool)) public completedTasks;
    mapping(string => uint256) public taskRewardPoints;
    mapping(address => uint256) public totalRewardsEarned;

    // Multi-chain Token contract address (for reward transfer)
    address public rewardTokenAddress;

    event RewardClaimed(address indexed user, uint256 amount);
    event TaskCompleted(address indexed user, string taskId, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier hasCompletedTask(string memory taskId) {
        require(completedTasks[msg.sender][taskId] == false, "Task already completed");
        _;
    }

    constructor(address _rewardTokenAddress) {
        owner = msg.sender;
        rewardTokenAddress = _rewardTokenAddress;
    }

    // Function to set the reward for a specific task
    function setTaskReward(string memory taskId, uint256 rewardPoints) public onlyOwner {
        taskRewardPoints[taskId] = rewardPoints;
    }

    // Function to mark a task as completed by the user
    function completeTask(string memory taskId) public hasCompletedTask(taskId) {
        uint256 reward = taskRewardPoints[taskId];
        require(reward > 0, "No reward set for this task");

        // Mark the task as completed
        completedTasks[msg.sender][taskId] = true;

        // Increase user's reward balance
        rewardsBalance[msg.sender] += reward;
        totalRewardsEarned[msg.sender] += reward;

        emit TaskCompleted(msg.sender, taskId, reward);
    }

    // Function to claim rewards
    function claimRewards() public {
        uint256 rewardAmount = rewardsBalance[msg.sender];
        require(rewardAmount > 0, "No rewards to claim");

        // Reset user's reward balance after claiming
        rewardsBalance[msg.sender] = 0;

        // Transfer rewards from the multi-chain token contract
        IERC20(rewardTokenAddress).transfer(msg.sender, rewardAmount);

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    // Function to view the reward balance of the user
    function viewRewardBalance(address user) public view returns (uint256) {
        return rewardsBalance[user];
    }

    // Function to change the reward token address (in case of migration)
    function changeRewardTokenAddress(address newTokenAddress) public onlyOwner {
        rewardTokenAddress = newTokenAddress;
    }

    // Function to view the reward details of a specific task
    function getTaskReward(string memory taskId) public view returns (uint256) {
        return taskRewardPoints[taskId];
    }
}
