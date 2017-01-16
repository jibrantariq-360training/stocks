$(document).ready(function (){
    getList();
	$(".i").blur(function() {
		if ( $("#actiontype").val() !== "BUY" && $("#actiontype").val() !== "SELL")  {
			fillBalance();
		}else{
			calculate();
		}	
	});
});
function fillBalance(){
	avalue = checkStringEmpty($("#a_value").val(),"0");
	balance = checkStringEmpty($("#spanbal").text(),"0");
	if ( $("#actiontype").val() === 'CASH Inject') {
		balance = parseFloat(avalue) + parseFloat(balance);
	}else{
		balance = parseFloat(balance) - parseFloat(avalue) ;
	}
	$("#balance").val(precise_round(balance,2));
	
}
function saveData(){
	
	$.post({                                      
      url: 'admin/insert.php', 
	  data:$("#transaction_form").serialize(),
      success:function(data){
		 clearTable();
		 getList();
		 
	  }
   });
	
}
function clearTable(){
	
	$("#list tbody").children().remove();
	$("#transaction_form").find("input[type=text]").val("");
}
function getList(){
	$.ajax({                                      
      url: 'admin/list.php',              
      success:function(data) {
		if (data || data.length != 0 )
		appendInTable(jQuery.parseJSON(data));
      }
   });
}
function appendInTable(data){
	 $.each(data, function (index, row) {
		 if (index == 0) { 
		 $(".bal").val(row['balance']);
		 $("#spanbal").text(row['balance']);
		 }
		if (row['completed'] == 1) {
		tablerow = "<tr class='success'>";	
		} else{
		tablerow = "<tr>";	
		}
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
	    if (row['action_name'] === 'SELL'){
			tablerow += "<td><a class='glyphicon glyphicon-random' href='selldistribute.php?sid="+row['scrip_id']+"&aid="+row['action_id']+"&tid="+row['transaction_id']+"'></td>";	
		}else{
			tablerow += "<td><a class='glyphicon glyphicon-random' href='distribute.php?sid="+row['scrip_id']+"&aid="+row['action_id']+"&tid="+row['transaction_id']+"'></td>";	
		}
		
		tablerow += "</tr>";
		$("#list tbody").append(tablerow);
	 });
}

function calculate(){
	minus = false;
	if ( $("#actiontype").val() === "BUY" ) {
		minus = true;
	}
	price = checkStringEmpty($("#price").val(),"0");
	qty = checkStringEmpty($("#qty").val(),"0");
	tax1 = checkStringEmpty($("#tax1").val(),"0");
	tax2 = checkStringEmpty($("#tax2").val(),"0");
	balance = checkStringEmpty($("#spanbal").text(),"0");
	if (price < 49.99) {
		commission = 0.03 * qty;
	}else if(price > 49.99 && price < 99.99) {
		commission = 0.05 * qty;
	}else{
		commission = 0.0005 * (price * qty) ;
	}
	if (minus){ 
		tempvalue = - (price * qty) - tax1 - tax2 - commission ; 
	}
	else {
		tempvalue = (price * qty) - tax1 - tax2 - commission;
	}
	tempvalue = precise_round(tempvalue,2)
	balance = parseFloat(balance) + parseFloat(tempvalue);
	
	$("#commission").val(precise_round(commission,2));
	$("#a_value").val(tempvalue);
	$("#balance").val(precise_round(balance,2));
	
}