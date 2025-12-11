// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedERC20 is ERC20, Ownable {
    uint256 private _maxSupply;
    uint256 private _totalBurned;
    
    // 定义扩展事件
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event MaxSupplyUpdated(uint256 oldMaxSupply, uint256 newMaxSupply);

    /**
     * @dev 构造函数，初始化代币
     * @param name_ 代币名称
     * @param symbol_ 代币符号
     * @param initialSupply_ 初始供应量
     * @param maxSupply_ 最大供应量
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(initialSupply_ <= maxSupply_, "Initial supply exceeds max supply");
        _maxSupply = maxSupply_;
        _totalBurned = 0;
        
        if (initialSupply_ > 0) {
            _mint(msg.sender, initialSupply_);
        }
    }

    /**
     * @dev 仅所有者可以调用的铸币函数
     * @param to 接收铸币的地址
     * @param amount 铸币数量
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Mint to the zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(totalSupply() + amount <= _maxSupply, "Exceeds max supply");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev 任何人都可以销毁自己代币的函数
     * @param amount 销毁数量
     */
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        _burn(msg.sender, amount);
        _totalBurned += amount;
        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @dev 销毁他人代币的函数（需要授权）
     * @param account 代币持有者地址
     * @param amount 销毁数量
     */
    function burnFrom(address account, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
        _totalBurned += amount;
        emit TokensBurned(account, amount);
    }

    /**
     * @dev 更新最大供应量（仅所有者）
     * @param newMaxSupply 新的最大供应量
     */
    function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
        require(newMaxSupply >= totalSupply(), "New max supply less than current supply");
        uint256 oldMaxSupply = _maxSupply;
        _maxSupply = newMaxSupply;
        emit MaxSupplyUpdated(oldMaxSupply, newMaxSupply);
    }

    /**
     * @dev 获取最大供应量
     */
    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev 获取已销毁代币总量
     */
    function totalBurned() external view returns (uint256) {
        return _totalBurned;
    }
}