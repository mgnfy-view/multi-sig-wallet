/** We'll follow the layout given below for our contract
        1. Type declarations
        2. State variables
        3. Events
        4. Errors
        5. Modifiers
        6. Functions
           a. External
           b. Public
           c. Internal
           d. Private
*/

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
        Transfer,
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
        address allowanceFrom;
        address tokenContractAddress;
        TxnDetails txnDetails;
    }

    struct NftTxn {
        TxnAction action;
        address to;
        uint256 tokenId;
        address allowanceFrom;
        address nftContractAddress;
        TxnDetails txnDetails;
    }

    mapping(address => bool) private owners;
    uint256 private requiredApprovals;

    EthTxn[] private ethTxns;
    uint256 private ethTxnCount;
    mapping(uint256 => mapping(address => bool)) private ethTxnApprovals;

    TokenTxn[] private tokenTxns;
    uint256 private tokenTxnCount;
    mapping(uint256 => mapping(address => bool)) private tokenTxnApprovals;

    NftTxn[] private nftTxns;
    uint256 private nftTxnCount;
    mapping(uint256 => mapping(address => bool)) private nftTxnApprovals;

    event TxnIssued(TxnType txnType, uint256 txnIndex, address by);
    event TxnApproved(TxnType txnType, uint256 txnIndex, address by);
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
        if (!owners[msg.sender]) revert MultiSigWallet__NotOneOfTheOwners();
        _;
    }

    modifier onlyValidTxnIndex(TxnType _txnType, uint256 _txnIndex) {
        if (_txnType == TxnType.ETH) {
            if (_txnIndex > ethTxns.length)
                revert MultiSigWallet__InvalidIndex();
        } else if (_txnType == TxnType.Token) {
            if (_txnIndex > tokenTxns.length)
                revert MultiSigWallet__InvalidIndex();
        } else if (_txnType == TxnType.NFT) {
            if (_txnIndex > nftTxns.length)
                revert MultiSigWallet__InvalidIndex();
        }
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        if (_requiredApprovals > _owners.length)
            revert MultiSigWallet__InvalidRequiredApprovals();

        for (uint32 count = 0; count < _owners.length; count++) {
            owners[_owners[count]] = true;
        }

        requiredApprovals = _requiredApprovals;
        ethTxnCount = 0;
        tokenTxnCount = 0;
        nftTxnCount = 0;
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function issueEthTxn(
        address _to,
        uint256 _amount
    ) external onlyOneOfTheOwners {
        ethTxnCount++;

        EthTxn memory newTxn = EthTxn({
            to: _to,
            amount: _amount,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        ethTxns.push(newTxn);

        emit TxnIssued(TxnType.ETH, ethTxnCount - 1, msg.sender);
    }

    function issueTokenTransferTxn(
        address _to,
        uint256 _amount,
        address _tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.Transfer,
            _to,
            _amount,
            address(0),
            _tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, tokenTxnCount - 1, msg.sender);
    }

    function issueTokenTransferFromTxn(
        address _to,
        uint256 _amount,
        address _from,
        address _tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.TransferFrom,
            _to,
            _amount,
            _from,
            _tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, tokenTxnCount - 1, msg.sender);
    }

    function issueTokenApprovalTxn(
        address _to,
        uint256 _amount,
        address _tokenContractAddress
    ) external onlyOneOfTheOwners {
        issueTokenTxnHelper(
            TxnAction.Approve,
            _to,
            _amount,
            address(0),
            _tokenContractAddress
        );

        emit TxnIssued(TxnType.Token, tokenTxnCount - 1, msg.sender);
    }

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

        emit TxnIssued(TxnType.NFT, nftTxnCount - 1, msg.sender);
    }

    function issueNftTransferFromTxn(
        address _to,
        address _from,
        uint256 _tokenId,
        address _nftContractAddress
    ) external onlyOneOfTheOwners {
        issueNftTxnHelper(
            TxnAction.TransferFrom,
            _to,
            _tokenId,
            _from,
            _nftContractAddress
        );

        emit TxnIssued(TxnType.NFT, nftTxnCount - 1, msg.sender);
    }

    function issueNftApprovalTxn(
        address _to,
        uint256 _tokenId,
        address _nftContractAddress
    ) external onlyOneOfTheOwners {
        issueNftTxnHelper(
            TxnAction.Approve,
            _to,
            _tokenId,
            address(0),
            _nftContractAddress
        );

        emit TxnIssued(TxnType.NFT, nftTxnCount - 1, msg.sender);
    }

    function approveTxn(
        TxnType _txnType,
        uint256 _txnIndex
    ) external onlyOneOfTheOwners onlyValidTxnIndex(_txnType, _txnIndex) {
        if (_txnType == TxnType.ETH) {
            if (ethTxnApprovals[_txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (ethTxns[_txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            ethTxnApprovals[_txnIndex][msg.sender] = true;
            ethTxns[_txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.ETH, _txnIndex, msg.sender);
        } else if (_txnType == TxnType.Token) {
            if (tokenTxnApprovals[_txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (tokenTxns[_txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            tokenTxnApprovals[_txnIndex][msg.sender] = true;
            tokenTxns[_txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.Token, _txnIndex, msg.sender);
        } else if (_txnType == TxnType.NFT) {
            if (nftTxnApprovals[_txnIndex][msg.sender])
                revert MultiSigWallet__TxnAlreadyApproved();
            if (nftTxns[_txnIndex].txnDetails.executed)
                revert MultiSigWallet__TxnAlreadyExecuted();

            nftTxnApprovals[_txnIndex][msg.sender] = true;
            nftTxns[_txnIndex].txnDetails.approvals++;

            emit TxnApproved(TxnType.NFT, _txnIndex, msg.sender);
        }
    }

    function executeTxn(
        TxnType _txnType,
        uint256 _txnIndex
    ) external onlyOneOfTheOwners onlyValidTxnIndex(_txnType, _txnIndex) {
        if (_txnType == TxnType.ETH) {
            executeEthTxn(_txnIndex);
            emit TxnExecuted(TxnType.ETH, _txnIndex, msg.sender);
        } else if (_txnType == TxnType.Token) {
            executeTokenTxn(_txnIndex);
            emit TxnExecuted(TxnType.Token, _txnIndex, msg.sender);
        } else if (_txnType == TxnType.NFT) {
            executeNftTxn(_txnIndex);
            emit TxnExecuted(TxnType.NFT, _txnIndex, msg.sender);
        }
    }

    function isOwner(address _account) public view returns (bool) {
        return owners[_account];
    }

    function getRequiredApprovals() public view returns (uint256) {
        return requiredApprovals;
    }

    function getEthTxnCount() public view returns (uint256) {
        return ethTxnCount;
    }

    function getTokenTxnCount() public view returns (uint256) {
        return tokenTxnCount;
    }

    function getNftTxnCount() public view returns (uint256) {
        return nftTxnCount;
    }

    function getEthTxnDetails(
        uint256 _txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.ETH, _txnIndex)
        returns (EthTxn memory)
    {
        return ethTxns[_txnIndex];
    }

    function getTokenTxnDetails(
        uint256 _txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.Token, _txnIndex)
        returns (TokenTxn memory)
    {
        return tokenTxns[_txnIndex];
    }

    function getNftTxnDetails(
        uint256 _txnIndex
    )
        public
        view
        onlyValidTxnIndex(TxnType.NFT, _txnIndex)
        returns (NftTxn memory)
    {
        return nftTxns[_txnIndex];
    }

    function issueTokenTxnHelper(
        TxnAction _action,
        address _to,
        uint256 _amount,
        address _from,
        address _tokenContractAddress
    ) internal {
        tokenTxnCount++;

        TokenTxn memory newTxn = TokenTxn({
            action: _action,
            to: _to,
            amount: _amount,
            allowanceFrom: _from,
            tokenContractAddress: _tokenContractAddress,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        tokenTxns.push(newTxn);
    }

    function issueNftTxnHelper(
        TxnAction _action,
        address _to,
        uint256 _tokenId,
        address _from,
        address _nftContractAddress
    ) internal {
        nftTxnCount++;

        NftTxn memory newTxn = NftTxn({
            action: _action,
            to: _to,
            tokenId: _tokenId,
            allowanceFrom: _from,
            nftContractAddress: _nftContractAddress,
            txnDetails: TxnDetails({approvals: 0, executed: false})
        });
        nftTxns.push(newTxn);
    }

    function executeEthTxn(uint256 _txnIndex) internal {
        if (ethTxns[_txnIndex].txnDetails.approvals < requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                ethTxns[_txnIndex].txnDetails.approvals
            );
        else if (ethTxns[_txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();
        else if (address(this).balance < ethTxns[_txnIndex].amount)
            revert MultiSigWallet__NotEnoughEtH(address(this).balance);

        ethTxns[_txnIndex].txnDetails.executed = true;

        (bool success, ) = ethTxns[_txnIndex].to.call{
            value: ethTxns[_txnIndex].amount
        }("");
        if (!success) revert MultiSigWallet__TxnFailed();
    }

    function executeTokenTxn(uint256 _txnIndex) internal {
        // test transferFrom and approve in pytest
        if (tokenTxns[_txnIndex].txnDetails.approvals < requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                tokenTxns[_txnIndex].txnDetails.approvals
            );
        else if (tokenTxns[_txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();

        if (tokenTxns[_txnIndex].action == TxnAction.Transfer) {
            uint256 tokenBalance = IERC20(
                tokenTxns[_txnIndex].tokenContractAddress
            ).balanceOf(address(this));
            if (tokenBalance < tokenTxns[_txnIndex].amount)
                revert MultiSigWallet__NotEnoughTokens(tokenBalance);

            tokenTxns[_txnIndex].txnDetails.executed = true;

            IERC20(tokenTxns[_txnIndex].tokenContractAddress).transfer(
                tokenTxns[_txnIndex].to,
                tokenTxns[_txnIndex].amount
            );
        } else if (tokenTxns[_txnIndex].action == TxnAction.TransferFrom) {
            uint256 allowance = IERC20(
                tokenTxns[_txnIndex].tokenContractAddress
            ).allowance(tokenTxns[_txnIndex].allowanceFrom, address(this));
            if (allowance < tokenTxns[_txnIndex].amount)
                revert MultiSigWallet__NotEnoughAllowance(allowance);

            tokenTxns[_txnIndex].txnDetails.executed = true;

            IERC20(tokenTxns[_txnIndex].tokenContractAddress).transferFrom(
                tokenTxns[_txnIndex].allowanceFrom,
                tokenTxns[_txnIndex].to,
                tokenTxns[_txnIndex].amount
            );
        } else if (tokenTxns[_txnIndex].action == TxnAction.Approve) {
            uint256 tokenBalance = IERC20(
                tokenTxns[_txnIndex].tokenContractAddress
            ).balanceOf(address(this));
            if (tokenBalance < tokenTxns[_txnIndex].amount)
                revert MultiSigWallet__NotEnoughTokens(tokenBalance);

            tokenTxns[_txnIndex].txnDetails.executed = true;

            IERC20(tokenTxns[_txnIndex].tokenContractAddress).approve(
                tokenTxns[_txnIndex].to,
                tokenTxns[_txnIndex].amount
            );
        }
    }

    function executeNftTxn(uint256 _txnIndex) internal {
        if (nftTxns[_txnIndex].txnDetails.approvals < requiredApprovals)
            revert MultiSigWallet__NotEnoughApprovalsGiven(
                nftTxns[_txnIndex].txnDetails.approvals
            );
        else if (nftTxns[_txnIndex].txnDetails.executed)
            revert MultiSigWallet__TxnAlreadyExecuted();

        if (nftTxns[_txnIndex].action == TxnAction.Transfer) {
            address ownerOfNft = IERC721(nftTxns[_txnIndex].nftContractAddress)
                .ownerOf(nftTxns[_txnIndex].tokenId);
            if (ownerOfNft != address(this))
                revert MultiSigWallet__TokenIdNotOwned();

            nftTxns[_txnIndex].txnDetails.executed = true;

            IERC721(nftTxns[_txnIndex].nftContractAddress).safeTransferFrom(
                address(this),
                nftTxns[_txnIndex].to,
                nftTxns[_txnIndex].tokenId
            );
        } else if (nftTxns[_txnIndex].action == TxnAction.TransferFrom) {
            address approvedFor = IERC721(nftTxns[_txnIndex].nftContractAddress)
                .getApproved(nftTxns[_txnIndex].tokenId);
            if (approvedFor != address(this))
                revert MultiSigWallet__NftNotApproved();

            nftTxns[_txnIndex].txnDetails.executed = true;

            IERC721(nftTxns[_txnIndex].nftContractAddress).safeTransferFrom(
                nftTxns[_txnIndex].allowanceFrom,
                nftTxns[_txnIndex].to,
                nftTxns[_txnIndex].tokenId
            );
        } else if (nftTxns[_txnIndex].action == TxnAction.Approve) {
            address nftOwner = IERC721(nftTxns[_txnIndex].nftContractAddress)
                .ownerOf(nftTxns[_txnIndex].tokenId);
            if (nftOwner != address(this))
                revert MultiSigWallet__NotOwnerOfNft(
                    nftTxns[_txnIndex].tokenId
                );

            nftTxns[_txnIndex].txnDetails.executed = true;

            IERC721(nftTxns[_txnIndex].nftContractAddress).approve(
                nftTxns[_txnIndex].to,
                nftTxns[_txnIndex].tokenId
            );
        }
    }
}
