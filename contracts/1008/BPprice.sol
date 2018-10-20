pragma solidity ^0.4.24;

import "./Owned";

contract BPprice {
    mapping(string => uint256) public BPhashPrice;
    mapping(string => bool) public isBPhashSet;

    event AssignBPprice(string indexed BPhash, uint256 indexed price);

    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function set(string BPhash, uint256 price)
        public
        onlyAdmins
    {
        BPhashPrice[BPhash] = price;
        if(isBPhashSet[BPhash] == false) {
            isBPhashSet[BPhash] = true;
        }

        emit AssignBPprice(BPhash, price);

    }

    function getBPhashPrice(string BPhash)
        public
        view
        returns(uint256)
    {
        return BPhashPrice[BPhash];
    }

    function getBPisSet(string BPhash)
        public
        view
        returns(bool)
    {
        return isBPhashSet[BPhash];
    }
}