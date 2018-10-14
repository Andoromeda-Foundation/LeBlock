pragma solidity ^0.4.24;

contract Instance {


    address CCAddress; // CopyrightCenter address
    address TATaddress; // 侧链镜像TAT的地址
    address ERC721address; // ERC721的地址

    function makeInstance(string _BPhash)
        public
    {
        ERC721Instance _erc721instance = ERC721Instance(ERC721address);
    }


}


interface  ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

interface CopyrightCenter {

}

interface ERC721Instance {
    function mint(address _to, uint256 _tokenId, string _BPhash) external;
    function totalSupply() external view returns (uint256);
    

}

interface DyeABprice {
    function getDyeABprice(address _dyeABaddress) external view returns(uint256);
}