--  BattlegroundHudMover


--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
BattlegroundHudMover = {}
BattlegroundHudMover.name = "BattlegroundHudMover"
BattlegroundHudMover.slashCommand = "/bhm"
BattlegroundHudMover.debug = false

--------------------------------------------------
-- Default saved variable settings
--------------------------------------------------
BattlegroundHudMover.defaults = {
	left = 500,
	top = 500,
	moveWindow = false
}


--------------------------------------------------
-- Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function BattlegroundHudMover.Initialize()
	BattlegroundHudMover.savedVariables = ZO_SavedVars:NewAccountWide("BattlegroundHudMoverSavedVariables", 1, nil, BattlegroundHudMover.defaults)
	BattlegroundHudMover.RestoreLocation()
	--------------------------------------------------
	-- Set the handler for when the battleground hud is moved
	--------------------------------------------------
	BATTLEGROUND_HUD_FRAGMENT.control:SetHandler("OnMoveStop", function ()
-- d("OnMoveStop")
		BattlegroundHudMover.savedVariables.left = BATTLEGROUND_HUD_FRAGMENT.control:GetLeft()
		BattlegroundHudMover.savedVariables.top = BATTLEGROUND_HUD_FRAGMENT.control:GetTop()
-- d("Left: "..BattlegroundHudMover.savedVariables.left.."  Top: "..BattlegroundHudMover.savedVariables.top)
	end)
end


--------------------------------------------------
-- Restore the battleground hud location and lock state from the savedVariables
--------------------------------------------------
function BattlegroundHudMover.RestoreLocation()
	local left = BattlegroundHudMover.savedVariables.left
	local top = BattlegroundHudMover.savedVariables.top
	local lock = BattlegroundHudMover.savedVariables.moveWindow
	
	BATTLEGROUND_HUD_FRAGMENT.control:SetMouseEnabled(lock)
	BATTLEGROUND_HUD_FRAGMENT.control:SetMovable(lock)
	BATTLEGROUND_HUD_FRAGMENT.control:ClearAnchors()
	BATTLEGROUND_HUD_FRAGMENT.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end


--------------------------------------------------
-- Called when the movement menu setting is changed
--------------------------------------------------
function BattlegroundHudMover.MoveOptionSet(value)
	-- value is a true / false that is passed from LibAddonMenu2
	BattlegroundHudMover.savedVariables.moveWindow = value
	BATTLEGROUND_HUD_FRAGMENT.control:SetMouseEnabled(value)
	BATTLEGROUND_HUD_FRAGMENT.control:SetMovable(value)	
end


--------------------------------------------------
-- SlashCommand Debug - various debug and development information triggered by the slash command
--------------------------------------------------
function BattlegroundHudMover.PingDebug()
	d("BattlegroundHudMover")
	local text
	if BattlegroundHudMover.savedVariables.moveWindow == true then text="UNLOCK" else text="LOCK" end
	d("Locked: "..text)
	d("Left: "..BattlegroundHudMover.savedVariables.left.."  Top: "..BattlegroundHudMover.savedVariables.top)
end


-- ***** Main *****


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function BattlegroundHudMover.AddOnLoaded(event, addonName)
	if addonName == BattlegroundHudMover.name then
		if BattlegroundHudMover.debug then SLASH_COMMANDS[BattlegroundHudMover.slashCommand] = BattlegroundHudMover.PingDebug end
		BattlegroundHudMover.Initialize()
		-- Was getting an error message from LAM saying the settings panel was trying to load before the
		-- rest of the addon loaded.  Wrapping it in a function seems to have fixed it.
		BattlegroundHudMover.InitializeSettingsMenu()
		EVENT_MANAGER:UnregisterForEvent(BattlegroundHudMover.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(BattlegroundHudMover.name, EVENT_ADD_ON_LOADED, BattlegroundHudMover.AddOnLoaded)


--------------------------------------------------
-- ***** Settings *****
--------------------------------------------------

--------------------------------------------------
-- Initialize Settings Menu (Uses LibAddonMenu2)
--------------------------------------------------
function BattlegroundHudMover.InitializeSettingsMenu()
	if BattlegroundHudMover.debug then d("Settings Menu") end

	--------------------------------------------------
	-- Initialize LibAddonMenu2 table and variables
	--------------------------------------------------
	local LAM = LibAddonMenu2
	local saveData = BattlegroundHudMover.savedVariables
	local panelName = "BattlegroudHudMoverSettingsPanel"

	--------------------------------------------------
	-- Initialize settings panel info
	--------------------------------------------------		 
	local panelData = {
		type = "panel",
		name = "Battleground Hud Mover",
		displayName = "|c00E600Battleground Hud Mover|r",
		author = "|c787878ShadowMau (@pawprints.shadow)|r",
		registerForRefresh = true
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)

	--------------------------------------------------
	-- Table to specify the options used to provide menu settings
	--------------------------------------------------	
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Move Battleground Scoring Hud:",
			tooltip = "",
			getFunc = function() return BattlegroundHudMover.savedVariables.moveWindow end,
			setFunc = function(value) BattlegroundHudMover.MoveOptionSet(value) end
		}
	}

	LAM:RegisterOptionControls(panelName, optionsData)
end