local addon = {
	name = "TheSoullessOfTamriel"
}
local em = GetEventManager()

local function sendDonate(gold)
	SCENE_MANAGER:CallWhen(
		MAIL_SEND_SCENE:GetName(),
		SCENE_SHOWN,
		function()
			ZO_MailSendToField:SetText("@Neomazu")
			ZO_MailSendSubjectField:SetText("Gildenspende")
			QueueMoneyAttachment(gold)
			ZO_MailSendBodyField:TakeFocus()
		end
	)
	SCENE_MANAGER:Show(MAIL_SEND_SCENE:GetName())
end

local function CreateMenu()
	local entries = {
		{
			label = "Donate",
			callback = function()
				sendDonate(0)
			end
		},
		{
			label = "Donate 5000 Gold",
			callback = function()
				sendDonate(5000)
			end
		},
		{
			label = "Donate 25000 Gold",
			callback = function()
				sendDonate(25000)
			end
		}
	}

	local orgShowContextMenu = SharedChatContainer.ShowContextMenu
	function SharedChatContainer.ShowContextMenu(...)
		local orgShowMenu = ShowMenu
		local container, tabIndex = ...
		function ShowMenu(...)
			ShowMenu = orgShowMenu
			if not ZO_Dialogs_IsShowingDialog() then
           AddCustomMenuItem(LibCustomMenu.DIVIDER)
				AddCustomMenuItem(
					"Port to Guild Hall: The Soulless of Tamriel",
					function()
						local playerName = "@Neomazu"
						if GetDisplayName() == playerName then
							RequestJumpToHouse(47)
						else
							JumpToHouse(playerName, 47)
						end
					end
				)
				AddCustomMenuItem(
					"Post to Chat: The Soulless of Tamriel",
					function()
						StartChatInput(
							"Seeking for soulless throughout Tamriel. All set crafting stations, target dummies of all sizes, armory assistent, ragpicker, merchant, banker, all mundus stones, aetherial walls, blood basin, soul-sworn thrall, transmute, enchant, cooking, alchemy and outfit stations. Guild addon and Discord. |H1:guild:748282|hThe Soulless of Tamriel|h"
						)
					end
				)
				AddCustomMenuItem(LibCustomMenu.DIVIDER)
				AddCustomSubMenuItem("Send Feedback", entries)
				AddCustomMenuTooltip("The gold will be used for maintaining the guild hall and guild trader.")
			end
			return ShowMenu(...)
		end
		return orgShowContextMenu(...)
	end
end

local function OnAddonLoaded(event, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	CreateMenu()
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
