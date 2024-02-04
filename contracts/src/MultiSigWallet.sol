// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

contract MultiSigWallet is IERC721Receiver {
    enum TxnType {
        ETH,
        Token,
        NFT
    }

    enum TxnAction {
        Transfer, // ETH transactions have this action by default
        TransferFrom,
        Approve
    }

    struct TxnDetails {
        uint256 approvals;
        bool executed;
    }

    struct EthTxn {
        address to;
        uint256 amount;
        TxnDetails txnDetails;
    }

    struct TokenTxn {
        TxnAction action;
        address to;
        uint256 amount;
        address allowanceProvider;
        address tokenContractAddress;
        TxnDetails txnDetails;
    }

    struct NftTxn {
        TxnAction action;
        address to;
        uint256 tokenId;
        address allowanceProvider;
        address nftContractAddress;
        TxnDetails txnDetails;
    }

    mapping(address => bool) private s_owners;
    uint256 private s_requiredApprovals;

    EthTxn[] private s_ethTxns;
    uint256 private s_ethTxnCount;
    // ETH txn array index --> owner --> approval given?
    mapping(uint256 => mapping(address => bool)) private s_ethTxnApprovals;

    TokenTxn[] private s_tokenTxns;
    uint256 private s_tokenTxnCount;
    // token txn array index --> owner --> approval given?
    mapping(uint256 => mapping(address => bool)) private s_tokenTxnApprovals;

    NftTxn[] private s_nftTxns;
    uint256 private s_nftTxnCount;
    // NFT txn array index --> owner --> approval given?
    mapping(uint256 => mapping(address => bool)) private s_nftTxnApprovals;

    /**
     * @notice Emitted each time the wallet receives ETH.
     * @param amount The amount of ETH received.
     */
    event ETHReceived(uint256 amount);

    /**
     * @notice Emitted each time a new transaction is issued by one of the owners.
     * @param txnType The type of transaction (ETH, token, or NFT).
     * @param txnIndex The array index at which the transaction request details are stored for the given transaction type.
     * @param by The address of the owner who issued the transaction.
     */
    event TxnIssued(TxnType txnType, uint256 txnIndex, address by);

    /**
     * @notice Emitted each time a transaction is approved by one of the owners.
     * @param txnType The type of transaction (ETH, token, or NFT).
     * @param txnIndex The array index at which the transaction request details are stored for the given transaction type.
     * @param by The address of the owner who issued the transaction.
     */
    event TxnApproved(TxnType txnType, uint256 txnIndex, address by);

    /**
     * @notice Emitted each time a transaction is executed by one of the owners.
     * @param txnType The type of transaction (ETH, token, or NFT).
     * @param txnIndex The array index at which the transaction request details are stored for the given transaction type.
     * @param by The address of the owner who issued the transaction.
     */
    event TxnExecuted(TxnType txnType, uint256 txnIndex, address by);

    error MultiSigWallet__NotOneOfTheOwners();
    error MultiSigWallet__InvalidIndex();
    error MultiSigWallet__InvalidRequiredApprovals();
    error MultiSigWallet__TxnAlreadyApproved();
    error MultiSigWallet__NotEnoughApprovalsGiven(uint256 approvals);
    error MultiSigWallet__TxnAlreadyExecuted();
    error MultiSigWallet__NotEnoughEtH(uint256 balance);
    error MultiSigWallet__TxnFailed();
    error MultiSigWallet__NotEnoughTokens(uint256 tokenBalance);
    error MultiSigWallet__NotEnoughAllowance(uint256 allowance);
    error MultiSigWallet__TokenIdNotOwned();
    error MultiSigWallet__NftNotApproved();
    error MultiSigWallet__NotOwnerOfNft(uint256 tokenId);

    modifier onlyOneOfTheOwners() {
        if (!s_owners[msg.sender]) revert MultiSigWallet__NotOneOfTheOwners();
        _;
    }

    modifier onlyValidTxnIndex(TxnType txnType, uint256 txnIndex) {
        if (txnType == TxnType.ETH) {
            if (txnIndex > s_ethTxns.length)
                revert MultiSigWallet__InvalidIndex();
        } else if (txnType == TxnType.Token) {
            if (txnIndex > s_tokenTxns.length)
                revert MultiSigWallet__InvalidIndex();
        } else if (txnType == TxnType.NFT) {
            if (txnIndex > s_nftTxns.length)
                revert MultiSigWallet__InvalidIndex();
        }
        _;
    }

    /**
     * @notice Initialises the wallet contract by setting the owners, required approvals, and transaction counts.
     * @param owners A list of the wallet owners.
     * @param requiredApprovals The minimum number of approvals required for the wallet's transactions to be authorized.
     */
    constructor(address[] memory owners, uint256 requiredApprovals) {
        if (requiredApprovals > owners.length)
            revert MultiSigWallet__InvalidRequiredApprovals();

        for (uint32 count = 0; count < owners.length; count++) {
            s_owners[owners[count]] = true;
        }

        s_requiredApprovals = requiredApprovals;
        s_ethTxnCount = 0;
        s_tokenTxnCount = 0;
        s_nftTxnCount = 0;
    }

    /**
     * @notice Allows the contract to receive ETH.
     */
    receive() external payable {
        emit ETHReceived(msg.value);
    }

    /**
     * @notice Allows the contract to receive NFTs using the safeMint() function.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @notice Issues an ETH transfer request.
     * @param to The recipient of ETH.
     * @param amount The amount of ETH to send.
     */
    function issueEthTxn(
        address to,
        uint256 amount
    ) external onlyOneOfTheOwners {
        s_ethTxnCount++;

        EthTxn memory newTxn = EthTxn({
            to: to,
            amount: amount,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        s_ethTxns.push(newTxn);

        emit TxnIssued(TxnType.ETH, s_ethTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues a token transfer request.
     * @param to The recipient of tokens.
     * @param amount The amount of tokens to send.
     * @param tokenContractAddress The token's contract address.
     */
    function issueTokenTransferTxn(
        address to,
        uint256 amount,
        address tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.Transfer,
            to,
            amount,
            address(0),
            tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, s_tokenTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues a token transfer from request. This request will allow the wallet to spend the token allowance given by the allowance provider.
     * @param to The recipient of the tokens.
     * @param amount The amount of tokens to send.
     * @param allowanceProvider The address that gave a token allowance to this wallet.
     * @param tokenContractAddress The token's contract address.
     */
    function issueTokenTransferFromTxn(
        address to,
        uint256 amount,
        address allowanceProvider,
        address tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.TransferFrom,
            to,
            amount,
            allowanceProvider,
            tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, s_tokenTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues a token approval request. This request will provide a token allowance to the recipient.
     * @param to The receipient of an allowance.
     * @param amount The amount of tokens to approve.
     * @param tokenContractAddress The token's contract address.
     */
    function issueTokenApprovalTxn(
        address to,
        uint256 amount,
        address tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.Approve,
            to,
            amount,
            address(0),
            tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, s_tokenTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues an NFT transfer request.
     * @param _to The recipient of the NFT.
     * @param _tokenId The NFT's tokenId.
     * @param _nftContractAddress The contract address that issued the NFT.
     */
    function issueNftTransferTxn(
        address _to,
        uint256 _tokenId,
        address _nftContractAddress
    ) external onlyOneOfTheOwners {
        issueNftTxnHelper(
            TxnAction.Transfer,
            _to,
            _tokenId,
            address(0),
            _nftContractAddress
        );

        emit TxnIssued(TxnType.NFT, s_nftTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues an NFT transfer from request. This request will allow the wallet to transfer the NFT tokenId allowance on behalf of the allowance provider.
     * @param to The recipient of the NFT.
     * @param allowanceProvider The address that gave the NFT tokenId allowance to this wallet.
     * @param tokenId The NFT tokenId approved for this contract.
     * @param nftContractAddress The contract address that issued the NFT.
     */
    function issueNftTransferFromTxn(
        address to,
        address allowanceProvider,
        uint256 tokenId,
        address nftContractAddress
    ) external onlyOneOfTheOwners {
        issueNftTxnHelper(
            TxnAction.TransferFrom,
            to,
            tokenId,
            allowanceProvider,
            nftContractAddress
        );

        emit TxnIssued(TxnType.NFT, s_nftTxnCount - 1, msg.sender);
    }

    /**
     * @notice Issues an NFT approval request.
     * @param to The recipient of the NFT tokenId allowance.
     * @param tokenId The NFT tokenId to approve for the spender.
     * @param nftContractAddress The NFT's contract address
     */
    function issueNftApprovalTxn(
        address to,
        uint256 tokenId,
        address nftContractAddress
    ) external onlyOneOfTheOwners {
        issueNftTxnHelper(
            TxnAction.Approve,
            to,
            tokenId,
            address(0),
            nftContractAddress
        );

        emit TxnIssued(TxnType.NFT, s_nftTxnCount - 1, msg.sender);
    }

    /**
     * @notice Allows owners to approve transactions.
     * @param txnType The type of transaction to approve (ETH, toke, or NFT).
     * @param txnIndex The array index where the transaction request details are stored.
     */
    function approveTxn(
        TxnType txnType,
        uint256 txnIndex
    ) external onlyOneOfTheOwners onlyValidTxnIndex(txnType, txnIndex) {
        if (txnType == TxnType.ETH) {
            if (s_ethTxnApprovals[txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (s_ethTxns[txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            s_ethTxnApprovals[txnIndex][msg.sender] = true;
            s_ethTxns[txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.ETH, txnIndex, msg.sender);
        } else if (txnType == TxnType.Token) {
            if (s_tokenTxnApprovals[txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (s_tokenTxns[txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            s_tokenTxnApprovals[txnIndex][msg.sender] = true;
            s_tokenTxns[txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.Token, txnIndex, msg.sender);
        } else if (txnType == TxnType.NFT) {
            if (s_nftTxnApprovals[txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (s_nftTxns[txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            s_nftTxnApprovals[txnIndex][msg.sender] = true;
            s_nftTxns[txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.NFT, txnIndex, msg.sender);
        }
    }

    /**
     * @notice Executes a transaction if it has enough approvals, and if it hasn't been executed yet.
     * @param txnType The type of transaction to execute (ETH, toke, or NFT).
     * @param txnIndex The array index where the transaction request details are stored.
     */
    function executeTxn(
        TxnType txnType,
        uint256 txnIndex
    ) external onlyOneOfTheOwners onlyValidTxnIndex(txnType, txnIndex) {
        if (txnType == TxnType.ETH) {
            executeEthTxn(txnIndex);
            emit TxnExecuted(TxnType.ETH, txnIndex, msg.sender);
        } else if (txnType == TxnType.Token) {
            executeTokenTxn(txnIndex);
            emit TxnExecuted(TxnType.Token, txnIndex, msg.sender);
        } else if (txnType == TxnType.NFT) {
            executeNftTxn(txnIndex);
            emit TxnExecuted(TxnType.NFT, txnIndex, msg.sender);
        }
    }

    /**
     * @notice Returns a boolean value indicating whether the account is an owner of this wallet or not.
     * @param account The account whose ownership you want to check.
     */
    function isOwner(address account) public view returns (bool) {
        return s_owners[account];
    }

    /**
     * @notice Returns the minimum number of approvals required for transactions to be executed.
     */
    function getRequiredApprovals() public view returns (uint256) {
        return s_requiredApprovals;
    }

    /**
     * @notice Returns the total number of ETH transactions issued.
     */
    function getEthTxnCount() public view returns (uint256) {
        return s_ethTxnCount;
    }

    /**
     * @notice Returns the total number of token transactions issued.
     */
    function getTokenTxnCount() public view returns (uint256) {
        return s_tokenTxnCount;
    }

    /**
     * @notice Returns the total number of NFT transactions issued.
     */
    function getNftTxnCount() public view returns (uint256) {
        return s_nftTxnCount;
    }

    /**
     * @notice Returns a struct consisting of the ETH transaction request details.
     * @param txnIndex The array index at which the transaction request details are stored.
     */
    function getEthTxnDetails(
        uint256 txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.ETH, txnIndex)
        returns (EthTxn memory)
    {
        return s_ethTxns[txnIndex];
    }

    /**
     * @notice Returns a struct consisting of the token transaction request details.
     * @param txnIndex The array index at which the transaction request details are stored.
     */
    function getTokenTxnDetails(
        uint256 txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.Token, txnIndex)
        returns (TokenTxn memory)
    {
        return s_tokenTxns[txnIndex];
    }

    /**
     * @notice Returns a struct consisting of the NFT transaction request details.
     * @param txnIndex The array index at which the transaction request details are stored.
     */
    function getNftTxnDetails(
        uint256 txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.NFT, txnIndex)
        returns (NftTxn memory)
    {
        return s_nftTxns[txnIndex];
    }

    /**
     * @notice All token transaction issual requests are directed here.
     * @param action The type of token transaction request (transfer, transfer from, or approve).
     * @param to The recipient of tokens.
     * @param amount The amount of tokens.
     * @param allowanceProvider The allowance provider.
     * @param tokenContractAddress The token's contract address.
     */
    function issueTokenTxnHelper(
        TxnAction action,
        address to,
        uint256 amount,
        address allowanceProvider,
        address tokenContractAddress
    ) internal {
        s_tokenTxnCount++;

        TokenTxn memory newTxn = TokenTxn({
            action: action,
            to: to,
            amount: amount,
            allowanceProvider: allowanceProvider,
            tokenContractAddress: tokenContractAddress,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        s_tokenTxns.push(newTxn);
    }

    /**
     * @notice All NFT transaction issual requests are directed here.
     * @param action The type of NFT transaction request (transfer, transfer from, or approve).
     * @param to The recipient of NFT.
     * @param tokenId The NFT's tokenId.
     * @param allowanceProvider The NFT tokenId allowance provider.
     * @param nftContractAddress The NFT's contract address.
     */
    function issueNftTxnHelper(
        TxnAction action,
        address to,
        uint256 tokenId,
        address allowanceProvider,
        address nftContractAddress
    ) internal {
        s_nftTxnCount++;

        NftTxn memory newTxn = NftTxn({
            action: action,
            to: to,
            tokenId: tokenId,
            allowanceProvider: allowanceProvider,
            nftContractAddress: nftContractAddress,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        s_nftTxns.push(newTxn);
    }

    /**
     * @notice Executes ETH an transaction if it has enough approvals, and if it hasn't been executed before.
     * @param txnIndex The array index where the transaction request details have been stored.
     */
    function executeEthTxn(uint256 txnIndex) internal {
        if (s_ethTxns[txnIndex].txnDetails.approvals < s_requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                s_ethTxns[txnIndex].txnDetails.approvals
            );
        else if (s_ethTxns[txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();
        else if (address(this).balance < s_ethTxns[txnIndex].amount)
            revert MultiSigWallet__NotEnoughEtH(address(this).balance);

        s_ethTxns[txnIndex].txnDetails.executed = true;

        (bool success, ) = s_ethTxns[txnIndex].to.call{
            value: s_ethTxns[txnIndex].amount
        }("");
        if (!success) revert MultiSigWallet__TxnFailed();
    }

    /**
     * @notice Executes token transactions if they have enough approvals, and if they haven't been executed before
     * @param txnIndex The array index where the transaction request details have been stored.
     */
    function executeTokenTxn(uint256 txnIndex) internal {
        // test transferFrom and approve in pytest
        if (s_tokenTxns[txnIndex].txnDetails.approvals < s_requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                s_tokenTxns[txnIndex].txnDetails.approvals
            );
        else if (s_tokenTxns[txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();

        if (s_tokenTxns[txnIndex].action == TxnAction.Transfer) {
            uint256 tokenBalance = IERC20(
                s_tokenTxns[txnIndex].tokenContractAddress
            ).balanceOf(address(this));
            if (tokenBalance < s_tokenTxns[txnIndex].amount)
                revert MultiSigWallet__NotEnoughTokens(tokenBalance);

            s_tokenTxns[txnIndex].txnDetails.executed = true;

            IERC20(s_tokenTxns[txnIndex].tokenContractAddress).transfer(
                s_tokenTxns[txnIndex].to,
                s_tokenTxns[txnIndex].amount
            );
        } else if (s_tokenTxns[txnIndex].action == TxnAction.TransferFrom) {
            uint256 allowance = IERC20(
                s_tokenTxns[txnIndex].tokenContractAddress
            ).allowance(s_tokenTxns[txnIndex].allowanceProvider, address(this));
            if (allowance < s_tokenTxns[txnIndex].amount)
                revert MultiSigWallet__NotEnoughAllowance(allowance);

            s_tokenTxns[txnIndex].txnDetails.executed = true;

            IERC20(s_tokenTxns[txnIndex].tokenContractAddress).transferFrom(
                s_tokenTxns[txnIndex].allowanceProvider,
                s_tokenTxns[txnIndex].to,
                s_tokenTxns[txnIndex].amount
            );
        } else if (s_tokenTxns[txnIndex].action == TxnAction.Approve) {
            uint256 tokenBalance = IERC20(
                s_tokenTxns[txnIndex].tokenContractAddress
            ).balanceOf(address(this));
            if (tokenBalance < s_tokenTxns[txnIndex].amount)
                revert MultiSigWallet__NotEnoughTokens(tokenBalance);

            s_tokenTxns[txnIndex].txnDetails.executed = true;

            IERC20(s_tokenTxns[txnIndex].tokenContractAddress).approve(
                s_tokenTxns[txnIndex].to,
                s_tokenTxns[txnIndex].amount
            );
        }
    }

    /**
     * @notice Executes NFT transactions if they have enough approvals, and if they haven't been executed before.
     * @param txnIndex The array index where the transaction request details have been stored.
     */
    function executeNftTxn(uint256 txnIndex) internal {
        if (s_nftTxns[txnIndex].txnDetails.approvals < s_requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                s_nftTxns[txnIndex].txnDetails.approvals
            );
        else if (s_nftTxns[txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();

        if (s_nftTxns[txnIndex].action == TxnAction.Transfer) {
            address ownerOfNft = IERC721(s_nftTxns[txnIndex].nftContractAddress)
                .ownerOf(s_nftTxns[txnIndex].tokenId);
            if (ownerOfNft != address(this))
                revert MultiSigWallet__TokenIdNotOwned();

            s_nftTxns[txnIndex].txnDetails.executed = true;

            IERC721(s_nftTxns[txnIndex].nftContractAddress).safeTransferFrom(
                address(this),
                s_nftTxns[txnIndex].to,
                s_nftTxns[txnIndex].tokenId
            );
        } else if (s_nftTxns[txnIndex].action == TxnAction.TransferFrom) {
            address approvedFor = IERC721(
                s_nftTxns[txnIndex].nftContractAddress
            ).getApproved(s_nftTxns[txnIndex].tokenId);
            if (approvedFor != address(this))
                revert MultiSigWallet__NftNotApproved();

            s_nftTxns[txnIndex].txnDetails.executed = true;

            IERC721(s_nftTxns[txnIndex].nftContractAddress).safeTransferFrom(
                s_nftTxns[txnIndex].allowanceProvider,
                s_nftTxns[txnIndex].to,
                s_nftTxns[txnIndex].tokenId
            );
        } else if (s_nftTxns[txnIndex].action == TxnAction.Approve) {
            address nftOwner = IERC721(s_nftTxns[txnIndex].nftContractAddress)
                .ownerOf(s_nftTxns[txnIndex].tokenId);
            if (nftOwner != address(this))
                revert MultiSigWallet__NotOwnerOfNft(
                    s_nftTxns[txnIndex].tokenId
                );

            s_nftTxns[txnIndex].txnDetails.executed = true;

            IERC721(s_nftTxns[txnIndex].nftContractAddress).approve(
                s_nftTxns[txnIndex].to,
                s_nftTxns[txnIndex].tokenId
            );
        }
    }
}
