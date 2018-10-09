pragma solidity ^0.4.24;

import "./Owned.sol";
import "./AddressUtils.sol";
import "./SafeMath.sol";

contract CopyrightCenter is Owned {
    using AddressUtils for address;
    using SafeMath for uint256;

    address WHaddress; // WareHouse

    event Shelf(address _maker, string _CRHash);
    event Unshelf(address _maker, string _CRHash);

    // CRhash IS BPhash in CopyrightCenter
    string[] allCRs;
    mapping(string => address) CRmaker; // CRhash => 制造者
    mapping(address => uint256) makedCRsCount;  // 制造者 => 他制造了多少CR
    mapping(address => string[]) makedCRs;  // 制作者 => 他制造的所有CR的CRhash
    mapping(string => uint256) makedCRsIndex;   // CRhash => 该CR在制造者所有CR中(makedCRs)的索引
    mapping(string => uint256) allCRsIndex; // CRhash => 该CR在所有CR中(allCRs)的索引


    constructor()
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
    }



    function setWHaddress(address _addr)
        public
        onlyAdmins
    {
        require(_addr.isContract());
        WHaddress = _addr;
    }


    function canShelf(string _CRhash, address _BPmaker)
        public
        view
        returns(bool)
    {
        WareHouse wh = WareHouse(WHaddress);

        if(wh.exists(_CRhash) && wh.makerOf(_CRhash) == _BPmaker && !exists(_CRhash) && !wh.lockState(_CRhash) && !isEmptyString(_CRhash)) {
            return true;
        } else {
            return false;
        }
    }

    function shelf(string _CRhash, address _CRmaker)
        public
        onlyAdmins
    {
        require(canShelf(_CRhash, _CRmaker));
        WareHouse wh = WareHouse(WHaddress);

        wh.setLock(_CRhash, true);


        _mint(_CRhash, _CRmaker);

        
        emit Shelf(_CRmaker, _CRhash);
        
    }

    function _mint(string _CRhash, address maker)
        internal
    {
        require(CRmaker[_CRhash] == address(0));
        
        CRmaker[_CRhash] = maker;
        makedCRsCount[maker] = makedCRsCount[maker].add(1);

        uint256 lengthOfmaked = makedCRs[maker].push(_CRhash);
        makedCRsIndex[_CRhash] = lengthOfmaked.sub(1);

        allCRsIndex[_CRhash] = allCRs.length;        
        allCRs.push(_CRhash);

        require(makedCRsCount[maker] == makedCRs[maker].length);
    }    
    
    function canUnshelf(string _CRhash, address _CRmaker)
        public
        view
        returns(bool)
    {
        WareHouse wh = WareHouse(WHaddress);

        if(exists(_CRhash) && _CRmaker == CRmaker[_CRhash] && wh.lockState(_CRhash)) {
            return true;
        } else {
            return false;
        }
    }


    function unshelf(string _CRhash)
        public
        onlyAdmins
    {
        WareHouse wh = WareHouse(WHaddress);

        address _maker = makerOf(_CRhash);

        require(canUnshelf(_CRhash, _maker));

        _burn(_CRhash, _maker);

        wh.setLock(_CRhash, false);

        emit Unshelf(_maker, _CRhash);

    }

    function _burn(string _CRhash, address _maker)
        internal
    {
        makedCRsCount[_maker] = makedCRsCount[_maker].sub(1);
        delete CRmaker[_CRhash];

        // 维护该用户的CRhash相关数据
        uint256 CRindex = makedCRsIndex[_CRhash];
        uint256 lastCRindex = makedCRs[_maker].length.sub(1);
        string memory lastCR = makedCRs[_maker][lastCRindex];

        makedCRs[_maker][CRindex] = lastCR;
        delete makedCRs[_maker][CRindex];

        makedCRs[_maker].length = makedCRs[_maker].length.sub(1);
        delete makedCRsIndex[_CRhash];
        makedCRsIndex[lastCR] = CRindex;

        require(makedCRsCount[_maker] == makedCRs[_maker].length);


        // 维护全网的CRhash相关数据
        uint256 CRindexInAll = allCRsIndex[_CRhash];
        uint256 lastCRindexInAll = allCRs.length.sub(1);
        string memory lastCRinAll = allCRs[lastCRindexInAll];

        allCRs[CRindexInAll] = lastCRinAll;
        delete allCRs[lastCRindexInAll];

        allCRs.length = allCRs.length.sub(1);
        delete allCRsIndex[_CRhash];
        allCRsIndex[lastCRinAll] = CRindexInAll;

    }    

    function amountOfCRs(address _maker)
        public
        view
        returns(uint256 _balance)
    {
        return makedCRsCount[_maker];
    }

    function makerOf(string CRhash)
        public
        view
        returns(address)
    {
        return CRmaker[CRhash];
    }

    function CRofMakerByIndex(address _maker, uint256 _index)
        public
        view
        returns(string)
    {
        return makedCRs[_maker][_index];
    }


    function haveShelf(string _CRhash)
        public
        view
        returns(bool)
    {
        if(makerOf(_CRhash) != address(0)) {
            return true;
        } else {
            return false;
        }
    }


    function getWHaddress()
        public
        view
        returns(address)
    {
        return WHaddress;
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

    function exists(string _CRhash)
        public
        view
        returns(bool)
    {
        address maker = CRmaker[_CRhash];
        return maker != address(0);
    }



}


interface WareHouse {
    function setLock(string BPhash, bool isLock) external;
    function lockState(string BPhash) external view returns(bool);
    function exists(string BPhash) external view returns(bool);
    function makerOf(string BPhash) external view returns(address);
}