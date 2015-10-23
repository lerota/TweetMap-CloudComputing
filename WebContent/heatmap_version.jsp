<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>TweetMap</title>
    <style>
      html, body, #map-canvas {
        height: 100%;
        margin: 0px;
        padding: 0px
      }
      #panel {
        position: absolute;
        top: 5px;
        left: 50%;
        margin-left: -180px;
        z-index: 5;
        background-color: #fff;
        padding: 5px;
        border: 1px solid #999;
      }
      div.absolute{
      	position: absolute;
 	 	top: 230px;
 	  	left: -200px;
  	 	width: 400px;
  	 	height:200px; 
      }
      
    </style>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true&libraries=visualization"></script>
    
    <script src="//code.jquery.com/jquery-1.11.2.min.js"></script>
	<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
    
    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="css/clean-blog.min.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href='http://fonts.googleapis.com/css?family=Lora:400,700,400italic,700italic' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800' rel='stylesheet' type='text/css'>
    
    <script>   
    var finance;
    var entertainment;
    var sports;
    var technology;
    var stringObj = ['Finance','Entertainment','Sports','Technology'];
    var numberObj = [0,0,0,0];

	var map, pointArray, heatmap;
	var taxiData = [];
	var layers = [];

	var chatClient = new WebSocket("ws://52.91.63.118:8080/aws");

	var markers = [];

	var curKW = "";
	var reset = false;

	chatClient.onopen = function(){
		setInterval(function(){
			if (reset){
				if(layers.length>0){
					for(i=0;i<layers.length;i++){
						layers[i].setMap(null);
						layers[i] = null;
					}
					layers = [];
				}
				reset = false;
			}
			chatClient.send(curKW);
		},3000);
	}

	chatClient.onmessage = function(evt) {
		taxiData = [];
		stringObj = [];
		numberObj = [];
	    var rawString = evt.data;
	  	var rawJSON = JSON.parse(rawString);
	    for (var loc in rawJSON){
	    	var lat = rawJSON[loc].latitude;
	    	var lng = rawJSON[loc].longitude;
	    	 finance = Number(rawJSON[loc].finance);
	 		 entertainment = Number(rawJSON[loc].entertainment);
	 		 sports = Number(rawJSON[loc].sports);
	 		 technology = Number(rawJSON[loc].technology);
	    	if(lat&&lng){
	    		var latlng = new google.maps.LatLng(lat,lng);
	    		taxiData.push(latlng);
	    	}
	  	}
	    stringObj.push('Finance');
	    numberObj.push(finance);
	    stringObj.push('Entertainment');
	    numberObj.push(entertainment);
	    stringObj.push('Sports');
	    numberObj.push(sports);
	    stringObj.push('Technology');
	    numberObj.push(technology);
	    console.log(taxiData)
	    if(taxiData){
	    	pointArray.clear();
	    	for (i=0; i<taxiData.length; i++){
	    		pointArray.push(taxiData[i]);
	    	}
	    }
	}

	function kwselect(kw){
		reset = true;
		taxiData = [];
		curKW = kw;
	}

	function initialize() {
	  var mapOptions = {
	    zoom: 2,
	    center: new google.maps.LatLng(46, 0),
	    mapTypeId: google.maps.MapTypeId.ROADMAP,
	    noClear:false
	  };
	
	  map = new google.maps.Map(document.getElementById('map-canvas'),
	      mapOptions);
	
	  pointArray = new google.maps.MVCArray(taxiData);
	
	  heatmap = new google.maps.visualization.HeatmapLayer({
	    data: pointArray
	  });
	
	  heatmap.setMap(map);
	}

	google.maps.event.addDomListener(window, 'load', initialize);
    </script>  
     
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>    
    <script type="text/javascript">
	  google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(init);

      function init(){
    	  var data = new google.visualization.DataTable();
    	  data.addColumn('string', 'Trend');
          data.addColumn('number', 'Number');
          for(i = 0; i < stringObj.length; i++)
              data.addRow([stringObj[i], numberObj[i]]); 
          var options = {
                  backgroundColor: 'transparent',
            	  fontName:'Arial',
            	  slices: [{color: '#A4D3EE',offset:0.1}, {color: '#B0E2FF',offset:0.2}, {color: '#C3E4ED',offset:0.05}, {color: '#42C0FB',offset:0.05}],   
          		  legendTextColor: 'white',
          		  legend: {position:'none'}
          		  };
          var chart = new google.visualization.PieChart(document.getElementById('piechart'));
          var button = document.getElementById('dropdownMenu1');
          function drawChart() {
       		button.disabled = true;
              google.visualization.events.addListener(chart, 'ready',
                    function() {
                      button.disabled = false;
                    });
              chart.draw(data, options);
          }
          drawChart();

          button.onclick = function() {
        	  kwselect('ok');
              data = new google.visualization.DataTable();
              data.addColumn('string', 'Trend');
              data.addColumn('number', 'Number');
              console.log(data)
              for(i = 0; i < stringObj.length; i++)
                  data.addRow([stringObj[i], numberObj[i]]);
              drawChart();
          }
     }          
     </script>
  </head>

  <body>
  <!-- Navigation -->
    <nav class="navbar navbar-default navbar-custom navbar-fixed-top">
        <div class="container-fluid">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header page-scroll">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
            </div>
        </div>
        <!-- /.container -->
    </nav>

    <!-- Page Header -->
    <!-- Set your background image for this header on the line below. -->
    <header class="intro-header" style="background-image: url('img/home-bg.png')">
        <div class="container">
            <div class="row">
                <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
                    <div class="site-heading" style="color:#FFF; text-shadow: 0 0 20px #5bc0de">
                        <h1>TweetMap</h1>
                        <hr class="small">
                        
                        <div class="absolute" id="piechart" style="width: 400px; height: 200px"></div>
  						<div class="btn-group" style="top:140px; right:80px">
  						<button class="btn btn-info dropdown-toggle" type="button" id="dropdownMenu1" aria-expanded="true">
    						Show Trends
  						</button> </div>                        
                        <div class="btn-group" style="top:140px; left:40px">
  						<button class="btn btn-info dropdown-toggle" type="button" id="dropdownMenu2" data-toggle="dropdown" aria-expanded="true">
    						Choose the Keyword
    						<span class="caret"></span>
  						</button>
  						<ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu2" style="left:50px">
  						<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('football')">Football</a></li>
  						<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('Taylor Swift')">Taylor Swift</a></li>
  						<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('Accenture')">Accenture LLC.</a></li>
  						<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('apple')">Apple</a></li>
  						</ul>
  						</div>
  						<div class="btn-group" style="top:140px; left:130px">
  						<button class="btn btn-info dropdown-toggle" type="button" id="dropdownMenu3" data-toggle="dropdown" aria-expanded="true">
    						Choose the Category
    						<span class="caret"></span>
  						</button>
  						<ul class="dropdown-menu" role="menu" aria-labelledby="dropdownMenu3" style="left:50px">
    					<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('finance')">Finance</a></li>
    					<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('technology')">Technology</a></li>
    					<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('sports')">Sports</a></li>
    					<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('entertainment')">Entertainment</a></li>
    					<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="text-align:center" onclick="kwselect('all')">All</a></li>
  						</ul>
						</div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
        <div id="map-canvas" style="margin-top:0px;"> </div>
    <hr>

    <!-- Footer -->
    <footer>
        <div class="container">
            <div class="row">
                <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">
                    <ul class="list-inline text-center"> </ul>
                    <p class="copyright text-muted">Copyright &copy; 2015</p>
                </div>
            </div>
        </div>
    </footer>

    <!-- jQuery -->
    <script src="js/jquery.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="js/bootstrap.min.js"></script>

    <!-- Custom Theme JavaScript -->
    <script src="js/clean-blog.min.js"></script>

</body>

</html>