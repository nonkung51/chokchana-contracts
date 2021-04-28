// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat');

async function main() {
	// We get the contract to deploy
	const THBTokenContract = await hre.ethers.getContractFactory('THBToken');
	const THBToken = await THBTokenContract.deploy();

	await THBToken.deployed();

	console.log('THBToken deployed to:', THBToken.address);

	const TicketContract = await hre.ethers.getContractFactory('ChokchanaTicket');
	const Ticket = await TicketContract.deploy();

	await Ticket.deployed(true, 0, 99);

	console.log('Ticket deployed to:', Ticket.address);

	const LotteryContract = await hre.ethers.getContractFactory('ChokchanaLottery');
	const Lottery = await LotteryContract.deploy();

	await Lottery.deployed(true, 0, 99);

	console.log('Lottery deployed to:', Lottery.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

/*
const _thbToken = await ethers.getContractFactory('THBToken')
const thbToken = await _thbToken.deploy()
await thbToken.mint(100000)

const _ticket = await ethers.getContractFactory('ChokchanaTicket')
const ticket = await _ticket.deploy(true, 1000, 9999)
const [owner, acc1] = await ethers.getSigners();

await ticket.mint(1234, owner.address);
await ticket.getNumberOf(1, 1234)
await ticket.getNumberOf(1, 1235)

const _lottery = await ethers.getContractFactory('ExternalLottery');
const lottery = await _lottery.deploy(ticket.address, thbToken.address, 80, 0, 0)
await thbToken.approve(lottery.address, 10000000);

await lottery.setBuyingPeriod(true)
await lottery.buyTicket(1234);
*/