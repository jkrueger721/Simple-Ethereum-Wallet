pragma solidity >=0.4.24 <0.6.0;
contract SimpleWallet {
    
    address payable owner;
    
    struct WithdrawalStruct {
        address to;
        uint amount;
    }
    
    struct Senders {
        bool allowed;
        uint amount_sends;
        mapping(uint => WithdrawalStruct) withdrawals;
    }
    
    mapping(address => Senders) public isAllowedToSendFundsMapping;
    
    event Deposit(address _sender, uint _amount);
    event Withdrawal(address _sender, uint _amount, address _beneficiary);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not allowed!");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function() payable external {
        require(isAllowedToSend(msg.sender),"You are not allowed, go away!");
        emit Deposit(msg.sender, msg.value);
    }
    
    function sendFunds(uint amount, address payable receiver) public {
        require(isAllowedToSend(msg.sender),"You are not allowed, go away!");
        receiver.transfer(amount);
        emit Withdrawal(msg.sender, amount, receiver);
        isAllowedToSendFundsMapping[msg.sender].withdrawals[isAllowedToSendFundsMapping[msg.sender].amount_sends].to = receiver;
        isAllowedToSendFundsMapping[msg.sender].withdrawals[isAllowedToSendFundsMapping[msg.sender].amount_sends].amount = amount;
        
        isAllowedToSendFundsMapping[msg.sender].amount_sends++;
    }
    
    function allowAddressToSendMoney(address _address) public onlyOwner {
        isAllowedToSendFundsMapping[_address].allowed = true;
        
    }
    
    function disallowAddressToSendMoney(address _address) public onlyOwner {
        isAllowedToSendFundsMapping[_address].allowed = false;
    }
    
    function isAllowedToSend(address _address) public view returns(bool) {
        return isAllowedToSendFundsMapping[_address].allowed || msg.sender == owner;
    }
    
    function getWithdrawalForAddress(address _address, uint _index) public view returns(address, uint) {
        return (isAllowedToSendFundsMapping[_address].withdrawals[_index].to, isAllowedToSendFundsMapping[_address].withdrawals[_index].amount);
    }
    
    function killWallet() public onlyOwner {
        selfdestruct(owner);
    }
}
