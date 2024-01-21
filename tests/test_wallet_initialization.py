import pytest


@pytest.mark.wallet_initialization
def test_wallet_owners_set_correctly(owners, wallet):
    for owner in owners:
        assert wallet.isOwner(owner) is True


@pytest.mark.wallet_initialization
def test_required_approvals_set_to_two(wallet):
    assert wallet.getRequiredApprovals() == 2


@pytest.mark.wallet_initialization
def test_txn_counts_set_to_zero(wallet):
    assert wallet.getEthTxnCount() == 0
    assert wallet.getTokenTxnCount() == 0
    assert wallet.getNftTxnCount() == 0
