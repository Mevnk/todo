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

    mapping(string => Task) private postedTasks;
    event print(string name);
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
        for (uint i = 0; i<heads.length; i++) {
            emit print(heads[i]);
        }
    }
}