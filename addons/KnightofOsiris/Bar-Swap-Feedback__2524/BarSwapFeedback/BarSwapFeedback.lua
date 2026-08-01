------------------------------------------------------------------------
-- Bar Swap Feedback
-- Copyright 2019-2022 KnightofOsiris
------------------------------------------------------------------------
-- Adds animated feedback and an optional sound effect when switching
-- between action bars.
------------------------------------------------------------------------

-- Create global name space.
BarSwapFeedback = {}

-- Save metadata into the name space.
BarSwapFeedback.addonName = "BarSwapFeedback"
BarSwapFeedback.displayName = "Bar Swap Feedback"
BarSwapFeedback.author = "@KnightofOsiris"
BarSwapFeedback.version = "101036.1"
BarSwapFeedback.settingsVersion = "6"

-- Create local saved variables.
local savedVars

-- Get pointers to event, animation and window managers.
local eventManager = GetEventManager()
local animationManager = GetAnimationManager()
local windowManager = GetWindowManager()

-- Create pointer for notification control.
local barSwapNotificationControl

-- Declare default settings.
local defaults = {
	animationStyle = "Pulse (1 Pulse)",
	glyphStyle = "Text: Square 721",
	notificationSide = "Right",
	notificationXOffset = 96,
	notificationYOffset = 0,
	notificationScale = 1,
	feedbackSettings = {
		[0] = {
			notificationColour = {
				r = 1,
				g = 0,
				b = 0
			},
			enableAudioFeedback = false,
			notificationSound = "NEW_NOTIFICATION"
		},
		[1] = {
			notificationColour = {
				r = 0,
				g = 1,
				b = 0
			},
			enableAudioFeedback = false,
			notificationSound = "NEW_NOTIFICATION"
		}
	}
}

-- Glyph options.
local glyphStyles = {
	["Shapes: Arrows (Left & Right)"] = {
		[0] = "BarSwapFeedback/media/ShapesArrows1/bar1.dds",
		[1] = "BarSwapFeedback/media/ShapesArrows1/bar2.dds",
	},
	["Shapes: Arrows (Up & Down)"] = {
		[0] = "BarSwapFeedback/media/ShapesArrows2/bar1.dds",
		[1] = "BarSwapFeedback/media/ShapesArrows2/bar2.dds",
	},
	["Shapes: Bars"] = {
		[0] = "BarSwapFeedback/media/ShapesBars/bar1.dds",
		[1] = "BarSwapFeedback/media/ShapesBars/bar2.dds",
	},
	["Shapes: Circles"] = {
		[0] = "BarSwapFeedback/media/ShapesCircles/bar1.dds",
		[1] = "BarSwapFeedback/media/ShapesCircles/bar2.dds",
	},
	["Shapes: Triangles"] = {
		[0] = "BarSwapFeedback/media/ShapesTriangles/bar1.dds",
		[1] = "BarSwapFeedback/media/ShapesTriangles/bar2.dds",
	},
	["Text: Code Prediators"] = {
		[0] = "BarSwapFeedback/media/TextCodePrediators/bar1.dds",
		[1] = "BarSwapFeedback/media/TextCodePrediators/bar2.dds",
	},
	["Text: Loaded"] = {
		[0] = "BarSwapFeedback/media/TextLoaded/bar1.dds",
		[1] = "BarSwapFeedback/media/TextLoaded/bar2.dds",
	},
	["Text: Ode To Idle Gaming"] = {
		[0] = "BarSwapFeedback/media/TextOdeToIdleGaming/bar1.dds",
		[1] = "BarSwapFeedback/media/TextOdeToIdleGaming/bar2.dds",
	},
	["Text: Square 721"] = {
		[0] = "BarSwapFeedback/media/TextSquare721/bar1.dds",
		[1] = "BarSwapFeedback/media/TextSquare721/bar2.dds",
	},
	["Text: Square Brush"] = {
		[0] = "BarSwapFeedback/media/TextSquareBrush/bar1.dds",
		[1] = "BarSwapFeedback/media/TextSquareBrush/bar2.dds",
	},
	["Text: Square Wise"] = {
		[0] = "BarSwapFeedback/media/TextSquareWise/bar1.dds",
		[1] = "BarSwapFeedback/media/TextSquareWise/bar2.dds",
	},
	["Text: Typo Square"] = {
		[0] = "BarSwapFeedback/media/TextTypoSquare/bar1.dds",
		[1] = "BarSwapFeedback/media/TextTypoSquare/bar2.dds",
	},
	["Text: USPF Liberty"] = {
		[0] = "BarSwapFeedback/media/TextUSPFLiberty/bar1.dds",
		[1] = "BarSwapFeedback/media/TextUSPFLiberty/bar2.dds",
	}
}

-- Get names of all glyph options.
local function GetGlyphOptions()
	local choices = {}

	for key in pairs(glyphStyles) do
		choices[#choices + 1] = key
	end

	return choices
end

-- Anchor options.
local anchorOptions = {
	["Left"] = RIGHT,
	["Centre"] = CENTER,
	["Right"] = LEFT,
}

-- Get names of all anchor options.
local function GetAnchorOptions()
	return {"Left", "Centre", "Right"}
end

-- Table of available sound choices.
local soundOptions = {
	["ACHIEVEMENT_AWARDED"] = "Achievement Awarded",
	["ALCHEMY_CREATE_TOOLTIP_GLOW_FAIL"] = "Alchemy: Create Fail",
	["BATTLEGROUND_MATCH_LOST"] = "Battleground Match Lost",
	["BATTLEGROUND_MATCH_WON"] = "Battleground Match Won",
	["BLACKSMITH_EXTRACTED_BOOSTER"] = "Blacksmith Extract Booster",
	["CHAMPION_PENDING_POINTS_CLEARED"] = "Champion System: Pending Points Cleared",
	["CHAMPION_POINTS_COMMITTED"] = "Champion System: Points Committed",
	["CHAMPION_POINT_GAINED"] = "Champion System: Point Gained",
	["CHAMPION_RESPEC_ACCEPT"] = "Champion System: Respec Accepted",
	["CHAMPION_RESPEC_TOGGLED"] = "Champion System: Respec Toggled",
	["CHAMPION_STAR_LOCKED"] = "Champion System: Star Locked",
	["CHAMPION_STAR_MOUSEOVER"] = "Champion System: Star Mouseover",
	["CHAMPION_STAR_UNLOCKED"] = "Champion System: Star Unlocked",
	["CHAMPION_SYSTEM_UNLOCKED"] = "Champion System: Unlocked",
	["CHAMPION_WINDOW_CLOSED"] = "Champion System: Interface Closed",
	["CHAMPION_WINDOW_OPENED"] = "Champion System: Interface Opened",
	["CHAMPION_ZOOM_IN"] = "Champion System: Interface Zoom In",
	["CHAMPION_ZOOM_OUT"] = "Champion System: Interface Zoom Out",
	["COLLECTIBLE_UNLOCKED"] = "Collectible Unlocked",
	["DEFER_NOTIFICATION"] = "Defer Notification",
	["ENCHANTING_ESSENCE_RUNE_PLACED"] = "Enchanting Essence Rune Placed",
	["GROUP_DISBAND"] = "Group Disband",
	["GROUP_JOIN"] = "Group Joined",
	["GROUP_LEAVE"] = "Group Leave",
	["HOUSING_EDITOR_RETRIEVE_ITEM"] = "Housing Editor Retrieve Item",
	["INVENTORY_ITEM_JUNKED"] = "Inventory Item Junked",
	["INVENTORY_ITEM_UNJUNKED"] = "Inventory Item Unjunked",
	["JUSTICE_GOLD_REMOVED"] = "Justice Gold Removed",
	["JUSTICE_ITEM_REMOVED"] = "Justice Item Removed",
	["JUSTICE_NOW_KOS"] = "Justice Now KOS",
	["JUSTICE_NO_LONGER_KOS"] = "Justice No Longer KOS",
	["JUSTICE_PICKPOCKET_BONUS"] = "Justice Pickpocket Bonus",
	["JUSTICE_PICKPOCKET_FAILED"] = "Justice Pickpocket Failed",
	["JUSTICE_STATE_CHANGED"] = "Justice State Changed",
	["MAIL_SENT"] = "Mail Sent",
	["NEW_MAIL"] = "New Mail",
	["NEW_NOTIFICATION"] = "New Notification", -- Default
	["OBJECTIVE_ACCEPTED"] = "Objective Accepted",
	["OBJECTIVE_COMPLETED"] = "Objective Completed",
	["OBJECTIVE_DISCOVERED"] = "Objective Discovered",
	["OUTFIT_ARMOR_TYPE_HEAVY"] = "Armour Type: Heavy",
	["OUTFIT_ARMOR_TYPE_LIGHT"] = "Armour Type: Light",
	["OUTFIT_ARMOR_TYPE_MEDIUM"] = "Armour Type: Medium",
	["OUTFIT_WEAPON_TYPE_BOW"] = "Weapon Type: Bow",
	["OUTFIT_WEAPON_TYPE_STAFF"] = "Weapon Type: Staff",
	["OUTFIT_WEAPON_TYPE_SWORD"] = "Weapon Type: Sword",
	["QUEST_ABANDONED"] = "Quest Abandoned",
	["QUEST_ACCEPTED"] = "Quest Accepted",
	["QUEST_COMPLETED"] = "Quest Completed",
	["QUEST_FOCUSED"] = "Quest Focused",
	["QUEST_STEP_FAILED"] = "Quest Step Failed",
	["SKILL_RESPEC_PURCHASED"] = "Skill Respec Purchased",
	["TELVAR_GAINED"] = "Telvar Gained",
	["TELVAR_LOST"] = "Telvar Lost",
}

-- Get names of all sound options.
local function GetSoundOptions()
	local choices = {}

	for _, title in pairs(soundOptions) do
		choices[#choices + 1] = title
	end

	return choices
end

-- Pack or unpack RGB values to or from a table.
local function RGB(r, g, b)
	if type(r) == "table" then
		return
			r.r and r.r or 0,
			r.g and r.g or 0,
			r.b and r.b or 0
	else
		return {
			r = (r and r or 0),
			g = (g and g or 0),
			b = (b and b or 0)
		}
	end
end

-- Constants.
local FADE_STYLE = "SmithingImprovementBoosterFade"
local ZOOM_STYLE = "NotificationPulse"
local PULSE_STYLE = "CraftingGlowAlphaAnimation"

-- Get timeline, set up OnStop handler.
local function GetTimeline(style, control)
	local timeline = animationManager:CreateTimelineFromVirtual(style, control)

	timeline:SetHandler("OnStop", function()
		barSwapNotificationControl:SetAlpha(0)
	end)

	return timeline
end

-- Create table of animation styles and initialisation functions.
local animationStyles =
{
	["Fade (1 second)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(FADE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(1000)
			anim:SetAlphaValues(1, 0)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
		end,
	},
	["Fade (1.5 seconds)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(FADE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(1500)
			anim:SetAlphaValues(1, 0)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
		end,
	},
	["Fade (2 seconds)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(FADE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(2000)
			anim:SetAlphaValues(1, 0)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
		end,
	},
	["Pulse (1 Pulse)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(PULSE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(200)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 1)
		end,
	},
	["Pulse (2 Pulses)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(PULSE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(200)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 3)
		end,
	},
	["Pulse (3 Pulses)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(PULSE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(200)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 5)
		end,
	},
	["Pulse (4 Pulses)"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(PULSE_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(200)
			barSwapNotificationControl:SetScale(1 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 7)
		end,
	},
	["Zoom In and Fade"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(ZOOM_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(1000)
			anim:SetScaleValues(1.5 * savedVars.notificationScale, 0.5 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
		end,
	},
	["Zoom Out and Fade"] =
	{
		Initialise = function()
			barSwapNotificationControl.animation = GetTimeline(ZOOM_STYLE, barSwapNotificationControl)
			local anim = barSwapNotificationControl.animation:GetFirstAnimation()
			anim:SetDuration(1000)
			anim:SetScaleValues(0.5 * savedVars.notificationScale, 1.5 * savedVars.notificationScale)
			barSwapNotificationControl.animation:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
		end,
	}
}

-- Get names of all animation styles.
local function GetAnimationStyles()
	local styles = { }

	for name in pairs(animationStyles) do
		styles[#styles + 1] = name
	end

	return styles
end

-- Set animation style, call style's Initialise() function.
local function SetAnimationStyle(name)
	animationStyles[name].Initialise()
end

-- Terminate the animation.
local function StopAnimation()
	barSwapNotificationControl.animation:Stop()
	barSwapNotificationControl:SetHidden(true)
	eventManager:UnregisterForUpdate("BarSwapFeedbackAnimationTimeout")
end

-- Initialise and set up animation.
local function StartAnimation(barNumber)
	-- Clear any outstanding update events.
	eventManager:UnregisterForUpdate("BarSwapFeedbackAnimationTimeout")

	-- Set up notification control's texture and colour.
	barSwapNotificationControl:SetHidden(false)
	barSwapNotificationControl:SetTexture(glyphStyles[savedVars.glyphStyle][barNumber])
	barSwapNotificationControl:SetColor(RGB(savedVars.feedbackSettings[barNumber].notificationColour))

	-- Start the animation.
	barSwapNotificationControl.animation:PlayFromStart()

	-- Register for update to terminate animation after 3000ms.
	eventManager:RegisterForUpdate("BarSwapFeedbackAnimationTimeout", 3000, StopAnimation)

	-- Play confirmation sound.
	if savedVars.feedbackSettings[barNumber].enableAudioFeedback then
		PlaySound(SOUNDS[savedVars.feedbackSettings[barNumber].notificationSound])
	end
end

-- Set-up or reset notification anchor.
local function SetNotificationAnchor()
	barSwapNotificationControl:ClearAnchors()
	barSwapNotificationControl:SetAnchor(
		anchorOptions[savedVars.notificationSide],
		RETICLE.control,
		CENTER,
		(savedVars.notificationSide == "Left" and -savedVars.notificationXOffset) or (savedVars.notificationSide == "Right" and savedVars.notificationXOffset) or 0,
		savedVars.notificationYOffset)
end

-- Initialise options panel.
local function InitialiseSettings()
	local LAM2 = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = BarSwapFeedback.displayName,
		displayName = BarSwapFeedback.displayName,
		author = BarSwapFeedback.author,
		version = BarSwapFeedback.version,
		registerForDefaults = true,
		registerForRefresh = true,
		slashCommand = "/barswapfeedback",
		website = "https://www.esoui.com/downloads/info2524-BarSwapFeedback.html",
	}

	local audioChoices = GetSoundOptions()

	local optionsTable = {
		{
			type = "header",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_HEADER_NOTIFICATION_STYLE),
			width = "full"
		},
		{
			type = "dropdown",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_DESIGN),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_DESIGN_TOOLTIP),
			choices = GetGlyphOptions(),
			getFunc = function()
				return savedVars.glyphStyle
			end,
			setFunc = function(value)
				savedVars.glyphStyle = value
			end,
			width = "full",
			sort = "name-up",
			default = defaults.glyphStyle
		},
		{
			type = "dropdown",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_ANIMATION),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_TOOLTIP),
			choices = GetAnimationStyles(),
			getFunc = function()
				return savedVars.animationStyle
			end,
			setFunc = function(value)
				savedVars.animationStyle = value
				SetAnimationStyle(value)
			end,
			width = "full",
			sort = "name-up",
			default = defaults.animationStyle
		},
		{
			type = "dropdown",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_RETICLE_ALIGNMENT),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_RETICLE_ALIGNMENT_TOOLTIP),
			choices = GetAnchorOptions(),
			getFunc = function()
				return savedVars.notificationSide
			end,
			setFunc = function(choice)
				savedVars.notificationSide = choice
				SetNotificationAnchor()
			end,
			width = "full",
			default = function()
				savedVars.notificationSide = defaults.notificationSide
				SetNotificationAnchor()
				return savedVars.notificationSide
			end
		},
		{
			type = "slider",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_X_OFFSET),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_X_OFFSET_TOOLTIP),
			min = 0,
			max = 712,
			step = 8,
			getFunc = function()
				return savedVars.notificationXOffset
			end,
			setFunc = function(value)
				savedVars.notificationXOffset = value
				SetNotificationAnchor()
			end,
			disabled = function()
				return (savedVars.notificationSide == "Centre") and true or false
			end,
			default = function()
				savedVars.notificationXOffset = defaults.notificationXOffset
				SetNotificationAnchor()
				return savedVars.notificationXOffset
			end
		},
		{
			type = "slider",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_Y_OFFSET),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_Y_OFFSET_TOOLTIP),
			min = -400,
			max = 400,
			step = 8,
			getFunc = function()
				return savedVars.notificationYOffset
			end,
			setFunc = function(value)
				savedVars.notificationYOffset = value
				SetNotificationAnchor()
			end,
			default = function()
				savedVars.notificationYOffset = defaults.notificationYOffset
				SetNotificationAnchor()
				return savedVars.notificationYOffset
			end
		},
		{
			type = "slider",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SIZE),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SIZE_TOOLTIP),
			min = 10,
			max = 300,
			step = 5,
			getFunc = function() return math.floor(savedVars.notificationScale * 100) end,
			setFunc = function(value)
				savedVars.notificationScale = value / 100
				SetAnimationStyle(savedVars.animationStyle)
			end,
			default = defaults.notificationScale * 100
		},
		{
			type = "header",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_HEADER_ACTION_BAR1),
			width = "full"
		},
		{
			type = "colorpicker",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_COLOUR),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_COLOUR_BAR1_TOOLTIP),
			getFunc = function()
				return RGB(savedVars.feedbackSettings[0].notificationColour)
			end,
			setFunc = function(r, g, b)
				savedVars.feedbackSettings[0].notificationColour = RGB(r, g, b)
			end,
			default = defaults.feedbackSettings[0].notificationColour
		},
		{
			type = "checkbox",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_ENABLE),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_ENABLE_BAR1_TOOLTIP),
			getFunc = function() return savedVars.feedbackSettings[0].enableAudioFeedback end,
			setFunc = function(value)
				savedVars.feedbackSettings[0].enableAudioFeedback = value
			end,
			width = "full",
			default = defaults.feedbackSettings[0].enableAudioFeedback,
		},
		{
			type = "dropdown",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_BAR1_TOOLTIP),
			choices = audioChoices,
			getFunc = function()
				return soundOptions[savedVars.feedbackSettings[0].notificationSound]
			end,
			disabled = function() return not savedVars.feedbackSettings[0].enableAudioFeedback end,
			setFunc = function(choice)
				for key, value in pairs(soundOptions) do
					if choice == value then
						savedVars.feedbackSettings[0].notificationSound = key
						PlaySound(SOUNDS[savedVars.feedbackSettings[0].notificationSound])
						return
					end
				end
			end,
			width = "full",
			scrollable = true,
			sort = "name-up",
			default = function()
				savedVars.feedbackSettings[0].notificationSound = defaults.feedbackSettings[0].notificationSound
				return savedVars.feedbackSettings[0].notificationSound
			end
		},
		{
			type = "header",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_HEADER_ACTION_BAR2),
			width = "full"
		},
		{
			type = "colorpicker",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_COLOUR),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_COLOUR_BAR2_TOOLTIP),
			getFunc = function()
				return RGB(savedVars.feedbackSettings[1].notificationColour)
			end,
			setFunc = function(r, g, b)
				savedVars.feedbackSettings[1].notificationColour = RGB(r, g, b)
			end,
			default = defaults.feedbackSettings[1].notificationColour
		},
		{
			type = "checkbox",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_ENABLE),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_ENABLE_BAR2_TOOLTIP),
			getFunc = function() return savedVars.feedbackSettings[1].enableAudioFeedback end,
			setFunc = function(value)
				savedVars.feedbackSettings[1].enableAudioFeedback = value
			end,
			width = "full",
			default = defaults.feedbackSettings[1].enableAudioFeedback
		},
		{
			type = "dropdown",
			name = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX),
			tooltip = GetString(SI_BARSWAPFEEDBACK_SETTINGS_SOUND_FX_BAR2_TOOLTIP),
			choices = audioChoices,
			getFunc = function()
				return soundOptions[savedVars.feedbackSettings[1].notificationSound]
			end,
			disabled = function() return not savedVars.feedbackSettings[1].enableAudioFeedback end,
			setFunc = function(choice)
				for key, value in pairs(soundOptions) do
					if choice == value then
						savedVars.feedbackSettings[1].notificationSound = key
						PlaySound(SOUNDS[savedVars.feedbackSettings[1].notificationSound])
						return
					end
				end
			end,
			width = "full",
			scrollable = true,
			sort = "name-up",
			default = function()
				savedVars.feedbackSettings[1].notificationSound = defaults.feedbackSettings[1].notificationSound
				return savedVars.feedbackSettings[1].notificationSound
			end
		},
	}

	LAM2:RegisterAddonPanel(BarSwapFeedback.addonName.."Options", panelData)
	LAM2:RegisterOptionControls(BarSwapFeedback.addonName.."Options", optionsTable)
end

-- Handler for EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED.
local function Event_OnActionSlotsActiveHotbarUpdated(eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
	if didActiveHotbarChange and not shouldUpdateAbilityAssignments then
		if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY or activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
			StartAnimation(activeHotbarCategory)
		end
	end
end

-- Handler for EVENT_ADD_ON_LOADED.
local function Event_OnAddonLoaded(eventCode, addonName)
	if addonName ~= BarSwapFeedback.addonName then return end

	-- Unregister EVENT_ADD_ON_LOADED.
	eventManager:UnregisterForEvent(BarSwapFeedback.addonName, EVENT_ADD_ON_LOADED)

	-- Load saved variables.
	savedVars = ZO_SavedVars:NewAccountWide("BarSwapFeedback_SavedVars", BarSwapFeedback.settingsVersion, nil, defaults)

	-- Initialise options panel.
	InitialiseSettings()

	-- Create notification control and attached to reticle.
	barSwapNotificationControl = windowManager:CreateControl("$(parent)BarSwapNotification", RETICLE.control, CT_TEXTURE)
	barSwapNotificationControl:SetBlendMode(TEX_BLEND_MODE_ALPHA)
	barSwapNotificationControl:SetTexture("")
	barSwapNotificationControl:SetDrawLevel(2)
	barSwapNotificationControl:SetDimensions(256, 256)
	barSwapNotificationControl:SetHidden(true)
	barSwapNotificationControl:SetScale(1)
	barSwapNotificationControl.animation = nil

	-- Set notification anchors.
	SetNotificationAnchor()

	-- Initialise animation style.
	SetAnimationStyle(savedVars.animationStyle)

	-- Register for action bar update event.
	eventManager:RegisterForEvent(BarSwapFeedback.addonName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, Event_OnActionSlotsActiveHotbarUpdated)
end

-- Register for Addon Loaded event.
eventManager:RegisterForEvent(BarSwapFeedback.addonName, EVENT_ADD_ON_LOADED, Event_OnAddonLoaded)