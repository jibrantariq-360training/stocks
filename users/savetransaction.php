<?php

require_once (dirname(__DIR__).'/common/MysqliDb.php');

//print_r ($_POST);
if (isset($_POST['user'])){
	$user_arr = $_POST['user'];
}
if (isset($_POST['qty'])){
	$qty_arr = $_POST['qty'];
}
if (isset($_POST['a_value'])){
	$a_value = $_POST['a_value'];
}

$actionName = $_POST['aname'];
$aid =  $_POST['aid'];
$sid =  $_POST['sid'];
$tid = $_POST['tid'];
$price = $_POST['price'];
$btrans = 0;

if ( isset ($_POST['btrans'])  ) {
	$btrans = $_POST['btrans'];
}

$db->connect();

for ($x=0;$x<count($user_arr);$x++){
	 $i_qty = 0 ;
	 if (strcmp($actionName,"BUY") != 0 && strcmp($actionName,"SELL") != 0){
		 
	 }else{
		$i_qty =  $qty_arr[$x];
	 } 	
	 
	 $userBalance = explode("|",$user_arr[$x]);
	 $ibalance =  $userBalance[1] + $a_value[$x] ;
	 $query = "CALL subtransaction_sp($aid,$sid,$price,$i_qty,$a_value[$x],$ibalance,$tid,$userBalance[0],$btrans)";
	 //echo $query."\n";
     $db->rawQueryOne($query);
	 
}
 
if (strcmp($actionName,"SELL") == 0) {
	 if (isset($_POST['tsq'])){
		$tsq = $_POST['tsq'];
		for ($x=0;$x<count($tsq);$x++){
			$data = explode(";",$tsq[$x]);
			$_query = "CALL transaction_scrip_qty_sp($data[0],$data[1],$data[2])";
			$db->rawQueryOne($_query);
			//echo $_query."\n";
		}
	 }
}


/*
IN `i_action_name` INT(255)
IN `i_scrip` INT(255)
IN `i_price` DECIMAL(10,2)
IN `i_qty` INT(11)
IN `i_a_value` DECIMAL(20,2)
IN `i_balance` DECIMAL(20,2)
IN `i_transaction_id` INT(255)
IN `user_id`

*/
?>