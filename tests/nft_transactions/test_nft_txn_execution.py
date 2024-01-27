import pytest
import ape


@pytest.mark.txn_execution
def test_nft_transfer_txn_execution(
    owners, not_owner, wallet, test_nft, issue_nft_transfer_txn
):
    test_nft.mintNFT(wallet, sender=owners[0])
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])
    wallet.executeTxn(2, 0, sender=owners[0])

    assert test_nft.ownerOf(1) == not_owner


@pytest.mark.txn_execution
def test_nft_transfer_txn_reverts_if_the_wallet_does_not_own_the_nft(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__TokenIdNotOwned):
        wallet.executeTxn(2, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_nft_transfer_from_txn_execution(
    owners, not_owner, wallet, test_nft, issue_nft_transfer_from_txn
):
    test_nft.mintNFT(owners[0], sender=owners[0])
    test_nft.approve(wallet, 1, sender=owners[0])
    issue_nft_transfer_from_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])
    wallet.executeTxn(2, 0, sender=owners[0])

    assert test_nft.ownerOf(1) == not_owner


@pytest.mark.txn_execution
def test_nft_transfer_from_txn_execution_reverts_if_the_nft_is_not_approved_for_the_wallet(
    owners, wallet, test_nft, issue_nft_transfer_from_txn
):
    test_nft.mintNFT(owners[0], sender=owners[0])
    issue_nft_transfer_from_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NftNotApproved):
        wallet.executeTxn(2, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_nft_approval_txn_execution(
    owners, not_owner, wallet, test_nft, issue_nft_approval_txn
):
    test_nft.mintNFT(wallet, sender=owners[0])
    issue_nft_approval_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])
    wallet.executeTxn(2, 0, sender=owners[0])

    assert test_nft.getApproved(1) == not_owner


@pytest.mark.txn_execution
def test_nft_approval_txn_execution_reverts_if_the_wallet_does_not_hold_the_nft(
    owners, wallet, issue_nft_approval_txn
):
    issue_nft_approval_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotOwnerOfNft):
        wallet.executeTxn(2, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_nft_txns_can_only_be_executed_by_owners(
    owners, not_owner, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__NotOneOfTheOwners):
        wallet.executeTxn(2, 0, sender=not_owner)


@pytest.mark.txn_execution
def test_nft_txn_execution_reverts_if_invalid_index_is_passed(
    owners, wallet, issue_nft_transfer_txn
):
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])

    with ape.reverts(wallet.MultiSigWallet__InvalidIndex):
        wallet.executeTxn(2, 10, sender=owners[0])


@pytest.mark.txn_execution
def test_nft_txn_reverts_if_not_enough_approvals_have_been_given(
    owners, wallet, test_nft, issue_nft_transfer_txn
):
    test_nft.mintNFT(wallet, sender=owners[0])
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__NotEnoughApprovalsGiven):
        wallet.executeTxn(2, 0, sender=owners[0])


@pytest.mark.txn_execution
def test_nft_txn_execution_reverts_if_the_txn_has_already_been_executed(
    owners, wallet, test_nft, issue_nft_transfer_txn
):
    test_nft.mintNFT(wallet, sender=owners[0])
    issue_nft_transfer_txn(owners[0])
    wallet.approveTxn(2, 0, sender=owners[0])
    wallet.approveTxn(2, 0, sender=owners[1])
    wallet.executeTxn(2, 0, sender=owners[0])

    with ape.reverts(wallet.MultiSigWallet__TxnAlreadyExecuted):
        wallet.executeTxn(2, 0, sender=owners[0])
