const fs = require("fs")
const { network } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let priceFeedAddress
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : network.config.blockConfirmations

    if (chainId == 31337) {
        const aggregator = await deployments.get("MockV3Aggregator")
        priceFeedAddress = aggregator.address
    } else {
        priceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    }
    log("--------------- Deploying Dynamic SVG NFT Contract... ---------------")

    const lowSvg = await fs.readFileSync("./images/frown.svg", { encoding: "utf-8" })
    const highSvg = await fs.readFileSync("./images/happy.svg", { encoding: "utf-8" })
    const args = [lowSvg, highSvg, priceFeedAddress]
    const dynamicSvgNft = await deploy("DynamicSvgNft", {
        from: deployer,
        log: true,
        args: args,
        waitConfirmations: waitBlockConfirmations,
    })

    log("--------------- Dynamic SVG NFT Contract Deployed! ---------------")

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("--------------- Verifying!... --------------- ")
        await verify(dynamicSvgNft.address, args)
        log("--------------- Veryfy process finished! ---------------")
    }
}

module.exports.tags = ["all", "dynamicsvg", "main"]
