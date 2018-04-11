pragma solidity ^0.4.17;

contract SmartFund {
    address public owner;
    address public benefactor;
    bool public isRefunded;
    bool public isCmpleted;
    uint public numPledges;
    struct Pledge {
        uint amount;
        address eth_address;
        bytes32 message;
    }
    mapping(uint => Pledge) public pledges;

    // constructor
    function smartFund(address _benefactor) public {
        owner = msg.sender;
        numPledges = 0;
        isRefunded = false;
        isCmpleted = false;
        benefactor = _benefactor;
    }

    // add a new pledge
    function back(bytes32 _message) public payable {
        if (msg.value == 0 || isCmpleted || isRefunded) revert();
        pledges[numPledges] = Pledge(msg.value, msg.sender, _message);
        numPledges++;
    }

    function getPot() public constant returns (uint) {
        address contractAddress = this;
        return contractAddress.balance;
    }

    // refund the backers
    function refund() public {
        if (msg.sender != owner || isCmpleted || isRefunded) revert();
        for (uint i = 0; i < numPledges; ++i) {
            pledges[i].eth_address.transfer(pledges[i].amount);
        }
        isRefunded = true;
        isCmpleted = true;
    }

    // send funds to the contract benefactor
    function drawdown() public {
        if (msg.sender != owner || isCmpleted || isRefunded) revert();
        address contractAddress = this;
        benefactor.transfer(contractAddress.balance);
        isCmpleted = true;
    }
}
