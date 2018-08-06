pragma solidity ^0.4.24;

import "./Pausable.sol";
 
contract ExchangeBetween20token is Pausable {
	
	mapping(address => uint256) priceOf;
	
	/**
	 * @dev set the price between two block, or TAT.
	 */
	function setPrice(uint256 _price, address _tokenAddress) 
		public 
		onlyAdmins 
	{
		priceOf[_tokenAddress] = _price;
	}


}