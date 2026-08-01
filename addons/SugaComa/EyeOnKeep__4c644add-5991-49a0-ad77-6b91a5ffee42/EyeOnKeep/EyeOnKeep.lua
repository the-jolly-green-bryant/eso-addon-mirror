--------------------------------------------------------------
-- EyeOnKeep.lua — v1.6.1-test1
-- Author: SugaComa (Rik Sprint)
-- RESOURCES NOW FILTER BY HOME TERRITORY (same as keeps/outposts/towns)
--------------------------------------------------------------
local ADDON_NAME = "EyeOnKeep"
EyeOnKeep = EyeOnKeep or {}
EyeOnKeep.version = "1.7.1-test1"
local EM = EVENT_MANAGER
local EOK_SV_VERSION = 44
local EOK_SV = nil
local _inited = false
local muted = false
local BG_CONTEXT = BGQUERY_LOCAL

-- DUAL Polling: Resources FAST (10s) | Keeps SLOW (45s)
local RESOURCE_POLL_MS = 10000
local KEEP_POLL_MS = 45000
local MSG_COOLDOWN_MS = 45000

-- SavedVars defaults
local DEFAULTS = {
    excludeIC = true,
    messageStyle = "immersive",
    alertMatrix = {
        keep = { true, true, true },
        outpost = { true, true, true },
        town = { true, true, true },
        resource = { true, true, true },
    },
}

--------------------------------------------------------------
-- Factions
--------------------------------------------------------------
local FACTION = {
    [ALLIANCE_ALDMERI_DOMINION] = { tag="AD", name="Aldmeri Dominion", color="|cFFD700", monarch="Queen Ayrenn" },
    [ALLIANCE_EBONHEART_PACT]     = { tag="EP", name="Ebonheart Pact",     color="|cFF2400", monarch="Jorunn the Skald-King" },
    [ALLIANCE_DAGGERFALL_COVENANT]= { tag="DC", name="Daggerfall Covenant",color="|c4169E1", monarch="King Emeric" },
    [ALLIANCE_NONE]               = { tag="--", name="In Conflict",        color="|cFFFFFF", monarch="No ruler" },
}
local INFO_COLOR = "|c00FFCC"
local CHAT_TAG = "[EoK] "

-- Central chat output. Every EyeOnKeep line carries the same short tag so
-- narration tools such as VCAP2 can identify it reliably.
local function EmitChat(msg, force)
    if not msg or msg == "" then return end
    if muted and not force then return end

    local line = CHAT_TAG .. "|cFFFFFF" .. msg .. "|r"
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(line)
    else
        d(line)
    end
end

function EyeOnKeep.Chat(msg, force)
    EmitChat(msg, force == true)
end

local chat = EyeOnKeep.Chat

--------------------------------------------------------------
-- Keep Types
--------------------------------------------------------------
local KEEP_TYPE_KEEP = 1
local KEEP_TYPE_OUTPOST = 5
local KEEP_TYPE_TOWN = 6
local KEEP_TYPE_RESOURCE = 8

--------------------------------------------------------------
-- Canonicalize helper
--------------------------------------------------------------
local function canon(s)
    if not s or s == "" then return "" end
    s = s:gsub("’","'"):gsub("^%s*(.-)%s*$","%1")
    return s
end


--------------------------------------------------------------
-- Territory & Classification
--------------------------------------------------------------
local HOME_KEEPS = {
    ["Castle Alessia"]=1, ["Castle Black Boot"]=1, ["Castle Bloodmayne"]=1,
    ["Castle Brindle"]=1, ["Castle Faregyl"]=1, ["Castle Roebeck"]=1,
    ["Fort Aleswell"]=3, ["Fort Ash"]=3, ["Fort Dragonclaw"]=3,
    ["Fort Glademist"]=3, ["Fort Rayles"]=3, ["Fort Warden"]=3,
    ["Arrius Keep"]=2, ["Blue Road Keep"]=2, ["Chalman Keep"]=2,
    ["Drakelowe Keep"]=2, ["Kingscrest Keep"]=2, ["Farragut Keep"]=2,
}
local OUTPOSTS = {
    ["Nikel Outpost"]=1, ["Carmala Outpost"]=1,
    ["Bleaker's Outpost"]=3, ["Winter's Peak Outpost"]=3,
    ["Sejanus Outpost"]=2, ["Harlun's Outpost"]=2,
}
local TOWNS = { ["Vlastarus"]=1, ["Bruma"]=3, ["Cropsford"]=2, }

local EMP_KEEPS = {
    ["Castle Alessia"]=true, ["Castle Roebeck"]=true,
    ["Blue Road Keep"]=true, ["Chalman Keep"]=true,
    ["Fort Aleswell"]=true, ["Fort Ash"]=true,
}
local OUTER_KEEPS = {
    ["Castle Brindle"]=true, ["Fort Dragonclaw"]=true, ["Drakelowe Keep"]=true,
}

--------------------------------------------------------------
-- Resource → Parent Keep
--------------------------------------------------------------
local TOKEN_TO_KEEP = {
    ["Alessia"]="Castle Alessia",["Black Boot"]="Castle Black Boot",["Bloodmayne"]="Castle Bloodmayne",
    ["Brindle"]="Castle Brindle",["Faregyl"]="Castle Faregyl",["Roebeck"]="Castle Roebeck",
    ["Aleswell"]="Fort Aleswell",["Ash"]="Fort Ash",["Dragonclaw"]="Fort Dragonclaw",
    ["Glademist"]="Fort Glademist",["Rayles"]="Fort Rayles",["Warden"]="Fort Warden",
    ["Arrius"]="Arrius Keep",["Blue Road"]="Blue Road Keep",["Chalman"]="Chalman Keep",
    ["Drakelowe"]="Drakelowe Keep",["Kingscrest"]="Kingscrest Keep",["Farragut"]="Farragut Keep",
}
local function stripResourceSuffix(name)
    return canon(name):gsub("%s+Farm$",""):gsub("%s+Mine$",""):gsub("%s+Lumbermill$","")
end
local function parentKeepForResource(name)
    return TOKEN_TO_KEEP[stripResourceSuffix(name)]
end

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local function nowMs() 
return GetFrameTimeMilliseconds() or (os.time()*1000) 
end
local function SafeColor(a) 
return (FACTION[a] and FACTION[a].color) or "|cFFFFFF" 
end
local function SafeName(a) 
return (FACTION[a] and FACTION[a].name) or "Unknown" 
end
local function SafeMonarch(a) 
return (FACTION[a] and FACTION[a].monarch) or "Unknown Ruler" 
end


local function getKeepType(keepId)
    if not keepId or keepId <= 0 or type(GetKeepType) ~= "function" then return 0 end
    return GetKeepType(keepId)
end

--------------------------------------------------------------
-- Improved Objective Type Detection
-- Adds fallback for farms / mines / lumbermills by name
--------------------------------------------------------------
local function getObjectiveType(name, keepId)
    if not keepId or keepId <= 0 or not name or name == "?" then
        return "other"
    end

    local key = canon(name)
    local kt = getKeepType(keepId)

    -- Primary detection via keep type ID
    if kt == KEEP_TYPE_RESOURCE then
        return "resource"
    end
    if HOME_KEEPS[key] then
        return "keep"
    end
    if OUTPOSTS[key] then
        return "outpost"
    end
    if TOWNS[key] then
        return "town"
    end

    -- 🔧 Fallback: detect by name if API misreports type
    if key:find("Farm", 1, true)
        or key:find("Mine", 1, true)
        or key:find("Lumber", 1, true)
        or key:find("Mill", 1, true) then
        return "resource"
    end

    return "other"
end


--------------------------------------------------------------
-- Resolve territory (home alliance)
--------------------------------------------------------------
local function resolveTerritory(name, keepId)
    local key = canon(name)
    local native = HOME_KEEPS[key] or OUTPOSTS[key] or TOWNS[key]
    if native then return native end
    local parent = parentKeepForResource(name)
    if parent then
        local pk = canon(parent)
        return HOME_KEEPS[pk] or OUTPOSTS[pk] or TOWNS[pk] or ALLIANCE_NONE
    end
    if type(GetKeepAlliance) == "function" then
        local owner = GetKeepAlliance(keepId, BG_CONTEXT)
        if owner and owner ~= ALLIANCE_NONE then return owner end
    end
    return ALLIANCE_NONE
end

--------------------------------------------------------------
-- Message Formatter
--------------------------------------------------------------
local function FormatKeepMessage(template, keepName, owner, territory, myAlliance)
    if not template then return "" end

    local parent = parentKeepForResource(keepName)
    local n = INFO_COLOR .. keepName .. "|r|cFFFFFF"
    local p = INFO_COLOR .. (parent or keepName) .. "|r|cFFFFFF"
    local o = SafeColor(owner) .. SafeName(owner) .. "|r|cFFFFFF"
    local t = SafeColor(territory) .. SafeName(territory) .. "|r|cFFFFFF"
    local m = SafeColor(myAlliance) .. SafeName(myAlliance) .. "|r|cFFFFFF"
    local r = SafeColor(owner) .. SafeMonarch(owner) .. "|r|cFFFFFF"



    local msg = template
        :gsub("%%Kn", n)
        :gsub("%%Kp", p)
        :gsub("%%Ko", o)
        :gsub("%%Kt", t)
        :gsub("%%Km", m)
        :gsub("%%Kr", r)

    return msg .. "|r"
end

--------------------------------------------------------------
-- FILTER: ALL OBJECTS USE HOME TERRITORY (including resources!)
--------------------------------------------------------------
local function matrixAllows(otype, filterAlliance)
    if not EOK_SV or not EOK_SV.alertMatrix then return true end
    local t = EOK_SV.alertMatrix[otype]
    if not t then return true end
    local v = t[filterAlliance]
    if v == nil then return true end
    return v
end

--------------------------------------------------------------
-- LEXICON (Token Reference) for building messages below
-- ------------------------------------------------------------
-- These tokens are replaced dynamically in alert message templates.
-- Use them inside any string passed to FormatKeepMessage().
--
--  %Kn = Keep or Resource name               (e.g. "Alessia Farm")
--  %Ko = Current owner alliance              (e.g. "Ebonheart Pact")
--  %Kt = Territory or home alliance          (e.g. "Aldmeri Dominion")
--  %Km = My alliance                         (e.g. "Daggerfall Covenant")
--  %Ka = Attacker or extra info (flex token)
--  %Ks = Keep Attacker (who has siege up)
--  %Kr = Monarch name of owner (e.g. "Queen Ayrenn")
--
--  Color Codes:
--    Applied automatically per faction:
--      AD = |cFFD700  (gold)
--      EP = |cFF2400  (red)
--      DC = |c4169E1  (blue)
--      Neutral/Conflict = |cFFFFFF
--
--  Example Templates:
--    "%Kn is under attack — defend %Km lands!"
--    "%Ko have captured %Kn in the name of %Kr."
--    "Disruption reported at %Kn — %Ko are defending."
--
--  ⚙️ Expansion Ideas:
--    %Kp = Parent keep (for resources)
--    %Kc = Campaign name
--    %Ki = Keep ID
--    %Kb = Battle state (Under Attack / Captured / Defended)
-- ------------------------------------------------------------
--------------------------------------------------------------
-- styles NOW WITH ABBREVIATIONS
--------------------------------------------------------------
local ABBR = {
    keep = {
        ["Castle Alessia"]      = "LESSY", ["Castle Black Boot"] = "BB", ["Castle Bloodmayne"] = "BM",
        ["Castle Brindle"]      = "BRIN", ["Castle Faregyl"]    = "FARE", ["Castle Roebeck"]    = "ROE",
        ["Fort Aleswell"]       = "ALES", ["Fort Ash"]         = "ASH", ["Fort Dragonclaw"]   = "DRAGON",
        ["Fort Glademist"]      = "GLADE", ["Fort Rayles"]      = "RAYLES", ["Fort Warden"]       = "WARDEN",
        ["Arrius Keep"]         = "ARRY", ["Blue Road Keep"]   = "BRK", ["Chalman Keep"]      = "CHAL",
        ["Drakelowe Keep"]      = "DRAKE", ["Kingscrest Keep"]  = "KINGS", ["Farragut Keep"]     = "FARRA",
    },
    resource = {
		["Castle Alessia Farm"] = "LESSY FARM", ["Castle Alessia Mine"] = "LESSY MINE", ["Castle Alessia Lumbermill"] = "LESSY LUMB",
		["Castle Black Boot Farm"] = "BB FARM", ["Castle Black Boot Mine"] = "BB MINE", ["Castle Black Boot Lumbermill"] = "BB LUMB",
		["Castle Bloodmayne Farm"] = "BM FARM", ["Castle Bloodmayne Mine"] = "BM MINE", ["Castle Bloodmayne Lumbermill"] = "BM LUMB",
		["Castle Brindle Farm"] = "BRIN FARM", ["Castle Brindle Mine"] = "BRIN MINE", ["Castle Brindle Lumbermill"] = "BRIN LUMB",
		["Castle Faregyl Farm"] = "FARE FARM", ["Castle Faregyl Mine"] = "FARE MINE", ["Castle Faregyl Lumbermill"] = "FARE LUMB",
		["Castle Roebeck Farm"] = "ROE FARM", ["Castle Roebeck Mine"] = "ROE MINE", ["Castle Roebeck Lumbermill"] = "ROE LUMB",
		["Fort Aleswell Farm"] = "ALES FARM", ["Fort Aleswell Mine"] = "ALES MINE", ["Fort Aleswell Lumbermill"] = "ALES LUMB",
		["Fort Ash Farm"] = "ASH FARM", ["Fort Ash Mine"] = "ASH MINE", ["Fort Ash Lumbermill"] = "ASH LUMB",
		["Fort Dragonclaw Farm"] = "DRAGON FARM", ["Fort Dragonclaw Mine"] = "DRAGON MINE", ["Fort Dragonclaw Lumbermill"] = "DRAGON LUMB",
		["Fort Glademist Farm"] = "GLADE FARM", ["Fort Glademist Mine"] = "GLADE MINE", ["Fort Glademist Lumbermill"] = "GLADE LUMB",
		["Fort Rayles Farm"] = "RAYLES FARM", ["Fort Rayles Mine"] = "RAYLES MINE", ["Fort Rayles Lumbermill"] = "RAYLES LUMB",
		["Fort Warden Farm"] = "WARDEN FARM", ["Fort Warden Mine"] = "WARDEN MINE", ["Fort Warden Lumbermill"] = "WARDEN LUMB",
		["Arrius Keep Farm"] = "ARRY FARM", ["Arrius Keep Mine"] = "ARRY MINE", ["Arrius Keep Lumbermill"] = "ARRY LUMB",
		["Blue Road Keep Farm"] = "BRK FARM", ["Blue Road Keep Mine"] = "BRK MINE", ["Blue Road Keep Lumbermill"] = "BRK LUMB",
		["Chalman Keep Farm"] = "CHAL FARM", ["Chalman Keep Mine"] = "CHAL MINE", ["Chalman Keep Lumbermill"] = "CHAL LUMB",
		["Drakelowe Keep Farm"] = "DRAKE FARM", ["Drakelowe Keep Mine"] = "DRAKE MINE", ["Drakelowe Keep Lumbermill"] = "DRAKE LUMB",
		["Kingscrest Keep Farm"] = "KINGS FARM", ["Kingscrest Keep Mine"] = "KINGS MINE", ["Kingscrest Keep Lumbermill"] = "KINGS LUMB",
		["Farragut Keep Farm"] = "FARRA FARM", ["Farragut Keep Mine"] = "FARRA MINE", ["Farragut Keep Lumbermill"] = "FARRA LUMB",

    },
    outpost = {
        ["Nikel Outpost"]       = "NIK", ["Carmala Outpost"]  = "CARM",
        ["Bleaker's Outpost"]   = "BLEAKERS", ["Winter's Peak Outpost"] = "WINTERS",
        ["Sejanus Outpost"]     = "SEJ", ["Harlun's Outpost"] = "HARLUN",
    },
    town = {
        ["Vlastarus"]           = "VLAST", ["Bruma"]            = "BRUMA", ["Cropsford"]        = "CROPS",
    },
    alliance = {
        [ALLIANCE_ALDMERI_DOMINION] = "AD",
        [ALLIANCE_EBONHEART_PACT]   = "EP",
        [ALLIANCE_DAGGERFALL_COVENANT] = "DC",
        [ALLIANCE_NONE]             = "--",
    }
}

local function getAbbr(name, otype)
    name = canon(name)
    if ABBR[otype] and ABBR[otype][name] then
        return ABBR[otype][name]
    end
    local parent = parentKeepForResource(name)
    if parent and ABBR.keep[parent] then
        return ABBR.keep[parent] ..
            (name:find("Farm") and "F" or name:find("Mine") and "M" or "L")
    end
    return name:sub(1, 3):upper()
end


--------------------------------------------------------------
-- MESSAGE STYLE SYSTEM (Immersive / Compact / Quick)
--------------------------------------------------------------
local STYLE = "immersive"

--------------------------------------------------------------
-- UNDER ATTACK (Colour-aware for all styles)
--------------------------------------------------------------
local function sayUnderAttack(name, owner, territory, otype, myAlliance)
    if not matrixAllows(otype, territory) then return end

    local colorO = SafeColor(owner)
    local colorM = SafeColor(myAlliance)
    local abbrK = getAbbr(name, otype)
    local abbrO = ABBR.alliance[owner] or "--"
    local abbrM = ABBR.alliance[myAlliance] or "--"

    local msg

	if STYLE == "quick" then
		-- BRK UA (cyan keep name, white tag)
		msg = string.format("%s%s|r |cFFFFFFUA|r", INFO_COLOR, abbrK)

		
	elseif STYLE == "compact" then
		if owner == myAlliance and territory == myAlliance then
			msg = string.format("%s%s|r under attack at %s%s|r",
				colorM, abbrM, INFO_COLOR, abbrK)
		elseif owner ~= myAlliance and territory == myAlliance then
			msg = string.format("%s%s|r losing %s%s|r (our land)",
				colorO, abbrO, INFO_COLOR, abbrK)
		else
			msg = string.format("%s%s|r losing %s%s|r",
				colorO, abbrO, INFO_COLOR, abbrK)
		end
				

    else -- immersive
        local K = INFO_COLOR .. name .. "|r"
        local P = INFO_COLOR .. (parentKeepForResource(name) or name) .. "|r"
        local O = colorO .. SafeName(owner) .. "|r"
        local T = SafeColor(territory) .. SafeName(territory) .. "|r"
        local M = colorM .. SafeName(myAlliance) .. "|r"
        local R = colorO .. SafeMonarch(owner) .. "|r"

        if otype == "resource" then
            msg = (owner == myAlliance)
                and "%Kn is under attack — defend the supply line!"
                or "Disruption reported at %Kn — %Ko are defending."
        elseif owner == myAlliance and territory == myAlliance then
            msg = "%Kn is under attack — defend %Km lands!"
        elseif owner ~= myAlliance and territory == myAlliance then
            msg = "Enemy hold at %Kn is faltering — recapture it now!"
        elseif owner == myAlliance and territory ~= myAlliance then
            msg = "We’re losing %Kt ground — defend %Kn!"
        else
            msg = "Territorial dispute at %Kn — %Ko forces engaged."
        end

        msg = msg:gsub("%%Kn", K):gsub("%%Kp", P):gsub("%%Ko", O)
                 :gsub("%%Kt", T):gsub("%%Km", M):gsub("%%Kr", R)
    end

    chat(msg)
end


--------------------------------------------------------------
-- RESOLUTION (Colour-aware for all styles)
--------------------------------------------------------------
local function sayResolution(name, oldOwnerAtStart, ownerNow, territory, otype, myAlliance)
    if not matrixAllows(otype, territory) then return end

    local colorO = SafeColor(ownerNow)
    local colorM = SafeColor(myAlliance)
    local abbrK = getAbbr(name, otype)
    local abbrO = ABBR.alliance[ownerNow] or "--"
    local abbrM = ABBR.alliance[myAlliance] or "--"

    local msg

    if STYLE == "quick" then
        -- e.g. |cFFD700BRK|r CAP
        local tag = (ownerNow == oldOwnerAtStart and "HELD")
            or (ownerNow == myAlliance and "CAP")
            or "LOST"
        msg = string.format("%s%s|r |cFFFFFF%s|r", colorO, abbrK, tag)

    elseif STYLE == "compact" then
        if ownerNow == oldOwnerAtStart then
            msg = string.format("%s%s|r held %s%s|r", colorO, abbrO, colorO, abbrK)
        elseif ownerNow == myAlliance then
            msg = string.format("%s%s|r captured %s%s|r", colorM, abbrM, colorM, abbrK)
        else
            msg = string.format("%s%s|r took %s%s|r", colorO, abbrO, colorO, abbrK)
        end

    else -- immersive
        local K = INFO_COLOR .. name .. "|r"
        local P = INFO_COLOR .. (parentKeepForResource(name) or name) .. "|r"
        local O = colorO .. SafeName(ownerNow) .. "|r"
        local T = SafeColor(territory) .. SafeName(territory) .. "|r"
        local M = colorM .. SafeName(myAlliance) .. "|r"
        local R = colorO .. SafeMonarch(ownerNow) .. "|r"

        if otype == "resource" then
            msg = (ownerNow == myAlliance)
                and "Supply restored at %Kn — %Ko hold the line."
                or "%Ko have reclaimed %Kn — supply rerouted."
        elseif ownerNow == oldOwnerAtStart then
            msg = "%Ko forces have held %Kn — the line stands."
        elseif ownerNow == territory then
            msg = "%Ko reclaim %Kn in the name of %Kr."
        elseif ownerNow == myAlliance and territory ~= myAlliance then
            msg = "Victory at %Kn — %Km have seized enemy ground!"
        elseif territory == myAlliance and ownerNow ~= myAlliance then
            msg = "We’ve lost %Kn — %Ko forces now occupy %Km lands!"
        else
            msg = "%Ko have captured %Kn."
        end

        msg = msg:gsub("%%Kn", K):gsub("%%Kp", P):gsub("%%Ko", O)
                 :gsub("%%Kt", T):gsub("%%Km", M):gsub("%%Kr", R)
    end

    chat(msg)
end

--------------------------------------------------------------
-- State Machine
--------------------------------------------------------------
local STATE = {}
local function readState(keepId)
    local name = (type(GetKeepName) == "function") and GetKeepName(keepId, BG_CONTEXT) or "?"
    local owner = (type(GetKeepAlliance) == "function") and GetKeepAlliance(keepId, BG_CONTEXT) or ALLIANCE_NONE
    local under = (type(GetKeepUnderAttack) == "function") and GetKeepUnderAttack(keepId, BG_CONTEXT) or false
    local otype = getObjectiveType(name, keepId)
    local territory = resolveTerritory(name, keepId)
    return name, owner, under, territory, otype
end

local function handleUpdate(keepId, myAlliance)
    local name, owner, under, territory, otype = readState(keepId)
    if name == "?" then return end

    local tNow = nowMs()
    local st = STATE[keepId] or {
        owner=owner, under=under, territory=territory, otype=otype,
        battleOwner=nil, lastUnderAlert=0, lastMsgAt=0
    }
    STATE[keepId] = st

    local underCdOk = (tNow - (st.lastUnderAlert or 0) >= MSG_COOLDOWN_MS)
    local sayCdOk = (tNow - (st.lastMsgAt or 0) >= MSG_COOLDOWN_MS)

    if under and not st.under then
        st.battleOwner = owner
        if underCdOk then
            sayUnderAttack(name, owner, territory, otype, myAlliance)
            st.lastUnderAlert = tNow
            st.lastMsgAt = tNow
        end
    elseif under and st.under then
        if underCdOk then
            sayUnderAttack(name, owner, territory, otype, myAlliance)
            st.lastUnderAlert = tNow
            st.lastMsgAt = tNow
        end
    elseif not under and st.under then
        if sayCdOk then
            local oldOwnerAtStart = st.battleOwner or st.owner
            sayResolution(name, oldOwnerAtStart, owner, territory, otype, myAlliance)
            st.lastMsgAt = tNow
        end
        st.battleOwner = nil
    end

    st.owner = owner
    st.under = under
    st.territory = territory
    st.otype = otype
end


-- Detect fast resource state updates
local function OnKeepResourceUpdate(_, keepId, bgContext)
    if muted or bgContext ~= BG_CONTEXT then return end
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    handleUpdate(keepId, myAlliance)
end


--------------------------------------------------------------
-- Events & Polling
--------------------------------------------------------------
local function OnKeepUnderAttackChanged(_, keepId, bgContext)
    if muted or bgContext ~= BG_CONTEXT then return end
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    handleUpdate(keepId, myAlliance)
end
local function OnKeepOwnerChanged(_, keepId, bgContext)
    if muted or bgContext ~= BG_CONTEXT then return end
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    handleUpdate(keepId, myAlliance)
end

		--------------------------------------------------------------
		-- EARLY WARNING: Triggered the moment the flag is touched
		--------------------------------------------------------------
local function OnObjectiveControlState(_, keepId, objectiveId, battlegroundContext, objectiveControlEvent, objectiveControlState, objectiveOwnerAlliance)
    if muted or battlegroundContext ~= BG_CONTEXT then return end
    local name = GetKeepName(keepId, battlegroundContext)
    if not name or name == "?" then return end

    -- only act on known resource types
    if getObjectiveType(name, keepId) ~= "resource" then return end

    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE

    -- early alert if flag changes control state (player steps on flag)
    if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_STATE_CHANGED then
        sayUnderAttack(name, objectiveOwnerAlliance, resolveTerritory(name, keepId), "resource", myAlliance)
    end
end
	

local function PollResources()
    if muted then zo_callLater(PollResources, RESOURCE_POLL_MS); return end
    local total = GetNumKeeps() or 0
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    for keepId = 1, total do
        local name = GetKeepName(keepId, BG_CONTEXT)
        if name and name ~= "?" and getObjectiveType(name, keepId) == "resource" then
            handleUpdate(keepId, myAlliance)
        end
    end
    zo_callLater(PollResources, RESOURCE_POLL_MS)
end

local function PollKeepsOT()
    if muted then zo_callLater(PollKeepsOT, KEEP_POLL_MS); return end
    local total = GetNumKeeps() or 0
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    for keepId = 1, total do
        local name = GetKeepName(keepId, BG_CONTEXT)
        if name and name ~= "?" then
            local otype = getObjectiveType(name, keepId)
            if otype ~= "resource" then
                handleUpdate(keepId, myAlliance)
            end
        end
    end
    zo_callLater(PollKeepsOT, KEEP_POLL_MS)
end


--------------------------------------------------------------
-- Settings Menu
--------------------------------------------------------------
local function BuildSettingsMenu()
    local LHA = LibHarvensAddonSettings
    if not LHA then
        chat("LibHarvensAddonSettings not found — settings panel disabled.", true)
        return
    end
    if not EOK_SV.alertMatrix then
        EOK_SV.alertMatrix = {
            keep = { true, true, true },
            outpost = { true, true, true },
            town = { true, true, true },
            resource = { true, true, true },
        }
    end
    local panel = LHA:AddAddon(ADDON_NAME, { allowDefaults = true, allowRefresh = true })
    if not panel then return end

    local factions = { "Aldmeri Dominion", "Ebonheart Pact", "Daggerfall Covenant" }
    local types = { "keep", "outpost", "town", "resource" }

    for _, typ in ipairs(types) do
        local typeKey = typ
        panel:AddSetting({ type = LHA.ST_SECTION, label = string.upper(typeKey) .. " Alerts (by home territory)" })
        for i = 1, 3 do
            local allianceIndex = i
            panel:AddSetting({
                type = LHA.ST_CHECKBOX,
                label = factions[allianceIndex],
                tooltip = "Alert when " .. typeKey .. " in " .. factions[allianceIndex] .. " home territory is attacked",
                getFunction = function() return EOK_SV.alertMatrix[typeKey][allianceIndex] ~= false end,
                setFunction = function(v)
                    if not EOK_SV.alertMatrix[typeKey] then EOK_SV.alertMatrix[typeKey] = {} end
                    EOK_SV.alertMatrix[typeKey][allianceIndex] = v
                end,
            })
        end
    end
end


--------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------

SLASH_COMMANDS["/eyemute"] = function()
    muted = not muted
    chat("Alerts are now " .. (muted and "|cFF4444muted|r" or "|c00FF00unmuted|r") .. ".", true)
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

--------------------------------------------------------------
-- Init function
--------------------------------------------------------------
local function EyeOnKeep_Init()
    if _inited then return end
    _inited = true

    -- 🔧 Create SavedVars FIRST
    EOK_SV = ZO_SavedVars:NewAccountWide("EyeOnKeep_SV", EOK_SV_VERSION, nil, DEFAULTS)

    -- 🔧 Restore saved message style (fallback = immersive)
    STYLE = EOK_SV.messageStyle or "immersive"

    -- 🔧 Style command (persistent)
    SLASH_COMMANDS["/eokstyle"] = function(arg)
        arg = (arg or ""):lower()
        if arg == "compact" or arg == "quick" or arg == "immersive" then
            STYLE = arg
            EOK_SV.messageStyle = STYLE
            chat("Message style → |cFFFF00" .. arg:upper() .. "|r", true)
        else
            chat("Current: |cFFFF00" .. STYLE:upper() ..
                 "|r  |cFFFFFF/eokstyle immersive | compact | quick|r", true)
        end
    end


    --------------------------------------------------------------
    -- Register Core Events
    --------------------------------------------------------------
    EM:RegisterForEvent(ADDON_NAME.."_Attack", EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttackChanged)
    EM:RegisterForEvent(ADDON_NAME.."_Owner", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnKeepOwnerChanged)
    EM:RegisterForEvent(ADDON_NAME.."_Objective", EVENT_OBJECTIVE_CONTROL_STATE, OnObjectiveControlState)
    EM:RegisterForEvent(ADDON_NAME.."_Resource", EVENT_KEEP_RESOURCE_UPDATE, OnKeepResourceUpdate)

    
    --------------------------------------------------------------
    -- Start Polling + Load Modules (delayed)
    --------------------------------------------------------------
    zo_callLater(function()
        PollResources()
        PollKeepsOT()
    end, 2000)

    --------------------------------------------------------------
    -- Settings Menu
    --------------------------------------------------------------
    BuildSettingsMenu()

    --------------------------------------------------------------
    -- Startup Message
    --------------------------------------------------------------
    local myAlliance = GetUnitAlliance("player") or ALLIANCE_NONE
    local f = FACTION[myAlliance] or FACTION[ALLIANCE_NONE]
    local campaign = "Unknown Campaign"
    if GetCurrentCampaignId and GetCampaignName then
        local id = GetCurrentCampaignId()
        if id and id > 0 then campaign = GetCampaignName(id) or campaign end
    end
    chat(string.format("%sEyeOnKeep|r v%s — watching %s%s|r for the %s%s|r.",
        FACTION[1].color, EyeOnKeep.version, INFO_COLOR, campaign, f.color, f.name))
end

--------------------------------------------------------------
-- On Load
--------------------------------------------------------------
local function OnAddonLoaded(_, addon)
    if addon ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EyeOnKeep_Init()
end
EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

