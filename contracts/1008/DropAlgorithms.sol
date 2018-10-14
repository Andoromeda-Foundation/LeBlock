pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract DropAlgorithms {
    using SafeMath for uint256;

    function expected(uint256 _times, uint256[] _dropRate, uint256 _totalBlock, uint256 _userForce, uint256 _totalForce)
        public
        pure
        returns(uint256[])
    {
        
        uint256[] memory _ABamount = new uint256[](_dropRate.length);
        uint256[] memory _userGetOfAll = new uint256[](_dropRate.length);

        

        for (uint256 i = 0; i < _dropRate.length; i++) {

            _ABamount[i] = _dropRate[i].mul(_totalBlock).div(1000);

            _userGetOfAll[i] = _ABamount[i].mul(_userForce).div(_totalForce).mul(_times);

        }
    }

}