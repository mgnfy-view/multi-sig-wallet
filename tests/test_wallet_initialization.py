import pytest


@pytest.mark.initialization
def test_number_of_owners(wallet):
    assert wallet.getNumberOfOwners() == 3


@pytest.mark.initialization
def test_if_owners_set_correctly(owners, wallet):
    for count in range(0, 3):
        assert wallet.getOwner(count) == owners[count]


@pytest.mark.initialization
def test_ownership(owners, wallet):
    for owner in owners:
        assert wallet.isOneOfTheOwners(owner) is True


@pytest.mark.initialization
def test_required_approvals(wallet):
    assert wallet.getRequiredApprovals() == 2


@pytest.mark.initialization
def test_transaction_count_set_to_zero(wallet):
    assert wallet.getTransactionCount() == 0
