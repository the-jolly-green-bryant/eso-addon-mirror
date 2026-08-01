UnchainedHelper = UnchainedHelper or { }
local UnchainedHelper = UnchainedHelper
local sounds = {
    "No Sound Effect",
    "Justice_PickpocketFailed",
    "Dialog_Decline",
    "Ability_Ultimate_Ready_Sound",
    "Quest_Shared",
    "Champion_PointsCommitted",
    "GroupElection_Requested",
    "Duel_Boundary_Warning",
}

local spawnColors = {
	"red",
	"green",
	"blue",
	"aqua",
	"yellow",
	"white",
}

local spawnPortalColors = {
	"red",
	"green",
	"blue",
	"aqua",
	"yellow",
	"white",
	"portal",
}


function UnchainedHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Unchained Helper",
		displayName = "|cFFD700Unchained Helper|r",
		author = "Branddi",
		version = ""..UnchainedHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(UnchainedHelper.name.."Options", panelData)

	local options = {


		{
			type = "header",
			name = "Wave Times"
		},



		{
			type = "slider",
			name = "Remove Makers after (seconds)",
			tooltip = "Time after spawn to remove markers",
			min = 2,
			max = 10,
			getFunc = function() return UnchainedHelper.savedVars.removeMarkerSeconds end,
			setFunc = function(value)
				UnchainedHelper.savedVars.removeMarkerSeconds = value
			end
		},

		{
			type = "slider",
			name = "Time to display next wave of markers (seconds)",
			tooltip = "Time after removing markers from above, time until displaying next wave of markers",
			min = 2,
			max = 30,
			getFunc = function() return UnchainedHelper.savedVars.nextMarkerSeconds end,
			setFunc = function(value)
				UnchainedHelper.savedVars.nextMarkerSeconds = value
			end
		},

		{
			type = "header",
			name = "Chat Window"
		},


		{
			type = "checkbox",
			name = "Waves",
			tooltip = "Show wave numbers in chat window?",
			getFunc = function() return UnchainedHelper.savedVars.wavesInChat end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.wavesInChat = false
				else
					UnchainedHelper.savedVars.wavesInChat = true
				end
			end
		},

	    {
			type = "checkbox",
			name = "Tank Hints",
			tooltip = "Show tank hints chat window?",
			getFunc = function() return UnchainedHelper.savedVars.tankHints end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.tankHints = false
				else
					UnchainedHelper.savedVars.tankHints = true
				end
			end
		},
	    {
			type = "checkbox",
			name = "DPS Hints",
			tooltip = "Show DPS hints chat window?",
			getFunc = function() return UnchainedHelper.savedVars.dpsHints end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.dpsHints = false
				else
					UnchainedHelper.savedVars.dpsHints = true
				end
			end
		},

	    {
			type = "checkbox",
			name = "Healer Hints",
			tooltip = "Show Healer hints chat window?",
			getFunc = function() return UnchainedHelper.savedVars.healerHints end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.healerHints = false
				else
					UnchainedHelper.savedVars.healerHints = true
				end
			end
		},


	    {
			type = "checkbox",
			name = "Arena 1 Hints",
			tooltip = "Show Arena 1 hints chat window? If off, no hints for arena 1 will be displayed regardless or previous answers",
			getFunc = function() return UnchainedHelper.savedVars.hintsInChatArena1 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.hintsInChatArena1 = false
				else
					UnchainedHelper.savedVars.hintsInChatArena1 = true
				end
			end
		},


	    {
			type = "checkbox",
			name = "Arena 2 Hints",
			tooltip = "Show Arena 2 hints chat window? If off, no hints for arena 2 will be displayed regardless or previous answers",
			getFunc = function() return UnchainedHelper.savedVars.hintsInChatArena2 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.hintsInChatArena2 = false
				else
					UnchainedHelper.savedVars.hintsInChatArena2 = true
				end
			end
		},


	    {
			type = "checkbox",
			name = "Arena 3 Hints",
			tooltip = "Show Arena 3 hints chat window? If off, no hints for arena 3 will be displayed regardless or previous answers",
			getFunc = function() return UnchainedHelper.savedVars.hintsInChatArena3 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.hintsInChatArena3 = false
				else
					UnchainedHelper.savedVars.hintsInChatArena3 = true
				end
			end
		},


	    {
			type = "checkbox",
			name = "Arena 4 Hints",
			tooltip = "Show Arena 4 hints chat window? If off, no hints for arena 4 will be displayed regardless or previous answers",
			getFunc = function() return UnchainedHelper.savedVars.hintsInChatArena4 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.hintsInChatArena4 = false
				else
					UnchainedHelper.savedVars.hintsInChatArena4 = true
				end
			end
		},


	    {
			type = "checkbox",
			name = "Arena 5 Hints",
			tooltip = "Show Arena 5 hints chat window? If off, no hints for arena 5 will be displayed regardless or previous answers",
			getFunc = function() return UnchainedHelper.savedVars.hintsInChatArena5 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.hintsInChatArena5 = false
				else
					UnchainedHelper.savedVars.hintsInChatArena5 = true
				end
			end
		},

		{
			type = "header",
			name = "Player Positions"
		},

		{
			type = "checkbox",
			name = "Tank",
			tooltip = "Show tanks pecific positions",
			getFunc = function() return UnchainedHelper.savedVars.tankPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.tankPosition = false
				else
					UnchainedHelper.savedVars.tankPosition = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Group",
			tooltip = "Show group positions (usually 1 position for tank, dps, healer)",
			getFunc = function() return UnchainedHelper.savedVars.dpsPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.dpsPosition = false
				else
					UnchainedHelper.savedVars.dpsPosition = true
				end
			end
		},





		{
			type = "header",
			name = "Mob Spawns"
		},

		{
			type = "checkbox",
			name = "Boss",
			tooltip = "Show boss spawn locations",
			getFunc = function() return UnchainedHelper.savedVars.bossPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.bossPosition = false
				else
					UnchainedHelper.savedVars.bossPosition = true
				end
			end
		},
		{
			type = "checkbox",
			name = "Elite",
			tooltip = "Show mini/elite spawn locations",
			getFunc = function() return UnchainedHelper.savedVars.miniPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.miniPosition = false
				else
					UnchainedHelper.savedVars.miniPosition = true
				end
			end
		},


		{
            type = "dropdown",
            name = "Boss and Elite Color",
            tooltip = "Color used for bosses and non-chainable elite adds",
            choices = spawnColors,
            getFunc = function() return UnchainedHelper.savedVars.bossColor end,
            setFunc = function(value)
                UnchainedHelper.savedVars.bossColor = value
            end,
        },




		{
			type = "checkbox",
			name = "No Chain",
			tooltip = "Show mob spawn for which you likely don't need to chain",
			getFunc = function() return UnchainedHelper.savedVars.nonchainAddsPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.nonchainAddsPosition = false
				else
					UnchainedHelper.savedVars.nonchainAddsPosition = true
				end
			end
		},


		{
            type = "dropdown",
            name = "No Chain Color",
            tooltip = "Color used for melee type chainable adds",
            choices = spawnColors,
            getFunc = function() return UnchainedHelper.savedVars.nochainColor end,
            setFunc = function(value)
                UnchainedHelper.savedVars.nochainColor = value
            end,
        },


		{
			type = "checkbox",
			name = "Chain",
			tooltip = "Show mob spawn for which you likely need to chain",
			getFunc = function() return UnchainedHelper.savedVars.chainAddsPosition end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.chainAddsPosition = false
				else
					UnchainedHelper.savedVars.chainAddsPosition = true
				end
			end
		},


		{
            type = "dropdown",
            name = "Chain Color",
            tooltip = "Color used for range type chainable adds",
            choices = spawnColors,
            getFunc = function() return UnchainedHelper.savedVars.chainColor end,
            setFunc = function(value)
                UnchainedHelper.savedVars.chainColor = value
            end,
        },


		{
			type = "checkbox",
			name = "Warden Healer Portals",
			tooltip = "Show location of warden portals that healer should place before mobs spawn, helpful to coordinate pulls between healer and tank",
			getFunc = function() return UnchainedHelper.savedVars.wardenPortals end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.wardenPortals = false
				else
					UnchainedHelper.savedVars.wardenPortals = true
				end
			end
		},


		{
            type = "dropdown",
            name = "Warden Healer Portal Color",
            tooltip = "Color used for warden portals",
            choices = spawnPortalColors,
            getFunc = function() return UnchainedHelper.savedVars.wardenPortalColor end,
            setFunc = function(value)
                UnchainedHelper.savedVars.wardenPortalColor = value
            end,
        },


		{
			type = "checkbox",
			name = "Debug Numbers",
			tooltip = "Show numbers on spawn locations, useful for troubleshooting pulls or requestion different settings for a given spawn",
			getFunc = function() return UnchainedHelper.savedVars.spawnNumbers end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.spawnNumbers = false
				else
					UnchainedHelper.savedVars.spawnNumbers = true
				end
			end
		},

		{
			type = "header",
			name = "Purge"
		},
		{
			type = "checkbox",
			name = "Display Purge Notification",
			tooltip = "For group purge show how many players currently require a purge (Poison Bloom, Arrow Poison)",
			getFunc = function() return UnchainedHelper.savedVars.displayPurge end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.displayPurge = false
				else
					UnchainedHelper.savedVars.displayPurge = true
				end
			end
		},


		{
			type = "checkbox",
			name = "Lock Purge Location",
			tooltip = "Unlock to position of purge notification",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					UnchainedHelperFramePurge:SetText("Purge X")
					UnchainedHelperFrame:SetHidden(false)
					UnchainedHelperFrame:SetMovable(true)
					UnchainedHelperFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, UnchainedHelper.hideFrame)
					UnchainedHelperFramePurge:SetText("")
					UnchainedHelperFrame:SetHidden(false)
					UnchainedHelperFrame:SetMovable(false)
					UnchainedHelperFrame:SetMouseEnabled(false)
				end
			end
		},
		{
            type = "dropdown",
            name = "Purge sound effect",
            tooltip = "Sound to play when a purge is needed",
            choices = sounds,
            getFunc = function() return UnchainedHelper.savedVars.soundEffectPurge end,
            setFunc = function(value)
                UnchainedHelper.savedVars.soundEffectPurge = value
                if value == "No Sound Effect" then
                else
                    PlaySound(value)
                end
            end,
        },


		{
			type = "header",
			name = "Combat Alerts"
		},
		{
			type = "checkbox",
			name = "Footsoldier/Prisoner heavy attack",
			tooltip = "Add dodge notification to Code's Combat Alerts for Footsoldier/Prisoner Heavy attacks.  Footsoldier notification only applied to DPS and Healers once enabled.",
			getFunc = function() return UnchainedHelper.savedVars.footsoldierHeavy end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.footsoldierHeavy = false
					UnchainedHelper.RemoveFootsoldierHeavy()
				else
					UnchainedHelper.savedVars.footsoldierHeavy = true
					UnchainedHelper.AddFootsoldierHeavy()
				end
			end
		},
		{
			type = "header",
			name = "Group Specific"
		},

		{
			type = "checkbox",
			name = "High DPS Groups",
			tooltip = "Anticipate high dps causing 3.3.2 to 3.3.3 transition to happen very fast (therefore list 3.3.3 spawns with 3.3.2)",
			getFunc = function() return UnchainedHelper.savedVars.highDps332 end,
			setFunc = function(value)
				if not value then
					UnchainedHelper.savedVars.highDps332 = false
				else
					UnchainedHelper.savedVars.highDps332 = true
				end
			end
		},
	}

	LAM:RegisterOptionControls(UnchainedHelper.name.."Options", options)
end
