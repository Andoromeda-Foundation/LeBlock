pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./AddressUtils.sol";
import "./Owned.sol";

contract Gateway_notary is Owned {
    using AddressUtils for address;
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) depositOfERC20;
    mapping(address => mapping(address => uint256[])) depositOfERC721;
    mapping(address => mapping(address => uint256)) withdrawOfERC20;
    mapping(address => mapping(address => uint256[])) withdrawOfERC721;

    event Deposit(address user, address tokenAddr, uint256 amountOrId);
    event Withdraw(address user, address tokenAddr, uint256 amountOrId);

    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;   
    }

    // erc20
    function deposit20(uint256 amount, address erc20Address)
        public
    {
        ERC20 token = ERC20(erc20Address);
        if(token.transferFrom(msg.sender, address(this), amount)) {
            depositOfERC20[msg.sender][erc20Address] = depositOfERC20[msg.sender][erc20Address].add(amount);
            emit Deposit(msg.sender, erc20Address, amount);
        }
    }

    // erc721
    function deposit721(uint256 tokenId, address erc721Address)
        public
    {
        ERC721 token = ERC721(erc721Address);
        token.transferFrom(msg.sender, address(this), tokenId);
        depositOfERC721[msg.sender][erc721Address].push(tokenId);
        
        emit Deposit(msg.sender, erc721Address, tokenId);
    }    

    // 20
    function withdraw20(uint256 amount, address erc20Address, address to)
        public
        onlyAdmins
    {
        ERC20 token = ERC20(erc20Address);
        if(token.transfer(to, amount)) {
            withdrawOfERC20[to][erc20Address] = withdrawOfERC20[msg.sender][erc20Address].add(amount);
            emit Withdraw(to, erc20Address, amount);
        }
    }

    function withdraw721(uint256 tokenId, address erc721Address, address to)
        public
        onlyAdmins
    {
        ERC721 token = ERC721(erc721Address);
        token.transferFrom(address(this), to, tokenId);

        withdrawOfERC721[to][erc721Address].push(tokenId);

        emit Withdraw(to, erc721Address, tokenId);
    }

    // view
    function getDepositOfERC20(address user, address erc20Address)
        public
        view
        returns(uint256)
    {
        return depositOfERC20[user][erc20Address];
    }

    function getDepositOfERC721(address user, address erc721Address)
        public
        view
        returns(uint256[])
    {
        return depositOfERC721[user][erc721Address];
    }

    function getWithdrawOfERC20(address user, address erc20Address)
        public
        view
        returns(uint256)
    {
        return withdrawOfERC20[user][erc20Address];
    }

    function getWithdrawOfERC721(address user, address erc721Address)
        public
        view
        returns(uint256[])
    {
        return withdrawOfERC721[user][erc721Address];
    }




}

interface  ERC20 {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}

interface ERC721 {
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
}