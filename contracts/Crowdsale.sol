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
    address public Token;
    uint private rate;
    uint public start;
    uint public end;
    uint public endInvestor;
    uint public endPrivate ;
    uint public endPublic;
    uint private saleLimit;
    uint public investorSold;
    uint public privateSold;
    uint public publicSold;
    uint private remainingLimit;
    uint private userLimit = 10000 * 10 ** 18;

    mapping(address => uint) public limit;

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

    function tokensRemaining() public view returns (uint) {
        return IERC20(Token).balanceOf(address(this));
    }



    function remainingInvestor() private view returns(uint){
     return saleLimit - investorSold;
    }
    function remainingPrivate() private view returns(uint){
     return saleLimit - privateSold;
    }
    function remainingPublic() private view returns(uint){
     return saleLimit - publicSold;
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
         (bool sent, ) = to.call{value:address(this).balance}("");

        require(sent,"Transaction was not sucessful");
    }

    function withdrawRemainingTokens(address  to) public ownable  {
        require(presentTime()>end ,"The remaining tokens are only transferrable after the sale is over" );
       IERC20(Token).transfer(to, tokensRemaining());     
    }

    function sendToken (uint amount, address to) private  {
        uint tokensToSend = (amount*10**18)/rate;
        require(tokensToSend <= remainingLimit,"Sale limit reached wait for the next sale");

        IERC20(Token).transfer(to, tokensToSend);
       
           if (presentTime() <= endInvestor){
            investorSold += tokensToSend;
        }else if (presentTime() <= endPrivate){
            privateSold += tokensToSend;
        }else if (presentTime() <= endPublic){
            publicSold += tokensToSend;
        }         
    }

    function buyToken() public payable {

        if (start==0){
          revert("Sale Has not started yet");

        } else if  (presentTime() <= endInvestor) {
           rate = 1e15;
           saleLimit = 4000 * 10**18;
           remainingLimit = remainingInvestor();
           sendToken(msg.value, msg.sender);

        } else if (presentTime() <= endPrivate) {
           rate = 2e15;
           saleLimit = 3000 * 10**18;
           remainingLimit = remainingPrivate();
           sendToken(msg.value, msg.sender);

        } else if (presentTime() <= endPublic) {
            rate = 5e15;
           saleLimit = 3000 * 10**18;
           remainingLimit = remainingPublic();
           sendToken(msg.value, msg.sender);

        } else {
          revert ("Sale is closed");
        }     
    }

    receive()external payable{
        buyToken();
    }
   
}

