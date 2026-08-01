local GA = GuildAlert
local EH = GA.EventHandlers
local UI = GA.UI
local Util = GA.Util
local Setup = GA.Setup


------[[ Operations : Center Screen Announcements ]]------


function UI.Announce( msgText )

	local msgParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams( CSA_CATEGORY_LARGE_TEXT, SOUNDS.EMPEROR_CORONATED_ALDMERI )
	msgParams:SetText( msgText )
	msgParams:SetCSAType( CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN )

	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams( msgParams )

end
