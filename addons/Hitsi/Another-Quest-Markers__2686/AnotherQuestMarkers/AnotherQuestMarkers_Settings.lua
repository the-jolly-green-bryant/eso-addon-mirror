local AQM = AQM
AQM.LAM = LibAddonMenu2

local function getThemeFromTexture(path)
	local themes=AQM.themes
	local fullpath, file= string.match(path, "(.+)/([^/]+)")
	fullpath=fullpath.."/"
	for idx,val in pairs(themes) do
		if (val.textures_full and val.textures_full==fullpath) then
			return idx
		end
	end
	return "vanilla"
end

function AQM:CreateOptionsPanel(icon_themes)
	local SV = self.SV
	local Lng = self.i18n
	local c = self.const
	local paths = self.PATH
	local defaults = self.defaults
	local samples = self.samples
	local menuitems = self.menuitems
    local panelData = {
        type = "panel",
        name = AQM.Name,
        displayName = ZO_HIGHLIGHT_TEXT:Colorize(AQM.Name),
        author = "|c779cff@Hitsi|r [EU]",
        slashCommand = "/aqm",
		version = AQM.Version,
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsTable = {
        {
            type = "header",
            name = Lng.OptHdr,
            width = "full"
        },
        {
            type = "checkbox",
            name = Lng.ShowComp,
            tooltip = Lng.ShowCompTlp,
            default = defaults[show_on_compass],
            getFunc = function()
                return SV.show_on_compass
            end,
            setFunc = function(val)
                SV.show_on_compass = val
            end,
            width = "full",
            warning = Lng.LoadWarn
        },
        {
            type = "slider",
            name = Lng.MSize,
            tooltip = Lng.MSizeTlp,
            min = c.MinMSize,
            max = c.MaxMSize,
            step = c.StepMSize,
            getFunc = function()
                return SV.quest_marker_size
            end,
            setFunc = function(val)
                SV.quest_marker_size = val
                AQM.OnPlayerActivated()
            end,
            width = "full",
            default = defaults[quest_marker_size]
        },
    }
	
	for idx = 1, #menuitems do
		local choices={}
		local choicesTooltips={}
		local menuname=menuitems[idx]
		local var_name=menuname.."_theme"
		local sample=samples[menuname]
		local default=AQM.getPathFromTheme(defaults[var_name])..sample
		for i = 1, #icon_themes do
			choices[i]=AQM.getPathFromTheme(icon_themes[i].theme)..sample
			choicesTooltips[i]=icon_themes[i].tooltip
		end
		
		optionsTable[#optionsTable + 1] = {
            type = "iconpicker",
            name = Lng.headers[menuname],
            choices = choices,
            getFunc = function()
				return AQM.getPathFromTheme(SV[var_name])..sample
            end,
            setFunc = function(val)
                local selected = getThemeFromTexture(val)
				if SV[var_name] ~= selected then
					SV[var_name]=selected
					AQM.OnPlayerActivated()
				end
            end,
            tooltip = Lng.ThemeTlp,
            choicesTooltips = choicesTooltips,
            maxColumns = c.IconCol,
            visibleRows = c.IconRow,
            iconSize = c.IconSize,
            width = "full",
            beforeShow = function(control, iconPicker)
                return preventShow
            end,
            warning = Lng.LoadThemeWarn,
            default = default
        }
	end
    
    self.LAM:RegisterAddonPanel("AnotherQuestMarkers_Panel", panelData)
    self.LAM:RegisterOptionControls("AnotherQuestMarkers_Panel", optionsTable)
end