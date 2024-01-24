import pytest
import ape


@pytest.mark.txn_issual
def test_eth_txn_issual(owners, not_owner, wallet, issue_eth_txn, web3):
    issue_eth_txn(owners[0])
    txn_details = wallet.getEthTxnDetails(0)

    assert txn_details[0] == not_owner
    assert txn_details[1] == web3.to_wei(1, "ether")
    assert list(txn_details[2]) == [0, False]


@pytest.mark.txn_issual
def test_eth_txn_issual_increments_eth_txn_count(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])

    assert wallet.getEthTxnCount() == 1


@pytest.mark.txn_issual
def test_eth_txn_issual_emits_txn_issued_event(owners, wallet, issue_eth_txn):
    txn_receipt = issue_eth_txn(owners[0])

    logs = txn_receipt.decode_logs(wallet.TxnIssued)
    assert len(logs) == 1
    assert logs[0].txnType == 0
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]


@pytest.mark.txn_issual
def test_only_owners_can_issue_eth_txns(not_owner, wallet, issue_eth_txn):
    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        issue_eth_txn(not_owner)
