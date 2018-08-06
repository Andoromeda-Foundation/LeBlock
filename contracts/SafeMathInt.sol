pragma solidity ^0.4.24;

/**
 * @title SafeMathInt
 * @dev Math operations with safety checks that throw on error
 * @dev SafeMath adapted for int256
 */
library SafeMathInt {
    function mul(int256 a, int256 b) 
        internal 
        pure 
        returns (int256) 
    {
        /**
         * @dev Prevent overflow when multiplying INT256_MIN with -1
         * https://github.com/RequestNetwork/requestNetwork/issues/43
         */
        assert(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

        int256 c = a * b;
        assert((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) 
        internal 
        pure 
        returns (int256) {
        /**
         * @dev Prevent overflow when dividing INT256_MIN by -1
         * https://github.com/RequestNetwork/requestNetwork/issues/43
         */
        assert(!(a == - 2**255 && b == -1));
        /**
         * @dev assert(b > 0); // Solidity automatically throws when dividing by 0
         * assert(a == b * c + a % b); // There is no case in which this doesn't hold
         */
        int256 c = a / b;
        return c;
    }

    function sub(int256 a, int256 b) 
        internal 
        pure 
        returns (int256) 
    {
        assert((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

        return a - b;
    }

    function add(int256 a, int256 b) 
        internal 
        pure 
        returns (int256) 
    {
        int256 c = a + b;
        assert((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function toUint256Safe(int256 a) 
        internal 
        pure 
        returns (uint256) 
    {
        assert(a>=0);
        return uint256(a);
    }
}