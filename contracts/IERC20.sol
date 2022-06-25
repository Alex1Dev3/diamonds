pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferAgent(address from, uint256 value) external returns (bool);
}
