local L = SocialIndicators.Localization
local SafeIsFriend = SocialIndicators.SafeIsFriend
local GetPreferredGuildMemberIndexFromCharacterOrDisplayName = SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName
local RegisterForEvent = SocialIndicators.RegisterForEvent

local TARGET_UNIT_TAG = "reticleover"
local FRIEND_ICON_TEXTURE = "SocialIndicators/images/adominion/friendicon.dds"
local CROPPED_ICON_SIZE = 14
local ICON_SIZE = 24
local SKIP_CREATE = true

local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
local lastSeenCharacter, db

local function AddHeaderLines(tooltip, lines, alignment)
	for i = 1, #lines do
		tooltip:AddHeaderLine(lines[i], "ZoFontWinH5", i, alignment, r, g, b)
	end
end

local function AddNote(tooltip, note)
	if(note and #note > 0) then
		ZO_Tooltip_AddDivider(tooltip)
		tooltip:AddLine(note)
	end
end

local function ClearOpenDetailWindowButton(tooltip)
	local button = tooltip.siDetailButton
	if(button) then
		button:SetHidden(true)
		button.player = nil
		button.character = nil
	end
end

local function HidePopupTooltip()
	ZO_PopupTooltip_Hide()
	ClearOpenDetailWindowButton(PopupTooltip)
	PopupTooltip.lastPlayer = nil
end

local function HandleOpenDetailWindowButtonClicked(control, button, isInside)
	if(control:GetState() == BSTATE_NORMAL and button == MOUSE_BUTTON_INDEX_LEFT and isInside) then
		CALLBACK_MANAGER:FireCallbacks("SocialIndicatorsPlayerChanged", control.player)
		CALLBACK_MANAGER:FireCallbacks("SocialIndicatorsCharacterChanged", control.character)
		MAIN_MENU_KEYBOARD:ShowScene("playerDetails")
		HidePopupTooltip()
	end
end

local function AddOpenDetailWindowButton(tooltip, player, character)
	local button = tooltip.siDetailButton
	if(not button) then
		button = CreateControlFromVirtual("$(parent)SocialIndicatorsButton", tooltip, "ZO_DefaultButton")
		button:SetText(L["PLAYER_DETAIL_POPUP_OPEN_DETAIL_WINDOW"])
		button:SetHandler("OnMouseUp", HandleOpenDetailWindowButtonClicked)
		tooltip.siDetailButton = button
	end
	button.player = player
	button.character = character
	tooltip:AddControl(button)
	button:ClearAnchors()
	button:SetAnchor(CENTER)
	button:SetHidden(false)
end

local function PreparePlayerDetailTooltip(tooltip, player, character)
	tooltip:ClearLines()
	ClearOpenDetailWindowButton(tooltip)
	if(character and player) then
		local iconControl = tooltip:GetNamedChild("Icon")
		if(iconControl) then
			iconControl:SetTexture(character:GetAllianceTexture())
			iconControl:SetHidden(false)
		end

		local headers = {}
		local guildId = GetPreferredGuildMemberIndexFromCharacterOrDisplayName(player.displayName)
		if(guildId) then
			headers[#headers + 1] = GetGuildName(guildId)
			headers[#headers + 1] = zo_iconTextFormat(player:GetGuildRankIcon(guildId), CROPPED_ICON_SIZE, CROPPED_ICON_SIZE, player:GetGuildRankName(guildId))
		end

		if(character.gender > 0) then
			headers[#headers + 1] = character:GetGenderName()
		end
		if(character.race > 0) then
			headers[#headers + 1] = character:GetRaceName()
		end
		headers[#headers + 1] = character.zoneName

		AddHeaderLines(tooltip, headers, TOOLTIP_HEADER_SIDE_LEFT)

		headers = {}
		if(player.playerStatus == 0) then
			headers[#headers + 1] = "Last Seen: |cffffff" .. ZO_FormatDurationAgo(player:GetTimeSinceLastSeen())
		elseif(player.playerStatus == PLAYER_STATUS_OFFLINE) then
			headers[#headers + 1] = zo_strformat(SI_SOCIAL_LIST_LAST_ONLINE, ZO_FormatDurationAgo(player:GetTimeSinceLogoff()))
		else
			headers[#headers + 1] = zo_iconTextFormat(player:GetStatusIcon(), ICON_SIZE, ICON_SIZE, player:GetStatusString())
		end

		if(SafeIsFriend(player.displayName)) then
			headers[#headers + 1] = zo_iconTextFormat(FRIEND_ICON_TEXTURE, CROPPED_ICON_SIZE, CROPPED_ICON_SIZE, L["PLAYER_DETAIL_POPUP_FRIEND"])
		end

		local level, championPoints = character.level, player.championPoints
		headers[#headers + 1] = GetString(SI_FRIENDS_LIST_PANEL_TOOLTIP_LEVEL) .. " " .. level
		if championPoints > 0 then
			headers[#headers + 1] = zo_iconTextFormat(GetChampionPointsIcon(), ICON_SIZE, ICON_SIZE, championPoints)
		end

		if(character.classType > 0) then
			headers[#headers + 1] = zo_iconTextFormat(character:GetClassIcon(), ICON_SIZE, ICON_SIZE, character:GetClassName())
		end

		if(character.avaRank > 0) then
			headers[#headers + 1] = zo_iconTextFormat(character:GetAvARankIcon(), ICON_SIZE, ICON_SIZE, character:GetAvARankName())
		end

		AddHeaderLines(tooltip, headers, TOOLTIP_HEADER_SIDE_RIGHT)

		tooltip:AddLine(player.displayName, "ZoFontGameBold", r, g, b)

		tooltip:AddLine(character.characterName)

		local altNames = db:GetCharacterNamesForPlayer(player.displayName)
		if(altNames) then
			local filteredAltNames = {}
			for i = 1, #altNames do
				if(altNames[i] ~= character.characterName) then
					filteredAltNames[#filteredAltNames + 1] = altNames[i]
				end
			end
			AddNote(tooltip, table.concat(filteredAltNames, ", "))
		end

		AddNote(tooltip, player.guildNote[guildId])
		AddNote(tooltip, player.friendNote)
	else
		if(player or character) then
			tooltip:AddLine(zo_strformat("<<1>>", player and player.displayName or character.characterName), "ZoFontGameBold", r, g, b)
		end
		tooltip:AddLine(L["PLAYER_DETAIL_POPUP_NO_INFO"])
	end
end

local function TogglePlayerDetailTooltip(name)
	if not PopupTooltip:IsHidden() and PopupTooltip.lastPlayer == name then
		HidePopupTooltip()
	else
		local player, character = db:GetPlayerAndCharacterFromCharacterOrDisplayName(name)
		PreparePlayerDetailTooltip(PopupTooltip, player, character)
		--AddOpenDetailWindowButton(PopupTooltip, player, character)
		PopupTooltip:SetHidden(false)
		PopupTooltip.lastPlayer = name
	end
end

local function ShowTargetPlayerDetails()
	if(lastSeenCharacter) then
		TogglePlayerDetailTooltip(lastSeenCharacter)
	end
end

local function ShowPlayerDetailInfoTooltip(player, character, owner)
	InitializeTooltip(InformationTooltip, owner)
	PreparePlayerDetailTooltip(InformationTooltip, player, character)
end

local function HidePlayerDetailInfoTooltip()
	ClearTooltip(InformationTooltip)
end

local function InitPlayerDetailPopup()
	db = SocialIndicators.db

	-- hijack the friend list and guild roster
	local originalClearMenu = ClearMenu
	local noopClearMenu = function() end

	local function InjectSocialListMenuEntry(object, method)
		local orginalCall = object[method]
		object[method] = function(self, control, button, upInside)
			if(button == 2 and upInside) then
				ClearMenu()

				local data = ZO_ScrollList_GetData(control)
				if data then
					AddCustomMenuItem(L["DETAIL_POPUP_MENU_ENTRY"], function()
						TogglePlayerDetailTooltip(data.displayName)
					end)

					ClearMenu = noopClearMenu
					orginalCall(self, control, button, upInside)
					ClearMenu = originalClearMenu
				end
			end
		end
	end

	InjectSocialListMenuEntry(FRIENDS_LIST, "FriendsListRow_OnMouseUp")
	InjectSocialListMenuEntry(GUILD_ROSTER_KEYBOARD, "GuildRosterRow_OnMouseUp")

	-- add an entry to the player context menu
	local originalShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
	CHAT_SYSTEM.ShowPlayerContextMenu = function(self, name, ...)
		ClearMenu()
		AddCustomMenuItem(L["DETAIL_POPUP_MENU_ENTRY"], function()
			TogglePlayerDetailTooltip(name)
		end)
		ClearMenu = noopClearMenu
		originalShowPlayerContextMenu(self, name, ...)
		ClearMenu = originalClearMenu
	end

	-- remember the last seen character name so we can toggle the detail popup more reliably
	ZO_PreHook(ZO_TargetUnitFramereticleoverName, "SetText", function()
		if(not IsUnitPlayer(TARGET_UNIT_TAG)) then return end
		lastSeenCharacter = GetUnitName(TARGET_UNIT_TAG)
	end)

	RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
		lastSeenCharacter = nil
	end)

	ZO_CreateStringId("SI_BINDING_NAME_SHOW_DETAIL_POPUP", L["KEYBIND_SHOW_DETAIL_POPUP"])
end

SocialIndicators.ShowPlayerDetailInfoTooltip = ShowPlayerDetailInfoTooltip
SocialIndicators.HidePlayerDetailInfoTooltip = HidePlayerDetailInfoTooltip
SocialIndicators.TogglePlayerDetailTooltip = TogglePlayerDetailTooltip
SocialIndicators.ShowTargetPlayerDetails = ShowTargetPlayerDetails
SocialIndicators.InitPlayerDetailPopup = InitPlayerDetailPopup
