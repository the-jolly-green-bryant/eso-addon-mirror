---------------------------------------------------------
--	ARKadium's Extended Guild Notes Core file  		    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 


--[[ TODO list


]]--


---------------------------------------------------------
--	LOCALS & DEFAULTS		   	   					   --
--------------------------------------------------------- 

ARK_EGN       			= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.UI					= EGN.UI or {}

EGN.addonName        	= "ARK_EGN"
EGN.addonVersion    	= "1.4"

EGN.author 				= "Carter_DC"
EGN.savedVarsVersion 	= 2
EGN.guildName 		 	= "ARKADIUM"
EGN.guildWebSite 		= "http://www.arkadium.fr"

EGN.bInitialized			= false



EGN.defaults  = {-- default settings for saved variables
    --general
	bUseDebugMode 		= false,
	bEnableStartMessage = true,
	--permissions
	bIsARK				= false,
	bIsTester			= false,
	--modules
	bEnableTestage		= false,
	bEnableNotes		= true,
	bEnableCombatState  = false,
	bEnableGuildHouse	= true,
	bEnableChat		   	= true,
	
	mainTextColor		={
		r 				= 0.8, --204
		g 				= 0.13, --33
		b 				= 0.153, --39
		a 				= 1, --255
		hex 			= "CC2127",
	},	
}

--saved variables
EGN.sVars={}

-- colors
local BLUE, RED, WHITE, GREEN = 1, 2, 3, 4


---------------------------------------------------------
--	EVENT HANDLERS			   	   					   --
--------------------------------------------------------- 

function EGN.OnAddOnLoaded( eventCode, name ) --EVENT_ADD_ON_LOADED

	if name ~= EGN.addonName then return end
	EVENT_MANAGER:UnregisterForEvent( EGN.addonName, EVENT_ADD_ON_LOADED )
	
	--loads saved variables from file or default
	EGN.sVars = ZO_SavedVars:NewAccountWide( "ARK_EGN_SavedVariables", EGN.savedVarsVersion, "Main", EGN.defaults )
	
	--key bindings (essayer de caser après les perm)
	if EGN.sVars.bEnableTestage then
		ZO_CreateStringId( "SI_BINDING_NAME_ARK_EGN_TEST", "Testage" )	
		ZO_CreateStringId( "SI_BINDING_NAME_ARK_EGN_CPS_EXPORT", "Exporter CPs")
	end
	if EGN.sVars.bEnableCombatState then
		ZO_CreateStringId( "SI_BINDING_NAME_ARK_EGN_TOGGLECSUI", "Toggle CombatState UI" )	
	end	
	
	ZO_CreateStringId( "SI_BINDING_NAME_ARK_EGN_RELOADUI", "Reload UI" )	
	
	--initialize, only, once the player is activated
	EVENT_MANAGER:RegisterForEvent( EGN.addonName, EVENT_PLAYER_ACTIVATED , EGN.Initialize )

end

--redo the guild list if player joins or leaves a guild.
function EGN.OnPlayerJoindedGuild ( eventCode, guildId, guildName)
	EGN.CheckPermissions()
end

function EGN.OnPlayerLeftGuild( eventCode, guildId, guildName)
	EGN.CheckPermissions()
end


---------------------------------------------------------
--	CORE FUNCTIONS			   	   					   --
--------------------------------------------------------- 


--called once, the first time the player finsishes loading an area 
function EGN.Initialize() --EVENT_PLAYER_ACTIVATED
	
	--unregister player activated
	EVENT_MANAGER:UnregisterForEvent( EGN.addonName, EVENT_PLAYER_ACTIVATED )
	
	--permissions
	if ( not EGN.CheckPermissions() ) then return end --player doesn't have the permission to use the addon
	
	-- start message
	EGN.StartMessage()
	
	-- Modules
	if EGN.sVars.bEnableTestage then ARK_EGN.Testage:Initialize() end
	if EGN.sVars.bEnableNotes then ARK_EGN.Notes:Initialize() end
	if EGN.sVars.bEnableGuildHouse then ARK_EGN.GuildHouse:Initialize() end
	if EGN.sVars.bEnableChat then ARK_EGN.Chat:Initialize() end
	if EGN.sVars.bEnableCombatState then ARK_EGN.CombatState:Initialize() end
	
	-- Settings
	EGN.CreateSettingsMenu()
	
	-- Init UI
	--EGN.InitUI()
	
	--register events
	EVENT_MANAGER:RegisterForEvent(EGN.addonName, EVENT_GUILD_SELF_JOINED_GUILD , EGN.OnPlayerJoindedGuild )
	EVENT_MANAGER:RegisterForEvent(EGN.addonName, EVENT_GUILD_SELF_LEFT_GUILD , EGN.OnPlayerLeftGuild )
	
	EGN.bInitialized = true
end


---------------------------------------------------------
--	Utils					   	   					   --
---------------------------------------------------------  

function EGN.SetToolTip(ctrl, text)
	ctrl:SetHandler("OnMouseEnter", function(self)
		ZO_Tooltips_ShowTextTooltip(self, TOP, text)
	end)
	ctrl:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
	end)
end
	
function EGN.ReloadUI()
	ReloadUI()
end

--PostHook : object table is optionnal _G will be used by default
function EGN.PostHook(existingFunctionName, postHookFunction, objectTable)
	
	if objectTable then
		local originalFunction = _G[objectTable][existingFunctionName]
		_G[objectTable][existingFunctionName] = function(...)
			originalFunction(...)
			postHookFunction()
		end		
	else
		local originalFunction = _G[existingFunctionName]
		_G[existingFunctionName] = function(...)
			originalFunction(...)
			postHookFunction()
		end	
	end
end

--round to nearest
function EGN.Round( val, decimal )
	if ( decimal ) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

function EGN.PopulateGuildList()
		
	EGN.guildList = {}
	local guildName = ""
	
	for guildId = 1, GetNumGuilds() do
		guildName = GetGuildName(guildId)
		if guildName ~= "" then 
			EGN.guildList[string.upper(guildName)] = guildId   
		end
    end 
end

function EGN.CheckPermissions()
		
	EGN.PopulateGuildList()
	local permissionGranted = true
		
	for guildName, guildId in pairs (EGN.guildList) do
		
		if guildName == EGN.guildName then 
			EGN.sVars.bIsARK	= true
			EGN.sVars.bIsTester = true
		end	
	end

	--todo : set permissionGranted to false under some circumstances
	return permissionGranted
	
end

function EGN.StartMessage()
	EGN.displayName = EGN.Colorize( "ARKadium" )..EGN.Colorize( "'s Extended Guild Notes.", WHITE )
	
	if EGN.sVars.bEnableStartMessage then 
		zo_callLater(function() EGN.Msg2Chat(EGN.displayName..EGN.Colorize( " v "..EGN.addonVersion, WHITE )) end, 2000)
		zo_callLater(function() EGN.Debug( EGN.sVars.bUseDebugMode, "Debug Mode" ) end, 2500)
	end
end

function EGN.Colorize( stringToColorize, color )
	
	if ( color ~= nil and color ~="" ) then 
		if color == BLUE then
			return "|c2020F0"..stringToColorize.."|r"
		elseif color == WHITE then
			return "|cF0F0F0"..stringToColorize.."|r"
		elseif color == RED then
			return "|cF02020"..stringToColorize.."|r"
		elseif color == GREEN then
			return "|c20F020"..stringToColorize.."|r"
		end		
	else
		return "|c"..EGN.sVars.mainTextColor.hex..""..stringToColorize.."|r"	
	end
	
end
	
function EGN.Debug( paramToDump, paramName )

	if EGN.sVars.bUseDebugMode then
		
		if ( paramToDump == nil ) then
			paramToDump = EGN.Colorize( "Null value", RED ) 
		elseif ( paramToDump == "" ) then
			paramToDump = EGN.Colorize( "Empty string", RED ) 
		elseif ( paramToDump == true ) then 
			paramToDump = EGN.Colorize( "True", BLUE )
		elseif ( paramToDump == false ) then
			paramToDump = EGN.Colorize( "False", BLUE )
		else
			paramToDump = EGN.Colorize( paramToDump, WHITE ) 
		end
	
		if ( paramName == nil ) or ( paramName == "" ) then 
			paramName = EGN.Colorize( "Debug out", WHITE ) 
		elseif ( string.find("Function, Event, Override, Permission, PreHook, Binding, Slash, Module Loaded", paramName ) ) then 
			paramName = EGN.Colorize( paramName, BLUE )
		else
			paramName = EGN.Colorize( paramName, WHITE )
		end

		EGN.Msg2Chat( paramName.." : "..paramToDump )
	end
end

function EGN.Msg2Chat( stringToDisplay )
	d( stringToDisplay )
end

function EGN.GetMainTextColor()
	return EGN.sVars.mainTextColor.r, EGN.sVars.mainTextColor.g, EGN.sVars.mainTextColor.b, EGN.sVars.mainTextColor.a
end

function EGN.SetMainTextColor(r, g, b, a)
	EGN.sVars.mainTextColor.r = r
	EGN.sVars.mainTextColor.g = g 
	EGN.sVars.mainTextColor.b = b 
	EGN.sVars.mainTextColor.a = a 
	EGN.sVars.mainTextColor.hex = EGN.RGBAToHex(r, g, b)
end

function EGN.RGBAToHex(r, g, b, a)
  if r>1 then r=1 end
  if g>1 then g=1 end
  if b>1 then b=1 end
  
  r = r <= 1 and r >= 0 and r or 0
  g = g <= 1 and g >= 0 and g or 0
  b = b <= 1 and b >= 0 and b or 0
  if a ~= nil then
	  return string.format("%02x%02x%02x%02x", EGN.Round(r * 255), EGN.Round(g * 255), EGN.Round(b * 255), EGN.Round(a * 255))
	else
		return string.format("%02x%02x%02x", EGN.Round(r * 255), EGN.Round(g * 255), EGN.Round(b * 255))
	end
end

function EGN.HexToRGBA( hex )
	local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

--returns wether parameter is an odd number or not (even)
function EGN.IsOdd(iNumber)
	_, oddPart = math.modf(iNumber/2)
	if oddPart ~= 0 then return true end -- oddpart should be 0.5 if iNumber is odd
	return false
end
---------------------------------------------------------
--	slash 					   	   					   --
--------------------------------------------------------- 

--SLASH_COMMANDS["/egn_testage"] = ARK_EGN.Test
--
--SLASH_COMMANDS["/ark_death_counter"] = EGN.DisplayDeathCounter
--SLASH_COMMANDS["/ark_roster_dump"] = EGN.Dump




EVENT_MANAGER:RegisterForEvent(EGN.addonName, EVENT_ADD_ON_LOADED, EGN.OnAddOnLoaded)
