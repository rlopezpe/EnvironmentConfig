	<!---
	*****************************************************
	Name: 				environment.cfc
	Description:		Main Component for Environment Configurator
	Authors:			Rolando Lopez
						roland@soft-itech.com
						www.rolando-lopez.com/tech
	Past Contributors:  Rob Gonda; Tom DeManincor; Paul Marcotte
	Date:				2007

	*****************************************************
	License: 	Copyright 2007 Rolando Lopez (www.rolando-lopez.com) 
				Licensed under the Apache License, Version 2.0 (the "License"); 
				you may not use this file except in compliance with the License.
				You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
				Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
				WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
				See the License for the specific language governing permissions and limitations under the License. 		
	--->

<cfcomponent name="environment" displayName="environment" hint = "Main Component for Environment Configurator." extends="Object" >
		<!---
		*************************************************************************
		Init
		************************************************************************
		--->

	<cffunction name = "init" returntype = "environment" output = "No" hint = "Class constructor" access="package">
		<cfargument name = "xmlFile" type = "string" required = "true"  />
		<cfscript>
			var theFile = '';
		</cfscript>

		<cftry>
			<cffile action="read" file="#expandPath( arguments.xmlFile )#" variable="theFile">
			<cfcatch type = "any" >
				<cfthrow type="ec.fileNotFound" message="unable to find xmlFile" />
			</cfcatch>
		</cftry>

		<cfif not isXML( theFile )>
			<cfthrow type="ec.notXml" message="#arguments.xmlFile# is not in valid XML format" />
		</cfif>
		<cftry>
			<cfscript>
				variables.instance = structNew();
				variables.instance.environmentXml  	= xmlParse( theFile );
			</cfscript>
			<cfcatch type="any">
				<cfthrow type="ec.xmlParseError" message="Error Parsing XML file #arguments.xmlFile# ">
			</cfcatch>
		</cftry>

		<cfreturn this />
	</cffunction>

		<!---
		**********************************************************************************
		getEnvironmentById
		Author: rolando.lopez - Date: 5/29/2007
		**********************************************************************************
		 --->

	<cffunction name = "getEnvironmentById" access = "package" output = "false" returntype = "struct" hint="Returns a structure of properties based on the environmentID parameter.">
		<cfargument name = "environmentID" type = "string" required = "true" hint="Environment ID as defined in the EnvironmentConfig XML config file."  />

		<cfscript>
			writeDump(var:"Loading properties from environment with ID: '#arguments.environmentID#'...", output:"console");
			var properties = structnew();
			var defaultEnvironment = '';
			var defaultPropertiesArray = arrayNew(1);
			var targetEnvironment = '';
			var targetPropertiesArray = arrayNew(1);
			var targetStruct = structNew();
			var ixKey = '';
			var aTemp = arrayNew(1);
			//Vars end
			defaultEnvironment	= xmlSearch( getXmlFile(), '/environments/default/' );
			targetEnvironment	= xmlSearch( getXmlFile(), '/environments/environment[@id="#arguments.environmentID#"]/' );
		</cfscript>

			<!--- validation --->
		<cfif not arrayLen( targetEnvironment ) >
			<cfthrow errorcode="ec.emptyArray" message="Attempted to evaluate an empty array of name selectedElem." type="ec.missingArrayElement">
		<cfelseif arrayLen( targetEnvironment[1].xmlChildren ) lte 1>
			<cfthrow errorcode="ec.missingArrayElement" message="Element 2 does not exists in array of name xmlChildren." type="ec.missingArrayElement">
		</cfif>

		<cftry>
		<cfscript>
			defaultPropertiesArray = defaultEnvironment[1].XmlChildren[1].XmlChildren;
			targetPropertiesArray = targetEnvironment[1].XmlChildren[arrayLen(targetEnvironment[1].XmlChildren)].XmlChildren;
			
			structAppend(properties,getArrayProperties(defaultPropertiesArray),false);
			targetStruct = getArrayProperties(targetPropertiesArray);
			for( ixKey in targetStruct ){
				if( not isStruct( targetStruct[ixKey] )){
					properties[ixKey] = targetStruct[ixKey];
				}
				else{
					if(not structKeyExists( properties, ixKey ))
						properties[ixKey] = structNew();
					structAppend( properties[ixKey], targetStruct[ixKey], true);
				}
			}
			
			populateVariablesWithValues(properties);

			properties = parseStructForCFMOutput(duplicate(properties));
			properties["environmentID"] = arguments.environmentID;
			//structAppend(properties,getArrayProperties(targetPropertiesArray),true);
			writeDump(var:"Properties loaded for: '#arguments.environmentID#' environment.", output:"console");
		</cfscript>

		<cfcatch type = "any" >
			<cfscript>
				if(listFirst(cfcatch.type,".") == 'ec')
						rethrow;
				throw(  message:'Failed to: get environment by id ',detail:cfcatch.detail );
			</cfscript>
		</cfcatch>
		</cftry>
		<cfreturn properties />
	</cffunction>

		<!---
		**********************************************************************************
		getEnvironmentByUrl
		Author: roland lopez - Date: 5/29/2007
		**********************************************************************************
		 --->

	<cffunction name = "getEnvironmentByUrl" access = "package" output = "false" returntype = "struct" hint="Returns a structure of properties based on the environment URL pattern.">
		<cfargument name = "serverName" type = "string" required = "true" hint="Environment URL Pattern as defined in the EnvironmentConfig XML config file." />
		<cfargument name = "serverIp" type = "string" required = "false" hint="The server's IP address. If passed the method will try match the environment by IP based on ip_patterns tag in the Environment xml file" />
		<cfscript>
			var propertiesArray	= arrayNew(1);
			var i = 0;
			var j = 0;
			var k = 0;
			var environmentUrl = '';
				//end of vars

			writeDump(var:"Starting getEnvironmentByURL...", output:"console");
			propertiesArray = xmlSearch( getXmlFile(), '/environments/environment' );

		</cfscript>

		<cfscript>
		//writeDump(var:"Checkpoint 1 getEnvironmentByURL...", output:"console");
			if( isArray( propertiesArray )){
				for(i=1; i lte arrayLen( propertiesArray ); i=i+1){
					if( isArray( propertiesArray[i].xmlChildren )){
						for(j=1; j lte arrayLen(propertiesArray[i].xmlChildren); j=j+1 ){
							if( structKeyExists(arguments,"serverIp") && propertiesArray[i].xmlChildren[j].xmlName eq 'ippatterns'){
								for( k=1; k lte arrayLen( propertiesArray[i].xmlChildren[j].xmlChildren); k=k+1){
									environmentIp = propertiesArray[i].xmlChildren[j].xmlChildren[k].xmlText;
									if( refindnocase( environmentIp, arguments.serverIp ))
										return getEnvironmentById( propertiesArray[i].xmlAttributes.id );
								}
							}else if( propertiesArray[i].xmlChildren[j].xmlName eq 'patterns' ){
								for( k=1; k lte arrayLen( propertiesArray[i].xmlChildren[j].xmlChildren); k=k+1){
									environmentUrl = propertiesArray[i].xmlChildren[j].xmlChildren[k].xmlText;
									if( refindnocase( environmentUrl, arguments.serverName ))
										return getEnvironmentById( propertiesArray[i].xmlAttributes.id );
								}
							}
						}
					}
				}
			}
		</cfscript>
		
		<cfreturn structNew() />
	</cffunction>

		<!---
		**********************************************************************************
		getArrayProperties
		Author: paul marcotte - Date: 3/27/2008
		**********************************************************************************
		 --->

	<cffunction name="getArrayProperties" access="private" output="false" returntype="struct" hint="Parses the XML attributes and return as struct. Updated on 3/2008 By P. Marcotte to handle map of properties.">
		<cfargument name="propArray" type="array" required="true">
		<cfscript>
			var i = 0;
			var j = 0;
			var value = "";
			var entriesArray = arraynew(1);
			var properties = structNew();
			var propertiesArray = arguments.propArray;

		</cfscript>
		<cfscript>
			//Vars end
			for( i = 1; i lte arrayLen( propertiesArray ); i = i+1 ){
				entriesArray = xmlsearch(propertiesArray[i],'map/entry');
				if (arraylen(entriesArray))
				{
					value = structnew();
					for (j = 1; j lte ArrayLen(entriesArray); j = j + 1)
					{
						value[entriesArray[j].XmlAttributes["key"]] = entriesArray[j].value.XmlText;
					}
				}
				else
				{
					value = trim(propertiesArray[i].XmlText);
				}
				properties[ propertiesArray[i].XmlAttributes.name ] = value;
			}
			return properties;
		</cfscript>
	</cffunction>


		<!---
		**********************************************************************************
		getXmlFile
		Author: roland lopez - Date: 5/29/2007
		**********************************************************************************
		 --->

	<cffunction name = "getXmlFile" access = "package" output = "false" returntype = "xml" hint="Returns the XML file.">
		<cfreturn variables.instance.environmentXml />
	</cffunction>
	<!---
		********************************************************************************
		parseCFMOutput()
		@Author: Rolando Lopez
		@Date: 5/11/2009
		@Hint: I parse text with pound signs (#) and evaluate it as CF output
		@Access: private
		********************************************************************************
		--->
	<cffunction name="parseCFMOutput" output="false" access="private" returntype="any" hint="I parse text with pound signs (##) and evaluate it as CF output">
		<cfargument name="inputString" type="string" required="true" />
		<cfscript>
			var stl 	= structNew();
			var ixPounds = 1;
			stl.aPounds = arrayNew(1);
			stl.poundsCount = 0;
			
			stl.stringToReplace = "";
		</cfscript>

		<cftry>
			<cfscript>
				stl.aPounds = reMatchNoCase("##{1}",inputString);
				stl.poundsCount = arrayLen(stl.aPounds);
				stl.removeStartPos = find("##",inputString);
				if(stl.removeStartPos > 1)
					stl.tokenPosStart	= 2;
				else
					stl.tokenPosStart	= 1;
				//stl.removeStartPos = 2;
				if(stl.poundsCount MOD 2 NEQ 0)
					ethrow( "Invalid pound sign found in string" & inputString &". A matching end pound is required or you need to escape the pound sign." );

				for(ixPounds; ixPounds <= stl.poundsCount; ixPounds++){
					stl.stringToReplace = getToken(inputString,stl.tokenPosStart,"##");
					//writeDump(var:stl,output:"console",format:"text");
					if(len(trim(stl.stringToReplace)))
						inputString = replace(inputString,"##"&stl.stringToReplace&"##",evaluate(stl.stringToReplace),"ALL");
					else
						inputString = replace(inputString,"##"&stl.stringToReplace&"##","##","ALL");
					stl.tokenPosStart = 2;
				}
			</cfscript>
			<cfcatch type="any">
				<cfscript>
					//todo: fix throw catch here
					if(listFirst(cfcatch.type,".") == 'ec')
						rethrow;
						writeDump(var:local,abort:false,label:"local");
						writeDump(var:cfcatch,abort:true,label:"cfcatch");
					ethrow(  'Failed to: Parse text with pound signs (##) and evaluate it as CF output ','ec.parseCFMOutput' );
				</cfscript>
			</cfcatch>
		</cftry>
		<cfreturn inputString />
	</cffunction>

		<!---
		********************************************************************************
		parseStructForCFMOutput()
		@Author: Rolando Lopez
		@Date: 5/12/2009
		@Hint: Loop over struct elements and parse them for CFM output
		@Access: private
		********************************************************************************
		--->
	<cffunction name="parseStructForCFMOutput" output="false" access="private" returntype="struct" hint="Loop over struct elements and parse them for CFM output">
		<cfargument name="inputStruct" type="struct" required="true" />
		<cfscript>
			var ixKey = "";
			var ixKey2= "";
			var stTmp = structNew();
		</cfscript>

			<cfscript>
				for (ixKey in inputStruct){
					if(not isStruct( inputStruct[ixKey] ))
						inputStruct[ixKey]=parseCFMOutput(inputStruct[ixKey]);
					else{
						stTmp = inputStruct[ixKey];
						for (ixKey2 in stTmp){
							stTmp[ixKey2]=parseCFMOutput(toString(stTmp[ixKey2]));

						}
					}
				}
			</cfscript>
		<cfreturn inputStruct />
	</cffunction>

		<!---
		********************************************************************************
		populateVariablesWithValues()
		@Author: Rolando Lopez
		@Date: 5/12/2009
		@Hint: I parse a structure looking for environment variables and replace the variables with the string values
		@Access: private
		********************************************************************************
		--->
		
	<cffunction name="populateVariablesWithValues" output="false" access="private" returntype="void" hint="I parse a structure looking for local environment variables and replace the variables with the string values">
		<cfargument name="inputStruct" type="struct" required="true" hint="pass by reference" />
		<cfargument name="subStruct" type="struct" required="false" />	
		<cfscript>
			var stl 	= structNew();
			stl.regex 	= "(\$\{{1}([_a-zA-Z0-9]+)\}{1})";
			stl.regexReturn = structNew();
			stl.stTemp  = structNew();
			writeDump(var:"Starting populateVars...", output:"console");
		</cfscript>

		<cftry>
			<cfscript>
				for (var ixKey in arguments.inputStruct){
					if(not isStruct( arguments.inputStruct[ixKey] )){
							replaceVariables(stl.regex,arguments.inputStruct,ixKey);
					}else{
						stl.stTemp = arguments.inputStruct[ixKey];
						for (var ixKey2 in stl.stTemp){
							replaceVariables(stl.regex,arguments.inputStruct,ixKey2);
							
						}
					}
				}
			</cfscript>
			<cfcatch type="any">
				<cfscript>
					if(listFirst(cfcatch.type,".") == 'ec')
						rethrow;
					ethrow(  'Failed to: parse a structure looking for environment variables and replace the variables with the string values ','ec.populateVariablesWithValues' );
				</cfscript>
			</cfcatch>
		</cftry>
	</cffunction>
	
		<!---
    	******************************************************************************** 
    	replaceVariables()
    	@Author: Rolando Lopez 
    	@Date: 9/19/2010 
    	@Hint: Replaces EC variables ${x} with the appropriate value. If a variable is not found an error is thrown
    	@Access: private
    	********************************************************************************
    	--->
		<!--- @todo: replace this entire method below for something more efficient. --->
    <cffunction name="replaceVariables" output="false" access="private" returntype="void" hint="Replaces EC variables ${x} with the appropriate value. If a variable is not found an error is thrown">
		<cfargument name="regexTest" type="string" required="true" />
		<cfargument name="inputStruct" type="struct" required="true" />
		<cfargument name="structKey" type="string" required="true" />
    	<cfscript>	
    		var stl = structNew();
			var ix	= 2;

    		try{
				stl.foundKey	= structFindKey(inputStruct, arguments.structKey,"all");
				stl.counter=0;
				stl.regexReturn = [];
				for(var ixKey=1; ixKey <= arrayLen(stl.foundKey); ixKey++ ){
					arrayAppend(stl.regexReturn, rematchNocase(arguments.regexTest,stl.foundKey[ixKey].value));
					
					// while(stl.regexReturn[ixKey]["len"][1] >0){
					if(listLen(stl.foundKey[ixKey].path,'.') gt 1){
						stl.ownerStruct = evaluate("arguments.inputStruct#listDeleteAt(stl.foundKey[ixKey].path,listLen(stl.foundKey[ixKey].path,'.'),'.')#");
						stl["structReplaced"] = stl.ownerStruct[listLast(stl.foundKey[ixKey].path,'.')];
					}else{
						stl.ownerStruct = arguments.inputStruct;
						stl["structReplaced"] = arguments.inputStruct[right(stl.foundKey[ixKey].path,len(stl.foundKey[ixKey].path)-1)];
					}

					for(var ixMatch in stl.regexReturn[ixKey]){

							stl.varName = mid(ixMatch, 3, (len(trim(ixMatch))-2)-1);
								// writeDump(var:"replacing " & ixMatch & " as " & stl.varName, output:"console");
							stl.aVarValue = structFindKey(arguments.inputStruct,stl.varName,"all");

							if(arrayLen(stl.aVarValue)){
							// writeDump(var:"Value found as : " & stl.aVarValue[1].value, output:"console");

								replaceVariables(arguments.regexTest,arguments.inputStruct,stl.varName);
								if(listLen(stl.foundKey[ixKey].path,'.') gt 1){
									stl["structReplaced"] = replaceNoCase(stl["structReplaced"],"${"&stl.varName&"}",stl.aVarValue[1].value,"ALL");
									stl["structReplaced"] = parseCFMOutput(toString(stl.structReplaced));
								}else{
									stl["structReplaced"] = replaceNoCase(stl["structReplaced"],"${"&stl.varName&"}",stl.aVarValue[1].value,"ALL");
								}	
								stl.ownerStruct[ARGUMENTS.structKey]	= stl.structReplaced;						
								// writeDump("replaced: " & stl["structReplaced"] & "<br />");
							}
							else{
								ethrow("ERROR: #stl.varName# property Variable in '" & arguments.inputStruct[arguments.structKey] & "' does not exist. Verify that this property is defined in the environment XML file.","ec.variableNotExist");
							}
					}	
					// } // while end
				}
    		}
			catch(ec.variableNotExist e){
				rethrow;
			}
			catch(any e){
				/* dump(local);
				abort; */
    			// dump( e, true);
    			ethrow(  'Failed to: Replace EC variables ${x} with the appropriate value. If a variable is not found an error is thrown ','ec.replaceVariables' );
    		}	
    	</cfscript>
    </cffunction>
</cfcomponent>