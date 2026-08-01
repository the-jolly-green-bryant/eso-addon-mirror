local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

local RPF = RPFlagger

function RPF:GetTitleText(characterName, note)
	if not note or note == "" then return nil end
	local start, stop, text = RPF:GetSingleTag(note, "RP_" .. characterName)
	if text then return text end
	
	start, stop, text = RPF:GetSingleTag(note, "RP")
	return text
end

function RPF:GetReplacementTitle(accountName, characterName)
	return self:GetCharacterRPInfo(accountName, characterName,
		function(cn, note) return RPF:GetTitleText(cn, note) end )
end


-- Hook into the original (or already patched) GetTitle and GetUnitTitle functions
local GetUnitTitle_original = GetUnitTitle
local GetTitle_original = GetTitle

local function GetUnitInfo(unitTag)
	local unitTitleOriginal = GetUnitTitle_original(unitTag)
	local unitDisplayName = GetUnitDisplayName(unitTag)
	local unitCharacterName = GetUnitName(unitTag)

	return unitTitleOriginal, unitDisplayName, unitCharacterName
end

local function GetPlayerInfo(index)
	local unitTitleOriginal = GetTitle_original(index)
	local unitDisplayName = GetDisplayName()
	local unitCharacterName = GetUnitName("player")

	return unitTitleOriginal, unitDisplayName, unitCharacterName
end

local function GetUnitTitle_patched(unitTag)
	local to, dn, cn = GetUnitInfo(unitTag)
	local tr = RPF:GetReplacementTitle(dn, cn)
	return tr or to
end

local function GetTitle_patched(index)
	local to, dn, cn = GetPlayerInfo(index)
	local tr = RPF:GetReplacementTitle(dn, cn)
	return tr or to
end

GetTitle = GetTitle_patched
GetUnitTitle = GetUnitTitle_patched
