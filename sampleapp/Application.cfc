<!---
*****************************************************
Copyright 2007 Rolando Lopez (www.rolando-lopez.com) 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except 
in compliance with the License.You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License. 
***************************************************** 
--->

<cfcomponent displayname="Application" output="false" extends="model.Object" >

	<cfscript>
		this.name = "environmentConfig";
		this.sessionManagement 	= false;
			//set EC mapping manually
		this.mappings["/environmentConfig"] = getDirectoryFromPath(getCurrentTemplatePath());


			//execute EnvironmentConfig
		variables.ecResults = createObject( 'component', 'environmentConfig.model.EnvironmentService' ).init().configureEnvironment( '/sampleApp/config/environment.xml.cfm' );
			//set dynamic mappings using EC
		
		structAppend(this.mappings,variables.ecResults.mappings);
	
	</cfscript>

	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="true" hint="Fires when the application is first created.">
		<cfscript>
			var stLocal = structNew();
			var ec		= structNew();
			stLocal.bError 					= false;
		</cfscript>
		<cfscript>
		//	writeDump(var:variables.ecResults,abort:true);
				//For sample app only, use selected option
			if( not stLocal.bError ){
				if( structKeyExists( variables.ecResults, 'ec' ) )
					ec = variables.ecResults.ec;
				else if(structKeyExists( variables.ecResults.stProperties, 'ec' ) )
					ec = variables.ecResults.stProperties.ec;
				
				if(structCount(ec)){
						//if flag to created coldspring file, assume we're using coldspring
					if(ec.bCreateColdSpringFile){
						Application.factory = createObject( "component","coldspring.beans.DefaultXmlBeanFactory" ).init(structNew(), variables.ecResults.stFlattened);
						Application.factory.loadBeansFromXmlFile( "#expandPath( ec.sColdSpringDefFilePath )#",true );
					}else if(ec.bCreateBeanFile)
						if( not ec.bUseFlattenedStruct)
							Application.oGlobalConfig = createObject( 'component', ec.sConfigBeanObjPath ).init(argumentCollection = variables.ecResults.stProperties);
						else
							Application.oGlobalConfig = createObject( 'component', ec.sConfigBeanObjPath ).init(argumentCollection = variables.ecResults.stFlattened);
					else if( not ec.bUseFlattenedStruct)
						Application.stGlobalProperties = variables.ecResults.stProperties;
					else
						Application.stGlobalProperties = variables.ecResults.stFlattened;
				}
			}
		</cfscript>
		<cfif stLocal.bError>
			<cfset ethrow( message="An error occurred while starting the Application", type="ecDemoError") />
		</cfif>
		<cfreturn true />
	</cffunction>

	<cffunction  name="OnRequestStart" access="public" returntype="boolean"  output="false" hint="Fires at first part of page processing.">
		<cfscript>
			structClear(application);
			onApplicationStart();
		</cfscript>
		<cfreturn true />
	</cffunction>
	<cffunction  name="OnRequest" access="public" returntype="boolean"  output="true" hint="Fires at first part of page processing.">
		<cfargument name="template" type="string" required="true" />
		
		<cfinclude template="#arguments.template#">
		<cfreturn true />
	</cffunction>
	
	<cffunction name="onError">
	   <!--- The onError method gets two arguments:
	         An exception structure, which is identical to a cfcatch variable.
	         The name of the Application.cfc method, if any, in which the error
	         happened. --->
	   <cfargument name="Except" required=true/>
	   <cfargument type="String" name = "EventName" required=true/>
	   <!--- Log all errors in an application-specific log file. --->
	   <cflog file="#This.Name#" type="error" text="Event Name: #Eventname#" >
	   <cflog file="#This.Name#" type="error" text="Message: #except.message#">
	   <!--- Throw validation errors to ColdFusion for handling. --->
	   <cfif Find("coldfusion.filter.FormValidationException",
	                Arguments.Except.StackTrace)>
	      <cfthrow object="#except#">
	   <cfelse>
	      <!--- You can replace this cfoutput tag with application-specific
	            error-handling code. --->
	      <cfoutput>
	         <p>Error Event: #EventName#</p>
	         <p>Error details:<br>
	         <cfdump var="#except#"></p>
	      </cfoutput>
	   </cfif>
	</cffunction>
</cfcomponent>