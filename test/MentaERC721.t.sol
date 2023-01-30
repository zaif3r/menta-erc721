// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/erc721/MentaERC721.sol";

contract MentaERC721Test is Test {
    MentaERC721 public menta;

    address owner;
    address bob;
    uint256 maxSupply;

    function setUp() public {
        owner = vm.addr(1);
        bob = vm.addr(2);

        maxSupply = 10;

        vm.deal(bob, 1 ether);

        vm.prank(owner);
        menta = new MentaERC721("Menta", "MENTA", "QmZ1", maxSupply);
    }

    function testOwner() public {
        assertEq(menta.owner(), owner);
    }

    function testMetadata() public {
        assertEq(menta.name(), "Menta");
        assertEq(menta.symbol(), "MENTA");
        assertEq(menta.maxSupply(), maxSupply);
        assertEq(menta.contractURI(), "ipfs://QmZ1");
    }

    function testSetContractCid(string memory cid) public {
        vm.prank(owner);
        menta.setContractCid(cid);

        assertEq(menta.contractURI(), string(abi.encodePacked("ipfs://", cid)));
    }

    function testFailSetContractCidNotOwner() public {
        vm.prank(bob);
        menta.setContractCid("QmZ2");
    }

    function testMintOwner() public {
        vm.prank(owner);
        menta.mintOwner(bob, "QmZ1");

        assertEq(menta.tokenCount(), 1);
    }

    function testFailMintOwnerNotOwner() public {
        vm.prank(bob);
        menta.mintOwner(bob, "QmZ1");
    }

    function testFailMintOwnerMaxSupplyReached() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < maxSupply + 1; i++) {
            menta.mintOwner(bob, "QmZ1");
        }
    }

    function testOwnerOf() public {
        vm.prank(owner);
        menta.mintOwner(bob, "QmZ1");

        assertEq(menta.ownerOf(0), bob);
    }

    function testTokenURI(string memory cid) public {
        vm.prank(owner);
        menta.mintOwner(bob, cid);

        assertEq(menta.tokenURI(0), string(abi.encodePacked("ipfs://", cid)));
    }

    function testSetTokenCid(string memory cid) public {
        vm.startPrank(owner);
        menta.mintOwner(bob, "QmZ1");
        menta.setTokenCid(0, cid);
        
        assertEq(menta.tokenURI(0), string(abi.encodePacked("ipfs://", cid)));
    }

    function testFailSetTokenCidNotOwner() public {
        vm.prank(owner);
        menta.mintOwner(bob, "QmZ1");

        vm.prank(bob);
        menta.setTokenCid(0, "QmZ2");
    }
}
