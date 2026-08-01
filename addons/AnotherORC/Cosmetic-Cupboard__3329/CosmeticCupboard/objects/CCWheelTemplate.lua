--[[
    Wheel items
]]
local CCWheelItem = ZO_Object:Subclass()

function CCWheelItem:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function CCWheelItem:Initialize(control)
    self.m_control = control
    self.m_textureControl = control:GetNamedChild("Image")
end

function CCWheelItem:SetData(owner, data)
    self.m_owner = owner
    self.m_itemData = data
    self.m_texture = data.texture or 'eosui/art/quickslots/quickslot_emptySlot.dds'

    self:UpdateItem()
end

function CCWheelItem:UpdateItem()
    self.m_textureControl:SetTexture(self.m_texture)

    local x, y = self.m_owner:GetItemDimensions()

    self.m_control:SetDimensions(x, y)
    self.m_control:SetHidden(false)
end


--[[
    Wheel template
]]

local CCWheelTemplate = ZO_Object:Subclass()

function CCWheelTemplate:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function CCWheelTemplate:Initialize(control)
    self.m_control = control
    self.m_items = {}
end

function CCWheelTemplate:Reset()
    self._pool:ReleaseAllObjects()
    self.m_items = {}
end

function CCWheelTemplate:GetItemDimensions()
    return self.itemSizeX, self.itemSizeY
end

function CCWheelTemplate:SetData(data)
    if self._pool ~= nil then return end

    self._pool = ZO_ControlPool:New(data.buttonTemplate or "CC_WheelItem")
    self._pool:SetCustomResetBehavior(function(control)
        control.m_object:Reset()
    end)

    self.itemSizeX = data.itemWidth or 80
    self.itemSizeY = data.itemHeight or 80
end

--[[
    Add an item to the wheel.
    This does not update the wheel visuals
]]
function CCWheelTemplate:AddItem(itemData)
    local item, key = self._pool:AcquireObject()
    item.m_object:SetData(self, itemData)
    table.insert(self.m_items, { item, key, itemData.descriptor })
    return item
end

--[[
    Create the wheel layout
]]
local INITIAL_ROTATION = 0
function CCWheelTemplate:PerformSlotLaylout()
    local width, height = self.m_control:GetDimensions()
    local scale = self.m_control:GetScale()
    local halfWidth, halfHeight = width * scale * 0.5, height * scale * 0.5
    local numSlots = #self.m_items

    for i = 1, numSlots do
        local control = self.m_items[i][1]
        local centerAngle = INITIAL_ROTATION + i / numSlots * ZO_TWO_PI
        local x, y = math.sin(centerAngle), math.cos(centerAngle)

        if math.abs(x) < 0.01 then
            x = 0
        end

        control:SetAnchor(TOPLEFT, self.m_control, TOPLEFT, 0, 0)
        control:SetDimensions(100, 100)
        control:SetHidden(false)
    end
end

--[[
    When changes are made we need to update the icons
]]
function CCWheelTemplate:UpdateSlots(slotId, slotData)
end

--[[
    Item
]]
function CC_WheelItem_OnInitialized(self)
    self.m_object = CCWheelItem:New(self)
end

function CC_WheelItem_SetData(self, data)
    self.m_object:SetData(data)
end

function CC_WheelItem_Build(self)

end

--[[
    Template
]]
function CC_WheelTemplate_OnInitialized(self)
    self.m_object = CCWheelTemplate:New(self)
end

function CC_WheelTemplate_SetData(self, data)
    self.m_object:SetData(data)
end

function CC_WheelTemplate_InitializeSlots(self)
    self.m_object:PerformSlotLaylout()
end

function CC_WheelTemplate_AddItem(self, itemData)
    return self.m_object:AddItem(itemData)
end

function CC_WheelTemplate_UpdateSlot(self, slotId, slotData)
    self.m_object:UpdateSlots(slotId, slotData)
end