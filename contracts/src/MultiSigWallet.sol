/** We'll follow the layout given below for our contract
        1. Type declarations
        2. State variables
        3. Events
        4. Errors
        5. Modifiers
        6. Functionstransaction
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract MultiSigWallet {
    enum TransactionTypes {
        ETH,
        Token,
        NFT
    }

    enum TransactionActions {
        Transfer,
        TransferFrom,
        Approve,
        Burn
    }

    struct Transaction {
        TransactionTypes transactionType;
        TransactionActions action;
        address issuer;
        address to;
        uint256 amountOrTokenId;
        uint256 approvalsGiven;
        bool executed;
        address tokenContract;
        address allowanceOwner;
    }

    address[] private owners;
    mapping(address => bool) private isOwner;
    uint256 private requiredApprovals;
    Transaction[] private transactions;
    uint256 private transactionCount;
    mapping(uint256 => mapping(address => bool)) private transactionApproval;

    event TransactionIssued(
        uint256 indexed transactionIndex,
        address indexed owner
    );
    event TransactionApproved(
        uint256 indexed transactionIndex,
        address indexed owner
    );
    event TransactionExecuted(
        uint256 indexed transactionIndex,
        address indexed owner
    );

    error MultiSigWallet__NotOneOfTheOwners();
    error MultiSigWallet__InvalidRequiredApprovals();
    error MultiSigWallet__InvalidTransactionRequest();
    error MultiSigWallet__InvalidTransactionIndex();
    error MultiSigWallet__TransactionAlreadyApprovedByOwner();
    error MultiSigWallet__NotEnoughApprovalsGiven();
    error MultiSigWallet__TransactionAlreadyExecuted();
    error MultiSigWallet__NotEnoughEtH(uint256 balance);
    error MultiSigWallet__TransactionFailed();
    error MultiSigWallet__InvalidIndex();
    error MultiSigWallet__NotEnoughTokens(uint256 tokenBalance);

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert MultiSigWallet__NotOneOfTheOwners();
        _;
    }

    modifier onlyValidtransactionIndex(uint256 _transactionIndex) {
        if (_transactionIndex > transactionCount)
            revert MultiSigWallet__InvalidTransactionIndex();
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        if (_requiredApprovals > _owners.length)
            revert MultiSigWallet__InvalidRequiredApprovals();

        for (uint32 count = 0; count < _owners.length; count++) {
            owners.push(_owners[count]);
            isOwner[_owners[count]] = true;
        }

        requiredApprovals = _requiredApprovals;
        transactionCount = 0;
    }

    receive() external payable {}

    function issueETHTransferTransactionRequest(
        address _to,
        uint256 _amount
    ) public onlyOwner {
        Transaction memory newTransaction = Transaction({
            transactionType: TransactionTypes.ETH,
            action: TransactionActions.Transfer,
            issuer: msg.sender,
            to: _to,
            amountOrTokenId: _amount,
            approvalsGiven: 0,
            executed: false,
            tokenContract: address(0),
            allowanceOwner: address(0)
        });

        transactions.push(newTransaction);

        emit TransactionIssued(transactionCount, msg.sender);

        transactionCount++;
    }

    function issueTokenTransferTransactionRequest(
        address _tokenContract,
        TransactionActions _transactionAction,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        Transaction memory newTransaction = Transaction({
            transactionType: TransactionTypes.Token,
            action: _transactionAction,
            issuer: msg.sender,
            to: _to,
            amountOrTokenId: _amount,
            approvalsGiven: 0,
            executed: false,
            tokenContract: _tokenContract,
            allowanceOwner: address(0)
        });

        transactions.push(newTransaction);

        emit TransactionIssued(transactionCount, msg.sender);

        transactionCount++;
    }

    function approveTransaction(
        uint256 _transactionIndex
    ) public onlyOwner onlyValidtransactionIndex(_transactionIndex) {
        if (transactionApproval[_transactionIndex][msg.sender])
            revert MultiSigWallet__TransactionAlreadyApprovedByOwner();

        transactionApproval[_transactionIndex][msg.sender] = true;
        transactions[_transactionIndex].approvalsGiven++;

        emit TransactionApproved(_transactionIndex, msg.sender);
    }

    function executeTransaction(
        uint256 _transactionIndex
    ) public onlyOwner onlyValidtransactionIndex(_transactionIndex) {
        if (transactions[_transactionIndex].approvalsGiven < requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven();
        if (transactions[_transactionIndex].executed)
            revert MultiSigWallet__TransactionAlreadyExecuted();

        if (
            transactions[_transactionIndex].transactionType ==
            TransactionTypes.ETH
        ) executeETHTransaction(_transactionIndex);
        else if (
            transactions[_transactionIndex].transactionType ==
            TransactionTypes.Token
        ) executeTokenTransaction(_transactionIndex);

        emit TransactionExecuted(_transactionIndex, msg.sender);
    }

    function getOwner(uint256 _index) public view returns (address) {
        if (_index > owners.length - 1) revert MultiSigWallet__InvalidIndex();
        return owners[_index];
    }

    function isOneOfTheOwners(address _address) public view returns (bool) {
        return isOwner[_address];
    }

    function getNumberOfOwners() public view returns (uint256) {
        return owners.length;
    }

    function getRequiredApprovals() public view returns (uint256) {
        return requiredApprovals;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }

    function getTransactionDetails(
        uint256 _transactionIndex
    )
        public
        view
        onlyValidtransactionIndex(_transactionIndex)
        returns (Transaction memory)
    {
        return transactions[_transactionIndex];
    }

    function checkTransactionApproval(
        address _owner,
        uint256 _transactionIndex
    ) public view onlyValidtransactionIndex(_transactionIndex) returns (bool) {
        return transactionApproval[_transactionIndex][_owner];
    }

    function executeETHTransaction(uint256 _transactionIndex) private {
        if (
            address(this).balance <
            transactions[_transactionIndex].amountOrTokenId
        ) revert MultiSigWallet__NotEnoughEtH(address(this).balance);

        (bool success, ) = transactions[_transactionIndex].to.call{
            value: transactions[_transactionIndex].amountOrTokenId
        }("");
        if (!success) revert MultiSigWallet__TransactionFailed();
        transactions[_transactionIndex].executed = true;
    }

    function executeTokenTransaction(uint256 _transactionIndex) private {
        address tokenContract = transactions[_transactionIndex].tokenContract;

        if (
            transactions[_transactionIndex].action ==
            TransactionActions.Transfer
        ) {
            uint256 tokenBalance = IERC20(tokenContract).balanceOf(
                address(this)
            );

            if (tokenBalance < transactions[_transactionIndex].amountOrTokenId)
                revert MultiSigWallet__NotEnoughTokens(tokenBalance);

            IERC20(tokenContract).transfer(
                transactions[_transactionIndex].to,
                transactions[_transactionIndex].amountOrTokenId
            );
        }
    }
}
