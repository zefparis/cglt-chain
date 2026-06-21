// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockUSDT is ERC20, Ownable {
    constructor() ERC20("Tether USD", "USDT") Ownable(msg.sender) {
        // Mint 1,000,000 USDT au deployer pour bootstrapper le pool
        _mint(msg.sender, 1_000_000 * 10**6);
    }

    function decimals() public pure override returns (uint8) {
        return 6; // USDT utilise 6 décimales
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
