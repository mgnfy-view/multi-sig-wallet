import pytest


@pytest.mark.txn_issual
def test_token_transfer_txn_issual(
    owners, not_owner, wallet, token_contract, issue_token_transfer_txn, web3
):
    issue_token_transfer_txn(owners[0])
    txn_details = wallet.getTokenTxnDetails(0)

    assert txn_details[0] == 0
    assert txn_details[1] == not_owner
    assert txn_details[2] == web3.to_wei(1, "ether")
    assert txn_details[3] == "0x0000000000000000000000000000000000000000"
    assert txn_details[4] == token_contract
    assert list(txn_details[5]) == [0, False]


@pytest.mark.txn_issual
def test_token_transfer_from_txn_issual(
    owners, not_owner, wallet, token_contract, issue_token_transfer_from_txn, web3
):
    issue_token_transfer_from_txn(owners[0])
    txn_details = wallet.getTokenTxnDetails(0)

    assert txn_details[0] == 1
    assert txn_details[1] == not_owner
    assert txn_details[2] == web3.to_wei(1, "ether")
    assert txn_details[3] == owners[0]
    assert txn_details[4] == token_contract


@pytest.mark.txn_issual
def test_token_approval_txn_issual(
    owners, not_owner, wallet, token_contract, issue_token_approval_txn, web3
):
    issue_token_approval_txn(owners[0])
    txn_details = wallet.getTokenTxnDetails(0)

    assert txn_details[0] == 2
    assert txn_details[1] == not_owner
    assert txn_details[2] == web3.to_wei(1, "ether")
    assert txn_details[4] == token_contract


@pytest.mark.txn_issual
def test_any_token_txn_issual_emits_event(owners, wallet, issue_token_approval_txn):
    txn_receipt = issue_token_approval_txn(owners[0])

    logs = txn_receipt.decode_logs(wallet.TxnIssued)

    assert len(logs) == 1
    assert logs[0].txnType == 1
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]
