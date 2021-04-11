pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract testSafeMath {
    using SafeMath for uint256;
    
    uint256 denom = 1e18;
    uint256 rewardPool;
    
    constructor(uint256 _reward) {
        rewardPool = _reward;
        rewardPool = rewardPool.mul(denom);
    }
    
    // first second third
    // entire pool allocatableReward will be 95 percent of rewardPool wallet
    // 5% will be reserved
    // let's say first got 50% (of entire pool)
    // seconds 30% (of entire pool)
    // third 20% (of entire pool)
    function testSplitReward() public view returns (uint256, uint256, uint256) {
        uint256 allocatableReward = rewardPool.mul(95).div(100);

        console.log(allocatableReward);

        uint256 firstReward = allocatableReward.mul(50).div(100);
        uint256 secondReward = allocatableReward.mul(30).div(100);
        uint256 thirdReward = allocatableReward.sub(firstReward).sub(secondReward);
        
        return (firstReward, secondReward, thirdReward);
    } 
}