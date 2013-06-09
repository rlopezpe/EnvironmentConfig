<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<cfscript>
	if(structKeyExists(application,'stGlobalProperties')){
		output		= 'You just loaded the  <span class="highlight b">#Application.stGlobalProperties.environmentID#</span> environment and you''re using the <span class="highlight b">structure</span> of properties.';
		dump  		= Application.stGlobalProperties;
		label		= "Structure of Properties]";
		expand 		= true;
		dumpCode	= "Application.stGlobalProperties;"; 
	}else if(structKeyExists( Application, 'oGlobalConfig')){
		output		= 'You just loaded the <span class="highlight b">#Application.oGlobalConfig.getEnvironmentID()#</span> environment and you''re using the generated properties <span class="highlight b">#getMetaData(Application.oGlobalConfig).fullname#</span> bean, loaded into the <span class="highlight b">Application scope</span>.';
		dump  		= Application.oGlobalConfig;
		label		= "GlobalConfig Object";
		expand 		= false;
		dump2		= Application.oGlobalConfig.getMemento();
		label2 		= "getMemento() - From Application scope";
		dumpCode 	= "Application.oGlobalConfig;";
		dump2Code 	= "Application.oGlobalConfig.getMemento();";
	}else if (structKeyExists( Application, 'factory') and application.factory.containsBean('GlobalConfig')){
		output	= 'You just loaded the <span class="highlight b">#Application.factory.getBean("GlobalConfig").getEnvironmentID()#</span> environment	and you''re using the generated properties <span class="highlight b">#getMetaData(Application.factory.getBean("GlobalConfig")).fullname#</span> bean, loaded via <span class="highlight b">ColdSpring</span>';
		dump  	= Application.factory.getBean('GlobalConfig');
		label	= "GlobalConfig Object";
		expand 	= false;
		dump2	=Application.factory.getBean('GlobalConfig').getMemento();
		label2 	= "getMemento() - Memento From Object Factory";
		dumpCode 	= "Application.factory.getBean('GlobalConfig');";
		dump2Code 	= "<cfdump var=""Application.factory.getBean('GlobalConfig').getMemento();"">";
	}
</cfscript>
<html>
<head>
	<title>Environment Config 1.3</title>
	<meta name="keywords" content="">
	<link type="text/css" rel="stylesheet" href=sample.css />
</head>
<body>
	<div class="h2 b">
		Environment Config 1.3
	</div>
	<div class="h3">
		Notice the generated mappings in the This scope:
    </div>
	<div class="h3">
		<cfdump var="#this#" label="Application This scope">
    </div>
<cfoutput>
	<div class="h3">
		#output#
	</div>
	<div class="h3">
		<span class="code">#dumpCode#</span>
		<cfdump var="#dump#" label = "#label#" expand="#expand#" />
		<cfif structKeyExists(variables,"dump2")>
			<span class="code">#dump2Code#</span>
			<cfdump var="#dump2#" label="#label2#"  />
		</cfif>
	</div>
</cfoutput>
	
</body>
</html>