# 已有的合约
1. Gateway_notary.sol(MC/TC):通过公证人的方法实现跨链。  
2. WareHouse.sol(TC):用Oracle的方案实现仓库。Oracle没有实现，但是能够测试。  
3. WareHouse_Admins.sol(TC):没使用Oracle的方案实现仓库。  
4. CopyrightCenter.sol(TC):侧链上的版权中心。  
5. CopyrightCenter_MC.sol(MC):主链上的版权中心。  
6. BP.sol(TC/MC):侧链上的BP、CC(已shelf了的BP)表示者，主链上的CC表示者。  
7. Leblock.sol(TC/MC):侧链以及主链上的AB表示者。  



# 测试流程
## 跨链转账
### TC => MC
侧链：  
1. 侧链上部署`Leblock.sol`, 假设其名称为`ab1`, 地址为`ab1`, 主链上部署`Leblock.sol`, 名称为`AB1`, 地址为`AB1`. 部署`Leblock.sol`时注意输入符号, 名字, 总供应量:
`constructor(string _symbol, string _name, uint256 _totalSupply) public`, 
其中总供应量会全部给部署合约的人的地址  
2. 在侧链以及主链上部署`Gateway_notary.sol`, 侧链上的地址为`g1`, 主链上的为`G1`  
3. 玩家A在`ab1`上有`100 ab1`, 玩家A调用`ab1`上合约的`approve`, 输入`g1`, `100*10^18`.  
4. 玩家A调用`g1`上合约的`deposit20`, 输入`100*10^18`, `ab1`  
主链：  
5. 官方先从`AB1`转足够的`AB1`到`G1`地址下, 然后官方从链下得知玩家A已经在侧链上充值了, 官方调用`G1`的`withdraw20`, 输入`100*10^18`, `AB1`, `玩家A在主网上地址`，`txhash`，等额的token将会转给玩家A在主网上的地址。`  

### MC => TC
和上面类似  


## 逻辑（主链路）
### 基于Oracle版本
侧链：
1. 在侧链上部署两个合约`Leblock.sol`, 其名称为`ab1`, `ab2`(注意其他量的初始化). 玩家地址A下有`ab1`, `ab2`各`10 * 10^18`. 
2. 在侧链上部署`WareHouse.sol`, 地址为`wh`.  
3. 在侧链上部署`BP.sol`, 地址为`bp`(注意初始化量, 名字, 符合).  
4. 玩家A调用`ab1`, `ab2`的`approve`函数, 参数为`wh`, `10 * 10^18`(其实estmate没有要求这么多，第一个`1 * 10^18`, 第二个`2 * 10^18`).  
5. 玩家上传数据到IPFS, 并得到一个`BPhash`(链下).  
6. 官方(`owner`)调用`wh`上的`addABaddress`两次, 以此把`ab1`, `ab2`地址传进去. 最好调用`getABaddress`check一下.  
7. 官方(`owner`)调用`wh`上的`changeBPaddress`, 把`bp`传进去.   
8. 官方调用`BP`的`addAdmins`.   
9. 玩家A调用`wh`的`compose`, 传入`BPhash`, 正常执行. 至此`compose`流程走完. 玩家A将减少`1 * 10^18`的`ab1`以及`2 * 10^18`的`ab2`, 将得到一个BP.  

10. 玩家A调用`wh`的`deCompose`, 传入`8步骤`里面的`BPhash`, 即能销毁BP，得到AB  

### 基于Admin版本（没有Oracle）
侧链:  
1. 在侧链上部署两个合约`Leblock.sol`, 其名称为`ab1`, `ab2`(注意其他量的初始化). 玩家地址A下有`ab1`, `ab2`各`10 * 10^18`.  
2. 在侧链上部署`WareHouse.sol`, 地址为`wh`.  
3. 在侧链上部署`BP.sol`, 地址为`bp`(注意初始化量, 名字, 符合).  
4. 玩家A调用`ab1`, `ab2`的`approve`函数, 参数为`wh`, `10 * 10^18`(其实estmate没有要求这么多，第一个`1 * 10^18`, 第二个`2 * 10^18`).  
5. 玩家上传数据到IPFS, 并得到一个`BPhash`(链下).  
6. 官方(`owner`)调用`wh`上的`addABaddress`两次, 以此把`ab1`, `ab2`地址传进去. 最好调用`getABaddress`check一下.  
7. 官方(`owner`)调用`wh`上的`changeBPaddress`, 把`bp`传进去.  
8. 玩家A调用发起请求给PS,将`BPHash`传给PS(链下).
9. 官方(`owner`)去调用`wh`的`compose`, 传入`BPhash`, `玩家A地址`, `对应BP消耗的` 正常执行. 至此`compose`流程走完. 玩家A将减少`1 * 10^18`的`ab1`以及`2 * 10^18`的`ab2`, 将得到一个BP.  

9. 玩家A调用`wh`的`deCompose`, 传入`8步骤`里面的`BPhash`, 即能销毁BP，得到AB  


