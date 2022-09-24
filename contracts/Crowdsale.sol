// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
interface  IERC20 {
    function allowance(address tokenOwner, address spender) external  view returns (uint remaining);
    function balanceOf(address tokenOwner) external  view returns (uint balance);
    function totalSupply() external view  returns  (uint);
    function transferFrom(address from, address to, uint tokens) external  returns (bool success);
    function transfer(address to, uint tokens) external  returns (bool success);
    function approve(address spender, uint tokens) external  returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Crowdsale {
    address public owner;
    uint public rate;
    uint public start;
    uint public end;
    uint public endInvestor;
    uint public endPrivate ;
    uint public endPublic;
    address public Token;

    constructor() {
      owner =msg.sender;
    }
    
    modifier ownable () {
        require (msg.sender == owner, "You are not the owner");
        _;
    }

    function setTokenAddress(address _addr) external ownable{
     Token = _addr;
    }

     function presentTime() public view returns(uint){
        return block.timestamp;
    }

    function remainingTokens() public view returns (uint) {
        return IERC20(Token).allowance(Token, address(this));
    }

    function setStart() external ownable {
         start = block.timestamp;
         end = start + 12 minutes;
         endInvestor = start + 4 minutes;
         endPrivate = endInvestor + 4 minutes;
         endPublic = endPrivate +  4 minutes;
    }
   
    function transferFundsToOwner(address payable to) public ownable {
        require(presentTime()>end ,"The ethers are only tranferrable after the sale is over" );
        to.transfer(address(this).balance);
    }

    function withdrawRemainingTokens(address  to) public ownable  {
        require(presentTime()>end ,"The remaining tokens are only transferrable after the sale is over" );
       IERC20(Token).transferFrom(Token, to, remainingTokens());     
    }

    function sendToken (uint amount, address to) private {
        uint tokensToSend = (amount*10**18)/rate;
       IERC20(Token).transferFrom(Token, to, tokensToSend);
       
    }

    function buyToken() public payable {

        if (start==0){
          revert("Sale Has not started yet");

        } else if  (presentTime() <= endInvestor) {
           rate = 1e15;
           sendToken(msg.value, msg.sender);

        } else if (presentTime() <= endPrivate) {
           rate = 2e15;  
           sendToken(msg.value, msg.sender);

        } else if (presentTime() <= endPublic) {
            rate = 5e15;
           sendToken(msg.value, msg.sender);

       } else {
          revert ("Sale is closed");
        }     
    }

    receive()external payable{
        buyToken();
    }
   
}