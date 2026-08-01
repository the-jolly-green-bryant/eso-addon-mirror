local YEI = {}

local FrameTexture = "YssEquipmentIndicator/Frame2.dds"
--local FrameTexture = "YssEquipmentIndicator/frame_background.dds"
--local FrameTexture = "YssEquipmentIndicator/frame_overlay.dds"

-- underlay
--local drawlayer = 0

-- overlay
local drawlayer = 10

YEI.Frames = {}
YEI.FramesBySlot = {}

local texSize = 44 --size of item texture
local texoffset = 2 -- frame border thickness
local frametexsize = texSize + (texoffset*2)

function YEI:AddFrame(parent, slot)
	local frame = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
		frame:SetDimensions(frametexsize,frametexsize)
		frame:SetAnchor(BOTTOM, parent, BOTTOM, 0,texoffset)
		frame:SetTexture(FrameTexture)
		frame:SetDrawLevel(drawlayer)
		local frameEmpty = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
			frameEmpty:SetDimensions(frametexsize,frametexsize)
			frameEmpty:SetAnchor(BOTTOM, frame, TOP, 0,0)
			frameEmpty:SetTexture(FrameTexture)
			frameEmpty:SetDrawLevel(drawlayer)
		frame.emptypart = frameEmpty
	self.FramesBySlot[slot] = frame
	self.Frames[#self.Frames + 1] = slot
	self:UpdateFrame(slot)
end

function YEI:UpdateFrame(slot)
	local frame = self.FramesBySlot[slot]
	local frameEmpty = frame.emptypart
	local equipable = IsEquipable(0, slot)
	frame:SetHidden(not equipable)
	frameEmpty:SetHidden(not equipable)
	if equipable then
		local c = GetItemQualityColor(select(8, GetItemInfo(0, slot)))
		frame:SetColor(c.r, c.g, c.b, .8)
		local percentage = 50 --some random number :P
		if IsItemChargeable(0, slot) then
			local charge, max_charge = GetChargeInfoForItem(0, slot)
			percentage = charge/max_charge
		else
			percentage = GetItemCondition(0, slot)/100
		end
		--local repair = math.random() --use for debug or screenshots :)
		frame:SetTextureCoords(0,1,1-percentage,1)
		frame:SetHeight(frametexsize*percentage)
		frameEmpty:SetColor(c.r/3, c.g/3, c.b/3, .7)
		frameEmpty:SetTextureCoords(0,1,0,1-percentage)
		frameEmpty:SetHeight(frametexsize*(1-percentage))
	end
end

function YEI:ForceUpdate()
	for i=1, #self.Frames do
		self:UpdateFrame(self.Frames[i])
	end
end

local EVENT_INVENTORY_SINGLE_SLOT_UPDATE = EVENT_INVENTORY_SINGLE_SLOT_UPDATE

local function EventHandler(eventCode, ...)
	if eventCode == EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
		local bagId, slotId = ...
		if bagId == BAG_WORN and slotId ~= EQUIP_SLOT_BACKUP_POISON and slotId ~= EQUIP_SLOT_POISON then
			YEI:UpdateFrame(slotId)
		end
	elseif eventCode == EVENT_ADD_ON_LOADED and "YssEquipmentIndicator" == ... then
		YEI:SetupFrames()
	end
end

local function OnShow(frame, ...)
	YEI:ForceUpdate()
	-- call old OnShow function if it exists
	if YEI.OldOnShow then
		return YEI.OldOnShow(frame, ...)
	end
end

function YEI:SetupFrames()
	local slots = {
		["EQUIP_SLOT_BACKUP_MAIN"] = "ZO_CharacterEquipmentSlotsBackupMain",
		["EQUIP_SLOT_BACKUP_OFF"] = "ZO_CharacterEquipmentSlotsBackupOff",
		["EQUIP_SLOT_CHEST"] = "ZO_CharacterEquipmentSlotsChest",
		["EQUIP_SLOT_COSTUME"] = "ZO_CharacterEquipmentSlotsCostume",
		["EQUIP_SLOT_FEET"] = "ZO_CharacterEquipmentSlotsFoot",
		["EQUIP_SLOT_HAND"] = "ZO_CharacterEquipmentSlotsGlove",
		["EQUIP_SLOT_HEAD"] = "ZO_CharacterEquipmentSlotsHead",
		["EQUIP_SLOT_LEGS"] = "ZO_CharacterEquipmentSlotsLeg",
		["EQUIP_SLOT_MAIN_HAND"] = "ZO_CharacterEquipmentSlotsMainHand",
		["EQUIP_SLOT_NECK"] = "ZO_CharacterEquipmentSlotsNeck",
		["EQUIP_SLOT_OFF_HAND"] = "ZO_CharacterEquipmentSlotsOffHand",
		["EQUIP_SLOT_RING1"] = "ZO_CharacterEquipmentSlotsRing1",
		["EQUIP_SLOT_RING2"] = "ZO_CharacterEquipmentSlotsRing2",
		["EQUIP_SLOT_SHOULDERS"] = "ZO_CharacterEquipmentSlotsShoulder",
		["EQUIP_SLOT_WAIST"] = "ZO_CharacterEquipmentSlotsBelt",
	}

	for slotName, frameName in pairs(slots) do
		self:AddFrame(_G[frameName], _G[slotName])
	end

	EVENT_MANAGER:RegisterForEvent("YssEquipmentIndicator", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EventHandler)

	-- save old OnShow function so we can call it again
	self.OldOnShow = ZO_Character:GetHandler("OnShow")
	ZO_Character:SetHandler("OnShow", OnShow)
end

-- Lets start this thing
EVENT_MANAGER:RegisterForEvent("YssEquipmentIndicator", EVENT_ADD_ON_LOADED, EventHandler)
