pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SmartFund.sol";

contract Test {
    SmartFund smartFund = SmartFund(DeployedAddresses.SmartFund());

    // Testing the adopt() function
    function testUserCanAdoptPet() public {
        bool returnedId = smartFund.pledge(8);

        bool expected = true;

        Assert.equal(returnedId, expected, "Adoption of pet ID 8 should be recorded.");
    }
}

