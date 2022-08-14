const { network } = require("hardhat")
const { DECIMALS, INITIAL_PRICE } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    if (chainId == 31337) {
        log("--------------- Local network detected! ---------------")
        log("--------------- Deploying V3 Aggregator Mock ---------------")
        const aggregatorConstructorArgs = [DECIMALS, INITIAL_PRICE]
        await deploy("MockV3Aggregator", {
            from: deployer,
            log: true,
            args: aggregatorConstructorArgs,
        })
        log("--------------- V3 Aggregator Mock deployed! ---------------")
        log("--------------- Mocks deployed! ---------------")
    }
}

module.exports.tags = ["all", "mocks", "main"]
