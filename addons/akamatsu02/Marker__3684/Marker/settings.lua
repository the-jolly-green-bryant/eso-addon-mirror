MARK = MARK or {}

-- PERFORMANCE: Localize globals
local t_tonumber = tonumber
local m_clamp = math.clamp

function MARK.settings()
	local panelData = {
		type = "panel",
		name = MARK.name,
		displayName = MARK.addonInfo.title,
		author = MARK.addonInfo.author,
		registerForRefresh = true,
	}

	LibAddonMenu2:RegisterAddonPanel(MARK.name.." - Options", panelData)

	local options = {
		{
			type = "checkbox",
			name = "Marker Icon in Chat",
			tooltip = "Enable the Chat Menu Button",
			getFunc = function() 
                -- BUG FIX: `false or true` evaluates to `true`. 
                -- Explicitly check for nil to allow `false` to be returned properly.
                if MARK.savedVars.showChatButton == nil then return true end
                return MARK.savedVars.showChatButton
            end,
			setFunc = function(value) 
                -- BUG FIX: Use the boolean `value` provided by LAM2 directly
                MARK.savedVars.showChatButton = value
				if value then
					MARK.chatButton:show()
				else
					MARK.chatButton:hide()
				end
			end,
		},
		{
			type = "checkbox",
			name = "Show all emotes in selection",
			tooltip = "Show all 1000+ emotes when you select a texture",
			getFunc = function() return MARK.savedVars.emotePackName ~= "mark" end,
			setFunc = function(value) 
                -- BUG FIX: Use the boolean `value` provided by LAM2 directly
                MARK.savedVars.emotePackName = value and "" or "mark"
			end,
		},
		{
		    type = "editbox",
		    name = "Icon-Size multiplier (%)",
			tooltip = "Size multiplier for all icons",
		    getFunc = function() return MARK.savedVars.iconsizemultiplier or 100 end,
		    setFunc = function(text)
				MARK.savedVars.iconsizemultiplier = m_clamp(t_tonumber(text) or 100, 10, 1000)
				MARK.ClearAndReload()
			end,
		    isMultiline = false,
		    default = 100,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 3
		},
		{
		    type = "editbox",
		    name = "Distance",
			tooltip = "Radius of the distance check (in cm)",
		    getFunc = function() return MARK.savedVars.radius end,
		    setFunc = function(text)
				MARK.savedVars.radius = m_clamp(t_tonumber(text) or 10000, 500, 100000)
				MARK.reloadProfile()
			end,
		    isMultiline = false,
		    default = 10000,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 5
		},
		{
		    type = "editbox",
		    name = "Delay",
			tooltip = "Amount of milliseconds before all markers are updated again (min 100, max 10000)",
		    getFunc = function() return MARK.savedVars.delay end,
		    setFunc = function(text)
				MARK.savedVars.delay = m_clamp(t_tonumber(text) or 2000, 100, 10000)
				MARK.reloadProfile()
			end,
		    isMultiline = false,
		    default = 2000,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 5
		},
		{
		    type = "editbox",
		    name = "Minimum delay",
			tooltip = "Minimal delay between each marker update (min 5, max 1000)",
		    getFunc = function() return MARK.savedVars.minimumdelay end,
		    setFunc = function(text)
				MARK.savedVars.minimumdelay = m_clamp(t_tonumber(text) or 50, 5, 1000)
				MARK.reloadProfile()
			end,
		    isMultiline = false,
		    default = 50,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 3
		}
	}
	
	LibAddonMenu2:RegisterOptionControls(MARK.name.." - Options", options)
end