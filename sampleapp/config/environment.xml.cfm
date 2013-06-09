<?xml version="1.0" encoding="UTF-8"?>
<environments>
	<default>
        <config>
				<!-- default vars -->
			<property name="EC">
				<map>
					<entry key="bCreateBeanFile"><value>true</value></entry>
					<entry key="bCreateColdSpringFile"><value>true</value></entry>
					<entry key="bUseFlattenedStruct"><value>true</value></entry>
					<entry key="sConfigBeanObjPath"><value>sampleApp.com.GlobalConfig</value></entry>
					<entry key="sColdSpringDefFilePath"><value>/sampleApp/config/GlobalConfigColdspring.xml.cfm</value></entry>
					<entry key="sECDefinitionFilePath"><value>config/environment.xml.cfm</value></entry>
					<entry key="bEmbedECIntoProperties"><value>false</value></entry>
				</map>
			</property>
			
			<property name="appName">EnvironmentConfig</property>
			<property name="configPath">config</property>
			<property name="viewsPath">views</property>
			<property name="adminEmail">admin@mysite.com</property>
			<property name="assetsPath">assets</property>
			<property name="enableDebugOutput">true</property>
			<property name="mySiteRoot">http://rolando-lopez.com</property>
			<property name="techBlog">${mySiteRoot}/tech</property>
			<property name="ecHome">${techBlog}/category/coldfusion/environmentconfig</property>
			<property name="thirdLevel">${ecHome}/2009/06/environmentconfig-about/</property>
			<property name="a0simpleValueCFOutputMixed">Ran on #dateFormat(now(),'mmm dd, yyyy')# at #timeFormat(now(),'HH:mm:ss')# | Did you know that 52*11=#52*11# is the same as 5_(5+2)_2 =  5#5+2#2? | This is #uCase('${appName}')#</property>
			<property name="siteRootPath">#replace(expandPath('/'),'\','/',"all")#</property>
			<property name="frameworksRoot">E:/_library/frameworks</property>
			
            <property name="mappings">
            	<map>
            		<entry key="/userUploads"><value>${siteRootPath}/assets/files/userUploads</value></entry>
            		<entry key="/business"><value>${siteRootPath}/sampleApp/com/business</value></entry>
            		<entry key="/coldspring"><value>${frameworksRoot}/coldspring</value></entry>
            	</map>
            </property>	
        </config>
	</default>
	
		<!-- local environment -->
	<environment id="local">
        <patterns>
            <pattern>^environmentconfig.local</pattern>
            <pattern>^ec.local</pattern>
        </patterns>
        <config>
			
			<property name="adminEmail">developer@mysite.com</property>
			<property name="isDev">#iif(1 eq 1,DE('true'),DE('false'))#</property>
			<property name="ishttps">#iif(cgi.https eq 'on',DE('https'),DE('http'))#://#lcase(cgi.server_name)#</property>
			<property name="stDSN">
				<map>
					<entry key="dsn"><value>myDSN</value></entry>
					<entry key="dsnUser"><value>localUser</value></entry>
					<entry key="dsnPassword"><value>passwordXX</value></entry>
					<entry key="extra"><value>#expandPath('${sColdSpringDefFilePath}')#/EXTRA</value></entry>
				</map>
			</property>		
			<property name="mailServer">mail.localServer.com</property>
		</config>
	</environment>
		<!-- dev -->
	<environment id="dev">
        <patterns>
            <pattern>^environmentConfig.dev</pattern>
            <pattern>^ec.dev</pattern>
        </patterns>
        <config>
			
			<property name="stDSN">
				<map>
					<entry key="dsn"><value>devDSN</value></entry>
					<entry key="dsnUser"><value>devUser</value></entry>
					<entry key="dsnPassword"><value>devPassword</value></entry>
				</map>
			</property>
			<property name="frameworksRoot">C:/dev/frameworksAndTools</property>
			<property name="mappings">
            	<map>
            		<entry key="/userUploads"><value>${siteRootPath}/assets/files/userUploads</value></entry>
            		<entry key="/business"><value>${siteRootPath}/sampleApp/com/business</value></entry>
            		<entry key="/coldspring"><value>${frameworksRoot}/coldspring</value></entry>
            	</map>
            </property>	
			<property name="mailServer">mail.devServer.com</property>
        </config>
	</environment>

		<!-- staging-->
	<environment id="staging">
        <patterns>
            <pattern>^environmentConfig.staging</pattern>
            <pattern>^ec.staging</pattern>
        </patterns>
        <config>
			<property name="isDev">false</property>
			<property name="stDSN">
				<map>
					<entry key="dsn"><value>stagingDSN</value></entry>
					<entry key="dsnUser"><value>stagingUser</value></entry>
					<entry key="dsnPassword"><value>2345$xls9i</value></entry>
				</map>
			</property>
			<property name="mailServer">mail.devServer.com</property>
        </config>
	</environment>

		<!-- production -->
	<environment id="production">
        <patterns>
            <pattern>.*</pattern>
        </patterns>
        <config>
			<property name="isDev">false</property>
			<property name="dsn">productionDSN</property>
			<property name="dsUserName">prodUser</property>
			<property name="dsPassword">prodPassword</property>
			<property name="mailServer">mail.mySite.com</property>
        </config>
	</environment>
</environments>		