// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract todoList {
    address owner;
    string[] private heads;

    struct Task {
        string descr;
        uint reward;
        uint dueDate;
    }

    struct Exec {
        string name;
        bytes32 sign;
        address wallet;
    }

    string[] private postedTasksHeads;
    string[] private execVerifHeads;
    string[] private execApplyHeads;

    mapping(string => Task) private postedTasks;
    mapping(string => Exec) private execApplies;
    mapping(string => Exec) private execVerif;

    event print(string name, uint reward, uint dueDate, string descr);
    event sendStamp(uint stamp);
    event checkBal(uint bal);

    constructor() {
        owner = msg.sender;
    }

    function compareStrings(string memory a, string memory b) private view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function placeTask(string calldata name, uint dueDate, uint reward, string calldata description) payable public {
        require(msg.sender == owner, "You don't have rights for this action");
        require(reward == msg.value/2, "Insufficient deposits");
        heads.push(name);
        Task memory newTask;
        newTask.descr = description;
        newTask.dueDate = dueDate;
        newTask.reward = reward;
        postedTasks[name] = newTask;
        postedTasksHeads.push(name);
        emit checkBal(address(this).balance);
    }

    function printAllTasks() public {
        string memory name;
        for (uint i = 0; i<heads.length; i++) {
            name = heads[i];
            emit print(name, postedTasks[name].reward, postedTasks[name].dueDate, postedTasks[name].descr);
        }
    }

    function execApply(string calldata name) public {
        Exec memory newApply;
        newApply.name = name;
        uint stamp = block.timestamp;
        newApply.sign = keccak256(abi.encodePacked(name, msg.sender, stamp));
        newApply.wallet = msg.sender;
        execApplies[name] = newApply;
        execApplyHeads.push(name);
        emit sendStamp(stamp);       
    }

    function execAppr(string calldata name, uint nonce) public {
        require(msg.sender == owner, "You don't have rights for this action");
        bytes32 makeSign = keccak256(abi.encodePacked(name, execApplies[name].wallet, nonce));
        require(makeSign == execApplies[name].sign, "Signatures don't match");
        execVerifHeads.push(name);
        execVerif[name] = execApplies[name];
    }

    function setTaskDone(string memory execName, string memory taskName) public {
        require(msg.sender == owner, "You don't have rights for this action");
        uint i;
        for (i = 0; i < execVerifHeads.length; i++) {
            if (compareStrings(execVerifHeads[i], execName))
                break;
        }
        require(i != execVerifHeads.length, "User doesn't exist or is not verified");
        for (i = 0; i < postedTasksHeads.length; i++) {
            if (compareStrings(postedTasksHeads[i], taskName))
                break;
        }
        require(i != postedTasksHeads.length, "Task doesn't exist");
        payable(execVerif[execName].wallet).transfer(postedTasks[taskName].reward);
        payable(owner).transfer(postedTasks[taskName].reward);
    }
}