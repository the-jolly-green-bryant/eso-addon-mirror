
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Icons = {}

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, v = pcall(fn, ...)
    if not ok then return nil end
    return v
end

function Icons.class(classId)
    if not classId or classId == 0 then return nil end
    return safe(GetClassIcon, classId)
end

Icons.ROLE = {
    dps    = "EsoUI/Art/LFG/LFG_icon_dps.dds",
    healer = "EsoUI/Art/LFG/LFG_icon_healer.dds",
    tank   = "EsoUI/Art/LFG/LFG_icon_tank.dds",
}

Icons.XP  = "EsoUI/Art/Icons/Icon_Experience.dds"
Icons.CP  = "EsoUI/Art/Champion/champion_icon_32.dds"

function Icons.ap()
    local C = BGMeter.zenimax.constants
    return safe(BGMeter.zenimax.api.get_currency_icon, C.CURT_ALLIANCE_POINTS)
end

function Icons.medal(medalId)
    local info = Icons.medal_info(medalId)
    return info and info.icon or nil
end

local medal_bank = {}

function Icons.medal_info(medalId)
    if not medalId then return nil end
    local cached = medal_bank[medalId]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end
    if type(GetMedalInfo) ~= "function" then return nil end
    local ok, name, icon, condition, reward = pcall(GetMedalInfo, medalId)
    if not ok or not name or name == "" then
        medal_bank[medalId] = false
        return nil
    end
    local info = { name = name, icon = icon, condition = condition, reward = reward }
    medal_bank[medalId] = info
    return info
end

function Icons.scan_medal_ids(limit, cap)
    local found = {}
    for id = 1, (limit or 300) do
        if Icons.medal_info(id) then
            found[#found + 1] = id
            if #found >= (cap or 8) then break end
        end
    end
    return found
end

BGMeter.Icons = Icons
