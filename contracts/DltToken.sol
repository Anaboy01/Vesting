// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract DltToken{

   
    string tokenName;
    string tokenSymbol;
    uint256 totalSupply;
    address owner;

   
    mapping (address user => uint256)  balances;
   
    mapping (address => mapping (address => uint256))  allow;

    constructor(string memory _name, string memory _symbol){
        tokenName = _name;
        tokenSymbol = _symbol;
        owner = msg.sender;
    
        mint(1_000_000, owner);
    }

  
    event Transfer(address indexed sender, address indexed reciever, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    function getTokenName() external view returns (string memory){
        return tokenName;
    }

    function getSymbol() external view returns (string memory){
        return tokenSymbol;
    }

    function getTotalSupply() external view returns (uint256){
        return totalSupply;
    }

    function decimal() external pure returns(uint8){
        return 18;
    }

    //balance check
    function balanceOf(address _address) external view returns (uint256){
        return balances[_address];
    }

function transfer(address _receiver, uint256 _amountOfToken) external {
    require(_receiver != address(0), "Address is not allowed");
    require(_amountOfToken <= balances[msg.sender], "You can't take more than what is available");

    uint256 percentageToBeBurnt = _amountOfToken * 5 / 100;

    burn(msg.sender, percentageToBeBurnt);

    
    uint256 amountTobeSent = _amountOfToken - percentageToBeBurnt;

    balances[msg.sender] -= _amountOfToken;

    balances[_receiver] += amountTobeSent;

    emit Transfer(msg.sender, _receiver, amountTobeSent);
}



    function approve(address _delegate, uint256 _amountOfToken) external {
        require(balances[msg.sender] > _amountOfToken, "Balance is not enough");

        allow[msg.sender][_delegate] = _amountOfToken;

        emit Approval(msg.sender, _delegate, _amountOfToken);
    }

    function allowance(address _owner, address _delegate) external view returns (uint) {
        return allow[_owner][_delegate];
    }

    function transferFrom(address _owner, address _buyer, uint256 _amountOfToken) external {
        //sanity check
        require(_owner != address(0), "Address is not allowed");
        require(_buyer != address(0), "Address is not allowed");

        require(_amountOfToken <= balances[_owner]);
        require(_amountOfToken <= allow[_owner][msg.sender]);

         uint256 percentageToBeBurnt = _amountOfToken * 5 / 100;

        burn(_owner, percentageToBeBurnt);

        uint256 amountTobeSent = _amountOfToken - percentageToBeBurnt;

        balances[_owner] = balances[_owner] - _amountOfToken;

        allow[_owner][msg.sender] -= _amountOfToken;

        balances[_buyer] = balances[_buyer] + amountTobeSent;

        emit Transfer(_owner, _buyer, amountTobeSent);
    }

    function burn(address _address, uint256 _amount) internal{
        balances[_address] = balances[_address] - _amount;
        totalSupply = totalSupply - _amount;

        emit Transfer(_address, address(0), _amount);
    }

 
    function mint(uint256 _amount, address _addr) internal {
        uint256 actualSupply = _amount * (10**18);
        balances[_addr] = balances[_addr] + actualSupply;

        totalSupply = totalSupply + actualSupply;

        emit Transfer(address(0), _addr, actualSupply);
    }
}