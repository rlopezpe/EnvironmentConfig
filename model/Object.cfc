<!--- ****************************************************
Copyright 2007 Rolando Lopez (www.rolando-lopez.com) 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except 
in compliance with the License.You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License. 
***************************************************** --->

	<!---
	*****************************************************
	This is a base Object class for common methods in 
	objects.
	*****************************************************
	--->

<cfcomponent displayname="Object" hint="base object class" output="false">

			<!--- 	
    		*************************************************************************
    		init()
    		************************************************************************
    		--->																										
    	<cffunction name="init" returntype="Object" output="false" hint="Basic constructor. Can be leveraged by child classes">
    		
    			<!--- initialize variables --->
    		<cfscript>		
    			return this;
    		</cfscript>
    	</cffunction>
    

		<!---
    	******************************************************************************** 
    	eThrow()
    	@Author: Rolando Lopez 
    	@Date: 9/14/2010 
    	@Hint: Basic cfthrow tag facade method for cfscript
    	@Access: private
    	********************************************************************************
    	--->
    <cffunction name="eThrow" output="false" access="private" returntype="void" hint="Basic cfthrow tag facade method for cfscript">
    	<cfargument name="message" type="string" required="true" />
		<cfargument name="type" type="string" required="false" default="Application" />
    	
		<cfthrow message="#arguments.message#" type="#arguments.type#" >
    </cffunction>
    
		<!---
    	******************************************************************************** 
    	dump()
    	@Author: Rolando Lopez 
    	@Date: 9/14/2010 
    	@Hint: dump tag facade method
    	@Access: private
    	********************************************************************************
    	--->
    <cffunction name="dump" output="true" access="private" returntype="void" hint="dump tag facade method">
    	<cfargument name="variable" type="any" required="true" />
		<cfargument name="abort" type="boolean" required="false" default="false" />
		<cfargument name="label" type="string" required="false" default="#getMetaData(arguments.variable).getCanonicalName()#" />
		
		<cfdump var="#arguments.variable#" label="#arguments.label#">
		<!---<cfdump var="#getMetaData(arguments.variable)#">--->
		<cfif arguments.abort><cfabort/></cfif>
    </cffunction>
    
		<!---
		******************************************************************************** 
		flattenStruct()
		Author: Tom De Manincor - Date: 4/9/2008 
		Hint: I flatten a struct to one level deep
		********************************************************************************
		--->
	<cffunction name="flattenStruct" access="public" output="false" returntype="struct">
		<cfargument name="stObject"  required="true"  type="struct" />
		<cfargument name="delimiter" required="false" type="string" default="." />
		<cfargument name="prefix" 	 required="false" type="string" default="" />
		<cfargument name="stResult"  required="false" type="struct" default="#structNew()#" />
		<cfargument name="addPrefix" required="false" type="boolean" default="false" />
		
		<cfset var sKey = '' />
		<cfloop collection="#arguments.stObject#" item="sKey">		
			<cfif isSimpleValue(arguments.stObject[sKey])>
				<cfif arguments.addPrefix and len(arguments.prefix)>
					<cfset arguments.stResult[arguments.prefix & arguments.delimiter & sKey] = arguments.stObject[sKey] />
				<cfelse>
					<cfset arguments.stResult[sKey] = arguments.stObject[sKey] />
				</cfif>
				
			<cfelseif isStruct(arguments.stObject[sKey])>
				<cfset flattenStruct(arguments.stObject[sKey],arguments.delimiter,sKey,arguments.stResult) />	
			</cfif>
		</cfloop>
		<cfreturn arguments />
	</cffunction>
</cfcomponent>