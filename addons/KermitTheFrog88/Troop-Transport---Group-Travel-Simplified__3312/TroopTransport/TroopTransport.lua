local LAM2 = LibAddonMenu2
local hudtrackerpostinit = false
local HUDHidden = true
TroopTransport = {}
TroopTransport.name = "TroopTransport" 
TroopTransport.variableVersion = 1
TroopTransport.version = "0.09"
TroopTransport.savedVariables = 0
TroopTransport.GroupList = {}
TroopTransport.FriendList = {}
TroopTransport.Default = {
	  OffsetX = 20,
	  OffsetY = 75,
	  Show = true,
	  HideInCombat = true,
	  Width = 200,
	  Height = 400,
 }

function TroopTransport.OnAddOnLoaded(event, addonName)
	if addonName ~= TroopTransport.name then return end
	CHAT_SYSTEM:AddMessage("Start AddOnLoaded")
	TroopTransport:Initialize()
end

function TroopTransport:Initialize()

TroopTransport.CreateSettingsWindow()
TroopTransport.savedVariables = ZO_SavedVars:NewAccountWide("TroopTransportVars", TroopTransport.variableVersion, nil, TroopTransport.Default, GetWorldName())

TroopTransportMainButton:ClearAnchors()
TroopTransportMainButton:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TroopTransport.savedVariables.OffsetX, TroopTransport.savedVariables.OffsetY)

TroopTransport.HUDHidden = true
TroopTransport1:SetHidden(true)
TroopTransportMainButtonBG:SetHidden(true)
TroopTransportMainButton:SetHidden(false)

TroopTransport.InitializeGroupComboBox()
TroopTransport.InitializeFriendComboBox()
GroupDropDownWindow:SetHidden(true)
FriendDropDownWindow:SetHidden(true)

TroopTransport.inCombat = IsUnitInCombat("player")
EVENT_MANAGER:RegisterForEvent(TroopTransport.name, EVENT_PLAYER_COMBAT_STATE, TroopTransport.OnPlayerCombatState)

local fragment1 = ZO_SimpleSceneFragment:New(TroopTransportMainButton)
HUD_SCENE:AddFragment(fragment1)
HUD_UI_SCENE:AddFragment(fragment1)

TroopTransport.fragment2 = ZO_SimpleSceneFragment:New(TroopTransport1)
TroopTransport.fragment3 = ZO_SimpleSceneFragment:New(GroupDropDownWindow)
TroopTransport.fragment4 = ZO_SimpleSceneFragment:New(FriendDropDownWindow)

EVENT_MANAGER:UnregisterForEvent(TroopTransport.name, EVENT_ADD_ON_LOADED)

end

function TroopTransport.OnPlayerCombatState(event, inCombat)


	if TroopTransport.savedVariables.HideInCombat then
		if inCombat then
			TroopTransportMainButton:SetHidden(inCombat)
			TroopTransport1:SetHidden(inCombat)
			GroupDropDownWindow:SetHidden(inCombat)
			FriendDropDownWindow:SetHidden(inCombat)
			HUD_SCENE:RemoveFragment(TroopTransport.fragment2)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment2)
			HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)
			HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)
		else 
			TroopTransportMainButton:SetHidden(inCombat)
		end
	end


end

EVENT_MANAGER:RegisterForEvent(TroopTransport.name, EVENT_ADD_ON_LOADED, TroopTransport.OnAddOnLoaded)

function TroopTransport.CreateSettingsWindow()

	local panelData = {
		type = "panel",
		name = "Troop Transport",
		displayName = "Troop Transport",
		author = "KermitTheFrog88",
		version = TroopTransport.version,
		slashCommand = "/troopt",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3312-TroopTransport-GroupTravelSimplified.html",  --update url
		feedback = "https://www.esoui.com/downloads/info3312-TroopTransport-GroupTravelSimplified.html#comments", --update url
		donation = "https://www.esoui.com/downloads/info3312-TroopTransport-GroupTravelSimplified.html",  --Add in game mail function
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Troop_Transport", panelData)
	
	local optionsData={
		[1] = {
			type = "header",
			name = "Settings",
		},
		[2] = {
			type = "description",
			text = "Settings to control the Troop Transport interface",
		},
		[3] = {
			type = "checkbox",
			name = "Hide interface when in combat.",
			tooltip = "If set to ON Troop Transport interface will be hidden when in combat",
			default = false,
			getFunc = function() return TroopTransport.savedVariables.HideInCombat end,
			setFunc = function(newValue)
				TroopTransport.savedVariables.HideInCombat = newValue
				end,
		},
	}
	
	LAM2:RegisterOptionControls("Troop_Transport", optionsData)
 CHAT_SYSTEM:AddMessage("End Settings Window")
	
end

function TroopTransport.SaveLocWindow()
	-- TroopTransport.savedVariables.OffsetX = TroopTransport1:GetLeft()
	-- TroopTransport.savedVariables.OffsetY = TroopTransport1:GetTop()
end

function TroopTransport.SaveLocButton()
	TroopTransport.savedVariables.OffsetX = TroopTransportMainButton:GetLeft()
	TroopTransport.savedVariables.OffsetY = TroopTransportMainButton:GetTop()
end
 
function TroopTransport.GetGroupMembers()

ZO_ClearTable(TroopTransport.GroupList)

if IsUnitGrouped("player") then
	 for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			local displayName = GetUnitDisplayName(unitTag)
			if(IsUnitOnline(unitTag)) then
				local characterName = GetUnitName(unitTag)
				table.insert(TroopTransport.GroupList, displayName)
			end
	end
	table.insert(TroopTransport.GroupList, 1, "Select Group Member")
else
	table.insert(TroopTransport.GroupList, "No Group Found")
end

end

function TroopTransport.GetFriends()

ZO_ClearTable(TroopTransport.FriendList)

if GetNumFriends() > 0 then
   for i = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(i)
        local hasChar, characterName, zoneName, _, _, level, cp = GetFriendCharacterInfo(i)
		if(status ~= PLAYER_STATUS_OFFLINE) then
            table.insert(TroopTransport.FriendList, displayName)
        end
    end
	table.insert(TroopTransport.FriendList, 1, "Select Friend")
else
	table.insert(TroopTransport.FriendList, "No friends found")
end
	
end
 
function TroopTransport.HasDisplayName(displayName)
    return TroopTransport.players[zo_strlower(displayName)] ~= nil
end 
 
function TroopTransport.TravelToLeaderOnClicked()

	HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
	HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)
	HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
	HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)
	FriendDropDownWindow:SetHidden(true)
	GroupDropDownWindow:SetHidden(true)
	
	if IsUnitGrouped("player") then
		d("Traveling to group leader")
		JumpToGroupLeader()
		TroopTransport1:SetHidden(true)
		TroopTransport.HUDHidden = true
	else
		d("You are not in a group")
		TroopTransport1:SetHidden(true)
		TroopTransport.HUDHidden = true
	end
end

function TroopTransport.TravelToGroupMemberOnClicked()
	if IsUnitGrouped("player") then
	TroopTransport.PopulateGroupComboBox(GroupDropDownWindow.m_comboBox)

	HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
	HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)	
	FriendDropDownWindow:SetHidden(true)
	
	GroupDropDownWindow:SetHidden(false)
	HUD_SCENE:AddFragment(TroopTransport.fragment3)
	HUD_UI_SCENE:AddFragment(TroopTransport.fragment3)
	
	else
	HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
	HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)
	FriendDropDownWindow:SetHidden(true)
	
	GroupDropDownWindow:SetHidden(true)
	d("Your are not in a group")
	end

end

function TroopTransport.TravelToFriendOnClicked()

	TroopTransport.PopulateFriendComboBox(FriendDropDownWindow.m_comboBox)
	
	HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
	HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)
	GroupDropDownWindow:SetHidden(true)
	
	FriendDropDownWindow:SetHidden(false)
	HUD_SCENE:AddFragment(TroopTransport.fragment4)
	HUD_UI_SCENE:AddFragment(TroopTransport.fragment4)
	
end

function TroopTransport.ShowHideTTMainWindowOnClicked()

		
	if TroopTransport.HUDHidden then
		TroopTransport1:SetHidden(false)
		TroopTransport.HUDHidden = false
		HUD_SCENE:AddFragment(TroopTransport.fragment2)
		HUD_UI_SCENE:AddFragment(TroopTransport.fragment2)
	else
		TroopTransport1:SetHidden(true)
		TroopTransport.HUDHidden = true
		GroupDropDownWindow:SetHidden(true)
		FriendDropDownWindow:SetHidden(true)
		HUD_SCENE:RemoveFragment(TroopTransport.fragment2)
		HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment2)
		HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
		HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)
		HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
		HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)	
	end
	
end

function TroopTransport.ShowButtonBG()
	TroopTransportMainButtonBG:SetHidden(false)
end

function TroopTransport.HideButtonBG()
	TroopTransportMainButtonBG:SetHidden(true)
end

function TroopTransport.CreateGroupDropDown()

    local tlw = CreateTopLevelWindow("GroupDropDownWindow")
    tlw:SetDimensions(300, 80)
    tlw:SetAnchor(TOPLEFT, TroopTransport1, BOTTOMRIGHT, 0, 0)
    
    local bd = WINDOW_MANAGER:CreateControlFromVirtual("GroupDropDownBackdrop", tlw, "ZO_DefaultBackdrop")
	bd:SetAnchorFill()
    
    local comboBox = WINDOW_MANAGER:CreateControlFromVirtual("GroupDropDownList", tlw, "ZO_ComboBox")
    comboBox:SetDimensions(250, 30)
    comboBox:ClearAnchors()
    comboBox:SetAnchor(CENTER, tlw, CENTER, 0, 0)
	
	local closeButton = WINDOW_MANAGER:CreateControl("GroupListCloseButton", tlw, CT_BUTTON)
	closeButton:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, 0, 0)
	closeButton:SetDimensions(30, 30)
	closeButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
	closeButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
	closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
		closeButton:SetHandler("OnMouseDown", 
		function(self) 
			HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)
			GroupDropDownWindow:SetHidden(true) 
		end, 
	"TroopTransport")
    
    -- tooltip text
    comboBox.data = { tooltipText = "" }
    
    -- tooltip handlers
    comboBox:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    comboBox:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    
    local m_comboBox = comboBox.m_comboBox
    m_comboBox:SetSortsItems(false)
    
    -- easy access references from tlw
    -- tlw.backdrop = bd
    tlw.comboBox = comboBox
    tlw.m_comboBox = m_comboBox
    
    return tlw
end

function TroopTransport.CreateFriendDropDown()
    local tlw = CreateTopLevelWindow("FriendDropDownWindow")
    tlw:SetDimensions(300, 80)
    tlw:SetAnchor(TOPLEFT, TroopTransport1, BOTTOMRIGHT, 0, 0)
    
    local bd = WINDOW_MANAGER:CreateControlFromVirtual("FriendDropDownBackdrop", tlw, "ZO_DefaultBackdrop")
	bd:SetAnchorFill()
    
    local comboBox = WINDOW_MANAGER:CreateControlFromVirtual("FriendDropDownList", tlw, "ZO_ComboBox")
    comboBox:SetDimensions(250, 30)
    comboBox:ClearAnchors()
    comboBox:SetAnchor(CENTER, tlw, CENTER, 0, 0)
	
	local closeButton = WINDOW_MANAGER:CreateControl("FriendListCloseButton", tlw, CT_BUTTON)
	closeButton:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, 0, 0)
	closeButton:SetDimensions(30, 30)
	closeButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
	closeButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
	closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
	closeButton:SetHandler("OnMouseDown", 
		function(self) 
			HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)
			FriendDropDownWindow:SetHidden(true) 
		end, 
	"TroopTransport")
    
    -- tooltip text
    comboBox.data = { tooltipText = "" }
    
    -- tooltip handlers
    comboBox:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    comboBox:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    
    local m_comboBox = comboBox.m_comboBox
    m_comboBox:SetSortsItems(false)
    
    -- easy access references from tlw
    -- tlw.backdrop = bd
    tlw.comboBox = comboBox
    tlw.m_comboBox = m_comboBox
    
    return tlw
end

function TroopTransport.PopulateGroupComboBox(m_comboBox)
    m_comboBox:ClearItems()
    
    local function ItemSelectCallback(comboBox, itemName, item, selectionChanged)
		if itemName == "Select Group Member" or itemName == "No Group Found" then
			--do nothing
		else
        d("Traveling to " .. itemName)
		JumpToGroupMember(itemName)
		HUD_SCENE:RemoveFragment(TroopTransport.fragment3)
		HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment3)		
		GroupDropDownWindow:SetHidden(true)
        end
    end
 
	TroopTransport.GetGroupMembers()

 
    for k,name in ipairs(TroopTransport.GroupList) do
        local itemEntry = m_comboBox:CreateItemEntry(name, ItemSelectCallback)
        
        -- suppress update until were done adding items
        m_comboBox:AddItem(itemEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
--===============================================================--
    
    -- Update & select first item
    m_comboBox:UpdateItems()
    m_comboBox:SelectFirstItem()
end

function TroopTransport.PopulateFriendComboBox(m_comboBox)
    m_comboBox:ClearItems()
    
    local function ItemSelectCallback(comboBox, itemName, item, selectionChanged)
		if itemName == "Select Friend" then
			--do nothing
		else
			d("Traveling to " .. itemName)
			JumpToFriend(itemName)
			HUD_SCENE:RemoveFragment(TroopTransport.fragment4)
			HUD_UI_SCENE:RemoveFragment(TroopTransport.fragment4)
			FriendDropDownWindow:SetHidden(true)
		end

    end
 
	TroopTransport.GetFriends()

 
    for k,name in ipairs(TroopTransport.FriendList) do
        local itemEntry = m_comboBox:CreateItemEntry(name, ItemSelectCallback)
        
        -- suppress update until were done adding items
        m_comboBox:AddItem(itemEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
--===============================================================--
    
    -- Update & select first item
    m_comboBox:UpdateItems()
    m_comboBox:SelectFirstItem()
end

function TroopTransport.InitializeGroupComboBox()
    local tlw = TroopTransport.CreateGroupDropDown()
    TroopTransport.PopulateGroupComboBox(tlw.m_comboBox)
end

function TroopTransport.InitializeFriendComboBox()
    local tlw = TroopTransport.CreateFriendDropDown()
    TroopTransport.PopulateFriendComboBox(tlw.m_comboBox)
end