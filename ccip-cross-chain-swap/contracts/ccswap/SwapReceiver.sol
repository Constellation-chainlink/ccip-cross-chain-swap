// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract SwapReceiver is CCIPReceiver {
    ISwapRouter swapRouter;

    event SwapSuccessful(uint256 amountOut);

    constructor(address router, ISwapRouter _swapRouter) CCIPReceiver(router) {
        swapRouter = _swapRouter;
    }

    function _performSwap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint160 sqrtPriceLimitX96
    ) internal {
        // Transfer the specified amount of tokenIn to this contract
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend tokenIn
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // Set parameters for the swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: sqrtPriceLimitX96
            });

        // Execute the swap
        uint256 amountOut = swapRouter.exactInputSingle(params);

        emit SwapSuccessful(amountOut);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (bool success, ) = address(swapRouter).call(message.data);
        require(success);
        // emit SwapSuccessful();
    }
}
