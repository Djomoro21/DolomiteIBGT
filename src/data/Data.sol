// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Data {

    // The trade cycle status
    enum TradeCycleStatus {
        INIT,
        OPEN,
        PENDING,
        CLOSED
    }
    enum PositionStatus {
        OPEN,
        PENDING,
        CLOSED
    }


    struct PositionData {
        PositionStatus status;// The status of the trade cycle
        uint24 positionId;
        uint256 depositAt;
        uint256 amountDeposited;

    }

    struct TradeCycle {
        TradeCycleStatus status;// The status of the trade cycle
        PositionData[] positions;
        uint256 startedAt; // The time when the trade cycle started
        uint256 endedAt; // The time when the trade cycle   ended
        uint256 AmountAvailable;
    }


}
