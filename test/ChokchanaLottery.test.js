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

    it('Should be able to distribute reward', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 10, 99);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 80);
        await lottery.setReward(1, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try (every) buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 10; i< 30; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        const firstWinner = (await lottery.getReward(1, 0)).toNumber();
        console.log(`first winner: ${firstWinner}`, await (lottery.getClaimInfo(1, firstWinner)));
        
        console.log('total reward:', await (lottery.getTotalReward()));
    });

    it('Should be able to claim reward', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 10, 99);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 80);
        await lottery.setReward(1, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try (every) buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 10; i < 99; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        const firstWinner = (await lottery.getReward(1, 0)).toNumber();
        let firstWinnerId = 0;

        for (let i = 0; i < 99; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() === firstWinner) {
                firstWinnerId = i;
            }
        }

        console.log('first winner', firstWinner);

        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        
        await lottery.claimReward(firstWinnerId);

        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
    });

    it('Should be able to distribute reward (Multiple)', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 10, 99);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 80);
        await lottery.setReward(1, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try (every) buying ticket (twice)
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 10; i< 100; i++) {
            await lottery.buyTicket(i);
        }

        for (let i = 10; i< 100; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        const firstWinner = (await lottery.getReward(1, 0)).toNumber();
        console.log(`first winner: ${firstWinner}`, (await (lottery.getClaimInfo(1, firstWinner))).toNumber());
        
        console.log('total reward:', await (lottery.getTotalReward()));
    });

    it('Should be able to claim reward (Multiple)', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 10, 99);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 80);
        await lottery.setReward(1, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try (every) buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 10; i < 99; i++) {
            await lottery.buyTicket(i);
        }
        for (let i = 10; i < 99; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        const firstWinner = (await lottery.getReward(1, 0)).toNumber();
        let firstWinnerId = 0;

        for (let i = 0; i < 200; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() === firstWinner) {
                firstWinnerId = i;
                break;
            }
        }
        console.log('first\'s claim id: ', firstWinnerId);
        console.log('first winner', firstWinner);

        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        
        await lottery.claimReward(firstWinnerId);

        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
    
        for (let i = firstWinnerId + 1; i < 200; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() === firstWinner) {
                firstWinnerId = i;
                break;
            }
        }
        console.log('second\'s claim id: ', firstWinnerId);
        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        await lottery.claimReward(firstWinnerId);
        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
    });

    it('Should be able to claim reward multiple round', async function () {
        // deploy buyingToken
        const [owner, acc1] = await ethers.getSigners();
		const _token = await ethers.getContractFactory('THBToken');
		const thbToken = await _token.deploy();
		const tokenDeploy = await thbToken.deployed();

        // deploy Ticket smart contract
        const _ticket = await ethers.getContractFactory('ChokchanaTicket');
		const ticket = await _ticket.deploy(true, 10, 99);
		const ticketDeploy = await ticket.deployed();

        // deploy Lottery smart contract
        const _lottery = await ethers.getContractFactory('ChokchanaLottery');
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 80);
        await lottery.setReward(1, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try (every) buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 10; i < 99; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        let firstWinner = (await lottery.getReward(1, 0)).toNumber();
        let firstWinnerId = 0;

        for (let i = 0; i < 99; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() === firstWinner) {
                firstWinnerId = i;
            }
        }

        console.log('first winner', firstWinner);
        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        
        await lottery.claimReward(firstWinnerId);
        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());

        // New round!
        // buy ticket
        for (let i = 10; i < 99; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        firstWinner = (await lottery.getReward(2, 0)).toNumber();

        for (let i = 0; i < 400; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() === firstWinner) {
                firstWinnerId = i;
            }
        }

        console.log('first winner', firstWinner);
        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        
        await lottery.claimReward(firstWinnerId);
        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());

    });

    it('Should be able to claim last 2nd digit reward', async function () {
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
        const lottery = await _lottery.deploy(ticketDeploy.address, tokenDeploy.address, 2, 10);
        const lotteryDeploy = await lottery.deployed();

        // set distribute rate
        await lottery.setReward(0, 50);
        await lottery.setReward(1, 30);
        await lottery.setReward(2, 20);

        // mint token for self
        await thbToken.mint(1000000000000);

        // approve buyingToken to Lottery smart contract
        await thbToken.approve(lotteryDeploy.address, 100000000000000);

        // try buying ticket
        expect((await ticket.balanceOf(owner.address)).toNumber()).to.equal(0); // check balance before buying
        for (let i = 1000; i < 1099; i++) {
            await lottery.buyTicket(i);
        }

        await lottery.drawRewards();

        const firstWinner = (await lottery.getReward(1, 0)).toNumber();
        let firstWinnerId = 0;

        for (let i = 0; i < 99; i++) {
            const [number,] = await ticket.get(i);
            if (number.toNumber() % 100 === firstWinner % 100) {
                firstWinnerId = i;
                break;
            }
        }

        console.log('2nd digit', firstWinner);

        console.log('Balance before cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
        
        await lottery.claimReward(firstWinnerId);

        console.log('Balance after cliam: ', (await thbToken.balanceOf(owner.address)).toNumber());
    });
});