// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

async function main() {
	console.log('Start deploying process...');
	const [owner] = await ethers.getSigners();
	console.log('Deployer is', owner.address);

	const _thbToken = await ethers.getContractFactory('THBToken');
	const thbToken = await _thbToken.deploy();
	await thbToken.mint(100000);
	console.log('Deploy Token contract at: ', thbToken.address);

	const _ticket = await ethers.getContractFactory('ChokchanaTicket');
	const ticket = await _ticket.deploy(true, 1000, 9999);
	console.log('Deploy Ticket contract at: ', ticket.address);

	const _lottery = await ethers.getContractFactory('ExternalLottery');
	const lottery = await _lottery.deploy(
		ticket.address,
		thbToken.address,
		80,
		0,
		0
	);
	console.log('Deploy Lottery contract at: ', lottery.address);

	const _randomGenerator = await ethers.getContractFactory(
		'RandomGenerator'
	);
	const randomGenerator = await _randomGenerator.deploy(
		lottery.address,
		ticket.address,
		3
	);
	console.log('Deploy RandomGenerator contract at: ', randomGenerator.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
