--[[
MasterThief - Helper Functions Module
Utility functions for messaging, UI management, and system settings
--]]

----------------------------------------
-- Initialize Module Table
----------------------------------------
if not MasterThief then
	MasterThief = {}
end

-- Local references for performance
local MT = MasterThief

-- Module-level state for message handling
local _EventList = {}

----------------------------------------
-- String Manipulation Helpers
----------------------------------------
function MT:trim(s)
	-- Remove leading and trailing whitespace
	return s:match("^%s*(.-)%s*$")
end

function MT:FixLinkName(sString)
	-- Clean up item link names for display
	-- Extract just the item name from the link
	-- Item links format: |H1:item:...|h[Item Name]|h|r
	
	-- Extract text between |h[ and ]|h
	local itemName = sString:match("|h%[(.-)%]|h")
	if itemName then
		return itemName
	end
	
	-- Fallback: strip all formatting codes
	local sResult = sString:gsub("|c%x%x%x%x%x%x", "")  -- Color codes
	sResult = sResult:gsub("|H.-|h", "")
	sResult = sResult:gsub("|h", "")
	sResult = sResult:gsub("|r", "")
	return sResult
end

----------------------------------------
-- Session Knowledge Cache
----------------------------------------
function MT:ClearSessionKnowledgeCache()
	-- Clear the cache of recipe/furnishing knowledge checks this session
	-- Used to reduce repeated API calls for the same items
	if not MT.SessionKnowledgeCache then
		MT.SessionKnowledgeCache = {}
	end
	
	MT.SessionKnowledgeCache = {}
end

----------------------------------------
-- Message Display System
----------------------------------------
function MT:ShowMessage(sText, ChatOrBox)
	-- Display messages either in chat, on-screen, or both
	-- ChatOrBox: 0 = special (on-screen and/or chat), 1 = chat only, 2 = on-screen only
	
	local delay = MT.SavedVarsOptions.MessageBoxDelay
	
	if ChatOrBox == 0 then
		-- Special messages (recipes, motifs, etc.)
		if MT.SavedVarsOptions.SpecialOnScreenMsg then
			ctlMasterThiefLabel:SetText(sText)
			MT:ShowMsgBox(true)
			zo_callLater(function() MT:ShowMsgBox(false) end, delay)
		end
	elseif ChatOrBox == 1 then
		-- Chat only
		if MT.SavedVarsOptions.SpecialChatMsg then
			d(sText)
		end
	elseif ChatOrBox == 2 then
		-- On-screen only
		if MT.SavedVarsOptions.SpecialOnScreenMsg then
			MT:MessageHandler(sText, delay)
		end
	end
end

function MT:ShowMsgBox(bValue)
	-- Show or hide the on-screen message box
	if ctlMasterThief then
		ctlMasterThief:SetHidden(not bValue)
	end
end

function MT:IsMsgBoxHidden()
	-- Check if message box is currently hidden
	if ctlMasterThief then
		return ctlMasterThief:IsHidden()
	end
	return true
end

----------------------------------------
-- Message Queue Handler
----------------------------------------
function MT:MessageHandler(sMessage, _duration)
	-- Add message to queue and start display timer
	table.insert(_EventList, {
		sMessage = sMessage,
		iDuration = _duration or MT.SavedVarsOptions.MessageBoxDelay,
		iTimeStamp = GetGameTimeMilliseconds()
	})
	
	if #_EventList == 1 then
		-- First message, start the display cycle
		MT.ThrowMessage()
	end
end

function MT.ThrowMessage()
	-- Display next message from queue
	if #_EventList == 0 then return end
	
	local event = _EventList[1]
	
	if ctlMasterThiefLabel and ctlMasterThief then
		ctlMasterThief:SetHidden(false)
		ctlMasterThiefLabel:SetText(event.sMessage)
		
		-- Schedule next message or hide
		zo_callLater(function()
			table.remove(_EventList, 1)
			
			if #_EventList > 0 then
				MT.ThrowMessage()
			else
				ctlMasterThief:SetHidden(true)
			end
		end, event.iDuration)
	end
end

function MT.CheckForEvents()
	-- Legacy function - check if messages are pending
	-- Returns true if message box should be visible
	if #_EventList > 0 then
		local currentTime = GetGameTimeMilliseconds()
		local event = _EventList[1]
		
		-- Check if current message should still be shown
		local elapsed = currentTime - event.iTimeStamp
		if elapsed < event.iDuration then
			return true
		end
	end
	
	return false
end

function MT:StopAllHandledEvents()
	-- Clear all pending messages
	_EventList = {}
	
	if ctlMasterThief then
		ctlMasterThief:SetHidden(true)
	end
end

----------------------------------------
-- Window Position Management
----------------------------------------
function MT.WinMoveStop()
	-- Called when message box is moved - save position
	if not ctlMasterThief then return end
	
	local _, point, _, relativePoint, offsetX, offsetY = ctlMasterThief:GetAnchor(0)
	
	if MT.SavedVarsOptions then
		MT.SavedVarsOptions.left = offsetX
		MT.SavedVarsOptions.top = offsetY
	end
end

function MT:RestorePosition()
	-- Restore message box to saved position
	if not ctlMasterThief then return end
	
	local left = MT.SavedVarsOptions.left or 50
	local top = MT.SavedVarsOptions.top or 50
	
	ctlMasterThief:ClearAnchors()
	ctlMasterThief:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

----------------------------------------
-- Character Management (Recipe Comparison)
----------------------------------------
function MT:AddOrRemovePlayerchar(nPos, bAdd)
	-- Add or remove character from recipe comparison list
	-- Used for cross-character recipe knowledge tracking
	
	if not MT.AccountSavedVariables.KnownRecipes then
		MT.AccountSavedVariables.KnownRecipes = {}
	end
	
	if bAdd then
		-- Add current character's recipes
		local playerName = GetUnitName("player")
		-- Implementation depends on recipe API
	else
		-- Remove character from comparison
		if nPos and MT.AccountSavedVariables.KnownRecipes[nPos] then
			table.remove(MT.AccountSavedVariables.KnownRecipes, nPos)
		end
	end
end

----------------------------------------
-- System Settings Management
----------------------------------------
function MT:ToggleSystemAttackInnocents()
	-- Toggle game's "Attack Innocent NPCs" setting
	local currentSetting = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
	
	if currentSetting == "0" then
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "1")
		d("[MasterThief] Prevent attacking innocents: ON")
	else
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, "0")
		d("[MasterThief] Prevent attacking innocents: OFF")
	end
end

function MT:ChangeSystemSettings()
	-- Save and modify game's auto-loot stolen items setting
	-- MasterThief takes over this functionality
	
	local currentSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	
	-- Save original setting
	if MT.SavedVarsOptions.SYSTEM_AutolootStolenItems == "" then
		MT.SavedVarsOptions.SYSTEM_AutolootStolenItems = currentSetting
	end
	
	-- Disable game's auto-loot stolen to let MasterThief handle it
	if currentSetting ~= "0" then
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, "0")
	end
end

----------------------------------------
-- Module Initialization
----------------------------------------
-- This module is ready when MasterThief is initialized
-- No separate initialization needed