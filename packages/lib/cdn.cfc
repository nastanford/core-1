<cfcomponent displayname="File" hint="Encapsulates file persistence functionality" output="false" persistent="false" scopelocation="application.fapi">
	
	<cffunction name="init" returntype="any">
		
		<cfset var thispath = "" />
		<cfset var thiscdn = "" />
		<cfset var utils = createobject("component","farcry.core.packages.farcry.utils") />
		
		<!--- Initialize CDN components --->
		<cfset this.cdns = structnew() />
		<cfloop list="#utils.getComponents('cdn')#" index="thiscdn">
			<cfset this.cdns[thiscdn] = createobject("component",utils.getPath("cdn",thiscdn)) />
			
			<cfif structkeyexists(this.cdns[thiscdn],"init")>
				<cfset this.cdns[thiscdn].init(cdn=this) />
			</cfif>
		</cfloop>
		
		<!--- Initialize location information --->
		<cfset this.locations = structnew() />
		<cfif structkeyexists(application,"path") and structkeyexists(application,"url")>
			<!--- Cache --->
			<cfset setLocation(name="cache",cdn="local",fullpath=normalizePath(application.path.cache),urlpath=normalizePath(application.url.cache)) />
			<cfset setLocation(name="images",cdn="local",fullpath=normalizePath(application.path.imageRoot),urlpath=normalizePath(application.url.imageRoot)) />
			<cfset setLocation(name="archive",cdn="local",fullpath=normalizePath(application.path.mediaArchive)) />
			<cfset setLocation(name="publicfiles",cdn="local",fullpath=normalizePath(application.path.defaultFilePath),urlpath=normalizePath(application.url.fileRoot)) />
			<cfset setLocation(name="privatefiles",cdn="local",fullpath=normalizePath(application.path.secureFilePath)) />
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getLocations" output="false" access="public" returntype="query" hint="Returns query of all configured locations and their CDN type">
		
		<cfset var qLocations = querynew("name,type") />
		<cfset var thislocation = "" />
		
		<cfloop collection="#this.locations#" item="thislocation">
			<cfset queryaddrow(qLocations) />
			<cfset querysetcell(qLocations,"name",thislocation) />
			<cfset querysetcell(qLocations,"type",this.locations[thislocation].cdn) />
		</cfloop>
		
		<cfquery dbtype="query" name="qLocations">select * from qLocations order by name</cfquery>
		
		<cfreturn qLocations />
	</cffunction>
	
	<cffunction name="getLocation" output="false" access="public" returntype="struct" hint="Returns the specified location">
		<cfargument name="name" type="string" required="true" />
		
		<cfif structkeyexists(this.locations,arguments.name)>
			<cfreturn this.locations[arguments.name] />
		<cfelse>
			<cfthrow message="Location [#arguments.name#] has not been defined" />
		</cfif>
	</cffunction>
	
	<cffunction name="setLocation" output="false" access="public" returntype="void" hint="Sets the specified location">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="cdn" type="string" required="true" />
		<cfargument name="locationinfo" type="struct" required="false" default="#structnew()#" />
		
		<cfset var thiskey = "" />
		<cfset var aErrors = "" />
		
		<cfloop collection="#arguments#" item="thiskey">
			<cfif not listfindnocase("locationinfo",thiskey)>
				<cfset arguments.locationinfo[thiskey] = arguments[thiskey] />
			</cfif>
		</cfloop>
		
		<cfset this.locations[arguments.name] = this.cdns[arguments.cdn].validateConfig(config=arguments.locationinfo) />
	</cffunction>
	
	<cffunction name="normalizePath" returntype="string" access="public" output="false" hint="Normalizes filename character set, replaces '\' with '/', removes trailing '/'">
		<cfargument name="path" type="string" required="true" />
		
		<!--- Normalize slashes to forward slash --->
		<cfset arguments.path = replace(arguments.path,"\","/","ALL") />
		
		<!--- Remove duplicate slashes --->
		<cfset arguments.path = replace(arguments.path,"//","/","ALL") />
		
		<!--- Remove potentially invalid characters --->
		<cfset arguments.path = reReplaceNoCase(arguments.path, "[^a-z0-9\.\-\_/ ]","", "all") />
		
		<!--- Remove trailing slash --->
		<cfif right(arguments.path,1) eq "/">
			<cfset arguments.path = left(arguments.path,len(arguments.path-1)) />
		</cfif>
		
		<cfreturn arguments.path />
	</cffunction>
	
	<!--- @@description: 
		<p>Does what it says on the box. Checks a single location to see if a file exists.</p>
		
		@@examples:
		<code>
			<cfif application.fc.lib.cdn.ioFileExists(location="cache",file=sCacheFileName)>
			    <cfreturn sCacheFileName />
			</cfif>
		</code>
	 --->
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified file exists">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfreturn this.cdns[config.cdn].ioFileExists(config=config,argumentCollection=arguments) />
	</cffunction>
	
	<!--- @@description: 
		<p>Searches the provided locations, and returns the first that contains the specified file, or an empty string if there isn't any.</p>
		
		@@examples:
		<code>
			<cfset currentLocation = application.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=arguments.stObject[arguments.stMetadata.name]) />
		</code>
	 --->
	<cffunction name="ioFindFile" returntype="string" access="public" output="false" hint="Searches the provided locations, and returns the first that contains the specified file, or an empty string if none">
		<cfargument name="locations" type="string" required="true" hint="The returned file will be unique for all the specified locations" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var thislocation = "" />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfloop list="#arguments.locations#" index="thislocation">
			<cfif ioFileExists(location=thislocation,file=arguments.file)>
				<cfreturn thislocation />
			</cfif>
		</cfloop>
		
		<cfreturn "" />
	</cffunction>
	
	<!--- @@description: 
		<p>
			Returns a version of the specified filename which is unique among every listed location by appending numbers to the name. 
			Note that it is rare to have to call this function directly, as all functions which put a file into a CDN have options to 
			enforce filename uniqueness. However if you wish to change how FarCry enforces uniqueness, you can override this function 
			in your project.
		</p>
		
		@@examples:
		<code>
			<cfset moveto = ioGetUniqueFilename(locations="privatefiles,publicfiles",file=newfile) />
		</code>
	 --->
	<cffunction name="ioGetUniqueFilename" returntype="string" access="public" output="false" hint="Returns a version of the specified filename which is unique among every listed location.">
		<cfargument name="locations" type="string" required="false" hint="The returned file will be unique for all the specified locations. If this is not specified, the file will be treated as an absolute local file" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var i = 0 />
		<cfset var currentfile = arguments.file />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfif structkeyexists(arguments,"locations")>
			<cfloop condition="len(ioFindFile(locations=arguments.locations,file=currentfile))">
				<cfset i = i + 1 />
				<cfset currentfile = rereplace(arguments.file,"(\.\w+)?$","#i#\1") />
			</cfloop>
		<cfelse>
			<cfloop condition="fileExists(currentfile)">
				<cfset i = i + 1 />
				<cfset currentfile = rereplace(arguments.file,"(\.\w+)?$","#i#\1") />
			</cfloop>
		</cfif>
		
		<cfreturn currentfile />
	</cffunction>
	
	<!--- @@description: 
		<p>Returns the size of the file in bytes.</p>
		
		@@examples:
		<code>
			<cfoutput>Size: <span class="image-size">#round(application.fc.lib.cdn.ioGetFileSize(location="images",file=arguments.stMetadata.value)/1024)#</span>KB</cfoutput>
		</code>
	 --->
	<cffunction name="ioGetFileSize" returntype="numeric" output="false" hint="Returns the size of the file in bytes">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfreturn this.cdns[config.cdn].ioGetFileSize(config=config,argumentCollection=arguments) />
	</cffunction>
	
	<!--- @@description: 
		<p>Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path.</p>
		
		@@examples:
		<code>
			<cfset stImage = application.fc.lib.cdn.ioGetFileLocation(location="images",file=arguments.stMetadata.value) />
			<cfoutput><img src="#stImage.path#"></cfoutput>
		</code>
	 --->
	<cffunction name="ioGetFileLocation" returntype="struct" output="false" hint="Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfreturn this.cdns[config.cdn].ioGetFileLocation(config=config,argumentCollection=arguments) />
	</cffunction>
	
	<!--- @@description: 
		<p>Writes the specified data to a file.</p>
		
		@@examples:
		<code>
			<cfset stResult.filename = application.fc.lib.cdn.ioWriteFile(location="images",file=filename,data=newImage,datatype="image",quality=arguments.quality,nameconflict="makeunique",uniqueamong="images") />
		</code>
	 --->
	<cffunction name="ioWriteFile" returntype="string" access="public" output="false" hint="Writes the specified data to a file">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		<cfargument name="quality" type="numeric" required="false" default="1" hint="This is only required for image writes" />
		
		<cfargument name="nameconflict" type="string" required="false" default="overwrite" options="makeunique,overwrite" />
		<cfargument name="uniqueamong" type="string" required="false" default="" hint="If nameconflict=makeunique, then the file is made to be unique among this list of locations" />
		
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfif arguments.nameconflict eq "makeunique" and not len(arguments.uniqueamong)>
			<cfset arguments.uniqueamong = arguments.location />
		</cfif>
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfif arguments.nameconflict eq "makeunique">
			<cfset arguments.file = ioGetUniqueFilename(locations=arguments.uniqueamong,file=arguments.file) />
		</cfif>
		
		<cfset this.cdns[config.cdn].ioWriteFile(config=config,argumentCollection=arguments) />
		
		<cfreturn arguments.file />
	</cffunction>
	
	<!--- @@description: 
		<p>Reads from the specified file.</p>
		
		@@examples:
		<code>
			<cfimage action="info" source="#application.fc.lib.cdn.ioReadFile(location='images',file=stResult.value,datatype='image')#" structName="stImage" />
		</code>
	 --->
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfreturn this.cdns[config.cdn].ioReadFile(config=config,argumentCollection=arguments) />
	</cffunction>
	
	<!--- @@description: 
		<p>Moves the specified file between locations.</p>
		<p>
			Note that when moving a file between different CDN types, this function moves the file to the local temporary directory,
			then to the target location from there.
		</p>
		<p>Note that while every argument is marked as optional, in practice you need:</p>
		<ul>
			<li>source_location and source_file OR source_localpath</li>
			<li>dest_location and dest_file OR dest_localpath</li>
		</ul>
		
		@@examples:
		<code>
			<cfset application.fc.lib.cdn.ioMoveFile(source_location="publicfiles",source_file=arguments.stObject[arguments.stMetadata.name],dest_location="privatefiles") />
		</code>
	 --->
	<cffunction name="ioMoveFile" returntype="string" access="public" output="false" hint="Moves the specified file between locations">
		<cfargument name="source_location" type="string" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		
		<cfargument name="dest_location" type="string" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfargument name="nameconflict" type="string" required="false" default="overwrite" options="makeunique,overwrite" />
		<cfargument name="uniqueamong" type="string" required="false" default="" hint="If nameconflict=makeunique, then the file is made to be unique among this list of locations" />
		
		
		<cfset var stArgs = structnew() />
		<cfset var tmp = "#getTempDirectory()##createuuid()#.tmp" />
		<cfset var resultfilename = "" />
		
		<cfif arguments.nameconflict eq "makeunique" and not len(arguments.uniqueamong) and structkeyexists(arguments,"dest_location")>
			<cfset arguments.uniqueamong = arguments.dest_location />
		</cfif>
		
		<!--- Prepare source information --->
		<cfif structkeyexists(arguments,"source_location") and structkeyexists(arguments,"source_file")>
			<cfset stArgs.source_config = this.locations[arguments.source_location] />
			<cfset stArgs.source_file = normalizePath(arguments.source_file) />
		<cfelseif structkeyexists(arguments,"source_localpath")>
			<cfset stArgs.source_localpath = arguments.source_localpath />
		<cfelse>
			<cfthrow message="ioMoveFile file must be passed source_location and source_file OR source_localpath" />
		</cfif>
		
		<!--- Prepare destination information  --->
		<cfif structkeyexists(arguments,"dest_location") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
			<cfset stArgs.dest_config = this.locations[arguments.dest_location] />
			
			<cfif structkeyexists(arguments,"dest_file")>
				<cfset stArgs.dest_file = normalizePath(arguments.dest_file) />
			<cfelse>
				<cfset stArgs.dest_file = normalizePath(arguments.source_file) />
			</cfif>
			
			<cfif arguments.nameconflict eq "makeunique">
				<cfset stArgs.dest_file = ioGetUniqueFilename(locations=arguments.uniqueamong,file=arguments.dest_file) />
			</cfif>
			
			<cfset resultfilename = stArgs.dest_file />
		<cfelseif structkeyexists(arguments,"dest_localpath")>
			<cfset stArgs.dest_localpath = arguments.dest_localpath />
			
			<cfif arguments.nameconflict eq "makeunique">
				<cfset stArgs.dest_localpath = ioGetUniqueFilename(file=arguments.dest_localpath) />
			</cfif>
			
			<cfset resultfilename = stArgs.dest_localpath />
		<cfelse>
			<cfthrow message="ioMoveFile file must be passed dest_location and dest_file OR dest_localpath" />
		</cfif>
		
		<!--- Move file --->
		<cfif structkeyexists(stArgs,"source_config") and structkeyexists(stArgs,"dest_config") and stArgs.source_config.cdn eq stArgs.dest_config.cdn>
			<cfset this.cdns[stArgs.source_config.cdn].ioMoveFile(argumentCollection=stArgs) />
		<cfelseif structkeyexists(stArgs,"source_localpath")>
			<cfset this.cdns[stArgs.dest_config.cdn].ioMoveFile(argumentCollection=stArgs) />
		<cfelseif structkeyexists(stArgs,"dest_localpath")>
			<cfset this.cdns[stArgs.source_config.cdn].ioMoveFile(argumentCollection=stArgs) />
		<cfelse>
			<cfset this.cdns[stArgs.source_config.cdn].ioMoveFile(source_config=stArgs.source_config,source_file=stArgs.source_file,dest_localpath=tmp) />
			<cfset this.cdns[stArgs.dest_config.cdn].ioMoveFile(source_localpath=tmp,dest_config=stArgs.dest_config,dest_file=stArgs.dest_file) />
		</cfif>
		
		<cfreturn resultfilename />
	</cffunction>
	
	<!--- @@description: 
		<p>Copies the specified file between locations.</p>
		<p>
			Note that when copying a file between different CDN types, this function copies the file to the local temporary directory,
			then moves it to the target location from there.
		</p>
		<p>Note that while every argument is marked as optional, in practice you need:</p>
		<ul>
			<li>source_location and source_file OR source_localpath</li>
			<li>dest_location and dest_file OR dest_localpath</li>
		</ul>
		
		@@examples:
		<code>
			<cfset application.fc.lib.cdn.ioCopyFile(
				source_location="images",
				source_file=stLocal.stInstance.thumbnail,
				dest_location="archive",
				dest_file="/#stLocal.stInstance.typename#/#stLocal.stProps.archiveID#_thumb.#ListLast(stLocal.stInstance.thumbnail,'.')#"
			) />
		</code>
	 --->
	<cffunction name="ioCopyFile" returntype="string" access="public" output="false" hint="Moves the specified file between paths">
		<cfargument name="source_location" type="string" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		
		<cfargument name="dest_location" type="string" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfargument name="nameconflict" type="string" required="false" default="overwrite" options="makeunique,overwrite" />
		<cfargument name="uniqueamong" type="string" required="false" default="" hint="If nameconflict=makeunique, then the file is made to be unique among this list of locations" />
		
		
		<cfset var stArgs = structnew() />
		<cfset var tmp = "#getTempDirectory()##createuuid()#.tmp" />
		<cfset var resultfilename = "" />
		
		<cfif arguments.nameconflict eq "makeunique" and not len(arguments.uniqueamong) and structkeyexists(arguments,"dest_location")>
			<cfset arguments.uniqueamong = arguments.dest_location />
		</cfif>
		
		<!--- Prepare source information --->
		<cfif structkeyexists(arguments,"source_location") and structkeyexists(arguments,"source_file")>
			<cfset stArgs.source_config = this.locations[arguments.source_location] />
			<cfset stArgs.source_file = normalizePath(arguments.source_file) />
		<cfelseif structkeyexists(arguments,"source_localpath")>
			<cfset stArgs.source_localpath = arguments.source_localpath />
		<cfelse>
			<cfthrow message="ioCopyFile file must be passed source_location and source_file OR source_localpath" />
		</cfif>
		
		<!--- Prepare destination information --->
		<cfif structkeyexists(arguments,"dest_location") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
			<cfset stArgs.dest_config = this.locations[arguments.dest_location] />
			
			<cfif structkeyexists(arguments,"dest_file")>
				<cfset stArgs.dest_file = normalizePath(arguments.dest_file) />
			<cfelse>
				<cfset stArgs.dest_file = normalizePath(arguments.source_file) />
			</cfif>
			
			<cfif arguments.nameconflict eq "makeunique">
				<cfset stArgs.dest_file = ioGetUniqueFilename(locations=arguments.uniqueamong,file=arguments.dest_file) />
			</cfif>
			
			<cfset resultfilename = stArgs.dest_file />
		<cfelseif structkeyexists(arguments,"dest_localpath")>
			<cfset stArgs.dest_localpath = arguments.dest_localpath />
			
			<cfif arguments.nameconflict eq "makeunique">
				<cfset stArgs.dest_localpath = ioGetUniqueFilename(file=arguments.dest_localpath) />
			</cfif>
			
			<cfset resultfilename = stArgs.dest_localpath />
		<cfelse>
			<cfthrow message="ioCopyFile file must be passed dest_location and dest_file OR dest_localpath" />
		</cfif>
		
		<!--- Copy file --->
		<cfif structkeyexists(stArgs,"source_config") and structkeyexists(stArgs,"dest_config") and stArgs.source_config.cdn eq stArgs.dest_config.cdn>
			<cfset this.cdns[stArgs.source_config.cdn].ioCopyFile(argumentCollection=stArgs) />
		<cfelseif structkeyexists(stArgs,"source_localpath")>
			<cfset this.cdns[stArgs.dest_config.cdn].ioCopyFile(argumentCollection=stArgs) />
		<cfelseif structkeyexists(stArgs,"dest_localpath")>
			<cfset this.cdns[stArgs.source_config.cdn].ioCopyFile(argumentCollection=stArgs) />
		<cfelse>
			<cfset this.cdns[stArgs.source_config.cdn].ioCopyFile(source_config=stArgs.source_config,source_file=stArgs.source_file,dest_localpath=tmp) />
			<cfset this.cdns[stArgs.dest_config.cdn].ioMoveFile(source_localpath=tmp,dest_config=stArgs.dest_config,dest_file=stArgs.dest_file) />
		</cfif>
		
		<cfreturn resultfilename />
	</cffunction>
	
	<cffunction name="ioValidateFile" returntype="string" access="public" output="false" hint="Validates the specified file and returns an error if there is one">
		<cfargument name="location" type="string" required="false" />
		<cfargument name="file" type="string" required="false" />
		<cfargument name="localpath" type="string" required="false" />
		
		<cfargument name="acceptextensions" type="string" required="false" />
		<cfargument name="sizeLimit" type="numeric" required="false" />
		<cfargument name="existingfile" type="string" requried="false" />
		
		<cfset var message = "" />
		
		<!--- Check the extension --->
		<cfif structkeyexists(arguments,"acceptextensions") 
			AND len(arguments.acceptextensions) 
			AND not listfindnocase(arguments.acceptextensions,listlast(arguments.file,"."))>
			
			<cfset message = "Invalid extension. Valid extensions are {1}" />
			<cfreturn application.fapi.getResource(key="FAPI.throw.#rereplaceNoCase(message, '[^/w]+', '_', 'all')#@message", default=message, substituteValues=[ replace(arguments.acceptextensions,",",", ","ALL") ]) />
		</cfif>
		
		<!--- Check the size of the uploaded file --->
		<cfif structkeyexists(arguments,"sizeLimit") 
			AND arguments.sizeLimit gt 0
			AND (
				(structkeyexists(arguments,"localpath") and getFileInfo(arguments.localpath).filesize gt arguments.sizeLimit)
				OR (structkeyexists(arguments,"location") and ioGetFileSize(location=arguments.location,file=arguments.file) gt arguments.sizeLimit)
			)>
			
			<cfset message = "File size is not within limit of {1}MB" />
			<cfreturn application.fapi.getResource(key="FAPI.throw.#rereplaceNoCase(message, '[^/w]+', '_', 'all')#@message", default=message, substituteValues=round(arguments.sizeLimit/1048576)) />
		</cfif>
		
		<!--- file destinations must must have the same extension as the new file --->
		<!--- <cfif structkeyexists(arguments,"existingFile") 
			AND refind("\.\w+$",arguments.destination) 
			AND listlast(arguments.file,".") neq listlast(arguments.existingFile)>
			
			<cfset message = "New file must have the same extension. Current extension is {1}" />
			<cfreturn application.fapi.getResource(key="FAPI.throw.#rereplaceNoCase(message, '[^/w]+', '_', 'all')#@message", default=message, substituteValues=[ listlast(arguments.destination,".") ]) />
		</cfif>
		 --->
		<cfreturn "" />
	</cffunction>
	
	<!--- @@description: 
		<p>Uploads the a file to the specified location.</p>
		
		@@examples:
		<code>
			<cfset stResult.value = application.fc.lib.cdn.ioUploadFile(
			    location="securefiles",
			    destination=arguments.stMetadata.ftDestination,
			    field="#stMetadata.FormFieldPrefix##stMetadata.Name#New",
			    nameconflict="makeunique",
			    uniqueamong="privatefiles,publicfiles",
			    acceptedextensions=arguments.stMetadata.ftAllowedFileExtensions
			) />
		</code>
	 --->
	<cffunction name="ioUploadFile" returntype="string" access="public" output="false" hint="Uploads the a file to the specified location">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		<cfargument name="field" type="string" required="true" />
		<cfargument name="nameconflict" type="string" required="false" default="overwrite" options="makeunique,overwrite" />
		<cfargument name="uniqueamong" type="string" required="false" default="" hint="If nameconflict=makeunique, then the file is made to be unique among this list of locations" />
		<cfargument name="acceptextensions" type="string" required="false" />
		<cfargument name="sizeLimit" type="numeric" required="false" />
		
		<cfset var filename = "" />
		<cfset var cffile = structnew() />
		<cfset var tmpdir = GetTempDirectory() />
		
		<cfif arguments.nameconflict eq "makeunique" and not len(arguments.uniqueamong)>
			<cfset arguments.uniqueamong = arguments.location />
		</cfif>
		<cfset arguments.destination = normalizePath(arguments.destination) />
		
		<!--- Check that there is a file to upload --->
		<cfif not len(form[arguments.field])>
			<cfset application.fapi.throw(message="No file was uploaded",type="uploaderror") />
		</cfif>
		
		<cffile action="upload" filefield="#arguments.field#" destination="#tmpdir#" nameconflict="MakeUnique" mode="664" result="cffile" />
		
		<cfset errormessage = ioValidateFile(
			localpath="#tmpdir#/#cffile.serverFile#",
			acceptextensions=arguments.acceptextensions,
			sizeLimit=arguments.sizeLimit,
			existingFile=arguments.destination
		) />
		<cfthrow message="#errormessage#" type="uploaderror" />
		
		<!--- DESTINATION can specify a directory or a file --->
		<cfif refind("\.\w+$",arguments.destination)>
			<cfset filename = arguments.destination />
		<cfelse>
			<cfset filename = arguments.destination & "/" & cffile.ServerFile />
		</cfif>
		
		<cfset filename = ioMoveFile(source_localpath="#tmpdir##cffile.serverFile#",dest_location=arguments.location,dest_file=filename,nameconflict=arguments.nameconflict,uniqueamong=arguments.uniqueamong) />
		
		<cfreturn filename />
	</cffunction>
	
	<!--- @@description: 
		<p>Deletes the specified file.</p>
		
		@@examples:
		<code>
			<cfset application.fc.lib.cdn.ioDeleteFile(location="images",file="/#arguments.stObject[arguments.stMetadata.name]#") />
		</code>
	 --->
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.file = normalizePath(arguments.file) />
		
		<cfset this.cdns[config.cdn].ioDeleteFile(config=config,file=arguments.file) />
	</cffunction>
	
	
	<!--- @@description: 
		<p>
			Checks that a specified directory exists. All CDN functions which create a file already perform internal checks to 
			find out if a directory needs to be created first. As a result, there is no example in core of a call to this function.
		</p>
		
		@@examples:
		<code>
			<cfif application.fc.lib.cdn.ioDirectoryExists(location="images",file="/#stMetadata.ftDestination#")>
			    <!--- something here --->
			</cfif>
		</code>
	 --->
	<cffunction name="ioDirectoryExists" returntype="boolean" access="public" output="false" hint="Checks that a specified directory exists">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.dir = normalizePath(arguments.dir) />
		
		<cfset this.cdns[config.cdn].ioDirectoryExists(config=config,dir=arguments.dir) />
	</cffunction>
	
	<!--- @@description: 
		<p>
			Creates the specified directory, including parent directories. All CDN functions which create a file already perform 
			internal checks and create directories as necessary. As a result, there is no example in core of a call to this function.
		</p>
		<p>Creates the specified directory, including parent directories.</p>
		
		@@examples:
		<code>
			<cfif application.fc.lib.cdn.ioDirectoryExists(location="images",file="/#stMetadata.ftDestination#")>
			    <!--- something here --->
			</cfif>
		</code>
	 --->
	<cffunction name="ioCreateDirectory" returntype="void" access="public" output="false" hint="Creates the specified directory, including parent directories.">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.dir = normalizePath(arguments.dir) />
		
		<cfset this.cdns[config.cdn].ioCreateDirectory(config=config,dir=arguments.dir) />
	</cffunction>
	
	<!--- @@description: 
		<p>
			Returns a query containing the files under the specfied directory. The resulting query has a single field "file", which 
			is the full path as would be passed into the other CDN functions. The results are recursive and do not include directories, 
			except by implication.
		</p>
		<p>
			It is worth noting that the "images" location is unusual in that it usually corresponds to the project WWW directory,
			and so a naive query to the "images" location will return everything in the webroot. In practice, listings of "images"
			should be filtered by /images.
		</p>
		
		@@examples:
		<code>
			<cfset qSourceFiles = application.fc.lib.cdn.ioGetDirectoryListing(location=form.source_location,dir=form.source_filter) />
			<cfset qTargetFiles = application.fc.lib.cdn.ioGetDirectoryListing(location=form.target_location,dir=form.target_filter) />
			
			<cfset stFound = structnew() />
			<cfloop query="qSourceFiles">
				<cfif not structkeyexists(stFound,qSourceFiles.file)>
					<cfset stFound[qSourceFiles.file] = 1 />
				<cfelse>
					<cfset stFound[qSourceFiles.file] = stFound[qSourceFiles.file] + 1 />
				</cfif>
			</cfloop>
			<cfloop query="qTargetFiles">
				<cfif not structkeyexists(stFound,qTargetFiles.file)>
					<cfset stFound[qTargetFiles.file] = 2 />
				<cfelse>
					<cfset stFound[qTargetFiles.file] = stFound[qTargetFiles.file] + 2 />
				</cfif>
			</cfloop>
			
			
			<cfloop collection="#stFound#" item="thisfile">
				<cfset queryaddrow(qFiles) />
				<cfset querysetcell(qFiles,"file",thisfile) />
				<cfset querysetcell(qFiles,"inSource",bitand(stFound[thisfile],1) eq 1) />
				<cfset querysetcell(qFiles,"inTarget",bitand(stFound[thisfile],2) eq 2) />
			</cfloop>
			
			<cfquery dbtype="query" name="qFiles">select * from qFiles order by file</cfquery>
		</code>
	 --->
	<cffunction name="ioGetDirectoryListing" returntype="query" access="public" output="false" hint="Lists the files the specfied directory.">
		<cfargument name="location" type="string" required="true" />
		<cfargument name="dir" type="string" required="false" default="" />
		
		<cfset var config = this.locations[arguments.location] />
		
		<cfset arguments.dir = normalizePath(arguments.dir) />
		
		<cfreturn this.cdns[config.cdn].ioGetDirectoryListing(config=config,dir=arguments.dir) />
	</cffunction>
	
</cfcomponent>