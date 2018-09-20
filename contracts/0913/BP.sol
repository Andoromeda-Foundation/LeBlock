pragma solidity ^0.4.24;

import "./ERC721Token.sol";

/*
 * BP是继承了一个
 */

contract BP is ERC721Token {

    // Mapping from token ID to maker
    mapping(uint256 => address) tokenMaker;
    // Mapping from maker to number of maked token
    mapping(address => uint256) makedTokensCount;
    // Mapping from maker to list of maked token IDs
    mapping(address => uint256[]) makedTokens;
    // Mapping from token ID to index of the maker tokens list
    mapping(uint256 => uint256) makedTokensIndex;




    constructor(string _name, string _symbol)
        public
        ERC721Token(_name, _symbol)
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    /**
     * @dev Gets the maked amounts of the specified address
     * @param _maker address to query the amounts of
     * @return uint256 representing the amount owned by the passed address
     */
    function amountsOf(address _maker) 
        public
        view 
        returns (uint256) 
    {
        require(_maker != address(0));
        return makedTokensCount[_maker];
    }

    /**
     * @dev Gets the maker of the specified token ID
     * @param _tokenId uint256 ID of the token to query the maker of
     * @return maker address currently marked as the maker of the given token ID
     */
    function makerOf(uint256 _tokenId) 
        public 
        view 
        returns (address) 
    {
        address maker = tokenMaker[_tokenId];
        return maker;
    }


    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested maker
     * @param _maker address owning the tokens list to be accessed
     * @param _index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list maked by the requested address
     */
    function tokenOfMakerByIndex(
        address _maker,
        uint256 _index
    )
        public
        view
        returns (uint256)
    {
        require(_index < amountsOf(_maker));
        return makedTokens[_maker][_index];
    }


    /**
     * @dev Just for test function to mint a new token
     * Reverts if the given token ID already exists
     * @param _to address the beneficiary that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function mint(address _to, uint256 _tokenId, address _maker) 
        public
        onlyAdmins
    {
        super._mint(_to, _tokenId);
        tokenMaker[_tokenId] = _maker;
        makedTokensCount[_maker] = makedTokensCount[_maker].add(1);
        makedTokens[_maker].push(_tokenId);
        makedTokensIndex[_tokenId] = makedTokens[_maker].length.sub(1);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param _owner owner of the token to burn
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
     */
    function burn(address _owner, uint256 _tokenId, address _maker) 
        public
        onlyAdmins 
    {
        super._burn(_owner, _tokenId);

        require(makerOf(_tokenId) == _maker);
        makedTokensCount[_maker] = makedTokensCount[_maker].sub(1);
        tokenMaker[_tokenId] = address(0);

        uint256 _makerTokenIndex = makedTokensIndex[_tokenId];
        uint256 _makerLastTokenIndex = makedTokens[_maker].length.sub(1);
        uint256 _makerLastToken = makedTokens[_maker][_makerLastTokenIndex];
        makedTokens[_maker][_makerTokenIndex] = _makerLastToken;
        makedTokens[_maker][_makerLastTokenIndex] = 0;
        makedTokens[_maker].length--;
        makedTokensIndex[_tokenId] = 0;
        makedTokensIndex[_makerLastToken] = _makerTokenIndex;
    }
}