const { ethers } = require("hardhat")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deployer } = await getNamedAccounts()
    const dynamicSvgNft = await ethers.getContract("DynamicSvgNft", deployer)
    const highValue = ethers.utils.parseEther("4000")
    const dynamicMintTx = await dynamicSvgNft.mintNft(highValue)
    await dynamicMintTx.wait(1)
    console.log(`Dynamic SVG NFT index 0 tokenURI: ${await dynamicSvgNft.tokenURI}`)
}
module.exports.tags = ["all", "mint"]
