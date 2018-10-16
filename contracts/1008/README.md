### 基于Admin版本（没有Oracle）
侧链:  
1. 在侧链上部署两个合约`Leblock.sol`, 其名称为`ab1`, `ab2`(注意其他量的初始化). 玩家地址A下有`ab1`, `ab2`各`10 * 10^18`.  
2. 在侧链上部署`WareHouse_Admins.sol`, 地址为`wh`.  
3. 玩家A调用`ab1`, `ab2`的`approve`函数, 参数为`wh`, `10 * 10^18`(其实estmate没有要求这么多，第一个`1 * 10^18`, 第二个`2 * 10^18`).  
4. 玩家上传数据到IPFS, 并得到一个`BPhash`(链下).  
5. 官方(`owner`)调用`wh`上的`addABaddress`两次, 以此把`ab1`, `ab2`地址传进去. 最好调用`getABaddress`check一下.  
6. 玩家A调用发起请求给PS,将`BPHash`传给PS(链下).
7. 官方(`owner`)去调用`wh`的`compose`, 传入`BPhash`, `玩家A地址`, `对应BP消耗的` 正常执行. 至此`compose`流程走完. 玩家A将减少`1 * 10^18`的`ab1`以及`2 * 10^18`的`ab2`, 将得到一个BP.  
8. 玩家A调用`wh`的`deCompose`, 传入`8步骤`里面的`BPhash`, 即能销毁BP，得到AB  


## CopyrightCenter的shelf和unshelf
### 侧链
`(1-7)`和基于`Admin`版本的`compose`的`(1-7)`相同
1. 在侧链上部署两个合约`Leblock.sol`, 其名称为`ab1`, `ab2`(注意其他量的初始化). 玩家地址A下有`ab1`, `ab2`各`10 * 10^18`.  
2. 在侧链上部署`WareHouse_Admins.sol`, 地址为`wh`.  
3. 玩家A调用`ab1`, `ab2`的`approve`函数, 参数为`wh`, `10 * 10^18`(其实estmate没有要求这么多，第一个`1 * 10^18`, 第二个`2 * 10^18`).  
4. 玩家上传数据到IPFS, 并得到一个`BPhash`(链下).  
5. 官方(`owner`)调用`wh`上的`addABaddress`两次, 以此把`ab1`, `ab2`地址传进去. 最好调用`getABaddress`check一下.  
6. 玩家A调用发起请求给PS,将`BPHash`传给PS(链下).
7. 官方(`owner`)去调用`wh`的`compose`, 传入`BPhash`, `玩家A地址`, `对应BP消耗的` 正常执行. 至此`compose`流程走完. 玩家A将减少`1 * 10^18`的`ab1`以及`2 * 10^18`的`ab2`, 将得到一个BP.  

10. 在侧链上部署`CopyrightCenter.sol`, 地址为`cc`.
12. 官方(`owner`)调用`cc`的`setWHaddress`, 分别传入`wh`.
14. 官方(`owner`)调用`wh`的`addAdmin`, 传入`cc`, 把`cc`设置为`wh`的admin.
15. 官方(`owner`)调用`cc`的`shelf`, 传入上述步骤的`BPhash`, `玩家A`的地址, 就会锁住`BPhash`对应的`bp`, 生成一个`cr`
16. 官方(`owner`)调用`cc`的`unshelf`, 传入`BPhash`, 就会解锁对应的`bp`, 删除一个`cr`

### 主链

1. 在主链上部署`CopyrightCenter_MC.sol`, 地址为`cc_mc`.
2. 官方(`owner`)调用`cc_mc`的`shelf`, 传入上述步骤的`BPhash`, `玩家A`的地址, 就会生成一个`cr`
3. 官方(`owner`)调用`cc`的`unshelf`, 传入`BPhash`, 就会删除一个`cr`


ropsten测试环境：  
`ab1`:      
0x200A363b71b84F6120C1D112774E11A51B79a49b  
https://ropsten.etherscan.io/address/0x200A363b71b84F6120C1D112774E11A51B79a49b#code  
  
`ab2`:    
0xE090EEd19A0a1CC26B31624cf0BfCF529c19bd2f    
https://ropsten.etherscan.io/address/0xE090EEd19A0a1CC26B31624cf0BfCF529c19bd2f#code  
  
`WareHouse_Admins`: 
0x45CaBA99e2085030A8d71eaAfB3AAB7E7009d475  
https://ropsten.etherscan.io/address/0x45caba99e2085030a8d71eaafb3aab7e7009d475#code

`CopyrightCenter`:  
0xAf1BaeA8e561b7383A4A9950AAb3AD92F05ae0Df  
https://ropsten.etherscan.io/address/0xaf1baea8e561b7383a4a9950aab3ad92f05ae0df#code

`CopyrightCenter_MC`:
0x4de67d0De179975b7c741299Dab1b05415665564  
https://ropsten.etherscan.io/address/0x4de67d0de179975b7c741299dab1b05415665564#code  

测试侧链逻辑：  
1. ab1 approve : 
https://ropsten.etherscan.io/tx/0x7e204ba6559fbf08ea44575ccfafae399619c114813362a131755c111bff01b3  

2. ab2 approve:
https://ropsten.etherscan.io/tx/0x8a8f77d1f6fdd3637adebd3ff951b88d5ffa13d26f0a80fb606f8a0a10cfd730  

3. WareHouse_Admins   
addABaddress(0x200A363b71b84F6120C1D112774E11A51B79a49b,"AB1")    
https://ropsten.etherscan.io/tx/0x1ed7eb80af452cbf94cdd343e8ab0f6ae9dfc9b05c72924c011e01c13c192e6e  

4. WareHouse_Admins   
addABaddress(0xE090EEd19A0a1CC26B31624cf0BfCF529c19bd2f,"AB2")    
https://ropsten.etherscan.io/tx/0x032772797127ddba85f39f7060a2868e617e24866e319aba9481b0fafdfacee9

5. WareHouse_Admins  
canCompose("A",[1,1],0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回：bool: true  

6. WareHouse_Admins    
canDeCompose("A")  
返回 bool: false  

7. WareHouse_Admins  
canCompose("",[1,1],0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回 bool: false

8. WareHouse_Admins  
compose("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9,[1000000000000000,200000000000000])  
https://ropsten.etherscan.io/tx/0x749f7f7fcc30dee12276039452b9d61f877a9c0e06c681b78c565f071940e204

9. WareHouse_Admins  
canCompose("A",[1,1],0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回0: bool: false

10. WareHouse_Admins    
canDeCompose("A")  
返回 bool: true

11. CopyrightCenter  
setWHaddress(0x45CaBA99e2085030A8d71eaAfB3AAB7E7009d475)
https://ropsten.etherscan.io/tx/0x504161a473f651c0ae9a7e67153a81516bb0ca292c2d01a1f052e5e29db3a2ce  

12. CopyrightCenter  
canShelf("1",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回 bool: false

13. CopyrightCenter  
canShelf（"A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9）  
返回 bool: true

14. WareHouse_Admins  
addAdmin(0xAf1BaeA8e561b7383A4A9950AAb3AD92F05ae0Df)  
https://ropsten.etherscan.io/tx/0xf481abd657582397e36407ec619b4051856fb78a5774a070c3f53c2cc60fc038

15. CopyrightCenter    
shelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
https://ropsten.etherscan.io/tx/0xc5ff68eff00f09b09ccfc1a4ad517b796a2a4b5c65c897ffd4525e8bc0d70937

16. CopyrightCenter  
canShelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回： bool: false  

17. CopyrightCenter  
canUnshelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
返回： bool: true  

18. CopyrightCenter  
exists（"A")  
0: bool: true

19. WareHouse_Admins
canDeCompose("A")
返回： bool: false

20. CopyrightCenter  
unshelf("A")  
https://ropsten.etherscan.io/tx/0x7d7323b804867129092e678460763005223a60d3cd00239eaa2e34e809a0f6d4

21. WareHouse_Admins  
canDeCompose("A")  
返回： bool: true

22. CopyrightCenter     
canShelf  
"A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9  
0: bool: true   

23. CopyrightCenter    
canUnshelf  
"A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9  
0: bool: false

24. CopyrightCenter    
shelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
https://ropsten.etherscan.io/tx/0x56c289d3a7b2c4e8a91823195f0d3122d4bb834ed44d9eed4e15c126aaff5905

25. CopyrightCenter  
unshelf("A")  
https://ropsten.etherscan.io/tx/0xb883e990c2a42f52967e651c9c248d6f5818984297f4175f17f0d5e6e3ac2384

26. WareHouse_Admins  
deCompose("A")
https://ropsten.etherscan.io/tx/0x19878bdc682f352dd4f2528e9b22589a8d95cc28c62e5b50064110bd23b74cb6


测试主链逻辑：  
1. CC_MC:  
shelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
https://ropsten.etherscan.io/tx/0xc5982bf807cdb4b22593dafac2809bd758576161831ec85a4607107701fa5c09

2. unshelf("A")
https://ropsten.etherscan.io/tx/0xb9a7aa291446a5d4e4d38765905adef31967787f714d4923d03d54439c36cfb6  

3. shelf("A",0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)    
https://ropsten.etherscan.io/tx/0xa85290e8adba61b4f18978b89489ed5ed709990a7f62b3da1a3120051dd9a493





Miner_part.sol Rinkeby 测试
1. `owner`: 0xbd70d89667a3e1bd341ac235259c5f2dde8172a9  

2. `玩家A`: 0x9a63ca719b9433c0cdbc5aeee130614634163279

3. `owner`部署`Miner_part.sol`: https://rinkeby.etherscan.io/address/0xc4b88465b23594b17032049eec7448929b09c610  

4. `owner`部署`DropAlgorithms.sol`：https://rinkeby.etherscan.io/address/0x4a5cbaef2e1c1c0ff2370291af3e439fd779082d  

5. `owner`部署`Leblock.sol`两次, 代表TAT这样的token:
部署时初始化:("T1","Token1",1000): https://rinkeby.etherscan.io/address/0x854b0732410491005a2724ba5d6646c493972c80  
部署时初始化:("T2","Token2",1000): https://rinkeby.etherscan.io/address/0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520  

6. `owner`部署`Leblock.sol`两次, 代表产出的AB:  
部署时初始化：("ab1","AB1",1000): https://rinkeby.etherscan.io/address/0xec73a7539588a1555bfdcb9b8dc44687dd82c481  
部署时初始化：("ab2","AB2",1000): https://rinkeby.etherscan.io/address/0x16383d64635503a02f05d9e8a6fa34c907e5e407


7. `owner`调用:  
`Miner_part.setBeginTime`(1539570299):  
10.15上午某一刻开始  
`Miner_part.assignPledge`(10^20):  
玩家算力上限是100
`Miner_part.setDropAlgoAddr`(0x4a5cbaef2e1c1c0ff2370291af3e439fd779082d):  
设置计算掉落ab数量的合约地址
`Miner_part.assignToken`(0x854b0732410491005a2724ba5d6646c493972c80,10,100*10^18):   
T1 token, 10 T1 token = 1 算力。玩家最多能够质押100个T1 token  
`Miner_part.assignToken`(0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520,5,100*10^18):    
T2 token, 5 T2 token = 1 算力。玩家最多能够质押100个T1 token  
`Miner_part.assignAB`(0xec73a7539588a1555bfdcb9b8dc44687dd82c481, 400, 1000*10^18):   
ab1, 在掉落的块中占40%, 一轮投放最多掉落1000*10^18  
`Miner_part.assignAB`(0x16383d64635503a02f05d9e8a6fa34c907e5e407, 600, 1000*10^18):    
ab2, 在掉落的块中占60%, 一轮投放最多掉落1000*10^18  
注意, 必须所有AB的掉率之和加起来等于1000

8. owner 调用AB1和AB2的addAdmin将Miner_part地址设置为admins

8. view:  
`Miner_part.abList`  
0: address[]: 0xec73a7539588A1555bfdCb9b8Dc44687dD82c481,  0x16383d64635503a02f05D9E8A6fA34C907E5e407  
`beginTime`  
0: uint256: 1539570299 // 2018/10/15 10:24:59  
`dropAlgoAddr`  
0: address: 0x4a5CbAEF2E1C1C0FF2370291Af3E439fD779082D  
`dropInfo`  
0: uint256: 3600  
`getDropIndex`  
0: uint256: 2 //我在12点06查询的, 过了处在第二轮
`getGainIndex`(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
0: uint256: 0  
`getTotalCalForce`  
0: uint256: 0  
`lastChangeDropIndex`  
0: uint256: 0  
`lastChangeSpanTime`  
0: uint256: 0  
`tokenInfo`(0x854b0732410491005a2724ba5d6646c493972c80)  
0: address: 0x854B0732410491005a2724BA5D6646C493972c80  
1: uint256: 10  
2: uint256: 100000000000000000000  
`tokenInfo`(0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520)  
0: address: 0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520  
1: uint256: 5  
2: uint256: 100000000000000000000   
`tokenInfo`(0xbd70d89667A3E1bD341AC235259c5f2dDE8172A9)  
0: address: 0x0000000000000000000000000000000000000000  
1: uint256: 0  
2: uint256: 0  
`tokenList`
0: address[]: 0x854B0732410491005a2724BA5D6646C493972c80,0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520
`totalPledge`(0x854B0732410491005a2724BA5D6646C493972c80)
0: uint256: _num 0  
1: uint256: _calForcePledge 0  
`totalPledgeOf`(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)
0: uint256: 0

9. owner转1000 t1给 A, 转1000 t2给 B：
Leblock.transfer(0x9a63ca719b9433c0cdbc5aeee130614634163279, 1000*10^18)

10. owner调用t1,t2的mintToken, 给自己增发1000 t1和t2(因为发现owner没有token了)
Leblock.mintToken(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9,1000000000000000000000)

11. owner设置每轮总AB发行了总数是100个
Miner_part.setTotalBlock(100*10^18)

12. A在Miner_part里面充值t1,t2:
Miner_part.pledgeToken(0x854B0732410491005a2724BA5D6646C493972c80, 100*10^18)
Miner_part.pledgeToken(0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520, 100*10^18)
那么玩家A将得到10+20=30算力，合约里面是30*10^18 wei 算力。

13. owner在Miner_part里面充值t1,t2:
Miner_part.pledgeToken(0x854B0732410491005a2724BA5D6646C493972c80, 50*10^18)
Miner_part.pledgeToken(0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520, 200*10^18)
那么owner将得到5+40=45算力，合约里面是45*10^18 wei 算力

第12，13的时候revert, 因为triggerDrop之前处理时是如果没有可以领取的，就直接revert。改为直接return。再次部署试试。



上面的步骤同上，但是miner_part地址需要更改





Miner_part.sol Rinkeby 测试
// 第二部署时忘记切换metamask的账户了，所以Miner_part的owner时 玩家A；
1. `owner`: 0xbd70d89667a3e1bd341ac235259c5f2dde8172a9  

2. `玩家A`: 0x9a63ca719b9433c0cdbc5aeee130614634163279

3. `owner`部署`Miner_part.sol`: https://rinkeby.etherscan.io/address/0x55c1547094f90caa85dde7baa110df1cdb427d3d   

4. `owner`部署`DropAlgorithms.sol`：https://rinkeby.etherscan.io/address/0x4a5cbaef2e1c1c0ff2370291af3e439fd779082d  

5. `owner`部署`Leblock.sol`两次, 代表TAT这样的token:
部署时初始化:("T1","Token1",1000): https://rinkeby.etherscan.io/address/0x854b0732410491005a2724ba5d6646c493972c80  
部署时初始化:("T2","Token2",1000): https://rinkeby.etherscan.io/address/0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520  

6. `owner`部署`Leblock.sol`两次, 代表产出的AB:  
部署时初始化：("ab1","AB1",1000): https://rinkeby.etherscan.io/address/0xec73a7539588a1555bfdcb9b8dc44687dd82c481  
部署时初始化：("ab2","AB2",1000): https://rinkeby.etherscan.io/address/0x16383d64635503a02f05d9e8a6fa34c907e5e407


7. `owner`调用:  
`Miner_part.setBeginTime`(1539570299):  
10.15上午某一刻开始  
`Miner_part.assignPledge`(10^22):  
玩家算力上限是10000
`Miner_part.setDropAlgoAddr`(0x4a5cbaef2e1c1c0ff2370291af3e439fd779082d):  
设置计算掉落ab数量的合约地址
`Miner_part.assignToken`(0x854b0732410491005a2724ba5d6646c493972c80,10,1000*10^18):   
T1 token, 10 T1 token = 1 算力。玩家最多能够质押1000个T1 token  
`Miner_part.assignToken`(0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520,5,1000*10^18):    
T2 token, 5 T2 token = 1 算力。玩家最多能够质押1000个T1 token  
`Miner_part.assignAB`(0xec73a7539588a1555bfdcb9b8dc44687dd82c481, 400, 10000*10^18):   
ab1, 在掉落的块中占40%, 一轮投放最多掉落10000*10^18  
`Miner_part.assignAB`(0x16383d64635503a02f05d9e8a6fa34c907e5e407, 600, 10000*10^18):    
ab2, 在掉落的块中占60%, 一轮投放最多掉落10000*10^18  
注意, 必须所有AB的掉率之和加起来等于1000

8. owner 调用AB1和AB2的addAdmin将Miner_part地址设置为admins

9. owner和玩家A分别都调用T1,T2的approve函数，允许Miner_part转移token。
approve(0x55c1547094f90caa85dde7baa110df1cdb427d3d,1000000000000000000000)


8. view:  
`Miner_part.abList`  
0: address[]: 0xec73a7539588A1555bfdCb9b8Dc44687dD82c481,  0x16383d64635503a02f05D9E8A6fA34C907E5e407  
`beginTime`  
0: uint256: 1539570299 // 2018/10/15 10:24:59  
`dropAlgoAddr`  
0: address: 0x4a5CbAEF2E1C1C0FF2370291Af3E439fD779082D  
`dropInfo`  
0: uint256: 3600  
`getDropIndex`  
0: uint256: 2 //我在12点06查询的, 过了处在第二轮
`getGainIndex`(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)  
0: uint256: 0  
`getTotalCalForce`  
0: uint256: 0  
`lastChangeDropIndex`  
0: uint256: 0  
`lastChangeSpanTime`  
0: uint256: 0  
`tokenInfo`(0x854b0732410491005a2724ba5d6646c493972c80)  
0: address: 0x854B0732410491005a2724BA5D6646C493972c80  
1: uint256: 10  
2: uint256: 100000000000000000000  
`tokenInfo`(0x58eb248ae9a3cd58731f7e2e0cfc20ac66444520)  
0: address: 0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520  
1: uint256: 5  
2: uint256: 100000000000000000000   
`tokenInfo`(0xbd70d89667A3E1bD341AC235259c5f2dDE8172A9)  
0: address: 0x0000000000000000000000000000000000000000  
1: uint256: 0  
2: uint256: 0  
`tokenList`
0: address[]: 0x854B0732410491005a2724BA5D6646C493972c80,0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520
`totalPledge`(0x854B0732410491005a2724BA5D6646C493972c80)
0: uint256: _num 0  
1: uint256: _calForcePledge 0  
`totalPledgeOf`(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)
0: uint256: 0

9. owner转1000 t1给 A, 转1000 t2给 B：
Leblock.transfer(0x9a63ca719b9433c0cdbc5aeee130614634163279, 1000*10^18)

10. owner调用t1,t2的mintToken, 给自己增发1000 t1和t2(因为发现owner没有token了)
Leblock.mintToken(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9,1000000000000000000000)

11. owner设置每轮总AB发行了总数是100个
Miner_part.setTotalBlock(100*10^18)

12. A在Miner_part里面充值t1,t2:
Miner_part.pledgeToken(0x854B0732410491005a2724BA5D6646C493972c80, 100*10^18)
Miner_part.pledgeToken(0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520, 100*10^18)
那么玩家A将得到10+20=30算力，合约里面是30*10^18 wei 算力。

13. owner在Miner_part里面充值t1,t2:
Miner_part.pledgeToken(0x854B0732410491005a2724BA5D6646C493972c80, 50*10^18)
Miner_part.pledgeToken(0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520, 200*10^18)
那么owner将得到5+40=45算力，合约里面是45*10^18 wei 算力

14. view
Miner_part:

abDropInfo

0xec73a7539588A1555bfdCb9b8Dc44687dD82c481
0: address: 0xec73a7539588A1555bfdCb9b8Dc44687dD82c481
1: uint256: 400
2: uint256: 10000000000000000000000

abDropInfo

0x16383d64635503a02f05D9E8A6fA34C907E5e407
0: address: 0x16383d64635503a02f05D9E8A6fA34C907E5e407
1: uint256: 600
2: uint256: 10000000000000000000000

abList
0: address[]: 0xec73a7539588A1555bfdCb9b8Dc44687dD82c481,0x16383d64635503a02f05D9E8A6fA34C907E5e407

beginTime
0: uint256: 1539570299

dropAlgoAddr
0: address: 0x4a5CbAEF2E1C1C0FF2370291Af3E439fD779082D

dropInfo
0: uint256: 3600

getDropIndex
0: uint256: 5

getGainIndex

0x9a63ca719b9433c0cdbc5aeee130614634163279
0: uint256: 5

// 每次投放100个块(AB总数)
getTotalBlock
0: uint256: 100000000000000000000

// 总算力
getTotalCalForce
0: uint256: 75000000000000000000

getTriggerInfo

0xbd70d89667a3e1bd341ac235259c5f2dde8172a9
0: uint256[]:

lastChangeDropIndex
0: uint256: 0

lastChangeSpanTime
0: uint256: 0

owner
0: address: 0x9a63CA719b9433c0cdBc5AeeE130614634163279


pledgeOf

"0x9a63CA719b9433c0cdBc5AeeE130614634163279","0x854B0732410491005a2724BA5D6646C493972c80"
0: uint256: 100000000000000000000 // 充值了这么多t1 100
1: uint256: 10000000000000000000  // 以上t1产生了这么多算力 10

pledgeOf

"0x9a63CA719b9433c0cdBc5AeeE130614634163279","0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520"
0: uint256: 100000000000000000000 // 充值了这么多t2 100
1: uint256: 20000000000000000000 // 这么多t2产生了这么多算力 20
所以玩家A 有30算力

Owner：
pledgeOf

"0xbd70d89667a3e1bd341ac235259c5f2dde8172a9","0x854B0732410491005a2724BA5D6646C493972c80"
0: uint256: 50000000000000000000
1: uint256: 5000000000000000000

pledgeOf

"0xbd70d89667a3e1bd341ac235259c5f2dde8172a9","0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520"
0: uint256: 200000000000000000000
1: uint256: 40000000000000000000

所以玩家owner 有45算力

totalPledgeOf

0xbd70d89667a3e1bd341ac235259c5f2dde8172a9
0: uint256: 45000000000000000000

totalPledge

0x854B0732410491005a2724BA5D6646C493972c80
0: uint256: _num 150000000000000000000
1: uint256: _calForcePledge 15000000000000000000

totalPledge

0x58EB248Ae9A3CD58731f7E2E0Cfc20ac66444520
0: uint256: _num 300000000000000000000
1: uint256: _calForcePledge 60000000000000000000


一段时间过去了，发块投放到了第六轮，但是玩家上次是领取了第五轮。
getDropIndex
0: uint256: 6

getGainIndex(0x9a63ca719b9433c0cdbc5aeee130614634163279)
0: uint256: 5

因此可以得到玩家owner可领取的的量：
getTriggerInfo(0xbd70d89667a3e1bd341ac235259c5f2dde8172a9)
0: uint256[]: 24000000000000000000,36000000000000000000

玩家A可领取的量：
getTriggerInfo(0x9a63ca719b9433c0cdbc5aeee130614634163279)
0: uint256[]: 16000000000000000000,24000000000000000000

调用triggerDrop()正常领取

玩家提取t1：
正常
