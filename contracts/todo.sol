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

    mapping(string => Task) private postedTasks;
    mapping(string => Exec) private execApplies;
    mapping(string => Exec) private execVerif;

    event print(string name, string descr);
    event sendStamp(uint stamp);

    constructor() {
        owner = msg.sender;
    }

    function placeTask(string calldata name, uint dueDate, uint reward, string calldata description) public {
        require(msg.sender == owner);
        heads.push(name);
        Task memory newTask;
        newTask.descr = description;
        newTask.dueDate = dueDate;
        newTask.reward = reward;
        postedTasks[name] = newTask;
    }

    function printAllTasks() public {
        string memory name;
        for (uint i = 0; i<heads.length; i++) {
            name = heads[i];
            emit print(name, postedTasks[name].descr);
        }
    }

    function execApply(string calldata name) public {
        Exec memory newApply;
        newApply.name = name;
        uint stamp = block.timestamp;
        newApply.sign = keccak256(abi.encodePacked(name, msg.sender, stamp));
        newApply.wallet = msg.sender;
        execApplies[name] = newApply;
        emit sendStamp(stamp);       
    }

    function execAppr(string calldata name, uint nonce) public {
        require(msg.sender == owner, "You don't have rights for this action");
        bytes32 makeSign = keccak256(abi.encodePacked(name, execApplies[name].wallet, nonce));
        require(makeSign == execApplies[name].sign, "Signatures don't match");
    }
}