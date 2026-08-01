TREASURE_MAP_LISTING = ZO_InitializingObject:Subclass()
local TML = TREASURE_MAP_LISTING
local LT_ITEMCACHE = LOST_TREASURE.internal.itemCache
local LT_UTILITIES = LOST_TREASURE.internal.utilities

local categories = {
    current = { id = 1, expanded = true },
    treasure = { id = 2, expanded = true },
    survey = { id = 3, expanded = true },
    clue = { id = 4, expanded = true },
    lookup = function(id)
        for k, v in pairs(TML.categories) do
            if type(v) == "table" then
                if (v.id == id) then
                    return k;
                end
            end
        end
    end
}
TML.categories = categories

TREASURE_MAP_LISTING_ENTRY_HEIGHT = 50
TREASURE_MAP_LISTING_CATEGORY_HEIGHT = 40

local TREASURE_MAP_LISTING_ENTRY = 1
local TREASURE_MAP_LISTING_HEADER = 2

local list

function TML:Initialize(control)
    self.control = control

    self.fragment = ZO_FadeSceneFragment:New(control)
    self.fragment:RegisterCallback("StateChange",  function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:OnShowing()
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            self:OnHidden()
        end
    end)

    self:SetNoItemsLabelControl(control:GetNamedChild("NoItemsLabel"))

    self:InitializeList(control)

    local function UpdateForModeChange(modeData)
        self:SetListEnabled(WORLD_MAP_MANAGER:IsMapChangingAllowed())
    end

    local function RefreshList()
        self:RefreshList()
    end

    local TreasureMapsButtonData = {
        normal = "EsoUI/Art/tradinghouse/tradinghouse_trophy_treasure_map_up.dds",
        pressed = "EsoUI/Art/tradinghouse/tradinghouse_trophy_treasure_map_down.dds",
        highlight = "EsoUI/Art/tradinghouse/tradinghouse_trophy_treasure_map_over.dds"
    }
    WORLD_MAP_INFO.modeBar:Add("Treasure Maps", { self.fragment }, TreasureMapsButtonData)

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", UpdateForModeChange)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", RefreshList)
    --TODO: Add Item pickup event for adding new maps.
end

function TML:InitializeList(control)
    list = control:GetNamedChild("List")

    local function ResetMap(entryControl)
        ZO_ObjectPool_DefaultResetControl(entryControl)
        entryControl.mapData = nil
    end

    local NO_HIDE_CALLBACK = nil
    local NO_SELECT_SOUND = nil

    local function SetupMap(entryControl, entryData)
        entryControl.mapData = entryData.mapData
        entryControl.nameLabel:SetText(entryData.mapData.slotData.itemLink)
    end
    ZO_ScrollList_AddDataType(list, TREASURE_MAP_LISTING_ENTRY, "TREASURE_MAP_LISTING_ENTRY", TREASURE_MAP_LISTING_ENTRY_HEIGHT, SetupMap, NO_HIDE_CALLBACK, NO_SELECT_SOUND, ResetMap)

    local function SetupHeader(headerControl, data)
        headerControl.label:SetText(data.text)
        headerControl.data = data
    end
    ZO_ScrollList_AddDataType(list, TREASURE_MAP_LISTING_HEADER, "TREASURE_MAP_LISTING_HEADER", TREASURE_MAP_LISTING_CATEGORY_HEIGHT, SetupHeader)

    ZO_ScrollList_EnableHighlight(list, "ZO_TallListHighlight")
end

function TML:SetListEnabled(enabled)
    listEnabled = enabled

    ZO_ScrollList_RefreshVisible(list)
end

function TML:GetData()
    local uniqueIdList = LT_ITEMCACHE.uniqueIdList
    local data = {}
    data[1] = { name = "Current Zone", data = {} }
    data[2] = { name = "Treasure Maps", data = {} }
    data[3] = { name = "Surveys", data = {} }
    data[4] = { name = "Clues", data = {} }

    for _, slotData in pairs(uniqueIdList) do
        local mapData = LibTreasure_GetItemIdData(slotData.itemId)
        mapData.slotData = slotData
        if (mapData.mapId == GetCurrentMapId()) then
            table.insert(data[1]["data"], mapData)
        elseif mapData.pinType == "treasure" then
            table.insert(data[2]["data"], mapData)
        elseif mapData.pinType == "survey" then
            table.insert(data[3]["data"], mapData)
        elseif mapData.pinType == "clue" then
            table.insert(data[4]["data"], mapData)
        end
    end
    return data
end

function TML:RefreshList()
    ZO_ScrollList_Clear(list)
    local scrollData = ZO_ScrollList_GetDataList(list)

    local data = self:GetData()

    for k, v in pairs(data) do
        if not v.hidden and #v.data > 0 then
            local category = self.categories.lookup(k)
            local expanded = self.categories[category].expanded
            local text = v.name .. " (" .. #v.data ..")"

            if expanded then
                text = "-  " .. text .. "  -"
            else
                text = "V  " .. text .. "  V"
            end

            local dataHeader = ZO_ScrollList_CreateDataEntry(TREASURE_MAP_LISTING_HEADER, { text = text, category = category })
            table.insert(scrollData, dataHeader)
            if (expanded) then
                for k2, v2 in pairs(v.data) do
                    local _, _, _, zoneIndex, _ = GetMapInfoById(v2.mapId)
                    local zoneId = GetZoneId(zoneIndex)
                    v2.zoneId = zoneId
                    local dataEntry = ZO_ScrollList_CreateDataEntry(TREASURE_MAP_LISTING_ENTRY, { mapData = v2 } )
                    table.insert(scrollData, dataEntry)
                end
            end
        end
    end

    ZO_ScrollList_Commit(list)
end

function TML:ShowOnMap(control)
    ZO_WorldMapManager:SetMapById(control.mapData.mapId)
    --TODO: Add `RALLY_POINT` style pin to treasure location.
end

function TML:PortToZone(zoneId)
    d("attempting to warp to " ..zoneId)
    local result = BMU.createTable({index=6, fZoneId=zoneId, dontDisplay=true})
    local firstRecord = result[1]
    if firstRecord.displayName ~= "" then
        BMU.PortalToPlayer(firstRecord.displayName, firstRecord.sourceIndexLeading, firstRecord.zoneName, firstRecord.zoneId, firstRecord.category, true, true, true)
    elseif firstRecord.isOwnHouse then
        BMU.portToOwnHouse(false, firstRecord.houseId, true, firstRecord.parentZoneName)
    else
        local s = "[" .. BMU.var.appNameAbbr .. "]: " .. BMU.formatName(GetZoneNameById(fZoneId), BMU.savedVarsAcc.formatZoneName) .. " - " .. BMU.SI.get(BMU.SI.TELE_CHAT_NO_FAST_TRAVEL)
        d(s)
        a(s)
    end
end

function TML:EntryClicked(control, button)
    local texturePath = "/esoui/art/treasuremaps/" .. control.mapData.texture .. ".dds"
    control:GetParent():GetParent():GetParent():GetNamedChild("Texture"):SetTexture(texturePath)

    if button == MOUSE_BUTTON_INDEX_LEFT then
        self:ShowOnMap(control)
    elseif button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()
        AddMenuItem("Show on map", function()
            self:ShowOnMap(control)
        end)

        if (os.date("%m/%d") == "10/17") then
            AddMenuItem("Happy Birthday FusionLord!", function() end)
        end

        if BMU then
            AddMenuItem("|t18:18:"..BMU.textures.wayshrineBtn.."|t [BMU] Warp to Zone", function()
                TML:PortToZone(control.mapData.zoneId)
            end)
        end
        ShowMenu(control)
    end
end

function TML:EntryMouseEnter(control)
    ZO_ScrollList_MouseEnter(list, control)
end

function TML:EntryMouseExit(control)
    ZO_ScrollList_MouseExit(list, control)
end

function TML:SetNoItemsLabelControl(control)
    self.noItemsLabel = control
end

function TML:OnShowing()
    self:RefreshList()
end

function TML:OnHidden()
end

-- Global XML functions
function TREASURE_MAP_LISTING_HEADER_CLICK(control, button, upInside)
    if upInside then
        TML.categories[control.data.category].expanded = not TML.categories[control.data.category].expanded
        TML:RefreshList()
    end
end

function TREASURE_MAP_LISTING_ENTRY_CLICK(control, button, upInside)
    if upInside then
        TML:EntryClicked(control, button)
    end
end

function TREASURE_MAP_LISTING_ENTRY_BMU_CLICK(control, button, upInside)
    if upInside then
        TML:PortToZone(control.mapData.zoneId)
    end
end

function TREASURE_MAP_LISTING_OnMouseEnter(control)
    TML:EntryMouseEnter(control)
end

function TREASURE_MAP_LISTING_OnMouseExit(control)
    TML:EntryMouseExit(control)
end

function TREASURE_MAP_LISTING_OnInitialized(self)
    TREASURE_MAP_LISTING = TML:New(self)
end
