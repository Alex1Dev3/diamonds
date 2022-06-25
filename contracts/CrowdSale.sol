pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";

contract CrowdSale is ReentrancyGuard {
    using SafeMath for uint256;

    IERC20 public token;

    uint256 private _ratioE;
    uint256 private _ratioT;
    uint256 public summary1 = 0;
    uint256 public summary2 = 0;
    uint256 public summary3 = 0;

    mapping (address => bool) public owners;
    mapping (address => bool) public recipients1;
    mapping (address => bool) public recipients2;
    mapping (address => bool) public recipients3;

    constructor (IERC20 initToken, address defaultOwner, address defaultRecipient1, address defaultRecipient2, address defaultRecipient3)
    public
    {
        require(address(initToken) != address(0), "Token is zero address");

        token = initToken;

        _ratioE = 5000;
        _ratioT = 20;

        owners[defaultOwner] = true;
        recipients1[defaultRecipient1] = true;
        recipients2[defaultRecipient2] = true;
        recipients3[defaultRecipient3] = true;
    }

    modifier onlyOwner()
    {
        require(owners[msg.sender], "Caller is not owner");
        _;
    }

    modifier onlyRecipient()
    {
        require(recipients1[msg.sender] || recipients2[msg.sender] || recipients3[msg.sender], "Caller is not recipient");
        _;
    }

    modifier onlyRecipient1()
    {
        require(recipients1[msg.sender], "Caller is not recipient1");
        _;
    }

    modifier onlyRecipient2()
    {
        require(recipients2[msg.sender], "Caller is not recipient2");
        _;
    }

    modifier onlyRecipient3()
    {
        require(recipients3[msg.sender], "Caller is not recipient3");
        _;
    }

    function createTokens(uint256 quantity, uint256 decimal)
    public payable
    nonReentrant onlyOwner
    {
        uint256 weiAmount = msg.value;
        uint256 minAmount = minAmount(quantity, decimal);

        require(weiAmount >= minAmount, "WeiAmount is less than minimum");

        uint256 tokens = quantity.mul(_ratioT).div(10 ** decimal);
        uint256 summary = weiAmount.div(3);

        token.mint(msg.sender, tokens);
        summary1 = summary1.add(summary);
        summary2 = summary2.add(summary);
        summary3 = summary3.add(weiAmount.sub(summary.mul(2)));
    }

    function burnTokens(address account, uint256 amount)
    public
    onlyOwner
    {
        token.burn(account, amount);
    }

    function minAmount(uint256 quantity, uint256 decimal)
    public view
    returns (uint256)
    {
        return quantity.mul(10 ** 18).div(_ratioE).div(10 ** decimal);
    }

    function getAmount()
    public
    nonReentrant onlyRecipient
    {
        uint256 amount;
        if (recipients1[msg.sender]) {
            amount = summary1;
            require(amount != 0, "Summary1 is zero");
            summary1 = 0;
        }
        if (recipients2[msg.sender]) {
            amount = summary2;
            require(amount != 0, "Summary2 is zero");
            summary2 = 0;

        }
        if (recipients3[msg.sender]) {
            amount = summary3;
            require(amount != 0, "Summary3 is zero");
            summary3 = 0;
        }
        msg.sender.transfer(amount);
    }

    function addOwner(address owner)
    public
    onlyOwner
    {
        require(owners[owner] == false, "This address already has owner rights");
        owners[owner] = true;
    }

    function removeOwner(address owner)
    public
    onlyOwner
    {
        require(owners[owner] == true, "Owner address not provided");
        owners[owner] = false;
    }

    function addRecipient1(address recipient)
    public
    onlyRecipient1
    {
        require(recipients1[recipient] == false, "This address already has recipient1 rights");
        recipients1[recipient] = true;
    }

    function removeRecipient1(address recipient)
    public
    onlyRecipient1
    {
        require(recipients1[recipient] == true, "Recipient1 address not provided");
        recipients1[recipient] = false;
    }

    function addRecipient2(address recipient)
    public
    onlyRecipient2
    {
        require(recipients2[recipient] == false, "This address already has recipient2 rights");
        recipients2[recipient] = true;
    }

    function removeRecipient2(address recipient)
    public
    onlyRecipient2
    {
        require(recipients2[recipient] == true, "Recipient2 address not provided");
        recipients2[recipient] = false;
    }

    function addRecipient3(address recipient)
    public
    onlyRecipient3
    {
        require(recipients3[recipient] == false, "This address already has recipient3 rights");
        recipients3[recipient] = true;
    }

    function removeRecipient3(address recipient)
    public
    onlyRecipient3
    {
        require(recipients3[recipient] == true, "Recipient3 address not provided");
        recipients3[recipient] = false;
    }
}
