//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract CrowdFund {
    event Launch (
        uint id,
        //we give indexed because if the creator has a lot of campaigns we will show all of them.
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    //we create a struct for get from users to starting information 
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }
    //import IERC20 standarts to our token
    IERC20 public immutable token;
    //state variables. -give an id for each campaign, and count every campaign when created. 
    //how much token pledged for each campaign. we took campaign id and created another mapping for take address and amount.
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        //start at must be equal or greater than now
        //end at must be equal or greater than start at
        //contracts max duration is 90 days.
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt," end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");
        //we update the campaign informations 
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed:false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }
     //users can be cancelled funds 
        function cancel(uint _id) external {
            //only the campaign creator exist the campaign.
            Campaign memory campaign = campaigns[_id];
            require(msg.sender == campaign.creator, "not creator");
            require(block.timestamp < campaign.startAt, "started");
            delete campaigns[_id];
            //calling the cancel event.
            emit Cancel(_id);
        }
        //users can be cancelled funds
        function pledge(uint _id,uint _amount) external {
            //we used to storage because we update the campaign data.
            Campaign storage campaign = campaigns[_id];
            //creator can not be pledged before campaign will be end. 
            require(block.timestamp >= campaign.startAt, "not started");
            require(block.timestamp <= campaign.endAt, "ended");
            //pledged takes total amount of campaign
            campaign.pledged += _amount;
            //we should hold amount for each id and address
            pledgedAmount[_id][msg.sender] += _amount;
            token.transferFrom(msg.sender,address(this), _amount);

            emit Pledge(_id, msg.sender, _amount);

        }


        function unpledge(uint _id,uint _amount) external {
            Campaign storage campaign = campaigns[_id];
            //users should not unpledge the campaign will be ended.
            require(block.timestamp <= campaign.endAt, "ended");
            //when unpledged we should send user tokens back
            campaign.pledged -= _amount;
            pledgedAmount[_id][msg.sender] -= _amount;
            token.transfer(msg.sender, _amount);

            emit Unpledge(_id, msg.sender, _amount);
        }
        //users can be claim their tokens
        function claim(uint _id) external {

             Campaign storage campaign = campaigns[_id];
             require(msg.sender == campaign.creator, "not creator");
             require(block.timestamp > campaign.endAt, "not ended");
             require(campaign.pledged >= campaign.goal, "pledged < goal");
             require(!campaign.claimed, "claimed");
             campaign.claimed = true;

             token.transfer(msg.sender, campaign.pledged);

             emit Claim(_id);
        }
        //when the campaign will unsuccessfull, pledged less then goal, users can be refund.
        function refund(uint _id) external {
             Campaign storage campaign = campaigns[_id];
             require(block.timestamp > campaign.endAt, "not ended");
             require(campaign.pledged < campaign.goal, "pledged < goal");

            //reset the id amount data and send to creator
             uint bal = pledgedAmount[_id][msg.sender];
             pledgedAmount[_id][msg.sender] = 0;
             token.transfer(msg.sender, bal);

             emit Refund(_id, msg.sender, bal);
        }
}