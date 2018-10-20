pragma solidity ^0.4.24;

import "./Owned.sol";
import "./SafeMath.sol";

contract Dye is Owned {
    using SafeMath for uint256;
    
    // 与其限制DyeAB能够由哪些sourceAB染出，不如限制


    struct DyeAB {
        address abAddress;
        uint256 amount; // 已产出多少dyeAB
        address[] abSourceAddress;
    }

    mapping(address => DyeAB)  DyeABof;
    address[]  dyeAB;

    address[] public sourceAB;

    address public dyeABprice;

    address public tatAddress;


    mapping(address => mapping(address => uint256)) public dyeAmountOf; // 某用户产出了多少某个染色的块

    event AssignDye(address indexed _dyeTokenAddress);
    event UnAssignDye(address indexed _dyeTokenAddress);
    
    event AssignAB(address indexed _ABaddress);
    event UnAssignAB(address indexed _ABaddress);

    event AssignTAT(address indexed _address);

    event DyeIt(address indexed _ABaddress, address indexed _dyeABaddress, uint256 indexed _amount);

    constructor() 
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setDyeABpriceAddress(address _addr)
        public
        onlyAdmins
    {
        dyeABprice = _addr;
    }

    function assignDyeRule(address _dyeABaddress, address[] _abSourceAddress)
        public
        onlyAdmins
    {
        DyeAB memory _dyeAB = DyeAB(_dyeABaddress, 0, _abSourceAddress);

        for (uint256 i = 0; i < dyeAB.length; i++) {
            if (dyeAB[i] == _dyeABaddress) {
                DyeABof[_dyeABaddress] = _dyeAB;

                emit AssignDye(_dyeABaddress);
                return;
            }
        }

        dyeAB.push(_dyeABaddress);
        DyeABof[_dyeABaddress] = _dyeAB;

        emit AssignDye(_dyeABaddress);
    }

    function unAssignDyeRule(address _dyeAddress)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < dyeAB.length; i++) {
            if(dyeAB[i]==_dyeAddress) {
                dyeAB[i] == dyeAB[dyeAB.length.sub(1)];
                delete dyeAB[dyeAB.length.sub(1)];
                dyeAB.length = dyeAB.length.sub(1);

                delete DyeABof[_dyeAddress];

                emit UnAssignDye(_dyeAddress);

                return;
            }
        }
    }


    function assignSourceAB(address _ABaddress)
        public
        onlyAdmins
    {
        sourceAB.push(_ABaddress);

        emit AssignAB(_ABaddress);
    }

    function unAssignSourceAB(address _ABaddress)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < dyeAB.length; i++) {
            if(sourceAB[i] == _ABaddress) {
                sourceAB[i] == sourceAB[sourceAB.length.sub(1)];
                delete sourceAB[sourceAB.length.sub(1)];

                emit UnAssignAB(_ABaddress);

                return;
            }
        }
    }



    function assignTATaddress(address _address)
        public
        onlyAdmins
    {
        tatAddress = _address;
        emit AssignTAT(_address);
    }


    // 查询 dye 规则,该 AB 块可由哪些 原料AB(sourceAB)产生
    function dyeRuleOf(address _dyeABtoken)
        public
        view
        returns(address[])
    {
        return DyeABof[_dyeABtoken].abSourceAddress;
    }

    // 查询染色AB地址
    function dyeList()
        public
        view
        returns(address[])
    {
        return dyeAB;
    }

    // 查询某种用户染色 AB产量
    function dyeABOf(address _user, address _dyeAddress)
        public
        view
        returns(uint256)
    {
        return dyeAmountOf[_user][_dyeAddress];
    }

    // 查询某种染色 AB总产量
    function totalDyeAB(address _dyeAddress)
        public
        view
        returns(uint256)
    {
        return DyeABof[_dyeAddress].amount;
    }

    //
    function dye(address _abAddress, uint256 _amount)
        public
    {
        for (uint256 i = 0; i < sourceAB.length; i++) {
            if (_abAddress == sourceAB[i]) {
                ERC20Interface _token = ERC20Interface(_abAddress);
                _token.transferFrom(msg.sender, address(this), _amount);


                uint256 _length = canDyeToAmount(_abAddress);
                address[] memory _dyeABaddressArray = canDyeTo(_abAddress);
                uint256 _random = uint256(keccak256(abi.encodePacked(now, msg.sender, blockhash(block.number-10)))) % _length;
                ERC20Interface _dyeAB = ERC20Interface(_dyeABaddressArray[_random]);
                _dyeAB.mintToken(msg.sender, _amount);
                

                DyeABprice _priceContract = DyeABprice(dyeABprice);
                uint256 _price = _priceContract.getDyeABprice(_dyeABaddressArray[_random]);
                ERC20Interface _tatToken = ERC20Interface(tatAddress);
                uint256 _fee = _amount.mul(1000).div(_price);
                _tatToken.transferFrom(msg.sender, address(this), _fee);
                

                emit DyeIt(_abAddress, dyeAB[_random], _amount);

                return;
            }
        }

    }

    function getToken(address _tokenAddress, uint256 _amount)
        public
        onlyAdmins
    {
        ERC20Interface _token = ERC20Interface(_tokenAddress);
        _token.transfer(msg.sender, _amount);
    }

    // 判断某个原AB是否是在对应dyeAB的允许列表中
    function isInArray(address _sourceAddress, address _dyeAddress )
        public 
        view
        returns(bool)
    {
        for (uint256 i = 0; i < DyeABof[_dyeAddress].abSourceAddress.length; i++) {
            if (_sourceAddress == DyeABof[_dyeAddress].abSourceAddress[i]) {
                return true;
            }
        }

        return false;
    }

    // 查询某个sourceAB能够染成的dyeAB列表
    function canDyeTo(address _sourceAddress)
        public
        view
        returns(address[])
    {
        uint256 _length = 0;

        // 保存能够用sourceAB染成的dyeAB地址的index, 可能用不到这么多，所以就直接用前几个
        uint256[] memory _num = new uint256[](dyeAB.length);

        for(uint256 i = 0; i < dyeAB.length; i++) {
            if(isInArray(_sourceAddress,dyeAB[i])) {
                _num[_length] = i;
                _length = _length.add(1);
            }
        }

        if(_length == 0) {
            address[] memory _nullAddr = new address[](0);
            return _nullAddr;
        }

        address[] memory dyeABarray = new address[](_length);

        for(uint256 k = 0; k < _length; k++) {
            dyeABarray[k] = dyeAB[_num[k]];
        }

        return dyeABarray;
    }

    // 查询某个sourceAB能够染成的dyeAB的个数
    function canDyeToAmount(address _sourceAddress)
        public
        view
        returns(uint256)
    {
        uint256 _length = 0;

        for(uint256 i = 0; i < dyeAB.length; i++) {
            if(isInArray(_sourceAddress,dyeAB[i])) {
                _length = _length.add(1);
            }
        }

        return _length;
    }

    

}




interface DyeABprice {
    function getDyeABprice(address _dyeABaddress) external view returns(uint256);
}

contract ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function mintToken(address _target, uint256 _mintedAmount) external;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}
