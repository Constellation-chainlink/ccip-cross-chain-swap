// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "../utils/Withdraw.sol";

contract SimpleReceiver is CCIPReceiver, Withdraw {
    uint256 amount;
    address senderAddress;

    event MessageReceived(uint256 amount, address senderAddress);

    constructor(address router) CCIPReceiver(router) {}

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (amount, senderAddress) = abi.decode(message.data, (uint256, address));
        emit MessageReceived(amount, senderAddress);
    }
}
