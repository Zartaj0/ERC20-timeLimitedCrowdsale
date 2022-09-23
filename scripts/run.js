const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
  
    console.log("Deploying contracts with account: ", deployer.address);
  
    const tokenFactory = await hre.ethers.getContractFactory("Token");
    const Token = await tokenFactory.deploy();
    await Token.deployed();

    const crowdSalealeFactory = await hre.ethers.getContractFactory("Crowdsale");
    const CrowdSale = await crowdSalealeFactory.deploy();
    await CrowdSale.deployed();

    await CrowdSale.setTokenAddress(Token.address);
    await Token.approveContract(CrowdSale.address);

  
    console.log("Token Address ", Token.address);
    console.log("crowdsale Address ", CrowdSale.address);
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