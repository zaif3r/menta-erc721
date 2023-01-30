// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";
import "../src/erc721/MentaERC721Signature.sol";

contract MentaERC721SignatureTest is Test {
    MentaERC721Signature public menta;

    uint256 ownerPk;
    address owner;
    address bob;

    function setUp() public {
        ownerPk = 1;
        owner = vm.addr(ownerPk);
        bob = vm.addr(ownerPk + 1);

        vm.deal(bob, 1 ether);
        vm.prank(owner);
        menta = new MentaERC721Signature("Menta", "MENTA", "QmZ1", 100);
    }

    function testMintWithSignature() public {
        (
            MentaERC721Signature.Mint memory mint,
            bytes memory signature
        ) = buildMintSignature(ownerPk, bob, 1 wei, "QmZ1");

        menta.mintWithSignature{value: 1 wei}(mint, signature);

        assertEq(menta.tokenCount(), 1);
        assertEq(address(menta).balance, 1 wei);
    }

    function testFailMintWithSignatureInvalidSignature() public {
        (
            MentaERC721Signature.Mint memory mint,
            bytes memory signature
        ) = buildMintSignature(ownerPk + 1, bob, 1 wei, "QmZ1");

        vm.prank(bob);
        menta.mintWithSignature{value: 1 wei}(mint, signature);
    }

    function testFailMintWithSignatureIncorrectValue() public {
        (
            MentaERC721Signature.Mint memory mint,
            bytes memory signature
        ) = buildMintSignature(ownerPk, bob, 1 wei, "QmZ1");

        vm.prank(bob);
        menta.mintWithSignature{value: 0}(mint, signature);
    }

    function buildMintSignature(
        uint256 pk,
        address to,
        uint256 value,
        string memory tokenCid
    )
        internal
        returns (MentaERC721Signature.Mint memory mint, bytes memory signature)
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(menta.name())),
                keccak256(bytes("1")),
                block.chainid,
                address(menta)
            )
        );

        emit log_named_bytes32("domainSeparator", domainSeparator);

        mint = MentaERC721Signature.Mint({
            to: to,
            value: value,
            tokenCid: tokenCid
        });

        bytes32 typeHash = keccak256(
            "Mint(address to,uint256 value,string tokenCid)"
        );

        emit log_named_bytes32("typeHash", typeHash);

        bytes32 structHash = keccak256(
            abi.encode(typeHash, mint.to, mint.value, mint.tokenCid)
        );

        bytes32 digest = ECDSA.toTypedDataHash(domainSeparator, structHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        signature = abi.encodePacked(r, s, v);
    }
}
