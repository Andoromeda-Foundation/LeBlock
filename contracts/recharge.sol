pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param addr address to check
     * @return whether the target address is a contract
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

/**
 * @title Owned
 */
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
         owner = newOwner;
        newOwner = address(0);
    }
    function addAdmin(address _admin) onlyOwner public {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) onlyOwner public {
        delete admins[_admin];
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyAdmins whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyAdmins whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract recharge  is Pausable {
    using SafeMath for uint256;
    using AddressUtils for address;

    event RechargeEth(address indexed _user, uint256 ethAmount);

    // 用户充值ETH数量
    mapping (address => uint256) public userRecharge;
    // 1 ETH = price TAT;
    uint256 price;
    address ERC20address;
    ERC20Interface token;

    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setPrice(uint256 _price) public onlyAdmins {
        price = _price;
    }

    function setTatAddress(address _address) public onlyAdmins {
        ERC20address = _address;
        token = ERC20Interface(ERC20address);

    }

    function rechargeEth() public payable whenNotPaused {
        require(ERC20address != address(0));
        require(ERC20address.isContract());
        require(msg.value != 0);
        
        uint256 amount = msg.value.mul(price);
        token.transfer(msg.sender, amount);

        emit RechargeEth(msg.sender, msg.value);
    }    

    function withdrawTatAmount (uint256 _amount) public onlyOwner whenNotPaused {
        token.transfer(msg.sender, _amount);    
    }

	function withdrawAll() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount (uint256 _amount) public onlyOwner {
        msg.sender.transfer(_amount);
    }
}

interface ERC20Interface {
    function transfer(address to, uint256 tokens) external returns (bool success);
}