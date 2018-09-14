1、部署warehouse.sol 
2、部署AB，即ERC20。文件为Leblock.sol。构造函数输入如下
    1) "AB1","ABlock1",1000    
    2) "AB2","ABlock2",1000  
3、部署BP，即ERC721，文件为ERC721Token.sol。
    "Blueprint“,"BP"
4、调用warehouse合约，把AB,BP的地址设置进去
    1) 用owner地址调用addABaddress()两次，把AB1和AB2合约地址传入
    2) 用owner地址调用changeBPaddress()一次，把BP合约地址传入
    3) 用owner地址调用BP合约，把warehouse合约地址设置为admins。
    4) 用owner地址分别调用AB1、AB2合约，转移一定数量的token给测试地址X。 （只要大于2 ether，即2 * 10^18，就ok）
    5) 用X地址分别调用AB1、AB2的approve函数，传入warehouse地址，即允许warehouse合约转移X地址下一些ERC20 token。（数量同上）
    6) 用X地址调用warehouse的compose，执行成功即表示玩家合成了BP。

    




    下面的本来是我准备在测试网上自己调用一遍的，结果部署到一般发现warehouse那个转出ERC20逻辑有误，下面是之前部署的，即逻辑有误的：
1、部署warehouse.sol 
    1) owner:0xbd70d89667a3e1bd341ac235259c5f2dde8172a9
    2) 地址: https://ropsten.etherscan.io/address/0xbe2628d45c8371cbb76746427e0867240600b6f1#code
2、部署AB，即ERC20
    1) "AB1","ABlock1",1000     owner同上   https://ropsten.etherscan.io/address/0xb3a309d3406b7a114a4eb91d31e5f3dc0e827fab#code
    2) "AB2","ABlock2",1000     owner同上   https://ropsten.etherscan.io/address/0xe47a682ae5f74f8677a6509abcb07290eaecf33b#code
3、部署BP，即ERC721
    "Blueprint“,"BP"            https://ropsten.etherscan.io/address/0x37b0ec8dd237a5038720c84c324c44713b314ba0#code
4、调用warehouse合约，把AB,BP的地址设置进去
    1) 用owner地址调用addABaddress()两次，把AB1和AB2合约地址传入
    2) 用owner地址调用changeBPaddress()一次，把BP合约地址传入
    
