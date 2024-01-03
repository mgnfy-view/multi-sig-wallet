require("hardhat-docgen");

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.20",
            },
        ],
    },
    paths: {
        sources: "./contracts/src",
    },
    docgen: {
        path: "./docs",
        clear: true,
        runOnCompile: false,
    },
};
