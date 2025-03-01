// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./piggy.sol";

contract PiggyBankFactory {
    // Custom Errors
    error DeploymentFailed();
    error InvalidUnlockTime();
    error ZeroAddress();
    error AlreadyWithdrawn();

    // Array to track all created banks
    PiggyBank[] public allPiggyBanks;
    
    // Immutable developer address
    address public immutable developer;

    event PiggyBankCreated(address indexed piggyBank, address indexed owner, string purpose, uint256 unlockTime);

    constructor(address _developer) {
        if(_developer == address(0)) revert ZeroAddress();
        developer = _developer;
    }

    // Modifier to check if bank is still active
    modifier isWithdrawn(PiggyBank bank) {
        if(bank.withdrawn()) revert AlreadyWithdrawn();
        _;
    }

    function createPiggyBank(
        string memory purpose, 
        uint256 unlockTime,
        bytes32 salt
    ) external returns (address) {
        if(unlockTime <= block.timestamp) revert InvalidUnlockTime();

        // Include developer address in bytecode
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(msg.sender, developer, purpose, unlockTime)
        );

        // Deploy with CREATE2
        address newBank;
        assembly {
            newBank := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(newBank) {
                revert(0, 0)
            }
        }

        if(newBank == address(0)) revert DeploymentFailed();

        // Track the new piggy bank
        allPiggyBanks.push(PiggyBank(newBank));

        emit PiggyBankCreated(newBank, msg.sender, purpose, unlockTime);
        return newBank;
    }

    // Get all active (not withdrawn) piggy banks
    function getActivePiggyBanks() external view returns (PiggyBank[] memory) {
        uint256 activeCount = 0;
        
        // First count active banks
        for(uint i = 0; i < allPiggyBanks.length; i++) {
            if(!allPiggyBanks[i].withdrawn()) {
                activeCount++;
            }
        }

        // Create array of active banks
        PiggyBank[] memory activeBanks = new PiggyBank[](activeCount);
        uint256 currentIndex = 0;
        
        for(uint i = 0; i < allPiggyBanks.length; i++) {
            if(!allPiggyBanks[i].withdrawn()) {
                activeBanks[currentIndex] = allPiggyBanks[i];
                currentIndex++;
            }
        }

        return activeBanks;
    }

    // Get all piggy banks (including withdrawn ones)
    function getAllPiggyBanks() external view returns (PiggyBank[] memory) {
        return allPiggyBanks;
    }
} 