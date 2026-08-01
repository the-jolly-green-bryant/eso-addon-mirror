Jukebox = {}
local Jukebox = Jukebox

Jukebox.name = "Jukebox"
Jukebox.version = "2.1"

Jukebox.defaults = {
    enabledChapters = {},
	logoutAttempted = false,
	changeType = 1,
	chance = 50,
	logoutCooldown = 20,
	logoutCount = 1,
}

local function GetRandomMusic()
	local music = {}
	local current = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC)

	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		if Jukebox.SV.enabledChapters[chapterId] and current ~= chapterId then
			table.insert(music, chapterId)
		end
	end
	
	if #music == 0 then
		-- In case no music is enabled to be used, fall back to "Default" setting from ESO
		return -1
	else
		return music[zo_round((math.random() * #music * 100) / 100)] or -1
	end
end

local function UpdateMusic()
	-- This is needed since you can't really catch the actual logout, since the player can cancel the logout process.
	-- However, logging out or quitting triggeres this once so we do our thing here regardless, but only once.
	-- The saved logoutAttempted variable gets set to false whenever the addon loads i.e. when you log in (or reload UI, not perfect but egh, at least minimizes false music change triggers)
	if Jukebox.SV.logoutAttempted then return end
	Jukebox.SV.logoutAttempted = true

	if Jukebox.SV.changeType == 2 then -- Weighted
		-- baseChance + (count/target)^3 * (1 - baseChance)
		local chance = Jukebox.SV.chance + math.pow(Jukebox.SV.logoutCount / Jukebox.SV.logoutCooldown, 3) * (1 - Jukebox.SV.chance)
		if math.random(0, 100) < chance then
			Jukebox.SV.logoutCount = 0
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, GetRandomMusic())
		end
	elseif Jukebox.SV.changeType == 1 then -- Random
		local rand = math.random(0, 100)
		if rand < Jukebox.SV.chance then
			d(zo_strformat("[Jukebox] Changing music (<<1>>/<<2>>, Random Mode)", rand, Jukebox.SV.chance))
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, GetRandomMusic())
		else
			d(zo_strformat("[Jukebox] Not changing music (<<1>>/<<2>>, Random Mode)", rand, Jukebox.SV.chance))
		end
	else -- Fixed
		Jukebox.SV.logoutCount = Jukebox.SV.logoutCount + 1
		if Jukebox.SV.logoutCount >= Jukebox.SV.logoutCooldown then
			d(zo_strformat("[Jukebox] Changing music (<<1>>/<<2>>, Fixed Mode)", Jukebox.SV.logoutCount, Jukebox.SV.logoutCooldown))
			Jukebox.SV.logoutCount = 0
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_INTRO_MUSIC, GetRandomMusic())			
		else
			d(zo_strformat("[Jukebox] Not changing music (<<1>>/<<2>>, Fixed Mode)", Jukebox.SV.logoutCount, Jukebox.SV.logoutCooldown))
		end
	end
end

local function InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Jukebox",
		displayName = "Jukebox",
		author = "MrPikPik",
		version = Jukebox.version,
		website = 'https://www.esoui.com/downloads/info3403-Jukebox-MenuMusicRandomizer.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Jukebox'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForDefaults = true
	}

	local optionsData = {}

    -- Addon Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(JUKEBOX_OPTIONS_DESCRIPTION),
	})
    
	-- Blacklist header
	table.insert(optionsData, {
		type = "header",
		name = GetString(JUKEBOX_OPTIONS_HEADER_BLACKLIST),
	})
	
	-- Blacklist Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(JUKEBOX_OPTIONS_BLACKLIST_DESCRIPTION),
	})
		
	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		table.insert(optionsData, {
			type = "checkbox",
			name = GetString("SI_CHAPTER", chapterId),
			default = Jukebox.defaults.enabledChapters[chapterId],
			getFunc = function() return Jukebox.SV.enabledChapters[chapterId] end,
			setFunc = function(newValue) Jukebox.SV.enabledChapters[chapterId] = newValue end,
			width = "half"
		})
	end
	
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(Jukebox_OPTIONS_HEADER),
	})
	
    -- Change Type
    table.insert(optionsData, {
		type = "dropdown",
		name = GetString(JUKEBOX_OPTIONS_TYPE),
        tooltip = GetString(JUKEBOX_OPTIONS_TYPE_DESCRIPTION),
        choices = {
			GetString(JUKEBOX_OPTIONS_TYPE_FIXED),
            GetString(JUKEBOX_OPTIONS_TYPE_RANDOM),
            GetString(JUKEBOX_OPTIONS_TYPE_WEIGHTED)
        },
		getFunc = function()
			if Jukebox.SV.changeType == 2 then
                return GetString(JUKEBOX_OPTIONS_TYPE_WEIGHTED)
            elseif Jukebox.SV.changeType == 1 then
                return GetString(JUKEBOX_OPTIONS_TYPE_RANDOM)
            else -- Default to fixed
                return GetString(JUKEBOX_OPTIONS_TYPE_FIXED)
            end
        end,
		setFunc = function(newValue)
			if newValue == GetString(JUKEBOX_OPTIONS_TYPE_WEIGHTED) then
                Jukebox.SV.changeType = 2
			elseif newValue == GetString(JUKEBOX_OPTIONS_TYPE_RANDOM) then
                Jukebox.SV.changeType = 1
            else -- Default to fixed
                Jukebox.SV.changeType = 0
            end
        end,
        default = GetString(JUKEBOX_OPTIONS_TYPE_FIXED),
	})
    
	-- Change cooldown slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(JUKEBOX_OPTIONS_COOLDOWN),
		tooltip = GetString(JUKEBOX_OPTIONS_COOLDOWN_DESCRIPTION),
        min = 1,
        max = 100,
		default = Jukebox.defaults.logoutCooldown,
		getFunc = function()
            return Jukebox.SV.logoutCooldown
        end,
		setFunc = function(newValue)
            Jukebox.SV.logoutCooldown = newValue
        end,
	})
	
	-- Chance slider
	table.insert(optionsData, {
		type = "slider",
		name = GetString(JUKEBOX_OPTIONS_RANDOM),
		tooltip = GetString(JUKEBOX_OPTIONS_RANDOM_DESCRIPTION),
        min = 1,
        max = 100,
		default = Jukebox.defaults.chance,
		getFunc = function()
            return Jukebox.SV.chance
        end,
		setFunc = function(newValue)
            Jukebox.SV.chance = newValue
        end,
	})
	
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(Jukebox.name .. "Settings", panelData)
	LibAddonMenu2:RegisterOptionControls(Jukebox.name .. "Settings", optionsData)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= Jukebox.name then return end
    EVENT_MANAGER:UnregisterForEvent(Jukebox.name, EVENT_ADD_ON_LOADED)
    
    Jukebox.SV = ZO_SavedVars:NewAccountWide("JukeboxSavedVariables", 1.0, nil, Jukebox.defaults)
	for chapterId = CHAPTER_ITERATION_BEGIN, CHAPTER_ITERATION_END do
		if not Jukebox.SV.enabledChapters[chapterId] then
			Jukebox.SV.enabledChapters[chapterId] = true
		end
	end
	Jukebox.SV.logoutAttempted = false
    ZO_PreHook("Logout", UpdateMusic)
	ZO_PreHook("Quit", UpdateMusic)
	
	SLASH_COMMANDS["/jukebox"] = function()
		d(GetRandomMusic())
	end
	
	InitializeAddonMenu()
end
EVENT_MANAGER:RegisterForEvent(Jukebox.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)