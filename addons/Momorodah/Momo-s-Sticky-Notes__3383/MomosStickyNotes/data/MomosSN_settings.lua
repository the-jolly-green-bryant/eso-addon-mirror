-- Author: Momorodah

local LAM = LibAddonMenu2
local panelName = "MomosSNSettings"

MomosSN.settings = {}

local SNOptionsTable = {}
local SNcounter = 0

function MomosSN.settings:Initialize()
	MomosSN.settings:CreateSNSettings()
end

function MomosSN.settings:CreateSNSettings()
	local panelData = {
		type = "panel",
		name = "Momo's Sticky Notes",
		displayName = "Momo's Sticky Notes",
		author = "Momorodah",
		version = "1.0",
		slashCommand = "/momo",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	-- DESCRIPTION
	table.insert(SNOptionsTable,{
        type = "description",
        text = "A bunch of sticky notes for your note-taking pleasures! Movable, resizable, with or without background textures and icons. This addon is a work in progress, make sure you create a backup of your most precious notes just to be safe! To move the sticky note simply drag it by clicking and holding the header text. If you click on an sticky note icon (if you have it enabled) it will bring up the control list where you can toggle visibility for every sticky note. This list can also be bound to a key for easy access.",
        width = "full",
    })
	-- HIDE SN CHECKBOX
	table.insert(SNOptionsTable,{
		type = "checkbox",
		name = "Hide sticky notes while in combat",
		tooltip = "This will hide your sticky notes while you are in combat since you'll probably have bigger things to worry about than your shopping list",
		getFunc = function() return MomosSN.savedVariables.hideInCombat end,
		setFunc = function(boolValue) MomosSN.savedVariables.hideInCombat = boolValue end,
		width = "full",
	})
	-- DIVIDER
	table.insert(SNOptionsTable,{
		type = "divider",
		width = "full",
	})
	-- SN LIST HEADER
	table.insert(SNOptionsTable,{
		type = "header",
		name = "Sticky Notes",
		width = "half",
	})
	-- Define these variables so we can reference them later.. and also don't add to the optionsTable just yet
	local SNListDescription = {
		type = "description",
		text = "",
		width = "half",
	}
	-- ADD NEW SN BUTTON
	table.insert(SNOptionsTable,{
		type = "button",
		name = "Add new Sticky Note",
		func = function()
			MomosSN.settings:AddNewSN("Momo's Sticky Note")
			-- Update the text showing in the settings menu with a green SN counter to visualize that a new sticky note was added
			SNcounter = SNcounter + 1
			SNListDescription.text = "Nr of sticky notes: |c00FF00" .. SNcounter .. "|r\n" ..
				"New sticky note added, you will need to reload your UI in order for it to show up!\n" ..
				"(Use the button to the right or type /reloadui in the chat window)"
		end,
		width = "half",
		warning = "UI reload required",
	})
	-- Add these down here instead so they're in the right place
	table.insert(SNOptionsTable,SNListDescription)
	-- RELOAD UI BUTTON
	table.insert(SNOptionsTable,{
		type = "button",
		name = "Reload UI",
		tooltip = "Reload the UI to make the new settings take effect. This might take a while.",
		func = function()
			ReloadUI()
		end,
		width = "half",
	})

	-- Add sticky notes to settings list
	for key, SNTable in ipairs(MomosSN.savedVariables.stickyNotes) do
		MomosSN.settings:AddSNToSettings(SNTable, SNListDescription)
		SNcounter = SNcounter + 1
	end
	SNListDescription.text = "Nr of sticky notes: " .. SNcounter

	local settingsPanel = LAM:RegisterAddonPanel("MomosSNEditWindow", panelData)
	local settingsControl = LAM:RegisterOptionControls("MomosSNEditWindow", SNOptionsTable)
end

function MomosSN.settings:AddSNToSettings(SNTable, SNListDescription)
	local SNOption = {
		type = "submenu",
		name = SNTable.name,
		controls = {},
	}
	-- SN NAME
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Name",
		tooltip = "Specify the name of the sticky note (this is the header that will be shown at the top of the sticky note).",
		getFunc = function() return SNTable.name end,
		setFunc = function(value) SNTable.name = value end,
		isMultiline = false,
		width = "full",
		default = "Momo's Sticky Note",
		warning = "UI reload required",
	})
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- CONTENT FONT NAME
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Content font",
        tooltip = "Choose the font to use for the content of the sticky note. UI reload required.",
        choices = MomosSN.fonts,
        getFunc = function() return SNTable.contentFontName end,
        setFunc = function(value) SNTable.contentFontName = value end,
        width = "half",
		default = "HANDWRITTEN_FONT",
		warning = "UI reload required",
    })
	-- CONTENT FONT SIZE
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Content font size",
		tooltip = "Specify the font size of the sticky note content (default:14). UI reload required.",
		getFunc = function() return SNTable.contentFontSize end,
		setFunc = function(value) SNTable.contentFontSize = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 14,
		warning = "UI reload required",
	})
	-- CONTENT FONT COLOR
	table.insert(SNOption.controls,{
		type = "colorpicker",
		name = "Content font color",
		getFunc = function() return unpack(SNTable.contentFontColor) end,
		setFunc = function(r,g,b,a) SNTable.contentFontColor = {r,g,b,a} end,
		width = "half",
		warning = "UI reload required",
	})
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- WIDTH
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Width",
		tooltip = "Specify the width of the sticky notes in pixels (default:200). UI reload required.",
		getFunc = function() return SNTable.width end,
		setFunc = function(value) SNTable.width = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 200,
		warning = "UI reload required",
	})
	-- HEIGHT
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Height",
		tooltip = "Specify the height of the sticky notes in pixels (default:200). UI reload required.",
		getFunc = function() return SNTable.height end,
		setFunc = function(value) SNTable.height = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 200,
		warning = "UI reload required",
	})
	-- RESIZING DESCRIPTION
	table.insert(SNOption.controls,{
		type = "description",
		text = "Tip! You can also resize by tugging at the edges of the sticky note, that way you won't have to reload your UI for the changes to take effect.",
		width = "full",
	})
	-- EDGE COLOR
	table.insert(SNOption.controls,{
		type = "colorpicker",
		name = "Edge color",
		getFunc = function() return unpack(SNTable.edgeColor) end,
		setFunc = function(r,g,b,a) SNTable.edgeColor = {r,g,b,a} end,
		width = "half",
		warning = "UI reload required",
	})
	-- CENTER COLOR
	table.insert(SNOption.controls,{
		type = "colorpicker",
		name = "Center color",
		getFunc = function() return unpack(SNTable.centerColor) end,
		setFunc = function(r,g,b,a) SNTable.centerColor = {r,g,b,a} end,
		width = "half",
		warning = "UI reload required",
	})
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- BACKGROUND TEXTURE ENABLED
	table.insert(SNOption.controls,{
		type = "checkbox",
		name = "Enable background texture",
		getFunc = function() return SNTable.backgroundEnabled end,
		setFunc = function(value) SNTable.backgroundEnabled = value end,
		width = "half",
		warning = "UI reload required",
	})
	-- BACKGROUND TEXTURE
	local bgTextureList = {}		
	for textureName, textureTable in pairs(MomosSN.backgrounds) do
		table.insert(bgTextureList, textureName)
	end
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Background texture",
        tooltip = "Choose which texture to use as the background for the sticky note. UI reload required.",
        choices = bgTextureList,
        getFunc = function() return SNTable.backgroundName end,
        setFunc = function(value) SNTable.backgroundName = value end,
        width = "half",
		default = "Top right",
		warning = "UI reload required",
    })
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- ICON TEXTURE
	local iconTextureList = {}		
	for textureName, textureTable in pairs(MomosSN.icons) do
		table.insert(iconTextureList, textureName)
	end
	table.insert(SNOption.controls,{
		type = "dropdown",
		name = "Icon texture",
		choices = iconTextureList,
		getFunc = function() return SNTable.iconName end,
		setFunc = function(value) SNTable.iconName = value end,
		width = "half",
		warning = "UI reload required",
	})
	-- ICON ANCHOR POINT
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Icon anchor",
        tooltip = "Choose where on the sticky note you want the icon to anchor. UI reload required.",
        choices = MomosSN.anchors,
        getFunc = function() return SNTable.iconAnchor end,
        setFunc = function(value) SNTable.iconAnchor = value end,
        width = "half",
		default = "Top right",
		warning = "UI reload required",
    })
	-- ICON ANCHOR OFFSET X
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Icon offset X",
		tooltip = "Specify the icon offset x (positive number make icon go right, default:0). UI reload required.",
		getFunc = function() return SNTable.iconOffsetX end,
		setFunc = function(value) SNTable.iconOffsetX = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 0,
		warning = "UI reload required",
	})
	-- ICON ANCHOR OFFSET Y
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Icon offset Y",
		tooltip = "Specify the icon offset y (positive number make icon go down, default:0). UI reload required.",
		getFunc = function() return SNTable.iconOffsetY end,
		setFunc = function(value) SNTable.iconOffsetY = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 0,
		warning = "UI reload required",
	})
	-- ICON CUSTOM COLOR ENABLED
	table.insert(SNOption.controls,{
		type = "checkbox",
		name = "Enable custom coloring for icon",
		getFunc = function() return SNTable.iconColorEnabled end,
		setFunc = function(value) SNTable.iconColorEnabled = value end,
		width = "half",
		warning = "UI reload required",
	})
	-- ICON CUSTOM COLOR
	table.insert(SNOption.controls,{
		type = "colorpicker",
		name = "Icon custom color",
		getFunc = function() return unpack(SNTable.iconColor) end,
		setFunc = function(r,g,b,a) SNTable.iconColor = {r,g,b,a} end,
		width = "half",
		warning = "UI reload required",
	})
	-- ICON SCALE
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Icon scale",
        tooltip = "Choose the scale of the icon (scale 1 is 8x8 pixels, default:4 which is 32x32 pixels). UI reload required.",
        choices = MomosSN.iconScales,
        getFunc = function() return SNTable.iconScale end,
        setFunc = function(value) SNTable.iconScale = value end,
        width = "half",
		default = 4,
		warning = "UI reload required",
    })
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- HEADER FONT NAME
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Header font",
        tooltip = "Choose the font to use for the header of the sticky note. UI reload required.",
        choices = MomosSN.fonts,
        getFunc = function() return SNTable.headerFontName end,
        setFunc = function(value) SNTable.headerFontName = value end,
        width = "half",
		default = "ANTIQUE_FONT",
		warning = "UI reload required",
    })
	-- HEADER FONT SIZE
	table.insert(SNOption.controls, {
		type = "editbox",
		name = "Header font size",
		tooltip = "Specify the header font size (default:20). UI reload required.",
		getFunc = function() return SNTable.headerFontSize end,
		setFunc = function(value) SNTable.headerFontSize = value end,
		isMultiline = false,
		textType = "TEXT_TYPE_NUMERIC_UNSIGNED_INT",
		width = "half",
		default = 20,
		warning = "UI reload required",
	})
	-- HEADER FONT ALIGNMENT
	table.insert(SNOption.controls,{
        type = "dropdown",
        name = "Header font alignment",
        tooltip = "Choose which alignment you want for the header. UI reload required.",
        choices = MomosSN.fontAlignments,
        getFunc = function() return SNTable.headerFontAlignment end,
        setFunc = function(value) SNTable.headerFontAlignment = value end,
        width = "half",
		default = "Center",
		warning = "UI reload required",
    })
	-- HEADER FONT COLOR
	table.insert(SNOption.controls,{
		type = "colorpicker",
		name = "Header font color",
		getFunc = function() return unpack(SNTable.headerFontColor) end,
		setFunc = function(r,g,b,a) SNTable.headerFontColor = {r,g,b,a} end,
		width = "half",
		warning = "UI reload required",
	})
	-- DIVIDER
	table.insert(SNOption.controls,{
		type = "divider",
		width = "full",
	})
	-- Remove button
	table.insert(SNOption.controls, {
		type = "button",
		name = "Remove",
		tooltip = "Button's tooltip text.",
		func = function()
			MomosSN.settings:RemoveSN(SNTable.identifier)
			-- Update the text showing in the settings menu with a red SN counter to visualize that a sticky note was removed
			SNcounter = SNcounter - 1
			SNListDescription.text = "Nr of sticky notes: |cFF0000" .. SNcounter .. "|r\n" ..
				"Sticky Note removed, you will need to reload your UI in order for it to disappear!\n" ..
				"(Use the button to the right or type /reloadui in the chat window)"
			SNOption.name = "|cFF0000[REMOVED]|r"
		end,
		width = "half",
		warning = "UI reload required",
	})

	-- Add the sticky note to the settings menu
	table.insert(SNOptionsTable, SNOption)
end

function MomosSN.settings:AddNewSN(name)
	-- Update the index so we get a unique identifier for the new sticky note
	MomosSN.savedVariables.SNIndex = MomosSN.savedVariables.SNIndex + 1
	local newSN = ZO_DeepTableCopy(MomosSN.defaultSN, nil)
	newSN.identifier = "id:" .. MomosSN.savedVariables.SNIndex
	table.insert(MomosSN.savedVariables.stickyNotes, newSN)
end

function MomosSN.settings:RemoveSN(identifier)
	local tableCounter = 1
	for key, SNTable in ipairs(MomosSN.savedVariables.stickyNotes) do
		if SNTable.identifier == identifier then
			table.remove(MomosSN.savedVariables.stickyNotes, tableCounter)
			d("Sticky Note removed:", SNTable)
		end
		tableCounter = tableCounter + 1
	end
end