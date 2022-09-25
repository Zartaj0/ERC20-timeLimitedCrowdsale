const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
  
    console.log("Deploying contracts with account: ", deployer.address);
  
    const tokenFactory = await hre.ethers.getContractFactory("Token");
    const token = await tokenFactory.deploy();
    await token.deployed();

    const crowdSaleFactory = await hre.ethers.getContractFactory("Crowdsale");
    const crowdsale = await crowdSaleFactory.deploy();
    await crowdsale.deployed();
     
    await token.transfer(crowdsale.address,token.totalSupply());
    await crowdsale.setTokenAddress(token.address);
    await crowdsale.setStart();

  
    console.log("Token Address ", token.address);
    console.log("crowdsale Address ", crowdsale.address);
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };

  
  runMain();