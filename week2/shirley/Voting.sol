// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleERC20Voting is ERC20 {
    // 候选人结构
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    // 状态变量
    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;
    
    // 事件
    event Voted(address indexed voter, uint256 indexed candidateId);
    
    /**
     * @dev 构造函数
     * @param name 代币名称
     * @param symbol 代币符号
     * @param initialSupply 初始供应量
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        
        // 初始化候选人
        candidates.push(Candidate(0, "Candidate A", 0));
        candidates.push(Candidate(1, "Candidate B", 0));
    }
    
    /**
     * @dev 投票函数
     * @param candidateId 候选人 ID
     */
    function vote(uint256 candidateId) external {
        require(balanceOf(msg.sender) > 0, "You need tokens to vote");
        require(!hasVoted[msg.sender], "You have already voted");
        require(candidateId < candidates.length, "Invalid candidate");
        
        // 记录投票
        candidates[candidateId].voteCount++;
        hasVoted[msg.sender] = true;
        
        emit Voted(msg.sender, candidateId);
    }
    
    /**
     * @dev 查询候选人票数
     * @param candidateId 候选人 ID
     */
    function getVotes(uint256 candidateId) external view returns (uint256) {
        require(candidateId < candidates.length, "Invalid candidate");
        return candidates[candidateId].voteCount;
    }
    
    /**
     * @dev 获取所有候选人信息
     */
    function getAllCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }
    
    /**
     * @dev 检查用户是否已投票
     * @param voter 投票者地址
     */
    function checkVoted(address voter) external view returns (bool) {
        return hasVoted[voter];
    }
}