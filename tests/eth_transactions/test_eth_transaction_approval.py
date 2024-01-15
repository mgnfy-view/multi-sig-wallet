import pytest
import ape


@pytest.mark.transaction_approval
def test_only_owners_can_approve_transactions(
    owners, not_owner, wallet, issue_eth_transfer_transaction_request
):
    issue_eth_transfer_transaction_request(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.approveTransaction(0, sender=not_owner)


@pytest.mark.transaction_approval
def test_transaction_approval_by_owners_increases_approval_count(
    owners, wallet, issue_eth_transfer_transaction_request
):
    issue_eth_transfer_transaction_request(owners[0])

    wallet.approveTransaction(0, sender=owners[0])

    assert wallet.getTransactionDetails(0)[5] == 1


@pytest.mark.transaction_approval
def test_owner_can_approve_a_transaction_only_once(
    owners, wallet, issue_eth_transfer_transaction_request
):
    issue_eth_transfer_transaction_request(owners[0])

    wallet.approveTransaction(0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TransactionAlreadyApprovedByOwner):
        wallet.approveTransaction(0, sender=owners[0])


@pytest.mark.transaction_approval
def test_transaction_approval_emits_transaction_approved_event(
    owners, wallet, issue_eth_transfer_transaction_request
):
    issue_eth_transfer_transaction_request(owners[0])
    transaction_receipt = wallet.approveTransaction(0, sender=owners[0])

    expected_event_values = [0, owners[0]]
    logs = list(transaction_receipt.decode_logs(wallet.TransactionApproved))
    assert len(logs) == 1
    assert logs[0].transactionIndex == expected_event_values[0]
    assert logs[0].owner == expected_event_values[1]
