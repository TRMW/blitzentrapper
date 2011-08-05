// JavaScript Document
var RADIO_OFFERS = {
    'blitzen-digi1' : {aId:11912,cId:10146938,persist:true},
    'blitzen-cd1' : {aId:11912,cId:10146935,persist:true},
	'dawes-digi1' : {aId:11912,cId:10146930,persist:true},
    'dawes-cd1' : {aId:11912,cId:10146927,persist:true},
    'dawes-lp1' : {aId:11912,cId:10146929,persist:true},
	'dawes-digi2' : {aId:11912,cId:10146933,persist:true},
    'dawes-cd2' : {aId:11912,cId:10146931,persist:true},
    'dawes-lp2' : {aId:11912,cId:10146932,persist:true},
};

function radioValue (radioGroup) {
    if (radioGroup)
    {
        for (var i = 0; i < radioGroup.length; i++)
        {
            if (radioGroup[i].checked)
            {
                var retVal = radioGroup[i].value;
                radioGroup = null;
                return retVal;
            }
        }
    }
    return null;
};

function radioSelect (formRef) {
    var radios = formRef;
    var value = radioValue(radios);
    if (value === null) {
        alert("Please select a package.");
    }
    var initHash = RADIO_OFFERS[value];
    if (initHash) {
        TSPurchase.load(initHash);
    }
}