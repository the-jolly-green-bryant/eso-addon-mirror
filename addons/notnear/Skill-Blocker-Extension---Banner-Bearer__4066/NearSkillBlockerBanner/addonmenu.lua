local addon = Near_SkillBlockerBanner

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup LibAddonMenu2 panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Near_SkillBlockerBanner.SetupSettings()
	local LAM2 = LibAddonMenu2
	local sv = Near_SkillBlockerBanner.ASV
	local skilldata = Near_SkillBlockerBanner.skilldata

	local libSkillBlockUpdateNeeded = false

	local function UpdateVars()
		libSkillBlockUpdateNeeded = true
	end

	local function createButtons(ability)
		local sv_skilldata = sv.skilldata[ability]
		return {
			b_cast = {
				type = 'checkbox',
				name = GetString(NEARSBB_LAM_co_bcast_name),
				tooltip = GetString(NEARSBB_LAM_co_bcast_tooltip),
				getFunc = function() return sv_skilldata.block end,
				setFunc = function(v)
					sv_skilldata.block, sv_skilldata.msg.re_cast = v, true
					UpdateVars()
				end
			},
			b_inCombat = {
				type = 'checkbox',
				name = GetString(NEARSB_LAM_co_binCombat_name),
				tooltip = GetString(NEARSB_LAM_co_binCombat_tooltip),
				getFunc = function() return sv_skilldata.block_inCombat end,
				setFunc = function(v)
					sv_skilldata.block_inCombat, sv_skilldata.msg.re_cast = v, true
					UpdateVars()
				end
			},
			b_pvp = {
				type = 'checkbox',
				name = GetString(NEARSB_LAM_co_bpvp_name),
				tooltip = GetString(NEARSB_LAM_co_bpvp_tooltip),
				getFunc = function() return sv_skilldata.pvp end,
				setFunc = function(v)
					sv_skilldata.pvp, sv_skilldata.msg.pvp = v, true
					UpdateVars()
				end
			}
		}
	end

	local panelData = {
		type = 'panel',
		name = addon.title,
		displayName = addon.title,
		author = addon.author,
		version = addon.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	Near_SkillBlockerBanner.LAM2SettingsPanel = LAM2:RegisterAddonPanel(addon.name, panelData)
	local function OnLamPanelClosed(panel)
		if panel ~= Near_SkillBlockerBanner.LAM2SettingsPanel or not libSkillBlockUpdateNeeded then return end
		libSkillBlockUpdateNeeded = false
		addon.Initialize()
	end

	local optionsTable = {}

	for index, value in ipairs(skilldata) do
		local controls = createButtons(index)

		optionsTable[#optionsTable+1] = {
			type = 'header',
			name = value.name
		}

		optionsTable[#optionsTable+1] = controls.b_cast
		optionsTable[#optionsTable+1] = controls.b_inCombat
		optionsTable[#optionsTable+1] = controls.b_pvp

	end

	LAM2:RegisterOptionControls(addon.name, optionsTable)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", OnLamPanelClosed)
end
