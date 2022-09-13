// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC20.sol";

contract ERC20_Test1 is Test {
    ERC20 drm_token;
    address internal constant alice = address(1);
    address internal constant bob = address(2);

    function setUp() public {
        drm_token = new ERC20();
    }
    
    function testName() public {
        assertEq(drm_token.name(), "DREAM");
    }

    function testSymbol() public {
        assertEq(drm_token.symbol(), "DRM");
    }

    function testDecimals() public {
        assertEq(drm_token.decimals(), 18);
    }

    function testTotalSupply() public {
        assertEq(drm_token.totalSupply(), 100 ether);
        assertEq(drm_token.balanceOf(address(this)), 100 ether);
    }

    function testApprove() public {
        drm_token.approve(alice, 10 ether);
        assertEq(drm_token.allowance(address(this), alice), 10 ether);
        assertEq(drm_token.allowance(alice, address(this)), 0 ether);
        assertEq(drm_token.allowance(address(this), bob), 0 ether);
    }

    function testMultiApprove1() public {
        drm_token.approve(alice, 10 ether);
        drm_token.approve(alice, 5 ether);
        assertEq(drm_token.allowance(address(this), alice), 5 ether);
        assertEq(drm_token.allowance(alice, address(this)), 0 ether);
        assertEq(drm_token.allowance(address(this), bob), 0 ether);
    }

    function testMultiApprove2() public {
        drm_token.approve(alice, 5 ether);
        drm_token.approve(alice, 10 ether);
        assertEq(drm_token.allowance(address(this), alice), 10 ether);
        assertEq(drm_token.allowance(alice, address(this)), 0 ether);
        assertEq(drm_token.allowance(address(this), bob), 0 ether);
    }

    function testMultiApprove3() public {
        drm_token.approve(alice, 5 ether);
        drm_token.approve(alice, 5 ether);
        assertEq(drm_token.allowance(address(this), alice), 5 ether);
        assertEq(drm_token.allowance(alice, address(this)), 0 ether);
        assertEq(drm_token.allowance(address(this), bob), 0 ether);
    }

    function testTransfer() public {
        drm_token.transfer(alice, 1 ether);
        assertEq(drm_token.balanceOf(alice), 1 ether);
        assertEq(drm_token.balanceOf(address(this)), 99 ether);
        assertEq(drm_token.totalSupply(), 100 ether);
    }

    function testMultiTransfer() public {
        drm_token.transfer(alice, 1 ether);
        drm_token.transfer(alice, 1 ether);
        drm_token.transfer(alice, 1 ether);
        assertEq(drm_token.balanceOf(alice), 3 ether);
        assertEq(drm_token.balanceOf(address(this)), 97 ether);
        assertEq(drm_token.totalSupply(), 100 ether);
    }

    function testFailTransfer1() public {
        drm_token.transfer(alice, 1000 ether);
    }

    function testFailTransfer2() public {
        drm_token.transfer(alice, 50 ether);
        drm_token.transfer(address(this), 50 ether);
        drm_token.transfer(alice, 50 ether);
        drm_token.transfer(address(this), 1);
    }

    function testTransferFrom() public {
        drm_token.approve(bob, 10 ether);
        assertEq(drm_token.allowance(address(this), bob), 10 ether);
        vm.prank(bob);
        drm_token.transferFrom(address(this), bob, 10 ether);
        assertEq(drm_token.balanceOf(bob), 10 ether);
        assertEq(drm_token.balanceOf(address(this)), 90 ether);
        assertEq(drm_token.allowance(address(this), bob), 0);
        assertEq(drm_token.totalSupply(), 100 ether);
    }

    function testPartialTransferFrom() public {
        drm_token.approve(bob, 10 ether);
        assertEq(drm_token.allowance(address(this), bob), 10 ether);
        vm.prank(bob);
        drm_token.transferFrom(address(this), bob, 5 ether);
        assertEq(drm_token.balanceOf(bob), 5 ether);
        assertEq(drm_token.balanceOf(address(this)), 95 ether);
        assertEq(drm_token.allowance(address(this), bob), 5 ether);
        assertEq(drm_token.totalSupply(), 100 ether);
    }

    function testFailTransferFrom() public {
        drm_token.approve(bob, 10 ether);
        assertEq(drm_token.allowance(address(this), bob), 10 ether);
        vm.prank(bob);
        drm_token.transferFrom(address(this), bob, 100 ether);
    }
}
