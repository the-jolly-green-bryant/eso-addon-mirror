local PANEL_NAME = "ConsistentColoursPanel"

local function BuildOptions()
    local opts = {}

    opts[#opts + 1] = {
        type = "header", 
        name = "Consistent Colours Settings"
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = { 
        type = "checkbox", 
        name = "Auto Apply Colours", 
        getFunc = function() return ConsistentColours.sv.autoApply end, 
        setFunc = function(value) ConsistentColours.sv.autoApply = value end,
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Public Chat",
        tooltip = "Set the colour of your Public chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[1]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[1] = { r = r, g = g, b = b }
        end,
        width = "full",
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Group Chat",
        tooltip = "Set the colour of your Group chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[2]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[2] = { r = r, g = g, b = b }
        end,
        width = "full",
    }


    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Guild 1 Chat",
        tooltip = "Set the colour of your Guild 1 chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[3]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[3] = { r = r, g = g, b = b }
        end,
        width = "full",
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Guild 2 Chat",
        tooltip = "Set the colour of your Guild 2 chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[4]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[4] = { r = r, g = g, b = b }
        end,
        width = "full",
    }


    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Guild 3 Chat",
        tooltip = "Set the colour of your Guild 3 chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[5]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[5] = { r = r, g = g, b = b }
        end,
        width = "full",
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Guild 4 Chat",
        tooltip = "Set the colour of your Guild 4 chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[6]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[6] = { r = r, g = g, b = b }
        end,
        width = "full",
    }

    opts[#opts + 1] = {
	type = "divider",
	height = 15,
	alpha = 0.5,
	width = "full"
    }

    opts[#opts + 1] = {
        type = "colorpicker",
        name = "Guild 5 Chat",
        tooltip = "Set the colour of your Guild 5 chat",
        getFunc = function()
            local colours = ConsistentColours.sv.guildColours[7]
            if not colours then return 1,1,1,1 end
            return colours.r, colours.g, colours.b, 1
        end,
        setFunc = function(r, g, b)
            ConsistentColours.sv.guildColours[7] = { r = r, g = g, b = b }
        end,
        width = "full",
    }

    opts[#opts + 1] = {
        type = "button",
        name = "Apply Settings",
        tooltip = "Apply the current chat settings",
        func = function() ReloadUI() end,
        width = "full",	--or "full" (optional)
        warning = "Will need to reload the UI.",	--(optional)
    }

    return opts
end

function ConsistentColours:InitLAM()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "ConsistentColours",
        author = "Scribe Rob",
        version = "0.0.1",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    LAM:RegisterAddonPanel(PANEL_NAME, panelData)
    LAM:RegisterOptionControls(PANEL_NAME, BuildOptions())
end