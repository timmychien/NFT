pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
// METADATA 是每一個token 都有不同的metadata

// import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/drafts/Counters.sol";

// ERC721Full
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721Enumerable.sol";
//import "./ERC721Metadata.sol";

// ERC721Metadata
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/GSN/Context.sol";
// import "./ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/introspection/ERC165.sol";
// import "./ownership.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";


contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Base URI
    string private _baseURI;

    struct metadata {
      uint256 tokenId;
      string property1;
      string property2;
      string property3;
      string property4;
      string property5;
    }

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

     mapping(uint256 => metadata) private _metadata;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the URI for a given token ID. May return an empty string.
     *
     * If the token's URI is non-empty and a base URI was set (via
     * {_setBaseURI}), it will be added to the token ID's URI as a prefix.
     *
     * Reverts if the token ID does not exist.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // Even if there is a base URI, it is only appended to non-empty token-specific URIs
        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            // abi.encodePacked is being used to concatenate strings
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     * TIP: if all token IDs share a prefix (e.g. if your URIs look like
     * `http://api.myproject.com/token/<id>`), use {_setBaseURI} to store
     * it and save gas.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }


    /**
     * @dev Internal function to set the token metadata for a given token.
     *
     * Reverts if the token ID does not exist.
     *
     */
    function _setMetaData(uint256 tokenId,  string memory property1, string memory property2,
     string memory property3, string memory property4, string memory property5) internal {
        require(_exists(tokenId), "ERC721Metadata: nonexistent token");
        metadata storage __metadata = _metadata[tokenId];
       __metadata.tokenId = tokenId;
       __metadata.property1 = property1;
       __metadata.property2 = property2;
       __metadata.property3 = property3;
       __metadata.property4 = property4;
       __metadata.property5 = property5;
    }
    
   
    
      /**
     * @dev Returns the MetaData for a given token ID. May return an empty string.
     *
     * Reverts if the token ID does not exist.
     *
     */
    function MetaData(uint256 tokenId) public view returns (metadata memory) {
        require(_exists(tokenId), "ERC721Metadata: Metadata set of nonexistent token");
        return ( 
       _metadata[tokenId]);
    }



    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI}.
     *
     * _Available since v2.5.0._
     */
    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a preffix in {tokenURI} to each token's URI, when
    * they are non-empty.
    *
    * _Available since v2.5.0._
    */
    function baseURI() external view returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

/**
 * @title Full ERC721 Token
 * @dev This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology.
 *
 * See https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721Full is ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

     
}


contract BaypayItem is ERC721Full, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => bool) internal mIsOfficialOperator;
    mapping(address => bool) internal mIsUserNotAcceptingAllOfficialOperators;
    mapping(address => uint256) public usedNonce;

    event OfficialOperatorAdded(address operator);
    event OfficialOperatorRemoved(address operator);
    event OfficialOperatorsAcceptedByUser(address indexed user);
    event OfficialOperatorsRejectedByUser(address indexed user);
    event tokenIdofOwner(uint256 index);
     
       event Sent(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 tokenId,
    bytes holderData
  );
  
    modifier onlyOwnerOrOperator() {
      require(isOwner() || mIsOfficialOperator[msg.sender],"");
      _;
    }
    
      modifier onlyOwnerOrTokenOwner(uint256 tokenId) {
             address owner = ownerOf(tokenId);
    
       require(isOwner() || msg.sender == owner ,"");
      _;
    }
    
     modifier onlyTokenOwner() {
      require(isOwner() || mIsOfficialOperator[msg.sender],"");
      _;
    }
    // name, symbol
    constructor(string memory  tokenName, string memory tokenSymbol) ERC721Full(tokenName, tokenSymbol) public {
    }

    function delivery(address player, string memory tokenURI, uint tokenId,string memory property1, string memory property2,
     string memory property3, string memory property4, string memory property5) public onlyOwnerOrOperator returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId =tokenId;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _setMetaData(newItemId, property1, property2, property3, property4, property5);
        return newItemId;
    }
    
    function mint(address player, string memory tokenURI,uint tokenId) public onlyOwnerOrOperator returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = tokenId;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    function setMetaData(uint256 tokenId, string memory property1, string memory property2,
     string memory property3, string memory property4, string memory property5) public onlyOwnerOrTokenOwner(tokenId) {
          require(_exists(tokenId), "ERC721Metadata: Metadata set of nonexistent token");
           _setMetaData(tokenId, property1, property2, property3, property4, property5);
     }

    /// @notice Add an address into the list of official operators.
    /// @param _operator The address of a new official operator.
    /// An official operator must be a contract.
    function addOfficialOperator(address _operator) external onlyOwner {
    //    require(_operator.isContract(), "An official operator must be a contract.");
        require(!mIsOfficialOperator[_operator], "_operator is already an official operator.");

        mIsOfficialOperator[_operator] = true;
        emit OfficialOperatorAdded(_operator);
    }

    
  /// @notice Delete an address from the list of official operators.
  /// @param _operator The address of an official operator.
  function removeOfficialOperator(address _operator) external onlyOwner {
    require(mIsOfficialOperator[_operator], "_operator is not an official operator.");

    mIsOfficialOperator[_operator] = false;
    emit OfficialOperatorRemoved(_operator);
  }

  /// @notice Unauthorize all official operators to manage `msg.sender`'s tokens.
  function rejectAllOfficialOperators() external {
    require(!mIsUserNotAcceptingAllOfficialOperators[msg.sender], "Official operators are already rejected by msg.sender.");

    mIsUserNotAcceptingAllOfficialOperators[msg.sender] = true;
    emit OfficialOperatorsRejectedByUser(msg.sender);
  }

  /// @notice Authorize all official operators to manage `msg.sender`'s tokens.
  function acceptAllOfficialOperators() external {
    require(mIsUserNotAcceptingAllOfficialOperators[msg.sender], "Official operators are already accepted by msg.sender.");

    mIsUserNotAcceptingAllOfficialOperators[msg.sender] = false;
    emit OfficialOperatorsAcceptedByUser(msg.sender);
  }

  /// @return true if the address is an official operator, false if not.
  function isOfficialOperator(address _operator) external view returns(bool) {
    return mIsOfficialOperator[_operator];
  }

  /// @return true if a user is accepting all official operators, false if not.
  function isUserAcceptingAllOfficialOperators(address _user) external view returns(bool) {
    return !mIsUserNotAcceptingAllOfficialOperators[_user];
  }

  /// @notice Check whether the `_operator` address is allowed to manage the tokens held by `_tokenHolder` address.
  /// @param _operator address to check if it has the right to manage the tokens
  /// @param _tokenHolder address which holds the tokens to be managed
  /// @return `true` if `_operator` is authorized for `_tokenHolder`
  function isOperatorFor(address _operator, address _tokenHolder) public view returns (bool) {
         return (
      _operator == _tokenHolder
      || (!mIsUserNotAcceptingAllOfficialOperators[_tokenHolder] && mIsOfficialOperator[_operator]));
  }


   /// @notice Helper function actually performing the sending of tokens.
  /// @param _from The address holding the tokens being sent
  /// @param _to The address of the recipient
  /// @param __tokenIds The ids of tokens to be sent
  /// @param _nonce uint256 Presigned transaction number.
  /// @param _userData  bytes Data generated by the user to be sent to the recipient.
  /// @param _sig_r bytes32 The r of the signature.
  /// @param _sig_s bytes32 The s of the signature.
  /// @param _sig_v uint8 The v of the signature.
 function operatorSend(address _from,
                   address _to,
                   uint256[] calldata __tokenIds,
                   uint256 _nonce,
                   bytes calldata  _userData,
                   bytes32 _sig_r,
                   bytes32 _sig_s,
                uint8 _sig_v) external {
    require(isOperatorFor(msg.sender, _from),"sender is not operator");
    
    address _signer = (_sig_v != 27 && _sig_v != 28) ?
      address(0) :
      ecrecover(
        keccak256(abi.encodePacked(
           msg.sender,
          _from,
          _to,
          _nonce
        )),
        _sig_v, _sig_r, _sig_s
      );
    
       require(
      _nonce > usedNonce[_signer],
      "_nonce must be greater than the last used nonce of the token holder."
    );

    usedNonce[_signer] = _nonce;
   doSend(msg.sender, _from, _to, __tokenIds, _userData);
  }

  /// @notice Helper function actually performing the sending of tokens.
  /// @param _operator The address performing the send
  /// @param _from The address holding the tokens being sent
  /// @param _to The address of the recipient
  /// @param __tokenIds The number of tokens to be sent

  ///  implementing `ERC777TokensRecipient`.
  ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
  ///  functions SHOULD set this parameter to `false`.
  function doSend(
    address _operator,
    address _from,
    address _to,
    uint256[] memory __tokenIds,
    bytes memory  _userData
  )
    internal
  {
    for(uint i = 0; i < __tokenIds.length; i++) {
     _transferFrom(_from, _to, __tokenIds[i]);
     emit Sent(_operator, _from, _to,  __tokenIds[i], _userData);
    }
  }
  
   /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isTokenOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner );
    }
    
    function tokenIdofOwnerByAddress(address owner) public view returns(uint256[] memory ){
        uint256  balance = balanceOf(owner);

       uint256[] memory tokenIds = new uint256[](balance);
      for (uint i = 0; i < balance; i++) {
          uint256 tokenId = tokenOfOwnerByIndex(owner,i );
       
        tokenIds[i]= tokenId;
      }
      return tokenIds;
    }
    
      function getMetaDataByTokenIds(uint256[] memory tokenIds) public view returns(metadata[] memory) {
         
           metadata[] memory _metadatas = new metadata[](tokenIds.length);
      for (uint i = 0; i < tokenIds.length; i++) {
           require(_exists(tokenIds[i]), "ERC721Metadata: Metadata set of nonexistent token");
           uint256  _tokenID = tokenIds[i];
  
          _metadatas[i]=MetaData(_tokenID);
      }
      return _metadatas;
     }
}
