pragma solidity ^0.4.24;

import "./Owned.sol";
import "./AddressUtils.sol";

contract CopyrightCenter is Owned {
    using AddressUtils for address;

    address BPaddress; // BP, ERC721
    address WHaddress; // WareHouse
    address CRaddress; // Copyright用户注册好版权的地方。
    mapping(string => address) destru;

    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setBPAddress(address _addr)
        public
        onlyAdmins
    {
        require(_addr.isContract());
        BPaddress = _addr;
    }

    function setWHaddress(address _addr)
        public
        onlyAdmins
    {
        require(_addr.isContract());
        WHaddress = _addr;
    }

    function setCRaddress(address _addr)
        public
        onlyAdmins
    {
        require(_addr.isContract());
        CRaddress = _addr;
    }

    function canShelf(string BPHash, address BPmaker)
        internal
        view
        returns(bool)
    {
        ERC721 bp = ERC721(BPaddress);
        WareHouse wh = WareHouse(WHaddress);
        uint256 _index = wh.getTokenId(BPHash);
        if(bp.exists(_index) && bp.makerOf(_index) == BPmaker) {
            return true;
        } else {
            return false;
        }
    }

    function shelf(string BPHash, address _maker)
        public
        onlyAdmins
    {
        require(canShelf(BPHash, _maker));
        ERC721 cr = ERC721(CRaddress);
        uint256 _index = cr.totalSupply();

        if(!BP.exists(_index)) {
            cr.mint(msg.sender, _index,_maker);
        }

    }
    
    function unshelf(string BP)
        public
    {

    }



}

interface ERC721 {
    function exists(uint256 _tokenId) external view returns (bool _exists);
    function makerOf(uint256 _tokenId) external view returns (address _maker);
    function totalSupply() external view returns (uint256);   
    function mint(address _to, uint256 _tokenId, address _maker) external;
    
}

interface WareHouse {
    function getTokenId(string BPhash) external view returns(uint256);
}