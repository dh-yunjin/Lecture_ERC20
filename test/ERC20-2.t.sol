// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/ERC20.sol";

contract ERC20_Test2 is ERC20, Test {
    ERC20 drm_token;
    address internal constant alice = address(1);
    address internal constant bob = address(2);

    function setUp() public {
    }
    
    function testMint() public {
        _mint(alice, 100 ether);
        assertEq(totalSupply(), 200 ether);
        assertEq(balanceOf(alice), 100 ether);
    }

    function testMultiMint() public {
        _mint(alice, 100 ether);
        assertEq(balanceOf(alice), 100 ether);
        assertEq(totalSupply(), 200 ether);
        
        _mint(bob, 10 ether);
        assertEq(balanceOf(bob), 10 ether);
        assertEq(totalSupply(), 210 ether);

        _mint(bob, 1 ether);
        assertEq(balanceOf(bob), 11 ether);
        assertEq(totalSupply(), 211 ether);
    }

    function testFailMintOverflow() public {
        uint256 amount = type(uint256).max - totalSupply() + 1;
        _mint(alice, amount);
    }

    function testBurn() public {
        _mint(alice, 100 ether);
        assertEq(totalSupply(), 200 ether);
        assertEq(balanceOf(alice), 100 ether);
        _burn(alice, 100 ether);
        assertEq(totalSupply(), 100 ether);
        assertEq(balanceOf(alice), 0);
    }

    function testMultiBurn() public {
        _mint(alice, 100 ether);
        assertEq(totalSupply(), 200 ether);
        assertEq(balanceOf(alice), 100 ether);
        _burn(alice, 50 ether);
        assertEq(totalSupply(), 150 ether);
        assertEq(balanceOf(alice), 50 ether);
        _burn(alice, 50 ether);
        assertEq(totalSupply(), 100 ether);
        assertEq(balanceOf(alice), 0);
    }

    function testFailMintWAddressZero() public {
        _mint(address(0), 100 ether);
    }

    function testFailburnWAddressZero() public {
        _burn(address(0), 100 ether);
    }

    function testFailBurn() public {
        _mint(alice, 10 ether);
        _burn(alice, 100 ether);
    }
}
