// step 1: inject jQuery 

var script = document.createElement('script');
script.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.6.3/jquery.min.js";
document.getElementsByTagName('head')[0].appendChild(script);

// step 2: get td

$("#pr_id_9-table td").each(function () {$(this).text}); 

// step 3: what td need?

1: td#xgemail-messages-history-v2-sender-0.xgemail-table-cell-md
2: td#xgemail-messages-history-v2-recipients-0.xgeamil-table-cell-sml
4: td#xgemail-messages-history-v2-subject-0.xgeamil-table-cell-sml.xgemail-table-column-divider
6: td#xgemail-messages-history-v2-date-0.xgemail-table-cell-s

// step 4 - profit

// sender

$(".xgemail-table-cell-md span").text().replace(/>/g, '>\n')

$(".xgemail-table-cell-md span").text(function(){
	var this_row = $(this).text;
	if(this.outerText.includes("SENDER")){} else {
	console.log(this.outerText);}
});

// recipient

$(".xgeamil-table-cell-sml span").text(function(){
	var this_row = $(this).text;
	if(this.outerText.includes("@")){
	console.log(this.outerText);}
});


// subject

$(".xgeamil-table-cell-sml a").text(function(){
	var this_row = $(this).text;
	console.log(this.outerText);
});


// date

$(".xgemail-table-cell-s span").text(function(){
	var this_row = $(this).text;
	if(this.outerText.includes("DATE")){} else {
	console.log(this.outerText);}
});
