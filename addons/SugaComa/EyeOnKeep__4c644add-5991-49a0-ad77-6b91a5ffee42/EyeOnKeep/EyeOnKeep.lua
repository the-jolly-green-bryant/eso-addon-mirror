--------------------------------------------------------------
-- EyeOnKeep.lua — v1.7.2-test1
-- Author: SugaComa (Rik Sprint)
-- RESOURCES NOW FILTER BY HOME TERRITORY (same as keeps/outposts/towns)
--------------------------------------------------------------
local ADDON_NAME = "EyeOnKeep"
EyeOnKeep = EyeOnKeep or {}
EyeOnKeep.version = "1.7.2-test1"
local EM = EVENT_MANAGER
local EOK_SV_VERSION = 44
local EOK_SV = nil
local _inited = false
local muted = false
local BG_CONTEXT = BGQUERY_LOCAL

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
return GetFrameTimeMilliseconds() 
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
-- Objective classification uses API constants; display names do not determine type.
--------------------------------------------------------------
local function getObjectiveType(name, keepId)
    if not keepId or keepId <= 0 or not name or name == "?" then
        return "other"
    end

    local key = canon(name)
    local kt = getKeepType(keepId)

    if kt == KEEPTYPE_RESOURCE then return "resource" end
    if kt == KEEPTYPE_KEEP then return "keep" end
    if kt == KEEPTYPE_OUTPOST then return "outpost" end
    if kt == KEEPTYPE_TOWN then return "town" end

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
			msg = string.format("%s%s|r under attack at %s%s|r (our land)",
				colorO, abbrO, INFO_COLOR, abbrK)
		else
			msg = string.format("%s%s|r under attack at %s%s|r",
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
            msg = "The enemy hold on %Kn is under attack — an opportunity to reclaim our lands!"
        elseif owner == myAlliance and territory ~= myAlliance then
            msg = "Our territory at %Kn is under attack — hold our position!"
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
                and "%Ko now control %Kn , secureing the supply line."
                or "%Ko now control %Kn — the supply line has changed hands."
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
-- Siege intelligence uses current ownership; homeland is only a wording/filter input.
local STATE, OBJECTIVES, RESOURCE_PARENTS = {}, {}, {}
local activeCampaign, scanNumber = nil, 0
local trackingSuspended = false
local function InCyrodiil()
    return IsInCyrodiil() and not IsInImperialCity() and not IsActiveWorldBattleground()
end

local function BuildObjectiveIndex()
    OBJECTIVES, RESOURCE_PARENTS = {}, {}
    local seen = {}
    for index = 1, GetNumKeeps() do
        local id, context = GetKeepKeysByIndex(index)
        if IsLocalBattlegroundContext(context) and not seen[id] then
            seen[id] = true
            local name = GetKeepName(id)
            local kind = getObjectiveType(name, id)
            if kind ~= "other" then OBJECTIVES[#OBJECTIVES + 1] = id end
            if kind == "keep" then
                for _, resourceType in ipairs({ RESOURCETYPE_FOOD, RESOURCETYPE_ORE, RESOURCETYPE_WOOD }) do
                    local resourceId = GetResourceKeepForKeep(id, resourceType)
                    if resourceId and resourceId > 0 then RESOURCE_PARENTS[resourceId] = id end
                end
            end
        end
    end
end

local function ReadState(id)
    local name = GetKeepName(id)
    if not name or name == "" then return end
    local kind = getObjectiveType(name, id)
    if kind == "other" then return end
    local parent = RESOURCE_PARENTS[id]
    local territory = resolveTerritory(parent and GetKeepName(parent) or name, parent or id)
    return name, GetKeepAlliance(id, BG_CONTEXT), GetKeepUnderAttack(id, BG_CONTEXT), territory, kind
end

local function NewState(owner, under)
    return { owner = owner, under = under, siege = {}, announcedSiege = {},
        lastSiegeAt = -math.huge, flagThreats = {} }
end

local function SaySiege(name, owner, territory, kind, counts)
    if not matrixAllows(kind, territory) then return end
    local forces = {}
    for alliance = 1, NUM_ALLIANCES do
        if counts[alliance] and counts[alliance] > 0 then
            forces[#forces + 1] = tostring(counts[alliance]) .. " " .. SafeColor(alliance)
                .. (STYLE == "immersive" and SafeName(alliance) or FACTION[alliance].tag) .. "|r|cFFFFFF"
        end
    end
    local report = table.concat(forces, ", ") .. " siege reported."
    if STYLE == "quick" then
        chat(INFO_COLOR .. getAbbr(name, kind) .. "|r " .. report)
    elseif STYLE == "compact" then
        chat(INFO_COLOR .. name .. "|r — " .. report)
    else
        local playerAlliance = GetUnitAlliance("player")
        local place = INFO_COLOR .. name .. "|r|cFFFFFF"
        local orders
        if owner == playerAlliance and territory == playerAlliance then
            orders = "Enemy siege at " .. place .. " — defend our lands!"
        elseif owner == playerAlliance and territory ~= ALLIANCE_NONE then
            orders = "Enemy siege at " .. place .. " — hold our territory!"
        elseif owner == playerAlliance then
            orders = "Enemy siege at " .. place .. " — hold this keep!"
        elseif territory == playerAlliance then
            orders = "The enemy hold on " .. place .. " is under siege — an opportunity to reclaim our lands!"
        else
            orders = SafeName(owner) .. "-held " .. place .. " is under siege — enemy forces are engaged."
        end
        chat(orders .. " " .. report)
    end
end

local function CheckSiege(id, st, name, owner, territory, kind)
    if kind ~= "keep" then return end
    local counts, freshFaction, growth = {}, false, false
    if not FACTION[owner] or owner == ALLIANCE_NONE then
        st.siege, st.announcedSiege = {}, {}
        return
    end
    for alliance = 1, NUM_ALLIANCES do
        if alliance ~= owner then
            local count = GetNumSieges(id, BG_CONTEXT, alliance) or 0
            if count > 0 then
                counts[alliance] = count
                if not st.siege[alliance] then freshFaction = true end
                if count >= (st.announcedSiege[alliance] or count) + 2 then growth = true end
            else
                st.announcedSiege[alliance] = nil
            end
        end
    end
    local now = nowMs()
    if freshFaction or (growth and now - st.lastSiegeAt >= 10000) then
        SaySiege(name, owner, territory, kind, counts)
        st.announcedSiege = {}
        for alliance, count in pairs(counts) do st.announcedSiege[alliance] = count end
        st.lastSiegeAt = now
    end
    st.siege = counts
end

local function HandleUpdate(id, ownerOverride, oldOwner, attackOverride)
    if not InCyrodiil() then return end
    local name, owner, under, territory, kind = ReadState(id)
    if not name then return end
    if ownerOverride ~= nil then owner = ownerOverride end
    if attackOverride ~= nil then under = attackOverride end
    local st = STATE[id]
    if not st then
        st = NewState(oldOwner or owner, false)
        STATE[id] = st
    end
    local playerAlliance = GetUnitAlliance("player")
    local changedOwner = owner ~= st.owner
    if changedOwner then
        if owner == ALLIANCE_NONE then
            if matrixAllows(kind, territory) then chat(INFO_COLOR .. name .. "|r — control is disputed.") end
        else
            sayResolution(name, st.owner, owner, territory, kind, playerAlliance)
        end
        st.siege, st.announcedSiege, st.flagThreats = {}, {}, {}
    end
    if under and not st.under and not changedOwner then
        sayUnderAttack(name, owner, territory, kind, playerAlliance)
    elseif not under and st.under and not changedOwner then
        if matrixAllows(kind, territory) then
            chat(INFO_COLOR .. name .. "|r — defences hold; " .. SafeName(owner) .. " retain control.")
        end
    end
    st.owner, st.under = owner, under
    CheckSiege(id, st, name, owner, territory, kind)
end

local function ResetTracking()
    STATE, activeCampaign, scanNumber = {}, GetCurrentCampaignId(), 0
    BuildObjectiveIndex()
    -- Snapshot existing owners without inventing captures. Siege is checked on the next scan.
    for _, id in ipairs(OBJECTIVES) do
        local name, owner, under = ReadState(id)
        if name then STATE[id] = NewState(owner, under) end
    end
end

local function EnsureContext()
    if trackingSuspended or not InCyrodiil() then return false end
    if activeCampaign ~= GetCurrentCampaignId() then ResetTracking() end
    return true
end

local function OnKeepUnderAttackChanged(_, id, context, under)
    if IsLocalBattlegroundContext(context) and EnsureContext() then HandleUpdate(id, nil, nil, under) end
end
local function OnKeepOwnerChanged(_, id, context, owner, oldOwner)
    if IsLocalBattlegroundContext(context) and EnsureContext() then HandleUpdate(id, owner, oldOwner) end
end
local function OnKeepResourceUpdate(_, id)
    if EnsureContext() then HandleUpdate(id) end
end
local function OnObjectiveControlState(_, id, objectiveId, context, objectiveName, objectiveType, controlEvent, controlState)
    if not IsLocalBattlegroundContext(context) or not EnsureContext() then return end
    local name, owner, under, territory, kind = ReadState(id)
    if not name or (kind ~= "resource" and kind ~= "town") then return end
    local st = STATE[id] or NewState(owner, under)
    STATE[id] = st
    if controlEvent == OBJECTIVE_CONTROL_EVENT_ASSAULTED or controlEvent == OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK then
        local alreadyThreatened = next(st.flagThreats) ~= nil
        st.flagThreats[objectiveId] = true
        if not alreadyThreatened and not st.under then
            sayUnderAttack(name, owner, territory, kind, GetUnitAlliance("player"))
        end
    elseif controlEvent == OBJECTIVE_CONTROL_EVENT_CAPTURED or controlEvent == OBJECTIVE_CONTROL_EVENT_RECAPTURED
        or controlEvent == OBJECTIVE_CONTROL_EVENT_FULLY_HELD or controlEvent == OBJECTIVE_CONTROL_EVENT_DEACTIVATED then
        st.flagThreats[objectiveId] = nil
    end
    -- Objective capture is not necessarily whole-town ownership. The owner event handles that.
end

local function Scan()
    if not EnsureContext() then return end
    scanNumber = scanNumber + 1
    for _, id in ipairs(OBJECTIVES) do
        if GetKeepType(id) == KEEPTYPE_KEEP or scanNumber % 5 == 0 then HandleUpdate(id) end
    end
end
local function ActivateTracking()
    trackingSuspended = false
    EM:UnregisterForUpdate(ADDON_NAME .. "_Scan")
    STATE, activeCampaign = {}, nil
    if not InCyrodiil() then return end
    ResetTracking()
    EM:RegisterForUpdate(ADDON_NAME .. "_Scan", 2000, Scan)
end
local function DeactivateTracking()
    trackingSuspended = true
    EM:UnregisterForUpdate(ADDON_NAME .. "_Scan")
    STATE, activeCampaign = {}, nil
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
    -- Zone-scoped event tracking and two-second siege scan
    --------------------------------------------------------------
    EM:RegisterForEvent(ADDON_NAME.."_Activated", EVENT_PLAYER_ACTIVATED, ActivateTracking)
    EM:RegisterForEvent(ADDON_NAME.."_Deactivated", EVENT_PLAYER_DEACTIVATED, DeactivateTracking)
    EM:RegisterForEvent(ADDON_NAME.."_Campaign", EVENT_CURRENT_CAMPAIGN_CHANGED, ActivateTracking)
    EM:RegisterForEvent(ADDON_NAME.."_KeepsReady", EVENT_KEEPS_INITIALIZED, ActivateTracking)
    EM:RegisterForEvent(ADDON_NAME.."_KeepReady", EVENT_KEEP_INITIALIZED, function()
        if InCyrodiil() then BuildObjectiveIndex() end
    end)
    ActivateTracking()

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

