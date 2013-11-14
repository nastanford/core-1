
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="../../tags" prefix="toro" />


<cfset qWebtopDashboards = application.fapi.getContentType("farWebtopDashboard").getPermittedWebtopDashboards() />

<cfparam name="session.webtopDashboardID" default="">

<ft:processForm action="Change Dashboard" url="refresh">
	<cfset session.webtopDashboardID = form.selectedObjectID>
</ft:processForm>

<ft:form>




<cfset aDashboardCardWebskins = arrayNew(1)>


<cfif qWebtopDashboards.recordCount>

	<cfif len(session.webtopDashboardID) AND listFindNoCase(valueList(qWebtopDashboards.objectid),session.webtopDashboardID)>
		<cfset stCurrentDashboard = application.fapi.getContentObject(typename="farWebtopDashboard", objectid="#session.webtopDashboardID#")>
	<cfelse>
		<cfset stCurrentDashboard = application.fapi.getContentObject(typename="farWebtopDashboard", objectid="#qWebtopDashboards.objectid#")>
	</cfif>
	

	<cfif qWebtopDashboards.recordCount GT 1>
		<cfoutput>
		<ft:buttonGroup>
			<ft:button value="Select Dashboard: #stCurrentDashboard.title#" type="button" icon=" ,caret" dropdownToggle="true" />
		
			<ft:dropdownMenu class="pull-right">
				<cfloop query="qWebtopDashboards">
					<li>
						<ft:button 
								value="Change Dashboard" 
								text="#qWebtopDashboards.title#"
								selectedObjectID="#qWebtopDashboards.objectid#"
								validate="false" 
								renderType="link" />
					</li>
				</cfloop>	
				
			</ft:dropdownMenu>
		</ft:buttonGroup>
		</cfoutput>
	</cfif>
	
	<cfloop list="#stCurrentDashboard.lCards#" index="iCard">
			
		<cfif application.fapi.checkWebskinPermission(type="#listFirst(iCard,':')#",webskin="#listLast(iCard,':')#")>
			<cfset stDashboardCard = structNew()>
			<cfset stDashboardCard.typename = listFirst(iCard,':')>
			<cfset stDashboardCard.webskin = listLast(iCard,':')>
			<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
			
			<cfloop list="bAjax:0,cardWidth:auto,cardHeight:auto" index="iCardMetadata">
				<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
				<cfelse>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
				</cfif>
			</cfloop>
			
			<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>

		</cfif>
	</cfloop>
		
<cfelse>

	<cfloop collection="#application.stCoapi#" item="iTypename">
		<cfset qWebskins = application.stcoapi[iTypename].qWebskins />
		
		<cfquery dbtype="query" name="qDashboardCardWebskins">
		SELECT * FROM qWebskins
		WHERE lower(qWebskins.name) LIKE 'webtopdashboardcard%'
		</cfquery>
	
		<cfoutput query="qDashboardCardWebskins">
			<cfif application.fapi.checkWebskinPermission(type="#iTypename#",webskin="#qDashboardCardWebskins.methodname#")>
				<cfset stDashboardCard = structNew()>
				<cfset stDashboardCard.typename = iTypename>
				<cfset stDashboardCard.webskin = qDashboardCardWebskins.methodname>
				<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
				
				<cfloop list="bAjax:0,cardHeight:auto,cardClass:fc-card-medium" index="iCardMetadata">
					<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
						<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
					<cfelse>
						<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
					</cfif>
				</cfloop>
				
				<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>
	
			</cfif>
		</cfoutput>
		
	</cfloop>
	
</cfif>

<!--- 300,620,940,1260 --->
<cfif arrayLen(aDashboardCardWebskins)>
	<grid:div style="width:100%;">
		<cfloop from="1" to="#arrayLen(aDashboardCardWebskins)#" index="i">
			<grid:div class="card-outer" style="height:#aDashboardCardWebskins[i].cardHeight#;width:620px;border:1px solid red;overflow:hidden;">
				<grid:div class="card-inner" style="">
					<skin:view typename="#aDashboardCardWebskins[i].typename#" webskin="#aDashboardCardWebskins[i].webskin#"  bAjax="#aDashboardCardWebskins[i].bAjax#" ajaxShowloadIndicator="true" ajaxindicatorText="Loading #aDashboardCardWebskins[i].displayName#...">
				</grid:div>
			</grid:div>
		</cfloop>
	</grid:div>
</cfif>