pragma solidity ^0.4.17;

contract EtherFund {

    address public creator;
    address public beneficiary; // creator may be different than recipient
    uint public target; // required to reach at least this much, else everyone gets refund
    string public campaignId;

    // Data structures
    enum State {
        Fundraising,
        ExpiredRefund,
        Successful,
        Closed
    }

    struct Contribution {
        uint amount;
        address contributor;
    }

    // State variables
    State public state = State.Fundraising; // initialize on create
    uint public totalRaised;
    uint public currentBalance;
    uint public raiseBy;
    uint public completeAt;
    Contribution[] public contributions;

    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);
    event LogFunderInitialized(
        address creator,
        address beneficiary,
        string _campaignId,
        uint _target,
        uint256 raiseby
    );

    modifier inState(State _state) {
        require (state == _state);
        _;
    }

    modifier isCreator() {
        require (msg.sender == creator);
        _;
    }

    // Wait 1 hour after final contract state before allowing contract destruction
    modifier atEndOfLifecycle() {
        require((state == State.ExpiredRefund || state == State.Successful) && completeAt + 1 hours < now);
        _;
    }

    function EtherFund(
        uint timeInDaysForFundraising,
        string _campaignId,
        address _beneficiary,
        uint _target) public
    {
        creator = msg.sender;
        beneficiary = _beneficiary;
        campaignId = _campaignId;
        target = _target * 1000000000000000000; //convert to wei
        raiseBy = now + (timeInDaysForFundraising * 24 hours);
        currentBalance = 0;
        emit LogFunderInitialized(
            creator,
            beneficiary,
            campaignId,
            target,
            raiseBy);
    }

    function contribute()
    public
    inState(State.Fundraising) payable returns (uint256)
    {
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
                }) // use array, so can iterate
            );
        totalRaised += msg.value;
        currentBalance = totalRaised;
        emit LogFundingReceived(msg.sender, msg.value, totalRaised);

        checkIfFundingCompleteOrExpired();
        return contributions.length - 1; // return id
    }

    function checkIfFundingCompleteOrExpired() public {
        if (totalRaised > target) {
            state = State.Successful;
            payOut();

            // could incentivize sender who initiated state change here
        } else if ( now > raiseBy ) {
            state = State.ExpiredRefund; // backers can now collect refunds by calling getRefund(id)
        }
        completeAt = now;
    }

    function payOut()
    public
    inState(State.Successful)
    {
        if(!beneficiary.send(address(this).balance)) {
            revert();
        }
        state = State.Closed;
        currentBalance = 0;
        emit LogWinnerPaid(beneficiary);
    }

    function getRefund(uint256 id)
    public
    inState(State.ExpiredRefund)
    returns (bool)
    {
        if (contributions.length <= id || id < 0 || contributions[id].amount == 0 ) {
            revert();
        }

        uint amountToRefund = contributions[id].amount;
        contributions[id].amount = 0;

        if(!contributions[id].contributor.send(amountToRefund)) {
            contributions[id].amount = amountToRefund;
            return false;
        }
        else{
            totalRaised -= amountToRefund;
            currentBalance = totalRaised;
        }

        return true;
    }

    function removeContract()
    public
    isCreator()
    atEndOfLifecycle()
    {
        selfdestruct(msg.sender);
        // creator gets all money that hasn't be claimed
    }

    function () public { revert(); }
}
