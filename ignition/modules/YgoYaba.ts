import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x170Bbd5A102B995517B133aa6b9275d103B9a120"

const YGYModule = buildModule("YGYModule", (m) => {

  const ygy = m.contract("YgoYabaContract", [tokenAddress]);

  return { ygy };
});

export default YGYModule;
