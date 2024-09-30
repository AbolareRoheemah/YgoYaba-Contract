import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TokenModule = buildModule("TokenModule", (m) => {

  const token = m.contract("YgoYaba");

  return { token };
});

export default TokenModule;
