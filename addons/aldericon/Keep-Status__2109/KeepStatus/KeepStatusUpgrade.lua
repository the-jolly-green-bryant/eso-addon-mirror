
KeepStatus.Upgrade = {}
KeepStatus.Upgrade.__index = KeepStatus.Upgrade
KeepStatus.Upgrade.type = "Upgrade"

setmetatable(KeepStatus.Upgrade, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

local Upgrade = KeepStatus.Upgrade

Upgrade.new = function(keepId)
    local self = setmetatable({}, Upgrade)

    self.keepId = keepId
    self.keepName = GetKeepName(self.keepId)
	self.keepAlliance = 0

	self.lumbermillLevel = 0
	self.mineLevel = 0
	self.farmLevel = 0
	self.lumbermillKeepId = GetResourceKeepForKeep(self.keepId, RESOURCETYPE_WOOD)
	self.mineKeepId = GetResourceKeepForKeep(self.keepId, RESOURCETYPE_ORE)
	self.farmKeepId = GetResourceKeepForKeep(self.keepId, RESOURCETYPE_FOOD)
	self.lumbermillAlliance = 0
	self.mineAlliance = 0
	self.farmAlliance = 0
	
    self:update()

    return self
end

local L_ICON = "img1"
local L_NAME, L_LUMBERMILL, L_MINE, L_FARM = "txt1", "txt2", "txt3", "txt4"
local verticalY = 5

function Upgrade:configureLabel(label)
	local startHorizontalX = 200

    label:exposeControls(1,4)

    label:positionControl(L_ICON, 40, 40, -2, -2)
    label:positionControl(L_NAME, 150, 30, 35, 5)

	label:positionControl(L_LUMBERMILL, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)
	startHorizontalX = startHorizontalX + 30
    label:positionControl(L_FARM, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)
	startHorizontalX = startHorizontalX + 30
	label:positionControl(L_MINE, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)
end

function Upgrade:updateLabel(label)
    label:getControl(L_ICON):SetTexture(self:getIcon())
	
	local keepColor = Upgrade.getColor(self.keepAlliance)
	label:getControl(L_ICON):SetColor(keepColor:UnpackRGBA())

    local name = label:getControl(L_NAME)
    name:SetText(self.keepName)
    name:SetColor(keepColor:UnpackRGBA())

    local lumbermillLabel = label:getControl(L_LUMBERMILL)
    lumbermillLabel:SetText(self.lumbermillLevel)
    lumbermillLabel:SetColor(Upgrade.getColor(self.lumbermillAlliance):UnpackRGBA())

    local mineLabel = label:getControl(L_MINE)
    mineLabel:SetText(self.mineLevel)
    mineLabel:SetColor(Upgrade.getColor(self.mineAlliance):UnpackRGBA())

    local farmLabel = label:getControl(L_FARM)
    farmLabel:SetText(self.farmLevel)
    farmLabel:SetColor(Upgrade.getColor(self.farmAlliance):UnpackRGBA())

    label.main:SetCenterColor(self:getBGColor():UnpackRGBA())
end

function Upgrade:update()
	self.lumbermillLevel = Upgrade.getResourceLevel(self.keepId, RESOURCETYPE_WOOD)
	self.mineLevel = Upgrade.getResourceLevel(self.keepId, RESOURCETYPE_ORE)
	self.farmLevel = Upgrade.getResourceLevel(self.keepId, RESOURCETYPE_FOOD)
	self.keepAlliance = Upgrade.getKeepAlliance(self.keepId)
	self.lumbermillAlliance = Upgrade.getKeepAlliance(self.lumbermillKeepId)
	self.mineAlliance = Upgrade.getKeepAlliance(self.mineKeepId)
	self.farmAlliance = Upgrade.getKeepAlliance(self.farmKeepId)

	if not self:needsUpgrade() then
        KeepStatus.upgrades[self.keepId] = nil
    end
end

function Upgrade:getBGColor()
    return KeepStatus.defaultBGColor
end

function Upgrade:needsUpgrade()
	if Upgrade.getKeepAlliance(self.keepId) ~= KeepStatus.playerAlliance or Upgrade.isKeepUA(self.keepId) == true then
		return false
	end

	-- because resource max level is 2
	if (self.lumbermillLevel + self.mineLevel + self.farmLevel) < 6 then
		return true
	end

    if self.lumbermillAlliance ~= KeepStatus.playerAlliance or self.mineAlliance ~= KeepStatus.playerAlliance or self.farmAlliance ~= KeepStatus.playerAlliance then
		return true
	end

	return false
end

function Upgrade.getColor(alliance)
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		return ZO_ColorDef:New(.765, .667, .290, 1)
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		return ZO_ColorDef:New(.408, .560, .698, 1)
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		return ZO_ColorDef:New(.871, .361, .310, 1)
	end
end

function Upgrade.getKeepAlliance(keepId)
	return GetKeepAlliance(keepId, BGQUERY_LOCAL)
end

function Upgrade.isKeepUA(keepId)
	return GetKeepUnderAttack(keepId, BGQUERY_LOCAL)
end

function Upgrade.getResourceLevel(keepId, resourceType)
	return GetKeepResourceLevel(keepId, BGQUERY_LOCAL, resourceType) 
end

function Upgrade:getIcon()
    return '/esoui/art/mappins/ava_largekeep_neutral.dds'
end
