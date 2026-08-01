synergy = synergy or {}
local syn = synergy

local LAM = LibAddonMenu2

function syn.buildMenu()
	local panelData = {
		type = "panel",
		name = syn.name,
		displayName = "|cd7f442S|rynergy",
		author = "Wheel5",
		version = ""..syn.version,
		registerForRefresh = true,
	}
	
	local options = {
		{
			type = "header",
			name = "Settings",
		},
		{
			type = "checkbox",
			name = "Trials Only",
			tooltip = "When enabled, extreme synergy blocking will only take effect in a trial zone (RECOMMENDED)",
			default = true,
			getFunc = function() return syn.savedVariables.trialsOnly end,
			setFunc = function(value) syn.savedVariables.trialsOnly = value end,
		},
		{
			type = "description",
			text = "Extreme syngery blocking will disable the use of ALL SYNERGIES for dps when there is no Alkosh applied to the boss. If you are in a raid setting where alkosh is not likely to be consistent, it is not recommended to enable this setting.\n\nAdditionally, there are a number of bosses where this setting will be ignored and it will be treated as if it were off, namely in fights were there are long periods of time where you cannot attack the boss, meaning  you will still be able to take orbs and such even if the boss does not have Alkosh applied.",
		},
		{
			type = "checkbox",
			name = "Extreme Synergy Blocking",
			tooltip = "Disables the use of ALL SYNERGIES for dps players when alkosh is down on a boss",
			default = false,
			getFunc = function() return syn.savedVariables.ExtremeBlocking end,
			setFunc = function(value) syn.savedVariables.ExtremeBlocking = value end,
		},
		{
			type = "checkbox",
			name = "Disable Cloudrest Portal",
			tooltip = "Disables the use of the portal synergy in Cloudrest when enabled",
			default = false,
			getFunc = function() return syn.savedVariables.portalDisable end,
			setFunc = function(value) syn.savedVariables.portalDisable = value end,
		},
		{
			type = "checkbox",
			name = "Only Synergize With Alkosh or Lokkestiiz Bonus",
			tooltip = "When enabled, this setting will disable synergies when you don't have either the Lokkestiiz or Alkosh 5-piece bonus while having one of the sets equipped. This will work on either bar, and if it is active on both bars (body pieces or otherwise) you'll be able to take synergies on both bars.",
			default = false,
			getFunc = function() return syn.savedVariables.frontBarOnly end,
			setFunc = function(value) syn.savedVariables.frontBarOnly = value end,
		},
		{
			type = "checkbox",
			name = "Show Synergy Available Alert",
			tooltip = "When enabled, if a synergy is blocked due to the above setting (not having the 5-piece bonus of Alkosh or Lokkestiiz while wearing one of the sets) an alert will instead be displayed, telling you that a synergy can be taken if you were to swap and activate the 5-piece bonus.",
			default = true,
			getFunc = function() return syn.savedVariables.showSynergyAlert end,
			setFunc = function(value) syn.savedVariables.showSynergyAlert = value end,
		},
		{
			type = "checkbox",
			name = "Advanced Lokkestiiz Mode",
			tooltip = "When enabled, if you have the Lokkestiiz set equipped and you have more than 5 seconds remaining on Major Slayer from any source, and you are above 50% stamina, you will not be able to take synergies (other than Charged Lightning). With less than 5 seconds remaining, or no Major Slayer at all, you will be able to take synergies again.",
			default = false,
			getFunc = function() return syn.savedVariables.advancedLokkeMode end,
			setFunc = function(value) syn.savedVariables.advancedLokkeMode = value end,
		},
		--{
		--	type = "checkbox",
		--	name = "Alkosh Mode",
		--	tooltip = "When the above setting (Only Synergize With Active Set) is enabled, if you are wearing the Roar of Alkosh set, you will only be able to take synergies with the 5-piece bonus active, and if you are not wearing Alkosh, you can take synergies on both bars.",
		--	default = false,
		--	getFunc = function() return syn.savedVariables.alkoshMode end,
		--	setFunc = function(value) syn.savedVariables.alkoshMode = value end,
		--},
		{
			type = "checkbox",
			name = "Disable Grave Robber",
			tooltip = "Enabling this will prevent you from being able to take the Grave Robber synergy from the Boneyard necro skill.",
			default = false,
			getFunc = function() return syn.savedVariables.disableGraveRobber end,
			setFunc = function(value) syn.savedVariables.disableGraveRobber = value end,
		},
		{
			type = "description",
			text = "Maelstrom Arena and Blackrose Prison share the same Defense and Healing sigil name, so if you have one of the following settings enabled the sigil will be disabled in BOTH arenas.",
		},
		{
			type = "checkbox",
			name = "Disable Blackrose Prison Sigils",
			tooltip = "When enabled, the sigils in Blackrose Prison can not be used",
			default = false,
			getFunc = function() return syn.savedVariables.brpSynDisable end,
			setFunc = function(value) syn.savedVariables.brpSynDisable = value end,
		},
		{
			type = "checkbox",
			name = "Disable Maelstrom Arena Sigils",
			tooltip = "When enabled, the sigils in Maelstrom Arena can not be used",
			default = false,
			getFunc = function() return syn.savedVariables.maSynDisable end,
			setFunc = function(value) syn.savedVariables.maSynDisable = value end,
		},
	}
	
	LAM:RegisterAddonPanel(syn.name.."Options", panelData)
	LAM:RegisterOptionControls(syn.name.."Options", options)
end
