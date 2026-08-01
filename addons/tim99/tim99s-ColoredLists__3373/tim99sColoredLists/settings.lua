tim99sColoredLists = tim99sColoredLists or {}
local tcl = tim99sColoredLists 

function tcl.ConvertHexToRGB(colourString)
	local r=tonumber(string.sub(colourString, 1, 2), 16) or 255
	local g=tonumber(string.sub(colourString, 3, 4), 16) or 255
	local b=tonumber(string.sub(colourString, 5, 6), 16) or 255
	return r/255, g/255, b/255
end
function tcl.ConvertRGBToHex(r, g, b)
	return string.format("%.2x%.2x%.2x", zo_floor(r*255), zo_floor(g*255), zo_floor(b*255))
end
function tcl.donatemail()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
        ZO_MailSendToField:SetText('@tïm\'99')
        ZO_MailSendSubjectField:SetText("Donation for ColoredLists")
        ZO_MailSendBodyField:SetText("Hi, sending some stuff or gold :)")
        ZO_MailSendBodyField:TakeFocus()
    end, 500)
end
--addon.Donate
function tcl.initMenu()
	local LAM2 = LibAddonMenu2
	local panelData = {
		type        = "panel",
		name        = tcl.col_tim:Colorize("tim99s Colored Lists"),
		author      = tcl.col_tim:Colorize("tim99"),
		version	    = "666",
		website		= "https://www.esoui.com/downloads/info3373-tim99sColoredLists.html",
		feedback	= "https://www.esoui.com/downloads/info3373-tim99sColoredLists.html#comments",
		donation	= tcl.donatemail,
		registerForRefresh = true,	--will refresh all options controls when a setting is changed and when the panel is shown
		registerForDefaults = true	--will set all options controls back to default values
	}
	LAM2:RegisterAddonPanel("tim99sColoredLists", panelData)
--===============================================================================================--
	local optionsData = {
		{	type		= "description",
			title		= tcl.col_tim:Colorize("Description"),
			text		= "|c999999I have come here to chew bubblegum and kick ass... and I'm all out of bubblegum|r",
			width		= "half",
		}, ----------------------------------------------------------------------------
		{	type		= "texture",
			image		= "/esoui/art/icons/assistant_banker_01.dds",
			--text      = "text",
			imageWidth	= 96,
			imageHeight	= 96,
			width		= "half",
		}, 
		--========================================================================--
		{	type    = "divider",
			alpha   = 0.4,
		}, -------------------------------------------
--		{	type    = "description",
--			title   = tcl.col_tim:Colorize("General"),
--			text    = "",
--		}, -------------------------------------------
--		{	type    = "checkbox",
--			name    = zo_iconFormat("/esoui/art/treeicons/tutorial_idexicon_gettingstarted_up.dds",32,32).." Widen the collection windows.",
--			getFunc = function() return tcl.svChar.widenCollection end,
--			setFunc = function(value) tcl.svChar.widenCollection=value end,
--			default = tcl.svCharDef.widenCollection,
--			width   = "full",
--			requiresReload = true,
--		}, -------------------------------------------
--		{	type    = "divider",
--			alpha   = 0.4,
--		}, -------------------------------------------
		{	type    = "description",
			title   = tcl.col_tim:Colorize("Sections"),
			text    = "",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_lorelibrary_up.dds",32,32).." Lorebooks",
			getFunc = function() return tcl.svChar.doLorebooks end,
			setFunc = function(value) tcl.svChar.doLorebooks=value end,
			default = tcl.svCharDef.doLorebooks,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
			width   = "half",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/tutorial_collections_tabicon_itemsets_up.dds",32,32).." SetCollection",
			getFunc = function() return tcl.svChar.doSetCollection end,
			setFunc = function(value) tcl.svChar.doSetCollection=value end,
			default = tcl.svCharDef.doSetCollection,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/tutorial_collections_tabicon_itemsets_up.dds",32,32).." SetCollection Header |cffff00(NEW)|r",
			getFunc = function() return tcl.svChar.doSetCollectHeader end,
			setFunc = function(value) tcl.svChar.doSetCollectHeader=value end,
			default = tcl.svCharDef.doSetCollectHeader,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/tutorial_collections_tabicon_itemsets_up.dds",32,32).." missed cnt behind SetCollection nodes",
			getFunc = function() return tcl.svChar.showSetsSums end,
			setFunc = function(value) tcl.svChar.showSetsSums=value end,
			disabled= function() return not tcl.svChar.doSetCollection end,
			default = tcl.svCharDef.showSetsSums,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/tutorial_collections_tabicon_itemsets_up.dds",32,32).." collapse finished sets |cffff00(NEW)|r",
			getFunc = function() return tcl.svChar.collapseSetDone end,
			setFunc = function(value) tcl.svChar.collapseSetDone=value end,
			default = tcl.svCharDef.collapseSetDone,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
			width   = "half",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds",32,32).." Achievements",
			getFunc = function() return tcl.svChar.doAchievements end,
			setFunc = function(value) tcl.svChar.doAchievements=value end,
			default = tcl.svCharDef.doAchievements,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds",32,32).." Achievement Header |cffff00(NEW)|r",
			getFunc = function() return tcl.svChar.doAchievHeader end,
			setFunc = function(value) tcl.svChar.doAchievHeader=value end,
			default = tcl.svCharDef.doAchievHeader,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds",32,32).." missed cnt behind Achievements nodes",
			getFunc = function() return tcl.svChar.showAchieveSums end,
			setFunc = function(value) tcl.svChar.showAchieveSums=value end,
			disabled= function() return not tcl.svChar.doAchievements end,
			default = tcl.svCharDef.showAchieveSums,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
			width   = "half",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/journal/journal_tabicon_antiquities_up.dds",32,32).." Antiquities",
			getFunc = function() return tcl.svChar.doAntiquities end,
			setFunc = function(value) tcl.svChar.doAntiquities=value end,
			default = tcl.svCharDef.doAntiquities,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/journal/journal_tabicon_antiquities_up.dds",32,32).." Antiquities Header |cffff00(NEW)|r",
			getFunc = function() return tcl.svChar.doAntiquHeader end,
			setFunc = function(value) tcl.svChar.doAntiquHeader=value end,
			default = tcl.svCharDef.doAntiquHeader,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/journal/journal_tabicon_antiquities_up.dds",32,32).." missed cnt behind Antiquities nodes",
			getFunc = function() return tcl.svChar.showAntiqueSums end,
			setFunc = function(value) tcl.svChar.showAntiqueSums=value end,
			disabled= function() return not tcl.svChar.doAntiquities end,
			default = tcl.svCharDef.showAntiqueSums,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
			width   = "half",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/leaderboard_indexicon_challenge_up.dds",32,32).." DungeonQueue",
			getFunc = function() return tcl.svChar.doDungeonQueue end,
			setFunc = function(value) tcl.svChar.doDungeonQueue=value end,
			default = tcl.svCharDef.doDungeonQueue,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
			width   = "half",
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = zo_iconFormat("/esoui/art/tutorial/inventory_tabicon_crafting_up.dds",32,32).." CraftingReceipts",
			getFunc = function() return tcl.svChar.doBlueprints end,
			setFunc = function(value) tcl.svChar.doBlueprints=value end,
			default = tcl.svCharDef.doBlueprints,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "divider",
			alpha   = 0.4,
		}, -------------------------------------------
		{	type = "submenu",
			--name = string.format("%s %s",zo_iconFormat("/esoui/art/icons/dyestamp_tricolorbanner.dds",32,32),tcl.col_tim:Colorize("Colors")),
			name = string.format("%s %s",tcl.col_tim:Colorize(zo_iconFormatInheritColor("/esoui/art/dye/dyes_categoryicon_down.dds",40,40)),tcl.col_tim:Colorize("Colors")),
			controls = {
				{	type    = "description",
					text    = "|cc5c29e[Info] ui default color: 197-194-158|r",
				}, -------------------------------------------
				{	type    = "divider",
					alpha   = 0.4,
				}, -------------------------------------------
				{	type    = "description",
					title   = tcl.col_tim:Colorize("Lorebooks / SetCollection / Achievements / Antiquities"),
					text    = "",
				}, -------------------------------------------
				{	type    = "colorpicker",
					name    = "Color 'completed'", --#66ff66
					getFunc = function() return tcl.ConvertHexToRGB(tcl.svChar.colorDone) end,
					setFunc = function(r,g,b) tcl.svChar.colorDone = tcl.ConvertRGBToHex(r,g,b) end,
					width   = "half",
					default = ZO_ColorDef:New(tcl.svCharDef.colorDone),
					requiresReload = true,
				}, -------------------------------------------
				{	type    = "colorpicker",
					name    = "Color 'open'", --#ff6666
					getFunc = function() return tcl.ConvertHexToRGB(tcl.svChar.colorOpen) end,
					setFunc = function(r,g,b) tcl.svChar.colorOpen = tcl.ConvertRGBToHex(r,g,b) end,
					width   = "half",
					default = ZO_ColorDef:New(tcl.svCharDef.colorOpen),
					requiresReload = true,
				}, -------------------------------------------
				{	type    = "divider",
					alpha   = 0.4,
				}, -------------------------------------------
				{	type    = "description",
					title   = tcl.col_tim:Colorize("DungeonQueue"),
					text    = "",
				}, -------------------------------------------
				{	type    = "colorpicker",
					name    = "Color 'selected'", --#9B30FF
					getFunc = function() return tcl.ConvertHexToRGB(tcl.svChar.colorQueue) end,
					setFunc = function(r,g,b) tcl.svChar.colorQueue = tcl.ConvertRGBToHex(r,g,b) end,
					width   = "half",
					default = ZO_ColorDef:New(tcl.svCharDef.colorQueue),
					requiresReload = true,
				}, -------------------------------------------
			},
		},
	}
	LAM2:RegisterOptionControls("tim99sColoredLists", optionsData)
end
