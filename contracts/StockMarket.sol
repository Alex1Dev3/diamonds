pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";

contract StockMarket {
    using SafeMath for uint256;

    mapping(address => uint256) public lotSell;
    mapping(address => uint256) public priceSell;
    mapping(address => bool) public statusSell;
    mapping(address => uint256) public lotBuy;
    mapping(address => bool) public statusBuy;
    mapping(address => uint256) internal _deposits;

    IERC20 public token;
    uint256 public maxPrice;
    uint256 public maxToken;
    uint256 public percentIn;
    uint256 public decimalIn;
    uint256 public percentOut;
    uint256 public decimalOut;
    address payable public owner;

    event Deal(address indexed payer, address payee, uint256 tokenAmount, uint256 weiAmount);
    event CancelOffer(address indexed sender);
    event OfferToSell(address indexed seller, uint256 valueLot, uint256 price);
    event OfferToBuy(address indexed buyer, uint256 valueLot, uint256 price);
    event Deposited(address indexed sender, uint256 weiAmount);

    constructor(IERC20 _token, uint256 _percentIn, uint256 _decimalIn, uint256 _percentOut, uint256 _decimalOut)
    public
    {
        token = _token;
        percentIn = _percentIn;
        decimalIn = _decimalIn;
        percentOut = _percentOut;
        decimalOut = _decimalOut;
        maxToken = _token.totalSupply();
        maxPrice = 1000000000000000;
        owner = msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function balanceToken(address _addr)
    public view
    returns(uint256)
    {
        uint256 balance = token.balanceOf(_addr);
        return balance;
    }

    function offerToSell(uint256 _valueLot, uint256 _price)
    public
    returns(bool)
    {
        require(balanceToken(msg.sender) >= _valueLot && _valueLot > 0 && _price > 0 && _price <= maxPrice.mul(_valueLot) && !statusSell[msg.sender]);

        token.transferAgent(msg.sender, _valueLot);
        lotSell[msg.sender] = lotSell[msg.sender].add(_valueLot);
        priceSell[msg.sender] = _price;
        statusSell[msg.sender] = true;

        emit OfferToSell(msg.sender, _valueLot, _price);
        return true;
    }

    function cancelOfferSell()
    public
    returns(bool)
    {
        require(statusSell[msg.sender]);

        uint256 valueTokens = lotSell[msg.sender];
        lotSell[msg.sender] = 0;
        priceSell[msg.sender] = 0;
        statusSell[msg.sender] = false;
        token.transfer(msg.sender, valueTokens);

        emit CancelOffer(msg.sender);
        return true;
    }

    function dealOfferToSell(address payable _payee, uint256 _valueLot)
    public payable
    returns(bool)
    {
        uint256 amount = msg.value;
        uint256 valueTokens = lotSell[_payee];
        uint256 valueWei = priceSell[_payee];

        require(amount >= valueWei && _valueLot == valueTokens);

        lotSell[_payee] = 0;
        priceSell[_payee] = 0;
        statusSell[_payee] = false;
        token.transfer(msg.sender, valueTokens);

        emit CancelOffer(msg.sender);
        emit Deal(msg.sender, _payee, valueTokens, amount);

        uint256 percent = valueWei.mul(percentOut).div(decimalOut).div(100);
        owner.transfer(percent);
        _payee.transfer(valueWei.sub(percent));

        return true;
    }

    function offerToBuy(uint256 _valueLot)
    public payable
    returns (bool)
    {
        uint256 amount = msg.value;

        require(amount != 0 && _valueLot <= maxToken && _valueLot > 0 && !statusBuy[msg.sender]);

        _deposits[msg.sender] = amount;
        lotBuy[msg.sender] = _valueLot;
        statusBuy[msg.sender] = true;

        emit OfferToBuy(msg.sender, _valueLot, amount);
        emit Deposited(msg.sender, amount);
        return true;
    }

    function cancelOfferBuy()
    public
    returns(bool)
    {
        uint256 valueWei = _deposits[msg.sender];

        require(statusBuy[msg.sender] && address(this).balance >= valueWei);

        _deposits[msg.sender] = 0;
        lotBuy[msg.sender] = 0;
        statusBuy[msg.sender] = false;

        emit CancelOffer(msg.sender);

        msg.sender.transfer(valueWei);

        return true;
    }

    function dealOfferToBuy(address _payee, uint256 _valueLot)
    public payable
    returns(bool)
    {
        require(_valueLot >= lotBuy[_payee] && address(this).balance >= _deposits[_payee]);

        uint256 valueWei = _deposits[_payee];
        uint256 valueTokens = lotBuy[_payee];

        token.transferAgent(msg.sender, valueTokens);
        token.transfer(_payee, valueTokens);
        _deposits[_payee] = 0;
        lotBuy[_payee] = 0;
        statusBuy[_payee] = false;

        emit CancelOffer(msg.sender);
        emit Deal(msg.sender, _payee, valueTokens, valueWei);

        uint256 percent = valueWei.mul(percentIn).div(decimalIn).div(100);
        owner.transfer(percent);
        msg.sender.transfer(valueWei.sub(percent));

        return true;
    }

    function depositsOf(address _payee)
    public view
    returns (uint256)
    {
        return _deposits[_payee];
    }

    function showOffersToSell(address _applicant)
    public view
    returns(bool, uint256, uint256)
    {
        return (statusSell[_applicant], lotSell[_applicant], priceSell[_applicant]);
    }

    function showOffersToBuy(address _applicant)
    public view
    returns(bool, uint256, uint256)
    {
        return (statusBuy[_applicant], lotBuy[_applicant], _deposits[_applicant]);
    }

    function statusBuyOf(address _owner)
    public view
    returns(bool)
    {
        return statusBuy[_owner];
    }

    function statusSellOf(address _owner)
    public view
    returns(bool)
    {
        return statusSell[_owner];
    }

    function correctOffers(address _addr)
    public
    onlyOwner
    returns(bool)
    {
        require(statusSell[_addr] || statusBuy[_addr]);

        if(statusSell[_addr]) {
            uint256 valueTokens = lotSell[_addr];

            lotSell[_addr] = 0;
            priceSell[_addr] = 0;
            statusSell[_addr] = false;
            token.transfer(msg.sender, valueTokens);

            emit CancelOffer(msg.sender);
        }

        if(statusBuy[_addr]) {
            uint256 valueWei = _deposits[_addr];

            require(address(this).balance >= valueWei);

            _deposits[_addr] = 0;
            lotBuy[_addr] = 0;
            statusBuy[_addr] = false;

            emit CancelOffer(msg.sender);

            msg.sender.transfer(valueWei);
        }

        return true;
    }

    function changeMaxPrice(uint256 value)
    public
    onlyOwner
    {
        maxPrice = value;
    }

    function changeMaxToken(uint256 value)
    public
    onlyOwner
    {
        maxToken = value;
    }

    function changePercentIn(uint256 _percentIn, uint256 _decimalIn)
    public
    onlyOwner
    {
        percentIn = _percentIn;
        decimalIn = _decimalIn;
    }

    function changePercentOut(uint256 _percentOut, uint256 _decimalOut)
    public
    onlyOwner
    {
        percentOut = _percentOut;
        decimalOut = _decimalOut;
    }
}
