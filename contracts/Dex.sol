// SPDX-License-Identifier: MIT
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

//Interface of the ERC-20 standard as defined in the ERC.
interface IERC20 {
    //Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //Returns the value of tokens in existence.
    function totalSupply() external view returns (uint256);

    //Returns the value of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    //Moves a `value` amount of tokens from the caller's account to `to`.
    //Returns a boolean value indicating whether the operation succeeded.
    //Emits a {Transfer} event.
    function transfer(address to, uint256 value) external returns (bool);

    //Returns the remaining number of tokens that `spender` will be
    //allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default.
    //This value changes when {approve} or {transferFrom} are called.
    function allowance(address owner, address spender) external view returns (uint256);

    //Sets a `value` amount of tokens as the allowance of `spender` over the caller's tokens.
    //Returns a boolean value indicating whether the operation succeeded.
    function approve(address owner, address spender, uint256 amount) external returns (bool);

    
    //Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism. `value` is then deducted from the caller's allowance.
    //Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract DXTK is IERC20 {
    mapping(address => uint256) public accBalance;
    mapping(address => mapping(address => uint256)) public accAllowance;
    string public name = "DX-token";
    string public symbol = "DXTK";
    uint256 public totalSupply = 100000000000000000000000; //100000 MATIC
    uint8 public decimals=18;

    constructor() {
        // name = _name;
        // symbol = _symbol;
        // totalSupply = _totalSupply;
        //decimals = _decimals;
        accBalance[msg.sender] = totalSupply; //send token to creator 
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(amount <= accBalance[msg.sender]);
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

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {   
        require(amount <= accBalance[sender]);
        require(amount <= accAllowance[sender][msg.sender]);

        accAllowance[sender][msg.sender] -= amount;
        accBalance[sender] -= amount;
        accBalance[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //view amount of token allow to transfer by delegate
    function allowance(address owner, address spender) external view returns (uint256){
        return accAllowance[owner][spender];
    }

    function getAddress() external view returns (address){
        return address(this);
    }

    function getTotalSupply() external view returns (uint256){
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
    //use safeMath library to prevent overflow
    using safeMath for uint256;

    IERC20 dexToken;

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
        uint256 Allowance = dexToken.allowance(msg.sender, address(this));
        require(Allowance > amount, "allowance need to larger than sell amount");
        dexToken.transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint swapAmount = getSwapPrice(from, to, amount); //calculate swap price
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).transfer(msg.sender, swapAmount);

    }

    function addLiquidity(address token_address, uint256 amount) public{
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
        uint256 fromBalance = IERC20(from).balanceOf(address(this));
        uint256 toBalance = IERC20(to).balanceOf(address(this));
        return (amount * toBalance / fromBalance);
    }

    function approve(address token, uint256 amount) public returns(bool) {
        bool isApprove = IERC20(token).approve(msg.sender, address(this), amount);
        require(isApprove, "Approval failed");
        return isApprove;
    }

    function getDexTokenAddress() public view returns (address) {
        return address(dexToken);
    }

        function getDexBalance(address token) public view returns(uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getOwnerBalance(address token) public view returns(uint256) {
        return IERC20(token).balanceOf(msg.sender);
    }

    function getAllowance(address token) public view returns (uint256) {
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        return allowance;
    }

}