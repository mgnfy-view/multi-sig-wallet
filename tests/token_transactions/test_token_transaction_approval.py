import pytest
import ape


@pytest.mark.txn_approval
def test_token_txn_approval(owners, wallet, issue_token_transfer_txn):
    issue_token_transfer_txn(owners[0])
    wallet.approveTxn(1, 0, sender=owners[0])
    txn_details = wallet.getTokenTxnDetails(0)

    assert list(txn_details[5])[0] == 1


@pytest.mark.txn_approval
def test_each_owner_can_approve_a_txn_only_once(
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


@pytest.mark.txn_approval
def test_token_txn_approval_emits_approval_event(
    owners, wallet, issue_token_transfer_txn
):
    issue_token_transfer_txn(owners[0])
    txn_receipt = wallet.approveTxn(1, 0, sender=owners[0])

    logs = txn_receipt.decode_logs(wallet.TxnApproved)

    assert len(logs) == 1
    assert logs[0].txnType == 1
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]
