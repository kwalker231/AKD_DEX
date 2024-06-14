// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
    function approve(address spender, uint256 value) external returns (bool);

    
    //Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism. `value` is then deducted from the caller's allowance.
    //Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ERC20 is IERC20 {

    uint256 public totalSupply;
    mapping(address => uint256) public accBalance;
    mapping(address => mapping(address => uint256)) public accAllowance;
    string public name;
    string public symbol;
    uint8 public decimals=18;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        //decimals = _decimals;
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

    function approve(address spender, uint256 amount) external returns (bool) {
        accAllowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
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

    function balanceOf(address owner) public override view returns (uint256) {
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

contract DexToken is ERC20 {

    constructor(
        string memory name,
        string memory symbol,
        uint256 TotoalSupply
    ) ERC20(name, symbol, TotoalSupply) {
        _mint(msg.sender, TotoalSupply * (10**ERC20.decimals));
    }
}
