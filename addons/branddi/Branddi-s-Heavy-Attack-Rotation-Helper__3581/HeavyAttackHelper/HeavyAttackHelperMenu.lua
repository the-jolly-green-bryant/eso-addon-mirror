

HeavyAttackHelper = HeavyAttackHelper or { }
local HeavyAttackHelper = HeavyAttackHelper




local sounds = {
    "Justice_PickpocketFailed",
    "Dialog_Decline",
    "Ability_Ultimate_Ready_Sound",
    "Quest_Shared",
    "Champion_PointsCommitted",
    "GroupElection_Requestewdd",
    "Duel_Boundary_Warning",
}

function HeavyAttackHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Branddi's Heavy Attack Helper",
		--displayName = "|cFFD700"..HeavyAttackHelper.name.."|r",
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Heavy Attack Helper",
		author = "Branddi",

		website = "https://www.esoui.com/downloads/info3581-HeavyAttackRotationHelper.html",
        feedback = "https://www.esoui.com/downloads/info3581-HeavyAttackRotationHelper.html#comments",

		version = ""..HeavyAttackHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(HeavyAttackHelper.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Documentation available at website listed above"
		},



		{
			type = "header",
			name = "Positioning"
		},



		{
			type = "checkbox",
			name = "Medium attack warnings",
			tooltip = "Provides an indication if your heavy attack was not completed, this can happen for many reasons including blocking, dodge, stun, stopping the heavy",
			getFunc = function() return HeavyAttackHelper.savedVars.mediumAttackWarning end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.mediumAttackWarning = false
				else
					HeavyAttackHelper.savedVars.mediumAttackWarning = true
				end
			end
		},



		{
			type = "checkbox",
			name = "No Skills warning",
			tooltip = "Warning when the addon  has no skills to suggest.  This might happen because you don't have enough short duration DOTs, semi-spammable, or spammable",
			getFunc = function() return HeavyAttackHelper.savedVars.noSkillsWarning end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.noSkillsWarning = false
				else
					HeavyAttackHelper.savedVars.noSkillsWarning = true
				end
			end
		},




		{
			type = "checkbox",
			name = "Yellow dot for DOTs/HOTs ready for cast",
			tooltip = "Show Yellow dot above HOTs or DOTs that are ready for casting",
			getFunc = function() return HeavyAttackHelper.savedVars.showYellowforOffCooldownSkills end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.showYellowforOffCooldownSkills = false
				else
					HeavyAttackHelper.savedVars.showYellowforOffCooldownSkills = true
				end
			end
		},


		{
			type = "checkbox",
			name = "Use small icons",
			tooltip = "Lower profile icons above skills",
			getFunc = function() return HeavyAttackHelper.savedVars.smallIcons end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.smallIcons = false
				else
					HeavyAttackHelper.savedVars.smallIcons = true
				end
			end
		},












		{
			type = "checkbox",
			name = "Compatability with Fancy Action Bar",
			tooltip = "Detect if Bandits is used for UI",
			getFunc = function() return HeavyAttackHelper.savedVars.compatibilityDetectFAB end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.compatibilityDetectFAB = false
				else
					HeavyAttackHelper.savedVars.compatibilityDetectFAB = true
				end
			end
		},



        --[[]


		{
			type = "slider",
			name = "Width of arrows (52 is default)",
			getFunc = function() return HeavyAttackHelper.savedVars.arrowWidth end,
			setFunc = function(value)
						HeavyAttackHelper.savedVars.arrowWidth = value
						HeavyAttackHelper.adjustFrameLocation()
					  end,
			min = 52,
			max = 128,
			step = 1,
			default = 52,
			--requiresReload = true,
			tooltip = "Used to help with alignment issues",
		},


		{
			type = "slider",
			name = "Y Offset of arrows (0 is default)",
			getFunc = function() return HeavyAttackHelper.savedVars.arrowYOffset end,
			setFunc = function(value)
						HeavyAttackHelper.savedVars.arrowYOffset = value
						HeavyAttackHelper.adjustFrameLocation()
					  end,
			min = 0,
			max = 64,
			step = 1,
			default = 0,
			--requiresReload = true,
			tooltip = "Used to help with alignment issues",
		},





    --]]

--[[

        {
            type = "header",
            name = "HA Timing Bar Position / Size",
        },



		{
			type = "checkbox",
			name = "Show Heavy Attack Timing bar",
			tooltip = "Bar to help with heavy attack skill cast timing",
			getFunc = function() return HeavyAttackHelper.savedVars.skillTimerBar end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.skillTimerBar = false
				else
					HeavyAttackHelper.savedVars.skillTimerBar = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Play sound as reminder to cast skill",
			tooltip = "Select the sound effect from next option",
			getFunc = function() return HeavyAttackHelper.savedVars.playSoundForNextSkillTime end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.playSoundForNextSkillTime = false
				else
					HeavyAttackHelper.savedVars.playSoundForNextSkillTime = true
				end
			end
		},


		{
            type = "dropdown",
            name = "Sound effect for cast skill reminder",
            choices = sounds,
            getFunc = function() return HeavyAttackHelper.savedVars.soundEffectCast end,
            setFunc = function(value)
                HeavyAttackHelper.savedVars.soundEffectCast = value
                PlaySound(value)
            end,
        },


        {
            type = "checkbox",
            name = "Unlock",
            tooltip = "Reposition / resize timing bar",
            getFunc = function() return HeavyAttackHelper.frame.IsUnlocked() end,
            setFunc = function(value)
                HeavyAttackHelper.frame:SetUnlocked(value)
            end,
        },

        {
            type = "slider",
            name = "X Offset",
            min = 0,
            max = math.floor(GuiRoot:GetWidth() - HeavyAttackHelper.savedVars.width),
            step = 1,
            getFunc = function() return HeavyAttackHelper.savedVars.xOffset end,
            setFunc = function(value) 
                HeavyAttackHelper.savedVars.xOffset = value 
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "button",
            name = "Center Horizontally",
            func = function()
                HeavyAttackHelper.savedVars.xOffset = math.floor((GuiRoot:GetWidth() - HeavyAttackHelper.savedVars.width) / 2)
                HeavyAttackHelper.BuildUI()
            end
        },
        {
            type = "slider",
            name = "Y Offset",
            min = 0,
            max = math.floor(GuiRoot:GetHeight() - HeavyAttackHelper.savedVars.height),
            step = 1,
            getFunc = function() return HeavyAttackHelper.savedVars.yOffset end,
            setFunc = function(value) 
                HeavyAttackHelper.savedVars.yOffset = value 
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "button",
            name = "Center Vertically",
            func = function()
                HeavyAttackHelper.savedVars.yOffset = math.floor((GuiRoot:GetHeight() - HeavyAttackHelper.savedVars.height) / 2)
                HeavyAttackHelper.BuildUI()
            end
        },
        {
            type = "slider",
            name = "Width",
            min = HeavyAttackHelper.MIN_WIDTH,
            max = HeavyAttackHelper.MAX_WIDTH,
            step = 1,
            getFunc = function() return HeavyAttackHelper.savedVars.width end,
            setFunc = function(value) 
                HeavyAttackHelper.savedVars.width = value 
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "slider",
            name = "Height",
            min = HeavyAttackHelper.MIN_HEIGHT,
            max = HeavyAttackHelper.MAX_HEIGHT,
            step = 1,
            getFunc = function() return HeavyAttackHelper.savedVars.height end,
            setFunc = function(value) 
                HeavyAttackHelper.savedVars.height = value 
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "header",
            name = "Timing Bar  Colour / Layout",
        },
        {
            type = "colorpicker",
            name = "Background Colour",
            tooltip = "Colour of the bar background",
            getFunc = function() return unpack(HeavyAttackHelper.savedVars.backgroundColour) end,
            setFunc = function(r, g, b, a)
                HeavyAttackHelper.savedVars.backgroundColour = {r, g, b, a}
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "colorpicker",
            name = "Heavy Attack Colour",
            tooltip = "Colour of the heavy attack bar",
            getFunc = function() return unpack(HeavyAttackHelper.savedVars.progressColour) end,
            setFunc = function(r, g, b, a)
                HeavyAttackHelper.savedVars.progressColour = {r, g, b, a}
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "colorpicker",
            name = "Cast Colour",
            tooltip = "Colour of the cast zone",
            getFunc = function() return unpack(HeavyAttackHelper.savedVars.pingColour) end,
            setFunc = function(r, g, b, a)
                HeavyAttackHelper.savedVars.pingColour = {r, g, b, a}
                HeavyAttackHelper.BuildUI()
            end,
        },
        {
            type = "dropdown",
            name = "Alignment",
            tooltip = "Alignment of the progress bar",
            choices = {"Left", "Center", "Right"},
            getFunc = function() return HeavyAttackHelper.savedVars.align end,
            setFunc = function(value)
                HeavyAttackHelper.savedVars.align = value
                HeavyAttackHelper.BuildUI()
            end,
        },



--]]






	}

	if HeavyAttackHelper.savedVars.extraFeatures then

        table.insert (options,
                {
                    type = "header",
                    name = "Development Only"
                }
        )






		table.insert (options,

		{
			type = "checkbox",
			name = "Debug Skill detection to Chat",
			tooltip = "Used to debug skill detection",
			getFunc = function() return HeavyAttackHelper.savedVars.debugCombatEventSkillDetection end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.debugCombatEventSkillDetection = false
				else
					HeavyAttackHelper.savedVars.debugCombatEventSkillDetection = true
				end
			end
		}
		)




		table.insert (options,

		{
			type = "checkbox",
			name = "Debug Fully Charged Heavy Attack in Chat",
			tooltip = "Used to debug heavy attacks",
			getFunc = function() return HeavyAttackHelper.savedVars.debugHeavyAttackDetection end,
			setFunc = function(value)
				if not value then
					HeavyAttackHelper.savedVars.debugHeavyAttackDetection = false
				else
					HeavyAttackHelper.savedVars.debugHeavyAttackDetection = true
				end
			end
		}
		)

	else
	    HeavyAttackHelper.savedVars.debugCombatEventSkillDetection = false
	    HeavyAttackHelper.savedVars.showXforDisabledSkills = false
        HeavyAttackHelper.savedVars.preventCastingOfNonOptimalSkill = false
	end

	LAM:RegisterOptionControls(HeavyAttackHelper.name.."Options", options)
end
