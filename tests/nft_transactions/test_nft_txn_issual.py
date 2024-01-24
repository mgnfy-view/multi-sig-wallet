import pytest
import ape


@pytest.mark.txn_issual
def test_nft_transfer_txn_issual(
    owners, not_owner, wallet, test_nft, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    txn_details = wallet.getNftTxnDetails(0)

    assert txn_details[0] == 0
    assert txn_details[1] == not_owner
    assert txn_details[2] == 1
    assert txn_details[3] == "0x0000000000000000000000000000000000000000"
    assert txn_details[4] == test_nft
    assert list(txn_details[5]) == [0, False]


@pytest.mark.txn_issual
def test_any_nft_txn_emits_txn_issued_event(owners, wallet, issue_nft_transfer_txn):
    txn_receipt = issue_nft_transfer_txn(owners[0])
    logs = txn_receipt.decode_logs(wallet.TxnIssued)

    assert len(logs) == 1
    assert logs[0].txnType == 2
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[0]


@pytest.mark.txn_issual
def test_only_owners_can_issue_nft_transfer_txn(
    not_owner, wallet, issue_nft_transfer_txn
):
    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        issue_nft_transfer_txn(not_owner)
