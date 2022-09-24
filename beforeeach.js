const [owner, buyer,buyer1,buyer2,] = await ethers.getSigners();
const Token = await ethers.getContractFactory("Token");
const token = await Token.deploy();
const Crowdsale = await ethers.getContractFactory("Crowdsale");
const crowdsale = await Crowdsale.deploy();
await token.approveContract(crowdsale.address);
await crowdsale.setTokenAddress(token.address);
await crowdsale.setStart();
