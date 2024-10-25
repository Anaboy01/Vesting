const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

async function main() {
    // 1. Deploy ERC20 Token
    const Token = await ethers.getContractFactory("DltToken");
    const token = await Token.deploy("DltToken", "DLT");
    const deployedToken = await token.waitForDeployment();
    console.log(`ERC20 Token deployed to: ${deployedToken.target}`);

    
    const Vesting = await ethers.getContractFactory("TokenVesting");
    const vesting = await Vesting.deploy(deployedToken.target);
    const deployedVesting = await vesting.waitForDeployment();
    console.log(`TokenVesting contract deployed to: ${deployedVesting.target}`);

   
    const [owner, beneficiary] = await ethers.getSigners();
    console.log("Owner:", owner.address);
    console.log("Beneficiary:", beneficiary.address);

    const amountToVest = ethers.parseEther("10000"); 
    const startTime = (await ethers.provider.getBlock("latest")).timestamp + 10; 
    console.log(startTime)
    const duration = 60; 

   
    await deployedToken.connect(owner).transfer(deployedVesting.target, amountToVest);
    const vestingContractBalance = await deployedToken.balanceOf(deployedVesting.target);
    console.log(`Vesting contract balance: ${vestingContractBalance} DLT`);


    await vesting.addBeneficiary(beneficiary.address, startTime, duration, amountToVest);
    console.log("Beneficiary added with vesting schedule");


    console.log("Advancing time to the start of vesting...");
    await time.increaseTo(startTime + 5); // 5 seconds after start time
    let releasableAmount = await vesting.getReleasableAmount(beneficiary.address);
    console.log(`Releasable amount for beneficiary shortly after start: ${releasableAmount} DLT`);

  
    const halfwayThroughVesting = startTime + duration ;
    console.log(halfwayThroughVesting)
    console.log("Advancing time to halfway through the vesting duration...");
    await time.increaseTo(halfwayThroughVesting);
    releasableAmount = await vesting.getReleasableAmount(beneficiary.address);
    console.log(`Releasable amount for beneficiary halfway through vesting: ${releasableAmount} DLT`);

   
    const endOfVesting = (await time.latest()) + 1000; 
    console.log("Advancing time to the end of the vesting duration...");
    await time.increaseTo(endOfVesting);
    releasableAmount = await vesting.getReleasableAmount(beneficiary.address);
    console.log(`Releasable amount for beneficiary at end of vesting: ${releasableAmount} DLT`);

   
    console.log("Claiming vested tokens...");
    await vesting.connect(beneficiary).claimTokens();
    console.log("Tokens successfully claimed by the beneficiary.");

  
    const beneficiaryBalance = await deployedToken.balanceOf(beneficiary.address);
    console.log(`Beneficiary balance after claim: ${beneficiaryBalance} DLT`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
