const { expect } = require("chai");
const { ethers } = require("hardhat");
let provider = ethers.getDefaultProvider();

describe("Token contract", function () {
   
    it("Deployment should assign the total supply of tokens to owner", async function () {
        [owner] = await ethers.getSigners();
        let Token = await ethers.getContractFactory("Token");
        let token = await Token.deploy();
        const ownerBalance = await token.balanceOf(owner.address);
        expect(await token.totalSupply()).to.equal(ownerBalance);
    });

})    


describe("Token contract", function () {
    let owner ;
    let buyer ;
    let buyer1 ;
    let buyer2 ;
    let Token ;
    let token ;
    let Crowdsale ;
    let crowdsale ;
    let supply;

    beforeEach(async function () {
         [owner, buyer,buyer1,buyer2,] = await ethers.getSigners();
         Token = await ethers.getContractFactory("Token");
         token = await Token.deploy();
         Crowdsale = await ethers.getContractFactory("Crowdsale");
         crowdsale = await Crowdsale.deploy();
         supply =token.totalSupply();
         await token.transfer(crowdsale.address,supply);


         crowdsale.setTokenAddress(token.address);
         crowdsale.setStart();
    })

    it("buyer can buy the token", async function () {
       
        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") })
        expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000")
    })

    it("Prices should change accoording to time", async function () {

        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000");

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer1).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer1.address)).to.equal("500000000000000000000");

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer2.address)).to.equal("200000000000000000000");

        await network.provider.send("evm_increaseTime", [240])
        
        await expect(crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1")})).to.eventually.be.rejected;

    })

    it("owner should be able to withdraw ether only after sale is over",async function(){

        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer1).buyToken({ value: ethers.utils.parseEther("1") });

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer2).buyToken({ value: ethers.utils.parseEther("1") });


        await expect( crowdsale.transferFundsToOwner(owner.address)).to.eventually.be.rejected;


        await network.provider.send("evm_increaseTime", [240])

        await expect( crowdsale.transferFundsToOwner(owner.address)).to.eventually.be.fulfilled;
        await  crowdsale.transferFundsToOwner(owner.address);

    })

    it("owner should withdraw the tokens only when sale is closed", async function(){

        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer.address)).to.equal("1000000000000000000000");

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer.address)).to.equal("1500000000000000000000");

        await network.provider.send("evm_increaseTime", [240]);
        await crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") });
        expect(await token.balanceOf(buyer.address)).to.equal("1700000000000000000000");
        await expect(crowdsale.withdrawRemainingTokens(owner.address)).to.be.rejectedWith("The remaining tokens are only transferrable after the sale is over" );

        await network.provider.send("evm_increaseTime", [240])
        await expect( crowdsale.withdrawRemainingTokens(owner.address)).to.be.fulfilled;

    })

    it("saleLimit shouldn't be exceeded", async function () {
        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("4") })).to.be.fulfilled;
        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") })).to.be.reverted;

        await network.provider.send("evm_increaseTime", [240]);

        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("6") })).to.be.fulfilled;
        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") })).to.be.reverted;

        await network.provider.send("evm_increaseTime", [240]);

        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("15") })).to.be.fulfilled;
        await expect(crowdsale.connect(buyer).buyToken({ value: ethers.utils.parseEther("1") })).to.be.reverted;

        
        

    })


});