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

contract Token is IERC20  {
    
    address public  owner;
    string public name;
    string public symbol;
    uint8 public decimals; 
    uint public maximumSupply;
                                 
    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private  allowed;
    mapping(address => bool) public blacklist;

    constructor()  {
        name = "Test";
        symbol = "TST";
        decimals = 18;
        maximumSupply = 10000000 * 10**18;
        owner= msg.sender;
            
        balances[address(this)] = maximumSupply;
        emit Transfer(address(0), address(this), maximumSupply);
    }

    //Modifiers
    
    modifier ownable()  {
        require (msg.sender== owner,"Only owner can perform this action");
        _;
    } 

    modifier checkBlacklist(address _who){
        require(!blacklist[_who], "This adreess is blacklisted ");
        _;
    }

    modifier checkBalance (address from,uint tokens ){
        require(balances[from] >= tokens , "Not enough balance");
        _;
    }

    //Read Only Functions
   
    //Total Supply
    
    function totalSupply() external  override view returns (uint) {
        return maximumSupply ;
    }
     

    //Token balance of any address 

    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }

    //Check Allowance

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    //Write Functions

    //Blacklisiting function

    function blackListing(address _who ) external  ownable {
        blacklist[_who] = true;

    }

    //Whitelisiting function

    function whitelisting(address _who) external  ownable {
        blacklist[_who] = false;
    }
    
   //approve Function

    function approve(address spender, uint tokens) public checkBlacklist(msg.sender) override returns (bool success)  {
        allowed[msg.sender][spender] = tokens ;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    
    function approveContract(address spender) public ownable   returns (bool success)  {
        allowed[address(this)][spender] = maximumSupply;
        emit Approval(msg.sender, spender, maximumSupply);
        return true;
    }

    //transfer Function

    function transfer(address to, uint tokens) public checkBlacklist(msg.sender) checkBalance(msg.sender,tokens) checkBlacklist(to)  override returns (bool success) {
        balances[msg.sender] = (balances[msg.sender] -= tokens);
        balances[to] = (balances[to] += tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    //transferFrom Function

    function transferFrom(address from, address to, uint tokens) public checkBlacklist(msg.sender)checkBalance(from,tokens) checkBlacklist(to) override returns (bool success) {
        require(allowed[from][msg.sender] >=tokens , "You are not approved to send tokens");
        balances[from] = (balances[from] -= tokens);
        allowed[from][msg.sender] = (allowed[from][msg.sender] -= tokens );
        balances[to] = (balances[to]+= tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // Burn Function

    function burn(uint amount) public {
        transfer(address(0),amount);
    }

}