const { expect } = require("chai");

describe("random", function() {
  it("Should return random number when called", async function() {
    const random = await ethers.getContractFactory("random");
    const randomer = await random.deploy();
    
    await randomer.deployed();
    expect(await greeter.greet()).to.equal("Hello, world!");

    await greeter.setGreeting("Hola, mundo!");
    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
