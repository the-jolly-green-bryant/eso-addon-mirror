DsRGuildBeam = DsRGuildBeam or {}
DsRBeam = DsRGuildBeam

DsRBeam.name = "DsRGuildBeamMenu"

local MenuOptions,MenuPanel,MenuHandlers={},{},{}
local Settings,SettingsGetFunc,SettingsSetFunc,SettingsDisabled={},{},{},{}

Settings = {
    [1]  = {name="DsRGuildMenue_BeamAttention",description=true},
    [2]  = {name="DsRGuildBeam_LightEnabled",key="LightEnabled",default=false,warning="ReloadUiWarn",checkbox=true},
    [3]  = {name="DsRGuildBeam_LightAlpha",key="LightAlpha",default=100,warning=false,slider=true,maxvalue=100,minvalue=5,step=5,lomdefault=1},
    [4]  = {name="DsRGuildBeam_LightScale",key="LightScale",default=50,warning=false,slider=true,maxvalue=150,minvalue=10,step=5,lomdefault=0.75},
    [5]  = {name="DsRGuildBeam_LightAlwaysIgnoresDepthBuffer",key="LightAlwaysIgnoresDepthBuffer",default=false,warning=false,onChange=DsRBeam.EffectUI.UpdateObstaclePenetration,reference="DsRLightAlwaysIgnoresDepthBuffer",checkbox=true},
    [6]  = {name="DsRGuildBeam_LightCombatOnly",key="LightCombatOnly",default=false,warning=false,checkbox=true},
    [7]  = {name="DsRGuildBeam_LightOwn",key="Lightown",default=false,warning=false,checkbox=true},
    [8]  = {name="DsRGuildBeam_HeaderTWO",subheader=true},
    [9]  = {name="DsRGuildBeam_LightDead",key="LightDead",default=true,warning=false,checkbox=true},
    [10]  = {name="DsRGuildBeam_LightDeadColor",key="LightDeadColor",default={r=1,g=0,b=0.9},warning=false,colorpicker=true},
    [11] = {name="DsRGuildBeam_LightResurrecting",key="LightResurrecting",default=true,warning=false,checkbox=true},
    [12] = {name="DsRGuildBeam_LightDeadColor",key="LightResurrectingColor",default={r=1,g=0.75,b=0},warning=false,colorpicker=true},
    [13] = {name="DsRGuildBeam_HeaderTHREE",subheader=true},
    [14] = {name="DsRGuildBeam_HeaderTHREE_desc",description=true},
    [15] = {name="DsRGuildBeam_HighlightLeader",key="HighlightLeader",default=true,warning=false,checkbox=true},
    [16] = {name="DsRGuildBeam_LightDeadColor",key="HighlightLeaderColor",default={r=1,g=1,b=1},warning=false,colorpicker=true},
    [17] = {name="DsRGuildBeam_HighlightTanks",key="HighlightTanks",default=false,warning=false,checkbox=true},
    [18] = {name="DsRGuildBeam_LightDeadColor",key="HighlightTanksColor",default={r=1,g=0,b=0},warning=false,colorpicker=true},
    [19] = {name="DsRGuildBeam_HighlightHealers",key="HighlightHealers",default=false,warning=false,checkbox=true},
    [20] = {name="DsRGuildBeam_LightDeadColor",key="HighlightHealersColor",default={r=0,g=1,b=0},warning=false,colorpicker=true},
    [21] = {name="DsRGuildBeam_HighlightDDs",key="HighlightDDs",default=false,warning=false,checkbox=true},
    [22] = {name="DsRGuildBeam_LightDeadColor",key="HighlightDDsColor",default={r=0,g=0,b=1},warning=false,colorpicker=true},
    [23] = {name="DsRGuildBeam_HeaderFOUR",subheader=true},
    [24] = {name="DsRGuildBeam_LightBattlegroundTeam",key="LightBattlegroundTeam",default=true,warning=false,checkbox=true},
    [25] = {name="DsRGuildBeam_LightCyrodiilTeam",key="LightCyrodiilTeam",default=true,warning=false,checkbox=true},
    [26] = {name="DsRGuildBeam_LightImperialCityTeam",key="LightImperialCityTeam",default=true,warning=false,checkbox=true},
    [27] = {name="DsRGuildBeam_LightNonPVPTeam",key="LightNonPVPTeam",default=true,warning=false,checkbox=true},
    [28] = {name="DsRGuildBeam_LightRAIDTeam",key="LightRAIDTeam",default=false,warning=false,checkbox=true},
}

SettingsGetFunc = {
    [1]  = false,
    [2]  = false,
    [3]  = function() return 100 * ( DsRBeam.GetSetting( "LightAlpha" ) or 1 ) end,
    [4]  = function() return 100 * ( DsRBeam.GetSetting( "LightScale" ) or 1 ) end,
    [5]  = function() return DsRBeam.GetSetting( "LightAlwaysIgnoresDepthBuffer" ) end,
    [6]  = false,
    [7]  = function() return DsRBeam.GetSetting( "Lightown" ) end,
    [8]  = false,
    [9]  = false,
    [10]  = function() local c = DsRBeam.GetColorSetting( "LightDeadColor" ) if c then return c.r, c.g, c.b end end,
    [11] = false,
    [12] = function() local c = DsRBeam.GetColorSetting( "LightResurrectingColor" ) if c then return c.r, c.g, c.b end end,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = function() local c = DsRBeam.GetColorSetting( "HighlightLeaderColor" ) if c then return c.r, c.g, c.b end end,
    [17] = false,
    [18] = function() local c = DsRBeam.GetColorSetting( "HighlightTanksColor" ) if c then return c.r, c.g, c.b end end,
    [19] = false,
    [20] = function() local c = DsRBeam.GetColorSetting( "HighlightHealersColor" ) if c then return c.r, c.g, c.b end end,
    [21] = false,
    [22] = function() local c = DsRBeam.GetColorSetting( "HighlightDDsColor" ) if c then return c.r, c.g, c.b end end,
    [23] = false,
    [24] = false,
    [25] = false,
    [26] = false,
    [27] = false,
    [28] = false,
}

SettingsSetFunc = {
    [1]  = false,
    [2]  = function(value) DsRBeam.SetSetting( "LightEnabled", value ) DsR.UI.ReloadUIButton() end,
    [3]  = function(value) DsRBeam.SetSetting( "LightAlpha", value / 100 ) end,
    [4]  = function(value) DsRBeam.SetSetting( "LightScale", value / 100 ) end,
    [5]  = function(value) DsRBeam.SetSetting( "LightAlwaysIgnoresDepthBuffer", value ) end,
    [6]  = false,
    [7]  = function(value) DsRBeam.SetSetting( "Lightown", value ) end,
    [8]  = false,
    [9]  = false,
    [10]  = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "LightDeadColor", { r = vr, g = vg, b = vb } ) end,
    [11] = false,
    [12] = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "LightResurrectingColor", { r = vr, g = vg, b = vb } ) end,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "HighlightLeaderColor", { r = vr, g = vg, b = vb } ) end,
    [17] = false,
    [18] = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "HighlightTanksColor", { r = vr, g = vg, b = vb } ) end,
    [19] = false,
    [20] = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "HighlightHealersColor", { r = vr, g = vg, b = vb } ) end,
    [21] = false,
    [22] = function( vr, vg, vb, va ) DsRBeam.SetColorSetting( "HighlightDDsColor", { r = vr, g = vg, b = vb } ) end,
    [23] = false,
    [24] = false,
    [25] = false,
    [26] = false,
    [27] = false,
    [28] = false,
}

function DsRBeam.Menu_Init()
    local DsRMenu=DsR and DsR.InternalMenu
	local Panel={
		type        = "panel",
		name        = (DsRMenu and "|c9fb6cd8.|r |t32:32:/esoui/art/icons/u38_housing_meridialights.dds|t" or "")..DsR.Localization[DsR.language].DsRGuildMenue_beams,
		displayName = (DsRMenu and "|c9fb6cd8.|r |t32:32:/esoui/art/icons/u38_housing_meridialights.dds|t" or "")..DsR.Localization[DsR.language].DsRGuildMenue_beams,
		author      = "|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
		}
	local MenuOptions={}
	local index=0
	for i,data in pairs(Settings) do
		index=index+1
		local _name    = data.name
		local _tip     = DsR.Localization[DsR.language][data.name.."Desc"] or nil

        if data.header then
			MenuOptions[index]=
			{	type = "header",
				name = _name,
			}
        elseif data.subheader then
			MenuOptions[index]=
			{	type = "subheader",
				name = _name,
			}
        elseif data.description then
			MenuOptions[index]=
			{	type = "description",
				name = _name,
			}
        elseif data.attention then
			MenuOptions[index]=
			{	type = "attention",
				name = _name,
			}
		elseif data.slider then
			MenuOptions[index]=
			{	type		= "slider",
				name		= _name,
				tooltip	    = _tip,
                key         = data.key,
				min		    = data.minvalue,
				max		    = data.maxvalue,
				step		= data.step,
                lomdefault  = data.lomdefault,
				getFunc	    = SettingsGetFunc[index],
				setFunc	    = SettingsSetFunc[index],
				default	    = data.default,
                warning     = data.warning,
			}
		elseif data.dropdown then
			MenuOptions[index]=
			{	type		= "dropdown",
				name		= _name,
				tooltip	    = _tip,
                key         = data.key,
				choices	    = data.choices,
				getFunc	    = SettingsGetFunc[index],
				setFunc	    = SettingsSetFunc[index],
				default	    = data.default,
                warning     = data.warning,
			}
		elseif data.button then
			MenuOptions[index]=
			{	type	= "button",
				name	= _name,
				tooltip	= _tip,
                key     = data.key,
				func	= data.func,
                warning = data.warning,
			}
		elseif data.checkbox then
            if data.name == "DsRGuildBeam_LightEnabled" then
                MenuOptions[index]=
                {	type		= "checkbox",
                    name		= _name,
                    tooltip	    = _tip,
                    key         = data.key,
                    onChange    = data.onChange,
                    getFunc	    = SettingsGetFunc[index],
                    setFunc	    = function(value) DsRBeam.SetSetting( "LightEnabled", value ) DsR.UI.ReloadUIButton() end,
                    default	    = data.default,
                    reference   = data.reference,
                    warning     = data.warning,
                }
            elseif data.name == "DsRGuildBeam_LightAlwaysIgnoresDepthBuffer" then
                MenuOptions[index]=
                {	type		= "checkbox",
                    name		= _name,
                    tooltip	    = _tip,
                    key         = data.key,
                    onChange    = data.onChange,
                    getFunc	    = SettingsGetFunc[index],
                    setFunc	    = SettingsSetFunc[index],
                    default	    = data.default,
                    reference   = data.reference,
                    warning     = data.warning,
                }
            else
                MenuOptions[index]=
                {	type		= "checkbox",
                    name		= _name,
                    tooltip	    = _tip,
                    key         = data.key,
                    getFunc	    = SettingsGetFunc[index],
                    setFunc	    = SettingsSetFunc[index],
                    default	    = data.default,
                    warning     = data.warning,
                }
            end
		elseif data.editbox then
			MenuOptions[index]=
			{	type		= "editbox",
				name		= _name,
				tooltip	    = _tip,
                key         = data.key,
				getFunc	    = SettingsGetFunc[index],
				setFunc	    = SettingsSetFunc[index],
				default	    = data.default,
                warning     = data.warning,
			}
		elseif data.colorpicker then
			MenuOptions[index]=
			{	type		= "colorpicker",
				name		= _name,
				tooltip	    = _tip,
                key         = data.key,
				getFunc	    = SettingsGetFunc[index],
				setFunc	    = SettingsSetFunc[index],
				default	    = data.default,
                warning     = data.warning,
			}
        end
	    for index, opt in ipairs( MenuOptions ) do
	    	if "string" == type( opt.key ) then
	    		if nil ~= opt.default then
	    			DsRBeam.SetDefaultSetting( opt.key, nil ~= opt.lomDefault and opt.lomDefault or opt.default )
	    		end

	    		if not opt.getFunc then
	    			opt.getFunc = function()
	    				return DsRBeam.GetSetting( opt.key )
	    			end
	    		end

	    		if not opt.setFunc then
	    			opt.setFunc = function(value)
	    				DsRBeam.SetSetting( opt.key, value )

	    				if opt.onChange then
	    					opt.onChange(value)
	    				end
	    			end
	    		end
	    	end
        end
	end
	DsR.Menu.RegisterPanel("DsRBeamPanel_Menu_1",Panel)
	DsR.Menu.RegisterOptions("DsRBeamPanel_Menu_1", MenuOptions)
end
