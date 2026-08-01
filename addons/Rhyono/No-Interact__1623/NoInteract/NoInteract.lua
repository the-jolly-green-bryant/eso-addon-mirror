local NoInteract = {
Name = "NoInteract",
Author = "Rhyono",
Version = "1.35",
SettingsVersion = "1.12"}

NoInteract.Blacklisted = {active=true,list={},verbose=true,container_blacklisted=true}

local function OnAddOnLoaded(event, addonName)
	if addonName == NoInteract.Name then 
		NoInteract:Initialize()
	end
end

--Search the blacklist (mode 0 = boolean, 1 = delete, 2 = chat message)
local function BlacklistSearch(text,crime,mode)
	if text ~= nil then
		if mode == nil then mode = 0 end
		for index,data in pairs(NoInteract.Blacklisted.list) do
			if mode == 2 then
				CHAT_SYSTEM:AddMessage(data.targ .. (data.crime and ' (theft)' or ''))
			elseif data.targ:lower() == text:lower() and data.crime == crime then
				if mode == 1 then
					NoInteract.Blacklisted.list[index] = nil
				end	
				return true
			end	
		end
	end
	return false
end

--Modified reticle hook from No, Thank You!
local function HookReticleTake()
	local function DisableReticleTake_Hook(interactionPossible)
		if interactionPossible and (NoInteract.Blacklisted.active or NoInteract.Blacklisted.container_blacklisted) then
			local _,text,empty,_,addinfo,_,_,crime = GetGameCameraInteractableActionInfo()
			if text ~= '' and text ~= nil then
				if (NoInteract.Blacklisted.active and BlacklistSearch(text,crime)) or (NoInteract.Blacklisted.container_blacklisted and empty and addinfo == 2) then
					return true
				end
			end		
		end
	return false
	end	
	ZO_PreHook(RETICLE, "TryHandlingInteraction", DisableReticleTake_Hook)
end

function NoInteract:Initialize()
	NoInteract.SavedVariables = ZO_SavedVars:NewAccountWide("NoInteractVars", NoInteract.SettingsVersion, nil, NoInteract.Blacklisted)
	NoInteract.Blacklisted.active = NoInteract.SavedVariables.active
	NoInteract.Blacklisted.verbose = NoInteract.SavedVariables.verbose
	NoInteract.Blacklisted.container_blacklisted = NoInteract.SavedVariables.container_blacklisted
	for index,data in pairs(NoInteract.SavedVariables.list) do
		NoInteract.Blacklisted.list[index] = data
	end
	EVENT_MANAGER:UnregisterForEvent(NoInteract.Name, EVENT_ADD_ON_LOADED)
	HookReticleTake()
end

--Show blacklist
local function BlacklistShow()
	CHAT_SYSTEM:AddMessage("Currently blacklisted NPCs:")
	BlacklistSearch('','',2)
	CHAT_SYSTEM:AddMessage("Blacklist completed.")
end

--Toggle if blacklist is active
function NIBlacklistToggle()
	if NoInteract.Blacklisted.active then
		NoInteract.Blacklisted.active = false
		CHAT_SYSTEM:AddMessage("|caf0000Blacklisting has been disabled.|r")
	else
		NoInteract.Blacklisted.active = true
		CHAT_SYSTEM:AddMessage("|c00a000Blacklisting has been enabled.|r")
	end
	NoInteract.SavedVariables.active = NoInteract.Blacklisted.active
end

--Toggle if container blacklisting is active
function NIEmptyContainerToggle()
	if NoInteract.Blacklisted.container_blacklisted then
		NoInteract.Blacklisted.container_blacklisted = false
		CHAT_SYSTEM:AddMessage("|caf0000Empty container hiding has been disabled.|r")
	else
		NoInteract.Blacklisted.active = true
		CHAT_SYSTEM:AddMessage("|c00a000Empty container hiding has been enabled.|r")
	end
	NoInteract.SavedVariables.container_blacklisted = NoInteract.Blacklisted.container_blacklisted
end

--Fixes indices to be rewritable
local function string_indices(tab)
	local temp = {}
	local new_index = 1
	for index,data in pairs(tab) do
		temp[new_index .. ''] = data
		new_index=new_index+1
	end	
	return temp
end

--Fixes messy escape issue
local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
string.quote = function(str)
    return str:gsub(quotepattern, "%%%1")
end

--Add to the blacklist
local function BlacklistNPC(text,crime)
	--If no crime, attempt to check for it
	if crime == nil then 
		crime = false
		if text:find("(theft)") then
			text = text:gsub(text:match("%s-%(theft%)"):quote(),'',1)
			crime = true
		end
	end
	--Check if already on the list
	if not BlacklistSearch(text,crime) then
		table.insert(NoInteract.Blacklisted.list,{['targ']=text,['crime']=crime})
		NoInteract.Blacklisted.list = string_indices(NoInteract.Blacklisted.list)
		NoInteract.SavedVariables.list = NoInteract.Blacklisted.list
		CHAT_SYSTEM:AddMessage("|c00a000" .. text  .. (crime and ' (theft)' or '') .. " has been blacklisted.|r")
	else
		CHAT_SYSTEM:AddMessage("|caf0000Already blacklisted.|r")
	end
end

--Remove from the blacklist
local function UnBlacklistNPC(text,crime)
	--If no crime, attempt to check for it
	if crime == nil then 
		crime = false
		if text:find("(theft)") then
			text = text:gsub(text:match("%s-%(theft%)"):quote(),'',1)
			crime = true
		end
	end
	--Check if already on the list
	if BlacklistSearch(text,crime,1) then
		NoInteract.SavedVariables.list = NoInteract.Blacklisted.list
		CHAT_SYSTEM:AddMessage("|c00a000" .. text .. (crime and ' (theft)' or '') .. " has been removed from the blacklist.|r")
	else
		CHAT_SYSTEM:AddMessage("|caf0000" .. text .. " could not be found on the blacklist.|r")
	end
end

--Checks if an  needs added or removed by keybinding
function NIBlacklisting()
	local _,text,_,_,_,_,_,crime = GetGameCameraInteractableActionInfo()
	if text ~= '' and text ~= nil then
		--Remove them from the blacklist
		if BlacklistSearch(text,crime) then
			UnBlacklistNPC(text,crime)
		-- Or add them	
		else
			BlacklistNPC(text,crime)
		end
	end	
end

-- Toggles whether to announce prevented interaction
local function NIBlacklistVerbose()
	if NoInteract.Blacklisted.verbose then
		NoInteract.Blacklisted.verbose = false
		CHAT_SYSTEM:AddMessage("|caf0000Verbose interactions have been disabled.|r")
	else
		NoInteract.Blacklisted.verbose = true
		CHAT_SYSTEM:AddMessage("|c00a000Verbose interactions have been enabled.|r")
	end
	NoInteract.SavedVariables.verbose = NoInteract.Blacklisted.verbose
end

--Stops interaction
local orgInteract = INTERACTIVE_WHEEL_MANAGER.StartInteraction
INTERACTIVE_WHEEL_MANAGER.StartInteraction = function(...)
	local _,text,_,_,_,_,_,crime = GetGameCameraInteractableActionInfo()
	if NoInteract.Blacklisted.active and BlacklistSearch(text,crime) then
		if NoInteract.Blacklisted.verbose then
			CHAT_SYSTEM:AddMessage("|caf0000Prevented interaction with " .. text ..".|r")
		end
		return true
	else
		return orgInteract(...)
	end
end

--Shows usage
local function NIHelp()
	CHAT_SYSTEM:AddMessage("No Interact Usage")
	--Keybind
	CHAT_SYSTEM:AddMessage("In Controls you can set keybinds for toggling whether the target is blacklisted/blacklisting is active.")
	--No Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/nointeract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Manual blacklisting.")
	CHAT_SYSTEM:AddMessage("Usage: /nointeract npc_name <optional>(theft)")
	CHAT_SYSTEM:AddMessage("Example: /nointeract lorela")
	CHAT_SYSTEM:AddMessage("Example: /nointeract sack (theft)")
	--Yes Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/yesinteract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Manual unblacklisting.")
	CHAT_SYSTEM:AddMessage("Usage: /yesinteract npc_name")
	CHAT_SYSTEM:AddMessage("Example: /yesinteract lorela")	
	--List Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/listinteract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Lists blacklisted NPCs.")
	CHAT_SYSTEM:AddMessage("Usage: /listinteract")
	--Toggle Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/toggleinteract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Toggles whether to stop NPC interactions.")
	CHAT_SYSTEM:AddMessage("Usage: /toggleinteract")
	--Toggle Empty Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/toggleemptyinteract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Toggles whether to hide empty container.")
	CHAT_SYSTEM:AddMessage("Usage: /toggleemptyinteract")	
	--Verbose Interact
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/verboseinteract|r")
	CHAT_SYSTEM:AddMessage("Purpose: Toggles whether to announce stopped NPC interactions.")
	CHAT_SYSTEM:AddMessage("Usage: /verboseinteract")	
end	

SLASH_COMMANDS["/nointeract"] = BlacklistNPC
SLASH_COMMANDS["/yesinteract"] = UnBlacklistNPC
SLASH_COMMANDS["/listinteract"] = BlacklistShow
SLASH_COMMANDS["/toggleinteract"] = NIBlacklistToggle
SLASH_COMMANDS["/verboseinteract"] = NIBlacklistVerbose
SLASH_COMMANDS["/toggleemptyinteract"] = NIEmptyContainerToggle
SLASH_COMMANDS["/nihelp"] = NIHelp

--Register keybinding
ZO_CreateStringId("SI_BINDING_NAME_BLACKLIST_TARGET", "Blacklist Target")
ZO_CreateStringId("SI_BINDING_NAME_BLACKLIST_TOGGLE", "Blacklist Toggle")
ZO_CreateStringId("SI_BINDING_NAME_EMPTY_TOGGLE", "Empty Toggle")

EVENT_MANAGER:RegisterForEvent(NoInteract.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)