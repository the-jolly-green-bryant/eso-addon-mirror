local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

local RPF = RPFlagger

function RPF:GetLongText(characterName, note)
	if not note or note == "" then return nil end
	local start, stop, text = RPF:GetSingleTag(note, "TXT_" .. characterName)
	if text then return text end
	
	start, stop, text = RPF:GetSingleTag(note, "TXT")
	return text
end

function RPF:DisplayLongTxt()
	local dn = GetUnitDisplayName("reticleover")
	local cn = GetUnitName("reticleover")
	
	if not cn or cn == "" then return true end
	
	local longtxt = self:GetCharacterRPInfo(dn, cn,
		function(cn, note) return RPF:GetLongText(cn, note) end )
	
	if not longtxt then
		longtxt = zo_strformat(GetString(SI_RPF_LONGTXT_NONE), cn)
	else
		longtxt = zo_strformat(_tr("|c88ffffOn <<1>> you notice something...|r\n|c88ffff<<2>>|r"), cn, longtxt)
	end
	
	CHAT_SYSTEM:AddMessage(longtxt)
	return true
end