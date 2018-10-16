pragma solidity ^0.4.24;

import "./Owned.sol";

contract Dye is Owned {

    
    struct DyeAB {
        address abAddress;
        uint256 amount; // 已产出多少dyeAB
        address[] abSourceAddress;
    }

    mapping(address => DyeAB) DyeABof;
    address[] dyeAB;

    address[] sourceAB;


    mapping(address => mapping(address => uint256)) dyeAmountOf; // 某用户铲除了多少某个染色的块

    event AssignDye(address _dyeTokenAddress);

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

    function assign

    // 查询 dye 规则,该 AB 块可由哪些 原料AB(sourceAB)产生
    function dyeRuleOf(address _dyeABtoken)
        public
        view
        returns(address[])
    {
        return DyeABof[_dyeABtoken]
    }

    // 查询染色AB地址
    function dyeList()
        public
        view
        returns(address[])
    {
        return dyeAB;
    }

    // 查询某种染色 AB产量
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

    function dye()
        public
    {


    }

}


interface DyeABprice {
    function getSourceABprice(address _sourceABaddress) external view returns(uint256);
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
