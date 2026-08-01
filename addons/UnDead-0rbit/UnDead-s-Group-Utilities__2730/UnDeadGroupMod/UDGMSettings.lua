--[[dropdownData = {
type = "dropdown",
name = "My Dropdown", -- or string id or function returning a string
choices = {"table", "of", "choices"},
choicesValues = {"foo", 2, "three"}, -- if specified, these values will get passed to setFunc instead (optional)
getFunc = function() return db.var end,
setFunc = function(var) db.var = var doStuff() end,
tooltip = "Dropdown's tooltip text.", -- or string id or function returning a string (optional)
choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
sort = "name-up", -- or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
width = "full", -- or "half" (optional)
scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
default = defaults.var, -- default value or function that returns the default value (optional)
helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
reference = "MyAddonDropdown" -- unique global reference to control (optional)
}

optionsData[#optionsData + 1] = {
			type = "header",
			name = "Name This Mod!",
		}
		optionsData[#optionsData + 1] = {
			type = "description",
			text = "",
		}
		optionsData[#optionsData + 1] = {
			type = "editbox",
			name = "Type Name to Suggest. Winner Gets 100k Gold!",
			sort = "name-up",
			isMultiline = true,
			isExtraWide = true,
			width = "full",
			requiresReload = false,
			getFunc = function() return nil end,
			setFunc = function(value) UnDeadGroupMod.MailBody = value end
		}
		optionsData[#optionsData + 1] = {
            type = "button",
            name = "Send Suggestion",
			width = "full",
            func = function()
				SCENE_MANAGER:ShowBaseScene()
				RequestOpenMailbox()
                SendMail("@UnDead0rbit", "Group Utilities Name", UnDeadGroupMod.MailBody)
				d("Mail Sent to @UnDead0rbit")
				UnDeadGroupMod.SavedVariables.didVoteNewName = true
            end,
        }
]]


local LAM = LibAddonMenu2
function UnDeadGroupMod.CreateSettings()
	local UDGM = UnDeadGroupMod
	---@type UDGM_SavedVars
	local sv = UDGM.SavedVariables
	local panelName = "UnDeadGroupModSettingsPanel"

	local panelData = {
		type = "panel",
		name = "UnDead's Group Utilities",
		displayName = "UnDead's Group Utilities",
		author = "UnDead0rbit",
		website = "https://www.esoui.com/downloads/info2730-UnDeadsGroupUtilities.html",
		feedback = "https://www.esoui.com/portal.php?uid=60193&a=listbugs",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)

	local optionsData = {}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Join a Friend's Group"
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text = "Step 1: Select a Friend.\nStep 2: Press Enter to Send the Chat Message Generated."
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown",
		name = "Select Friend to Join",
		choices = UDGM.FriendList,
		sort = "name-up",
		scrollable = true,
		default = false,
		width = "half",
		requiresReload = false,
		getFunc = function() return nil end,
		setFunc = function(value)
			SCENE_MANAGER:ShowBaseScene()
			UDGM.FriendToJoin = value
			UDGM.SendJoinMessage()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text =
		"Conditions: Selected Friend Must Have this Mod Installed! \nAlso, Friend must be solo or group leader, online, and able to be joined."
	}
	optionsData[#optionsData + 1] = {
		type = "button",
		name = "Close Settings",
		width = "full",
		func = function()
			SCENE_MANAGER:ShowBaseScene()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Favorite Friends"
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text =
		"Here you can select up to 3 friends to have on the UI for status, quick invites, traveling to player and home."
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		width = "half",
		text =
		"Status Colors\n|c89cff0Player is ONLINE|r\n|c873260Player is AWAY|r\n|c800020Player is DO NOT DISTURB|r\n|c3d2b1fPlayer is OFFLINE|r"
	}
	local function makeFriendDropdown(idx)
		return {
			type = "dropdown",
			name = "Friend Slot " .. idx,
			choices = UDGM.FriendList,
			sort = "name-up",
			scrollable = true,
			default = false,
			width = "half",
			requiresReload = false,
			getFunc = function()
				if not sv.Friends then sv.Friends = {} end
				return sv.Friends[idx]
			end,
			setFunc = function(value)
				if not sv.Friends then sv.Friends = {} end
				sv.Friends[idx] = value
			end
		}
	end

	for i = 1, 3 do
		optionsData[#optionsData + 1] = makeFriendDropdown(i)
	end

	optionsData[#optionsData + 1] = {
		type = "description",
		text = "If you recently added a friend, they may not appear until you travel or reloadui.",
	}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Auto Acceptors",
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Auto LFG Ready Check",
		default = false,
		width = "full",
		getFunc = function() return sv.willAcceptLFGCheck end,
		setFunc = function(value) sv.willAcceptLFGCheck = value end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Auto Leave LFG Group After Activity Completes",
		default = false,
		width = "full",
		warning =
		"Not Recommended, May BREAK Your Ability to Group, Until a Server Reset...  happened to me and a friend... not 100 positive it was because of this but pretty sure it was due to it triggering so fast after the activity ended. any ways use at your own risk....",
		getFunc = function() return sv.canLeaveLFG end,
		setFunc = function(value) sv.canLeaveLFG = value end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Auto Accept Group Invite from Favorites",
		default = false,
		width = "full",
		tooltip = "Doesnt Accept the Fast Travel to Leader if in another Zone, only the Initial Invite.",
		getFunc = function() return sv.willAcceptGroupInvite end,
		setFunc = function(value) sv.willAcceptGroupInvite = value end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Disable Travel to Leader Dialog",
		default = false,
		width = "full",
		tooltip = "If true, when accepting a group invite, it will not prompt you to travel to leader.",
		getFunc = function() return sv.willNotAcceptTravelToLeader end,
		setFunc = function(value) sv.willNotAcceptTravelToLeader = value end
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown",
		name = "Auto Queue Button Selection",
		choices = { "Random Normal Dungeon", "Solo Random Battleground" },
		choicesValues = { QUEUE.RANDOM_NORMAL_DUNGEON, QUEUE.SOLO_RANDOM_BATTLEGROUND }, -- if specified, these values will get passed to setFunc instead (optional)
		sort = "name-up",
		scrollable = true,
		default = "Random Normal Dungeon",
		width = "full",
		requiresReload = false,
		getFunc = function() return sv.selectedQ end,
		setFunc = function(value) sv.selectedQ = value end
	}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Display Settings",
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text = "Change the UI elements of the mod.",
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Show Difficulty",
		default = true,
		width = "half",
		tooltip = "if false, hides the Difficulty selector",
		getFunc = function() return sv.isDifficultyVisible end,
		setFunc = function(value)
			sv.isDifficultyVisible = value
			UDGM.VisibilityChange()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Show Group Role",
		default = true,
		width = "half",
		tooltip = "if false, hides the Group Role selector",
		getFunc = function() return sv.isRoleVisible end,
		setFunc = function(value)
			sv.isRoleVisible = value
			UDGM.VisibilityChange()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Show Ready Check",
		default = true,
		width = "half",
		tooltip = "if false, hides the Election selector",
		getFunc = function() return sv.isReadyCheckVisible end,
		setFunc = function(value)
			sv.isReadyCheckVisible = value
			UDGM.VisibilityChange()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Show Mod Title",
		default = true,
		width = "half",
		tooltip = "if false, hides the Title selector",
		getFunc = function() return sv.isTitleVisible end,
		setFunc = function(value)
			sv.isTitleVisible = value
			UDGM.VisibilityChange()
		end
	}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Contact Mod Developer",
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text = "Feel free to contact me with any bugs, comments, or anything else.",
	}
	optionsData[#optionsData + 1] = {
		type = "button",
		name = "Send Friend Request",
		width = "full",
		func = function()
			RequestFriend("@UnDead0rbit", "UnDead Utilities Mod Request")
		end,
	}
	optionsData[#optionsData + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown",
		name = "Select Mail Topic",
		choices = { "Bug Report", "Comment", "Give Idea", "Other Reason" },
		choicesValues = { "Re: I Have a Bug in UnDead Utilities Mod", "Re: Comment on UnDead Utilities Mod", "Re: I have an idea for UnDead Utilities Mod", "Re: I have something to tell you." }, -- if specified, these values will get passed to setFunc instead (optional)
		sort = "name-up",
		scrollable = true,
		default = "Bug Report",
		width = "full",
		requiresReload = false,
		getFunc = function() return UDGM.MailTopic end,
		setFunc = function(value) UDGM.MailTopic = value end
	}
	optionsData[#optionsData + 1] = {
		type = "editbox",
		name = "Type Message To Send",
		sort = "name-up",
		isMultiline = true,
		isExtraWide = true,
		width = "full",
		requiresReload = false,
		getFunc = function() return nil end,
		setFunc = function(value) UDGM.MailBody = value end
	}
	optionsData[#optionsData + 1] = {
		type = "button",
		name = "Send Mail",
		width = "full",
		func = function()
			SCENE_MANAGER:ShowBaseScene()
			RequestOpenMailbox()
			SendMail("@UnDead0rbit", UDGM.MailTopic, UDGM.MailBody)
			d("Mail Sent to @UnDead0rbit")
		end,
	}
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Additional Info",
	}
	optionsData[#optionsData + 1] = {
		type = "description",
		text =
		"The Change Difficulty Button does change the difficulty setting, yet the icon in your group menu will not update to show that without reloading the ui.  I had it force reloadui at first, but decided that was more annoying than it not showing.\n\n Nevertheless, if the difficulty says Vet, then you are on vet just the icon in your game menu may not be refreshed.",
	}

	LAM:RegisterOptionControls(panelName, optionsData)
end
