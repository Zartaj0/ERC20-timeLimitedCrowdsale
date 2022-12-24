const main = async () => {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with account: ", deployer.address);

  // Deploying the token contract
  const tokenFactory = await hre.ethers.getContractFactory("Token");
  const token = await tokenFactory.deploy();
  await token.deployed();

  // deploying the crowdsale contract
  const crowdSaleFactory = await hre.ethers.getContractFactory("Crowdsale");
  const crowdsale = await crowdSaleFactory.deploy();
  await crowdsale.deployed();

/**
 * Transferring all the tokens to the crowdsale contract so that people can buy from there
 * Setting the token address in the crowdsale contract,so that we can call the interface on it.
 * Starting the timer on crowdsale contract.
 *  */ 
  await token.transfer(crowdsale.address, token.totalSupply());
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