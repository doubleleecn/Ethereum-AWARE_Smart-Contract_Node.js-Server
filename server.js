var http = require('http');
var querystring = require('querystring');
var fs = require('fs');
var url = require("url");

http.createServer(function(req, res){
    var post = '';     
	var bresponse='';
	console.log("request:",req.url);
if(req.url=="/REALDATA"){
	
	req.on('data', function(chunk){    
			post += chunk;
		});	
	
	req.on('end', function(){ 
	console.log('Request for save real data: '+post);
	//append the real sensor data to a file	
	  fs.appendFile('realdata.txt', post, (err) => {
	  if (err) throw err;
	  console.log('The "data to append" was appended to file!');
	}); 
	setTimeout(function(){
		res.writeHead(200, {'Content-Type': 'text/plain'});
		res.end("data saved");},100);	 
	 });
	 
}else{
	 req.on('data', function(chunk){    
			post += chunk;
		});
	req.on('end', function(){ 
		var time= new Date();
		console.log('Request from mobile: '+post);
		console.log('Time:' + time);
		
		// An object of options to indicate where to post to
		var post_options = 
		  {
			  host: '127.0.0.1',
			  port: '8080',
			  method: 'POST',
			  headers: 
			  {
				  'Content-Type': 'application/json',
				  'Content-Length': Buffer.byteLength(post)
				}
			};
		  
		  // Set up the request
		  var post_req = http.request(post_options, function(res)
		  {
			  res.setEncoding('utf8');
			  res.on('data', function (chunk) 
			  {
				 bresponse +=chunk;   
			  });
		  });
		  
		  // post the data
		  post_req.write(post);
		  post_req.end();
		  
		  // call the rest of the code and have it execute after 3 seconds
		setTimeout(function(){
			console.log('bresponse2'+bresponse);
			res.writeHead(200, {'Content-Type': 'text/plain'});
			res.end(bresponse);},100);

		 
		 });
	 }
}).listen(3000, '10.20.195.229');

	
	
	