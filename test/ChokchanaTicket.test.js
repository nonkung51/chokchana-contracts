const { expect } = require('chai');

describe('ChokchanaTicket', async function () {
	const [owner] = await ethers.getSigners();

	it('Should be able to minting multiple number of Ticket (if multiple selected)', async function () {
		const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);

		await ticket.deployed();
		await ticket.mint(2312, owner.address);
		await ticket.mint(2312, owner.address);
		expect(await ticket.getNumberOf(1, 2312)).to.equal(await ticket.totalSupply());
	});

	/*
	it('Should not be able to minting multiple number of Ticket (if multiple unselected)', async function () {
		const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(false, 1000, 9999);

		await ticket.deployed();
		await ticket.mint(2312);
		await ticket.mint(2312);
		expect(await ticket.getNumberOf(2312)).to.equal(await ticket.totalSupply());
	});
	*/

	it('Should be able to minting Ticket with desire data.', async function () {
		const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);

		const ticketNo = 2312;

		await ticket.deployed();
		await ticket.mint(ticketNo, owner.address);
		expect(await ticket.getNumberOf(1, ticketNo)).to.equal(await ticket.totalSupply());
		const ticketData = await ticket.get(0);
		expect(ticketData[0].toNumber()).to.equal(ticketNo);
		expect(ticketData[2].toNumber()).to.equal(1);
	});

	it('Should be able to increase round of ticket.', async function () {
		const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 1000, 9999);

		const ticketNo = 2312;

		await ticket.deployed();
		await ticket.mint(ticketNo, owner.address);
		let ticketData = await ticket.get(0);
		expect(ticketData[2].toNumber()).to.equal(1);
		await ticket.nextRound();
		await ticket.mint(ticketNo, owner.address);
		ticketData = await ticket.get(1);
		expect(ticketData[2].toNumber()).to.equal(2);
	});
});
