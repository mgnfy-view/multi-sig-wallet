import pytest
import ape

# since approval function uses indexes, it is sufficient to test it for one type
# of transaction action


@pytest.mark.txn_approval
def test_nft_txn_approval_increases_approval_count(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    txn_details = wallet.getNftTxnDetails(0)

    assert list(txn_details[5])[0] == 1


@pytest.mark.txn_approval
def test_nft_txn_approval_emits_txn_approved_event(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    txn_receipt = wallet.approveTxn(2, 0, sender=owners[0])
    logs = txn_receipt.decode_logs(wallet.TxnApproved)

    assert len(logs) == 1
    assert logs[0].txnType == 2
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]


@pytest.mark.txn_approval
def test_nft_txns_can_only_be_approved_by_owners(
    owners, not_owner, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.approveTxn(2, 0, sender=not_owner)


@pytest.mark.txn_approval
def test_nft_txn_approval_reverts_if_invalid_index_is_passed(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidIndex):
        wallet.approveTxn(2, 10, sender=owners[0])


@pytest.mark.txn_approval
def test_nft_txns_can_only_be_approved_once_by_each_owner(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyApproved):
        wallet.approveTxn(2, 0, sender=owners[0])


@pytest.mark.txn_approval
def test_nft_txn_approval_reverts_if_the_txn_has_already_been_executed(
    owners, wallet, test_nft, issue_nft_transfer_txn
):
    test_nft.mintNFT(wallet, sender=owners[0])
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])
    wallet.executeTxn(2, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.approveTxn(2, 0, sender=owners[2])
