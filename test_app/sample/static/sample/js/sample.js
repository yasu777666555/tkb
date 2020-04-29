//Score
var selectedDate;
var scoreArray = [];
var scoreCard = document.getElementById("scoreCard");

//modal
var modal = document.getElementById("myModal");
var span = document.getElementsByClassName("close")[0];

// When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}

function openModal() {
  modal.style.display = "block";
  selectedDate = event.currentTarget.id
  console.log(selectedDate);
}

//Calender
const today = new Date();
const year = today.getFullYear();
const month = today.getMonth();
const firstdate = new Date(year, month, 1);
const lastdate = new Date(year, month + 1, 0);
var date = firstdate;
var dateArray = [];
const day = ["日","月","火","水","木","金","土"];

var calendarDiv = document.getElementById("calendar");

//Create Calender Table
var newTable = document.createElement("table");

//Create Calender Table Name Header
var newThead = document.createElement("thead");
var monthTr = document.createElement("tr");
var monthTh = document.createElement("th");
var monthTheader = document.createTextNode(month + 1);
monthTh.appendChild(monthTheader);
monthTr.appendChild(monthTh);
newThead.appendChild(monthTr);
newTable.appendChild(newThead);

//Create Calender Table Column  Header
var newTbody = document.createElement("tbody");
var dayTr = document.createElement("tr");
for (i = 0; i < day.length; i++) {
  var newElement = document.createElement("td");
  var newNode = document.createTextNode(day[i]);
  newElement.appendChild(newNode);
  dayTr.appendChild(newElement);
}
newTbody.appendChild(dayTr);
newTable.appendChild(newTbody);

//Create Calender Table Date Column
for (d = 1; date < lastdate; d++) {
   date = new Date(year, month, d);
   var checkday = date.getDay();

   if (d === 1 || checkday === 0) {
     var dateTr = document.createElement("tr");
   }
   if (d === 1) {
     var firstday = firstdate.getDay();
     for (dummy = 0; dummy < firstday; dummy++){
        var newElement = document.createElement("td");
        var newNode = document.createTextNode("");
        newElement.appendChild(newNode);
        dateTr.appendChild(newElement);
     }
   }

   var newElement = document.createElement("td");
   var newNode = document.createTextNode(date.getDate());
   newElement.appendChild(newNode);
   newElement.setAttribute("id",date.getDate());

   //Show modal
   //newElement.onclick = function() {
   //  modal.style.display = "block";
   //}
   //console.log(date);
   newElement.addEventListener("click", openModal, false)
   dateTr.appendChild(newElement);

   if (date.getDate() === lastdate.getDate() || checkday === 6){
     newTbody.appendChild(dateTr);
   };

   dateArray.push(date.getDate());
}

calendarDiv.appendChild(newTable);

/*
// csrf cookie jquery
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}


function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

$(document).on("click", "#sum", function() {
    var button = $(this);
    var csrf_token = getCookie("csrftoken");
        $.ajax({
           type: "POST",
           url: "http://127.0.0.1:8000/sample/",
           data: {
               "key1": "value1",
               "k2": "v2",
           },
           contentType: "application/json",
           // 送信前にヘッダにcsrf_tokenを付与。
           beforeSend: function(xhr, settings) {
                if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
                    xhr.setRequestHeader("X-CSRFToken", csrf_token);
                }
            },
            success: function(data) {
                alert(data);
            },
            error: function(xhr, status, error) {
                alert(status + "\n" +
                        "Status: " + xhr.status + "\n" + error);
            }
        });
    }
});


*/


// get  cookie
var COOKIES = COOKIES || {
    getCookie: function(cName) {
        if(cName != '' || cName != null) {
            var set_replace = '(?:(?:^|.*\s*)' + cName + '\s*\=\s*([^;]*).*$)|^.*$';
            return document.cookie.replace(new RegExp(set_replace), '$1');
        }
    },
    setCookie: function(cName, cValue, cTime) {
        var time = cTime ? (60 * 60 * 24) * cTime : '';
        if(cName != '' || cName != null) {
            document.cookie = cName + '=' + cValue + ';domain=' + location.hostname + ';max-age=' + time;
        }
    },
    deleteCookie: function(cName) {
        if(cName != '' || cName != null) {
            COOKIES.setCookie(cName, '', 0);
        }
    }
};

// HTMLフォームの形式にデータを変換する
function EncodeHTMLForm( data )
{
    var params = [];

    for( var name in data )
    {
        var value = data[ name ];
        var param = encodeURIComponent( name ) + '=' + encodeURIComponent( value );

        params.push( param );
    }

    return params.join( '&' ).replace( /%20/g, '+' );
}



// When the user clicks anywhere outside of the modal, close it
var btn = document.getElementById("sum");
btn.onclick = function() {
  var drinklevel = document.getElementById("drinklevel");
  var num = drinklevel.selectedIndex;
  var score = parseInt(drinklevel.options[num].value,10);
  modal.style.display = "none";
  scoreArray[selectedDate] = score;
  const reducer =(accumulater,currentValue) => accumulater + currentValue;
  var sum = scoreArray.reduce(reducer);

  scoreCard.firstChild.nodeValue = sum;

  //var newscoreCard = document.createTextNode(sum);

  console.log(score);
  console.log(scoreArray);

    //post
  var csrf_token = COOKIES.getCookie('csrftoken');
  var ajax= new XMLHttpRequest();
  var the_day=year+"-"+month+"-"+selectedDate
  var senddata = {"score":score,"date":the_day};
  ajax.open("POST","http://127.0.0.1:8000/sample/");
  ajax.setRequestHeader('content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
  ajax.setRequestHeader("X-CSRFToken", csrf_token);
  ajax.send(EncodeHTMLForm(senddata));
}

//var newElement = document.createElement("p");
//var newNode02 = document.createTextNode(dateArray);
//newElement.appendChild(newNode02);
//var calendarDiv = document.getElementById("calendar");
//calendarDiv.appendChild(newElement);




