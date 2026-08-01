CoralAerieHelper = CoralAerieHelper or { }
local CoralAerieHelper = CoralAerieHelper
local sounds = {
    "Justice_PickpocketFailed",
    "Dialog_Decline",
    "Ability_Ultimate_Ready_Sound",
    "Quest_Shared",
    "Champion_PointsCommitted",
    "GroupElection_Requested",
    "Duel_Boundary_Warning",
}

function CoralAerieHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = CoralAerieHelper.name,
		displayName = "|cFFD700"..CoralAerieHelper.name.."|r",
		author = "Branddi",
		version = ""..CoralAerieHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(CoralAerieHelper.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(CoralAerieHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					CoralAerieHelperFrame:SetHidden(false)
					CoralAerieHelperFrame:SetMovable(true)
					CoralAerieHelperFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(CoralAerieHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, CoralAerieHelper.hideFrame)
					CoralAerieHelperFrame:SetHidden(false)
					CoralAerieHelperFrame:SetMovable(false)
					CoralAerieHelperFrame:SetMouseEnabled(false)
				end
			end
		},




		{
			type = "checkbox",
			name = "Enable Purge Sound Effect",
			tooltip = "Use purge sound effect?",
			getFunc = function() return CoralAerieHelper.savedVars.enablePurgeSoundEffect end,
			setFunc = function(value)
				if not value then
					CoralAerieHelper.savedVars.enablePurgeSoundEffect = false
				else
					CoralAerieHelper.savedVars.enablePurgeSoundEffect = true
				end
			end
		},

		{
            type = "dropdown",
            name = "Purge required sound effect",
            choices = sounds,
            getFunc = function() return CoralAerieHelper.savedVars.soundEffectPurge end,
            setFunc = function(value)
                CoralAerieHelper.savedVars.soundEffectPurge = value
                PlaySound(value)
            end,
        },


		{
			type = "checkbox",
			name = "Enable Dagger Storm Sound Effect",
			tooltip = "Use dagger storm sound effect?",
			getFunc = function() return CoralAerieHelper.savedVars.enableStormSoundEffect end,
			setFunc = function(value)
				if not value then
					CoralAerieHelper.savedVars.enableStormSoundEffect = false
				else
					CoralAerieHelper.savedVars.enableStormSoundEffect = true
				end
			end
		},


		{
            type = "dropdown",
            name = "Dagger Storm sound effect",
            choices = sounds,
            getFunc = function() return CoralAerieHelper.savedVars.soundEffectStorm end,
            setFunc = function(value)
                CoralAerieHelper.savedVars.soundEffectStorm = value
                PlaySound(value)
            end,
        },



		{
			type = "checkbox",
			name = "Display 4 wave safe zones during Varallion fight",
			tooltip = "Display the 4 places that are always safe during waves",
			getFunc = function() return CoralAerieHelper.savedVars.waveZones end,
			setFunc = function(value)
				if not value then
					CoralAerieHelper.savedVars.waveZones = false
				else
					CoralAerieHelper.savedVars.waveZones = true
				end
			end
		},




	}

	LAM:RegisterOptionControls(CoralAerieHelper.name.."Options", options)
end
