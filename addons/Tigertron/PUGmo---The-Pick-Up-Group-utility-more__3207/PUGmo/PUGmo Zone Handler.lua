if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

-------------------------------------------------------------------------
--- Zone Handler
-------------------------------------------------------------------------
function PUG:zoneHandler(channel, _, msg, _, name)
    local mtime = os.time()
    local xtime = mtime + PUG.SV.xtime
    local guild = channel
    local lfg, wts, lfgcat, wtscat
    lfg, lfgcat = PUG:checkLFG(msg)
    wts, wtscat = PUG:checkWTS(msg)
    local bl = PUG:checkBlackList(msg, name)
    local keywords = ""
    if lfg then
        keywords = lfg
        wts = nil
        wtscat = nil
    end
    if wts then
        keywords = wts
    end

    if (not lfg and not wts) or bl then
        --- it is not processed
        return
    end

    if PUG.data.delay == 0 then
        --- interval is in milliseconds
        EM:RegisterForUpdate(PUG.data.zoneListCB, (PUG.SV.xtime * 1000) - 500, function(...)
            while PUG:windowRefresh() do
            end
        end)
        PUG.data.delay = PUG.SV.xtime + os.time()
    end

    --- clean up the window list mostly to purge expired messages now
    while PUG:windowRefresh() do
    end

    --- update the record if there is already a message from the same sender
    local index, z, msgs = PUG:updateMsg(name, msg)
    msg = string.gsub(msg, "|H%d:item:.-|h|h", "<item link>")
    --- update the record from the variables
    PUG.zoneBuffer[index] = {
        name = name,
        msg = z .. msg,
        msgs = msgs,
        channel = channel,
        xtime = xtime,
        lfg = lfg,
        wts = wts,
        keywords = keywords,
        index = index,
        guild = guild,
        category = lfgcat or wtscat or 0,
    }
    --- clean up again
    while PUG:windowRefresh() do
    end
end

-------------------------------------------------------------------------
function PUG:updateMsg(name, msg)
    local x = PUG.SV.xtime
    local y = #PUG.zoneBuffer
    local z = PUG.color.yellow .. os.date("%M:%S", 0) .. "|r "
    local msgs = {}
    for i = 1, y do
        --- update message if already a message from player in buffer
        if PUG.zoneBuffer[i].name == name then
            for j = 1, #PUG.zoneBuffer[i].msgs do
                table.insert(msgs, PUG.zoneBuffer[i].msgs[j])
            end
            x = x - (PUG.zoneBuffer[i].xtime - os.time())
            if x > PUG.SV.xtime then
                x = PUG.SV.xtime
            end
            y = i - 1
            z = PUG.color.orange .. os.date("%M:%S", x) .. "|r "
            break
        end
    end
    table.insert(msgs, msg)
    return y + 1, z, msgs
end

-------------------------------------------------------------------------
function PUG:windowRefresh()

    --- callback handler might overlap so this prevents it -- put in because of odd crashes -- need to test
    if PUG.data.blocked then
        return true
    end
    PUG.data.blocked = true
    --- remove expired messages
    PUG:purgeExpired()
    --- update the screen
    PUG:updateZoneLists()

    if #PUG.zoneBuffer == 0 and PUG.data.delay < os.time() then
        EM:UnregisterForUpdate(PUG.data.zoneListCB)
        PUG.data.delay = 0
    end

    PUG.data.blocked = false
    return false
end

-------------------------------------------------------------------------
function PUG:purgeExpired()

    local y = #PUG.zoneBuffer
    if y == 0 then
        return
    end
    --- sort by time
    table.sort(PUG.zoneBuffer, function(a, b)
        return a.xtime > b.xtime
    end)
    --- remove expired messages and reindex table
    local temp = {}
    local j = 1
    for i = 1, y do
        if PUG.zoneBuffer[i].xtime > os.time() and j < 41 then
            --- not expired yet and buffer is not full so move it in
            PUG.zoneBuffer[i].msg = string.gsub(PUG.zoneBuffer[i].msg, "%d%d:%d%d", os.date("%M:%S", PUG.SV.xtime - (PUG.zoneBuffer[i].xtime - os.time())))
            table.insert(temp, PUG.zoneBuffer[i])
            --- reindex what was added
            temp[j].index = j
            j = j + 1
        end
    end

    PUG.zoneBuffer = {}     --- clear the old
    PUG.zoneBuffer = temp   --- and copy the new
end

-------------------------------------------------------------------------
function PUG:updateZoneLists()
    local categories = {}
    if #PUG.zoneBuffer == 0 then
        ZO_ScrollList_Clear(PUGmoWindowZoneListLFG)
        ZO_ScrollList_Clear(PUGmoWindowZoneListWTS)
        for x = 1, 4 do
            ZO_ScrollList_AddCategory(PUGmoWindowZoneListLFG, x, nil)
            ZO_ScrollList_AddCategory(PUGmoWindowZoneListWTS, x, nil)
        end
        ZO_ScrollList_Commit(PUGmoWindowZoneListLFG)
        ZO_ScrollList_Commit(PUGmoWindowZoneListWTS)
        return
    end

    local entries = ZO_DeepTableCopy(PUG.zoneBuffer)
    local dataList = {}

    dataList = ZO_ScrollList_GetDataList(PUGmoWindowZoneListWTS)
    categories = ZO_DeepTableCopy(PUGmoWindowZoneListWTS.categories)
    ZO_ScrollList_Clear(PUGmoWindowZoneListWTS)
    PUGmoWindowZoneListWTS.categories = categories
    for i = 1, #entries do
        if entries[i].wts then
            ---Creates a data entry for use in the scroll list. Add it to the data list then commit it. Step 2.
            ---ZO_ScrollList_CreateDataEntry(typeId, data, categoryId)
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(1, entries[i], entries[i].category)
        end
    end

    dataList = ZO_ScrollList_GetDataList(PUGmoWindowZoneListLFG)
    categories = ZO_DeepTableCopy(PUGmoWindowZoneListLFG.categories)
    ZO_ScrollList_Clear(PUGmoWindowZoneListLFG)
    PUGmoWindowZoneListLFG.categories = categories
    for i = 1, #entries do
        if entries[i].lfg then
            ---Creates a data entry for use in the scroll list. Add it to the data list then commit it. Step 2.
            ---ZO_ScrollList_CreateDataEntry(typeId, data, categoryId)
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(1, entries[i], entries[i].category)
        end
    end

    --- Commit the list. Step 3.
    ZO_ScrollList_Commit(PUGmoWindowZoneListLFG)
    ZO_ScrollList_Commit(PUGmoWindowZoneListWTS)

end

-------------------------------------------------------------------------
function PUG:checkBlackList(msg, name)
    for i = 1, #PUG.playerBlacklist do
        return string.find(name, PUG.playerBlacklist[i])
    end

    local s = string.upper(msg)
    for i = 1, #PUG.SV.itemBlacklist do
        local bl = string.find(s, PUG.SV.itemBlacklist[i])
        --PUG:debug("Blacklisted: " .. (bl or "none"))
        if bl then
            return bl
        end
    end
    return false
end

-------------------------------------------------------------------------
function PUG:checkLFG(text)
    local patterns = {
        "(%sLF%s)", "^(LF%s)",
        "(%sLF[%dMG]%s)", "^(LF[%dMG]%s)","(LF[%dMG])$",
        "(LOOKING%sFOR)",
        "(ALL%sROLES)",
        "(%d?%s?%d?HEAL)",
        "(%d?%s?%d?TANK)",
        "(%d?%s?%d?DPS)",
        "(%d?%s?%d?DD%s)", "^(%d?%s?%d?DD%s)", "(%d?%s?%d?DD)$",
        "(RANDOM)", "(%sRND?)",
        "(PLEDGES)",
        "(DAILY)", "(DAILIES)",
        "(NORMA?L?)",
        "(VETERAN)", "(VET%s)",
        "(DUNGEON)",
        "(QUEST)",
        "(%s%a%sFOR%s)", "^(%a%sFOR%s)",
        "(TRIAL)",
        "(FARM)",
        "(GROUP)",
        "(GTG)",
        "(HELP%s)", "(HELP)$",
        "(%sWB%s)", "^(WB%s)", "(%sWB)$",
        "(WORLD%sBOSSE?S?)",
        "(NEED%s)",
        "(%s[NV]?CR%+?%d?%s)", "^([NV]?CR%+?%d?%s)", "(%s[NV]?CR%+?%d?)$", --- nCR+3
        "(%s[NV]?AA%s)", "^([NV]?AA%s)", "(%s[NV]?AA)$",
        "(%s[NV]?SS%s)", "^([NV]?SS%s)", "(%s[NV]?SS)$",
        "(%s[NV]AS%s)", "^([NV]AS%s)", "(%s[NV]AS)$",
        "(%s[NV]SO%s)", "^([NV]SO%s)", "(%s[NV]SO)$",
        "([NV]?MOL%s)",
        "([NV]?KA)",
        "([NV]?RG)",
        "([NV]?HOF)",
        "([NV]?HRC)",
        "([NV]?BRP)",
        "([NV]?DSA)",
    }
    local s = string.upper(text)
    local t, u = {}, {}

    local v = ""
    local i = 1
    local category = 1
    local spos, epos, key
    spos = string.find(s, "LF")
    if spos == 1 then
        category = 2
    end
    for j = 1, #patterns do
        spos, epos, key = string.find(s, patterns[j])
        if key then
            t[i] = {
                key = key,
                spos = spos,
            }
            i = i + 1
        end
    end
    --- return false if not at least two keywords found
    if #t < PUG.SV.minLFGKeys then
        return false
    end
    table.sort(t, function(a, b)
        return a.spos < b.spos
    end)

    for j = 1, #t do
        for w in string.gmatch(t[j].key, "(%w+)") do
            table.insert(u, w)
        end
    end
    v = table.concat(u, " ")
    return v, category
end

-------------------------------------------------------------------------
--- WTB WTS WTT FREE BUY SELL TRADE |H%d:ITEM:.-|H|H CROWNS CRAFTER
-- TODO the timer messes with links     ["msg"] = "00:12: WTS |H1:item:167000:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" vs correct ["wts"] = "WTS |H1:ITEM:167009:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|H"
-------------------------------------------------------------------------
function PUG:checkWTS(text)
    if not PUG.SV.wtsOn then
        return false
    end
    local patterns = {
        "(WT[BST])", "(LTB)",
        "(SELL)",
        "(BUY)",
        "(CROWNS?)",
        "(BITE)",
        "(TRADE)",
        "(FREE)",
        "(CRAFT)",
        "(CARRY)",
        "(|H%d:ITEM:.-|H|H)",
        "(%sSR%s)",
        "(N?BRP%s)",
    }
    local s, t, u = string.upper(text), {}, {}
    --- look for keywords
    local spos, epos, key
    local category = 3
    spos = string.find(s, "WTB")
    if spos then
        category = 4
    end
    local i = 1
    for j = 1, #patterns do
        spos, epos, key = string.find(s, patterns[j])
        if key then
            t[i] = {
                key = key,
                spos = spos,
            }
            i = i + 1
        end
    end
    --- return false if not at least one keyword found
    if #t < PUG.SV.minWTSKeys then
        return false
    end
    --- sort them in order found so that keywords make more sense
    table.sort(t, function(a, b)
        return a.spos < b.spos
    end)
    --- build the keyword string
    for j = 1, #t do
        for w in string.gmatch(t[j].key, "(%S+)") do
            table.insert(u, w)
        end
    end
    return table.concat(u, " "), category
end

-------------------------------------------------------------------------
function PUG:delListUnitRow(index)
    if IsShiftKeyDown() then
        table.insert(PUG.playerBlacklist, PUG.zoneBuffer[index].name)
    end
    table.remove(PUG.zoneBuffer, index)
    while PUG:windowRefresh() do
    end
end

