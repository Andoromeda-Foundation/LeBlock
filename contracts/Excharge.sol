pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./AddressUtils.sol";
import "./Pausable.sol";

/**
 * @title Excharge
 * @dev a convenient way for users to excharge ETH to TAT
 */
contract Excharge is Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

    event ExchargeETHtoTAT(address indexed _user, uint256 ethAmount, uint256 tatAmount);

    uint256 price;
    address ERC20address;

    constructor() 
        public 
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setPrice(uint256 _price)
        public
        onlyAdmins
    {
        price = _price;
    }

    function setTatAddress(address _address)
        public
        onlyAdmins
    {
        ERC20address = _address;
    }

    function rechargeEth()
        public
        payable
        whenNotPaused
    {
        require(ERC20address != address(0));
        require(ERC20address.isContract());
        require(price != uint256(0));
        require(msg.value != 0);
        
        uint256 amount = msg.value.mul(price);
        ERC20Interface token = ERC20Interface(ERC20address);

        token.transfer(msg.sender, amount);

        emit ExchargeETHtoTAT(msg.sender, msg.value, amount);
    }    

    function withdrawTatAmount(uint256 _amount)
        public
        onlyOwner
        whenNotPaused
    {
        ERC20Interface token = ERC20Interface(ERC20address);
        token.transfer(msg.sender, _amount);    
    }

    function withdrawAll()
        public
        onlyOwner
        whenNotPaused
    {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount(uint256 _amount)
        public
        onlyOwner
        whenNotPaused
    {
        msg.sender.transfer(_amount);
    }

}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
}