pragma solidity ^0.4.24;

import "./Owned.sol";
import "./SafeMath.sol";

contract SourceABprice is Owned {
    using SafeMath for uint256;

    mapping(address => uint256) sourceABprice; // 1000 TAT 能够兑换多少SourceAB

    address[] sourceAddress;   // sourceAddress 白名单


    event AssignSourceAB(address _sourceABaddress, uint256 _sourceABprice);
    event ChangeSourceAB(address _sourceABaddress, uint256 _beforePrice, uint256 _newPrice);
    event UnAssignSourceAB(address _sourceABaddress, uint256 _sourceABprice);


    // 增加sourceAB地址以及价格。如果存在就覆盖修改
    function assignSourceAB(address _sourceABaddress, uint256 _sourceABprice)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < sourceAddress.length; i++) {
            if (_sourceABaddress == sourceAddress[i]) {
                uint256 _beforePrice = sourceABprice[_sourceABaddress];

                sourceABprice[_sourceABaddress] = _sourceABprice;
                emit ChangeSourceAB(_sourceABaddress, _beforePrice, _sourceABprice);

                return;
            }
        }

        sourceAddress.push(_sourceABaddress);
        sourceABprice[_sourceABaddress] = _sourceABprice;

        emit AssignSourceAB(_sourceABaddress, _sourceABprice);
    }

    function unAssignSourceAB(address _sourceABaddress)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < sourceAddress.length; i++) {
            if (_sourceABaddress == sourceAddress[i]) {
                uint256 _sourceABprice = sourceABprice[_sourceABaddress];

                sourceAddress[i] = sourceAddress[sourceAddress.length.sub(1)];
                delete sourceAddress[sourceAddress.length.sub(1)];
                sourceAddress.length = sourceAddress.length.sub(1);

                delete sourceABprice[_sourceABaddress];

                emit UnAssignSourceAB(_sourceABaddress, _sourceABprice);

                break;
            }
        }
    }

    function getSourceABprice(address _sourceABaddress)
        public 
        view
        returns(uint256)
    {
        return sourceABprice[_sourceABaddress];
    }

}