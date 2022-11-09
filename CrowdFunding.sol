// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.7;


contract CrowdFunding {

    event fallbackCall(string);
    event receivedFunds(address, uint);
    uint fundingGoal = 1000;
    uint actualFunding = 0;
    uint sponsorFlag = 0;
    bool fundsWereRecieved = false;
    mapping(address => uint) contribuitors;
    SponsorFunding sponsorFundingContract = new SponsorFunding();
    DistributeFunding distributeFundingContract;

    modifier FirstPhase(){
        require(actualFunding + sponsorFundingContract.totalFunding() < fundingGoal, "Funding goal reached");
        _;   
    }
   

    modifier SecondPhase(){
        require(actualFunding + sponsorFundingContract.totalFunding() >= fundingGoal, "Funding goal not reached");
        _;   
    }

   

    function raiseSponsors(address payable sponsorFundingAdress) public {
        require(sponsorFlag == 0, "Raising sponsors already started");
        sponsorFlag = 1;
        sponsorFundingContract = SponsorFunding(sponsorFundingAdress);
        sponsorFundingContract.setCrowdFunding(payable(address(this)));
    }

   
    function notifySponsors() public SecondPhase payable{
        fundsWereRecieved = true;
        sponsorFundingContract.setCrowdFunding(payable(address(this)));
        sponsorFundingContract.sendFunds();

    }


    function sendFunds(address payable distributeFundingAdress) public SecondPhase{
        require(fundsWereRecieved == true, "Sponsor funds not recieved yet or not enough funds");
        distributeFundingContract = DistributeFunding(distributeFundingAdress);
        payable(address(distributeFundingContract)).transfer(fundingGoal);
        actualFunding = 0;
    }

   

    function addContributor(address addr) external payable FirstPhase{
        contribuitors[addr] += msg.value;
        actualFunding += msg.value;

    }

   

    function getContribution(address addr) external view  FirstPhase returns(uint) {
        return contribuitors[addr];

    }

   

    function refundContribution(address addr, uint amount) external payable FirstPhase{
        require(actualFunding < fundingGoal, "Funding goal reached");
        if(getMyBalance() == 0){
            revert("Not enough funds");

        }

        if(amount > contribuitors[addr]){
            payable(addr).transfer(contribuitors[addr]);
            contribuitors[addr] = 0;
            actualFunding -= contribuitors[addr];

        }
        else{
            payable(addr).transfer(amount);
            contribuitors[addr] -= amount;
            actualFunding -= amount;
        }
    }

   
    function getMyBalance() public view returns(uint){
        return address(this).balance;
    }

   

    function getFundingGoal() external view returns(uint){
        return fundingGoal;
    }


    function getActualFunding() external view returns(uint) {
        return actualFunding;
    }

    function isTheGoalAchieved() external view returns(bool){
        if(fundingGoal >= actualFunding){
            return true;
        }
        else{
            return false;
        }
    }

    receive () payable external {
      emit receivedFunds(msg.sender, msg.value);
    }

    fallback () external {
        emit fallbackCall("Falback Called!");
    }s

}