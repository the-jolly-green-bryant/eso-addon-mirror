local function Inititialize(db)
	local sceneName = "playerDetails"

	local playerDetail = SocialIndicators.PlayerDetailFragment:New(db)
	local characterList = SocialIndicators.CharacterListFragment:New(db)
	local PLAYER_DETAIL_SCENE = ZO_Scene:New("playerDetails", SCENE_MANAGER)
	PLAYER_DETAIL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	PLAYER_DETAIL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	PLAYER_DETAIL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	PLAYER_DETAIL_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	PLAYER_DETAIL_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	PLAYER_DETAIL_SCENE:AddFragment(playerDetail.fragment)
	PLAYER_DETAIL_SCENE:AddFragment(characterList.fragment)
	PLAYER_DETAIL_SCENE:AddFragment(TITLE_FRAGMENT)
	PLAYER_DETAIL_SCENE:AddFragment(CONTACTS_TITLE_FRAGMENT)
	PLAYER_DETAIL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
	PLAYER_DETAIL_SCENE:AddFragment(CONTACTS_WINDOW_SOUNDS)

	PLAYER_DETAIL_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if(PLAYER_DETAIL_SCENE:IsShowing()) then
			playerDetail:UpdatePlayer()
			playerDetail:UpdateCharacter()
			characterList:Update()
		end
	end)
	SocialIndicators.InjectContactsMenuTab(sceneName, SI_GAMEPAD_GUILD_HISTORY_GUILD_EVENT_TITLE, "EsoUI/Art/LFG/LFG_tabIcon_groupTools_%s.dds")

	SocialIndicators.PlayerDetail_OnMouseEnter = function(control) end
	SocialIndicators.PlayerDetail_OnMouseExit = function(control) end

	SocialIndicators.PlayerDetailFriendNote_OnMouseEnter = function(control) end
	SocialIndicators.PlayerDetailFriendNote_OnMouseExit = function(control) end

	SocialIndicators.PlayerDetailGuildNote_OnMouseEnter = function(control) end
	SocialIndicators.PlayerDetailGuildNote_OnMouseExit = function(control) end

	local currentPlayer, currentCharacter = db:GetPlayerAndCharacterFromCharacterOrDisplayName(GetUnitName("player"))
	characterList:SetPlayer(currentPlayer)
	playerDetail:SetPlayer(currentPlayer)
	playerDetail:SetCharacter(currentCharacter)

	local cm = CALLBACK_MANAGER
	cm:RegisterCallback("SocialIndicatorsPlayerChanged", function(player)
		currentPlayer = player
		characterList:SetPlayer(player)
		playerDetail:SetPlayer(player)
	end)

	cm:RegisterCallback("SocialIndicatorsPlayerUpdate", function(player)
		if(player == currentPlayer) then
			characterList:Update()
			playerDetail:UpdatePlayer()
		end
	end)

	cm:RegisterCallback("SocialIndicatorsCharacterChanged", function(character)
		currentCharacter = character
		playerDetail:SetCharacter(character)
	end)

	cm:RegisterCallback("SocialIndicatorsCharacterUpdate", function(character)
		if(character == currentCharacter) then
			playerDetail:UpdateCharacter()
		end
	end)
end

SocialIndicators.InitPlayerDetailScreen = Inititialize
