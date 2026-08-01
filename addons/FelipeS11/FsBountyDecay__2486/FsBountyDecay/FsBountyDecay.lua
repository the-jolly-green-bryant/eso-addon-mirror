-- Fs.BountyDecay ESO AddOn by FelipeS11
-- see README.txt for description of this addon and change log
--
-- If the global variable was created, continue with the execution
if not FsBountyDecay.fsAddonCreated then return end

-- define local variables as much as possible, so scope is local
-- see http://lua-users.org/wiki/ScopeTutorial
local wm = GetWindowManager()
local em = GetEventManager()

--
-- This function will initialize our addon with ESO
--
local function FsBountyDecay_Initialize(event, addon)
    -- filter for just FST addon event
	if addon ~= FsBountyDecay.name then return end
	
	em:UnregisterForEvent(FsBountyDecay.name .. "Initialize", EVENT_ADD_ON_LOADED)

	-- load our saved variables
	FsBountyDecay.settings = ZO_SavedVars:New(FsBountyDecay.name .. "SavedVars", 1, nil, FsBountyDecay.defaults)
	if (not FsBountyDecay.settings) then
		FsBountyDecay.settings = FsBountyDecay.defaults
	end
	
	FsBountyDecay.MakeMenu()
	
	-- also, do this last, to minimize the chance of problem zone transitions
	em:RegisterForEvent(FsBountyDecay.name .. "Start", EVENT_PLAYER_ACTIVATED, function(...) FsBountyDecay.RefreshWindow(...) end)
	
    -- Slash commands must be lowercase!!! Set to nil to disable.
    SLASH_COMMANDS[FsBountyDecay.slashCommandName] = FsBountyDecay.SlashCommandFunc
end

-- Slash command function
function FsBountyDecay.SlashCommandFunc(option)	
	FsBountyDecay.Utils.SlashCommandFuncDef(FsBountyDecay.slashCommands, FsBountyDecay.slashCommandName, SI_FSBOUNTDECAY_SLASH_COMMANDS_INVALID, option)
end

-- Only show the loading message on first load ever.
local function FsBountyDecay_Activated(e)
    em:UnregisterForEvent(FsBountyDecay.name .. 'Activated', EVENT_PLAYER_ACTIVATED)
	if (FsBountyDecay.settings.FirstLoad) then
        FsBountyDecay.settings.FirstLoad = false
        FsBountyDecay.Utils.PrintMsgColorize(FsBountyDecay.name .. ' ' .. GetString(SI_FSBOUNTDECAY_ACTIVATED)) -- Prints to chat.
    end
end

function FsBountyDecay_Infamy(eventCode, oldInfamy, newInfamy, oldInfamyLevel, newInfamyLevel)
	if(FsBountyDecay_Timer and FsBountyDecay_Timer.header and FsBountyDecay_Timer.header:IsHidden())then
		FsBountyDecay_UpdateBountyDecays()
	end
	if (FsBountyDecay.settings.showInfo) then
		FsBountyDecay.Utils.PrintMsgColorize(GetString(SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY) .. oldInfamy .. ' -> ' .. newInfamy)
		FsBountyDecay.Utils.PrintMsgColorize(GetString(SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY_LEVEL) .. oldInfamyLevel .. ' -> ' .. newInfamyLevel)
	end
end

FsBountyDecay.slashCommands = {
	[1] = {
		str = "SI_FSBOUNTDECAY_SLASH_COMMANDS_TITLE",
		defColor = true
	},
	[2] = {
		cmd = "donate",
		str = "SI_FSBOUNTDECAY_SLASH_COMMANDS_GOLD",
		compl = " <value>",
		func = function (options)
			local value = tonumber(options[2])
			if value and value >= 1000 then
				RequestOpenMailbox()
				QueueMoneyAttachment(tonumber(options[2]))	
				SendMail(FsBountyDecay.authorId, FsBountyDecay.name .. " Donation")
			end
		end
	},
	[3] = {
		cmd = "format",
		str = "SI_FSBOUNTDECAY_SLASH_COMMANDS_ISCLOCK",
		func = function (options)
			FsBountyDecay.settings.isClock = not FsBountyDecay.settings.isClock
			FsBountyDecay.Utils.PrintMsgColorize(GetString(SI_FSBOUNTDECAY_SLASH_COMMANDS_NEW_VALUE) .. tostring(FsBountyDecay.settings.isClock))
		end
	},
	[4] = {
		cmd = "showinfo",
		str = "SI_FSBOUNTDECAY_SLASH_COMMANDS_SHOWINFO",
		func = function (options)
			FsBountyDecay.settings.showInfo = not FsBountyDecay.settings.showInfo
			FsBountyDecay.Utils.PrintMsgColorize(GetString(SI_FSBOUNTDECAY_SLASH_COMMANDS_NEW_VALUE) .. tostring(FsBountyDecay.settings.showInfo))
		end
	},
	[5] = {
		cmd = "defaults",
		str = "SI_FSBOUNTDECAY_SLASH_COMMANDS_DEFAULTS",
		func = function (options)
			FsBountyDecay.setWindowDefault()
		end
	}
}

-- When player is ready, after everything has been loaded.
em:RegisterForEvent(FsBountyDecay.name .. 'Activated', EVENT_PLAYER_ACTIVATED, FsBountyDecay_Activated)

-- register our event handler function to be called to do initialization
em:RegisterForEvent(FsBountyDecay.name .. "Initialize", EVENT_ADD_ON_LOADED, function(...) FsBountyDecay_Initialize(...) end)

-- When Infamy is updated.
em:RegisterForEvent(FsBountyDecay.name .. "Infamy", EVENT_JUSTICE_INFAMY_UPDATED, function(...) FsBountyDecay_Infamy(...) end)

