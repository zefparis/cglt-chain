// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract CGLT is ERC20, Ownable, Pausable {
    
    address public minter;
    
    event Minted(address indexed to, uint256 amount, string txRef);
    event Burned(address indexed from, uint256 amount, string txRef);
    
    constructor(address _minter) ERC20("Congo Gaming Limited Token", "CGLT") Ownable(msg.sender) {
        minter = _minter;
    }
    
    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter");
        _;
    }
    
    function mint(address to, uint256 amount, string calldata txRef) 
        external onlyMinter whenNotPaused {
        _mint(to, amount);
        emit Minted(to, amount, txRef);
    }
    
    function burn(address from, uint256 amount, string calldata txRef) 
        external onlyMinter whenNotPaused {
        _burn(from, amount);
        emit Burned(from, amount, txRef);
    }
    
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    function setMinter(address _minter) external onlyOwner { minter = _minter; }
}
