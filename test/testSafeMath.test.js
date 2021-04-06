const { expect } = require('chai');

describe('random', function () {
	it('Should have sum of reward equal to total allocated reward', async function () {
		const _testSafeMath = await ethers.getContractFactory('testSafeMath');
        // deploy with some arbitary number
		const testSafeMath = await _testSafeMath.deploy(999);

		await testSafeMath.deployed();
        const rewards = await testSafeMath.testSplitReward();
        // let sumOfRewards = 
        // console.log(rewards);
		// expect(await randomer.getRandomNum()).to.equal(0);
	});
});
