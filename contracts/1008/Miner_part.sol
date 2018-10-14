pragma solidity ^0.4.24;

import "./Owned.sol";
import "./AddressUtils.sol";
import "./SafeMath.sol";

contract Miner is Owned {
    using AddressUtils for address;
    using SafeMath for uint256;

    // 算力


/*
关于投放轮次的维护：

官方可以有一次机会设置 beginTime, 在[beginTime, beginTime + timeSpan)的左闭右开的时间区间内
是第一轮次，以此类推。玩家可以领取的AB数量是 sum(第i轮能够领取的AB数量)。 并且在第i轮的任意时间
均可领取第i轮以及以前产出的AB。

在 beginTime 到玩家第一次充值的时间内，因为第i轮玩家能够领取的AB数量是为0，所以没问题。

在时间T时刻某玩家充值（提现）。假设玩家处于第k轮。那么会强制结算该玩家k轮以及之前得到的块。然后
第k+1轮起产出按照新的算力计算。（也就是从T时刻到第k轮结束的时间内，玩家的新充值得到的（和提现导致
减少的）算力是没有发挥作用的）

在时间T时刻，官方改动timeSpan，此时处于k轮，那么[T, T+timeSpan)为第k + 1 轮，以此类推。

为了简单起见，不再维护T之前某个时刻处于第几轮。
*/




    mapping(address => uint256) lastGainIndex;   // 某玩家上次收获到了哪个轮次

    uint256 public beginTime; // 开始产块时刻
    uint256 public lastChangeSpanTime; // 上次修改timeSpan时刻的Unix时间
    uint256 public lastChangeDropIndex; // 上次修改timeSpan时刻时处于哪轮投放

    event AssignDrop(uint256 indexed _timeSpan, uint256 indexed _lastChangeDropIndex, uint256 indexed _lastChangeSpanTime);


    address public dropAlgoAddr; // 计算掉块算法的合约

    uint256 totalBlock; // 总共产块数

    uint256 calMax;     // 算力上限    

    struct Token {
        address addressToken;
        uint256 rate;
        uint256 numMax;
    }

    Token[] tokens; // 所有token    

    mapping(address => mapping(address => uint256)) pledgeAmount; // 某用户质押某token的数量
    mapping(address => uint256) calForceOf; // 某用户的所有算力
    mapping(address => mapping(address => uint256)) tokenCalForceOf; // 某用户从某类质押的token上得到的算力
    

    uint256 totalCalForce;  // 全网总算力
    mapping(address => uint256) pledgeTokenOf; // 全网某类token质押的总数
    mapping(address => uint256) calForceFrom; // 全网所有某类token整体产生的算力数


    event AddABaddress(uint256 indexed _totalOfABsorts, address _ABaddress, string _ABname);
    event DelABaddress(uint256 indexed _indexed, address _delAddress, string _delName, uint256 _totalOfABsorts);
    event ChangeABaddress(string _ABname, address _beforeAddress, address _newAddress);

    event AssignPledge(uint256 indexed _beforeMax, uint256 indexed _newMax);
    event AssignToken(address _tokenAddress, uint256 indexed _rate, uint256 indexed _numMax);
    event ChangeToken(address _tokenAddress, uint256 indexed _beforeRate, uint256 _beforeMax, uint256 indexed _newRate, uint256 _newMax);
    event UnAssignToken(address _tokenAddress, uint256 indexed _rate, uint256 indexed _numMax);
    event PledgeToken(address indexed _user, address _tokenAddress, uint256 _amount);
    event UnPledgeToken(address indexed _user, address _tokenAddress, uint256 _amount);


    // 发块


    struct AB {
        address addressAB;
        uint256 dropRate;   // 概率是1000倍保存
        uint256 dropMax;
    }

    AB[] abs;

    uint256 timeSpan = 1 hours;   // Trigger时间间隔

    event AssignAB(address _ABaddress, uint256 indexed _dropRate, uint256 indexed _dropMax);
    event ChangeAB(address _ABaddress, uint256 indexed _beforeRate, uint256  _beforeMax, uint256 indexed _newRate, uint256  _newMax);
    event UnAssignAB(address _ABaddress, uint256 indexed _dropRate, uint256 indexed _dropMax);

    //

    constructor ()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function setBeginTime(uint256 _time)
        public
        onlyAdmins
    {
        require(_time != 0);

        beginTime = _time;
    }

    // 全局设置每人最大算力值。
    function assignPledge(uint256 _calMax)
        public
        onlyAdmins
    {
        uint256 _beforeMax = calMax;
        calMax = _calMax;

        emit AssignPledge(_beforeMax, _calMax);
    }

    function setDropAlgoAddr(address _addr) 
        public
        onlyAdmins
    {
        dropAlgoAddr = _addr;
    }




    // 对可抵押token(如TAT)的地址，名称等维护
    function assignToken(address _tokenAddress, uint256 _rate, uint256 _numMax)
        public
        onlyAdmins
    {
        require(_tokenAddress.isContract());

        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].addressToken == _tokenAddress) {
                uint256 _beforeRate = tokens[i].rate;
                uint256 _beforeMax = tokens[i].numMax;
                tokens[i].rate = _rate;
                tokens[i].numMax = _numMax;

                emit ChangeToken(_tokenAddress, _beforeRate, _beforeMax, _rate, _numMax);
                
                return;
            }
        }


        Token memory _token = Token(_tokenAddress, _rate, _numMax);
        tokens.push(_token);

        emit AssignToken(_tokenAddress, _rate, _numMax);
    }

    function unAssignToken(address _tokenAddress)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].addressToken == _tokenAddress) {
                uint256 _delRate = tokens[i].rate;
                uint256 _delMax = tokens[i].numMax;

                tokens[i] = tokens[tokens.length.sub(1)];
                delete tokens[tokens.length.sub(1)];
                tokens.length = tokens.length.sub(1);

                emit UnAssignToken(_tokenAddress, _delRate, _delMax);
                break;
            }
        }
    }


    // 得到所有的token地址
    function tokenList()
        public
        view
        returns(address[])
    {
        address[] memory addr = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            addr[i] = tokens[i].addressToken;
        }

        return addr;
    }

    // 得到某token的具体参数
    function tokenInfo(address _tokenAddress)
        public
        view
        returns(address, uint256, uint256)
    {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].addressToken == _tokenAddress) {
                uint256 _rate = tokens[i].rate;
                uint256 _numMax = tokens[i].numMax;

                return (_tokenAddress, _rate, _numMax);
            }
        }
    }

    // 质押Token，把token转进来
    function pledgeToken(address _tokenAddress, uint256 _amount)
        public
    {   
        // 检测token地址在不在列表
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].addressToken == _tokenAddress) {
                triggerDrop();            

                uint256 _rate = tokens[i].rate;
                uint256 _numMax = tokens[i].numMax;
                uint256 _addCalForce = _amount.div(_rate);

                pledgeAmount[msg.sender][_tokenAddress] = pledgeAmount[msg.sender][_tokenAddress].add(_amount);

                require(pledgeAmount[msg.sender][_tokenAddress] <= _numMax); 

                ERC20Interface _token = ERC20Interface(_tokenAddress);
                _token.transferFrom(msg.sender, address(this), _amount);

                calForceOf[msg.sender] = calForceOf[msg.sender].add(_addCalForce);
                tokenCalForceOf[msg.sender][_tokenAddress] = tokenCalForceOf[msg.sender][_tokenAddress].add(_addCalForce);

                require(calForceOf[msg.sender] <= calMax);

                totalCalForce = totalCalForce.add(_addCalForce);
                pledgeTokenOf[_tokenAddress] = pledgeTokenOf[_tokenAddress].add(_amount);
                calForceFrom[_tokenAddress] = calForceFrom[_tokenAddress].add(_addCalForce);

                emit PledgeToken(msg.sender, _tokenAddress, _amount);

                return;
            }
        }

        revert("error _tokenAddress");
    }

    // 取消质押
    function unpledgeToken(address _tokenAddress, uint256 _amount)
        public
    {
        // 检测token地址是不是再列表里面
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].addressToken == _tokenAddress) {
                triggerDrop();

                uint256 _rate = tokens[i].rate;
                uint256 _subCalForce = _amount.div(_rate);

                require(pledgeAmount[msg.sender][_tokenAddress] > _amount); 

                pledgeAmount[msg.sender][_tokenAddress] = pledgeAmount[msg.sender][_tokenAddress].sub(_amount);

                ERC20Interface _token = ERC20Interface(_tokenAddress);
                _token.transfer(msg.sender, _amount);

                if (_subCalForce > calForceOf[msg.sender]) {
                    _subCalForce = calForceOf[msg.sender];
                }                  
              
                calForceOf[msg.sender] = calForceOf[msg.sender].sub(_subCalForce);
                

                tokenCalForceOf[msg.sender][_tokenAddress] = tokenCalForceOf[msg.sender][_tokenAddress].sub(_subCalForce);

                totalCalForce = totalCalForce.sub(_subCalForce);
                pledgeTokenOf[_tokenAddress] = pledgeTokenOf[_tokenAddress].sub(_amount);
                calForceFrom[_tokenAddress] = calForceFrom[_tokenAddress].sub(_subCalForce);

                emit UnPledgeToken(msg.sender, _tokenAddress, _amount);
                return;
            }
        }

        revert("error _tokenAddress");

    }


    function isEmptyString(string _string)
        public
        pure
        returns(bool)
    {
        bytes memory bytesOfString = bytes(_string);

        if(bytesOfString.length == 0) {
            return true;
        } else {
            return false;
        }
    }

    // 某个用户某token质押的数量，以及该token给该用户带来的算力
    function pledgeOf(address _user, address _tokenAddress) 
        public
        view
        returns(uint256, uint256)
    {
        return (pledgeAmount[_user][_tokenAddress], tokenCalForceOf[_user][_tokenAddress]);
    }

    // 某token在全网被质押的总数，以及它在全网的算力
    function totalPledge(address _tokenAddress)
        public
        view
        returns(uint256 _num, uint256 _calForcePledge)
    {
        _num = pledgeTokenOf[_tokenAddress];
        _calForcePledge = calForceFrom[_tokenAddress];
    }


    // 某用户的所有算力(=用户质押token得到的算力)
    function totalPledgeOf(address _user)
        public
        view
        returns(uint256)
    {
        return calForceOf[_user];
    }

    // 全网算力
    function getTotalCalForce()
        public
        view
        returns(uint256)
    {
        return totalCalForce;
    }



    // 发块

    // 后续项目方如果要修改全局参数，单位是秒
    function assignDrop(uint256 _timeSpan)
        public
        onlyAdmins
    {
        require(timeSpan != _timeSpan);

        lastChangeDropIndex = getDropIndex();
        lastChangeSpanTime = now;
        timeSpan = _timeSpan;

        emit AssignDrop(_timeSpan, lastChangeDropIndex, lastChangeSpanTime);
    }

    // 针对AB设置掉落参数，增加AB或者修改AB，_dropRate是1000倍保存
    function assignAB(address _ABaddress, uint256 _dropRate, uint256 _dropMax)
        public
        onlyAdmins
    {
        require(_ABaddress.isContract());
        for (uint256 i = 0; i < abs.length; i++) {
            if (abs[i].addressAB == _ABaddress) {
                uint256 _beforeRate = abs[i].dropRate;
                uint256 _beforeMax = abs[i].dropMax;
                abs[i].dropRate = _dropRate;

                emit ChangeToken(_ABaddress, _beforeRate, _beforeMax, _dropRate, _dropMax);
                return;
            }
        }

        AB memory _ab = AB(_ABaddress, _dropRate, _dropMax);
        abs.push(_ab);

        emit AssignToken(_ABaddress, _dropRate, _dropMax);
    }

    // 移除AB设置
    function unAssignAB(address _addressAB)
        public
        onlyAdmins
    {
        for (uint256 i = 0; i < abs.length; i++) {
            if(abs[i].addressAB == _addressAB) {
                uint256 _dropRate = abs[i].dropRate;
                uint256 _dropMax = abs[i].dropMax;

                abs[i] = abs[abs.length.sub(1)];
                delete abs[abs.length.sub(1)];
                abs.length = abs.length.sub(1);

                emit UnAssignToken(_addressAB, _dropRate, _dropMax);
                break;
            }
        }
        
    }

    // 玩家领取乐块AB
    function triggerDrop()
        public
    {
        uint256 _DropIndex = getDropIndex();
        uint256 _times = _DropIndex.sub(lastGainIndex[msg.sender]);
        require(_times != 0);
        uint256 i;

        uint256[] memory _dropRate = new uint256[](abs.length);

        for (i = 0; i < abs.length; i++) {
            _dropRate[i] = abs[i].dropRate;
        }            

        DropAlgorithms _dropAlgorithms = DropAlgorithms(dropAlgoAddr);

        uint256[] memory _userGetOfAll = _dropAlgorithms.expected(_times, _dropRate, totalBlock, calForceOf[msg.sender], totalCalForce);

        for (i = 0; i < abs.length; i++) {
            ERC20Interface _ab = ERC20Interface(abs[i].addressAB);

            _ab.mintToken(msg.sender, _userGetOfAll[i]);          
        }

        lastGainIndex[msg.sender] = _DropIndex;
    }

    // 某一个时刻某玩家能够领取数量
    function getTriggerInfo(address _user)
        public
        view
        returns(uint256[])
    {
        uint256 _DropIndex = getDropIndex();
        uint256 _times = _DropIndex.sub(lastGainIndex[_user]);
        require(_times != 0);
        uint256 i;

        uint256[] memory _dropRate = new uint256[](abs.length);

        for (i = 0; i < abs.length; i++) {
            _dropRate[i] = abs[i].dropRate;
        }            

        DropAlgorithms _dropAlgorithms = DropAlgorithms(dropAlgoAddr);

        uint256[] memory _userGetOfAll = _dropAlgorithms.expected(_times, _dropRate, totalBlock, calForceOf[_user], totalCalForce);

        return _userGetOfAll;
    }


    // view

    // 现在是第几轮投放
    function getDropIndex()
        public
        view
        returns(uint256)
    {
        uint256 _duration;
        
        if (now < beginTime) {
            return 0;
        } else if (now >= beginTime && lastChangeSpanTime == 0) {
            _duration = now.sub(beginTime);
            return _duration.div(timeSpan).add(1);
        }  else {
            _duration = now.sub(lastChangeSpanTime);
            uint256 _newDropTimes = _duration.div(timeSpan).add(1);

            return _newDropTimes.add(lastChangeDropIndex);
        }
    }


    // 玩家上次领取到哪一轮
    function getGainIndex(address _user)
        public
        view
        returns(uint256)
    {
        return lastGainIndex[_user];
    }

    // 查询全局掉落参数
    function dropInfo()
        public
        view
        returns(uint256)
    {
        return timeSpan;
    }

    // 查询某AB的具体参数
    function abDropInfo(address _addressAB)
        public
        view
        returns(address, uint256, uint256)
    {
        for (uint256 i = 0; i < abs.length; i++) {
            if (abs[i].addressAB == _addressAB) {
                uint256 _dropRate = abs[i].dropRate;
                uint256 _dropMax = abs[i].dropMax;

                return (_addressAB, _dropRate, _dropMax);
            }
        }
    }

    // 查询所有的AB 地址
    function abList()
        public
        view
        returns(address[])
    {
        address[] memory addr = new address[](abs.length);
        for (uint256 i = 0; i < abs.length; i++) {
            addr[i] = abs[i].addressAB;
        }

        return addr;
    }
}

contract ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    function mintToken(address _target, uint256 _mintedAmount) external;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract DropAlgorithms {
    function expected(uint256 _times, uint256[] _dropRate, uint256 _totalBlock, uint256 _userForce, uint256 _totalForce) external pure returns(uint256[]);
}