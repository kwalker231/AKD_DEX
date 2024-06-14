// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract SwappableToken is ERC20 {
//     address private _dex;

//     constructor(
//         //address dexInstance,
//         string memory name,
//         string memory symbol,
//         uint256 initialSupply
//     ) ERC20(name, symbol) {
//         _mint(msg.sender, initialSupply);
//         //_dex = dexInstance;
//     }

//     function approve(address spender, uint256 amount) public override returns (bool) {
//         //require(msg.sender != _dex, "InvalidApprover");
//         return super.approve(spender, amount);
//     }
// }


pragma solidity ^0.8.20;

library safeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address owner, address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract DXTK is IERC20 {
    mapping(address => uint256) public accBalance;
    mapping(address => mapping(address => uint256)) public accAllowance;
    string public name = "DX-token";
    string public symbol = "DXTK";
    uint256 public totalSupply = 100000000000000000000000; // 100,000 DXTK
    uint8 public decimals = 18;

    constructor() {
        accBalance[msg.sender] = totalSupply; // Allocate initial supply to contract creator
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(amount <= accBalance[msg.sender], "Insufficient balance");
        accBalance[msg.sender] -= amount;
        accBalance[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address owner, address spender, uint256 amount) external returns (bool) {
        accAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(amount <= accBalance[sender], "Insufficient balance");
        require(amount <= accAllowance[sender][msg.sender], "Allowance exceeded");

        accAllowance[sender][msg.sender] -= amount;
        accBalance[sender] -= amount;
        accBalance[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return accAllowance[owner][spender];
    }

    function getAddress() external view returns (address) {
        return address(this);
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return accBalance[owner];
    }

    function _mint(address to, uint256 amount) internal {
        accBalance[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        accBalance[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract Dex {
    using safeMath for uint256;
    IERC20 public dexToken;

    constructor() {
        dexToken = new DXTK();
    }

    function buy() payable public {
        uint256 buyAmount = msg.value;
        uint256 dexBalance = dexToken.balanceOf(address(this));
        require(buyAmount <= dexBalance, "The purchase amount exceeds the amount available in reserve.");
        require(buyAmount > 0, "Please spend some MATIC to buy");
        dexToken.transfer(msg.sender, buyAmount);
    }

    function sell(uint256 amount) public {
        uint256 allowance = dexToken.allowance(msg.sender, address(this));
        emit DebugMessage("Allowance check before sell", allowance);

        require(allowance >= amount, "Allowance is less than the amount to sell");

        uint256 balance = dexToken.balanceOf(msg.sender);
        emit DebugMessage("Balance check before sell", balance);

        require(balance >= amount, "Insufficient balance");

        dexToken.transferFrom(msg.sender, address(this), amount);
        
        emit Sold(msg.sender, amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough tokens to swap");
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).transfer(msg.sender, swapAmount);
    }

    function addLiquidity(address tokenAddress, uint256 amount) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
        uint256 fromBalance = IERC20(from).balanceOf(address(this));
        uint256 toBalance = IERC20(to).balanceOf(address(this));
        return (amount * toBalance) / fromBalance;
    }

    function approve(address token, uint256 amount) public returns (bool) {
        bool isApprove = IERC20(token).approve(msg.sender, address(this), amount);
        emit ApprovalEvent(msg.sender, address(this), amount, token);
        return isApprove;
    }

    function getDexTokenAddress() public view returns (address) {
        return address(dexToken);
    }

    function getDexBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getOwnerBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(msg.sender);
    }

    event DebugMessage(string message, uint256 value);
    event Sold(address indexed seller, uint256 amount);
    event ApprovalEvent(address indexed owner, address indexed spender, uint256 value, address token);
}
