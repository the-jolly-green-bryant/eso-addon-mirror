MPPCDC = {}
local MPPCDC = MPPCDC

MPPCDC.name = "MPPCharDataCollector"
MPPCDC.version = "1.6"

MPPCDC.defaults = {
    characters = {},
    showUpdateInfo = false,
    showNewDataInfo = false,
    safeguard = false,
}

-- 1 week in seconds
MPPCDC.UpdateTheshold = 60 * 60 * 24 * 7
MPPCDC.SafeGuardThreshold = 100000

local function DataCount()
    local count = 0
    for _ in pairs(MPPCDC.SV.characters) do count = count + 1 end
    return count
end

local function GetNumTrackedCharactersWithRole()
    local count = 0
    for _, data in pairs(MPPCDC.SV.characters) do
        if data.role and data.role ~= LFG_ROLE_INVALID then
            count = count + 1
        end
    end
    return count
end

local function GetRoleName(roleID, plural)
    local format = plural and "<<m:1>>" or "<<1>>"
    if roleID == LFG_ROLE_HEAL then
        return zo_strformat(format, GetString(MPP_ROLE_HEAL))
    elseif roleID == LFG_ROLE_TANK then
        return zo_strformat(format, GetString(MPP_ROLE_TANK))
    elseif roleID == LFG_ROLE_DPS then
        return zo_strformat(format, GetString(MPP_ROLE_DD))
    else
        return "Unknown/Invalid"
    end
end

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function tableContains(table, value)
  for _, v in pairs(table) do
    if v == value then return true end
  end
  return false
end

function MPPCDC.MainCommand(option)
    if not option or option == "" then
        d(GetString(MPP_COMMAND_USAGE))
        return
    end
    
    -- Parse arguments
    local options = {}
    for substr in option:gmatch("%S+") do table.insert(options, substr) end
    
    -- Full flag
    local full = false
    if tableContains(options, "full") or tableContains(options, "f") then
        full = true
    end
    
    -- Percentages flag
    local percentages = false
    if tableContains(options, "percentage") or tableContains(options, "p") then
        percentages = true
    end
    
    --d("[MPP Character Data Collector] Starting report")
    
    -- Modes
    if tableContains(options, "count") then
        d(GetString(MPP_HEADER_COUNT))
        
    -- Functional commands
    elseif tableContains(options, "purge") then
        MPPCDC.Purge()
        return
    elseif tableContains(options, "deletedatabase") then
        ZO_Dialogs_ShowDialog("MPPCDC_CONFIRM_DELETION")
        return
    elseif tableContains(options, "import") then
        MPPCDC.Import()
        return
    elseif tableContains(options, "find") then
        MPPCDC.Find(options[2])
        return
    elseif tableContains(options, "upgrade") then
        MPPCDC.FixDataBase()
        return
        
    -- Toggle commands
    elseif tableContains(options, "toggle") and tableContains(options, "update") then
        MPPCDC.SV.showUpdateInfo = not MPPCDC.SV.showUpdateInfo
        d("Messages disabled: " .. MPPCDC.SV.showUpdateInfo)
        return
    elseif tableContains(options, "toggle") and tableContains(options, "new") then
        MPPCDC.SV.showNewDataInfo = not MPPCDC.SV.showNewDataInfo
        d("Messages disabled: " .. MPPCDC.SV.showNewDataInfo)
        return
    elseif tableContains(options, "toggle") and tableContains(options, "safeguard") then
        MPPCDC.SV.safeguard = not MPPCDC.SV.safeguard
        d("Safeguard enabled: " .. MPPCDC.SV.safeguard)
        return
        
    -- Report commands
    elseif tableContains(options, "race") or tableContains(options, "r") then
        MPPCDC.CreateReport("race", full, percentages)
    elseif tableContains(options, "class") or tableContains(options, "c") then
        MPPCDC.CreateReport("class", full, percentages)
    elseif tableContains(options, "gender") or tableContains(options, "g") then
        MPPCDC.CreateReport("gender", full, percentages)
    elseif tableContains(options, "alliance") or tableContains(options, "a") then
        MPPCDC.CreateReport("alliance", full, percentages)
    elseif tableContains(options, "combination") or tableContains(options, "co") then
        MPPCDC.CreateReport("combination", full, percentages)
    elseif tableContains(options, "role") or tableContains(options, "ro") then
        MPPCDC.CreateReport("role", full, percentages)
    elseif tableContains(options, "everything") or tableContains(options, "e") then
        MPPCDC.CreateReport("race", full, percentages)
        MPPCDC.CreateReport("class", full, percentages)
        MPPCDC.CreateReport("gender", full, percentages)
        MPPCDC.CreateReport("alliance", full, percentages)
        MPPCDC.CreateReport("combination", full, percentages)
        MPPCDC.CreateReport("role", full, percentages)
    elseif tableContains(options, "avgcp") then
        MPPCDC.CreateAverage("cp")
    elseif tableContains(options, "avgeffcp") then
        MPPCDC.CreateAverage("effcp")
    elseif tableContains(options, "avglvl") then
        MPPCDC.CreateAverage("lvl")
    elseif tableContains(options, "avgava") then
        MPPCDC.CreateAverage("avarank")
    elseif tableContains(options, "mpc") then
        MPPCDC.CreateReport("mostplayedclass", full, percentages, options[2])
    elseif tableContains(options, "mpr") then
        MPPCDC.CreateReport("mostplayedrace", full, percentages, options[2])
    elseif tableContains(options, "mostplayedroleclass") or tableContains(options, "mprc") then
        MPPCDC.CreateReport("mostplayedroleclass", full, percentages, options[2])
    elseif tableContains(options, "mostplayedrolerace") or tableContains(options, "mprr") then
        MPPCDC.CreateReport("mostplayedrolerace", full, percentages, options[2])
    elseif tableContains(options, "mostplayedrolecombo") or tableContains(options, "mprco") then
        MPPCDC.CreateReport("mostplayedrolecombo", full, percentages, options[2], options[3])
    elseif tableContains(options, "roleforclass") or tableContains(options, "roc") then
        MPPCDC.CreateReport("roleforclass", full, percentages, options[2])
    elseif tableContains(options, "roleforrace") or tableContains(options, "ror") then
        MPPCDC.CreateReport("roleforrace", full, percentages, options[2])
    elseif tableContains(options, "roleforcombo") or tableContains(options, "roco") then
        MPPCDC.CreateReport("roleforcombo", full, percentages, options[2])
    elseif tableContains(options, "group") or tableContains(options, "grp") then
        MPPCDC.CreateGroupReport(full, percentages)
    elseif tableContains(options, "player") or tableContains(options, "plr") then
        MPPCDC.CreatePlayerReport(full, percentages)
    elseif tableContains(options, "maxcp") then
        MPPCDC.CreateMax("cp")
    elseif tableContains(options, "uniqueplayers") or tableContains(options, "up") then
        MPPCDC.UniquePlayers()
    else
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, SI_ERROR_INVALID_COMMAND)
        d(GetString(MPP_COMMAND_UNKNOWN))
        return
    end

    d(zo_strformat(GetString(MPP_CHARS_RECORDED), DataCount()))
    --d("[MPP Character Data Collector] End of report")
end

function MPPCDC.Find(search)
    -- If the search starts with "@" we are looking for account wide data
    if string.sub(search, 1, 1) == "@" then
        -- Account report
        local findings = {}
        local accountName = ""
        for char, data in pairs(MPPCDC.SV.characters) do
            if data.account:lower() == search:lower() then
                findings[char] = data
                if accountName == "" then accountName = data.account end
            end
        end
              
        local count = 0
        for _ in pairs(findings) do
            count = count + 1
        end
              
        if count == 0 then
            d(zo_strformat(MPP_FIND_NOTHING, ZO_LinkHandler_CreateDisplayNameLink(search)))
        else
            d(zo_strformat(MPP_FIND_HEADER, count, ZO_LinkHandler_CreateDisplayNameLink(accountName)))
            local i = 1
            
            
            
            for char, data in pairs(findings) do
                local genderIcon = data.gender == GENDER_MALE and "/esoui/art/charactercreate/charactercreate_maleicon_up.dds" or "/esoui/art/charactercreate/charactercreate_femaleicon_up.dds"               
                
                local format = "|t24:24:<<2>>|t<<C:3>>"
                if data.alliance == ALLIANCE_ALDMERI_DOMINION then -- Aldmeri Dominion
                    format = "|cc3aa4a|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                elseif data.alliance == ALLIANCE_EBONHEART_PACT then -- Ebonheart Pact
                    format = "|cde594a|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                elseif data.alliance == ALLIANCE_DAGGERFALL_COVENANT then -- Daggerfall Covenant
                    format = "|c688fb2|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                end
                local ava = zo_strformat(format, GetAvARankIcon(data.avaRank), GetAvARankName(data.gender, data.avaRank)) 
                
                local charInfo = zo_strformat("<<1>><<2>> <<3>>", zo_iconFormat(genderIcon, 24, 24), GetRaceName(data.gender, data.race), GetClassName(data.gender, data.class))
                local level = zo_strformat("Level: <<1>>", GetLevelOrChampionPointsString(data.level, data.championPoints, 16))

                d(zo_strformat("|ceda600<<1>>. - <<2>>:|r", i, ZO_LinkHandler_CreateCharacterLink(char)))
                d(zo_strformat("|ceda600|          |        <<1>>. <<2>>, <<3>>|r", charInfo, level, ava))
                i = i + 1
            end
        end
    else
        -- Character lookup
        for char, data in pairs(MPPCDC.SV.characters) do
            if char:lower() == search:lower() then
                local genderIcon = data.gender == GENDER_MALE and "/esoui/art/charactercreate/charactercreate_maleicon_up.dds" or "/esoui/art/charactercreate/charactercreate_femaleicon_up.dds"               
                
                local format = "|t24:24:<<2>>|t<<C:3>>"
                if data.alliance == ALLIANCE_ALDMERI_DOMINION then -- Aldmeri Dominion
                    format = "|cc3aa4a|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                elseif data.alliance == ALLIANCE_EBONHEART_PACT then -- Ebonheart Pact
                    format = "|cde594a|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                elseif data.alliance == ALLIANCE_DAGGERFALL_COVENANT then -- Daggerfall Covenant
                    format = "|c688fb2|t24:24:<<1>>:inheritcolor|t<<C:2>>|r"
                end
                local ava = zo_strformat(format, GetAvARankIcon(data.avaRank), GetAvARankName(data.gender, data.avaRank)) 
                
                local charInfo = zo_strformat("<<1>><<2>> <<3>>", zo_iconFormat(genderIcon, 24, 24), GetRaceName(data.gender, data.race), GetClassName(data.gender, data.class))
                local level = zo_strformat("Level: <<1>>", GetLevelOrChampionPointsString(data.level, data.championPoints, 16))

                local ls = GetTimeStamp() - data.lastUpdate
                ls = ls - (ls % 86400)
                
                local timeText = ZO_FormatTime(ls, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING)
                local timesince = zo_strformat(SI_TIME_DURATION_AGO, timeText)
                if ls < 86400 then
                    if GetSecondsSinceMidnight() < ls then
                        timesince = "yesterday"
                    else
                        timesince = "today"
                    end
                end
                
                
                d(zo_strformat(MPP_FIND_CHAR_L1, ZO_LinkHandler_CreateCharacterLink(char), ZO_LinkHandler_CreateDisplayNameLink(data.account), timesince))
                d(zo_strformat(MPP_FIND_CHAR_L2, charInfo, level, ava))
                return
            end
        end
        d(zo_strformat(MPP_FIND_CHAR_FAIL, search))
    end
end

function MPPCDC.CreateGroupReport(full, percentages)
    if GetGroupSize() < 2 then
        d(GetString(MPP_GROUP_NO_GROUP))
        return
    end
    
    d(GetString(MPP_HEADER_GROUP))
    
    --Collect data
    local cpsum = 0
    local cpmin = 810
    local cpmax = 0
    
    local avasum = 0
    local avamin = 50
    local avamax = 0
    
    local genders = {}
    local alliances = {}
    
    for i = 1, GetGroupSize() do
        local cp = GetUnitChampionPoints("group" .. i)
        cpmin = math.min(cpmin, cp)
        cpmax = math.max(cpmax, cp)
        cpsum = cpsum + cp
        
        local ava = GetUnitAvARank("group" .. i)
        avamin = math.min(avamin, ava)
        avamax = math.max(avamax, ava)
        avasum = avasum + ava
        
        if genders[GetUnitGender("group" .. i)] == nil then
            genders[GetUnitGender("group" .. i)] = 1
        else
            genders[GetUnitGender("group" .. i)] = genders[GetUnitGender("group" .. i)] + 1
        end
        
        if alliances[GetUnitAlliance("group" .. i)] == nil then
            alliances[GetUnitAlliance("group" .. i)] = 1
        else
            alliances[GetUnitAlliance("group" .. i)] = alliances[GetUnitAlliance("group" .. i)] + 1
        end
    end
    
    --Generate report
    d(GetString(MPP_HEADER_AVG_CP))
    d(zo_strformat(GetString(MPP_GROUP_CP), string.format("%.2f", cpsum / GetGroupSize()), cpmin, cpmax))
    
    d(GetString(MPP_HEADER_GENDER))
    d(zo_strformat(GetString(MPP_GROUP_GENDER), genders[GENDER_FEMALE], string.format("(%.2f%%)", (genders[GENDER_FEMALE] / GetGroupSize()) * 100), genders[GENDER_MALE], string.format("(%.2f%%)", (genders[GENDER_MALE] / GetGroupSize()) * 100)))
    
    if full then
        d(GetString(MPP_HEADER_ALLIANCES))
        for k, v in alliances do
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetAllianceName(k), v, p))
        end
        
        d(GetString(MPP_HEADER_AVG_AVA))
        d(zo_strformat(GetString(MPP_AVG_AVA), string.format("(%.2f)", avasum / GetGroupSize()), GetAvARankName(GENDER_NEUTER, math.floor(avamin)), GetAvARankName(GENDER_NEUTER, math.floor(avamax))))
    end
end

function MPPCDC.CreatePlayerReport()
    -- TODO (?)
end

function MPPCDC.UniquePlayers()
    local players = {}
    for _, character in pairs(MPPCDC.SV.characters) do
        if players[character.account] == nil then
            players[character.account] = 1
        else
            players[character.account] = players[character.account] + 1
        end
    end
    
    local count = 0
    local total = DataCount()
    for _ in pairs(players) do count = count + 1 end
    
    d(GetString(MPP_HEADER_ACCOUNTS))
    d(zo_strformat(GetString(MPP_PLAYERS_1), count, total, string.format("%.2f", total/count)))
    
    local max = 0
    for k, v in spairs(players, function(t, a, b) return t[b] < t[a] end) do
        if v >= max then break end
        max = v
        d(zo_strformat(GetString(MPP_PLAYERS_2), k, v))
    end
end

function MPPCDC.CreateMax(mode)
    if mode == "cp" then
        local maxcp = 0
        local name = ""
        local displayname = ""
        for charname, character in pairs(MPPCDC.SV.characters) do
            if character.championPoints > maxcp then
                maxcp = character.championPoints
                name = charname
                displayname = character.account
            end
        end
        d(GetString(MPP_HEADER_MAX_CP))
        d(zo_strformat(GetString(MPP_MAX_CP), maxcp, name, displayname))
    else
        d(GetString(MPP_MODE_UNKNOWN))
        return
    end
end

function MPPCDC.CreateReport(mode, full, percentage, ...)
    local id, extra1, extra2 = ... -- Used for most played classes by race and most played races by class
    local total = 0 -- Used for most played classes by race and most played races by class
    
    local pre = ""
    if not full then pre = " Top 3" end
    if mode == "race" then
        d(zo_strformat(GetString(MPP_HEADER_RACES), pre))
    elseif mode == "class" then
        d(zo_strformat(GetString(MPP_HEADER_CLASSES), pre))
    elseif mode == "alliance" then
        d(GetString(MPP_HEADER_ALLIANCES))
    elseif mode == "gender" then
        d(GetString(MPP_HEADER_GENDER))
    elseif mode == "combination" then
        d(zo_strformat(GetString(MPP_HEADER_COMBO), pre))
    elseif mode == "mostplayedclass" then
        full = true
        id = tonumber(id)
        if id < 1 or id > 10 then
            d(GetString(MPP_INVALID_RACE))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_CLASS_DETAIL), GetRaceName(GENDER_NEUTER, id)))
    elseif mode == "mostplayedrace" then
        full = true
        id = tonumber(id)
        if id < 1 or id > 6 then
            d(GetString(MPP_INVALID_CLASS))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_RACE_DETAIL), GetClassName(GENDER_NEUTER, id)))
    elseif mode == "role" then
        d(GetString(MPP_HEADER_ROLES))
    elseif mode == "mostplayedroleclass" then
        full = true
        id = tonumber(id)
        if id < 1 or id > 6 then
            d(GetString(MPP_INVALID_CLASS))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_ROLES_DETAIL), GetClassName(GENDER_NEUTER, id)))
    elseif mode == "mostplayedrolerace" then
        full = true
        id = tonumber(id)
        if id < 1 or id > 10 then
            d(GetString(MPP_INVALID_RACE))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_ROLES_DETAIL), GetRaceName(GENDER_NEUTER, id)))
    elseif mode == "mostplayedrolecombo" then
        full = true
        id = tonumber(id)
        extra1 = tonumber(extra1)
        if not id or id < 1 or id > 10 then
            d(GetString(MPP_INVALID_RACE))
            return
        end
        if not extra1 or extra1 < 1 or extra1 > 6 then
            d(GetString(MPP_INVALID_CLASS))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_ROLES_DETAIL), GetClassName(GENDER_NEUTER, extra1), GetRaceName(GENDER_NEUTER, id).." "))
    elseif mode == "roleforclass" then
        full = true
        if id == "heal" then
            id = LFG_ROLE_HEAL
        elseif id == "tank" then
            id = LFG_ROLE_TANK
        elseif id == "dd" then
            id = LFG_ROLE_DPS
        else
            d(GetString(MPP_INVALID_ROLE))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_CLASS_DETAIL), GetRoleName(id)))
    elseif mode == "roleforrace" then
        full = true
        if id == "heal" then
            id = LFG_ROLE_HEAL
        elseif id == "tank" then
            id = LFG_ROLE_TANK
        elseif id == "dd" then
            id = LFG_ROLE_DPS
        else
            d(GetString(MPP_INVALID_ROLE))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_RACE_DETAIL), GetRoleName(id)))
    elseif mode == "roleforcombo" then
        full = true
        if id == "heal" then
            id = LFG_ROLE_HEAL
        elseif id == "tank" then
            id = LFG_ROLE_TANK
        elseif id == "dd" then
            id = LFG_ROLE_DPS
        else
            d(GetString(MPP_INVALID_ROLE))
            return
        end
        d(zo_strformat(GetString(MPP_HEADER_COMBO_DETAIL), GetRoleName(id)))
    else
        d(GetString(MPP_MODE_UNKNOWN))
        return
    end

    local counts = {}
    local function Add(index)
        if counts[index] == nil then
            counts[index] = 1
        else
            counts[index] = counts[index] + 1
        end
    end
    -- Fill counts
    for _, character in pairs(MPPCDC.SV.characters) do
        
    
        if mode == "race" then
            if character.race ~= nil then
                Add(character.race)
            end
        elseif mode == "class" then
            if character.class ~= nil then
                Add(character.class)
            end
        elseif mode == "alliance" then
            if character.alliance ~= nil then
                Add(character.alliance)
            end
        elseif mode == "gender" then
            if character.gender ~= nil then
                Add(character.gender)
            end
        elseif mode == "combination" then
            if (character.race ~= nil) and (character.class ~= nil) then
                local index = character.class * 100 + character.race
                Add(index)
            end
        elseif mode == "mostplayedclass" then
            if character.race ~= nil and character.race == id then
                Add(character.class)
            end
        elseif mode == "mostplayedrace" then
            if character.class ~= nil and character.class == id then
                Add(character.race)
            end
        elseif mode == "role" then
            full = true
            differentPercentage = true
            if character.role ~= nil and character.role ~= LFG_ROLE_INVALID then
                Add(character.role)
            end
        elseif mode == "mostplayedroleclass" then
            differentPercentage = true
            if character.class ~= nil and character.class == id then
                if character.role ~= nil and character.role ~= LFG_ROLE_INVALID then
                    Add(character.role)
                end
            end
        elseif mode == "mostplayedrolerace" then
            differentPercentage = true
            if character.race ~= nil and character.race == id then
                if character.role ~= nil and character.role ~= LFG_ROLE_INVALID then
                    Add(character.role)
                end
            end
        elseif mode == "roleforrace" then
            full = true
            differentPercentage = true
            if character.role ~= nil and character.role == id then
                Add(character.race)
            end
        elseif mode == "roleforclass" then
            full = true
            differentPercentage = true
            if character.role ~= nil and character.role == id then
                Add(character.class)
            end
        elseif mode == "roleforcombo" then
            differentPercentage = true
            if character.role ~= nil and character.role == id then
                local index = character.class * 100 + character.race
                Add(index)
            end
        elseif mode == "mostplayedrolecombo" then
            differentPercentage = true
            extra1 = tonumber(extra1)
            if character.role ~= nil and character.race == id and character.class == extra1 and character.role ~= LFG_ROLE_INVALID then
                Add(character.role)
            end
        end
    end
     
    -- Create report rows
    local i = 1
    local p = ""
    local limitedTotal = 0
    for k in pairs(counts) do limitedTotal = limitedTotal + counts[k] end
    
    for k, v in spairs(counts, function(t, a, b) return t[b] < t[a] end) do
        -- Get percentages
        if percentage then
            if differentPercentage then
                p = string.format(" - %.2f%%", (v / limitedTotal) * 100)
            else
                p = string.format(" - %.2f%%", (v / DataCount()) * 100)
            end
        end
        
        -- Data display for different modes
        if mode == "race" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC), i, GetRaceName(GENDER_NEUTER, k), v, p))
        elseif mode == "class" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC), i, GetClassName(GENDER_NEUTER, k), v, p))
        elseif mode == "alliance" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetAllianceName(k), v, p))
        elseif mode == "gender" then
            if k == GENDER_FEMALE then
                d(zo_strformat(GetString(MPP_GENDER_FEMALE), i, v, p))
            elseif k == GENDER_MALE then
                d(zo_strformat(GetString(MPP_GENDER_MALE), i, v, p))
            else
                d(zo_strformat(GetString(MPP_GENDER_UNKNOWN), i, v, p))
            end
        elseif mode == "combination" then
            local cl = math.floor(k / 100)
            local ra = k - (cl * 100)
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_2), i, GetRaceName(GENDER_MALE, ra), GetClassName(GENDER_NEUTER, cl), v, p))
        elseif mode == "mostplayedrace" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_2), i, GetRaceName(GENDER_MALE, k), GetClassName(GENDER_NEUTER, id), v, p))
            total = total + v
        elseif mode == "mostplayedclass" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_2), i, GetRaceName(GENDER_MALE, id), GetClassName(GENDER_NEUTER, k), v, p))
            total = total + v
        elseif mode == "role" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetRoleName(k, true), v, p))
            total = total + v
        elseif mode == "mostplayedrolerace" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetRoleName(k, true), v, p))
            total = total + v
        elseif mode == "mostplayedroleclass" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetRoleName(k, true), v, p))
            total = total + v
        elseif mode == "mostplayedrolecombo" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetRoleName(k, true), v, p))
            total = total + v
        elseif mode == "roleforcombo" then
            local cl = math.floor(k / 100)
            local ra = k - (cl * 100)
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_2), i, GetRaceName(GENDER_MALE, ra), GetClassName(GENDER_NEUTER, cl), v, p))
            total = total + v
        elseif mode == "roleforclass" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetClassName(GENDER_NEUTER, k), v, p))
            total = total + v
        elseif mode == "roleforrace" then
            d(zo_strformat(GetString(MPP_REPORT_GENERIC_A), i, GetRaceName(GENDER_MALE, k), v, p))
            total = total + v
        end
        
        -- Break execution if not a full report is to be generated
        if not full and i >= 3 then break end
        i = i + 1
    end
    
    -- Report tail
    if mode == "mostplayedrace" then
        d(zo_strformat(MPP_CHARS_TRACKED_CAT, total, GetClassName(GENDER_NEUTER, id)))
    elseif mode == "mostplayedclass" then
        d(zo_strformat(MPP_CHARS_TRACKED_CAT, total, GetRaceName(GENDER_NEUTER, id)))
    elseif mode == "role" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, DataCount()))
    elseif mode == "mostplayedroleclass" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, limitedTotal))
    elseif mode == "mostplayedrolerace" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, limitedTotal))
    elseif mode == "mostplayedrolecombo" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, limitedTotal))
    elseif mode == "roleforclass" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, GetNumTrackedCharactersWithRole(), GetRoleName(id, true)))
    elseif mode == "roleforrace" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, GetNumTrackedCharactersWithRole(), GetRoleName(id, true)))
    elseif mode == "roleforcombo" then
        d(zo_strformat(MPP_CHARS_TRACKED_ROLE, total, GetNumTrackedCharactersWithRole(), GetRoleName(id, true)))
    end
end

function MPPCDC.CreateAverage(mode)
    if mode == "cp" then
        d(GetString(MPP_HEADER_AVG_CP))
        
        local totalcp = 0
        local chars = 0
        for _, character in pairs(MPPCDC.SV.characters) do
            if character.level == 50 then
                chars = chars + 1
                totalcp = totalcp + character.championPoints
            end
        end
        
        local avgcp = totalcp / chars
        
        d(zo_strformat(MPP_AVG_CP, avgcp))
        d(zo_strformat(MPP_PLAYERS_CP, chars, string.format("%.2f%%", (chars / DataCount()) * 100)))
    elseif mode == "effcp" then
        d(GetString(MPP_HEADER_AVG_EFFCP))
        
        local totalcp = 0
        local chars = 0
        for _, character in pairs(MPPCDC.SV.characters) do
            if character.level == 50 then
                chars = chars + 1
                if character.championPoints > 810 then
                    totalcp = totalcp + 810
                else
                    totalcp = totalcp + character.championPoints
                end
            end
        end
        
        local avgcp = totalcp / chars
        
        d(zo_strformat(MPP_AVG_EFFCP, avgcp))
        d(zo_strformat(MPP_PLAYERS_CP, chars, string.format("%.2f%%", (chars / DataCount()) * 100)))
    elseif mode == "lvl" then
        d(GetString(MPP_HEADER_AVG_LVL))
        local total = 0
        local chars = 0
        for _, character in pairs(MPPCDC.SV.characters) do
            total = total + character.level
            if character.level == 50 then
                chars = chars + 1
            end
        end
        
        local avglvl = total / DataCount()
        d(zo_strformat(MPP_AVG_LVL, string.format("%.2f", avglvl)))
        d(zo_strformat(MPP_PLAYERS_LVL, chars, string.format("%.2f%%", (chars / DataCount()) * 100)))
    elseif mode == "avarank" then
        d(GetString(MPP_HEADER_AVG_AVA))
        local total = 0
        for _, character in pairs(MPPCDC.SV.characters) do
            total = total + character.avaRank
        end
        
        local avglvl = total / DataCount()
        df(zo_strformat(MPP_AVG_AVA, string.format("%.2f", avglvl), GetAvARankName(GENDER_NEUTER, math.floor(avglvl)), GetAvARankName(GENDER_NEUTER, math.ceil(avglvl))))
    else
        d(GetString(MPP_MODE_UNKNOWN))
        return
    end
end

function MPPCDC.Purge()
    d(GetString(MPP_PURGE))
    local purgelist = {}
    for charname, character in pairs(MPPCDC.SV.characters) do
        if character.class == 0 or character.race == 0 then
            table.insert(purgelist, charname)
        end
    end
    for _, charname in pairs(purgelist) do
        MPPCDC.SV.characters[charname] = nil
    end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(MPP_PURGE_COMPLETE, #purgelist))
    d(zo_strformat(MPP_PURGE_COMPLETE, #purgelist))
end

function MPPCDC.FixDataBase()
    d(GetString(MPP_FIX_HEADER))
    local fixes = 0
    for char, data in pairs(MPPCDC.SV.characters) do
        local hadFix = false
        if not data.account then
            data.account = "Unknown/Invalid"
            hadFix = true
        end
        if not data.lastUpdate then
            data.lastUpdate = GetTimeStamp()
            hadFix = true
        end
        if not data.alliance then
            data.alliance = ALLIANCE_NONE
            hadFix = true
        end
        if not data.avaRank then
            data.avaRank = 0
            hadFix = true
        end
        if not data.avaRankPoints then
            data.avaRankPoints = 0
            hadFix = true
        end
        if not data.championPoints then
            data.championPoints = 0
            hadFix = true
        end
        if not data.level then
            data.level = 0
            hadFix = true
        end
        if not data.gender then
            data.gender = GENDER_NEUTER
            hadFix = true
        end
        if not data.class then
            data.class = 0
            hadFix = true
        end
        if not data.race then
            data.race = 0
            hadFix = true
        end
        if not data.role then
            data.role = 0
            hadFix = true
        end
        if not data.server then
            data.server = GetWorldName()
            hadFix = true
        end
        
        if hadFix then
            fixes = fixes + 1
        end
    end
    
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(MPP_FIX_REPORT, fixes))
    d(zo_strformat(MPP_FIX_REPORT, fixes))
end

local function UpdateCharacterData(unitTag)
    if GetUnitRaceId(unitTag) == 0 then return end
    if GetUnitClassId(unitTag) == 0 then return end
    if GetUnitDisplayName(unitTag) == "" then return end
    if GetUnitDisplayName(unitTag) == nil then return end
    
    local role = LFG_ROLE_INVALID -- Set to invalid so we have some data in the dataset at any time
    if (string.sub(unitTag, 1, 5) == "group") then
        role = GetGroupMemberSelectedRole(unitTag) --Returns 0 if not in group
    elseif unitTag == "player" then
       role = GetSelectedLFGRole()
    end
    
    MPPCDC.SV.characters[GetUnitName(unitTag)] = {
        ["account"] =           GetUnitDisplayName(unitTag),
        ["lastUpdate"] =        GetTimeStamp(),
        ["alliance"] =          GetUnitAlliance(unitTag),
        ["avaRank"] =           GetUnitAvARank(unitTag),
        ["avaRankPoints"] =     GetUnitAvARankPoints(unitTag),
        ["championPoints"] =    GetUnitChampionPoints(unitTag),
        ["level"] =             GetUnitLevel(unitTag),
        ["gender"] =            GetUnitGender(unitTag),
        ["class"] =             GetUnitClassId(unitTag),
        ["race"] =              GetUnitRaceId(unitTag),
        ["role"] =              role,
        ["server"] =            GetWorldName(),
    }
end

local function UpdateRoleInfo(unitTag)
    if not (string.sub(unitTag, 1, 5) == "group") then return end
    if MPPCDC.SV.characters[GetUnitName(unitTag)] == nil then return end
    MPPCDC.SV.characters[GetUnitName(unitTag)]["role"] = GetGroupMemberSelectedRole(unitTag)
end

local function CollectCharacterData(unitTag)
    if IsUnitPlayer(unitTag) then
        -- Set unittag to the persons group tag if they are in your group
        for i = 1, GetGroupSize() do
            if AreUnitsEqual(unitTag, "group"..i) then
                unitTag = "group"..i
            end
        end
    
        if MPPCDC.SV.characters[GetUnitName(unitTag)] == nil then -- If a character is not already tracked, add it to the list
            -- Safeguard
            if MPPCDC.SV.safeguard and DataCount() >= MPPCDC.SafeGuardThreshold then
                d(GetString(MPP_SAFEGUARD))
                return
            end
        
            if MPPCDC.SV.showNewDataInfo then
                d(zo_strformat(MPP_ADD_NEW, GetUnitName(unitTag)))
            end
        
            UpdateCharacterData(unitTag)
        else -- If it is already tracked, update it if the collected data is too old
            if MPPCDC.SV.characters[GetUnitName(unitTag)]["lastUpdate"] ~= nil then
                if (GetTimeStamp() - MPPCDC.SV.characters[GetUnitName(unitTag)]["lastUpdate"]) >= MPPCDC.UpdateTheshold then
                    local cpbefore = MPPCDC.SV.characters[GetUnitName(unitTag)]["championPoints"]
                    local lvlbefore = MPPCDC.SV.characters[GetUnitName(unitTag)]["level"]
                    local avarankbefore = MPPCDC.SV.characters[GetUnitName(unitTag)]["avaRank"]
                    local cpafter = GetUnitChampionPoints(unitTag)
                    local lvlafter = GetUnitLevel(unitTag)
                    local avarankafter = GetUnitAvARank(unitTag)
                    local lastseen = MPPCDC.SV.characters[GetUnitName(unitTag)]["lastUpdate"]
                    
                    local rolebefore = ""
                    local roleafter = ""
                    if (string.sub(unitTag, 1, 5) == "group") then
                        rolebefore = MPPCDC.SV.characters[GetUnitName(unitTag)]["role"]
                        roleafter = GetGroupMemberSelectedRole(unitTag)
                        
                        if rolebefore == LFG_ROLE_HEAL then
                            rolebefore = "Healer"
                        elseif rolebefore == LFG_ROLE_TANK then
                            rolebefore = "Tank"
                        elseif rolebefore == LFG_ROLE_DPS then
                            rolebefore = "DD"
                        else
                            rolebefore = "Invalid"
                        end
                        
                        if roleafter == LFG_ROLE_HEAL then
                            roleafter = "Healer"
                        elseif roleafter == LFG_ROLE_TANK then
                            roleafter = "Tank"
                        elseif roleafter == LFG_ROLE_DPS then
                            roleafter = "DD"
                        else
                            roleafter = "Invalid"
                        end
                    end
                    
                    
                    -- Update messages
                    if MPPCDC.SV.showUpdateInfo then
                        -- Update message
                        
                        local ls = GetTimeStamp() - lastseen
                        ls = ls - (ls % 86400)
                        
                        local timeText = ZO_FormatTime(ls, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING)
                        local timesince = zo_strformat(SI_TIME_DURATION_AGO, timeText)
                        
                        d(zo_strformat(MPP_UPDATE_OLD_CHAR, ZO_LinkHandler_CreateCharacterLink(GetUnitName(unitTag)), timesince))
                        
                        
                        -- CP change
                        if cpbefore < cpafter then
                            d(" - CP: +" .. (cpafter - cpbefore) .. " (CP " .. cpafter .. ")")
                        end
                        
                        -- Level change
                        if lvlbefore < lvlafter then
                            d(" - LvL: +" .. (lvlafter - lvlbefore) .. " (LvL " .. lvlafter .. ")")
                        end
                        
                        -- AvA rank change
                        if avarankbefore < avarankafter then
                            d(" - AvA: +" .. (avarankafter - avarankbefore) .. " (AvA " .. avarankafter .. ")")
                        end
                        
                        -- Role change
                        if rolebefore ~= roleafter then
                            d(" - Role: " .. roleafter .. " (was " .. rolebefore .. ")")
                        end
                    end
                    UpdateCharacterData(unitTag)
                end
            elseif (string.sub(unitTag, 1, 5) == "group") then -- Update Role at anytime, regardless of update cooldown.
                --d("Target is in your group " .. unitTag)
                local rolebefore = MPPCDC.SV.characters[GetUnitName(unitTag)]["role"]
                UpdateRoleInfo(unitTag)
                local roleafter = MPPCDC.SV.characters[GetUnitName(unitTag)]["role"]
                
                
                if rolebefore == LFG_ROLE_HEAL then
                    rolebefore = "Healer"
                elseif rolebefore == LFG_ROLE_TANK then
                    rolebefore = "Tank"
                elseif rolebefore == LFG_ROLE_DPS then
                    rolebefore = "DD"
                else
                    rolebefore = "Invalid"
                end
                
                if roleafter == LFG_ROLE_HEAL then
                    roleafter = "Healer"
                elseif roleafter == LFG_ROLE_TANK then
                    roleafter = "Tank"
                elseif roleafter == LFG_ROLE_DPS then
                    roleafter = "DD"
                else
                    roleafter = "Invalid"
                end
                
                if rolebefore ~= roleafter then
                    d(zo_strformat(MPP_ROLE_HEADER, GetUnitName(unitTag)))
                    d(zo_strformat(MPP_ROLE, roleafter, rolebefore))
                end
            end
        end
    end
end

function MPPCDC.OnTargetChanged()
    CollectCharacterData("reticleover")
end

function MPPCDC.OnGroupChanged()
    if GetGroupSize() > 1 then
        for i = 1, GetGroupSize() do
            CollectCharacterData("group" .. i)
        end
    end
end

-- Import function for import.lua file
function MPPCDC.Import()
    if not MPPCDCSavedVariables2 then 
        d(GetString(MPP_NO_IMPORT_FILE))
    end
    d(GetString(MPP_IMPORT_MESSAGE))
    local importdata = {}
    local imports = 0
    for _, player in pairs(MPPCDCSavedVariables2["Default"]) do
        for char, data in pairs(player["$AccountWide"]["characters"]) do
            if MPPCDC.SV.characters[char] == nil then
                MPPCDC.SV.characters[char] = data
                imports = imports + 1
            end
        end
    end
    d(zo_strformat(MPP_IMPORT_REPORT, imports))
end

-- Creates the addon settings menu
local function InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Character Data Collector",
		displayName = "MrPikPik's Character Data Collector",
		author = "MrPikPik",
		version = MPPCDC.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	
	local optionsData = {}

    
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(MPP_OPTIONS_DESCRIPTION),
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(MPP_OPTIONS_HEADER),
	})
    
    -- Update Messages
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_OPTIONS_UPDATE),
		tooltip = GetString(MPP_OPTIONS_UPDATE_TT),
		default = MPPCDC.defaults.showUpdateInfo,
		getFunc = function() return MPPCDC.SV.showUpdateInfo end,
		setFunc = function(newValue) MPPCDC.SV.showUpdateInfo = newValue end,
	})
    
    -- New Character Messages
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_OPTIONS_NEW),
		tooltip = GetString(MPP_OPTIONS_NEW_TT),
		default = MPPCDC.defaults.showNewDataInfo,
		getFunc = function() return MPPCDC.SV.showNewDataInfo end,
		setFunc = function(newValue) MPPCDC.SV.showNewDataInfo = newValue end,
	})
    
    -- Divider
    table.insert(optionsData, {
		type = "divider",
	})
    
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(MPP_OPTIONS_SAFEGUARD_DESCRIPTION),
	})
    
    -- Safeguard
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(MPP_OPTIONS_SAFEGUARD),
		default = MPPCDC.defaults.safeguard,
		getFunc = function() return MPPCDC.SV.safeguard end,
		setFunc = function(newValue) MPPCDC.SV.safeguard = newValue end,
	})

	local optionsPanel = LibAddonMenu2:RegisterAddonPanel(MPPCDC.name, panelData)
	LibAddonMenu2:RegisterOptionControls(MPPCDC.name, optionsData)
end

-- Creates custom menus for lookups
local function InitializeCustomMenus()
    local function AddMenuItems(charnameOrUserid)
        local str = GetString(MPP_CONTEXT_MENU_LINK_CHAR)
        if string.sub(charnameOrUserid, 1, 1) == "@" then
            str = GetString(MPP_CONTEXT_MENU_LINK_USER)
        else
            for char, data in pairs(MPPCDC.SV.characters) do
                if char == charnameOrUserid then
                    AddMenuItem(GetString(MPP_CONTEXT_MENU_LINK_USER), function() MPPCDC.Find(data.account) end)
                    break
                end
            end
        end

        AddMenuItem(str, function() MPPCDC.Find(charnameOrUserid) end)
        ShowMenu()
    end


    ZO_PostHook(SYSTEMS:GetObject("ChatSystem"), "ShowPlayerContextMenu", function(self, playerName, rawName)
        AddMenuItems(playerName)
    end)
    
    ZO_PostHook(GROUP_LIST, "GroupListRow_OnMouseUp", function(self, control, button, upInside)
        if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
            local data = ZO_ScrollList_GetData(control)
            AddMenuItems(data.characterName)
        end
    end)
    
    ZO_PostHook(FRIENDS_LIST, "FriendsListRow_OnMouseUp", function(self, control, button, upInside)
        if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
            local data = ZO_ScrollList_GetData(control)
            AddMenuItems(data.characterName)
        end
    end)
    
    ZO_PostHook(GUILD_ROSTER_KEYBOARD, "GuildRosterRow_OnMouseUp", function(self, control, button, upInside)
        if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
            local data = ZO_ScrollList_GetData(control)
            AddMenuItems(data.characterName)
        end
    end)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= MPPCDC.name then return end
    EVENT_MANAGER:UnregisterForEvent(MPPCDC.name, EVENT_ADD_ON_LOADED) 

    MPPCDC.SV = ZO_SavedVars:NewAccountWide("MPPCDCSavedVariables", 1.0, nil, MPPCDC.defaults)
    
    SLASH_COMMANDS["/mpp"] = MPPCDC.MainCommand

    ESO_Dialogs["MPPCDC_CONFIRM_DELETION"] = {
		title = { text = GetString(MPP_CLEARDB_TITLE) },
		mainText =  { text = GetString(MPP_CLEARDB_PROMPT) },
		buttons = {
			[1] = {
				text = GetString(MPP_CLEARDB_YES),
				callback = function(dialog)
					MPPCDC.SV.characters = {}
				end
			},
			[2] = { text = GetString(MPP_CLEARDB_NO) },
		}
	}
    
    -- Bind to events
    EVENT_MANAGER:RegisterForEvent(MPPCDC.name, EVENT_RETICLE_TARGET_CHANGED, MPPCDC.OnTargetChanged)
    EVENT_MANAGER:RegisterForEvent(MPPCDC.name, EVENT_GROUP_MEMBER_JOINED, MPPCDC.OnGroupChanged)
    
    -- Collect your own data ;)
    CollectCharacterData("player")
    
    -- If LibAddonMenu is installed add options menu
    if LibAddonMenu2 then
        InitializeAddonMenu()
    end
    
    if LibCustomMenu then
        InitializeCustomMenus()
    end
end

EVENT_MANAGER:RegisterForEvent(MPPCDC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)