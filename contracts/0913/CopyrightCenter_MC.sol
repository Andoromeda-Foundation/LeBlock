pragma solidity ^0.4.24;

import "./Owned.sol";
import "./AddressUtils.sol";

contract CopyrightCenter_MC is Owned {
    using AddressUtils for address;

    address CRaddress; // Copyright用户注册好版权的地方。XBP,代码和BP一样，存储数据不同。

    mapping(string => uint256) indexOfCRhash;

    event Shelf(address _maker, uint256 indexed _tokenIdOfBP, uint256 indexed _tokenIdOfCR, string _BPHash);
    event Unshelf(address _maker, uint256 indexed _tokenIdOfBP, uint256 indexed _tokenIdOfCR, string _BPHash);

    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setCRaddress(address _addr)
        public
        onlyAdmins
    {
        require(_addr.isContract());
        CRaddress = _addr;
    }

    function canShelf(string BPHash)
        public
        view
        returns(bool)
    {
        BP cr = BP(CRaddress);
        uint256 _indexOfCR = indexOfCRhash[BPHash];

        if(!cr.exists(_indexOfCR)) {
            return true;
        } else {
            return false;
        }
    }

    function shelf(string BPHash, address _maker, uint256 _tokenIdOfBP)
        public
        onlyAdmins
    {
        require(canShelf(BPHash));
        BP cr = BP(CRaddress);

        // tokenId 不能为0，tokenId不能选择为0的数，否则exist(tokenId)会判定BPhash不存在的为存在。
        uint256 _tokenIdOfCR = cr.totalSupply().add(1);


        if(!cr.exists(_tokenIdOfCR)) {
            cr.mint(msg.sender, _tokenIdOfCR , _maker);

            indexOfCRhash[BPHash] = _tokenIdOfCR;

            emit Shelf(_maker, _tokenIdOfBP, _tokenIdOfCR, BPHash);
        }

    }
    
    function canUnshelf(string BPHash)
        public
        view
        returns(bool)
    {
        uint256 _tokenId = indexOfCRhash[BPHash];
        
        BP cr = BP(CRaddress);

        if(cr.exists(_tokenId)) {
            return true;
        } else {
            return false;
        }
    }


    function unshelf(string BPHash, uint256 _tokenIdOfBP)
        public
        onlyAdmins
    {
        BP cr = BP(CRaddress);
        uint256 _tokenIdOfCR = indexOfCRhash[BPHash];

        require(canUnshelf(BPHash));
        address _owner = cr.ownerOf(_tokenIdOfCR);
        address _maker = cr.makerOf(_tokenIdOfCR);

        cr.burn(_owner, _tokenIdOfCR, _maker);

        emit Unshelf(_maker, _tokenIdOfBP, _tokenIdOfCR, BPHash);
    }

    function haveShelf(string BPHash)
        public
        view
        returns(bool)
    {
        BP cr = BP(CRaddress);
        uint256 _tokenIdOfCR = indexOfCRhash[BPHash];
        if(cr.makerOf(_tokenIdOfCR) != address(0)) {
            return true;
        } else {
            return false;
        }
    }

    function getTokenIdOfCR(string BPHash)
        public
        view
        returns(uint256)
    {
        return indexOfCRhash[BPHash];    
    }

}

interface BP {
    function mint(address _to, uint256 _tokenId, address _maker) external;
    function burn(address _owner, uint256 _tokenId, address _maker) external;
    function totalSupply() external view returns (uint256);
    function exists(uint256 _tokenId) external view returns (bool _exists);    
    function makerOf(uint256 _tokenId) external view returns (address);
    function ownerOf(uint256 _tokenId) external view returns (address);
}
