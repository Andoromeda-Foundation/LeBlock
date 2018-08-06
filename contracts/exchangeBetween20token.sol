	/**
	 * @dev set the price between two block, or TAT.
	 */
	function setPrice(uint256 _price, address tokenAddress) public onlyAdmins {
		require(tokenAddress.isContract());
		price[tokenAddress] = _price;
	}

	/**
	 * @dev 
	 */
	function t