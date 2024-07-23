// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface ERC20 padrão
interface IERC20 {

    // Getters
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address tokenOwner, address spender) external view returns (uint256);

    // Funções
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Eventos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ApacheToken is IERC20 {

    string public constant name = "Apachecorp Token";
    string public constant symbol = "APACHECORP";
    uint8 public constant decimals = 18;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    uint256 private totalSupply_;

    address public owner;

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply_ = initialSupply * 10 ** uint256(decimals);
        balances[owner] = totalSupply_;
        emit Transfer(address(0), owner, totalSupply_);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Approve to the zero address");

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowed[sender][msg.sender], "Allowance exceeded");

        balances[sender] -= amount;
        allowed[sender][msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Função para emitir novos tokens
    function mint(uint256 amount) public onlyOwner returns (bool) {
        totalSupply_ += amount;
        balances[owner] += amount;
        emit Transfer(address(0), owner, amount);
        return true;
    }

    // Função para queimar tokens
    function burn(uint256 amount) public onlyOwner returns (bool) {
        require(amount <= balances[owner], "Insufficient balance to burn");

        totalSupply_ -= amount;
        balances[owner] -= amount;
        emit Transfer(owner, address(0), amount);
        return true;
    }
}
