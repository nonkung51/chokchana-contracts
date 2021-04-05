const { expect } = require('chai');

describe('ChokchanaLottery', function () {
    it('Should be able to draw rewards', async function () {
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);
		const ticketDeploy = await ticket.deployed();

        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, 3);
        await lottery.deployed();

        await lottery.drawRewards();
        expect((await lottery.getReward(1, 0)).toNumber()).to.be.within(1000, 9999);;
        expect((await lottery.getReward(1, 1)).toNumber()).to.be.within(1000, 9999);;
        expect((await lottery.getReward(1, 2)).toNumber()).to.be.within(1000, 9999);;
    });
});