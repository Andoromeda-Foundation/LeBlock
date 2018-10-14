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
