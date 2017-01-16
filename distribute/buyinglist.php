<?php

require_once (dirname(__DIR__).'/common/MysqliDb.php');

$db->connect();

$transactionslist = $db->rawQuery("select t.* from transaction_view t LEFT JOIN transaction_users_view tu on tu.transaction_id = t.transaction_id  where (tu.qty > ? or tu.qty is null) and scrip_id = ? and action_id = ? and created_on < ?",Array(0,$_GET['sid'],1,$_GET['c_date']) );

echo json_encode($transactionslist);

?>