// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    function allowance(
        address tokenOwner,
        address spender
    ) external view returns (uint remaining);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function totalSupply() external view returns (uint);

    function transferFrom(
        address from,
        address to,
        uint tokens
    ) external returns (bool success);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(
        address spender,
        uint tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );
}

///@dev We will send the tokens from the ERC20 token contract to this crowdsale contract..

contract Crowdsale {
    address public owner;
    address public Token;
    uint private rate;
    uint public start;
    uint public end;
    uint public endInvestor;
    uint public endPrivate;
    uint public endPublic;
    uint private saleLimit;
    uint public investorSold;
    uint public privateSold;
    uint public publicSold;
    uint private remainingLimit;
    uint private userLimit = 10000 * 10 ** 18;

    /** @dev this mapping keeps a track of all address about
     * the amount of tokens they bought so that we can limit them to a certain threshold
    */
    mapping(address => uint) public limit;

    constructor() {
        owner = msg.sender;
    }
     
    //modifier to check the owner
    modifier ownable() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    /// @dev assigns the ERC20 token address to the Token variable
    function setTokenAddress(address _addr) external ownable {
        Token = _addr;
    }

    //  returns  the present time
    function presentTime() public view returns (uint) {
        return block.timestamp;
    }

    // returns the remaining balance in the crowdsale contract 
    function tokensRemaining() public view returns (uint) {
        return IERC20(Token).balanceOf(address(this));
    }

    /**@dev these functions give the remaining limits for the different sales by substracting the sold tokens
     * form the given limit according to the time.
    */
    function remainingInvestor() private view returns (uint) {
        return saleLimit - investorSold;
    }

    function remainingPrivate() private view returns (uint) {
        return saleLimit - privateSold;
    }

    function remainingPublic() private view returns (uint) {
        return saleLimit - publicSold;
    }
     
    //Sets the time boundation for sale 
    function setStart() external ownable {
        start = block.timestamp;
        end = start + 12 minutes;
        endInvestor = start + 4 minutes;
        endPrivate = endInvestor + 4 minutes;
        endPublic = endPrivate + 4 minutes;
    }
    
    /**Can only be called by owner and only after the sale has ended
     * Owner can transfer the amount to any other address
    */   
    
    function transferFundsToOwner(address payable to) public ownable {
        require(
            presentTime() > end,
            "The ethers are only tranferrable after the sale is over"
        );
        (bool sent, ) = to.call{value: address(this).balance}("");

        require(sent, "Transaction was not sucessful");
    }

    //This function allows the owner to withdraw the remaining tokens that can't be sold
    
    function withdrawRemainingTokens(address to) public ownable {
        require(
            presentTime() > end,
            "The remaining tokens are only transferrable after the sale is over"
        );
        IERC20(Token).transfer(to, tokensRemaining());
    }

    /**@dev firstly we are calculating the tokens to be sold on the given amount
     * the require statements check the limits.
     * Then we are sending the tokens to buyer by calling the transfer function using interface of ERC20 token contrat.
     * After that limit mapping gets the value for that particular address.
     * Now according to time the value of respective variables for different sales gets increased.
     */
    function sendToken(uint tokensToSend, address to) private {
        require(
            tokensToSend <= remainingLimit,
            "Sale limit reached wait for the next sale"
        );
        require(
            userLimit - limit[to] >= tokensToSend,
            "Max. userLimit reached"
        );

        IERC20(Token).transfer(to, tokensToSend);
        limit[to] += tokensToSend;
    }


    /**This is the main logic of this contract
     * @dev Requiring the sale to start
     * If statements checks the ongoing sale according to the present time
     * Setting the rate, then calculating the tokens respective to the amount you enter.
     * Setting the salelimits for particular sales
     * Calculating the remaining tokens to be sold in a particular sale
     * Finally calling the senToken() function
     * Lastly recording the tokens in a wallet to limit them
    */
    function buyToken() public payable {
        require(start != 0, "Sale Has not started yet");

        if (presentTime() <= endInvestor) {
            rate = 1e15;
            uint tokensToSend = (msg.value * 10 ** 18) / rate;
            saleLimit = 10000 * 10 ** 18;
            remainingLimit = remainingInvestor();
            sendToken(tokensToSend, msg.sender);
            investorSold += tokensToSend;
        } else if (presentTime() <= endPrivate) {
            rate = 2e15;
            uint tokensToSend = (msg.value * 10 ** 18) / rate;
            saleLimit = 11000 * 10 ** 18;
            remainingLimit = remainingPrivate();
            sendToken(tokensToSend, msg.sender);
            privateSold += tokensToSend;
        } else if (presentTime() <= endPublic) {
            rate = 5e15;
            uint tokensToSend = (msg.value * 10 ** 18) / rate;
            saleLimit = 12000 * 10 ** 18;
            remainingLimit = remainingPublic();
            sendToken(tokensToSend, msg.sender);
            publicSold += tokensToSend;
        } else {
            revert("Sale is closed");
        }
    }

    receive() external payable {
        buyToken();
    }
}
