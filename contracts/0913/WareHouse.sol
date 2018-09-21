pragma solidity ^0.4.24;

import "./Owned.sol";
import "./AddressUtils.sol";
import "./SafeMath.sol";

contract WareHouse is Owned {
    using AddressUtils for address;
    using SafeMath for uint256;

    mapping(address => mapping(uint256 => uint256)) depositOf; // 玩家在这个合约里面质押了多少ERC20
    mapping(string => bool) isLock;
    // 代表AB种类的合约地址；
    address[] public addressOf;
    address public BPaddress;

    mapping(string => uint256) indexOfBPhash;

    event AddABaddress(uint256 indexed _indexed, address _ABaddress);
    event DelABaddress(uint256 indexed _indexed, address _BeforeAddress, address _nowAddress, uint256 _length);
    event ChangeBPaddress(address _before, address _now);
    event Compose(uint256 _BPindex);
    event GetAB(address _ABaddress, address _toAddress, uint256 _amount);

    constructor() 
        public 
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function addABaddress(address _ABaddress)
        public
        onlyAdmins
    {
        require(_ABaddress.isContract());
        addressOf.push(_ABaddress);

        emit AddABaddress(addressOf.length - 1, _ABaddress);
    }

    // 地址不要轻易改动，因为Oracle服务器是按照AB种类返回的且depositOf也是根据这个
    function delABaddress(uint256 _index, address _ABaddress)
        public
        onlyAdmins
    {
        require(addressOf[_index] == _ABaddress);
        addressOf[_index] = addressOf[addressOf.length - 1];
        delete addressOf[addressOf.length - 1];
        addressOf.length--;

        emit DelABaddress(_index, _ABaddress, addressOf[_index], addressOf.length);
    }

    function changeBPaddress(address _new)
        public
        onlyAdmins
    {
        require(_new.isContract());
        address _before = BPaddress;
        BPaddress = _new;
        
        emit ChangeBPaddress(_before, BPaddress);
    }

    function compose(string BPhash)
        public 
    {
        uint256[] memory arr = estimate(BPhash);

        require(canCompose(BPhash));
            
        // 假设返回的不同AB使用数量和addressOf保存的AB地址是对应的。因此arr的长度肯定和addressOf长度一致。
        for (uint256 i = 0; i < arr.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            if(AB.transferFrom(msg.sender,this, arr[i])) {
                depositOf[msg.sender][i] = depositOf[msg.sender][i].add(arr[i]);
            }         
        }

        BP bp = BP(BPaddress);
        // tokenId 不为零
        uint256 _totalSupply = bp.totalSupply();
        uint256 _tokenId = _totalSupply.add(1);

        if(!bp.exists(_tokenId)) {
            bp.mint(owner, _tokenId, msg.sender);
            indexOfBPhash[BPhash] = _tokenId;
        }

        emit Compose(_tokenId);

    }

    function canCompose(string BPhash)
        internal
        view
        returns(bool)
    {
        uint256[] memory arr = estimate(BPhash);
        BP bp = BP(BPaddress);
        uint256 _tokenId = indexOfBPhash[BPhash];

        if(checkBalance(arr) && !bp.exists(_tokenId)) {
            return true;
        } else {
            return false;
        }        
    }

    function deCompose(string BPhash)
        public
    {
        BP bp = BP(BPaddress);
        uint256 _tokenId = indexOfBPhash[BPhash];

        require(canDeCompose(BPhash));

        uint256[] memory arr = estimate(BPhash);
        for (uint256 i = 0; i < arr.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            if(AB.transfer(msg.sender,arr[i])) {
                depositOf[msg.sender][i] = depositOf[msg.sender][i].sub(arr[i]);
            }
        }

        address _owner = bp.ownerOf(_tokenId);
        bp.burn(_owner, _tokenId, msg.sender);
    }

    function canDeCompose(string BPhash)
        internal
        view
        returns(bool)
    {
        BP bp = BP(BPaddress);
        uint256 _tokenId = indexOfBPhash[BPhash];

        if(bp.exists(_tokenId) && msg.sender == bp.makerOf(_tokenId) && !isLock[BPhash]) {
            return true;
        } else {
            return false;
        }
    }

    // oracle
    function estimate(string BPhash)
        internal
        view
        returns(uint256[])
    {
        uint256[] memory a;
        for (uint256 i = 0; i < 2; i++) {
            a[i] = (i+1) * 1 ether;
        }

        return a;
    }

    function setLock(string BPhash, bool lock)
        public
        onlyAdmins
    {
        isLock[BPhash] = lock;
    }

    function lockState(string BPhash)
        public
        view
        returns(bool)
    {
        return isLock[BPhash];    
    }


    function checkBalance(uint256[] _array)
        internal
        view
        returns(bool)
    {
        for(uint256 i = 0; i < _array.length; i++) {
            ERC20 AB = ERC20(addressOf[i]);
            if (AB.balanceOf(msg.sender) < _array[i]) {
                return false;
            } 
        }

        return true;
    }

    function getABsort() 
        public
        view
        returns(uint256)
    {
        return addressOf.length;
    }

    function getTokenId(string BPhash)
        public
        view
        returns(uint256)
    {
        return indexOfBPhash[BPhash];
    }

    function getERC20(address _ABaddress, address _toAddress, uint256 _amount)
        public
        onlyAdmins
    {
        ERC20 AB = ERC20(_ABaddress);
        AB.transfer(_toAddress, _amount);

        emit GetAB(_ABaddress, _toAddress, _amount);
    }

}

interface  ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

interface BP {
    function mint(address _to, uint256 _tokenId, address _maker) external;
    function burn(address _owner, uint256 _tokenId, address _maker) external;
    function totalSupply() external view returns (uint256);
    function exists(uint256 _tokenId) external view returns (bool _exists);    
    function makerOf(uint256 _tokenId) external view returns (address);
    function ownerOf(uint256 _tokenId) external view returns (address);
}