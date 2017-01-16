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
<script src="js/admin.js"></script>
</head>
<body>


<div>
<form class="form-horizontal" id="transaction_form">
<table class="table">
<tbody>
<tr>
<td>
<select id="actiontype" name="action" class="form-control" style="margin-right: 30px;!important">
  <option value="BUY">BUY</option>
  <option value="SELL">SELL</option>  
  <option value="CASH Inject">INJECT</option>
  <option value="CASH Withdraw">WITHDRAW</option>
  <option value="CGT Deduction">CGT</option>
  <option value="CDC Deduction">CDC</option>
</select>
</td>
<td>
<input type="text" class="form-control" name="scrip" id="scrip" placeholder="Scrip"/>
</td>
<td>
<input type="text" class="form-control i" name="price" id="price" placeholder="Price"/>
</td>
<td>
<input type="text" class="form-control i" name="qty" id="qty" placeholder="Qty"/>
</td>
<td>
<input type="text" class="form-control i" name="tax1" id="tax1" placeholder="Tax1"/>
</td>
<td>
<input type="text" class="form-control i" name="tax2" id="tax2" placeholder="Tax2"/>
</td>
<td>
<input type="text" class="form-control" name="comission" id="commission" placeholder="Commission"/>
</td>
<td>
<input type="text" class="form-control i" name="a_value" id="a_value" placeholder="Actual Value"/>
</td>
<td>
<input type="text" class="form-control bal" name="balance" id="balance" placeholder="Balance"/>
<div class="text-center small initialism"> Prev # <span id="spanbal"></span></div>
</td>
<td>
<button type="button" onclick="saveData();" class="btn btn-success">Submit</button>
</td>
<td>
</td>
</tr>
</tbody>
</table>
</form>

</div>


<div class="table-responsive">
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
</div>

</body>

</html>