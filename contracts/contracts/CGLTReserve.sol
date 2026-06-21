// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CGLTReserve is Ownable, Pausable, ReentrancyGuard {
    
    IERC20 public cglt;
    IERC20 public usdt;
    
    uint256 public cgltPerUsdt = 2850;
    uint256 public feePercent = 50;
    uint256 public lastRate;
    uint256 public lastRateUpdate;
    
    uint256 public constant ALERT_THRESHOLD = 300;
    uint256 public constant SLOW_THRESHOLD = 700;
    uint256 public constant PAUSE_THRESHOLD = 1500;
    bool public swapSlowed = false;
    
    uint256 public maxSwapPerTx = 500 * 1e6;
    mapping(address => uint256) public dailySwapped;
    mapping(address => uint256) public lastSwapDay;
    uint256 public maxDailyPerUser = 1000 * 1e6;
    
    uint256 public emergencyReserve;
    uint256 public operationalBuffer;
    uint256 public accruedFees;
    
    event Swapped(address indexed user, string direction, uint256 amountIn, uint256 amountOut, uint256 fee);
    event RateUpdated(uint256 newRate, uint256 oldRate);
    event CircuitBreakerTriggered(uint8 level, uint256 rateChange);
    event EmergencyReserveUsed(uint256 amount);
    
    constructor(address _cglt, address _usdt) Ownable(msg.sender) {
        cglt = IERC20(_cglt);
        usdt = IERC20(_usdt);
        lastRate = cgltPerUsdt;
        lastRateUpdate = block.timestamp;
    }
    
    function swapCGLTtoUSDT(uint256 cgltAmount) 
        external nonReentrant whenNotPaused {
        
        // CGLT (18 déc) -> USDT (6 déc) : usdt6 = cgltWei / (rate * 1e12)
        uint256 usdtGross6 = cgltAmount / (cgltPerUsdt * 1e12);
        require(usdtGross6 > 0, "Amount too small");
        _checkDailyLimit(msg.sender, usdtGross6);

        uint256 fee6 = usdtGross6 * feePercent / 10000;
        uint256 usdtOut6 = usdtGross6 - fee6;

        require(usdtOut6 <= maxSwapPerTx, "Exceeds max swap");
        
        uint256 available = usdt.balanceOf(address(this)) - emergencyReserve;
        require(available >= usdtOut6, "Insufficient liquidity");
        
        accruedFees += fee6;
        cglt.transferFrom(msg.sender, address(this), cgltAmount);
        usdt.transfer(msg.sender, usdtOut6);
        
        emit Swapped(msg.sender, "CGLT->USDT", cgltAmount, usdtOut6, fee6);
    }
    
    function swapUSDTtoCGLT(uint256 usdtAmount6) 
        external nonReentrant whenNotPaused {
        
        _checkDailyLimit(msg.sender, usdtAmount6);
        require(usdtAmount6 <= maxSwapPerTx, "Exceeds max swap");
        
        uint256 fee6 = usdtAmount6 * feePercent / 10000;
        uint256 usdtNet6 = usdtAmount6 - fee6;
        // USDT (6 déc) -> CGLT (18 déc) : cgltWei = usdtNet6 * rate * 1e12
        uint256 cgltOut = usdtNet6 * cgltPerUsdt * 1e12;
        
        require(cglt.balanceOf(address(this)) >= cgltOut, "Insufficient CGLT liquidity");
        accruedFees += fee6;
        usdt.transferFrom(msg.sender, address(this), usdtAmount6);
        cglt.transfer(msg.sender, cgltOut);
        
        emit Swapped(msg.sender, "USDT->CGLT", usdtAmount6, cgltOut, fee6);
    }
    
    function updateRate(uint256 newRate) external onlyOwner {
        uint256 oldRate = cgltPerUsdt;
        uint256 change = oldRate > newRate 
            ? (oldRate - newRate) * 10000 / oldRate
            : (newRate - oldRate) * 10000 / oldRate;
        
        if (change >= PAUSE_THRESHOLD) {
            _pause();
            emit CircuitBreakerTriggered(3, change);
        } else if (change >= SLOW_THRESHOLD) {
            swapSlowed = true;
            maxSwapPerTx = 100 * 1e6;
            emit CircuitBreakerTriggered(2, change);
        } else if (change >= ALERT_THRESHOLD) {
            emit CircuitBreakerTriggered(1, change);
        }
        
        cgltPerUsdt = newRate;
        lastRate = newRate;
        lastRateUpdate = block.timestamp;
        emit RateUpdated(newRate, oldRate);
    }
    
    function resetCircuitBreaker() external onlyOwner {
        swapSlowed = false;
        maxSwapPerTx = 500 * 1e6;
        if (paused()) _unpause();
    }
    
    function _checkDailyLimit(address user, uint256 usdtAmount6) internal {
        uint256 today = block.timestamp / 1 days;
        if (lastSwapDay[user] < today) {
            dailySwapped[user] = 0;
            lastSwapDay[user] = today;
        }
        dailySwapped[user] += usdtAmount6;
        require(dailySwapped[user] <= maxDailyPerUser, "Daily limit exceeded");
    }
    
    function setEmergencyReserve(uint256 amount) external onlyOwner {
        require(amount <= usdt.balanceOf(address(this)), "Exceeds USDT balance");
        emergencyReserve = amount;
    }
    
    function withdrawFees(address to, uint256 amount) external onlyOwner {
        require(amount <= accruedFees, "Exceeds accrued fees");
        accruedFees -= amount;
        usdt.transfer(to, amount);
    }
    
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
