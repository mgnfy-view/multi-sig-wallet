import pytest
import ape


@pytest.mark.txn_approval
def test_eth_txn_approval_increases_txn_approval_count(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])
    wallet.approveTxn(0, 0, sender=owners[2])

    assert list(wallet.getEthTxnDetails(0)[2])[0] == 3


@pytest.mark.txn_approval
def test_eth_txn_approval_emits_txn_approved_event(owners, wallet, issue_eth_txn):
    issue_eth_txn(owners[0])
    txn_receipt = wallet.approveTxn(0, 0, sender=owners[1])
    logs = txn_receipt.decode_logs(wallet.TxnApproved)

    assert len(logs) == 1
    assert logs[0].txnType == 0
    assert logs[0].txnIndex == 0
    assert logs[0].by == owners[1]


@pytest.mark.txn_approval
def test_eth_txns_can_only_be_approved_by_owners(
    owners, not_owner, wallet, issue_eth_txn
):
    issue_eth_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.approveTxn(0, 0, sender=not_owner)


@pytest.mark.txn_approval
def test_eth_txn_approval_reverts_if_invalid_index_is_passed(
    owners, wallet, issue_eth_txn
):
    issue_eth_txn(owners[0])

    with ape.reverts(wallet.MultiSigWallet__InvalidIndex):
        wallet.approveTxn(0, 10, sender=owners[0])


@pytest.mark.txn_approval
def test_eth_txns_can_only_be_approved_once_by_each_owner(
    owners, wallet, issue_eth_txn
):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyApproved):
        wallet.approveTxn(0, 0, sender=owners[0])


@pytest.mark.txn_approval
def test_eth_txns_approval_reverts_if_the_txn_has_already_been_executed(
    owners, wallet, issue_eth_txn, web3
):
    issue_eth_txn(owners[0])
    wallet.approveTxn(0, 0, sender=owners[0])
    wallet.approveTxn(0, 0, sender=owners[1])
    owners[0].transfer(wallet, web3.to_wei(1, "ether"))
    wallet.executeTxn(0, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.approveTxn(0, 0, sender=owners[2])
