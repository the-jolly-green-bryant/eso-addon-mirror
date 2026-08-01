BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

BSCAS.Name = "BSCs-AdvancedSynergy"
BSCAS.Version = 2
BSCAS.SavedVar = "BSCASSaved"
BSCAS.InitWW = false

-----------------------------------------------------------------------------
-- Dialog functions for Update
------------------------------------------------------------------------------
local function ShowDialogUpdate()
	ZO_Dialogs_ShowPlatformDialog("BSC_ADVANCED_SYNERGY_UPDATE_CONFIRM", nil) --/script ZO_Dialogs_ShowPlatformDialog("BSC_ADVANCED_SYNERGY_UPDATE_CONFIRM", nil)
end
local function InitDialog()
    local customControl = BSCAS_ConfirmationDialog	
    ZO_Dialogs_RegisterCustomDialog("BSC_ADVANCED_SYNERGY_UPDATE_CONFIRM",
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.STATIC_LIST,
        },
        customControl = customControl,
        canQueue = false,
        title =
        {
            text = GetString(SI_SYNERGY_ALERT_UPDATE_TOP),
        },
        mainText =
        {
            text = GetString(SI_SYNERGY_ALERT_UPDATE_INFO),
        },
        setup = function(dialog, data)
			local iconControl = customControl:GetNamedChild("Skill"):SetHidden(true)
        end,
        buttons =
        {
            {
                control = customControl:GetNamedChild("Confirm"),
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)	
					SLASH_COMMANDS["/bscas"]()
                end,
            },
            {
                control = customControl:GetNamedChild("Cancel"),
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)	
					
                end,
            },
        }
    })
end
------------------------------------------------------------------------------
function BSCAS.PlaySound(loop, sound)
  loop = math.max(1, math.min(20, tonumber(loop) or 1))
  for _ = 1, loop do PlaySound(sound) end
end
function BSCAS:PrintDebug(FormatedText)
	if BSCAS.bDebugTab then
		BSCAS:PrintToDebugTab(FormatedText)
	else
		d(FormatedText)
	end
end
local function ClearMemory()
	if BSCAS.SV_acc.SHOW_USED_MEMPRY then
		local Gstart = collectgarbage("count")
		collectgarbage("collect")
		local diff = Gstart - collectgarbage("count")
		if diff > 1024 then
			CHAT_ROUTER:AddSystemMessage(zo_strformat("|cb3b6b7 Cleared Memory <<1>> MB", (diff / 1024)))
		end
	else
		collectgarbage("collect")
	end
end
local function SlashCommand(text)
	BSCAS:AddChatTab()
	local ftext = zo_strlower(text)
	if ftext == 'db' then
		BSCAS.BlockDebugMode()
		BSCAS.AlkoshDebugMode()
		BSCAS.MSlayerDebugMode()
		BSCAS.TrackDebugMode()		
	elseif ftext == 'dbb' then
		BSCAS.BlockDebugMode()
	elseif ftext == 'dba' then
		BSCAS.AlkoshDebugMode()
	elseif ftext == 'dbs' then
		BSCAS.MSlayerDebugMode()
	elseif ftext == 'dbt' then
		BSCAS.TrackDebugMode()		
	elseif ftext == 'dbb_clear' then
		BSCAS:PrintDebug("Debug List is now Empty again!")
		BSCAS.SV_acc.DEBUG_LIST = {}
	elseif ftext == 'dbb_print' then
		BSCAS:PrintDebug(" ")
		BSCAS:PrintDebug("-- Print Debug List :")
		for k, v in pairs(BSCAS.SV_acc.DEBUG_LIST) do
			BSCAS:PrintDebug(zo_strformat("Name[<<1>>] Icon[<<2>>]", k, v))
		end
		BSCAS:PrintDebug("-- Done Printing List")
	elseif ftext == 'alkosh' then
		BSCAS.ClalculateAlkosh()
	--elseif ftext == 'test' then
	--	BSCAS:PrintDebug(GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK))
	elseif ftext == 'dbbcheck' then
		BSCAS.CheckInfo()
	elseif ftext == 'remove' then		
		for k, v in ipairs(CHAT_SYSTEM.containers) do
			for i = 1, #v.windows do
				if v:GetTabName(i) == 'DebugChat' then
					 v:RemoveWindow(i,nil)
				end
			end
		end 
	elseif ftext == 'memc' then
		ClearMemory()
	elseif ftext == 'mem' then
		BSCAS.SV_acc.SHOW_USED_MEMPRY = not BSCAS.SV_acc.SHOW_USED_MEMPRY
		ClearMemory()
	else
		BSCAS:PrintDebug("Commands:")
		BSCAS:PrintDebug("/BSCAS db [Enables all debug modes]")
		BSCAS:PrintDebug("/BSCAS dbb [Enables debug Block mode]")
		BSCAS:PrintDebug("/BSCAS dba [Enables debug Alkosh mode]")
		BSCAS:PrintDebug("/BSCAS dbs [Enables debug Slayer mode]")
		BSCAS:PrintDebug("/BSCAS dbt [Enables debug Tracking mode]")
		BSCAS:PrintDebug("/BSCAS dbb_print [Print debug synergies list]")
		BSCAS:PrintDebug("/BSCAS dbb_clear [clears debug synergies list]")
		BSCAS:PrintDebug("/BSCAS mem [on/off show cleared memory]")
		BSCAS:PrintDebug("/BSCAS memc [force to clear unused memory]")
		BSCAS:PrintDebug("/BSCAS dbbcheck [checking names of synergies")
		BSCAS:PrintDebug("/BSCAS remove [removes DebugChat TAB")
	end
end
-- this need to be higer then "VERSION_ALERT"
local VERSION_ALERT = 2
local PLAYER_ACTIVATED = false

local bUnregister_LOADED = false
local function OnPlayerActivated()
	if not bUnregister_LOADED then
		EVENT_MANAGER:UnregisterForEvent(BSCAS.Name, 	EVENT_ADD_ON_LOADED)
		bUnregister_LOADED = true
	end
	ClearMemory()
	if PLAYER_ACTIVATED then return end 
	--
	PLAYER_ACTIVATED = true
		
	CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF<<1>> Now Enabled!.|r", BSCAS.Name))
	--				
	if BSCAS.SV_acc.VERSION_ALERT ~= VERSION_ALERT then
		-- set new version
		BSCAS.SV_acc.VERSION_ALERT = VERSION_ALERT
		-- Open DialogUI
		ShowDialogUpdate()
	end		
	if IsUnitInCombat('player') then
		BSCAS.AlkoshEnable()
	else
		BSCAS.AlkoshDisable()
		BSCAS:CallUpdateAfterCombatTT()
		BSCAS:CallUpdateAfterCombatTG()
	end		
	if LibBSCWizardBridge and BSCAS.InitWW and BSCAS.SV.ADD_WW_PLUGIN then
		BSCAS:registerClient() -- WizardsWardrobe "Plugin"
	end
	BSCASUIAlert:SetHidden(true)	
end

local function OnCombatState(_, inCombat)	
	--local pstatus = zo_strformat("<<1>>[<<2>><<3>><<4>>]", "|cb3b6b7", (inCombat and BSCAS.color_red or BSCAS.color_green), (inCombat and 'Combat' or 'No Combat'), "|cb3b6b7")
	--CHAT_ROUTER:AddSystemMessage(zo_strformat("|cb3b6b7<<1>> <<2>>", "CombatStatus", pstatus))	
	if inCombat then		
		BSCAS.AlkoshEnable()
	else
		BSCAS.AlkoshDisable()
		BSCAS:CallUpdateAfterCombatTT()
		BSCAS:CallUpdateAfterCombatTG()
	end
	BSCAS.AlkoshBuffActive = false
end

function BSCAS.FontCheck(size)
	local new_size = size
	if size > 54 then new_size = 54 end
	if size > 48 and size < 54 then new_size = 48 end
	if size > 40 and size < 48 then new_size = 40 end
	if size > 36 and size < 40 then new_size = 36 end
	if size > 34 and size < 36 then new_size = 34 end
	if size > 32 and size < 34 then new_size = 32 end
	if size > 30 and size < 32 then new_size = 30 end
	if size > 28 and size < 30 then new_size = 28 end
	if size > 26 and size < 28 then new_size = 26 end		
	return new_size
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Alert UI -- //////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCAS.AlertOnMoveStop()
	BSCAS.SV_acc.UIALERT_LEFT = BSCASUIAlert:GetLeft()
	BSCAS.SV_acc.UIALERT_TOP = BSCASUIAlert:GetTop()
end
local function RestorePosition()
	if BSCAS.SV_acc.UIALERT_LEFT == 0 and BSCAS.SV_acc.UIALERT_TOP == 0 then return end
	BSCASUIAlert:SetMovable(true)
	BSCASUIAlert:ClearAnchors()
	BSCASUIAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCAS.SV_acc.UIALERT_LEFT, BSCAS.SV_acc.UIALERT_TOP)
	BSCASUIAlert:SetMovable(false)
end
function BSCAS.ResetUI()
	BSCASUIAlert:SetMovable(true)
	BSCASUIAlert:ClearAnchors()
	BSCASUIAlert:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -165)
	BSCASUIAlert:SetMovable(false)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCAS.init(event, addonName)
	if addonName == "WizardsWardrobe" then -- Check If Wizzard
		BSCAS.InitWW = true
	end
	if addonName ~= BSCAS.Name then
		return 
	end
	-- Get Saved Data
	BSCAS.LoadSavedData()				
	-- Command
	SLASH_COMMANDS['/bscasd'] = SlashCommand	
	-- REWORKED / New
	BSCAS.BlockInit()		-- Block
	BSCAS.AlkoshInit()		-- Alkosh
	BSCAS.TrackInit()		-- Tracking
	BSCAS.MSlayerInit()		-- Mslayer
	BSCAS.GroupTrackInit() 	-- Tracking Group CD
	BSCAS.TargetTrackInit() -- Target Tracking CD
	RestorePosition()		-- Alert UI
	InitDialog()			-- Dialog
	BSCAS:InitPrority()
	BSCAS:InitMenu()
	--
	EVENT_MANAGER:RegisterForEvent(BSCAS.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(BSCAS.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
end
EVENT_MANAGER:RegisterForEvent(BSCAS.Name, EVENT_ADD_ON_LOADED, BSCAS.init)
