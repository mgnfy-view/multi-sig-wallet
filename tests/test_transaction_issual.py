import pytest
import ape


@pytest.fixture
def issue_eth_transaction_request(wallet):
    return lambda args, account: wallet.issueTransactionRequest(*args, sender=account)


@pytest.mark.transaction_issual
def test_issue_eth_transaction_request(
    owners, not_owner, wallet, web3, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])
    transaction_details = wallet.getTransactionDetails(0)

    expected_result = [0, 0, owners[0], not_owner, web3.to_wei(1, "ether"), 0, False]
    count = 0

    while count < len(expected_result):
        assert transaction_details[count] == expected_result[count]
        count += 1


@pytest.mark.transaction_issual
def test_transaction_issual_emits_event(
    owners, not_owner, wallet, issue_eth_transaction_request
):
    args = [0, 0, not_owner, "1 ether"]
    transaction_receipt = issue_eth_transaction_request(args, owners[0])

    expected_event_values = [0, owners[0]]
    logs = list(transaction_receipt.decode_logs(wallet.TransactionIssued))
    assert len(logs) == 1
    assert logs[0].transactionIndex == expected_event_values[0]
    assert logs[0].owner == expected_event_values[1]


@pytest.mark.transaction_issual
def test_transaction_count(owners, not_owner, wallet, issue_eth_transaction_request):
    args = [0, 0, not_owner, "1 ether"]
    issue_eth_transaction_request(args, owners[0])
    assert wallet.getTransactionCount(sender=owners[0]) == 1


@pytest.mark.transaction_issual
def test_transaction_issual_reverts_if_not_sent_by_owner(
    not_owner,
    wallet,
    issue_eth_transaction_request,
):
    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        args = [0, 0, not_owner, "1 ether"]
        issue_eth_transaction_request(args, not_owner)
