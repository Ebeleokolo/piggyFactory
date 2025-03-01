// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    address public developer;
    address public owner;
    uint256 public unlockTime;
    string public purpose;
    bool public withdrawn;

    mapping(address => bool) public allowedTokens;

    error Unauthorized();
    error InvalidToken();
    error NotEnoughBalance();
   // error withdrawn
    error AlreadyWithdrawn();
    error DurationNotMet();
    error InvalidAddress();

    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawn(address indexed user, uint256 penaltyAmount);

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier isWithdrawn() {
        if (withdrawn) revert AlreadyWithdrawn();
        _;
    }

    constructor(address _owner, string memory _purpose, uint256 _duration, address _developer) {
        if (_owner == address(0) || _developer == address(0)) revert InvalidAddress();
        
        owner = _owner;
        purpose = _purpose;
        unlockTime = block.timestamp + _duration;
        developer = _developer;

        allowedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        allowedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
        allowedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI
    }

    function deposit(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) revert InvalidAddress();
        if (!allowedTokens[token]) revert InvalidToken();
        if (amount == 0) revert NotEnoughBalance();
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, token, amount);
    }

    function withdraw(address token) external onlyOwner isWithdrawn {
        if (block.timestamp < unlockTime) revert DurationNotMet();
        if (token == address(0)) revert InvalidAddress();

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert NotEnoughBalance();

        withdrawn = true;
        IERC20(token).transfer(owner, balance);
        emit Withdrawn(owner, balance);
    }

    function emergencyWithdraw(address token) external onlyOwner isWithdrawn {
        if (token == address(0) || developer == address(0)) revert InvalidAddress();
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert NotEnoughBalance();

        withdrawn = true;
        uint256 penalty = (balance * 15) / 100;
        uint256 remaining = balance - penalty;

        IERC20(token).transfer(developer, penalty);
        IERC20(token).transfer(owner, remaining);
        emit EmergencyWithdrawn(owner, penalty);
    }
}
