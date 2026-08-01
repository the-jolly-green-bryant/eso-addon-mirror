-------------------------------------------------------------------------------
-- RP Target Frame
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------

RPTFrame = {}
RPTFrame.Name = "RPTargetFrame"
RPTFrame.Author = "Phinix"
RPTFrame.Version = "1.05"

local AccountDefaults = {RPTF = true, RPI = true, RPT = false, RPN = true}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hooks to hide @accountname in various locations.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RPTargetFrame()

	-- Hide the @accountname in the target frame context.
	if (not RPTFrame.ASV.RPT) then
		if (RPTFrame.ASV.RPTF) then
			local GetSecondary = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag
				ZO_GetSecondaryPlayerNameWithTitleFromUnitTag = function(unitTag)
				if not IsUnitPlayer(unitTag) then
					return zo_strformat(GetUnitTitle(unitTag))
				else
					GetSecondary(unitTag)
				end
			end
		end
	else
		-- Also hide the target's title.
		local GetSecondary = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag
			ZO_GetSecondaryPlayerNameWithTitleFromUnitTag = function(unitTag)
			if not IsUnitPlayer(unitTag) then
				return
			else
				GetSecondary(unitTag)
			end
		end
	end

	-- Hide the @accountname in the player interaction context.
	if (RPTFrame.ASV.RPI) then
		ZO_GetPrimaryPlayerNameWithSecondary = function(displayName, characterName)
			return zo_strformat(characterName)
		end
	end

	-- Remove the player head icon from the target character name.
	if (RPTFrame.ASV.RPN) then
		ZO_FormatUserFacingCharacterName = function(name) return name end
	end

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= "panel",
		name					= "RP Target Frame",
		displayName				= "RP Target Frame",
		author					= RPTFrame.Author,
		version					= RPTFrame.Version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	{
		type			= "description",
		text			= "Options to hide various UI informations."
	},
	{
		type			= "checkbox",
		name			= "Hide Target @Accountname",
		tooltip			= "Hide the @accountname in the target frame context.",
		getFunc			= function() return RPTFrame.ASV.RPTF end,
		setFunc			= function(value) RPTFrame.ASV.RPTF = value ReloadUI() end,
		warning			= "Will automatically reload the UI.",
		default			= AccountDefaults.RPTF
	},
	{
		type			= 'checkbox',
		name			= "Hide Target Title",
		tooltip			= "Also hide the target's title.",
		getFunc			= function() return RPTFrame.ASV.RPT end,
		setFunc			= function(value) RPTFrame.ASV.RPT = value ReloadUI() end,
		warning			= "Will automatically reload the UI.",
		default			= AccountDefaults.RPT,
		disabled		= function() return not RPTFrame.ASV.RPTF end
	},
	{
		type			= "checkbox",
		name			= "Hide Interact @Accountname",
		tooltip			= "Hide the @accountname in the player interaction context.",
		getFunc			= function() return RPTFrame.ASV.RPI end,
		setFunc			= function(value) RPTFrame.ASV.RPI = value ReloadUI() end,
		warning			= "Will automatically reload the UI.",
		default			= AccountDefaults.RPI
	},
	{
		type			= "checkbox",
		name			= "Hide Player Icon",
		tooltip			= "Remove the player head icon from the target character name.",
		getFunc			= function() return RPTFrame.ASV.RPN end,
		setFunc			= function(value) RPTFrame.ASV.RPN = value ReloadUI() end,
		warning			= "Will automatically reload the UI.",
		default			= AccountDefaults.RPN
	}
	}

	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("RPTFrame_Panel", panelData)
	LAM:RegisterOptionControls("RPTFrame_Panel", optionsData)
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= RPTFrame.Name then return end
	EVENT_MANAGER:UnregisterForEvent(RPTFrame.Name, EVENT_ADD_ON_LOADED)
	RPTFrame.ASV = ZO_SavedVars:NewAccountWide(RPTFrame.Name, 1.0, 'AccountSettings', AccountDefaults)
	CreateSettingsWindow(addonName)
	RPTargetFrame()
end

EVENT_MANAGER:RegisterForEvent(RPTFrame.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
