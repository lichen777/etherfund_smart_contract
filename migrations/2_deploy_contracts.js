var EtherFund = artifacts.require("EtherFund");

module.exports = function(deployer) {
  deployer.deploy(EtherFund, 30, "AB", "0xb0e004f47e1f18666a406270ec872a0b625e7def", 10);
};
