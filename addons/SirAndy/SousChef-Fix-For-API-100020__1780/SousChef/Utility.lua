local SousChef = SousChef
local u =  SousChef.Utility
local colors = {
	["green"] = "|c00ff00",
	["blue"] = "|c0066ff",
	["purple"] = "|c782ee6",
	["gold"] = "|cE6B800",
	["white"] = "|cFFFFFF",
	["ending"] = "|r",
}

function u.GetItemID(link)
    if link == "" or not link then return -1 end
    local itemid = select(4,ZO_LinkHandler_ParseLink(link))  
	return tonumber(itemid)
end

function u.GetColoredLinkName(link)
	if link == nil or link == "" then return "" end
	local plainName = GetItemLinkName(link)
	local color = GetItemLinkQuality(link)
	local coloredName
	if color == ITEM_QUALITY_NORMAL then -- white
		return colors.white .. zo_strformat("<<t:1>>", plainName) .. colors.ending
	elseif color == ITEM_QUALITY_MAGIC then -- green
		return colors.green .. zo_strformat("<<t:1>>", plainName) .. colors.ending
	elseif color == ITEM_QUALITY_ARCANE then -- blue
		return colors.blue .. zo_strformat("<<t:1>>", plainName) .. colors.ending
	elseif color == ITEM_QUALITY_ARTIFACT then -- purple
		return colors.purple .. zo_strformat("<<t:1>>", plainName) .. colors.ending
	elseif color == ITEM_QUALITY_LEGENDARY then -- gold
		return colors.gold .. zo_strformat("<<t:1>>", plainName) .. colors.ending
	else
		return zo_strformat("<<t:1>>", plainName)
	end
	return coloredName
end

function u.EndsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function u.StartsWith(String,Start)
    return Start=='' or string.sub(String, 1, string.len(Start))==Start
end

local separators = {"%^[%a:]+", "-", " " }

function u.Compress(entry)
    if not entry or entry == "" then return "" end
    for _,v in pairs(separators) do
        entry = entry:gsub(v, "")
    end
    return entry
end

function u.CleanString(entry)
    if not entry or entry == "" then return "" end
    return u.Compress(entry):lower()
end

function u.TableKeyConcat(t)
    local tt = {}
    for k in pairs(t) do tt[#tt+1]=k end
    return table.concat(tt, ", ")
end

function u.MatchInIgnoreList(name)
    name = u.CleanString(name)
    for recipe in pairs(SousChef.settings.ignoredRecipes) do
        if u.CleanString(recipe) == name then return true end
    end
    return false
end
