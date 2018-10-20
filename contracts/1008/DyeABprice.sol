pragma solidity ^0.4.24;

import "./Owned.sol";
import "./SafeMath.sol";

contract DyeABprice is Owned {
    using SafeMath for uint256;

    mapping(address => uint256) dyeABprice; // 1000 TAT 能够交付 染出多少dyeAB的手续费

    address[] dyeAddress;   // dyeAddress 白名单


    event AssignDyeAB(address _dyeABaddress, uint256 _dyeABprice);
    event ChangeDyeAB(address _dyeABaddress, uint256 _beforePrice, uint256 _newPrice);
    event UnAssignDyeAB(address _dyeABaddress, uint256 _dyeABprice);

    constructor() 
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }


    // 增加dyeAB地址以及价格。如果存在就覆盖修改
    function assignDyeAB(address _dyeABaddress, uint256 _dyeABprice)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < dyeAddress.length; i++) {
            if (_dyeABaddress == dyeAddress[i]) {
                uint256 _beforePrice = dyeABprice[_dyeABaddress];

                dyeABprice[_dyeABaddress] = _dyeABprice;
                emit ChangeDyeAB(_dyeABaddress, _beforePrice, _dyeABprice);

                return;
            }
        }

        dyeAddress.push(_dyeABaddress);
        dyeABprice[_dyeABaddress] = _dyeABprice;

        emit AssignDyeAB(_dyeABaddress, _dyeABprice);
    }

    function unAssignDyeAB(address _dyeABaddress)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < dyeAddress.length; i++) {
            if (_dyeABaddress == dyeAddress[i]) {
                uint256 _dyeABprice = dyeABprice[_dyeABaddress];

                dyeAddress[i] = dyeAddress[dyeAddress.length.sub(1)];
                delete dyeAddress[dyeAddress.length.sub(1)];
                dyeAddress.length = dyeAddress.length.sub(1);

                delete dyeABprice[_dyeABaddress];

                emit UnAssignDyeAB(_dyeABaddress, _dyeABprice);

                break;
            }
        }
    }

    function getDyeABprice(address _dyeABaddress)
        public 
        view
        returns(uint256)
    {
        return dyeABprice[_dyeABaddress];
    }

}