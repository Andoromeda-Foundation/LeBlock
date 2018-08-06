pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./AddressUtils.sol";
import "./Pausable.sol";
import "./QueueStru.sol";

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

    /**
     * @notice Query if a contract implements an interface
     * @param _interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool);
}

/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {
    bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
    /**
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) internal supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor()
        public
    {
        _registerInterface(InterfaceId_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool)
    {
        return supportedInterfaces[_interfaceId];
    }

    /**
     * @dev private method for registering an interface
     */
    function _registerInterface(bytes4 _interfaceId)
        internal
    {
        require(_interfaceId != 0xffffffff);
        supportedInterfaces[_interfaceId] = true;
    }
}


contract Leblock_main is SupportsInterfaceWithLookup, Pausable, QueueStru {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using AddressUtils for address;

    event Recharge(
        address indexed _user, 
        uint256 indexed _amount
    );

    event ChangeDeposit(
        address indexed _user,
        int256 indexed _amount
    );

    // mapping from different types leblock to leblock contract address
    mapping (uint256 => address) blockToken;
    
    // Mapping from player to account balance.(TAT)
    mapping (address => uint256) userTatAmount;

    // Mapping from player to amounts of differnet types blocks
    mapping (address => mapping (address => uint256)) userBlockAmount;

    // Mapping from player to rank of register memont
    mapping (address => uint256) userRegistrationRank;
    
    // Mapping from block type to amount
    mapping (address => uint256) typesTotalBlock;

    // mapping from power number to player
    mapping (uint256 => address) powerNumToUser;

    // totalPlayers
    uint256 totalplayers;

    // total miner machine power
    uint256 totalMinerPower;

    // mining machine parameters
    struct Miner {
        address owner;
        // the mining power after recharge deposit
        uint256 minerPower;
        // balance of TAT in deposit room
        uint256 depositAmount;
        // power number
        uint256[] powerNum;
    }

    mapping (address => Miner) ownerToMiner;

    constructor() public {
    }

    /**
     * @dev admin set block address
     */
    function setTokenAddr(uint256 _tokenId, address _tokenAddr)
        whenNotPaused
        onlyAdmins
        public
    {
        blockToken[_tokenId] = _tokenAddr;
    }

    /**
     * @dev get block address
     */
    function getTokenAddr(uint256 _tokenId) 
        view 
        public
        returns (address)
    {
        return blockToken[_tokenId];
    }

    /**
     * @dev using gateway provided by loom or server
     */
    function recharge(address _user, uint256 _amount)
        whenNotPaused 
        onlyAdmins
        public
    {
        userTatAmount[_user] = userTatAmount[_user].add(_amount);

        emit Recharge(_user, _amount);
    }

    /**
     * @dev player recharge/withdraw TAT to the deposit room
     * @dev if _amount is positive, from account to deposit room,
     * if _amount is negative, from deposit room to account
     */
    function changeDeposit(int256 _amount) 
        whenNotPaused 
        public 
    {
        require(_amount != 0);
        require(_amount.div(10).mul(10) == _amount);
        require(int256(userTatAmount[msg.sender]).sub(_amount) >= 0);
        require(int256(ownerToMiner[msg.sender].depositAmount).add(_amount) >= 0);

        int256 _increasePower = _amount.div(10);

        userTatAmount[msg.sender] = (int256(userTatAmount[msg.sender]).sub(_amount))
            .toUint256Safe();
        ownerToMiner[msg.sender].depositAmount = (int256(ownerToMiner[msg.sender].depositAmount)
            .add(_amount)).toUint256Safe();

        ownerToMiner[msg.sender].minerPower = (int256(ownerToMiner[msg.sender].minerPower)
            .add(_increasePower)).toUint256Safe();

        if(_amount > 0) {
            for (uint256 i = totalMinerPower + 1; i <= totalMinerPower + _increasePower.toUint256Safe(); i++) {
                require(powerNumToUser[i] == address(0));
                powerNumToUser[i] = msg.sender;
                ownerToMiner[msg.sender].powerNum.push(i);
            }
        } else {
            uint256 _length = ownerToMiner[msg.sender].powerNum.length;
            for (uint256 k = _length; k > _length.sub((0-(_increasePower + 1).toUint256Safe())); k--) {
                uint256 _powerNum = ownerToMiner[msg.sender].powerNum[k];
                if (_powerNum == totalMinerPower) {
                    delete ownerToMiner[msg.sender].powerNum[k];
                    powerNumToUser[_powerNum] = powerNumToUser[totalMinerPower];
                    delete powerNumToUser[totalMinerPower];
                }
            }
        }

        totalMinerPower = (int256(totalMinerPower).add(_increasePower)).toUint256Safe();

        emit ChangeDeposit(msg.sender, _amount);
    }

    /**
     * @return the random packageID 
     */
    function _miner(
        // 礼包个数
        uint256 _packageAmount,
        uint256 _totalPower
        )
        internal
        view
        returns (uint256[])
    {
        uint256 random;
        uint256 result;
        uint256[] memory packageId = new uint256[](_packageAmount);

        for (uint256 i = 0; i < _packageAmount; i++) {
            random = uint256(keccak256(abi.encodePacked(block.difficulty + i))); // assume result is the random number
            result = random % _totalPower;
            packageId[i] = result;
        }
         
        return packageId;
    }

    /**
     * @dev distribute package
     */	
    function _getpackage(
        uint256[] memory _userMinerPower,
        uint256[] memory _packageId
        )
        internal
        pure
        returns (uint256)
    {
        uint256 calculator = 0;
        bool[] memory tempArray = new bool[](_userMinerPower.length);
        for (uint256 i = 0; i < _userMinerPower.length; i++) {
            tempArray[_userMinerPower[i]] = true;
        }

        for (uint256 k = 0; k < _packageId.length; k++) {
            if (tempArray[_packageId[i]] == true) {
                calculator++;
            }
        }
        return calculator;
    }

    /**
     * @dev launch ERC20 block
     * @param  _chance % is the chance of diff blocks
     * @param _total is the upper limit of block
     * @dev totalMinerPower >= 100
     */
    function _minerBlock(uint256 _chance, uint256 _total)
        view 
        internal
        returns (uint256,uint256)
    {
        require(totalMinerPower >= 100);
        require(totalMinerPower.div(100).mul(100) == totalMinerPower);
        uint256 packageAmount = _chance.mul(totalMinerPower).div(100);
        uint256 amountPerPackage = _total.mul(1 ether).div(packageAmount);

        return  (packageAmount,amountPerPackage);
    }

    /**
     * @dev  issue blocks
     * @return the address can take one type block's amount
     */
    function _issueBlocks(
        uint256 _chance, 
        uint256 _total,
        address _addr
    )
        view
        internal
        returns (uint256)
    {
        uint256  packageAmount;
        uint256 amountPerPackage;
        
        (packageAmount, amountPerPackage) = _minerBlock(_chance, _total);

        uint256[] memory packageId = new uint256[](packageAmount);
        packageId = _miner(packageAmount, totalMinerPower);


        return _getpackage(ownerToMiner[_addr].powerNum, packageId);    
    }

    /**
     */
}

interface leblock {
    function mintToken(address _target, uint256 _mintedAmount) external;
}
