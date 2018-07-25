var happyBlock = artifacts.require("./happyBlock.sol");
var leblock = artifacts.require("./leblock.sol");
var recharge = artifacts.require("./recharge.sol");

module.exports = function(deployer) {
    deployer.deploy(happyBlock);
    deployer.deploy(leblock);
    deployer.deploy(recharge);
};
