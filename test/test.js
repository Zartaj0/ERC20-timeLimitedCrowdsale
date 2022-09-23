const { expect } = require("chai");
const { ethers } = require("hardhat");
let provider = ethers.getDefaultProvider();


describe("Token contract", function () {
    it("Deployment should assign the total supply of tokens to itself", async function () {
        const [owner,buyer,buyer1] = await ethers.getSigners();
        console.log(owner.address)

        const Token = await ethers.getContractFactory("Token");

        const token = await Token.deploy();

        const contractBalance = await token.balanceOf(token.address);
        expect(await token.totalSupply()).to.equal(contractBalance);
    });

    // it("buyer can buy the token", async function () {
    //     const [owner, buyer] = await ethers.getSigners();
    //     const Crowdsale = await ethers.getContractFactory("Crowdsale");
    //     const crowdsale = await Crowdsale.deploy();

    //     const Token = await ethers.getContractFactory("Token");
    //     const token = await Token.deploy();

    //     await crowdsale.setTokenAddress(token.address);
    //     await token.approveContract(crowdsale.address);
    //     await crowdsale.setStart();

    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") })
    //     expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000")
    // })

    // it("Prices should change accoording to time", async function () {
    //     const [owner, buyer,buyer1,buyer2,] = await ethers.getSigners();
    //     const Crowdsale = await ethers.getContractFactory("Crowdsale");
    //     const crowdsale = await Crowdsale.deploy();

    //     const Token = await ethers.getContractFactory("Token");
    //     const token = await Token.deploy();

    //     await crowdsale.setTokenAddress(token.address);
    //     await token.approveContract(crowdsale.address);
    //     await crowdsale.setStart();

    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000");

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer1).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer1.address)).to.equal("500000000000000000000");

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer2.address)).to.equal("200000000000000000000");

    //     await network.provider.send("evm_increaseTime", [240])
        
    //     await expect(crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1")})).to.eventually.be.rejected;

    // })

    // it("owner should be able to withdraw ether only after sale is over",async function(){
    //     const [owner, buyer,buyer1,buyer2,] = await  ethers.getSigners();

    //     const Crowdsale = await ethers.getContractFactory("Crowdsale");
    //     const crowdsale = await Crowdsale.deploy();

    //     const Token = await ethers.getContractFactory("Token");
    //     const token = await Token.deploy();

    //     await crowdsale.setTokenAddress(token.address);
    //     await token.approveContract(crowdsale.address);
    //     await crowdsale.setStart();

    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer1).buyToken({ value: ethers.utils.parseEther("1") });

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1") });


    //     await expect( crowdsale.transferFundsToOwner(owner.address)).to.eventually.be.rejected;


    //     await network.provider.send("evm_increaseTime", [240])

    //     await expect( crowdsale.transferFundsToOwner(owner.address)).to.eventually.be.fulfilled;
    //     await  crowdsale.transferFundsToOwner(owner.address);

    // })

    // it("owner should withdraw the tokens only when sale is closed", async function(){
    //     const [owner, buyer] = await ethers.getSigners();
    //     const Crowdsale = await ethers.getContractFactory("Crowdsale");
    //     const crowdsale = await Crowdsale.deploy();

    //     const Token = await ethers.getContractFactory("Token");
    //     const token = await Token.deploy();

    //     await crowdsale.setTokenAddress(token.address);
    //     await token.approveContract(crowdsale.address);
    //     await crowdsale.setStart();

    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000");

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer.address)).to.equal("1500000000000000000000");

    //     await network.provider.send("evm_increaseTime", [240]);
    //     await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
    //     expect(await token.balanceOf(buyer.address)).to.equal("1700000000000000000000");
    //     await expect(crowdsale.withdrawRemainingTokens(owner.address)).to.be.rejectedWith("The remaining tokens are only transferrable after the sale is over" );

    //     await network.provider.send("evm_increaseTime", [240])
    //     await expect( crowdsale.withdrawRemainingTokens(owner.address)).to.be.fulfilled;

    // })


});