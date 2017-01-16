<?php

require_once (dirname(__DIR__).'/common/MysqliDb.php');

$db->connect();

$transactionslist = $db->rawQuery("select * from transaction_view");

echo json_encode($transactionslist);

?>