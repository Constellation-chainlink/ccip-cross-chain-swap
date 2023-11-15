// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "./utils/Withdraw.sol";
import {LiquidityPool} from "./LiquidityPool.sol";

error Receiver__DataUnsuccessfullyReceived();

contract LPReceiver is CCIPReceiver, Withdraw {
    LiquidityPool liquidityPool;

    event TokenDeposited(); // Needs to be: event TokenDeposited(uint256 amount);
    event TokenWithdrawn(); // Needs to be: event TokenWithdrawn(address to, uint256 amount);

    constructor(address router, address lpAddress) CCIPReceiver(router) {
        liquidityPool = LiquidityPool(lpAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        // If depositToken is called from sender contract
        if (
            keccak256(message.data) ==
            keccak256(abi.encodePacked("depositToken(uint256)"))
        ) {
            (bool success, ) = address(liquidityPool).call(message.data);
            require(success, "Token deposit failed");
            emit TokenDeposited(); // Needs to be: emit TokenDeposited(amount);

            // If withdrawToken is called from sender contract
        } else if (
            keccak256(message.data) ==
            keccak256(abi.encodePacked("withdrawToken(address, uint256)"))
        ) {
            (bool success, ) = address(liquidityPool).call(message.data);
            require(success, "Token withdrawal failed");
            emit TokenWithdrawn(); // Needs to be: emit TokenWithdrawn(to, amount);
        } else {
            revert Receiver__DataUnsuccessfullyReceived();
        }
    }
}
