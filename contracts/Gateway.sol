pragma solidity ^0.4.24;

import "./ECRecovery.sol";
import "./Pausable.sol";
import "./SafeMath.sol";
import "./Memory.sol";

contract Gateway is Pausable {
    using ECRecovery for bytes32;
    using SafeMath for uint256;

    address clientContractAddress;
    address addr;

    // uint256, uint8, int256, int8, address, bytes4, bytes32, bool, 
    enum Paragmeters {uint256_, uint8_, int256_, int8_, address_, bytes4_, bytes32_, bool_}

    mapping(bytes4 => Paragmeters[]) funcParaList;
    bytes4[] exitMethod;
    mapping(bytes4 => uint256) methodToId; // methodId to index in exitMethod;

    constructor(address _client) 
        public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
        clientContractAddress = _client;
    }


    /**
     * @dev _methodId长度不影响执行,会自动截取或者补0; 但是_paras参数需要小于枚举的最大数
     * https://ropsten.etherscan.io/address/0x78e042078cf425c1b08a594c493560935378f64b#code
     */
    function registerFuntion(bytes4 _methodId, Paragmeters[] _paras) 
        public 
        onlyAdmins 
    {
        exitMethod.push(_methodId);
        methodToId[_methodId] = exitMethod.length;
        funcParaList[_methodId] = _paras;
    }


    function deleteFunciton(bytes4 _methodId)
        public
        onlyAdmins
    {
        uint256 _index = methodToId[_methodId];
        uint256 _length = exitMethod.length;
        exitMethod[_index] = exitMethod[_length - 1];
        delete exitMethod[_length - 1];
        exitMethod.length = _length - 1;

        delete methodToId[_methodId];
        delete funcParaList[_methodId];
    }
    

    /**
     * @dev without switch, solidity is stupid
     */
    function together(bytes _sig, bytes32 _hash, bytes _payload, bytes4 _methodId)
        public
        returns(bool)
    {
        require(isMethodExit(_methodId));
        address _from = decrypt(_sig, _hash);

        uint256 _len = funcParaList[_methodId].length;
        bytes32[] memory _paras = decodePayload(_payload);

        require(_len == _paras.length);

        if(_len == 0){
            return clientContractAddress.call(_methodId, _from);
        } else if (_len == 1) {
            execute1(_methodId, _from, _paras[0]);
        } else if (_len == 2) {
            if(funcParaList[_methodId][0] == Paragmeters.uint256_) {
                return clientContractAddress.call(_methodId, _from, uint256(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.uint8_) {
                return clientContractAddress.call(_methodId, _from, uint8(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.int256_) {
                return clientContractAddress.call(_methodId, _from, int256(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.int8_) {
                return clientContractAddress.call(_methodId, _from, int8(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.address_) {
                return clientContractAddress.call(_methodId, _from, address(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.bytes4_) {
                return clientContractAddress.call(_methodId, _from, bytes4(_paras[0]));
            } else if(funcParaList[_methodId][0] == Paragmeters.bytes32_) {
                return clientContractAddress.call(_methodId, _from, _paras[0]);
            }
        }
    }


    


    // view
    function isMethodExit(bytes4 _methodId) 
        public
        view
        returns (bool)
    {
        if (methodToId[_methodId] == 0 && exitMethod[0] != _methodId) {
            return false;
        } else {
            return true;
        }
    }

    


    // internal functions
    /**
     * @dev using inline assembly.
     */
    function subBytes(bytes memory _input, uint256 _startIndex, uint256 _endIndex) 
        internal 
        pure
        returns (bytes) 
    {
        require(_startIndex < _endIndex && _endIndex < _input.length);
        
        uint256 _addr = Memory.dataPtr(_input);
        return Memory.toBytes(_addr + _startIndex, _endIndex - _startIndex);
    }


    function decodePayload(bytes _payload)
        internal
        returns (bytes32[])
    {
        uint256 _len = _payload.length;
        bytes32[] storage _paras;
        
        require((_len.sub(4).mod(32)) == 0);
        uint256 _loops = _len.div(32);
        bytes32 _temp;

        for(uint256 i = 0; i < _loops; i++) {            
            _temp = bytesToBytes32(subBytes(_payload, 4 + 32*i, 4 + 32*(i + 1)));
            _paras.push(_temp);       
        }
        return _paras;       
    }


    /**
     * @dev convert 32 bytes array to bytes32
     */
    function bytesToBytes32(bytes b) 
        internal 
        pure 
        returns (bytes32) 
    {
        require(b.length == 32);

        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function bytes32ToBool(bytes32 _a)
        internal
        pure
        returns(bool)
    {
        if(uint256(_a) == 1){
            return true;
        } else {
            return false;
        }
    }
    


    function decrypt(bytes _sig, bytes32 _hash)
        internal
        pure
        returns(address) 
    { 
        bytes32 _toEthHash = _hash.toEthSignedMessageHash();
        address _x = _toEthHash.recover(_sig);

        return _x;
    }    


    /**
     * @dev call the run
     */
    function execute1(bytes4 _methodId, address _from, bytes32 _para) 
        internal 
        returns(bool)
    {
        if(funcParaList[_methodId][0] == Paragmeters.uint256_) {
            return clientContractAddress.call(_methodId, _from, uint256(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.uint8_) {
            return clientContractAddress.call(_methodId, _from, uint8(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.int256_) {
            return clientContractAddress.call(_methodId, _from, int256(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.int8_) {
            return clientContractAddress.call(_methodId, _from, int8(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.address_) {
            return clientContractAddress.call(_methodId, _from, address(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.bytes4_) {
            return clientContractAddress.call(_methodId, _from, bytes4(_para));
        } else if(funcParaList[_methodId][0] == Paragmeters.bytes32_) {
            return clientContractAddress.call(_methodId, _from, _para);
        } else if(funcParaList[_methodId][0] == Paragmeters.bool_) {
            return clientContractAddress.call(_methodId, _from, bytes32ToBool(_para));
        }
    }
/*
    function execute2(bytes4 _methodId, address _from, bytes32 _para1, bytes32 _para2) 
        internal 
        returns(bool)
    {
        if(funcParaList[_methodId][0] == Paragmeters.uint256_) {
            if(funcParaList[_methodId][1] == Paragmeters.uint256_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), uint256(_para2));
            } else if(funcParaList[_methodId][0] == Paragmeters.uint8_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), uint8(_para2));
            } else if(funcParaList[_methodId][0] == Paragmeters.int256_) {
            } else if(funcParaList[_methodId][0] == Paragmeters.int8_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), int8(_para2));
            } else if(funcParaList[_methodId][0] == Paragmeters.address_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), address(_para2));
            } else if(funcParaList[_methodId][0] == Paragmeters.bytes4_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), bytes4(_para2));
            } else if(funcParaList[_methodId][0] == Paragmeters.bytes32_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), _para2);
            } else if(funcParaList[_methodId][0] == Paragmeters.bool_) {
                return clientContractAddress.call(_methodId, _from, uint256(_para1), bytes32ToBool(_para2));
            }
            return clientContractAddress.call(_methodId, _from, uint256(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.uint8_) {
            return clientContractAddress.call(_methodId, _from, uint8(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.int256_) {
            return clientContractAddress.call(_methodId, _from, int256(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.int8_) {
            return clientContractAddress.call(_methodId, _from, int8(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.address_) {
            return clientContractAddress.call(_methodId, _from, address(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.bytes4_) {
            return clientContractAddress.call(_methodId, _from, bytes4(_para2));
        } else if(funcParaList[_methodId][0] == Paragmeters.bytes32_) {
            return clientContractAddress.call(_methodId, _from, _para2);
        } else if(funcParaList[_methodId][0] == Paragmeters.bool_) {
            return clientContractAddress.call(_methodId, _from, bytes32ToBool(_para2));
        }
    }
*/
}