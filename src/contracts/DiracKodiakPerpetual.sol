// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {Controller} from "../controls/Controller.sol";
import {IVault, VaultTypes} from "../interfaces/IVault.sol";
import {Data} from "../data/Data.sol";
import {Events} from "../events/Events.sol";

contract DiracKodiakPerpetual is Controller, ERC4626Upgradeable{

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the vault with the specified parameters.
     * @param _ivault The address of the associated vault contract.
     * @param _assetDeposit The ERC20 token used for deposits.
     */

    function initialize(
        address _ivault,
        IERC20 _assetDeposit
    ) external initializer {

        if (address(_assetDeposit) == address(0) || address(_ivault) == address(0)) {
            revert Events.ZeroAddress();
        }
        __ERC20_init("Dirac Kodiak Perpetual Vault", "DKPV");
        __ERC4626_init(_assetDeposit);

        __Controller_init(_ivault, _assetDeposit);


    }


    /**
   * @notice Deposits assets and mints corresponding shares.
     * @dev Only allowed when the trade cycle status is INIT and the caller is whitelisted.
     * @param _assets The amount of assets to deposit.
     * @param _receiver The address receiving the minted shares.
     * @return shares The number of shares minted.
     */
    function deposit(
        uint256 _assets,
        address _receiver
    )
    public
    override
    whenTradeClosed
    whenNotPaused
    returns (uint256 shares)
    {
        if (_assets == 0) {
            revert Events.ZeroAmount();
        }
        if (_receiver == address(0)) {
            revert Events.ZeroAddress();
        }

        if (userDeposits[msg.sender] == 0 && _assets > 0) {
            totalUsers++;
        }
        userDeposits[msg.sender] += _assets;
        totalTVL = totalTVL + _assets;
        shares = super.deposit(_assets, _receiver);
    }

    /**
     * @notice Mints shares corresponding to the specified amount of assets.
     * @dev Only allowed when the trade cycle status is INIT and the caller is whitelisted.
     * @param _shares The number of shares to mint.
     * @param _receiver The address receiving the minted shares.
     * @return assets The amount of assets corresponding to the minted shares.
     */
    function mint(
        uint256 _shares,
        address _receiver
    )
    public
    override
    whenTradeClosed
    whenNotPaused
    returns (uint256 assets)
    {
        assets = convertToAssets(_shares);
        if (assets == 0) {
            revert Events.ZeroAmount();
        }

        if (userDeposits[msg.sender] == 0 && assets > 0) {
            totalUsers++;
        }
        userDeposits[msg.sender] += assets;
        assets = super.mint(_shares, _receiver);
    }

    /**
     * @notice Withdraws assets by burning shares.
     * @dev Only allowed when the trade cycle status is INIT and the caller is whitelisted.
     * @param _assets The amount of assets to withdraw.
     * @param _receiver The address receiving the withdrawn assets.
     * @param _owner The owner of the shares being burned.
     * @return shares The number of shares burned.
     */
    function withdraw(
        uint256 _assets,
        address _receiver,
        address _owner
    )
    public
    override
    whenTradeClosed
    whenNotPaused
    returns (uint256 shares)
    {
        if (_assets == 0) {
            revert Events.ZeroAmount();
        }

        if (userDeposits[msg.sender] > _assets) {
            userDeposits[msg.sender] -= _assets;
        } else {
            delete userDeposits[msg.sender];
            if(totalUsers > 0) {
                totalUsers--;
            }
        }
        totalTVL = totalTVL - _assets;
        shares = super.withdraw(_assets, _receiver, _owner);
    }

    /**
     * @notice Redeems shares for assets.
     * @dev Only allowed when the trade cycle status is INIT and the caller is whitelisted.
     * @param _shares The number of shares to redeem.
     * @param _receiver The address receiving the redeemed assets.
     * @param _owner The owner of the shares being redeemed.
     * @return assets The amount of assets received.
     */

    function redeem(
        uint256 _shares,
        address _receiver,
        address _owner
    )
    public
    override
    whenTradeClosed
    whenNotPaused
    nonReentrant
    returns (uint256 assets)
    {
        assets = super.redeem(_shares, _receiver, _owner);

        if (assets == 0) {
            revert Events.ZeroAmount();
        }

        if (userDeposits[msg.sender] > assets) {
            userDeposits[msg.sender] -= assets;
        } else {
            delete userDeposits[msg.sender];
            if (totalUsers > 0) {
                totalUsers--;
            }
        }
    }

    function delegate(VaultTypes.VaultDelegate calldata data) public {

        IVault(ivault).delegateSigner(data);
    }

    function depositKodiak(VaultTypes.VaultDepositFE calldata data) public {

        IERC20(assetDeposit).approve(ivault, data.tokenAmount);
        IVault(ivault).deposit(data);
        /*
        Data.TradeCycle storage tradeCycle = tradeCycles[currentTradeCycleId];
        Data.PositionData memory position = Data.PositionData({
            status: Data.PositionStatus.OPEN,
            positionId: uint24(tradeCycle.positions.length + 1),
            depositAt: block.timestamp,
            withdrawAt: 0,
            amountDeposited: data.tokenAmount,
            amountWithdrawal: 0
        });
        tradeCycle.positions.push(position);
        */
        //emit Events.Deposit(s, currentTradeCycleId, data.tokenAmount);
    }

}
