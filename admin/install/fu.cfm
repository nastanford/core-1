<cfsetting enablecfoutputonly="true">

<!--- if the reffriendlyURL table exists, drop it --->
<cftry>
	
	<cfparam name="bTableExists" default="1" type="boolean" />
	
	<!--- bowden --->
	<cfswitch expression="#application.dbtype#">
		
		<cfcase value="ora">
			<cfquery name="qTableExists" datasource="#application.dsn#">
				select 1
				from user_tables
				where table_name =  'REFFRIENDLYURL' 
			</cfquery>
			<cfif qTableExists.recordcount gt 0>
				<cfquery name="qDrop" datasource="#application.dsn#">
					DROP TABLE #application.dbOwner#reffriendlyURL
				</cfquery>
				<cfset bTableExists = 0 />
			</cfif>
		</cfcase>
		
		<cfdefaultcase>
			<!--- not a great way, but this (at this stage) is quicker and easier that doing a case for all DB vendors. Error will be thown if table doesn't exist --->
			<cfquery name="qCheck" datasource="#application.dsn#" maxrows="1">
				SELECT objectid 
				FROM #application.dbOwner#reffriendlyURL
			</cfquery>
			<cfif qCheck.recordCount>
				<cfquery name="qDrop" datasource="#application.dsn#">
					DROP TABLE #application.dbOwner#reffriendlyURL
				</cfquery>
				<cfset bTableExists = 0 />
			</cfif>
		</cfdefaultcase>
		
	</cfswitch>

	<cfcatch type="database">
		<cfset bTableExists = 0 />
	</cfcatch>

</cftry>
			
			
			
<cftry>

	<cfif NOT bTableExists>
		<!--- only create table if one doesnt exist --->
		<!--- bowden --->
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="qCreateFUTable" datasource="#application.dsn#">
					CREATE TABLE #application.dbOwner#reffriendlyURL ( 
					objectid    		varchar2(50) NOT NULL,
					refobjectid 		varchar2(50) NOT NULL,
					friendlyurl	            varchar2(4000) NULL,
					query_string            varchar2(4000) NULL,
					datetimelastupdated     date NULL,
					status      		numeric NULL 
					)
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="qCreateFUTable" datasource="#application.dsn#">
					CREATE TABLE #application.dbOwner#reffriendlyURL ( 
					objectid    		varchar(50) NOT NULL,
					refobjectid 		varchar(50) NOT NULL,
					<cfswitch expression="#application.dbtype#">
						<cfcase value="ODBC,MSSQL">
							friendlyurl	varchar(8000) NULL,
							query_string varchar(8000) NULL,
							datetimelastupdated datetime NULL,
						</cfcase>
						<cfdefaultcase>
							friendlyurl 		text NULL,
							query_string		text NULL,
							datetimelastupdated timestamp NULL,
						</cfdefaultcase>
					</cfswitch>
					status      		numeric NULL 
					)
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
	</cfif>
	
	<cfcatch>
		<!--- TODO: exception handling --->
	</cfcatch>
	
</cftry>


<cfoutput>
	<table border="0" cellpadding="1" cellspacing="0" width="600">
		<tr>
			<td width="100%">Create Table Success: refFriendlyURL</td>
			<td><span class="success">DONE</span></td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false">