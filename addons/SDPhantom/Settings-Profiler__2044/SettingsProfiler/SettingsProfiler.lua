--[[	Settings Profiler
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

--------------------------
--[[	Namespace	]]
--------------------------
local AddOnName,AddOn=debug.traceback():match("\nuser:/AddOns/([^/]+)"),{};
_G[AddOnName]=AddOn;

--------------------------
--[[	Print Handler	]]
--------------------------
local print; do
	local MessageBuffer={};--	Message Cache
	local PrintBuffer={};--	Segment Buffer

	local function FlushBuffer()
		local msg=table.concat(PrintBuffer," ");--	Concatenate Segments
		for i=#PrintBuffer,1,-1 do PrintBuffer[i]=nil; end--	Clear Buffer
		if msg:find("%S") then
			msg=msg:match("^%s*(.-)%s*$");
			if MessageBuffer then table.insert(MessageBuffer,msg);--	Add to Message Cache
			else CHAT_SYSTEM:AddMessage(msg); end--	Print Message
		end
	end

	function print(...)
		for i=1,select("#",...) do
			local str,split=tostring((select(i,...))),false;
			for str in str:gmatch("[^\r\n]+") do--	Iterate Lines
				if split then FlushBuffer(); end--	Process if new line
				table.insert(PrintBuffer,str);--	Add Segment
				split=true;--	Flag for additional lines
			end
		end
		if #PrintBuffer>0 then FlushBuffer(); end--	Flush remaining segments
	end

--	Load Hook (Runs on either EVENT_ADD_ON_LOADED or EVENT_PLAYER_ACTIVATED, whichever fires later)
--	This function is responsable for setting up CHAT_SYSTEM to accept messages
	local SharedChatSystem_LoadChatFromSettings=SharedChatSystem.LoadChatFromSettings;
	function SharedChatSystem:LoadChatFromSettings(...)
		SharedChatSystem_LoadChatFromSettings(self,...);
		for _,msg in ipairs(MessageBuffer) do CHAT_SYSTEM:AddMessage(msg); end--	Print from Cache
		MessageBuffer=nil;--	Wipe Cache
	end
end
AddOn.Print=print;

----------------------------------
--[[	Support Functions	]]
----------------------------------
local function SaveOnWrite(child,parent,key)
	local meta=getmetatable(child);
	if not meta then meta={}; setmetatable(child,meta); end
	function meta.__newindex(t,k,v)
		if v==nil then return; end--	Setting an empty value to nil isn't writing
		parent[key]=t;--		Write ourselves to given table[key]

		meta.__newindex=nil;--					Remove this function
		if not next(meta) then setmetatable(t,nil); end--	Remove metatable if empty

		rawset(t,k,v);--	Don't forget to set this
	end
	return child;
end

local function ApplyMetadata(tbl,key,val)--	Adds value to metatable or creates one if needed
	local meta=getmetatable(tbl);
	if type(meta)=="table" then AddOn.SetPath(meta,"__index",key,val);--	Write Value
	elseif val~=nil then setmetatable(tbl,{__index={[key]=val}}); end--	Create Metatable (if we're writing something non-nil)
end

local function MergeTables(from,to,overwrite)
	local stack,key,destlook={from},nil,{[from]=to};
	while #stack>0 do
		local tbl=stack[1];--	Current table on stack
		key=next(tbl,key);--	Key Iterator

		if key~=nil then--			Do we have a key?
			local val=tbl[key];--			Current Value

			local desttbl=destlook[tbl];--		Destination Table
			local destval=desttbl[key];--		Destination Value

			if overwrite or destval==nil then--	Are we allowed to write?
				if type(val)=="table" then--		Is this a table?
					if not destlook[val] then--		Is this a new table?
						table.insert(stack,val);--		Add table to stack
						if type(destval)~="table" then--	Is existing data at this key not a table?
							local newtbl={};--			New Destination Table
							desttbl[key]=newtbl;--			Write new table to destination
							destlook[val]=newtbl;--			Register new table as destination for current one
						else destlook[val]=destval; end--		Register existing table as destination for current one
					else desttbl[key]=destlook[val]; end--		Mimic reference to an already processed table
				else desttbl[key]=val; end--		Write value to destination table
			end
		else table.remove(stack,1); end--	Remove table from stack
	end
end

--------------------------
--[[	API Variables	]]
--------------------------
local AcctName,CharID=GetDisplayName(),GetCurrentCharacterId();
AddOn.AcctName,AddOn.CharID=AcctName,CharID;

--------------------------
--[[	Table Path API	]]
--------------------------
--	These support calls on both self and given tables based on if called by : or .
function AddOn.SetPath(tbl,...)
	tbl=(type(tbl)=="table" and tbl or {});
	local cur,key,len=tbl,...,select("#",...);--	Initialize vars to their first step
	local new=select(len,...);--	The value we set is at the end of the vararg
	for i=2,len-1 do
		local val=cur[key];
		if type(val)~="table" then--	Overwrite any non-table value in the path with a new table
			if new==nil then return; end--	Exit if we would be setting nil (Doesn't make sense to set something that doesn't exist to nothing)
			val={}; cur[key]=val;--	New Table
		end
		cur,key=val,select(i,...);--	Index Step
	end
	cur[key]=new;--	Final Assignment
end

function AddOn.MakePath(tbl,...)
	for i=1,select("#",...) do
		local key=select(i,...);
		local val=tbl[key];--	Temporarily grab value for processing
		if type(val)~="table" then val={}; tbl[key]=val; end--	Overwrite any non-table value in the path with a new table
		tbl=val;--	Index Step
	end
	return tbl;--	Final Table
end

function AddOn.GetPath(tbl,...)
	if type(tbl)~="table" then return nil; end--	Can't index non-tables

	tbl=tbl[(...)];--	We don't need to be in the loop to take our first step
	for i=2,select("#",...) do
		if type(tbl)~="table" then return nil; end--	Return nil if we run into a non-table
		tbl=tbl[(select(i,...))];--	Index Step
	end
	return tbl;--	This is our final value (Doesn't have to be a table at this point)
end

--------------------------
--[[	Save Module API	]]
--------------------------
AddOn.Modules={};

do--	function AddOn:RegisterSaveModule(mod)
	local function HandleModCallback(mod,key,func,...)--	Since this handles both hooks and events, might as well consolidate this to a single function
		local profile=AddOn.ActiveProfile;
		if profile then
			local updated,newval=func(mod,profile.Data[key],...);
			if updated then
				local now=os.time();
				profile.Data[key]=newval;
				profile.Timestamps[key]=now;
				if AddOn.CharSave then AddOn.CharSave.Timestamps[key]=now; end--	We can only get here if we have a linked profile (Just check if we've loaded yet)
			end
		end
	end

--	Vararg wrap functions
	local function Wrap(...) local tbl={...}; tbl.n=select("#",...); return tbl; end
	local function Unwrap(tbl) return unpack(tbl,1,tbl.n or #tbl); end

	function AddOn:RegisterSaveModule(name,mod)
		self.Modules[name]=mod;

--		Note: Callbacks should only be registered if saving data needs to be handled
		if mod.Hooks then--	Hook-based Callbacks
			for _,info in ipairs(mod.Hooks) do
				local tbl,key,func,posthook=unpack(info);
				local origfunc=tbl[key];
				tbl[key]=(posthook and
					function(...)--	Post-Hook Function
						local ret=Wrap(origfunc(...));--	Call here, run hook, then return original values
						HandleModCallback(mod,name,func,...);
						return Unwrap(ret);--	Not the best method, but the only way for this kind of hook
					end
				or
					function(...)--	Pre-Hook Function
						HandleModCallback(mod,name,func,...);
						return origfunc(...);--	Preferred way, just straight up return via a tail call
					end
				);
			end
		end
		if mod.Events then--	Event-based Callbacks
			local namespace,list=AddOnName.."_SaveMod_"..name,mod.Events;
			for i=1,#list,2 do--	Comes in pairs, event(s) and callback
				local events,func=list[i],list[i+1];
				local eventfunc=function(...) return HandleModCallback(mod,name,func,...); end--	Tail calls replace the current function on the stack with the called one
				if type(events)=="table" then--	Support listing multiple events to one callback
					for _,event in ipairs(events) do EVENT_MANAGER:RegisterForEvent(namespace,event,eventfunc); end
				else EVENT_MANAGER:RegisterForEvent(namespace,events,eventfunc); end
			end
		end
	end
end

--------------------------
--[[	Profile API	]]
--------------------------
function AddOn:CreateProfile(name)
	local profile={Data={},Timestamps={}};--	Profile Structure
	if name==nil then return profile; end--	Don't process further if we don't have a name

--	Add Metadata
	ApplyMetadata(profile,"Name",name);

--	Add to Profile List
	self.AcctSave.Profiles[name]=profile;
	return profile;
end

function AddOn:GetProfile(name)--	Case-insensitive profile lookup, also normalizes the name/profile argument of the SaveDataAPI functions below
	if name==nil then return self.ActiveProfile; end--	If we were given nil, return linked profile (even if it doesn't exist, just let it return nil)
	if type(name)=="table" then return name; end--	We were actually given our profile, this function is expected to just return it
	if not self.AcctSave then return; end

--	Return exact match
	local profile=self.AcctSave.Profiles[name];
	if profile then return profile; end

--	Case-insensitive search
	local namelower=name:lower();
	for key,val in pairs(self.AcctSave.Profiles) do if key:lower()==namelower then return val; end end
end

--------------------------
--[[	Save Data API	]]
--------------------------
AddOn.ActiveProfile=AddOn:CreateProfile(nil);--	Temporary empty profile to cache save changes (applied on load or dropped as necessary)

local function WipeCharSaveData(charkey)
	local acctdata,charsave=AddOn.RawSave.Default[AcctName],AddOn.CharSave;
	for k in next,charsave do charsave[k]=nil; end--	Wipe Data
	acctdata[CharID]=nil; SaveOnWrite(charsave,acctdata,CharID);--	Wipe Pointer and Re-register Save-On-Write
end

local function InitSaveData()
--	Build/Acquire Saves
	local rawsave=SettingsProfiler_SaveData or {};
	local acctsave=AddOn.MakePath(rawsave,"Default",AcctName,"$AccountWide");
	local charsave=rawsave.Default[AcctName][CharID] or SaveOnWrite({},rawsave.Default[AcctName],CharID);
	SettingsProfiler_SaveData=rawsave;

	do--	Save Migration (See Migration.lua)
--		Convert ZO_SavedVars in version 1 to our custom format
		if acctsave.version then acctsave.Version,acctsave.version,charsave.version,charsave["$LastCharacterName"]=acctsave.version,nil,nil,nil; end

--		Setup
		local funclist=AddOn.SaveMigration;
		local numfuncs=funclist and #funclist or 0;
		local minver=AddOn.MinSaveVersion or 1;
		local curver=minver+numfuncs;
		local savever=acctsave.Version;

--		Migration
		if savever and savever~=curver then
			if savever>=minver then
				for i=savever-minver+1,numfuncs do funclist[i](acctsave,charsave); end
			else SettingsProfiler_SaveData={}; return InitSaveData(); end--	Call again with wiped data
		end
		acctsave.Version=curver;--	Update version
	end

--	Init Data
	AddOn.MakePath(acctsave,"Profiles");

--	Apply Metadata (Data we want to make accessable to profile functions, but don't want written to save)
	for name,profile in pairs(acctsave.Profiles) do ApplyMetadata(profile,"Name",name); end

--	Write to Namespace
	AddOn.RawSave,AddOn.AcctSave,AddOn.CharSave=rawsave,acctsave,charsave;

	do--	Module Save Migration
		local verlist=AddOn.MakePath(acctsave,"ModuleVersions");
		for name,mod in pairs(AddOn.Modules) do
--			Setup
			local funclist=mod.SaveMigration;
			local numfuncs=funclist and #funclist or 0;
			local minver=mod.MinSaveVersion or 1;
			local curver=minver+numfuncs;
			local savever=verlist[name];

--			Migration
			if savever and savever~=curver then
				if savever>=minver then
					for i=savever-minver+1,numfuncs do
						if acctsave.Default and acctsave.Default.Timestamps[name] then acctsave.Default.Data[name]=funclist[i](acctsave.Default.Data[name]); end--	Update Default Data
						for _,profile in pairs(acctsave.Profiles) do
							if profile.Timestamps[name] then profile.Data[name]=funclist[i](profile.Data[name]); end--	Update Profile Data
						end
					end
				else
					if acctsave.Default and acctsave.Default.Timestamps[name] then acctsave.Default.Data[name],acctsave.Default.Timestamps[name]=nil,nil; end--	Wipe Default Data
					for _,profile in pairs(acctsave.Profiles) do profile.Data[name],profile.Timestamps[name]=nil,nil; end--	Wipe Profile Data
				end
			end
			verlist[name]=curver;--	Update version
		end
	end

	return rawsave,acctsave,charsave;
end

function AddOn:SetProfile(profile)
	profile=self:GetProfile(profile) or self:CreateProfile(profile);

	local chartimetbl,now={},os.time();
	local datatbl,timetbl=profile.Data,profile.Timestamps;
	for key,mod in pairs(self.Modules) do
		if timetbl[key] then--				Has Timestamp (Load)
			mod:Load(datatbl[key]);--		Load Data
			chartimetbl[key]=timetbl[key];--	Copy Timestamp
		else--							Missing Timestamp (Save)
			datatbl[key]=mod:Save(datatbl[key]);--		Save Data
			timetbl[key],chartimetbl[key]=now,now;--	Mark as current time
		end
	end

--	Apply Links and Save Timestamps (if loading Default, profile.Name is nil)
	self.ActiveProfile,self.CharSave.Profile,self.CharSave.Timestamps=profile,profile.Name,chartimetbl;
	return profile;
end

function AddOn:ClearProfile()
	local charsave=self.CharSave;
	if not charsave.Profile then return; end--	Exit if not linked

	local profile=self.AcctSave.Default;
	if profile then self:SetProfile(profile); else--	Load Default
--		Default is empty
		self.ActiveProfile,charsave.Profile,charsave.Timestamps=nil,nil,nil;--	Erase Profile Link
		if next(charsave)==nil then WipeCharSaveData(); end--	Wipe CharSave if empty
	end
end

function AddOn:RenameProfile(profile,newname)
	profile=self:GetProfile(profile);
	if not profile or profile.Name==newname then return; end--	Exit if names are the same (Allow case change)

	local existing=self:GetProfile(newname);
	if existing and existing~=profile then return; end--	Don't Overwrite (Profile names are case-insensitive, we'll get back the same profile if the names are equivalent)

	local oldname=profile.Name;
	ApplyMetadata(profile,"Name",newname);--	Apply Name Change
	self.AcctSave[newname],self.AcctSave[oldname]=profile,nil;--	Move Profile

--	Update Links
	if self.CharSave.Profile==oldname then self.CharSave.Profile=newname; end
	for id,data in pairs(self.RawSave.Default[Acct]) do
		if id~="$AccountWide" and data.Profile==oldname then data.Profile=newname; end
	end
end

function AddOn:DeleteProfile(profile)
	profile=self:GetProfile(profile);
	if not profile then return; end

	local name=profile.Name;
	self.AcctSave.Profiles[name]=nil;--	Delete Profile
	if name==self.CharSave.Profile then self:ClearProfile(); end--	Unload if Active Profile

--	Remove orphaned data
	local charlist=self.RawSave.Default[AcctName];
	for id,data in pairs(charlist) do
		if id~="$AccountWide" and data.Profile==name then
			data.Profile,data.Timestamps=nil,nil;--	Wipe Link and Timestamps
			if next(data)==nil then charlist[id]=nil; end--	Remove if empty
		end
	end
end

function AddOn:SaveDefault()
--	Get or Make Default
	local default=self.AcctSave.Default;
	if not default then default=self:CreateProfile(nil); self.AcctSave.Default=default; end

	if not self.ActiveProfile then
		self.ActiveProfile=default;--	Set Default as Active Profile
		self.CharSave.Timestamps={};--	Create Timestamps table
	end

--	Save to Default
	local sync,chartimetbl,now=(default==self.ActiveProfile),self.CharSave.Timestamps,os.time();
	local datatbl,timetbl=default.Data,default.Timestamps;
	for key,mod in pairs(self.Modules) do
		datatbl[key],timetbl[key]=mod:Save(datatbl[key]),now;
		if sync then chartimetbl[key]=now; end--	Set to current time if Active Profile
	end
end

function AddOn:ClearDefault()
	local default=self.AcctSave.Default;
	if not default then return; end

	self.AcctSave.Default=nil;--	Clear Default
	if self.ActiveProfile==default then
		self.ActiveProfile=nil;--	Clear Active Profile
		self.CharSave.Timestamps=nil;--	Wipe Timestamps
		if next(self.CharSave)==nil then WipeCharSaveData(); end--	Wipe CharSave if empty
	end

--	Remove orphaned data
	local charlist=self.RawSave.Default[AcctName];
	for id,data in pairs(charlist) do
		if id~="$AccountWide" and id~=CharID and not data.Profile then--	Don't process AcctSave or CharSave
			data.Timestamps=nil;--	Wipe Timestamps
			if next(data)==nil then charlist[id]=nil; end--	Remove if empty
		end
	end
end

function AddOn:Reset()
	self.ActiveProfile=nil;--	Clear Active Profile
	SettingsProfiler_SaveData={};--	Wipe everything
	InitSaveData();--		Re-init Save Data
end

------------------
--[[	Events	]]
------------------
EVENT_MANAGER:RegisterForEvent(AddOnName,EVENT_ADD_ON_LOADED,function(_,addon)
	if addon==AddOnName then
		EVENT_MANAGER:UnregisterForEvent(AddOnName,EVENT_ADD_ON_LOADED);

--		Init Save Data
		local rawsave,acctsave,charsave=InitSaveData();

--		Acquire Profile and Link Validation
		local profile; do
			local name=charsave.Profile;
			profile=name and AddOn:GetProfile(name);
			if not profile then
				profile=acctsave.Default;--	Load Default
				if name or (not profile and charsave.Timestamps) then
					charsave.Profile,charsave.Timestamps=nil,nil;--	Clean up lingering data
					if next(charsave)==nil then WipeCharSaveData(); end--	Wipe CharSave if empty
				end
			end
		end

--		Load Profile (if exists)
		if profile then
			print(profile.Name and ("Linked profile |cffffff%s|r"):format(profile.Name) or "Linked default profile");

--			Grab our preload cache and set the real profile
			local preloadcache=AddOn.ActiveProfile;
			AddOn.ActiveProfile=profile;

--			Setup Locals
			local chartimetbl=AddOn.MakePath(charsave,"Timestamps");--	Sanity check, if we have a profile set, we should have a timestamp table
			local datatbl,timetbl=profile.Data,profile.Timestamps;

--			Sync preload cache into linked profile
			if next(preloadcache.Data) then
				MergeTables(preloadcache.Data,datatbl,true);--	Merge data
				for k,v in pairs(preloadcache.Timestamps) do--	Merge timestamps
					if v<=(chartimetbl[key] or 0) then
						timetbl[k],chartimetbl[k]=v,v;--	Sync both timestamps if they were already equal so we don't call load when there was no previous change
					end
				end
			end

--			Sync save modules
			local now=os.time();
			for key,mod in pairs(AddOn.Modules) do
				if not timetbl[key] then--	If we have no timestamp, we haven't run this module before (Save)
					datatbl[key]=mod:Save(datatbl[key]);
					timetbl[key],chartimetbl[key]=now,now;--	Wrote to profile, mark both with current time
				elseif timetbl[key]~=(chartimetbl[key] or 0) then--	Profile has different (likely newer) timestamp or hasn't been applied to character (Load)
					mod:Load(datatbl[key]);
					chartimetbl[key]=timetbl[key];--	Loaded from profile, copy timestamp
				end
			end
		else AddOn.ActiveProfile=nil; end--	Remove our preload cache if we aren't loading a profile
	end
end);
