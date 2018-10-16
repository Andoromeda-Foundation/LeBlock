pragma solidity ^0.4.24;

contract Instance {


    address CCAddress; // CopyrightCenter address
    address TATaddress; // 侧链镜像TAT的地址
    address ERC721address; // ERC721的地址
    address BPpriceAddress;

    // 因为在整条逻辑链的传输过程，BPhash == CRhash
    function makeInstance(string _BPhash)
        public
    {
        CopyrightCenter cc = CopyrightCenter(CCAddress);
        require(cc.exists(_BPhash));
        address _maker = cc.makerOf(_BPhash);
        
        // 因为instance没有销毁操作, tokenId这样实现没问题
        ERC721Instance _erc721instance = ERC721Instance(ERC721address);
        uint256 _tokenId = _erc721instance.totalSupply().add(1);
        _erc721instance.mint(msg.sender, _tokenId, _BPhash);

        BPprice _bpPrice = BPprice(BPpriceAddress);

        uint256 _price = _bpPrice.getBPprice(_BPhash);

        ERC20 token =  ERC20(TATaddress);
        token.transferFrom(msg.sender, _maker, _price);
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
    function exists(string _CRhash) external view returns(bool);
    function makerOf(string CRhash) external view returns(address);
}

interface ERC721Instance {
    function mint(address _to, uint256 _tokenId, string _BPhash) external;
    function totalSupply() external view returns(uint256);
}

interface BPprice {
    function getBPprice(string _BPhash) external view returns(uint256);
}