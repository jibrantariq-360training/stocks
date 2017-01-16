<html>

<head>

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

<script src="js/basic.js"></script>

<?php 


$scrip_id = $_GET['sid'];
$action_id = $_GET['aid'];
$transaction_id= $_GET['tid'];

?>
<script>
var cost = 0;
var tCost = 0;
var actionName='';
var price = 0;
var createdOn = '';
var btrans = 0;
var trans_ = 0;

$(document).ready(function (){
    getList();fillUser();calculateShare();
		$(".glyphicon-trash").on("click",function(){
		$(this).parent().remove();
	});
});

function showUsers(transaction_id){
	$.ajax({                                      
      url: 'distribute/buyinguser.php?tid='+transaction_id,              
      success:function(data) {
		if (data || data.length != 0 ) {
			$("#user_info tbody tr").remove();
			displayUsersDetail(jQuery.parseJSON(data));
			
		}
      }
   });
}
function displayUsersDetail(data){
	
	$.each(data, function (index, row) {
		tablerow = "<tr>";
		tablerow += "<td>"+row['name']+"</td>";
		tablerow += "<td>"+row['qty']+"</td>";
		tablerow += "</tr>";
		trans_ = row['transaction_id'];
		$("#user_info tbody").append(tablerow);
	});
	$("#user_info").removeClass("hide");
}
function getBuyingList(){
	$.ajax({                                      
      url: 'distribute/buyinglist.php?c_date='+createdOn+'&sid=<?php echo $scrip_id;?>&tid=<?php echo $transaction_id;?>',              
      success:function(data) {
		if (data || data.length != 0 )
		appendInTable(jQuery.parseJSON(data),-1);
      }
   });
}

function getList(){
	$.ajax({                                      
      url: 'distribute/list.php?tid=<?php echo $transaction_id;?>',              
      success:function(data) {
		if (data || data.length != 0 )
		appendInTable(jQuery.parseJSON(data),0);
      }
   });
}
function getFillSelect(data){
	$.each(data, function (index, row) {
		$('#user_selection').append($("<option></option>").attr("value",row['id']+'|'+row['balance']).text(row['name']+" [ "+row['balance']+" ]")); 
	});
}
function fillUser(){
	$.ajax({                                      
      url: 'users/list.php?sid=<?php echo $scrip_id;?>&tid=<?php echo $transaction_id;?>',              
      success:function(data) {
		if (data || data.length != 0 ){
			getFillSelect(jQuery.parseJSON(data));
		}
      }
   });
}

function calculateShare(){
	
	$(".qty").on("blur",(function() {
		$(this).parent().siblings().children().val(precise_round( ($(this).val() * cost), 7));
		val_ = $(this).siblings().val().split("|")[0];
		val_ = val_ + ';'+ trans_ + ';' + $(this).val();
		$(this).parent().parent().children("#tsq").val(val_);
		
	}));
}

function appendRow(){
		
		var row = $(".hide").clone(true,true).removeClass("hide");
		$("#uform").append(row);
}

function selectedRow(obj){
   $(obj).parent().parent().addClass("success").siblings().removeClass('success');
}
function appendInTable(data,num1){
	 $.each(data, function (index, row) {
		tablerow = "<tr>";
		tablerow += "<td>"+row['action_name']+"</td>";
		tablerow += "<td>"+row['scrip_name']+"</td>";
		tablerow += "<td>"+row['price']+"</td>";
		tablerow += "<td>"+row['qty']+"</td>";
		tablerow += "<td>"+row['tax1']+"</td>";
		tablerow += "<td>"+row['tax2']+"</td>";
		tablerow += "<td>"+row['comission']+"</td>";
		tablerow += "<td>"+row['a_value']+"</td>";
		tablerow += "<td>"+row['balance']+"</td>";
		tablerow += "<td>"+row['created_on']+"</td>";
		if (num1 != 0){
			tablerow += "<td><button onclick='showUsers("+row['transaction_id']+");selectedRow(this);' class='glyphicon glyphicon-ok'/></td>";
		}else{
			tablerow += "<td><button onclick='appendRow();' class='glyphicon glyphicon-chevron-down'/></td>";
			createdOn = row['created_on'];
		}
		tablerow += "</tr>";
		if (num1 != 0){
			$("#buylist tbody").append(tablerow);
		}else{
			$("#list tbody").append(tablerow);
			getBuyingList();
		}
		price = row['price'];
		actionName = row['action_name']; 
		if ( actionName === "SELL") {
			cost = precise_round(row['a_value'] / row['qty'],7);
			tCost = precise_round(row['a_value'],2);
			
		}
		
		
	 });
}

function saveData(){
	var sum = 0.00 ;
	
	$(".form-control.value").each(function(){
		console.log("Sum "+parseFloat(sum));
		console.log("Value "+ $(this).val());
		sum = precise_round ( parseFloat(sum) + parseFloat($(this).val() === '' ? 0 : $(this).val()),2);
	});
	  
	 if ( sum === tCost) { 
		 $(".hide").remove();
		 saveSubTransaction();
	 }else{
		 alert("Actual Value must be divided equally.");
	 }
}

function saveSubTransaction(){
	
	$.post({                                      
      url: 'users/savetransaction.php',
	  data: $("#uform").serialize()+'&btrans='+btrans+'&price='+price+'&aname=SELL&aid=<?php echo $action_id;?>&sid=<?php echo $scrip_id;?>&tid=<?php echo $transaction_id;?>',
      success:function(data) {
		console.log(data);
	    location.reload();
      }
   });
}

</script>
</head>
<body>

<div class="container-fluid">

<table id="list" class="table table-striped">
<thead>
<tr>
<th>Action</th>
<th>Scrip</th>
<th>Price</th>
<th>Qty</th>
<th>Tax1</th>
<th>Tax2</th>
<th>Commission</th>
<th>Actual Value</th>
<th>Balance</th>
<th>Created On</th>
<th></th>
</tr>
</thead>
<tbody>

</tbody>

</table>

<table id="buylist" class="table table-striped">
<thead>
<tr>
<th>Action</th>
<th>Scrip</th>
<th>Price</th>
<th>Qty</th>
<th>Tax1</th>
<th>Tax2</th>
<th>Commission</th>
<th>Actual Value</th>
<th>Balance</th>
<th>Created On</th>
<th></th>
</tr>
</thead>
<tbody>

</tbody>

</table>
<div></div>
<div class="hide" >
<div class="form-group">
<select id="user_selection" name="user[]" class="form-control"/>
</div>
<div class="form-group">
<input type="text" name="qty[]" class="form-control qty" placeholder="Quantity"/>
</div>
<div class="form-group">
<input type="text" name="a_value[]" class="form-control value" placeholder="Actual Value"/>
</div>
<input type="hidden" name="tsq[]" id="tsq" />
<span class="glyphicon glyphicon-trash"/>
</div>
<form id="uform" class="form-inline">

</form>
<button type="button" onclick="saveData();" class="btn btn-success">Save</button>
</div>

<div class="container">
<table id="user_info" class="table table-striped hide">
<thead>
<th>Users</th>
<th>QTY</th>
</thead>
<tbody>
</tbody>
</table>
</div>
</body>

</html>