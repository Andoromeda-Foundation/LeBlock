pragma solidity ^0.4.24;

import "./Owned.sol";

contract Dye is Owned {

    uint256 asd;

    
    struct DyeAB {
        address abAddress;

        address[] abSourceAddress;
    }

    event AssignDye(address _dyeTokenAddress);

    function assignDyeRule(address _dyeABaddress, address[] _abSourceAddress)
        public
        onlyAdmins
    {
        

        emit AssignDye(_dyeABaddress);
    }

    function dyeRuleOf(address _dyeABtoken)
        public
        view
        returns(address[])
    {
        
    }

    function dyeList()
        public
        view
        returns(address[] )
    {

    }

    function dyeABOf(address _user, address _dyeAddress)
        public
        view
        returns(uint256)
    {

    }

    function totalDyeAB(address _dyeAddress)
        public
        view
        returns(uint256)
    {

    }

    function dye()
        public
    {

    }

}


interface DyeABprice {
    function getSourceABprice(address _sourceABaddress) external view returns(uint256);
}
