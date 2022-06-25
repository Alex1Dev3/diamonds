pragma solidity ^0.5.0;

contract ReentrancyGuard {
    bool private _notEntered;

    constructor ()
    internal
    {
        _notEntered = true;
    }

    modifier nonReentrant()
    {
        require(_notEntered, "Reentrant call");

        _notEntered = false;
        _;

        _notEntered = true;
    }
}
