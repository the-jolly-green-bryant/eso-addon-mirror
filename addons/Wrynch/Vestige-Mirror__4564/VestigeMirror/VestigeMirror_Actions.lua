VestigeMirror = VestigeMirror or {}
VestigeMirror.Actions = {}

local PLAYER_ACTOR_CATEGORY = GAMEPLAY_ACTOR_CATEGORY_PLAYER
local RESTORE_FRAMING_DELAY_MS = 200
local MEMENTO_DATA_TYPE = 1
local MEMENTO_ROW_HEIGHT = 46

local function ShowMessage(message)
    if CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage("|cFFFF00Vestige Mirror:|r " .. message)
    end
end

function VestigeMirror.Actions:Initialize()
    self.panel = VestigeMirrorMementoPicker
    self.list = self.panel:GetNamedChild("List")
    self.title = self.panel:GetNamedChild("Title")
    self.count = self.panel:GetNamedChild("Count")
    self.mementos = {}

    self.panel:ClearAnchors()
    self.panel:SetAnchor(
        BOTTOMRIGHT,
        VestigeMirrorTextureBar:GetNamedChild("Mementos"),
        TOPRIGHT,
        0,
        -8)

    ZO_ScrollList_AddDataType(
        self.list,
        MEMENTO_DATA_TYPE,
        "VestigeMirrorMementoRow",
        MEMENTO_ROW_HEIGHT,
        function(control, data)
            self:SetupRow(control, data)
        end)
end

function VestigeMirror.Actions:RefreshMementos()
    local mementos = {}
    local count = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)

    for index = 1, count do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, index)
        if collectibleId and collectibleId > 0 then
            local name, _, icon, _, unlocked = GetCollectibleInfo(collectibleId)
            if unlocked and IsCollectibleValidForPlayer(collectibleId) then
                local formattedName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name)
                table.insert(mementos,
                {
                    id = collectibleId,
                    name = formattedName,
                    sortName = formattedName:lower(),
                    icon = icon,
                })
            end
        end
    end

    table.sort(mementos, function(left, right)
        return left.sortName < right.sortName
    end)

    self.mementos = mementos
end

function VestigeMirror.Actions:SetupRow(row, memento)
    row.memento = memento
    row:GetNamedChild("Icon"):SetTexture(memento.icon)
    row:GetNamedChild("Name"):SetText(memento.name)
    row:GetNamedChild("Highlight"):SetHidden(true)

    row:SetHandler("OnMouseEnter", function(control)
        control:GetNamedChild("Highlight"):SetHidden(false)
    end)
    row:SetHandler("OnMouseExit", function(control)
        control:GetNamedChild("Highlight"):SetHidden(true)
    end)
    row:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if PlaySound and SOUNDS and SOUNDS.DEFAULT_CLICK then
                PlaySound(SOUNDS.DEFAULT_CLICK)
            end
            self:UseMemento(memento)
        end
    end)
end

function VestigeMirror.Actions:RefreshList()
    ZO_ScrollList_Clear(self.list)
    local dataList = ZO_ScrollList_GetDataList(self.list)

    for _, memento in ipairs(self.mementos) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(MEMENTO_DATA_TYPE, memento))
    end

    ZO_ScrollList_Commit(self.list)
    ZO_ScrollList_ResetToTop(self.list)
end

function VestigeMirror.Actions:ShowMementoPicker()
    self:RefreshMementos()
    if #self.mementos == 0 then
        ShowMessage("No unlocked mementos are available for this character.")
        return
    end

    self:RefreshList()
    self.title:SetText("Mementos")
    self.count:SetText(tostring(#self.mementos))
    self.panel:SetHidden(false)
end

function VestigeMirror.Actions:HideMementoPicker()
    if self.panel then
        self.panel:SetHidden(true)
    end
end

function VestigeMirror.Actions:ToggleMementoPicker()
    if self:IsMementoPickerShowing() then
        self:HideMementoPicker()
    else
        self:ShowMementoPicker()
    end
end

function VestigeMirror.Actions:IsMementoPickerShowing()
    return self.panel and not self.panel:IsHidden()
end

function VestigeMirror.Actions:RunOutsideFraming(callback)
    if not VestigeMirror.Scene:IsShowing() then
        callback()
        return
    end

    ITEM_PREVIEW_KEYBOARD:EndCurrentPreview()
    VestigeMirror.Preview.active = false
    SetFrameLocalPlayerInGameCamera(false)

    zo_callLater(function()
        callback()

        zo_callLater(function()
            if not VestigeMirror.Scene:IsShowing() then
                return
            end

            SetFrameLocalPlayerInGameCamera(true)
            RequestReframeLocalPlayerInGameCamera()

            if VestigeMirror.Scene.appearance then
                VestigeMirror.Preview:ShowAppearance(VestigeMirror.Scene.appearance)
                VestigeMirror.UI:ApplyFrame()
            end
        end, RESTORE_FRAMING_DELAY_MS)
    end, 0)
end

function VestigeMirror.Actions:UseMemento(memento)
    self:HideMementoPicker()
    self:RunOutsideFraming(function()
        UseCollectible(memento.id, PLAYER_ACTOR_CATEGORY)
    end)
end
