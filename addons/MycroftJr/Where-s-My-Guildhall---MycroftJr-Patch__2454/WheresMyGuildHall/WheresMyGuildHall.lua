WheresMyGuildHall = {
    name = "WheresMyGuildHall",
    version = "2.1.1",
    displayName = GetString(WMGH_NAME),
}

local SF = LibSFUtils
-- -----------------------------
-- set up chat messaging
local chatter = SF.addonChatter:New(WheresMyGuildHall.name)
local debugmode=false
chatter:disableDebug()

-- mostly because I hate to type
local function dbg(...) 
	chatter:debugMsg(...) 
end

local function sfd(...) 
	chatter:systemMessage(...) 
end
 -- -----------------------------
local WMGH = WheresMyGuildHall
local WM = WINDOW_MANAGER
local GRM = GUILD_ROSTER_MANAGER
local container = WheresMyGuildHallContainer

WMGH.playerName = ""
WMGH.guilds = {}    -- [name] {id=, name=, ndx=, numMembers=, guildMaster=, GHLhalls={}, ghlinit=, ScannedGHalls={}, ghsinit=, setting={}}
WMGH.byId = {}      -- [id] {ndx=, name=} -- same as saved.guildIndex
WMGH.numGuilds = 0  -- same as saved.numberGuilds


-- Default values for account-wide saved variables
local Default = {
        guildsettings = {}, -- [ndx] {guildName=, GuildMasterOwner=, GHL_Compatible=, GuildHallScan=}
        guildIndex = {},    -- [id] {name=, ndx=,}
        numberGuilds = 0,
    }  -- end of Default

WheresMyGuildHall_GuildEntry = {}   -- {id=, name=, numMembers=, guildMaster=, GHLhalls={}, ghlinit=, ScannedGHalls={}, ghsinit=, setting={}}
local GuildEntry = WheresMyGuildHall_GuildEntry

WheresMyGuildHall_GuildSetting = {} -- {guildName=, GuildMasterOwner=, GHL_Compatible=, GuildHallScan=}
local GuildSetting = WheresMyGuildHall_GuildSetting

local GHL_MARKER = "<GH"
local SCANGH_MARKER = "Guild Hall"


-------------------------------------------
--[[
    Empty out my saved var tables/values
]]
local function ClearSavedGuildTables()
    WMGH.saved.guildIndex = {}
    WMGH.saved.numberGuilds = 0
    WMGH.saved.guildsettings = {}
end

-- look for value in table, returning true if found, false otherwise
local function has_value (tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- look for any GHL or Guild Hall members in the guild
local function getAllMarkerHalls(guildId, numMembers, setting)
    local ghlhalls = {}
    local sghhalls = {}
    if( setting.GHL_Compatible or setting.GuildHallScan) then
        for j = 1, numMembers do
            local memberName, note = GetGuildMemberInfo(guildId, j)
			if( memberName ~= nil and note ~= nil ) then
				WMGH.ScanGuildNote(GHL_MARKER, ghlhalls, memberName, note)
				WMGH.ScanGuildNote(SCANGH_MARKER, sghhalls, memberName, note)
			end
        end
    end
    if( setting.GHL_Compatible ~= true ) then
		ghlhalls = {}
	end
    if( setting.GuildHallScan ~= true ) then
		sghhalls = {}
	end
    return ghlhalls, sghhalls
end
WMGH.getAllMarkerHalls = getAllMarkerHalls

--[[ get the guilds that the player belongs to currently ]]
local function getActiveGuilds()
    local numGuilds = GetNumGuilds()
    local guildTable = {}
    local idLookup = {}
    local gn = ""
    if( numGuilds > 0 ) then
		local g = nil
        for i = 1, numGuilds, 1 do
            WMGH.AddGuild(i, guildTable, idLookup)
        end
    end
    return numGuilds, guildTable, idLookup
end
WMGH.getActiveGuilds = getActiveGuilds

-- Update the guild entries against real guild memberships
local function loadActiveGuilds()

    -- Get active guilds list from ESO for settings 
    WMGH.numGuilds, WMGH.guilds, WMGH.byId = getActiveGuilds()
	
    local ng = WMGH.numGuilds
    local guilds = WMGH.guilds
    local byId = WMGH.byId
	dbg("Number of active guilds = "..ng)
    if(ng == 0) then
        -- we have no guilds now
        ClearSavedGuildTables()
        return
    end
	if( WMGH.guilds == nil) then
		dbg("Error: table of active guilds = nil")
        -- we have no guilds now
        ClearSavedGuildTables()
        return
	end

    -- pair old settings with current guilds
	local gs = WMGH.saved.guildsettings
	local ngs = {}
    if( next(gs) ~= nil ) then
		dbg("Reconciling existing guilds with new")
		-- guildsettings table is not empty
        for i,s in pairs(gs) do
			local gname = s.guildName
			if( gname ~= nil and guilds[gname] ~= nil ) then
				dbg("Existing guild entry updated for "..gname)
				guilds[gname]:SetSettings(s)
				ngs[guilds[gname].ndx] = s
			else
				dbg("Clearing out guild "..i)
				gs[i] = nil
			end
        end
    end
	WMGH.saved.guildsettings = ngs
	gs = ngs

    -- create settings for "new" current guilds
    for k,g in ipairs(guilds) do
        if( g.setting == nil and g.name ~= nil) then
            -- don't have a previous setting for the guild
            -- create one
			dbg("Creating a new guild entry for "..g.name)
            g:SetSettings(GuildSetting:New(g.name))
			gs[k] = g.setting
        end
    end

    -- rebuild the WMGH.saved.guildsettings to be written to savedvars
    WMGH.saved.guildIndex = byId
    WMGH.saved.numberGuilds = ng
end
WMGH.loadActiveGuilds = loadActiveGuilds

-------------------------------------------
function GuildEntry:New(id)
	local ge = {}
	setmetatable(ge, self)
	self.__index = self

	ge.id = id
	ge.name = GetGuildName(id)
	ge.numMembers, _, ge.guildMaster = GetGuildInfo(id)
    
    ge.GHLhalls = nil
    ge.ghlinit = false

    ge.ScannedGHalls = nil
    ge.ghsinit = false
    
    ge.setting = GuildSetting:New(ge.name)
	return ge
end

function GuildEntry:SetSettings(settings)
	if( settings == nil ) then return end
	self.setting = settings
end

-------------------------------------------
function GuildSetting:New(name, gmo, ghl, ghs)
	local gs = {}
	--setmetatable(gs, self)
	--self.__index = self
	
	gs.guildName = name
	gs.GuildMasterOwner = SF.nilDefault(gmo,true)
	gs.GHL_Compatible = SF.nilDefault(ghl,false)
	gs.GuildHallScan = SF.nilDefault(ghs,false)
	
	return gs
end

function GuildSetting:UpdateSaved()
	local defaults = {
		guildName = self.guildName,
		GuildMasterOwner = true,
		GHL_Compatible = false,
		GuildHallScan = false,
	}
	SF.defaultMissing(self, defaults)
end

-------------------------------------------


local GuildHallList = ZO_SortFilterList:Subclass()
local GUILDHALL_DATA = 1
local hallslist = GuildHallList:Subclass()
WMGH.hallslist = hallslist

function WMGH.AddGuild(ndx, guildTable, idNameLookup)
    local id = GetGuildId(ndx)
    dbg("player guild entry = "..ndx.."  guild id = "..id)
    g = GuildEntry:New(id)
    g.ndx = ndx
    if( g.name ~= nil ) then
        dbg("  ->    "..g.name)
        guildTable[g.name] = g
        idNameLookup[id] = { ["name"]=g.name, ["ndx"]=ndx, }
    end
end    

-- display information for guild (guildId) on the guild page
function WMGH.DoDisplay(guildId)
    dbg("Do Display "..guildId)
    
    -- clear Guild Hall list
    hallslist.masterList = {}
    if( hallslist ~= nil ) then
        hallslist:RefreshData()
    end
	
    local guild = WMGH.GetGuildById(guildId)
    if not guild then return end
    
    local settings = WMGH.GetSettingsByIndex(guild.ndx)
    
    guild.numMembers, _, guild.guildMaster = GetGuildInfo(guildId)
    -- Add guild master to list
    if( settings.GuildMasterOwner == true) then
        dbg("Adding Guildmaster "..guild.guildMaster)
        table.insert(hallslist.masterList, guild.guildMaster)
    end
    
    -- Add "<GHL" to list
    if settings.GHL_Compatible == true and guild.GHLhalls ~= nil  then
        for displayName,_ in pairs(guild.GHLhalls) do
            if( has_value(hallslist.masterList,displayName) ~= true ) then
                dbg("Adding GHL marked "..displayName)
                table.insert(hallslist.masterList, displayName)
            end
        end
    end
    
    -- add "Guild Hall" to list
    if settings.GuildHallScan == true and guild.ScannedGHalls ~= nil then
        for displayName,_ in pairs(guild.ScannedGHalls) do
            if( has_value(hallslist.masterList,displayName) ~= true ) then
                dbg("Adding GuildHall marked "..displayName)
                table.insert(hallslist.masterList, displayName)
            end
        end
    end
    
    -- update Guild Hall list
    if( hallslist ~= nil ) then
        hallslist:RefreshData()
    end
end

--
function WMGH.DoRescan(guildId)
    dbg("DoRescan - "..guildId)
    local guild = WMGH.GetGuildById(guildId)
    local setting = WMGH.GetSettingsById(guildId)
    WMGH.ScanGuild(guild.ndx, guildId, setting)
    WMGH.DoDisplay(guildId)
end

function WMGH.GetGuildByIndex(ndx)
    local id = GetGuildId(ndx)
    if not id then return nil end
    return WMGH.GetGuildById(id)
end

function WMGH.GetGuildById(id)
    if not id then return nil end
    local g = WMGH.byId[id]
    if not g then return nil end
    local nm = g.name
    if not nm then return nil end
    return WMGH.guilds[nm]
end

-- will not return nil
function WMGH.GetSettingsByIndex(ndx)
    WMGH.saved.guildsettings = WMGH.saved.guildsettings or {}
    if not WMGH.saved.guildsettings[ndx] then 
        WMGH.saved.guildsettings[ndx] = GuildSetting:New(GetGuildName(GetGuildId(ndx)))
    elseif WMGH.saved.guildsettings[ndx].name=="" then
        WMGH.saved.guildsettings[ndx].name=GetGuildName(GetGuildId(ndx))
    end
    return WMGH.saved.guildsettings[ndx]
end

function WMGH.GetSettingsById(id)
    local guild = WMGH.GetGuildById(id)
    return WMGH.GetSettingsByIndex(guild.ndx)
end

function WMGH.ScanGuild(ndx, guildId, setting)
    dbg("ScanGuild: "..guildId.." ")
	local guild = WMGH.GetGuildById(guildId)
	if( guild == nil ) then 
		guild = GuildEntry:New(guildId)
		--guild:Initialize(guildId)
		WMGH.byId[guildId] = { ["name"]=guild.name, ["ndx"]=ndx }
		WMGH.guilds[guild.name] = guild
	end
	guild:SetSettings(setting)
	
    local gm = ""
    local ghlhalls = {}
    local sghhalls = {}
    
    -- scan for guildmaster owner
    if( setting.GuildMasterOwner == true ) then
        gm = guild.guildMaster
    end

    if( setting.GHL_Compatible == true or setting.GuildHallScan == true  ) then
        -- scan for GHL compatible halls
        if( guild.ghlinit == false ) then
            guild.GHLhalls, guild.ScannedGHalls = getAllMarkerHalls(guildId, guild.numMembers, setting)
            guild.ghlinit = true
        end
		if(setting.GHL_Compatible == true) then ghlhalls = guild.GHLhalls end
		if(setting.GuildHallScan == true) then sghhalls = guild.ScannedGHalls end
		sghhalls = guild.ScannedGHalls
    end
    return gm, ghlhalls, sghhalls
end

-------------------------------------------------------------


function WMGH.ScanGuildForHalls()
    local current_guild = GRM:GetGuildId()
    WMGH.DoDisplay(current_guild)
    return true    -- need to do this for ZO_PreHook
end

--[[
   checks to see if a member has a guild hall marker in note
   (GHL compatibility)
   --]]
function WMGH.ScanGuildNote(marker, halls, displayName, note)
    if(displayName == nil or displayName == "") then return halls end
	if( halls == nil ) then halls = {} end
    
    if(note == nil or note == nil or marker == nil) then
		halls[displayName] = nil
    elseif( string.find(note, marker) ) then
        dbg("Found not for "..marker.." in guild "..GRM:GetGuildId().." for "..displayName)
        halls[displayName] = true
    else
        halls[displayName] = nil
    end
    return halls
end

-------------------------------------------------------------
function GuildHallList:New( control )
    ZO_SortFilterList.InitializeSortFilterList(self, control)
    self.masterList = {}
    ZO_ScrollList_AddDataType(self.list, GUILDHALL_DATA, 
        "WheresMyGuildHallContainerRowTemplate", 30, 
        function(control, data) self:SetupRow(control, data) end);
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight");
    
    self:SetEmptyText(GetString(WMGH_NONE))
    self.emptyRow:GetNamedChild("BG"):SetHidden(true)
    return self
end

function GuildHallList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {name = data}))
	end
end

function GuildHallList:SetupRow( control, data )
    control.data = data
    
    control:SetText(data.name)
    control:GetNamedChild("Button"):SetHandler("OnMouseUp", 
        function(control, button, isInside, ctrl, alt, shift, command)
            if(isInside == true and button == MOUSE_BUTTON_INDEX_LEFT) then
                if(data.name == playerName) then
                    RequestJumpToHouse(GetHousingPrimaryHouse())
                else
                    JumpToHouse(data.name)
                end
            end
        end)
    ZO_SortFilterList.SetupRow(self, control, data)
end

local function BuildUI()
    local GUILD_HALL_DATA = 1
    local playerName = WMGH.playerName
    container = WheresMyGuildHallContainer
    container:SetParent(ZO_GuildHome)
    
    hallslist = GuildHallList:New(container)
     
    ZO_PreHook(GRM, "OnGuildIdChanged", WMGH.ScanGuildForHalls)
end

function WMGH.slashHelp()
	if chatter == nil then return end
    local cmdtable = {
        {"/wmgh", "Print this help message"},
        {"/wmgh rescan", "Rescan your guilds for guild halls"},
        {"/wmgh init", "Reload WMGH"},
        {"/wmgh debug", "Toggle debug messages for WMGH"},
    }
    local title = "Where's My Guild Hall commands"
    chatter:slashHelp(title, cmdtable)
end

local function slashToggleDebug()
	if chatter == nil then return end
	-- have a local debugmode variable instead of just using chatter:toggleDebug()
	-- (the addonChatter keeps track of its own state without outside assistance)
	-- just so that I can print to chat that I am enabling or disabling debug mode.
	if( debugmode == false ) then
		debugmode = true
		chatter:enableDebug()
		chatter:systemMessage("Enabling debug")

	else
		chatter:systemMessage("Disabling debug")
		debugmode = false
		chatter:disableDebug()
	end
end

--[[ 
    If we have a list of GHLmembers already loaded for the guild, 
    see if we need to update it with this change.
    If it is the current guild, refresh the display.
]]
local function onGuildMemberNoteChanged(ev, guildId, memberName, note)
    local mysettings = WMGH.saved.guildsettings[guildId]
	if( mysettings == nil ) then return end
    if( mysettings.GHL_Compatible == false and mysettings.GuildHallScan == false ) then return end
    if not note or note == "" then return end

    local guild = WMGH.GetGuildById(guildId) 
    if guild then
        if mysettings.GHL_Compatible == true then
            WMGH.ScanGuildNote(GHL_MARKER, guild.GHLhalls, memberName, note)
        end
        if mysettings.GuildHallScan == true then
            WMGH.ScanGuildNote(SCANGH_MARKER, guild.ScannedGHalls, memberName, note)
        end
    end
    WMGH.DoDisplay(guildId)
end

--[[ 
    If we have the guildmaster already loaded for the guild, 
    see if we need to update it with this change.
    If it is the current guild, refresh the display.
]]
local function onGuildMemberRankChanged(ev, guildId, memberName, rankIndex)
    if( not guildId ) then return end
    local mysettings = WMGH.saved.guildsettings[guildId]
    if not mysettings  then return end
    if mysettings.GuildMasterOwner == false  then return end

	if( WMGH.saved.guildsettings == nil ) then
		WMGH.saved.guildsettings = {}
	end
    
    local guild = WMGH.GetGuildById(guildId)
    if guild then
        guild.numMembers, _, guild.guildMaster = GetGuildInfo(guildId)
    end

    WMGH.DoDisplay(guildId)
end

--[[ 
    If we have either the guildmaster or the GHLlist loaded
    for this guild already then see if one of them is the one
    being removed.
    If it is the current guild, refresh the display.
]]
local function onGuildMemberRemoved(ev, guildId, memberName, charName)
    local mysettings = WMGH.saved.guildsettings[guildId]
    if not mysettings then return end
    if not (mysettings.GHL_Compatible or mysettings.GuildHallScan or mysettings.GuildMasterOwner) then return end
	
    local guild = WMGH.GetGuildById(guildId)
    if guild then
        if( guild.guildMaster == memberName ) then
            guild.numMembers, _, guild.guildMaster = GetGuildInfo(guildId)
        elseif (guild.ghlinit == true) then
            if( guild.GHLhalls[memberName] ~= nil) then
                guild.GHLhalls[memberName] = nil
            end
            if( guild.ScannedGHalls[memberName] ~= nil) then
                guild.ScannedGHalls[memberName] = nil
            end
        end
    end
    WMGH.DoDisplay(guildId)
end

local function onGuildJoined(ev, guildId, guildName)
end

local function onGuildLeft(ev, guildId, guildName)
end

--[[ load saved variables, initialize stuff ]]
local function onLoaded(ev, addon)
    if(addon ~= WMGH.name) then return end
    EVENT_MANAGER:UnregisterForEvent(WMGH.name, EVENT_ADD_ON_LOADED)
   
    WMGH.playerName = GetDisplayName()
    WMGH.saved = SF.getAcctSavedVars("WheresMyGuildHallVars", 1, Default)
end

local function onPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(WMGH.name, EVENT_PLAYER_ACTIVATED)
	for k,v in pairs(WMGH.saved.guildsettings) do
		GuildSetting.UpdateSaved(v)
	end
	
    -- load up the guilds and initialize settings for new ones
    loadActiveGuilds()
   
    WMGH.RegisterSettings(WMGH.numGuilds, WMGH.guilds)
    BuildUI()
	
	if( WMGH.numGuilds > 0 ) then
    for i=1,WMGH.numGuilds do
      local gid = GetGuildId(i)
		  WMGH.DoRescan(gid)
		  WMGH.DoDisplay(gid)
    end
	end
end

SF.LoadLanguage(WMGH_localization_strings, "en")

EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_ADD_ON_LOADED, onLoaded)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, onGuildMemberNoteChanged)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_GUILD_MEMBER_RANK_CHANGED, onGuildMemberRankChanged)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_GUILD_MEMBER_REMOVED, onGuildMemberRemoved)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_GUILD_SELF_JOINED_GUILD, onGuildJoined)
EVENT_MANAGER:RegisterForEvent(WMGH.name, EVENT_GUILD_SELF_LEFT_GUILD, onGuildLeft)


--[[
    Slash Commands
]]

local function showCurrent()
    local id = GRM:GetGuildId()
    local nm = GRM:GetGuildName()
    local guild = WMGH.GetGuildById(id)
    dbg("id="..id..", name="..nm)
    dbg("gid="..guild.id..", ndx="..guild.ndx..", gname="..guild.name..", gmaster="..guild.guildMaster)
end

SLASH_COMMANDS["/wmgh"] = function(...)
	local nargs = select('#',...)
	if( nargs == 0 ) then
		WMGH.slashHelp()
	else
		i = 1
		local v = select(i,...)
        local t = type(v)
        if(v == nil or v == "") then
			WMGH.slashHelp()
		elseif(t == "table") then
			chatter:debugMsg("Invalid argument for /wmgh")
		else
			local s = tostring(v)
			if( s == "debug" ) then
				slashToggleDebug()
			elseif( s == "init" ) then
				loadActiveGuilds()
			elseif( s == "rescan" ) then
				WMGH.ScanGuildForHalls()
			elseif( s == "getActive") then
                -- only useful when debug is enabled
				getActiveGuilds()
			elseif( s == "showCurrent") then
                -- only useful when debug is enabled
				showCurrent()
			end
		end
	end
end