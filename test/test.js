const EtherFund = artifacts.require('../contracts/EtherFund.sol')
const Web3 = require("web3");
const web3 = new Web3(Web3.givenProvider || "ws://localhost:8545");


contract("EtherFund", async (accounts) => {

  it("should show the correct target", async () => {
    let instance = await EtherFund.deployed();
    let target = await instance.target.call();
    assert.equal(target.valueOf().toString(), web3.utils.toWei('10', "ether"));
  });

  it("should contribute correctly", async () => {
    let instance = await EtherFund.deployed();
    //console.log(instance.contribute)
    instance.contribute({
      gas: 3000000,
      from: "0x508f9b2b87f45a44ec0096c78d490bd4deb7e774",
      value: web3.utils.toWei("0.1", "ether")
    });

    let totalRaised = await instance.totalRaised.call();
    assert.equal(totalRaised.valueOf().toString(), web3.utils.toWei("0.1", "ether"));
  });

});


async function logMyContract(EtherFund) {
  console.log("");
  console.log("MyContract:");
  console.log("--------------");
  console.log(`BALANCE: ${getBalanceInEth(EtherFund.address)}`);
  console.log(`creator=${await EtherFund.creator.call()}`);
  console.log(`beneficiary=${await EtherFund.beneficiary.call()}`);
  console.log(`target=${await EtherFund.target.call()}`);
  console.log(`currentBalance=${await EtherFund.currentBalance.call()}`);
  console.log(`isCreator()=${await EtherFund.isCreator.call()}`);
  console.log(`atEndOfLifecycle()=${await EtherFund.isCreator.call()}`);
  console.log("");
}