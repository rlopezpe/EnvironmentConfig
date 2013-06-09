<cfcomponent displayname="ColdSpringDefinitionMaker" hint="Creates ColdSpring Definition File for a CFC" output="false" >
		<!--- 	
		*************************************************************************
		init()
		************************************************************************
		--->																										
	<cffunction name="init" returntype="ColdSpringDefinitionMaker" output="No" hint="Class constructor" access="package">
		
			<!--- initialize variables --->
			
		<cfreturn this />
	</cffunction>

		<!---
		******************************************************************************** 
		createColdSpringDefinition()
		Author: Rolando Lopez - Date: 3/29/2008 
		Hint: I create the ColdSpring bean definition file for the GlobalConfig bean based on a structure of properties
		********************************************************************************
		--->
	<cffunction name="createColdSpringDefinition" output="true" access="package" returntype="xml" hint="Create the ColdSpring bean definition file for the GlobalConfig bean based on a structure of properties">
		<cfargument name="stProperties" type="struct" required="true" hint="A Structure of properties."/>
		<cfargument name="objPathDotNotation" type="string" required="false" default="model.GlobalConfig" hint="Dot path notation to the CFC File (e.g. com.entity.User)" />
		<cfscript>	
				var sCSDefinition = "";
				var stTemp = structNew();
			</cfscript>
			<cftry>
				<cfsetting enablecfoutputonly="true">
				<cfsavecontent variable="sCSDefinition">
	<cfoutput><?xml version="1.0" encoding="UTF-8"?>
	<beans>
		<bean id="#listLast(arguments.objPathDotNotation, '.')#" class="#arguments.objPathDotNotation#"></cfoutput>
					<cfloop collection="#arguments.stProperties#" item="ixProperty">
	<cfif not isStruct(arguments.stProperties[ixProperty] )>	
	<cfoutput>
			<constructor-arg 	name="#ixProperty#"><value>${#ixProperty#}</value></constructor-arg></cfoutput>
			<cfelse>
			<cfscript>stTemp = arguments.stProperties[ixProperty];</cfscript>  
			<cfoutput>
			<constructor-arg	name="#ixProperty#">
				<map>	
					<cfloop collection="#stTemp#" item="ixKey"><entry key="#ixKey#"><value>${#ixKey#}</value></entry>
					</cfloop></map>
			</constructor-arg></cfoutput>
			</cfif>
					</cfloop>
	<cfoutput>
		</bean>
	</beans></cfoutput>
				</cfsavecontent>
				<cfsetting enablecfoutputonly="false">
				<cfcatch type="any">
					<cfsetting enablecfoutputonly="false">
					<cfdump var="#cfcatch#" />
					<cfabort />
				</cfcatch>
			</cftry>
			<cfreturn sCSDefinition />
		</cffunction>			
		
			<!---
			******************************************************************************** 
			writeCSDefToFile()
			Author: Roland Lopez - Date: 1/24/2008 
			Hint: I write the file into a directory
			********************************************************************************
			--->
		<cffunction name="writeCSDefToFile" output="false" access="package" returntype="struct" hint="I write the ColdSpring Definition file to disk">
			<cfargument name="beanString" type="string" required="true" hint="Definition file content to write to file."  />
			<cfargument name="fullObjectPath" type="string" required="false" default="/config/GlobalConfigColdspring"  />
			<cfscript>	
				var stReturn 	= structNew();
				
				stReturn.success = true;
			</cfscript>
			<cftry>
				<cffile action="write" file="#expandPath( arguments.fullObjectPath )#" output="#arguments.beanString#" />
				<cfcatch type="any">
					<cfscript>
						stReturn.success = false;
						stReturn.errorDetails = cfcatch;
					</cfscript>
					<cfdump var = "#cfcatch#" label = "cfcatch" />
					<cfabort />
				</cfcatch>
			</cftry>
		
			<cfreturn stReturn />
		</cffunction>
	

</cfcomponent>