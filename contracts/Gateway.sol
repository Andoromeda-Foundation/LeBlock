pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./Pausable.sol";
import "./AddressUtils.sol";

/**
 * @title Gateway
 * @dev player recharge TAT to dappchain and withdraw TAT from dappchain
 */
contract Gateway  is Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

    event Recharge(address indexed _user, uint256 indexed tatAmount);
    event Withdraw(address indexed _user, uint256 indexed tatAmount);
    
    address ERC20address;
    mapping (address => uint256) blance;

    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setTatAddress(address _address)
        public
        onlyAdmins
    {
        ERC20address = _address;
    }

    function recharge(address _addr, uint256 _amount)
        public
        onlyAdmins
    {
        blance[_addr] = blance[_addr].add(_amount);
        emit Recharge(_addr, _amount);
    }

    function withdraw(address _addr, uint256 _amount)
        public
        onlyAdmins
    {
        require(blance[_addr] >= _amount);

        ERC20Interface token = ERC20Interface(ERC20address);
        token.transfer(_addr, _amount);
        blance[_addr] = blance[_addr].sub(_amount);

        emit Withdraw(_addr, _amount);
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

    function blanceOf(address _addr)
        public
        view
        returns (uint256)
    {
        return blance[_addr];
    }
}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
}