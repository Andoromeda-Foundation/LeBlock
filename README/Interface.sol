pragma solidity ^0.4.24;

interface ERC165{
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

contract ERC721Basic is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view return (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
}

contract ERC721Metadata is ERC721Basic {
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}

contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

contract ERC721Receiver {
    bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;
    function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns (bytes4);
}

// 策划说一下活动希望做成热插拔形式，所以到时有什么活动再部署新合约。
contract LeBlockInterface is  ERC721, ERC721Receiver {
    //read only
    // 返回每个用户的当前算力
    function minerPowerOf(address _owner) public view returns (uint256);
    // 返回每个用户押金室的TAT数量
    function depositAmountOf(address _owner) public view returns (uint256);
    // 返回每个用户游戏账户的TAT数量
    function tatAmountOf(address _owner) public view returns (uint256);
    // 返回每个用户的矿机强度
    function minerStrengthOf(address _owner) public view returns (uint256);
    // 返回每个用户不同种类的块的数量：白色块100，黄色块2.5
    function blockAmountOf(address _owner, uint256 _sortId) public view returns (uint256);
    // 返回用户是第多少个居民
    function registrationRankOf(address _owner) publci view returns (uint256);

    // 返回不同乐块材质的总数量
    function totalOfSort(uint256 _sortId) public view returns (uint256);
    // 返回当前玩家总数量
    function totalUsers() public view returns (uint256);
    // 返回乐块的累计产量
    // 直接用totalSupply函数
    // 返回乐块的今日产量
    function todaySupply() public view returns (uint256);


    // write
    function mint


}

contract recharge {       
    function setPrice(uint256 _price) public;
    function setTatAddress(address _address) public;
    function rechargeEth() public payable;
    function withdrawTatAmount (uint256 _amount) public;
	function withdrawAll() public;
}

