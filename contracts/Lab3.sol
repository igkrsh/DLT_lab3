pragma solidity ^0.5.0;

contract Auction {
    struct Item{
        uint id;
        string name;
        bool onSale;
    }
    
    struct Bid {
        uint amount;
        address payable bider;
    }
    
    address payable owner;
    uint ids = 0;
    uint min_bid_amount = 1000000000000000;
    mapping(address => Item[]) items;
    mapping(uint => Bid) auctions;
    
    constructor () public{
        owner = msg.sender;
    }
    
    function createItem(string memory name) public returns(uint){
        Item memory item = Item(ids, name, false);
        items[msg.sender].push(item);
        ids ++;
        return ids -1;
    }
    
    function transferItem(uint id, address to) public{
        uint index = own(id, msg.sender);
        require(index > 0);
        index --;
        items[to].push(items[msg.sender][index]);
        remove(index, msg.sender);
    }
    
    function startAuction(uint id, uint startBid) public payable{
        require(msg.value == startBid);
        uint index = own(id, msg.sender);
        require(index > 0);
        index --;
        require(startBid >= min_bid_amount);
        items[msg.sender][index].onSale = true;
        auctions[id] = Bid(startBid, msg.sender);
    }
    
    function placeBid(uint id, uint bid) public payable{
        require(msg.value == bid);
        require(bid >= min_bid_amount);
        Bid memory tmp = auctions[id];
        auctions[id] = Bid(tmp.amount + bid, msg.sender);
    }
    
    function endAuction(uint id) public {
        msg.sender.transfer(auctions[id].amount);
        transferItem(id, auctions[id].bider);
    }
    
    function remove(uint index, address tmp) private{
        Item[] storage array = items[tmp];

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        items[tmp] = array;
    }
    
    function own(uint id, address check) private view returns(uint){
        Item[] storage array = items[check];
        for (uint j = 0; j < array.length; j++) {
            if (array[j].id == id) {
                return j + 1;
            }
        }
        return 0;
    }
}