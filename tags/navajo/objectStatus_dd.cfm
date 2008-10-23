<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/objectStatus_dd.cfm,v 1.24.2.1 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name: milestone_3-0-1 $
$Revision: 1.24.2.1 $

|| DESCRIPTION || 
$Description: Changes the status of objects to approved/draft/pending. Intended for use with dynamic data pages $
$TODO: Fix date handling, for we have had to add a hack to convert custom date properties to ODBC$

|| DEVELOPER ||
$Developer: Unknown$

|| ATTRIBUTES ||
$in: url.Objectid$
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">

<cfparam name="attributes.lObjectIDs" default=""> <!---objects to have their status changed-required --->
<cfparam name="attributes.status" default=""> <!--- status to change to - required --->
<cfparam name="rMsg" default="msg"> <!--- The message returned to the caller - optional --->
<cfparam name="form.commentlog" default=""> <!--- hack --->

<cfloop index="attributes.objectID" list="#attributes.lObjectIDs#">
	<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObj">
		<cfif not structkeyexists(stObj, "status")>
			<cfoutput>
			<script>
				 alert("#application.rb.getResource('workflow.messages.objNoApprovalProcess@text','This content item type has no approval process attached to it.')#");
			</script>
			</cfoutput>
			<cfsetting enablecfoutputonly="false" />
			<cfexit>
		</cfif>

		<cfif attributes.status eq "approved">
			<cfset status = "approved">
			<cfset permission = "approve">
			<cfset active = 1>

			<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#attributes.objectID#" returnvariable="stRules">
			<cfif stRules.BLIVEVERSIONEXISTS>
				<cfinvoke component="#application.packagepath#.farcry.versioning" method="sendObjectLive" objectID="#attributes.objectID#"  stDraftObject="#stObj#" returnvariable="stRules">
				<cfset attributes.objectId=stObj.objectid>
			</cfif>

			<!--- send out emails informing object has been approved --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_approved_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>
			</cfinvoke>
			
			<!--- 
			// Set Friendly URL 
			 - TODO: this is going to cause issues if the approval process fails or is not confirmed GB20060123
			--->
			<!--- versioned objects use parent live object for fu --->
			<cfif StructKeyExists(stObj,"versionid") AND len(stobj.versionid)>
				<cfset fuoid=stobj.versionid>
			<!--- use objectid if no versionid --->
			<cfelse>
				<cfset fuoid=stobj.objectid>
			</cfif>

			<!--- set friendly url --->
			<cfset stresult_friendly = application.fc.factory.farFU.setFriendlyURL(objectid=fuoid)>

		<cfelseif trim(attributes.status) IS "draft">
			<cfset status = 'draft'>
			<cfset permission = "approve">
						
			<!--- send out emails informing object is sent back to draft --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_draft_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>
			</cfinvoke>
			

			<cfset active = 0>
		<cfelseif attributes.status eq "requestApproval">
			<cfset status = "pending">
			<cfset permission = "requestApproval">
			<cfset active = 0>

			<!--- send out emails informing object needs approval --->
			<cfinvoke component="#application.packagepath#.farcry.versioning" method="approveEmail_pending_dd">
				<cfinvokeargument name="objectId" value="#attributes.objectId#"/>
				<cfinvokeargument name="comment" value="#attributes.commentlog#"/>
				<cfif isdefined("attributes.lApprovers") and len(attributes.lApprovers)>
					<cfif listLen(attributes.lApprovers) gt 1 and listFind(attributes.lApprovers,"all")>
						<cfinvokeargument name="lApprovers" value="all"/>
					<cfelse>
						<cfinvokeargument name="lApprovers" value="#attributes.lApprovers#"/>
					</cfif>					
				<cfelse>
					<cfinvokeargument name="lApprovers" value="all"/>
				</cfif>
				<cfif isDefined("attributes.approveURL")>
					<cfinvokeargument name="approveURL" value="#attributes.approveURL#"/>
				</cfif>	
			</cfinvoke>
		<cfelse>
			<cfthrow errorcode="navajo" message="#application.rb.getResource('workflow.messages.passedUnknownStatus@text','Unknown status passed')#">
		</cfif>

		<!--- prepare date fields --->
		<cfloop collection="#stObj#" item="field">
			<cfif StructKeyExists(application.types[stObj.typeName].stProps, field) AND application.types[stObj.typeName].stProps[field].metaData.type eq "date" AND IsDate(stObj[field])>
				<cfset stObj[field] = CreateODBCDateTime(stObj[field])>
			</cfif>
		</cfloop>

		<!--- update related aObjectids status to approved --->
		<cfif status EQ "approved" AND StructKeyExists(stObj,"aObjectIDs")>
			<cfloop index="i" from="1" to="#ArrayLen(stObj.aObjectIDs)#">
				<q4:contentobjectget objectId="#stObj.aObjectIDs[i]#" r_stObject="relstObj">
				<cfif relstObj.typename EQ "dmFile" OR relstObj.typename EQ "dmImage">
					<cfset relstObj.status = status>
					<cfset oType = createobject("component", application.types[relstObj.typename].typePath)>
					<cfset oType.setData(stProperties=relstObj,bAudit=false)>
					
					<extjs:bubble title="#relstObj.label#" message="Status changed to #status#" />
					<farcry:logevent object="#stObj.objectid#" type="type" event="to#status#" note="#commentLog#" />
				</cfif>
			</cfloop>
		</cfif>

		<!--- update the structure data for object update --->
		<cfset stObj.datetimelastupdated = now() />
		<cfset stObj.status = status />
		
		<!--- update object --->	
		<cfset oType = createobject("component", application.types[stObj.typename].typePath) />
		<cfset oType.setData(stProperties=stObj) />
		
		<extjs:bubble title="#stObj.label#" message="Status changed to #status#" />
		<farcry:logevent object="#stObj.objectid#" type="types" event="to#status#" note="#commentLog#" />
		
	</cfloop>
	<cfset "caller.#attributes.rMsg#" = "#listLen(attributes.lObjectIds)# object(s) status changed"> 
<cfsetting enablecfoutputonly="No">
