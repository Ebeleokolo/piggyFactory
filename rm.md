// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PiggyBank.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract PiggyBankFactory {
    address public immutable piggyBankImplementation;
    address[] public allPiggyBanks;

    event PiggyBankCreated(address indexed piggyBank, address indexed owner, string purpose, uint256 duration);

    constructor() {
        piggyBankImplementation = address(new PiggyBank()); // Deploy a template PiggyBank contract
    }

    function createPiggyBank(string memory purpose, uint256 duration) external returns (address) {
        address newBank = Clones.cloneDeterministic(
            piggyBankImplementation,
            keccak256(abi.encode(msg.sender, purpose, duration))
        );
        PiggyBank(newBank).initialize(msg.sender, purpose, duration, msg.sender);
        allPiggyBanks.push(newBank);
        emit PiggyBankCreated(newBank, msg.sender, purpose, duration);
        return newBank;
    }

    function getAllPiggyBanks() external view returns (address[] memory) {
        return allPiggyBanks;
    }
}
