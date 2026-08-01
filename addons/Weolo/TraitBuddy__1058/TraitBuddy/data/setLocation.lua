local sf = string.format
local zo_cachedstr = ZO_CachedStrFormat

local ID_GLENUMBRA = 3
local ID_STORMHAVEN = 19
local ID_RIVENSPIRE = 20
local ID_STONEFALLS = 41
local ID_DESHAAN = 57
local ID_MALABALTOR = 58
local ID_BANGKORAI = 92
local ID_EASTMARCH = 101
local ID_THERIFT = 103
local ID_ALIKRDESERT = 104
local ID_GREENSHADE = 108
local ID_SHADOWFEN = 117
local ID_AURIDON = 381
local ID_REAPERSMARCH = 382
local ID_GRAHTWOOD = 383

local function GetAlliance(zoneId)
	if zoneId==ID_STONEFALLS or zoneId==ID_DESHAAN or zoneId==ID_EASTMARCH or zoneId==ID_THERIFT or zoneId==ID_SHADOWFEN then
		return ALLIANCE_EBONHEART_PACT
	elseif zoneId==ID_GLENUMBRA or zoneId==ID_STORMHAVEN or zoneId==ID_RIVENSPIRE or zoneId==ID_BANGKORAI or zoneId==ID_ALIKRDESERT then
		return ALLIANCE_DAGGERFALL_COVENANT
	elseif zoneId==ID_MALABALTOR or zoneId==ID_GREENSHADE or zoneId==ID_AURIDON or zoneId==ID_REAPERSMARCH or zoneId==ID_GRAHTWOOD then
		return ALLIANCE_ALDMERI_DOMINION
	else
		return ALLIANCE_NONE
	end
end

TB_Data_SetLocation = ZO_Object:Subclass()
function TB_Data_SetLocation:New(zone)
	local o = ZO_Object.New(self)
	o.zoneId = zone.id
	o.icon = zone.icon or "esoui/art/treeicons/store_indexicon_dungdlc_up.dds"
	o.alliance = GetAlliance(o.zoneId)
	return o
end

function TB_Data_SetLocation:GetFullname()
	local parentZoneId = GetParentZoneId(self.zoneId)
	if parentZoneId and parentZoneId ~= self.zoneId then
		return sf("%s - %s", GetZoneNameById(parentZoneId), GetZoneNameById(self.zoneId))
	else
		return GetZoneNameById(self.zoneId)
	end
end

function TB_Data_SetLocation:GetIcon()
	if self.alliance == ALLIANCE_NONE then
		return self.icon
	else
		return GetAllianceSymbolIcon(self.alliance)
	end
end

function TB_Data_SetLocation:GetFormattedText()
	local icon = self:GetIcon()
	if icon then
		return zo_iconTextFormat(icon, 32, 32, self:GetFullname())
	else
		return zo_cachedstr(SI_ZONE_NAME, self:GetFullname())
	end
end