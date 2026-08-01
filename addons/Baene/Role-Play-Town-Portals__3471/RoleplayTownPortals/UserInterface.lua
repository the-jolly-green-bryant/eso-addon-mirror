
if not RTP then RTP = { } end
if not RTP.UI then RTP.UI = { } end
if not RTP.UTIL then RTP.UTIL = { } end

RTP.UI.IndicatorTooltip = "Role-Play Town Portals"

local libScroll = LibScroll
local selectDestinationScrollList

local SelectDestinationSceneState = SCENE_HIDDEN
local TravelConfirmationSceneState = SCENE_HIDDEN

local SelectedDestinationId = 0

-- XML User Interface handling code
function RTP.UI.OnIndicatorButtonMouseEnter()
    ZO_Tooltips_ShowTextTooltip(RTPIndicatorButton, BOTTOMRIGHT, RTP.UI.IndicatorTooltip)
end

function RTP.UI.OnIndicatorButtonMouseExit()
    ZO_Tooltips_HideTextTooltip()
end

-- Context Menu
function RTP.UI.ShowIndicatorContextMenu()
    ClearMenu()

    if IsControlKeyDown() then
        AddCustomMenuItem("Generate Portal text", function() RTP.UI.GeneratePortalText() end)
    end

    for townId,town in pairs(RTP.Towns) do
        local publicLocations = {}
        local index = 1
        for _,location in pairs(RTP.Locations) do
            if location.public and location.townId == townId then
                local locationName = RTP.BuildLocationName(location)

                publicLocations[index] = {
                    label = locationName,
                    callback = function() 
                        RTP.UI.JumpToPortalLocationById(location.id)
                    end
                }
                
                index = index + 1
            end
        end

        AddCustomSubMenuItem(town.name.." Public Locations", publicLocations)
    end

    local minimizedIndex = AddCustomMenuItem("Minimize UI", 
            function() 
                RTP.SavedVars.IndicatorMinimized = not RTP.SavedVars.IndicatorMinimized
                RTP.IndicatorMinimizedChanged()
            end,
            MENU_ADD_OPTION_CHECKBOX
    )

    if RTP.SavedVars.IndicatorMinimized then
        ZO_CheckButton_SetChecked(ZO_Menu.items[minimizedIndex].checkbox)
    else
        ZO_CheckButton_SetUnchecked(ZO_Menu.items[minimizedIndex].checkbox)
    end
    
    ShowMenu()
end

function RTP.UI.GeneratePortalText()
    local houseId = GetCurrentZoneHouseId()
    local owner = GetCurrentHouseOwner()
    local zoneId, x, y, z = GetUnitRawWorldPosition("player")
    local normalizedX, normalizedZ = GetMapPlayerPosition("player")
    local _, map = LibMapPins:GetZoneAndSubzone()
    local locationId = -1
    
    for _,location in pairs(RTP.Locations) do
        if location.houseId == houseId and location.owner == owner then
            locationId = location.id
        end
    end
    
    d(string.format("Map: [%i] = {id = %i, map = \"%s\"},", houseId, houseId, map))
    d(string.format("Location: {id = %i, houseId = %i, owner = \"%s\", townId = 1, name = \"Name goes here\"},", locationId, houseId, owner))
    d(string.format("Portal: {location = %i, destinations = {##}, x = %i, y = %i, z = %i, cx = %f, cy = %f},", locationId, x, y, z, normalizedX, normalizedZ))
end

-- Dialogs
function RTP.UI.ShowTravelConfirmation(portal)
    local body = RTPTravelConfirmationDialog:GetNamedChild("BodyContainer"):GetNamedChild("Body")
    local destination = RTP.Locations[portal.destinations[1]]
    local town = RTP.Towns[destination.townId]
    local title = RTPTravelConfirmationDialog:GetNamedChild("Title")

    SelectedDestinationId = destination.id

    if portal.portalDescription ~= nil then
        body:SetText(portal.portalDescription)
    else 
        if destination.description ~= nil then
            body:SetText(destination.description)
        else 
            body:SetText("|cffffffThis is a portal to |c00ffff"..RTP.BuildLocationName(destination, portal).." in |c00ffff"..town.name.."|cffffff. Would you like to travel there now? ")
        end
    end

    if portal.nameOverride ~= nil then
        title:SetText(portal.nameOverride)
    else
        title:SetText(destination.name)
    end

    SCENE_MANAGER:Toggle("RTPTravelConfirmation")
end

local travelKeybindDesc = {
        name = "Travel Now",
        keybind = "UI_SHORTCUT_PRIMARY",
        callback = function()
            SCENE_MANAGER:Toggle("RTPTravelConfirmation")
            RTP.UI.JumpToPortalLocationById(SelectedDestinationId) 
        end,
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
}

local function SetupDestinationRow(rowControl, data, scrollList)
    rowControl:SetText(data.name)
    rowControl:SetFont("ZoFontWinH6")
    rowControl:SetHandler("OnMouseUp", function() 
        ZO_ScrollList_MouseClick(scrollList, rowControl)
    end)
end

local function OnDestinationSelected(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    if SelectDestinationSceneState == SCENE_SHOWN then
        SCENE_MANAGER:Toggle("RTPSelectDestination")
    end
    RTP.UI.JumpToPortalLocationById(selectedData.id)
end

function RTP.UI.ShowSelectLocationDialog(portal)
    local body = RTPSelectDestinationDialog:GetNamedChild("BodyContainer"):GetNamedChild("Body")
    local title = RTPSelectDestinationDialog:GetNamedChild("Title")

    body:SetText(portal.portalDescription)
    title:SetText(portal.nameOverride)
    
    selectDestinationScrollList:Clear()
    
    if portal.destinations ~= nil and GetTableLength(portal.destinations) > 0 then
        local destinations = {}
        local index = 1
        
        for _, v in pairs(portal.destinations) do
            local location = RTP.Locations[v]
            
            destinations[index] = { name = location.name, id = v }
            index = index + 1
        end

        selectDestinationScrollList:Update(destinations)
    end
    
    SCENE_MANAGER:Toggle("RTPSelectDestination")
end

function RTP.UI.JumpToPortalLocationById(locationId)
    local location = RTP.Locations[locationId]

    d("Travelling to "..location.name.."...")
    RTP.UI.JumpToPortalLocation(location.owner, location.houseId)
end

function RTP.UI.JumpToPortalLocation(owner, houseId)
    if owner == GetDisplayName() then
        RequestJumpToHouse(houseId)
    else
        JumpToSpecificHouse(owner, houseId)
    end
end

local function AddDivider(name, parent, width)
    local divider = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    divider:SetDimensions(width, 10)
    divider:SetAnchor(TOPLEFT, parent, TOP_LEFT, 5, 55)
    divider:SetTexture("/esoui/art/miscellaneous/wide_divider_left.dds")
end

local function SetupScene(name, dialogFragment, callback)
    local scene = ZO_Scene:New(name, SCENE_MANAGER)
    
    scene:RegisterCallback("StateChange", callback)
    scene:AddFragment(dialogFragment)
    scene:AddFragment(STOP_MOVEMENT_FRAGMENT)
    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
end

local function SortScrollList(objA, objB)
    return objA.data.name:len() < objB.data.name:len()
end

function RTP.UI.InitializeDestinationList()
    local listContainer = RTPSelectDestinationDialog:GetNamedChild("List")
    
    AddDivider("SelectTitleDivider", RTPSelectDestinationDialog, 350)
    AddDivider("TravelTitleDivider", RTPTravelConfirmationDialog, 460)

    local scrollData = {
        name = "SelectDestinationScrollList",
        parent = listContainer,

        width = 195,
        height = 240,
        rowHeight = 23,

        setupCallback = SetupDestinationRow,
        selectCallback = OnDestinationSelected,
        sortFunction = SortScrollList
    }

    selectDestinationScrollList = libScroll:CreateScrollList(scrollData)
    selectDestinationScrollList:SetAnchor(TOPLEFT, listContainer, TOPLEFT, 15, 3)

    SetupScene("RTPSelectDestination", ZO_SimpleSceneFragment:New(RTPSelectDestinationDialog), 
            function(oldState, newState) SelectDestinationSceneState = newState end)
    SetupScene("RTPTravelConfirmation", ZO_SimpleSceneFragment:New(RTPTravelConfirmationDialog),
            function(oldState, newState)
                TravelConfirmationSceneState = newState
                if newState == SCENE_HIDDEN then
                    KEYBIND_STRIP:RemoveKeybindButton(travelKeybindDesc)
                end
                if newState == SCENE_SHOWN then
                    KEYBIND_STRIP:AddKeybindButton(travelKeybindDesc)
                end
            end)
end
