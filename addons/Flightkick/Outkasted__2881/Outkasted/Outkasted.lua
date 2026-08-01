Outkasted = Outkasted or {}
Outkasted.name = "Outkasted"
Outkasted.abbreviation = "Outk"
Outkasted.version = "1.5"
Outkasted.website = "https://outkastedguild.com"
Outkasted.discord = "https://outkastedguild.com/discord"
Outkasted.guildId = 425252

local log = LibDebugLogger:Create(Outkasted.name)
local chat = LibChatMessage:Create(Outkasted.name, Outkasted.abbreviation)

function Outkasted.TeleportToGuildHall()
	local guildhall = { owner = "@Selegnar", houseId = 47 }

    -- Apparently JumpToSpecificHouse on the player's own house is not allowed. Something something cohesion...
	log:Debug("Teleporting to " .. guildhall.owner .. "'s home with house ID " .. guildhall.houseId)
	if guildhall.owner == GetDisplayName() then
        RequestJumpToHouse(guildhall.houseId)
	else
	    JumpToSpecificHouse(guildhall.owner, guildhall.houseId)
	end
end

function Outkasted.LeaveInstance(confirm)
	local LEAVE_DIALOG = "INSTANCE_LEAVE_DIALOG"

	log:Debug("Instance exit requested")
	if not IsUnitInDungeon("reticleover") then
		chat:Print(GetString(OUTK_LEAVEINSTANCE_ZOS_REPORTS_NOT_IN_TRIAL))
	else
		chat:Print(GetString(OUTK_LEAVEINSTANCE_EXITING_INSTANCE))
	end

	if confirm == false then
		ExitInstanceImmediately()
	else
		if IsInGamepadPreferredMode() then
			ZO_Dialogs_ShowGamepadDialog(LEAVE_DIALOG)
		else
			ZO_Dialogs_ShowDialog(LEAVE_DIALOG)
		end
	end
end

function Outkasted.OnAddOnLoaded(_, addonName)
	if addonName ~= Outkasted.name then return end
	EVENT_MANAGER:UnregisterForEvent(Outkasted.name, EVENT_ADD_ON_LOADED)
	log:Debug("Outkasted Add-On ready!")

	Outkasted.initMenu()

	SLASH_COMMANDS["/guildhall"] = function() Outkasted.TeleportToGuildHall() end
	SLASH_COMMANDS["/out"] = function() Outkasted.LeaveInstance(false) end

	SLASH_COMMANDS["/website"] = function() RequestOpenUnsafeURL(Outkasted.website) end
	SLASH_COMMANDS["/discord"] = function() RequestOpenUnsafeURL(Outkasted.discord) end
end

EVENT_MANAGER:RegisterForEvent(Outkasted.name, EVENT_ADD_ON_LOADED, Outkasted.OnAddOnLoaded)
