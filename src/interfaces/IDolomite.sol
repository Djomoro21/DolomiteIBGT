interface IDolomiteMargin {
    enum ActionType {
        Deposit,   // 0: Supply tokens
        Withdraw,  // 1: Borrow tokens or withdraw
        Transfer,  // 2: Transfer between accounts
        Buy,       // 3: Buy tokens
        Sell,      // 4: Sell tokens
        Trade,     // 5: Trade tokens
        Liquidate, // 6: Liquidate account
        Vaporize,  // 7: Vaporize account
        Call       // 8: Call external contract
    }

    enum AssetDenomination {
        Wei, // 0: Token amount
        Par  // 1: Principal amount
    }

    enum AssetReference {
        Delta,  // 0: Relative amount
        Target  // 1: Absolute amount
    }

    struct AssetAmount {
        bool sign;                  // true = positive, false = negative
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct AccountInfo {
        address owner;
        uint256 number;
    }

    struct OperatorArg {
        address operator;
        bool trusted;
    }
    
    function setOperators(OperatorArg[] calldata args) external;

    function operate(
        AccountInfo[] calldata accounts,
        ActionArgs[] calldata actions
    ) external;

    function getMarketIdByTokenAddress(address token) external view returns (uint256);
}