import pytest
import ape

# the approval function works with the indexes at which the transaction details have
# been stored, so testing it for one of the transaction actions is sufficient in most cases


@pytest.mark.txn_approval
def test_any_token_txn_approval_increases_approval_count(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    txn_details = wallet.getTokenTxnDetails(0)

    assert list(txn_details[5])[0] == 1


@pytest.mark.txn_approval
def test_any_token_txn_approval_emits_approval_event(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    txn_receipt = wallet.approveTxn(1, 0, sender=owners[0])
    logs = txn_receipt.decode_logs(wallet.TxnApproved)

    assert len(logs) == 1
    assert logs[0].txnType == 1
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]


@pytest.mark.txn_approval
def test_token_txns_can_only_be_approved_by_owners(
    owners, not_owner, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.approveTxn(1, 0, sender=not_owner)


@pytest.mark.txn_approval
def test_token_txn_approval_reverts_if_invalid_index_is_passed(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidIndex):
        wallet.approveTxn(1, 10, sender=owners[0])


@pytest.mark.txn_approval
def test_each_owner_can_approve_a_token_txn_only_once(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyApproved):
        wallet.approveTxn(1, 0, sender=owners[0])


@pytest.mark.txn_approval
def test_token_txn_approval_reverts_if_the_txn_has_already_been_executed(
    owners, wallet, token_contract, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    wallet.approveTxn(1, 0, sender=owners[1])
    token_contract.transfer(wallet, "2 ether", sender=owners[0])
    wallet.executeTxn(1, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.approveTxn(1, 0, sender=owners[2])
