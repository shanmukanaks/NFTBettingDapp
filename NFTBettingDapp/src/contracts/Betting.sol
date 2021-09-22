pragma solidity ^0.5.17;

contract MyContract {
    
    mapping(address => uint) public balances;
    mapping(address => uint) public bets;
    uint public numPpl = 0;
    uint public totPool = 0;
    uint public posPool = 0;
    uint public negPool = 0;
    
    address payable[] public recipients;
    
    function invest(uint bet) external payable {
        
        if (msg.value < 1 ether) {
            revert("Bet can not be less than 1 eth");
        }
        
        if (bet != 1 && bet != 0) {
            revert("Can only bet pos(1) or neg(0)");
        }
        
        balances[msg.sender] += msg.value;
        recipients.push(msg.sender);
        numPpl++;
        
        bets[msg.sender] += bet;
        totPool += msg.value;
        
        if(bet == 1) {
            posPool += msg.value;
        }
        else {
            negPool += msg.value;
        }
        
    }
    
    function balanceOf() external view returns(uint) {
        
        return address(this).balance;
        
    }
    
    function sendEther(uint result) external {
        
        if (result != 1 && result != 0) {
            revert("Result can only be up(1) or down(0)");
        }
        
        if(address(this).balance < 1000000000000000000) {
            revert("No eth in contract");
        }
        
        for(uint i = 0; i < recipients.length; i++) {
            
            if(bets[recipients[i]] == result) {
                
                if (result == 1) {
                    recipients[i].transfer((balances[recipients[i]] / posPool) * totPool);
                }   
                else {
                    recipients[i].transfer((balances[recipients[i]] / negPool) * totPool);
                } 
                
                
            }
            
        }

    }
    
    function cancelBet() external {
        
        msg.sender.transfer(balances[msg.sender]);
        
        totPool -= balances[msg.sender];

        if (bets[msg.sender] == 1) {
            posPool -= balances[msg.sender];
        }   
        else {
            negPool -= balances[msg.sender];
        } 
        
        delete balances[msg.sender];
        
        delete bets[msg.sender];
        
        numPpl--;

    }
    
}