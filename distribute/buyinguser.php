<?php

require_once (dirname(__DIR__).'/common/MysqliDb.php');

$db->connect();

$transactionslist = $db->rawQuery("select * from transaction_users_view where transaction_id = ?",Array($_GET['tid']) );

echo json_encode($transactionslist);

?>