<!--- ****************************************************
Copyright 2007 Rolando Lopez (www.rolando-lopez.com) 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except 
in compliance with the License.You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License. 
***************************************************** --->

<cfcomponent displayname="EnvironmentConfigAPI" hint="API to Environment Config. Use to leverage some of EC internal methods in your application" extends="Object" output="false">

		<!--- 	
		*************************************************************************
		init()
		************************************************************************
		--->																										
	<cffunction name="init" returntype="EnvironmentConfigAPI" output="No" hint="Class constructor">
		
			<!--- initialize variables --->
		<cfscript>		
			variables.ECService = createObject("component", "environmentConfig.model.EnvironmentService").init();
			return this;
		</cfscript>
	</cffunction>
	
		<!---
    	******************************************************************************** 
    	createBeanFromStruct()
    	@Author: Rolando Lopez 
    	@Date: 9/14/2010 
    	@Hint: Creates a Bean from a struct of properties and writes it to a CFC file
    	@Access: public
    	********************************************************************************
    	--->
    <cffunction name="createBeanFromStruct" output="false" access="public" returntype="struct" hint="Creates a ColdFusion Clas (CFC) from a struct of properties">
    	<cfargument name="properties" type="struct" required="true" hint="A Structure of properties. Getters and Setters will be generated based off these properties" />
		<cfargument name="path" type="string" required="false" default="/" hint="Relative path where the CFC will be written to. If not provided the CFC will be written to the root of your site" />
		<cfargument name="setterAccess" type="string" required="false" default="public" hint="The Access type for all set methods. Values accepted are 'Public','Package' or 'Private'. If not provided it defaults to Public"/>

    	<cfscript>	
    		try{
				return variables.ECService.createFiles(stProperties:arguments.properties, bCreateBeanFile:true, sConfigBeanObjPath:arguments.path, setterAccess:arguments.setterAccess);
    		}catch(any e){
    			//dump( e, true );
    			ethrow(  'Failed to: Creates a Bean from a struct of properties ','createBeanFromStruct' );
    		}	
    	</cfscript>
    </cffunction>
	
		<!---
    	******************************************************************************** 
    	createColdSpringConfigFile()
    	@Author: Rolando Lopez 
    	@Date: 9/14/2010 
    	@Hint: Creates a Bean from a struct of properties and writes it to a CFC file
    	@Access: public
    	********************************************************************************
    	--->
    <cffunction name="createColdSpringConfigFile" output="false" access="public" returntype="struct" hint="Creates the ColdSpring config file for a bean from a struct of properties">
    	<cfargument name="csFilePath" type="string" required="true" />
		<cfargument name="beanFilePath" type="string" required="true" />
		<cfargument name="properties" type="struct" required="true" />

    	<cfscript>	
    		try{
				return variables.ECService.createFiles(stProperties:arguments.properties, bCreateColdSpringFile:true, sConfigBeanObjPath:arguments.beanFilePath, sColdSpringDefFilePath:arguments.csFilePath);
    		}catch(any e){
    			//dump( e, true );
    			ethrow(  'Failed to: Creates a Bean from a struct of properties ','createBeanFromStruct' );
    		}	
    	</cfscript>
    </cffunction>
	
	
	
    	<!---
    	******************************************************************************** 
    	getEnvironmentRawXML()
    	@Author: Rolando Lopez 
    	@Date: 9/15/2010 
    	@Hint: Reads into memory and return the EnvironmentConfig XML file
    	@Access: public
    	********************************************************************************
    	--->
    <cffunction name="getEnvironmentRawXML" output="false" access="public" returntype="xml" hint="Reads into memory and return the EnvironmentConfig XML file">
    	<cfargument name="xmlFilePath" type="string" required="true" />
    	<cfscript>	
				return variables.ECService.getEnvironmentRawXML(xmlFilePath);
    	</cfscript>
    </cffunction>
</cfcomponent>