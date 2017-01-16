function precise_round(num,decimals) {
    var sign = num >= 0 ? 1 : -1;
    return (((num*Math.pow(10,decimals)) + (sign*0.001)) / Math.pow(10,decimals)).toFixed(decimals);
}

function checkStringEmpty(str,temp){
	if (str === "" ) return temp;
	return precise_round(str,2);
}