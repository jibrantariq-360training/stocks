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
$(document).ready(function (){
    getList();fillUser();calculateShare(); //getBuyingList();
		$(".glyphicon-trash").on("click",function(){
		$(this).parent().remove();
	});
});

function getBuyingList(){
	$.ajax({                                      
      url: 'distribute/buyinglist.php?sid=<?php echo $scrip_id;?>&tid=<?php echo $transaction_id;?>',              
      success:function(data) {
		if (data || data.length != 0 )
		appendInTable(jQuery.parseJSON(data));
      }
   });
}

function getList(){
	$.ajax({                                      
      url: 'distribute/list.php?tid=<?php echo $transaction_id;?>',              
      success:function(data) {
		if (data || data.length != 0 )
		appendInTable(jQuery.parseJSON(data, $("#list tbody") ));
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

function calculateShare(obj){
	
	$(".qty").on("blur",(function() {
		$(this).parent().siblings().children().val(precise_round( ($(this).val() * cost), 2));
	}));
}

function appendRow(){
		var row = $(".hide").clone(true,true).removeClass("hide");
		$("#uform").append(row);
}
function appendInTable(data,itable){
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
		tablerow += "<td><button onclick='appendRow();' class='glyphicon glyphicon-chevron-down'/></td>";
		tablerow += "</tr>";
		$("#list tbody").append(tablerow);
		actionName = row['action_name']; 
		price = row['price'];
		if ( actionName !== "BUY" && actionName !== "SELL") {
			$(".qty").prop('disabled', true);
		}else{
				cost = precise_round(row['a_value'] / row['qty'],4);
		}
			tCost = precise_round(row['a_value'],2);
		
	 });
}

function saveData(){
	var sum = 0.00 ;
	
	$(".form-control.value").each(function(){
		sum = precise_round ( parseFloat(sum) + parseFloat($(this).val() === '' ? 0 : $(this).val()),2 );
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
	  data: $("#uform").serialize()+'&price='+price+'&aname='+actionName+'&aid=<?php echo $action_id;?>&sid=<?php echo $scrip_id;?>&tid=<?php echo $transaction_id;?>',
      success:function(data) {
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
<span class="glyphicon glyphicon-trash"/>
</div>
<form id="uform" class="form-inline">

</form>
<button type="button" onclick="saveData();" class="btn btn-success">Save</button>
</div>
</body>

</html>