const { expect } = require('chai');

describe('ChokchanaTicket', function () {
    it('Should be able to minting multiple number of Ticket (if multiple selected)', async function () {
		const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true);

		await ticket.deployed();
		await ticket.mint();
	});
});
