import pytest
import ape


@pytest.mark.transaction_issual
def test_issue_eth_transfer_transaction_request(
    owners, not_owner, wallet, issue_eth_transfer_request, web3
):
    issue_eth_transfer_request(owners[0])
    transaction_details = wallet.getTransactionDetails(0)

    expected_result = [
        0,
        0,
        owners[0],
        not_owner,
        web3.to_wei(1, "ether"),
        0,
        False,
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ]
    count = 0
    while count < len(transaction_details):
        assert transaction_details[count] == expected_result[count]
        count += 1


@pytest.mark.transaction_issual
def test_eth_transfer_transaction_issual_emits_event(
    owners, wallet, issue_eth_transfer_request
):
    transaction_receipt = issue_eth_transfer_request(owners[0])

    logs = list(transaction_receipt.decode_logs(wallet.TransactionIssued))
    expected_event_values = [0, owners[0]]
    assert len(logs) == 1
    assert logs[0].transactionIndex == expected_event_values[0]
    assert logs[0].owner == expected_event_values[1]


@pytest.mark.transaction_issual
def test_transaction_count_increases(owners, wallet, issue_eth_transfer_request):
    issue_eth_transfer_request(owners[0])
    assert wallet.getTransactionCount(sender=owners[0]) == 1


@pytest.mark.transaction_issual
def test_eth_transaction_issual_reverts_if_not_sent_by_owner(
    not_owner,
    wallet,
    issue_eth_transfer_request,
):
    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        issue_eth_transfer_request(not_owner)
