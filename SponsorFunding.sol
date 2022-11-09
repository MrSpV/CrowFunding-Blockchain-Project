contract SponsorFunding {

    mapping(address => uint) sponsors;
    uint initialBalance = 100;
    uint public totalFunding = 0;
    CrowdFunding crowdFundingContract;

    modifier FirstPhase(){
        require(totalFunding + crowdFundingContract.getActualFunding() < crowdFundingContract.getFundingGoal(), "Funding goal reached");
        _;   
    }

    function setCrowdFunding (address payable crowdFundingAdress) public {
        crowdFundingContract = CrowdFunding(crowdFundingAdress);
    }

    function addSponsor (address addr, uint percent) public payable FirstPhase{
        sponsors[addr] = percent;
        totalFunding += (msg.value * percent) / 100;
    }

    function getSponsor(address addr) external FirstPhase view returns(uint){
        return (initialBalance * sponsors[addr]) / 100;
    }

    function getMyBalance() external view returns(uint){
        return address(this).balance;
    }

    function sendFunds() public payable{
        if(totalFunding + crowdFundingContract.getActualFunding() >= crowdFundingContract.getFundingGoal()){
            payable(address(crowdFundingContract)).transfer(totalFunding);
            totalFunding = 0;
        }
        else{
            revert("Not enough funding yet");
        }
    }
}