SMSettings = {}
local LAM = LibAddonMenu2

function SMSettings.ShowOptions()
	LAM:OpenToPanel(UnDeadSpeedometerSettingsPanel)
end

function SMSettings.CreateSettings()
	local panelName = "UnDeadSpeedometerSettingsPanel"

	local panelData = {
	   type = "panel",
		name = "Speedometer",
		displayName = "|c91a3b0Speedometer|r",
		author = "|c91a3b0UnDead0rbit|r",
		website = "https://www.esoui.com/downloads/info3040-Speedometer.html",
        feedback = "https://www.esoui.com/downloads/info3040-Speedometer.html#comments",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local panel = LAM:RegisterAddonPanel(panelName, panelData)

	local OD = {}
	OD[#OD + 1] = {
		type = "header",
		name = "|c03c03cSpeedometer Settings|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Here you can adjust your Speedometer settings.",
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Reset Odometer",
		width = "half",
		func = function()
			Speedometer.SavedVariables.OdometerTotal = 0
			SCENE_MANAGER:ShowBaseScene()
		end
    }
	OD[#OD + 1] = {
		type = "button",
		name = "Close Settings",
		width = "half",
		func = function()
			SCENE_MANAGER:ShowBaseScene()
		end
    }
	OD[#OD + 1] = {
		type = "checkbox",
		name = "Hide UI",
		default = false,
		width = "full",
		getFunc = function() return Speedometer.SavedVariables.isUIHidden end,
		setFunc = function(value) 
			Speedometer.SavedVariables.isUIHidden = value 
		end
	}
	OD[#OD + 1] = {
		type = "header",
		name = "|c00cc99Contact Mod Developer|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Feel free to contact me with any bugs, comments, or anything else.",
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Send Friend Request",
		width = "full",
		func = function()
			RequestFriend("@UnDead0rbit", "Speedometer Request")
		end,
	}
	OD[#OD + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}
	OD[#OD + 1] = {
		type = "dropdown",
		name = "|ce4717aSelect Mail Topic|r",
		choices = {"Bug Report","Comment","Give Idea","Other Reason"},
		choicesValues = {"Re: I Have a Bug in Speedometer Mod","Re: Comment on Speedometer Mod","Re: I have an idea for Speedometer Mod","Re: I have something to tell you."}, -- if specified, these values will get passed to setFunc instead (optional)
		sort = "name-up",
		scrollable = true,
		default = "Bug Report",
		width = "full",
		requiresReload = false,
		getFunc = function() return Speedometer.MailTopic end,
		setFunc = function(value) Speedometer.MailTopic = value end
	}
	OD[#OD + 1] = {
		type = "editbox",
		name = "|ce4717aType Message To Send|r",
		sort = "name-up",
		isMultiline = true,
		isExtraWide = true,
		width = "full",
		requiresReload = false,
		getFunc = function() return nil end,
		setFunc = function(value) Speedometer.MailBody = value end
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Send Mail",
		width = "full",
		func = function()
			SCENE_MANAGER:ShowBaseScene()
			RequestOpenMailbox()
			SendMail("@UnDead0rbit", Speedometer.MailTopic, Speedometer.MailBody)
			d("Mail Sent to @UnDead0rbit")
		end,
	}

	LAM:RegisterOptionControls(panelName, OD)
end