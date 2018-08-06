pragma solidity ^0.4.24;

import "./ERC721Token.sol";
import "./StringUtils.sol";

contract Register is ERC721Token, StringUtils {
    mapping(uint256 => string) ipfsAddrOf;
    mapping(string => uint256) indexOfIpfs;
    bool isOnAdmin;
    
    /**
     * @dev Constructor function
     */
    constructor(string _name, string _symbol) 
        public 
        ERC721Token(_name, _symbol)
    {
        isOnAdmin = true;
    }

    function registerByAdmin(address _user, string _ipfsAddr)
        public
        onlyAdmins
        whenNotPaused
    {
        require(isOnAdmin == true);
        require(indexOfIpfs[_ipfsAddr] == 0 && stringsEqual(ipfsAddrOf[0], _ipfsAddr));
        uint256 _tokenId = allTokens.length;
        require(!exists(_tokenId));

        _mint(_user, _tokenId);
        ipfsAddrOf[_tokenId] = _ipfsAddr;
        indexOfIpfs[_ipfsAddr] = _tokenId;
    }

    function burn(uint256 _tokenId)
        public
        onlyOwnerOf(_tokenId)
        whenNotPaused
    {
        _burn(msg.sender, _tokenId);

        delete indexOfIpfs[ipfsAddrOf[_tokenId]];
        delete ipfsAddrOf[_tokenId];
    }

    /**
     * @dev 用户点击注册，块的数据结构+用户签名发送到中心化服务器上，服务器通过检测其数据结构是否有效
     * @dev 服务器再将数据结构上IPFS，将hash交易上链。服务器要充当一个oracle，下面函数检测到oracle时才执行
     * @dev 为了避免用户直接用web3来调用这个合约。
     */
    /*
    function register(string _ipfsAddr)
        public
    {

    }
    */

    function setTheState(bool _state)
        public 
        onlyAdmins
    {
        isOnAdmin = _state;
    }

    function getIpfsAddr(uint256 _index) 
        public
        view
        returns(string)
    {
        return ipfsAddrOf[_index];
    }

    function getTokenIndex(string _ipfsAddr)
        public
        view
        returns(uint256)
    {
        return indexOfIpfs[_ipfsAddr];
    }

    function getOwnerFromIpfs(string _ipfsAddr)
        public
        view
        returns(address)
    {
        uint256 _tokenId = getTokenIndex(_ipfsAddr);
        return ownerOf(_tokenId);
    }
}