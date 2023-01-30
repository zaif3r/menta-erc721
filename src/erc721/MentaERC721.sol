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

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";

/// @author zaifer (https://github.com/zaifer/menta-erc721.git)
/// @notice Owned ERC721 token with max supply and IPFS CIDs for metadata.
contract MentaERC721 is ERC721, Owned {
    /*//////////////////////////////////////////////////////////////
                              TOKEN STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The number of tokens in existence, also used as the next token ID.
    uint256 public tokenCount;

    /// @notice The maximum number of tokens that can be minted.
    uint256 public immutable maxSupply;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error MaxSupplyReached();

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS   
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the max supply has been reached. If maxSupply is 0, no limit is enforced.
    modifier maxSupplyNotReached() {
        if (maxSupply != 0 && tokenCount >= maxSupply)
            revert MaxSupplyReached();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        IPFS CID STORAGE/SETTERS                                       
    //////////////////////////////////////////////////////////////*/

    /// @notice The IPFS CID for the contract metadata.
    string internal _contractCid;

    /// @notice Mapping from token ID to IPFS CID for the token metadata.
    mapping(uint256 => string) internal _tokenCidOf;

    function setContractCid(string calldata cid) external onlyOwner {
        _contractCid = cid;
    }

    function setTokenCid(uint256 id, string calldata cid) external onlyOwner {
        _tokenCidOf[id] = cid;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR                          
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory name,
        string memory symbol,
        string memory contractCid_,
        uint256 maxSupply_
    ) payable ERC721(name, symbol) Owned(msg.sender) {
        _contractCid = contractCid_;
        maxSupply = maxSupply_;
    }

    /*//////////////////////////////////////////////////////////////
                               URI GETTERS                          
    //////////////////////////////////////////////////////////////*/

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked("ipfs://", _contractCid));
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked("ipfs://", _tokenCidOf[id]));
    }

    /*//////////////////////////////////////////////////////////////
                               MINT LOGIC 
    //////////////////////////////////////////////////////////////*/

    function mintOwner(address to, string calldata cid) external onlyOwner {
        _menta(to, cid);
    }

    function _menta(address to, string memory cid)
        internal
        maxSupplyNotReached
    {
        _safeMint(to, tokenCount);
        _tokenCidOf[tokenCount] = cid;

        unchecked {
            tokenCount++;
        }
    }
}
