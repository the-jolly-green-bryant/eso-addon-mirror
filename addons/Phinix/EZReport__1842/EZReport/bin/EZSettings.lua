local EZReport = _G['EZReport']
local L = EZReport:GetLanguage()
local pTC = EZReport.TColor

------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Addon Settings
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.CreateSettingsWindow()
	local panelData = {
		type					= "panel",
		name					= "EZReport",
		displayName				= pTC("ffffff", "EZ")..pTC("66ccff", "Report"),
		author					= pTC("66ccff", "Phinix"),
		version					= '1.29',
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
------------------------------------------------------------------------------------------------------------------------------------
-- General Settings
------------------------------------------------------------------------------------------------------------------------------------
	{
		type			= "header",
		name			= ZO_HIGHLIGHT_TEXT:Colorize(L.EZReport_GOpts),
	},
	{
		type			= "checkbox",
		name			= L.EZReport_TIcon,
		tooltip			= L.EZReport_TIconT,
		getFunc			= function() return EZReport.ASV.sVars.targetIcon end,
		setFunc			= function(value) EZReport.ASV.sVars.targetIcon = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.targetIcon,
	},
	{
		type			= "checkbox",
		name			= L.EZReport_DTime,
		tooltip			= L.EZReport_DTimeT,
		getFunc			= function() return EZReport.ASV.sVars.targetDS end,
		setFunc			= function(value) EZReport.ASV.sVars.targetDS = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.targetDS,
		disabled		= function() return not EZReport.ASV.sVars.targetIcon end,
	},
	{
		type			= "checkbox",
		name			= L.EZReport_RCooldown,
		tooltip			= L.EZReport_RCooldownT,
		getFunc			= function() return EZReport.ASV.sVars.rCDown end,
		setFunc			= function(value) EZReport.ASV.sVars.rCDown = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.rCDown,
	},
	{
		type			= "checkbox",
		name			= L.EZReport_OutputChat,
		tooltip			= L.EZReport_OutputChatT,
		getFunc			= function() return EZReport.ASV.sVars.outputChat end,
		setFunc			= function(value) EZReport.ASV.sVars.outputChat = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.outputChat,
	},
	{
		type			= "checkbox",
		name			= L.EZReport_12HourFormat,
		tooltip			= L.EZReport_12HourFormatT,
		getFunc			= function() return EZReport.ASV.sVars.dt12 end,
		setFunc			= function(value) EZReport.ASV.sVars.dt12 = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.dt12,
	},
	{
		type			= "checkbox",
		name			= L.EZReport_IncPrev,
		tooltip			= L.EZReport_IncPrevT,
		getFunc			= function() return EZReport.ASV.sVars.pReports end,
		setFunc			= function(value) EZReport.ASV.sVars.pReports = value end,
		width			= "full",
		default			= EZReport.Defaults.sVars.pReports,
	},
--	{
--		type			= 'dropdown',
--		name			= L.EZReport_DCategory,
--		tooltip			= L.EZReport_DCategoryT,
--		choices			= EZReport.categoryList,
--		getFunc			= function() return EZReport.categoryList[EZReport.ASV.sVars.dCategory] end,
--		setFunc			= function(selected)
--							for k,v in ipairs(EZReport.categoryList) do
--								if v == selected then
--									EZReport.ASV.sVars.dCategory = k
--									break
--								end
--							end
--							HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectSubcategory(EZReport.ASV.sVars.dCategory)
--						end,
--		default			= EZReport.Defaults.sVars.dCategory,
--	},
	{
		type			= 'dropdown',
		name			= L.EZReport_DReason,
		tooltip			= L.EZReport_DReasonT,
		choices			= EZReport.reasonList,
		getFunc			= function() return EZReport.reasonList[EZReport.ASV.sVars.dReason] end,
		setFunc			= function(selected)
							for k,v in ipairs(EZReport.reasonList) do
								if v == selected then
									EZReport.ASV.sVars.dReason = k
									break
								end
							end
							EZReport.GetTargetInfo(nil, true)
						end,
		default			= EZReport.Defaults.sVars.dReason,
	},
------------------------------------------------------------------------------------------------------------------------------------
-- Color Settings
------------------------------------------------------------------------------------------------------------------------------------
	{
		type			= 'submenu',
		name			= ZO_HIGHLIGHT_TEXT:Colorize(L.EZReport_RColorS),
		tooltip			= "",
		controls		= {
						[1] = 	{
							type			= "colorpicker",
							name			= L.EZReport_RColor1,
							tooltip			= L.EZReport_RColor1T,
							getFunc			= function()
												local color = EZReport.ASV.rColor[0].color
												local cRGB = {color.r, color.g, color.b, color.a}
												return unpack(cRGB)
											end,
							setFunc			= function(r,g,b,a)
												local color = {r=r,g=g,b=b,a=a}
												EZReport.ASV.rColor[0].color = color
											end,
							width			= "full",
							default			= EZReport.Defaults.rColor[0].color,
						},
						[2] = 	{
							type			= "colorpicker",
							name			= L.EZReport_RColor2,
							tooltip			= L.EZReport_RColor2T,
							getFunc			= function()
												local color = EZReport.ASV.rColor[1].color
												local cRGB = {color.r, color.g, color.b, color.a}
												return unpack(cRGB)
											end,
							setFunc			= function(r,g,b,a)
												local color = {r=r,g=g,b=b,a=a}
												EZReport.ASV.rColor[1].color = color
											end,
							width			= "full",
							default			= EZReport.Defaults.rColor[1].color,
						},
						[3] = 	{
							type			= "colorpicker",
							name			= L.EZReport_RColor3,
							tooltip			= L.EZReport_RColor3T,
							getFunc			= function()
												local color = EZReport.ASV.rColor[2].color
												local cRGB = {color.r, color.g, color.b, color.a}
												return unpack(cRGB)
											end,
							setFunc			= function(r,g,b,a)
												local color = {r=r,g=g,b=b,a=a}
												EZReport.ASV.rColor[2].color = color
											end,
							width			= "full",
							default			= EZReport.Defaults.rColor[2].color,
						},
						[4] = 	{
							type			= "colorpicker",
							name			= L.EZReport_RColor4,
							tooltip			= L.EZReport_RColor4T,
							getFunc			= function()
												local color = EZReport.ASV.rColor[3].color
												local cRGB = {color.r, color.g, color.b, color.a}
												return unpack(cRGB)
											end,
							setFunc			= function(r,g,b,a)
												local color = {r=r,g=g,b=b,a=a}
												EZReport.ASV.rColor[3].color = color
											end,
							width			= "full",
							default			= EZReport.Defaults.rColor[3].color,
						},
						[5] = 	{
							type			= "colorpicker",
							name			= L.EZReport_RColor5,
							tooltip			= L.EZReport_RColor5T,
							getFunc			= function()
												local color = EZReport.ASV.rColor[4].color
												local cRGB = {color.r, color.g, color.b, color.a}
												return unpack(cRGB)
											end,
							setFunc			= function(r,g,b,a)
												local color = {r=r,g=g,b=b,a=a}
												EZReport.ASV.rColor[4].color = color
											end,
							width			= "full",
							default			= EZReport.Defaults.rColor[4].color,
						},
		},
	},
------------------------------------------------------------------------------------------------------------------------------------
-- Reset Database
------------------------------------------------------------------------------------------------------------------------------------
	{
		type			= 'submenu',
		name			= ZO_HIGHLIGHT_TEXT:Colorize(L.EZReport_Reset),
		tooltip			= "",
		controls		= {
						[1] = 	{
							type			= 'description',
							text			= L.EZReport_ResetT,
							width			= "half",
						},
						[2] = 	{
							type			= "button",
							name			= L.EZReport_Clear,
							width			= "half",
							func			= function()
												EZReport.ASV.accountDB={}
												EZReport.ASV.characterDB={}
												if (EZReport.ASV.sVars.outputChat) then
													d(L.EZReport_ResetM)
												end
											end,
						},
		},
	},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("EZReport_Panel", panelData)
	LAM:RegisterOptionControls("EZReport_Panel", optionsData)
end
