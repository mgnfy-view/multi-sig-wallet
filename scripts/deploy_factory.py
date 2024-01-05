from ape import accounts, networks, project


def main():
    """
    The factory contract is the preferred to deploy your
    multi-sig wallet. It keeps the track of the owners of
    a wallet and provides some useful functions to check
    your wallet's details
    """

    account_1 = None
    publish_source_code = True

    # use test accounts if wwaye are on a local chain such
    # as hardhat
    print("Getting accounts")
    if networks.active_provider.chain_id in (1337, 31337):
        account_1 = accounts.test_accounts[0]
        publish_source_code = False
    else:
        # here, use the alias of the account that you have
        # imported with ape
        account_1 = accounts.load("Crosstalk")

    print("Deploying factory contract..")
    factory = project.Factory.deploy(sender=account_1, publish=publish_source_code)

    # print the receipt after deployment
    print("Here's the receipt:")
    for key, value in factory.receipt:
        print(key, value)
