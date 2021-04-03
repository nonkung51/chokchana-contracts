const { expect } = require('chai');

describe('thbToken', function () {
	it('Should mint initialSupply = 0 when deployed', async function () {
		const [owner] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();

		await thbToken.deployed();
		expect(await thbToken.balanceOf(owner.address)).to.equal(
			await thbToken.totalSupply()
		);
	});

	it('Should be able to mint supply if minter', async function () {
		const [owner] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();

		await thbToken.deployed();
		await thbToken.mint(1000);
		expect(await thbToken.balanceOf(owner.address)).to.equal(
			await thbToken.totalSupply()
		);
	});

	it('Should not be able to mint supply if not minter', async function () {
		const [owner, addr1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();

		await thbToken.deployed();

		await expect(
			await thbToken.connect(addr1).mint(1000)
		).to.be.revertedWith("Minting new token require minter");
	});

	it('Should transfer thbToken between accounts', async function () {
		const [owner, addr1, addr2] = await ethers.getSigners();

		const _token = await ethers.getContractFactory('THBToken');

		const thbToken = await _token.deploy();

		await thbToken.mint(100);
		await thbToken.transfer(addr1.address, 50);
		expect(await thbToken.balanceOf(addr1.address)).to.equal(50);

		await thbToken.connect(addr1).transfer(addr2.address, 50);
		expect(await thbToken.balanceOf(addr2.address)).to.equal(50);
	});
});
