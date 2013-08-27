<!--- ****************************************************
Copyright 2007 Rolando Lopez (www.rolando-lopez.com) 
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License. 
***************************************************** --->

<cfcomponent displayname="EnvironmentService" hint="Main Service for EnvironmentConfig." output="false" extends="Object" >

			<!---
			*************************************************************************
			init()
			************************************************************************
			--->
	<cffunction name="init" returntype="EnvironmentService" output="No" hint="Class constructor">

			<!--- initialize variables --->
		<cfscript>
			setOCSDefinitionMaker( createObject( 'component', 'environmentConfig.model.ColdSpringDefinitionMaker').init());
		</cfscript>
		<cfreturn this />
	</cffunction>

		<!---
		********************************************************************************
		configureEnvironment()
		Author: Roland Lopez - Date: 4/9/2008
		Hint: I configure an application's environment properties
		********************************************************************************
		--->
	<cffunction name="configureEnvironment" output="false" access="public" returntype="struct" hint="Configures an application's environment properties">
		<cfargument name="sECDefinitionFilePath" type="string" required="true" />

		<cfscript>
			var stLocal 		= structNew();
			stLocal.success 	= true;
			stLocal.stProperties = structNew();
		</cfscript>

		<cfscript>
		try
        {
        	
			stLocal.stProperties 		= getEnvironmentProperties( arguments.sECDefinitionFilePath );

			if(not structKeyExists(stLocal.stProperties, 'ec') or not isStruct(stLocal.stProperties.ec)){
				stLocal.stProperties.ec = structNew();
			}
			setDefaultEcValues(stLocal.stProperties.ec);
			stLocal.ec = structCopy(stLocal.stProperties.ec);
			if(not stLocal.stProperties.ec.bEmbedECIntoProperties)
				structDelete(stLocal.stProperties,"EC");

			if(structKeyExists(stLocal.stProperties,"mappings")){
				stLocal["mappings"] = structCopy(stLocal.stProperties.mappings);
				structDelete(stLocal.stProperties,"mappings");
			}else
				stLocal["mappings"] = structNew();
				
			stLocal.stFlattened 		=  flattenStruct( stObject=stLocal.stProperties, addPrefix=false ).stResult;
			
			if( stLocal.ec.bUseFlattenedStruct )
				stLocal.stWriteFilesResults = createFiles( stLocal.stFlattened,
					stLocal.ec.bCreateBeanFile,
					stLocal.ec.bCreateColdSpringFile,
					stLocal.ec.sConfigBeanObjPath,
					stLocal.ec.sColdSpringDefFilePath
					);
			else
				stLocal.stWriteFilesResults = createFiles( stLocal.stProperties,
					stLocal.ec.bCreateBeanFile,
					stLocal.ec.bCreateColdSpringFile,
					stLocal.ec.sConfigBeanObjPath,
					stLocal.ec.sColdSpringDefFilePath
					);
			if(stLocal.ec.bEmbedECIntoProperties){
				structDelete(stLocal,"ec");
			}
        }
        catch(Any e)
        {
			rethrow;
        }

		</cfscript>
		<cfreturn stLocal />
	</cffunction>

		<!---
		********************************************************************************
		getEnvironmentProperties()
		Author: Rolando Lopez - Date: 4/1/2008
		Hint: I get the environment properties and return these in a structure
		********************************************************************************
		--->
	<cffunction name="getEnvironmentProperties" output="false" access="private" returntype="struct" hint="Gets the environment properties and return these in a structure">
		<cfargument name="sECDefinitionFilePath" type="string" required="true" />

		<cfscript>
			var stLocal = structNew();
			try{
					//get Application's properties
				//stLocal.stGlobalProperties = getOEnvironmentManager().getEnvironmentProperties(arguments.sECDefinitionFilePath).stGlobalProperties;
				stLocal.stGlobalProperties = createObject( 'component','environmentConfig.model.Environment' ).init(
															 arguments.sECDefinitionFilePath ).getEnvironmentByUrl( CGI.SERVER_NAME );
			}catch( any e ){
				eThrow(message:e.message,type:"ec.getEnvironmentProperties");
			}
		</cfscript>
		<cfreturn stLocal.stGlobalProperties />
	</cffunction>

		<!---
		********************************************************************************
		createFiles()
		Author: Rolando Lopez - Date: 4/1/2008
		Hint: I get the environment properties and return these in a structure
		********************************************************************************
		--->
	<cffunction name="createFiles" output="false" access="package" returntype="struct" hint="I get the environment properties and return these in a structure">
		<cfargument name="stProperties" type="struct" required="true"  />
		<cfargument name="bCreateBeanFile" type="boolean" required="false" default="false"  />
		<cfargument name="bCreateColdSpringFile" type="boolean" required="false" default="false" />
		<cfargument name="sConfigBeanObjPath" type="string" required="false" default="model.GlobalConfig" />
		<cfargument name="sColdSpringDefFilePath" type="string" required="false" default="/config/GlobalConfigColdspring.xml.cfm" />
		<cfargument name="setterAccess" type="string" required="false" default="private" />


		<cfscript>
			var stLocal = structNew();
		</cfscript>
		<cfscript>
			try{
				if(arguments.bCreateBeanFile and structKeyExists(arguments, 'sConfigBeanObjPath'))
					stLocal.stGlobalBeanWriteResults = createBeanFile(sConfigBeanObjPath=arguments.sConfigBeanObjPath, stProperties=arguments.stProperties,setterAccess:arguments.setterAccess);

				if(arguments.bCreateColdSpringFile and structKeyExists(arguments, 'sColdSpringDefFilePath')){
 					stLocal.stColdSpringDefResults 	= createColdSpringDefinition(argumentCollection=arguments);

				}
			}catch( any e ){
						rethrow;
				eThrow(message:e.message,type:e.Type);
			}
		</cfscript>
		<cfreturn stLocal />
	</cffunction>

		<!---
		********************************************************************************
		setDefaultEcValues()
		Author: Rolando Lopez - Date: 5/5/2008
		Hint: I work as a cfparam for the EC structure inside the properties
		********************************************************************************
		--->
	<cffunction name="setDefaultEcValues" output="false" access="private" returntype="void" hint="Works as a cfparam for the EC structure inside the properties">
		<cfargument name="stEC" type="struct" required="true"  />
		<cfscript>
			var stDefault = structNew();
		</cfscript>

			<cfscript>
				try{
					stDefault['bCreateBeanFile'] 			= false;
					stDefault['bCreateColdSpringFile']		= false;
					stDefault['bUseFlattenedStruct']		= true;
					stDefault['sConfigBeanObjPath']			= 'GlobalConfig';
					stDefault['sColdSpringDefFilePath']		= '/';
					stDefault['bEmbedECIntoProperties']		= false;
					//stDefault.sECDefinitionFilePath
					structAppend( stEC,stDefault,false );
				}catch(any e){
					eThrow(message:e.message,type:e.Type);
				}
			</cfscript>
				


	</cffunction>

		<!---
		********************************************************************************
		createBeanFile()
		Author: Rolando Lopez - Date: 4/1/2008
		Hint: I create the bean based on a structure
		********************************************************************************
		--->
	<cffunction name="createBeanFile" output="false" access="package" returntype="struct" hint="Creates the bean based on a structure">
		<cfargument name="sConfigBeanObjPath" type="string" required="true" />
		<cfargument name="stProperties" type="struct" required="true" />
		<cfargument name="setterAccess" type="string" required="false" default="private"/>

		<cfscript>
			var stLocal = structNew();

			stLocal.results 		= structNew();
			stLocal.results.success = true;

				stLocal.oBeanCreator = createObject( 'component', 'environmentConfig.model.BeanMaker' ).init();
					//creates the bean file &
					//writes the bean to disk, default value if not specified is model.GlobalConfig
					//if you want to name your GlobalCondfig differntly or place it in a different place, change the 2nd parameter
					//full path to your object can be send as dot path '.' notation or just regular file path '/' notation
				stLocal.results.stCreateBean = stLocal.oBeanCreator.createBean(arguments.stProperties,arguments.sConfigBeanObjPath,arguments.setterAccess);
		</cfscript>

		<cfreturn stLocal.results />
	</cffunction>

		<!---
		********************************************************************************
		createColdSpringDefinition()
		Author: Rolando Lopez - Date: 4/1/2008
		Hint: I crate the ColdSpring definition file for a bean based on a structure
		********************************************************************************
		--->
	<cffunction name="createColdSpringDefinition" output="false" access="package" returntype="struct" hint="I crate the ColdSpring definition file for a bean based on a structure">
		<cfargument name="sColdSpringDefFilePath" type="string" required="true" />
		<cfargument name="sConfigBeanObjPath" type="string" required="true" />
		<cfargument name="stProperties" type="struct" required="true" />

		<cfscript>
			var stLocal = structNew();
			stLocal.results=structNew();
			stLocal.results.success = true;

			try{

				stLocal.sCSDef					= getoCSDefinitionMaker().createColdSpringDefinition( arguments.stProperties, arguments.sConfigBeanObjPath );
				stLocal.results.bCSDefWriteSuccess	= getoCSDefinitionMaker().writeCSDefToFile( stLocal.sCSDef, sColdSpringDefFilePath);
			}catch( any e ){
				eThrow(message:e.message,type:e.Type);
			}
		</cfscript>

		<cfreturn stLocal.results />
	</cffunction>

		<!---
    	******************************************************************************** 
    	getEnvironmentRawXML()
    	@Author: Rolando Lopez 
    	@Date: 9/15/2010 
    	@Hint: Reads into memory and return the EnvironmentConfig XML file
    	@Access: package
    	********************************************************************************
    	--->
    <cffunction name="getEnvironmentRawXML" output="false" access="package" returntype="xml" hint="Reads into memory and return the EnvironmentConfig XML file">
    	<cfargument name="sECDefinitionFilePath" type="string" required="true" />
    	<cfscript>	
    		try{
				return createObject( 'component','environmentConfig.model.Environment' ).init(
															 arguments.sECDefinitionFilePath ).getXmlFile();
    		}catch(any e){
    			ethrow(  'Failed to: Read into memory and return the EnvironmentConfig XML file ','environmentConfig.getEnvironmentRawXML' );
    		}	
    	</cfscript>
    </cffunction>
    

    <cfscript>
	public struct function initEnvironmentConfig(required String ecConfigFilePath, String configVarName='oConfig', String ColdSpringDefinitionFile="/config/coldspring.xml.cfm", String factoryLabel="factory"){
		try{
			var ecProperties	= configureEnvironment( arguments.ecConfigFilePath );
			var ecConfig 		= {};

			if( structKeyExists( ecProperties, 'ec' ) )
				ecConfig = ecProperties.ec;
			else if(structKeyExists( ecProperties.stProperties, 'ec' ) )
				ecConfig = ecProperties.stProperties.ec;

			if(structCount(ecConfig)){
				if(ecConfig.bCreateColdSpringFile){
					Application[arguments.factoryLabel] = createObject( "component","coldspring.beans.DefaultXmlBeanFactory" ).init(structNew(), ecProperties.stFlattened);
					Application[arguments.factoryLabel].loadBeansFromXmlFile( "#expandPath( arguments.ColdSpringDefinitionFile )#",true );
				}else 
				if(ecConfig.bCreateBeanFile)
					if( not ecConfig.bUseFlattenedStruct)
						Application[arguments.configVarName] = createObject( 'component', ecConfig.sConfigBeanObjPath ).init(argumentCollection = ecProperties.stProperties);
					else
						Application[arguments.configVarName] = createObject( 'component', ecConfig.sConfigBeanObjPath ).init(argumentCollection = ecProperties.stFlattened);
				else if( not ecConfig.bUseFlattenedStruct)
					Application[arguments.configVarName] = ecProperties.stProperties;
				else
					Application[arguments.configVarName] = ecProperties.stFlattened;

			}
		}catch(any e){
			throw (message:"Error initializing EnvironmentConfig - #e.message#", detail:e.detail, extendedInfo:e.extendedInfo);
		}
		return ecProperties;
	}
    </cfscript>

		<!--- setters & getters --->

		<!--- setOCSDefinitionMaker(environmentConfig.model.ColdSpringDefinitionMaker) --->
	<cffunction name="setOCSDefinitionMaker" access="private" returntype="void" hint="I set OCSDefinitionMaker variable" output="false">
		<cfargument name="value" type="environmentConfig.model.ColdSpringDefinitionMaker" required="true" />
		<cfset variables.inst.OCSDefinitionMaker = arguments.value />
	</cffunction>
		<!--- getOCSDefinitionMaker() --->
	<cffunction name="getOCSDefinitionMaker" access="private" returntype="environmentConfig.model.ColdSpringDefinitionMaker" hint="I get OCSDefinitionMaker variable" output="false">
		<cfreturn variables.inst.OCSDefinitionMaker  />
	</cffunction>


</cfcomponent>
