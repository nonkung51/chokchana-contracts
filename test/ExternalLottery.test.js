const { expect } = require('chai');

describe('ExternalLottery', function () {
    it('Should be able to bought ticket', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 100000, 999999);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ExternalLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 100);
        const lotteryDeploy = await lottery.deployed();

        // mint token for self
        await thbToken.mint(1000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 10000000);

        // try buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        await lottery.buyTicket(123456);

        // check expect for token bought
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(1);
    });
});