const { expect } = require('chai');

describe('random', function () {
	it('Should return 0 when deployed', async function () {
		const random = await ethers.getContractFactory('Random');
		const randomer = await random.deploy();

		await randomer.deployed();
		expect(await randomer.getRandomNum()).to.equal(0);
	});

	it('Should return random number when call runRandom (3 digits)', async function () {
		const random = await ethers.getContractFactory('Random');
		const randomer = await random.deploy();

		await randomer.deployed();

		await randomer.runRandom(100, 999, 1);
		expect(await randomer.getRandomNum()).to.be.within(100, 999);
	});

	it('Should return random number when call runRandom (4 digits)', async function () {
		const random = await ethers.getContractFactory('Random');
		const randomer = await random.deploy();

		await randomer.deployed();

		await randomer.runRandom(1000, 9999, 1);
		expect(await randomer.getRandomNum()).to.be.within(1000, 9999);
	});

	it('Should return random number when call runRandom (6 digits)', async function () {
		const random = await ethers.getContractFactory('Random');
		const randomer = await random.deploy();

		await randomer.deployed();

		await randomer.runRandom(100000, 999999, 1);
		expect(await randomer.getRandomNum()).to.be.within(100000, 999999);
	});

	it('Should return random number when call runRandom (8 digits)', async function () {
		const random = await ethers.getContractFactory('Random');
		const randomer = await random.deploy();

		await randomer.deployed();

		await randomer.runRandom(10000000, 99999999, 1);
		expect(await randomer.getRandomNum()).to.be.within(
			10000000,
			99999999
		);
	});
});
