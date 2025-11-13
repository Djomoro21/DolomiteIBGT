// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


import {Script} from "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {DiracKodiakPerpetual} from "../src/contracts/DiracKodiakPerpetual.sol";
import {VaultTypes} from "../src/interfaces/IVault.sol";
import   "forge-std/Console.sol";
import {DiracKodiakV1} from "../src/contracts/DiracKodiakV1.sol";

contract DeployDiracKodiak is Script{

    address internal _ivault= 0x816f722424B49Cf1275cc86DA9840Fbd5a6167e9;
    IERC20 internal _assetDeposit= IERC20(0x549943e04f40284185054145c6E4e9568C1D3241);

    constructor(){

    }

    function run() public {
        //deploy();

        address vault = 0xFdFC9F12336974A60ae0c0918ceB8AEC73BdA716; // 0xCC9B3887be1e52fF0E55D783E151DE5a40602BE1;

        //initialisation(vault);
        //deposit(vault, 23000000, 0xC9104F69637C03D2646bF8225fcBb796C148D543, 0x549943e04f40284185054145c6E4e9568C1D3241);

        /*
        bytes32  brokerHash = keccak256(abi.encodePacked("kodiak"));
        console.log("brokerHash: ");
        console.logBytes32(brokerHash);

        bytes32 hashh  = 0x06bc873ee2707d92a1e23b12e5de4a5c63f35b28bab72ea15d1052985371773a;
        VaultTypes.VaultDelegate memory  data = VaultTypes.VaultDelegate({
            brokerHash: hashh,
            delegateSigner: address(0xacD8B8DF59BA4b7c8d69617400c0EA61e3704cFa)
        });

        delegate(vault, data);

        */
        //upgrade(vault);

        //transfersToDelegator(vault,0x194534c6690e83A12CEE569B5E2E0115c1F8e4a5,3000000);
        //updateVariable(vault, _ivault, address(_assetDeposit));
        //getBrokerHash("KodiakFi");


        bytes32 tokenHash_ = 0xd6aca1be9729c13d677335161321649cccae6a591554772516700f986f942eaa;
        bytes32 hash_  = 0x06bc873ee2707d92a1e23b12e5de4a5c63f35b28bab72ea15d1052985371773a;
        bytes32 accountId_ = 0x14091fbda30fc1302faae49974d39e3aad4ad827961d43da6f82bf7c7dfebaba;


        VaultTypes.VaultDepositFE memory depositData = VaultTypes.VaultDepositFE({
                        accountId : accountId_,
                        brokerHash : hash_,
                        tokenHash : tokenHash_,
                        tokenAmount : 21000000
        });

        depositKodiak(vault,depositData, 0.1 ether);

        /*
        VaultTypes.VaultWithdraw2Contract memory withdraw = VaultTypes.VaultWithdraw2Contract({

            vaultType : VaultTypes.VaultEnum.UserVault,
            accountId : accountId_,
            brokerHash : hash_,
            tokenHash : tokenHash_,
            tokenAmount : 1000000,
             fee : 0.1 ether,
             sender : 0xacD8B8DF59BA4b7c8d69617400c0EA61e3704cFa,
             receiver :0xFdFC9F12336974A60ae0c0918ceB8AEC73BdA716,
             withdrawNonce :1,
             clientId :0
    });

        withdrawToContract(vault, withdraw);

        */

        //sstartTradeCycle(vault, 10 days );

        //requestToEndTradeCycle(vault);
        //endTradeCycle(vault);
    }


    function deploy() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address proxy = Upgrades.deployTransparentProxy(
            "DiracKodiakV1.sol",
            msg.sender,
            abi.encodeCall(
                DiracKodiakV1.initialize,
                (
                   _ivault,
                    _assetDeposit
                )
            )
        );

        console.log("Proxy: ");
        console.logAddress(proxy);

        address implementationAddress = Upgrades.getImplementationAddress(
            proxy
        );
        address adminAddress = Upgrades.getAdminAddress(proxy);

        console.log("Implementation: ");
        console.logAddress(implementationAddress);

        console.log("Proxy Admin: ");
        console.logAddress(adminAddress);

        require(adminAddress != address(0), "Invalid admin address");

        vm.stopBroadcast();
    }

    function getVault(address vault) internal pure returns (DiracKodiakV1) {
        return DiracKodiakV1(payable(vault));
    }

    function upgrade(address proxyAddress) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Upgrades.upgradeProxy(
            proxyAddress,
            "DiracKodiakV1.sol",
            ""
        );
        vm.stopBroadcast();
    }
    function transferOwnership(address vault, address newOwner) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);


        getVault(vault).grantRole(0x00, newOwner);
        getVault(vault).grantRole(keccak256("OPERATOR_ROLE"), newOwner);
        //instance.renounceRole(0x00, msg.sender);

        vm.stopBroadcast();
    }

    function initialisation(address vault) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        getVault(vault).initializeCycle();
        vm.stopBroadcast();
    }
    function addOperator(address vault, address newOperator) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        getVault(vault).grantRole(keccak256("OPERATOR_ROLE"), newOperator);
        vm.stopBroadcast();
    }

    function removeOperator(address vault, address operator) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        getVault(vault).revokeRole(keccak256("OPERATOR_ROLE"), operator);

        vm.stopBroadcast();
    }

// ============= Trade Cycle Management =============

    function startTradeCycle(address vault, uint256 duration) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        getVault(vault).startTradeCycle(duration);
        vm.stopBroadcast();
    }

    function requestToEndTradeCycle(address vault) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        getVault(vault).requestToEndTradeCycle();
        vm.stopBroadcast();
    }

    function endTradeCycle(address vault) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        getVault(vault).endTradeCycle();

        vm.stopBroadcast();
    }

    function deposit(address vault, uint256 amount, address user, address token) public {
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");

        vm.startBroadcast(userPrivateKey);

        TransferHelper.safeApprove(address(token), vault, amount);
        getVault(vault).deposit(amount,user);
        vm.stopBroadcast();
    }


    function withdraw(address vault, uint256 amount) public {
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        address user = vm.addr(userPrivateKey);
        vm.startBroadcast(userPrivateKey);


        getVault(vault).withdraw(amount, user, user);
        vm.stopBroadcast();
    }

    function delegate(address  vault ,VaultTypes.VaultDelegate memory data) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        getVault(vault).delegate(data);
        vm.stopBroadcast();
    }

    function depositKodiak(address  vault, VaultTypes.VaultDepositFE memory data, uint256  fee) public{
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
            getVault(vault).deposit(data, fee);
        vm.stopBroadcast();
    }

    function withdrawToContract(address  vault, VaultTypes.VaultWithdraw2Contract memory data) public{
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        getVault(vault).withdraw2Contract(data);
        vm.stopBroadcast();
    }
/*
    function updateVariable(address  vault,  address  ivault, address asset) public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
            getVault(vault).updateVariable(ivault, asset);
        vm.stopBroadcast();
    }

    function transfersToDelegator(address vault, address delegatorAddres, uint256  amount) public{
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
            getVault(vault).transfersToDelegator(delegatorAddres, amount);
        vm.stopBroadcast();
    }
    */
}
