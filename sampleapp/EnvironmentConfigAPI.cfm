ý<html>
	<head>
		<title>Environment Config 1.3 API</title>
		<meta name="keywords" content="">
		<link type="text/css" rel="stylesheet" href=sample.css />
	</head>
	<body>
		<div class="h2 b">
			Environment Config 1.3 API
		</div>
		<div class="h3">
			<strong style="color:EFEFEF;">EnvironmentConfig API</strong> allows you to leverage some of it's core methods in your own applications. As of now 
			two methods are exposed that you can use: 
			<ul>
				<li>
					<div><span class="b">createBeanFromStruct</span>(Struct <span class="i">properties</span>, String <span class="i">path</span>, String <span class="i">setterAccess</span>)</div>
					<div>
                    	Allows to create your own ColdFusion Bean class (CFC) based on a structure with properties to disk. 
						It takes three parameters: a structure of properties, the path were the CFC will be stored and the type of access you want the setter methods to have (e.g. public, private, package).
                    </div>
				</li>
				<li>
					<div><span class="b">createColdSpringConfigFile</span>(Struct <span class="i">properties</span>, String <span class="i">beanFilePath</span>, String <span class="i">csFilePath</span>)</div>
					<div>
						Generates a ColdSpring definition file for a bean based on a structure of properties and writes it to disk. The import line in the main
						ColdSpring definition file must be manually written .
					</div>
				</li>
			</ul>
			
		</div>
		<div class="h3">
        	<div>Let's see some examples:</div>
			<div>
			Let's say you have a structure with user information such as name, email, loginName, password, company, address, city and state.  You can use EC's API to create a CFC
			based on that structure and EC will generate all the properties, getters & setters needed for you.
			</div>
        </div>

		<cfscript>
			import model.*;
				//User Structure. This structure will be used to dynamically generate a bean file and the ColdSpring definition file for the bean.
				//Add more properties or change the values to see it in action. 
			user = structNew();
			user["id"]			= createUUID();
			user["name"] 		= "Rolando Lopez";
			user["email"]		= "rolando.lopez@aboutweb.com";
			user["loginName"]	= "rlopez";
			user["company"]		= "AboutWeb";
			user["address"]		= "6177 Executive Blvd.";
			user["city"]		= "Rockville";
			user["state"]		= "MD";
			user["startDate"]	= dateFormat(now(),"mm/dd/yyyy");
			//user["myProperty"]  = "Create me new CFC and ColdSpring Files";
			
			writeOutput("<div class='h3' style='width:600'>Here's a basic user structure:
<pre class='code'>
user = structNew();
user[""name""] 		= ""Rolando Lopez"";
user[""email""]		= ""rolando.lopez@aboutweb.com"";
user[""loginName""]	= ""rlopez"";
user[""password""] 	= ""CACFUG"";
user[""company""]		= ""AboutWeb"";
user[""address""]		= ""6177 Executive Blvd."";
user[""city""]		= ""Rockville"";
user[""state""]		= ""MD"";
</pre>
			");
			writeDump(var:user,abort:false,label:"user structure");
			writeOutput(" </div>");
				//initialize an instance of the EnvironmentConfig API
			try{
				writeOutput("<div class='h3' style='width:800'>Initializing EnvironmentConfig API... 
<pre class='code'>
ecAPI = createObject(""component"", ""environmentConfig.model.EnvironmentConfigAPI"").init();
</pre>				
				
				");
				ecAPI = createObject("component", "environmentConfig.model.EnvironmentConfigAPI").init();
				writeOutput("Successful!");
			}catch( any e ){
				writeOutput("Failed to initialized EC API: #e.message#");
			}
				//Dump ecAPI
			writeDump(var:ecAPI,abort:false,label:"ecAPI" expand="false" );
			writeOutput("</div>");
			
				//create the bean from the user structure
			try{
				writeOutput("<div class='h3' >Now we tell the EnvironmentConfig API to create the Bean class for us. <br /><br />Creating bean class...
<pre class='code'>
createBeanResults 	= ecAPI.<span class='b'>createBeanFromStruct</span>(properties:user, path:""sampleApp.com.User"", setterAccess:""public"");
</pre>				
				
				 ");
				createBeanResults 	= ecAPI.createBeanFromStruct(properties:user, path:"sampleApp.com.User", setterAccess:'public');
				writeOutput("Successful!");
			}catch( any e ){
				writeOutput("Failed to create bean class: #e.message#");
			}
			writeOutput("</div>");
			
		

			
				//writeDump(createBeanResults);
				//writeDump(createCSFileResults);
			
				//Initialize User Object
			try{
				writeOutput("<div class='h3'>Initializing the User object... 
<pre class='code'>
oUser = createObject(""component"", ""sampleApp.com.User"").init(argumentCollection:user);
</pre>				
				");
				oUser = createObject("component", "sampleApp.com.User").init(argumentCollection:user);
				writeOutput("Successful!");
				writeDump(var:oUser,abort:false,label:"oUser",expand="false" );
			}catch( any e ){
				writeOutput("Failed to initialize the User object: #e.message#");
			}
			writeOutput("</div>");

				//Get User Object State 1
			writeOutput("<div class='h3'>Getting the User object current state
<pre class='code'>
oUser.getMemento();
</pre>			
			");	
			writeDump(var:oUser.getMemento(),abort:false,label:"oUser: Rolando Lopez");
			
			writeOutput("</div>");
			
			
			try{
				writeOutput("<div class='h3'>Changing the User object name property to 'Joe Doe' and address to '2001 Tyler St.'
<pre class='code'>
oUser.setName(""Joe Doe"");
oUser.setAddress(""2001 Tyler St."");
</pre>				
				");
				oUser.setName("Joe Doe");
				oUser.setAddress("2001 Tyler St.");
				writeOutput("Successful!");
			}catch( any e ){
				writeOutput("<span class='error'>Failed change the User object name property: #e.message#</span>");
			}
			writeOutput("</div>");
				//Get User Object State 2
			writeOutput("<div class='h3'>Getting the User object current state
<pre class='code'>
oUser.getMemento();
</pre>			
			");	
			writeDump(var:oUser.getMemento(),abort:false,label:"oUser: Joe Doe");
			writeOutput("</div>");
				//create the ColdSpring definition file from the user structure
			try{
				writeOutput("<div class='h3'>Now that you have your User class, if you are using ColdSpring you can tell EnvironmentConfig to 
				generate the ColdSpring definition file for you.<br /><br />Creating ColdSpring definition file for User bean... <br />
<pre class='code'>
createCSFileResults	= ecAPI.<span class='b'>createColdSpringConfigFile</span>(properties:user, beanFilePath:""sampleApp.com.User"", csFilePath:""/sampleApp/config/user.xml""); 
</pre>
");
csFilePath = "/sampleApp/config/user.xml";
				createCSFileResults	= ecAPI.createColdSpringConfigFile(properties:user, beanFilePath:"sampleApp.com.User", csFilePath:csFilePath);
				writeOutput("Successful!<br /> <a href='#csFilePath#' target='_blank'>#csFilePath#</a>");
			}catch( any e ){
				writeOutput("Failed to create ColdSpring definition file: #e.message#");
			}
			writeOutput("</div>");
			
						
		</cfscript>

	</body>
</html>