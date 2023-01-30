// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/*
                                                                                                                       
        ™/////^       ^¬////™.   ^¬/////////////¬^   .¬//¬™.       ™//™ .^™///////////////™.    .™////™.               
        ¬×××××/.      ™×××××/.   ™#×××××××××××××#^   ^#×××#¬^     .¬××¬ ^™/×××××××××××××××¬.    ™#××××#™               
        ¬×××××#™     ^/×××××/.   ™#×#¬^^^^^^^^^^^.   ^#×××××/^    .¬××¬ ..^^^^^¬×××#¬^^^^^.    ./××##××/.              
        ¬×××//×/^    ¬×#//#×/.   ™#×#™               ^#×#/#××/^   .¬××¬        ™#××#^        ..¬××/^/×××¬.             
        ¬×××¬™#×¬.. ^#×¬^¬#×/.   ™#××/¬¬¬¬¬¬¬¬¬¬^    ^/×#™™/#×/^   ¬××¬        ™#××#^        ™/#×#^ ^/#×#™             
        ¬×××¬^/×/™^ ¬×#™ ™#×/.   ™#×××××××××××××™    ^#×#^ .™#×/^ .¬××¬        ™#××#^       .¬×××¬. ..¬××¬.            
        ¬×××¬.™###™^/×¬. ™#×/.   ™#×#¬^^^^^^^^^^.    ^#×#^  .¬××¬. ¬××¬        ™#××#^       ™#×××¬^^^^¬××#™            
        ¬×××¬ ./××//×#^  ™#×/.   ™#×#™               ^#×#^   .¬#×/™/××¬        ™#××#^      ^/×××××××××××××/^           
        ¬×××¬  ^#××××¬   ™#×/.   ™#×#¬^^^^^^^^^^^.   ^#×#^    .¬#×××××¬        ™#××#^     .¬×××/™^^^^^^™/××¬^.         
        ¬×××¬  .¬#××/.   ™#×/.   ™#××××××××××××××¬.  ^#×#^     .™#××××¬        ™#××#^     ™#×#/™        ™#×##™         
        ^™™™^   .™™™^    .™™^.   .™¬¬™™™™™™™™™™¬™^   .™™™.      .^™™¬¬^        ^™™¬™.     ^™™^..        .^¬¬¬^         
            
 */

import "openzeppelin/utils/cryptography/EIP712.sol";
import "openzeppelin/utils/cryptography/SignatureChecker.sol";
import "./MentaERC721.sol";

/// @notice Menta ERC721 contract with signature minting
/// @author zaifer (https://github.com/zaifer/menta-erc721.git)
contract MentaERC721Signature is MentaERC721, EIP712 {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    bytes32 internal constant MINT_TYPEHASH =
        0xd419666d83d119f1088d843e03c0db5ca48596757e9096ed6ed29b57bacc5945;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error IncorrectMintValue();

    error InvalidMintSignature();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR                          
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory name,
        string memory symbol,
        string memory contractCid,
        uint256 _maxSupply
    )
        payable
        EIP712(name, "1")
        MentaERC721(name, symbol, contractCid, _maxSupply)
    {}

    /*//////////////////////////////////////////////////////////////
                               MINT LOGIC 
    //////////////////////////////////////////////////////////////*/

    struct Mint {
        address to;
        uint256 value;
        string tokenCid;
    }

    function mintWithSignature(Mint calldata mint_, bytes calldata signature)
        external
        payable
    {
        if (msg.value != mint_.value) {
            revert IncorrectMintValue();
        }

        if (
            SignatureChecker.isValidSignatureNow(
                owner,
                _hashTypedDataV4(
                    keccak256(
                        abi.encode(
                            MINT_TYPEHASH,
                            mint_.to,
                            mint_.value,
                            mint_.tokenCid
                        )
                    )
                ),
                signature
            )
        ) {
            _menta(mint_.to, mint_.tokenCid);
        } else {
            revert InvalidMintSignature();
        }
    }
}
