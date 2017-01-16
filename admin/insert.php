<?php

require_once (dirname(__DIR__).'/common/MysqliDb.php');

$db->connect();
/*
i_action_name
i_scrip
i_price
i_qty
i_tax1
i_tax2
i_comission
i_a_value
i_balance
o_transaction_id 
action_type
i_transaction_id
*/
$action = '';
$scrip = '';
$price = '0';
$qty = '0';
$tax1 = '0';
$tax2 = '0';
$comission = '0';
$a_value = '';
$balance = '';

if ( isset( $_POST["action"]  ) ) {
 $action = ($_POST['action']);
}
if ( isset( $_POST['scrip'] ) ) {
 $scrip = ($_POST['scrip']);
}
if ( isset( $_POST['price'] ) && !empty($_POST['price']) ) {
 $price = ($_POST['price']);
}
if ( isset( $_POST['qty'] ) && !empty( $_POST['qty'] )) {
 $qty = ($_POST['qty']);
}
if ( isset( $_POST['tax1'] ) && !empty( $_POST['tax1'] ) ) {
 $tax1 = ($_POST['tax1']);
}
if ( isset( $_POST['tax2'] ) && !empty( $_POST['tax2'] ) ) {
 $tax2 = ($_POST['tax2']);
}
if ( isset( $_POST['comission'] ) && !empty( $_POST['comission'] ) ) {
 $comission = ($_POST['comission']);
}
if ( isset( $_POST['a_value'] ) ) {
 $a_value = ($_POST['a_value']);
}
if ( isset( $_POST['balance'] )  ) {
 $balance = ($_POST['balance']);
}

$query = "CALL transaction_sp('$action','$scrip',$price,$qty,$tax1,$tax2,$comission, $a_value,$balance, @p9, 'INSERT', 0)";
$db->rawQuery($query);








?>