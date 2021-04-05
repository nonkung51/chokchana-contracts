const { expect } = require('chai');

describe('ChokchanaLottery', function () {
    it('Should be able to draw rewards', async function () {
        // deploy buyingToken
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 3, 100);
        await lottery.deployed();

        await lottery.drawRewards();
        expect((await lottery.getReward(1, 0)).toNumber()).to.be.within(1000, 9999);
        expect((await lottery.getReward(1, 1)).toNumber()).to.be.within(1000, 9999);
        expect((await lottery.getReward(1, 2)).toNumber()).to.be.within(1000, 9999);
    });

    it('Should be able to bought ticket', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 3, 100);
        const lotteryDeploy = await lottery.deployed();

        // mint token for self
        await thbToken.mint(1000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 10000000);

        // try buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        await lottery.buyTicket(1234);

        // check expect for token bought
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(1);
    });
});