pragma solidity ^0.5.0;

library SafeMath {
    function add(uint256 a, uint256 b)
    internal pure
    returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b)
    internal pure
    returns (uint256)
    {
        return sub(a, b, "Subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage)
    internal pure
    returns (uint256)
    {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b)
    internal pure
    returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b)
    internal pure
    returns (uint256)
    {
        return div(a, b, "Division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage)
    internal pure
    returns (uint256)
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b)
    internal pure
    returns (uint256)
    {
        return mod(a, b, "Modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage)
    internal pure
    returns (uint256)
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}
