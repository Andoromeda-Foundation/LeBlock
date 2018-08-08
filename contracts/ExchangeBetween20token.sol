pragma solidity ^0.4.24;

import "./Pausable.sol";
import "./SafeMath.sol";

contract ExchangeBetween20token is Pausable {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) public tokens;
    mapping(address => mapping(address => uint256)) public lockTokens;
    mapping(address => mapping(address => uint256)) public price; // TAT

    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event PendingOrder(address token, address user, uint256 amount, uint256 price);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);


    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function deposit(address _tokenAddr, uint256 _amount)
        public
    {
        tokens[_tokenAddr][msg.sender] = tokens[_tokenAddr][msg.sender].add(_amount);
        require(Token(_tokenAddr).transferFrom(msg.sender, this, _amount),"transfer your tokens failed");
        emit Deposit(_tokenAddr, msg.sender, _amount, tokens[_tokenAddr][msg.sender]);
    }

    function pendingOrder(address _tokenAddr, uint256 _amount, uint256 _price)
        public
    {
        require(tokens[_tokenAddr][msg.sender] >= lockTokens[_tokenAddr][msg.sender].add(_amount), "insufficient balance");

        lockTokens[_tokenAddr][msg.sender] = lockTokens[_tokenAddr][msg.sender].add(_amount);
        price[_tokenAddr][msg.sender] = _price; 

        emit PendingOrder(_tokenAddr, msg.sender, _amount, _price);       
    }

    // function setprice(addre)

    function withdraw(address _tokenAddr, uint256 amount)
        public
    {
        require(tokens[_tokenAddr][msg.sender] >= lockTokens[_tokenAddr][msg.sender].add(amount), "insufficient or on pending"); 
        require(_tokenAddr != address(0x0), "invalid token address");

        tokens[_tokenAddr][msg.sender] = tokens[_tokenAddr][msg.sender].sub(amount);

        require(Token(_tokenAddr).transfer(msg.sender, amount), "token transfer failed");
    
        emit Withdraw(_tokenAddr, msg.sender, amount, tokens[_tokenAddr][msg.sender]);
    }


}

/**
 * @title ERC20Interface
 * @dev https: *github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract Token {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}