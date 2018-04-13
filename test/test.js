const EtherFund = artifacts.require('../contracts/EtherFund.sol')

contract("EtherFund", function(accounts) {
  const recipientAccount = accounts[9]
  const init = { poolTime: 100, currentTime: 0, recipient: recipientAccount }

  describe('isClosed()', () => {
    it('should return false when currentTime is less than startTime + poolTime', async () => {
      return await isClosedTest({
        init,
        finalTime: 50,
        expectedReturnVal: false
      })
    })

    it('should return true when currentTime is greater than startTime + poolTime', async () => {
      return await isClosedTest({
        init,
        finalTime: 150,
        expectedReturnVal: true
      })
    })

    it('should return true when currentTime is equal to startTime + poolTime', async () => {
      return await isClosedTest({
        init,
        finalTime: 100,
        expectedReturnVal: true
      })
    })
});


async function logMyContract(EtherFund) {
  console.log("");
  console.log("MyContract:");
  console.log("--------------");
  console.log(`BALANCE: ${getBalanceInEth(EtherFund.address)}`);
  console.log(`startTime=${await EtherFund.startTime.call()}`);
  console.log(`poolTime=${await EtherFund.poolTime.call()}`);
  console.log(`threshold=${await EtherFund.threshold.call()}`);
  console.log(`recipient=${await EtherFund.recipient.call()}`);
  console.log(`currentTime()=${await EtherFund.currentTime.call()}`);
  console.log(`isClosed()=${await EtherFund.isClosed.call()}`);
  console.log("");
}