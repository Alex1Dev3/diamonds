pragma solidity ^0.5.0;

import "./ERC20.sol";

contract Token is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _changer;
    address private _stock;
    address private _owner;
    mapping (address => uint256) private _changerBalances;

    constructor ()
    public
    {
        _name = "Diamond Token";
        _symbol = "DMT";
        _decimals = 0;
        _owner = msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    modifier onlyChanger()
    {
        require(msg.sender == _changer, "Caller is not changer");
        _;
    }

    function setChanger(address changer)
    public
    onlyOwner
    {
        require(_changer == address(0), "Changer is no zero address");
        _changer = changer;
    }

    modifier onlyStock()
    {
        require(msg.sender == _stock, "Caller is not stock");
        _;
    }

    function setStock(address stock)
    public
    onlyOwner
    {
        require(_stock == address(0), "Stock is no zero address");
        _stock = stock;
    }

    function name()
    public view
    returns (string memory)
    {
        return _name;
    }

    function symbol()
    public view
    returns (string memory)
    {
        return _symbol;
    }

    function decimals()
    public view
    returns (uint8)
    {
        return _decimals;
    }
    
    function changerBalancesOf(address account)
    public view
    returns (uint256)
    {
        return _changerBalances[account];
    }

    function mint(address account, uint256 amount)
    public
    onlyChanger
    returns (bool)
    {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount)
    public
    onlyChanger
    {
        _changerBalances[account] = _changerBalances[account].sub(amount, "Burn amount exceeds balance");
        _burn(_changer, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    {
        if (to == _changer) {
            _changerBalances[from] = _changerBalances[from].add(amount);
        }
    }

	function transferAgent(address _from, uint256 _value)
	public
	onlyStock
    returns (bool)
	{
		_transfer(_from, msg.sender, _value);
		return true;
	}
}
