//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ToDoList {
    //created a struct for todos text and todos situation
    struct ToDo {
        string text;
        bool completed;
    }
    //collecting todos with an array.
    ToDo[] public todos;

    //Create Todo function. we used calldata for save gas and try to don't copy data again.
    function createToDo(string calldata _text) external {
        todos.push(ToDo({text: _text, completed: false}));
    }

    function updateToDo(uint256 _index, string calldata _text) external {
        //there is 2 way to update todos.this way spending more gas for multiple times. But we used one time so this is probably cheaper than second way.
        todos[_index].text = _text;

        //  ToDo storage todo = todos[_index];
        //  todo.text = _text;
    }

    //Get todos function. Actually we don't need this function because whel solidity deployed, contract gives an array with todos.
    function getTodo(uint256 _index) external view returns (string memory, bool) {
        ToDo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function completedToggle(uint256 _index) external {
        todos[_index].completed == !todos[_index].completed ;
    }
}
