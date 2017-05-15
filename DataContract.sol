pragma solidity ^0.4.0;
contract Data{ 
 
  address public organizer;
  mapping (uint => bytes32) public userskeys;
  mapping (bytes32 => uint) public usersBalance;
  mapping (bytes32 => Producer) public producers;
  mapping (bytes32 => Consumer) public consumers;
  struct Producer {
        string name;
		string property;
        uint id;
        uint balance;
		uint datasize;
		uint datastatus;
		uint datatype;
		uint consumerip;
		uint period;
        mapping (uint => bytes32) datahashes;
  }
  struct Consumer {
        string name;
		string property;
		string organization;
        uint id;
        uint balance;
		uint ipaddress;
		mapping (uint => string) dataevent;
  }
  
  uint public numTransactions;
  uint public accountCount =0;
  uint public ids = 1;
  uint public iddata = 0;
  uint public idevent =0;
  // so you can log these events
  event Log(string mess1,uint mess2);
  event Checkstatus(string producer, uint _datastatus, uint _datatype, uint _consumerip, uint _period);
  event Logm(string mess1, string mess2, string mess3, uint mess4);
  event Buy(uint indexed _consumerid,string _consumer, uint indexed _producer, uint _amount, uint _balance, string mess, bool res); 
  event Sell(uint indexed _consumerid, string consumer, uint indexed _producerid, string _producer, uint _amount, uint _balance, string mess); 
  event NewProducer(string _user, uint indexed _userid, uint _balance, string mess);
  event NewConsumer(string _user, uint indexed _userid, uint _balance, string mess);
  event NewData(uint indexed iddata, uint indexed _producerid, string producer, string description);
  event IncreaseBalance(string _consumer, uint indexed _consumerid, uint _balance);
  
  function Datav6() { // Constructor
    organizer = msg.sender;
    numTransactions = 0;
  }
    function addProducer(string user) returns (bool success){
        //add producer
		//Log("addproducer call",addBalance);
        var ukey = sha3(user);
        Producer p = producers[ukey];
		if(p.id==0){
			producers[ukey] = Producer (user, 'producer',ids,0,0,0,0,0,0);
			//Log("Producer struct created",addBalance);
			userskeys[ids] = ukey;
			//usersBalance[ukey] +=addBalance;
			ids++;
			accountCount++;
			NewProducer(user,producers[ukey].id,producers[ukey].balance,"producer added");//usersBalance[sha3(user)]);
			return true;
		}else{
		   Log("addproducer failed",0);
			return false;
		}
		
  }
    function addConsumer(string user, string organization, uint ipaddress, uint addBalance) returns (bool success){
        //add consumer 
		var ukey = sha3(user);
        Consumer c = consumers[ukey];
		if(c.id==0){
		consumers[ukey] = Consumer(user, 'consumer', organization, ids,addBalance,ipaddress);
        userskeys[ids] = ukey;
		usersBalance[sha3(user)] +=addBalance;
        ids++;
		accountCount++;
		NewConsumer(user,consumers[ukey].id,consumers[ukey].balance, "consumer added");//usersBalance[sha3(user)]);
		return true;
		}else{
			Log("addConsumer failed",0);
			return false;
		}
  }
  
    function addevent(string user, string database, string eventstring){
        var ukey = sha3(user);
        Consumer c = consumers[ukey];
		for (uint i = 1; i <=idevent+1; i ++)
		if(stringslength(c.dataevent[i])==0){
		c.dataevent[i] = eventstring;
		idevent++;
		Logm(user, database, eventstring, 1);
		break;
	}
  }
  
  
  function checkProducers() public{
	  //show the list of producers	  
	  for(uint x =1; x<=accountCount; x++){
		  Producer p =producers[userskeys[x]];
		  if(stringsEqual(p.property,'producer')){
			  Logm("Producer:",p.name,"datasize:",p.datasize);
		  } 
	  }
  }
  
  function checkEvent(string user) public{
		var ukey = sha3(user);
        Consumer c = consumers[ukey];
		for(uint x =1; x<=idevent; x++){
		  if(stringslength(c.dataevent[x])!=0)
			Logm("Event:",c.name,c.dataevent[x],1);
		   }
  }
  
  function checkConsumers() public{
	  //show the list of consumers	  
	  for(uint x =1; x<=accountCount; x++){
		  Consumer c =consumers[userskeys[x]];
		  if(stringsEqual(c.property,'consumer')){
			  Logm("Producer:",c.name,"Balance:",c.balance);
		  } 
	  }
  }
  
  function checkdatasize(string _producer) public {
  //consumer check the datasize of the user
    var pkey = sha3(_producer);
	Producer p = producers[pkey];
	Log("user datasize",p.datasize);
  }
  
  function checkdatastatu(string _producer) public{
  //producer check whether data was bought
	var pkey = sha3(_producer);
	Producer p = producers[pkey];
	//Log("userstatus",p.datastatus);
    Checkstatus(_producer, producers[pkey].datastatus, producers[pkey].datatype, producers[pkey].consumerip, producers[pkey].period);
	//NewData(iddata, producers[pkey].id, _producer, description);
	//Checkstatus(uint _datastatus,uint _datatype,uint _consumerip,uint _period);
	//LogI("datatype", p.datatype,"status", p.datastatus);
	//LogI("ip", p.consumerip,"period", p.period);
  }
  function checkbalance(string _user) public{
	  var ukey = sha3(_user);
	  Logm("checkbalance called", _user,"users' balance",usersBalance[ukey]);
  }
  
  	function stringsEqual(string memory _a, string memory _b) internal returns (bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}
	
  //datatype should be 1,2,3--1_Accelerometer--2_GPS--3_Accelerometer&GPS
  //period should like 2017010330 date+days
  //the price of data is 50/1 unit, and if consumer want to buy one month data, the data they bought will  averagely ditributed to each day
  function buyData(string _consumer, string _producer, uint datatype, uint amount, uint period) public returns (bool success) { 
    //if (numRegistrants >= quota) { Deposit(_id,from, amount, "conference is full"); return false; } // see footnote
    //Log("buyData call",amount);
    var ckey = sha3(_consumer);
    var pkey = sha3(_producer);
    Consumer c = consumers[ckey];
	Producer p = producers[pkey];
    //check consumer's balance
    if (usersBalance[ckey]< amount) {
        Log("buyData not enough balance",usersBalance[ckey]);
        Buy(c.id,_consumer,producers[pkey].id, amount, consumers[ckey].balance,"not enough funds",false); return false;    
    }else{
		//check user's data size
		// if(p.datasize<amount/50) {
		// Log("buyData not enough data",p.datasize);
        // Buy(c.id,_consumer,producers[pkey].id, amount, consumers[ckey].balance,"not enough data",false); return false;    
		// }else{
			if(datatype >= 2){
				if(stringsEqual(c.organization,'healthy')){
					//Log("Consumer can buy anydata",1);				
					p.balance += amount;
					usersBalance[pkey] +=amount;
					p.datastatus +=1;
					c.balance -=amount;
					usersBalance[ckey] -=amount;
					//store the consumer's ipaddress for producer to send real data
					p.consumerip = c.ipaddress;
					p.period = period;
					p.datatype = datatype;
					numTransactions++;
					Buy(c.id,_consumer,p.id, amount,  c.balance, "correctly bought",true);
					Sell(c.id, _consumer,p.id, _producer, amount,p.balance, "new sale"); 
					return true;
				}else{
					Log("Consumer can only buy accelerometer data",1);
					Buy(c.id,_consumer,producers[pkey].id, amount, consumers[ckey].balance,"not enough priority",false); return false;
				}
			}else{	 
				 p.balance += amount;
				 usersBalance[pkey] +=amount;
				 p.datastatus +=1;
				 c.balance -=amount;
				 usersBalance[ckey] -=amount;
				 //store the consumer's ipaddress for producer to send real data
				 p.consumerip = c.ipaddress;
				 p.period = period;
				 p.datatype = datatype;
				 numTransactions++;
				 Buy(c.id,_consumer,p.id, amount,  c.balance, "correctly bought",true);
				 Sell(c.id, _consumer,p.id, _producer, amount,p.balance, "new sale"); 
				 return true;
			}
		// }
	}
  }
  

////////////////////////////////////////////////////////////////////////////////   
   function increaseConsumerBalance(string _consumer,uint amount) public {
        if (msg.sender != organizer) { return; }
        var ckey = sha3(_consumer);
        Consumer c = consumers[ckey];
        c.balance +=amount;
        usersBalance[ckey] +=amount;
        IncreaseBalance(_consumer, c.id, c.balance);
  }
////////////////////////////////////////////////////////////////////////////////  


  function addData(string _producer, string pdata, string description) public {
    
    var pkey = sha3(_producer);
	Producer p= producers[pkey];
	var blocknumber = stringslength(pdata)/32;
	bytes32 hdata = sha3(pdata);
	uint location = now;
	p.datahashes[location] = hdata;
	p.datasize+=blocknumber;
	iddata++;
	NewData(iddata, producers[pkey].id, _producer, description);
  }
  
  function stringslength(string memory _a) internal returns (uint) {
		bytes memory a = bytes(_a);
			return a.length;
		
	}
  
  
  function destroy() { // so funds not locked in contract forever
    if (msg.sender == organizer) {
      suicide(organizer); // send funds to organizer
    }
  }
}