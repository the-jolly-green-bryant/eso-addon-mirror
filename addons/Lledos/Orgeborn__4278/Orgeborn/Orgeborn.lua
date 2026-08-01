local ADDON = "Orgeborn"

------------------------------------------------------------
-- Messaging: quiet by default; /og debug on to enable
------------------------------------------------------------
local function rawMsg(txt) d(string.format("|c7CB8FF[%s]|r %s", ADDON, tostring(txt))) end
local SV
local function msg(txt)
    if SV and SV.debug and SV.debug.enabled then
        rawMsg(txt)
    end
end

local function sLower(s) return type(s)=="string" and zo_strlower(s) or s end
local function zfmt(s) return s and zo_strformat(SI_UNIT_NAME, s) or s end

------------------------------------------------------------
-- Collectible ↔ houseId resolution helpers
------------------------------------------------------------
local function resolveCollectibleIdFromHouseId(houseId)
    -- Fast path
    if type(GetCollectibleIdFromHouseId) == "function" then
        local cid = GetCollectibleIdFromHouseId(houseId)
        if cid and cid > 0 then return cid end
    end
    -- Reliable fallback: iterate the HOUSE category correctly
    if type(GetTotalCollectiblesByCategoryType) == "function"
       and type(GetCollectibleIdFromCategoryType) == "function"
       and type(GetHouseIdFromCollectibleId) == "function" then
        local n = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE) or 0
        for i = 1, n do
            local cid = GetCollectibleIdFromCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE, i)
            if cid and cid > 0 then
                local hid = GetHouseIdFromCollectibleId(cid)
                if hid == houseId then
                    return cid
                end
            end
        end
    end
    return nil
end

------------------------------------------------------------
-- Destination summary (for /og list)
------------------------------------------------------------
local function destSummary(d)
    if not d then return "dest: <default>" end
    if d.mode=="SELF" then
        return string.format("dest: SELF collectibleId=%s %s",
            tostring(d.houseId), d.travelOutside and "(outside)" or "(inside)")
    end
    if d.mode=="SPECIFIC" then
        local extra = {}
        if d.allowSelfOutside then table.insert(extra, "allowSelfOutside") end
        if d.collectibleId then table.insert(extra, "collectibleId="..tostring(d.collectibleId)) end
        return string.format("dest: SPECIFIC owner=%s houseId=%s%s",
            tostring(d.owner), tostring(d.houseId),
            (#extra>0 and (" ["..table.concat(extra,", ").."]") or ""))
    end
    if d.mode=="ACCOUNT"  then return string.format("dest: ACCOUNT owner=%s", tostring(d.owner)) end
    return "dest: <unknown>"
end

-- Returns: ok(bool), reason(string)
local function verifyCollectibleForHouse(houseId, collectibleId)
    if not collectibleId then
        return false, "no collectibleId provided"
    end
    if type(GetHouseIdFromCollectibleId) ~= "function" then
        return true, "cannot verify mapping (API missing); assuming ok"
    end
    local mapped = GetHouseIdFromCollectibleId(collectibleId)
    if not mapped or tonumber(mapped) ~= tonumber(houseId) then
        return false, string.format("collectibleId %s maps to houseId %s (expected %s)",
            tostring(collectibleId), tostring(mapped), tostring(houseId))
    end
    return true, "collectible maps to house"
end

-- Returns: owns(bool), reason(string)
local function checkOwnership(collectibleId)
    if not collectibleId then return false, "no collectibleId" end
    if type(IsCollectibleUnlocked) == "function" then
        local ok = IsCollectibleUnlocked(collectibleId) == true
        return ok, ok and "you own this house" or "you do not own this house"
    end
    return true, "ownership API missing; assuming ownership if cid given"
end


------------------------------------------------------------
-- Teleport logic (implements requested rules exactly)
-- A) If owner == me → SELF; outside per travelOutside
-- B) If owner != me and travelOutside == true:
--      - if I own the house → SELF outside
--      - else → visit owner's house (inside)
-- C) If owner != me and travelOutside == false → visit owner's house (inside)
------------------------------------------------------------
-- Self = RequestJumpToHouse(collectibleId, outside)
-- Visit = JumpToSpecificHouse(@owner, houseId)
local function Teleport(dest)
    dest = dest or {}
    local mode = dest.mode or "ACCOUNT"

    local function selfCollectible(cid, outside)
        msg(string.format("SELF → RequestJumpToHouse(%s, %s)", tostring(cid), tostring(outside==true)))
        RequestJumpToHouse(cid, outside == true)
    end

    local function ensureCid(houseId, providedCid)
        -- Prefer the provided collectibleId (trust it if mapping API is missing)
        local cid = tonumber(providedCid)
        if cid then
            if type(GetHouseIdFromCollectibleId)=="function" then
                local mapped = GetHouseIdFromCollectibleId(cid)
                if mapped and tonumber(mapped) ~= tonumber(houseId) then
                    msg(string.format("provided cid %s maps to houseId %s (expected %s) → ignoring provided cid",
                        tostring(cid), tostring(mapped), tostring(houseId)))
                    cid = nil
                end
            else
                msg("mapping API missing → trusting provided collectibleId="..tostring(cid))
                return cid
            end
        end
        if not cid and resolveCollectibleIdFromHouseId then
            cid = resolveCollectibleIdFromHouseId(houseId)
            msg("resolved collectibleId="..tostring(cid).." from houseId="..tostring(houseId))
        end
        return cid
    end

    if mode == "SELF" then
        -- In SELF, we require a collectibleId (stored in houseId for legacy)
        local cid = tonumber(dest.houseId) or tonumber(dest.collectibleId)
        if not cid then rawMsg("SELF needs a collectibleId."); return end
        selfCollectible(houseId, dest.travelOutside)
        return
    end

    if mode ~= "SPECIFIC" then
        if not dest.owner then rawMsg("ACCOUNT destination missing owner @name."); return end
        msg("ACCOUNT → JumpToHouse("..tostring(dest.owner)..")")
        JumpToHouse(dest.owner)
        return
    end

    -- SPECIFIC
    if not dest.owner or not dest.houseId then rawMsg("SPECIFIC needs owner and houseId."); return end
    local me      = GetDisplayName and GetDisplayName()
    local owner   = dest.owner
    local houseId = tonumber(dest.trueHouseId or dest.houseId)

    local cid = ensureCid(houseId, dest.collectibleId)

    -- Owner is me → SELF via collectible (must have cid)
    if me and owner == me then
        if not cid then rawMsg("Owner==you but no collectibleId available for houseId="..tostring(houseId)); return end
        selfCollectible(houseId, dest.travelOutside)
        return
    end

    -- Not owner; if outside requested and I own it, do SELF; else visit owner (inside)
    if dest.travelOutside == true and cid then
        local owns = true
        if type(IsCollectibleUnlocked)=="function" then
            owns = IsCollectibleUnlocked(cid) == true
        else
            msg("ownership API missing → assuming ownership since cid provided")
        end
        msg("ownership check for cid "..tostring(cid)..": "..tostring(owns))
        if owns then
            selfCollectible(houseId, true)
            return
        end
    end

    msg(string.format("VISIT → JumpToSpecificHouse(%s, %s)", tostring(owner), tostring(houseId)))
    JumpToSpecificHouse(owner, houseId)
end





------------------------------------------------------------
-- Config + SavedVariables + auto-import
------------------------------------------------------------
Orgeborn_Config = Orgeborn_Config or {
    ConfigVersion = 1,
    ImportMode = "merge",
    defaultDestination = { mode="ACCOUNT", owner=nil, houseId=nil, travelOutside=false },
    triggers = {}
}

local defaults = {
    enabled = true,
    defaultDestination = Orgeborn_Config.defaultDestination or {},
    triggers = Orgeborn_Config.triggers or {},
    debug = { enabled=false }, -- QUIET by default
    autoImportOnLoad = true,
    preferredImportMode = Orgeborn_Config.ImportMode or "merge",
    lastImportedConfigVersion = nil,
    version = 11,
}

local function triggerKey(t)
    if t.type=="BOOK"    then return "BOOK:"..tostring(t.id or t.title or "")
    elseif t.type=="CHATTER" then return "CHATTER:"..tostring(t.unit or "")..":"..tostring(t.optionMatch or "")
    elseif t.type=="INTERACT" then return "INTERACT:"..tostring(t.unit or "")..":"..tostring(t.actionMatch or "")
    end
    return "?"
end

local function doImportFromConfig(mode, replaceDefaultDest)
    if not Orgeborn_Config then rawMsg("No Orgeborn_Config table found."); return 0,0 end
    local added, updated = 0, 0

    if replaceDefaultDest and Orgeborn_Config.defaultDestination then
        SV.defaultDestination = Orgeborn_Config.defaultDestination
    end
    if mode == "replace" then SV.triggers = {} end

    local index = {}
    for i,t in ipairs(SV.triggers) do index[triggerKey(t)] = i end

    for _,t in ipairs(Orgeborn_Config.triggers or {}) do
        local key = triggerKey(t)
        local i = index[key]
        if i then
            for k,v in pairs(t) do if k ~= "type" then SV.triggers[i][k] = v end end
            updated = updated + 1
        else
            table.insert(SV.triggers, t)
            added = added + 1
        end
    end
    return added, updated
end

local function autoImportIfNeeded()
    local cfgVer = Orgeborn_Config and Orgeborn_Config.ConfigVersion or nil
    local importMode = (Orgeborn_Config and Orgeborn_Config.ImportMode) or SV.preferredImportMode or "merge"
    local shouldImport =
        SV.autoImportOnLoad
        or (cfgVer ~= nil and cfgVer ~= SV.lastImportedConfigVersion)
        or (#SV.triggers == 0 and (Orgeborn_Config and (Orgeborn_Config.triggers and #Orgeborn_Config.triggers > 0)))

    if not shouldImport then return end
    local added, updated = doImportFromConfig(importMode, true)
    SV.lastImportedConfigVersion = cfgVer
    msg(string.format("Auto-import (%s): %d added, %d updated%s",
        importMode, added, updated, cfgVer and ("  [ConfigVersion="..tostring(cfgVer).."]") or ""))
end

local function onAddOnLoaded(_, name)
    if name ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
    SV = ZO_SavedVars:NewAccountWide("Orgeborn_SV", defaults.version, nil, defaults, nil)
    if SV.autoImportOnLoad then autoImportIfNeeded() end
end

------------------------------------------------------------
-- Matching logic
------------------------------------------------------------
local function findBookTrigger(bookId, title)
    local bid = tonumber(bookId)
    for _, t in ipairs(SV.triggers) do
        if t.type=="BOOK" then
            local tid = t.id and tonumber(t.id)
            if (tid and bid and tid == bid) or (t.title and sLower(t.title)==sLower(title or "")) then
                return t
            end
        end
    end
end

local function findChatterTrigger(unitName, chosenText)
    unitName = zfmt(unitName or "")
    chosenText = sLower(zfmt(chosenText or ""))
    for _, t in ipairs(SV.triggers) do
        if t.type=="CHATTER" then
            local unitOk = (not t.unit) or (zfmt(t.unit)==unitName)
            local optOk  = (not t.optionMatch) or (chosenText:find(sLower(t.optionMatch),1,true)~=nil)
            if unitOk and optOk then return t end
        end
    end
end

------------------------------------------------------------
-- Books
------------------------------------------------------------
local lastBook = { id=nil, title=nil }

local function onShowBook(_, title, _, _, _, bookId)
    if not SV.enabled then return end

    title = zfmt(title or "?")
    lastBook.id, lastBook.title = bookId, title

    msg(string.format('Book opened: %q (bookId=%s)', tostring(title), tostring(bookId)))

    local trig = findBookTrigger(bookId, title)
    if not trig then return end

    -- Close reader then jump a moment later so the jump isn't ignored
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing("loreReader") then
        SCENE_MANAGER:Hide("loreReader")
    end

    local dest = trig.dest or SV.defaultDestination
    msg("BOOK trigger matched. "..destSummary(dest))
    zo_callLater(function() Teleport(dest) end, 250)
end

------------------------------------------------------------
-- Chatter (dialog) options
------------------------------------------------------------
local CURRENT_CHATTER_NAME = nil

local function GetChatterTextSafe(i)
    local ok, a = pcall(function() return GetChatterOption(i) end)
    if ok and type(a)=="string" then return zfmt(a) end
    local t = ({GetChatterOptionInfo(i)})[1]
    return zfmt(t or "")
end

local function onChatterBegin()
    CURRENT_CHATTER_NAME = zfmt(GetUnitName("interact") or GetUnitName("talktarget") or "?")
end
local function onChatterEnd() CURRENT_CHATTER_NAME = nil end

ZO_PreHook("SelectChatterOption", function(index, ...)
    if not SV.enabled then return false end
    local chosen = GetChatterTextSafe(index)
    if not chosen or chosen=="" then return false end

    msg(string.format('Chatter: %s → %s', tostring(CURRENT_CHATTER_NAME or "?"), tostring(chosen)))

    local trig = findChatterTrigger(CURRENT_CHATTER_NAME or "", chosen)
    if trig then zo_callLater(function() Teleport(trig.dest or SV.defaultDestination) end, 250) end
    return false
end)

------------------------------------------------------------
-- House helpers
------------------------------------------------------------
local function getCurrentHouseId()
    if type(GetCurrentZoneHouseId)=="function" then
        local hid=GetCurrentZoneHouseId(); if hid and hid>0 then return hid end
    end
    if type(GetCurrentHouseId)=="function" then
        local hid=GetCurrentHouseId(); if hid and hid>0 then return hid end
    end
    if type(GetCurrentZoneHouseIdFromWorld)=="function" then
        local hid=GetCurrentZoneHouseIdFromWorld(); if hid and hid>0 then return hid end
    end
    return nil
end

------------------------------------------------------------
-- Slash commands
------------------------------------------------------------
local function listTriggers()
    if #SV.triggers==0 then rawMsg("No triggers yet. Use /og import or /og add ..."); return end
    rawMsg("Triggers:")
    for i,t in ipairs(SV.triggers) do
        local head = ""
        if t.type=="BOOK" then head = string.format("BOOK id=%s", tostring(t.id))
        elseif t.type=="CHATTER" then head = string.format("CHATTER %s | %s", tostring(t.unit or "nil"), tostring(t.optionMatch or "nil"))
        elseif t.type=="INTERACT" then head = string.format("INTERACT %s | %s", tostring(t.unit or "nil"), tostring(t.actionMatch or "nil"))
        else head = tostring(t.type or "?")
        end
        rawMsg(string.format("[%d] %s | %s", i, head, destSummary(t.dest)))
    end
end

local function listHouses()
    rawMsg("Your house collectible IDs:")
    local count = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE) or 0
    for i=1,count do
        local id=GetCollectibleIdForHouse(i)
        local name=GetCollectibleName(id)
        rawMsg(string.format("- %s (id=%d)", zfmt(name), id))
    end
end

local function ogHelp()
    rawMsg("/og help                         - show this help")
    rawMsg("/og debug on|off                 - toggle verbose logging (quiet by default)")
    rawMsg("/og list                         - list triggers (shows destinations)")
    rawMsg("/og houses                       - list your house collectible IDs")
    rawMsg("/og add book                     - add last opened book as trigger")
    rawMsg("/og add chatter <option text>    - add chatter trigger for current NPC")
    rawMsg("/og del <index>                  - delete trigger by index")
    rawMsg("/og dest self <collectibleId> [inside|outside]")
    rawMsg("/og dest account <@name>")
    rawMsg("/og dest specific <@name> <houseId_or_collectibleId> [allowSelfOutside]")
    rawMsg("/og dest here <@owner>          - set default dest to the house you’re in")
    rawMsg("/og setdest <index> here <@owner> - set that trigger’s dest to the house you’re in")
    rawMsg("/og import / /og resetconfig     - import from Orgeborn_Config.lua")
    rawMsg("/og houseid                      - print current houseId (if in a house)")
end

local function addBook()
    if not lastBook.id then rawMsg("Open the book first, then /og add book"); return end
    table.insert(SV.triggers, { type="BOOK", id=tonumber(lastBook.id) })
    rawMsg(string.format("Added BOOK trigger id=%s (%s)", tostring(lastBook.id), lastBook.title or "?"))
end

local function addChatter(text)
    local unit = zfmt(GetUnitName("interact") or GetUnitName("talktarget") or "?")
    if not text or text=="" then rawMsg("Usage: /og add chatter <option text>"); return end
    table.insert(SV.triggers, { type="CHATTER", unit=unit, optionMatch=text })
    rawMsg(string.format("Added CHATTER trigger unit=%q optionMatch=%q", unit, text))
end

local function delTrigger(i)
    i=tonumber(i)
    if not i or not SV.triggers[i] then rawMsg("Bad index."); return end
    table.remove(SV.triggers,i)
    rawMsg("Trigger removed.")
end

local function setDefaultDest(tokens)
    local mode=(tokens[1] or ""):lower()
    if mode=="self" then
        local houseId=tonumber(tokens[2]); if not houseId then rawMsg("Usage: /og dest self <houseId> [inside|outside]"); return end
        local outside=(tokens[3] or ""):lower()=="outside"
        SV.defaultDestination={mode="SELF",houseId=houseId,travelOutside=outside}
        rawMsg(string.format("Default dest = your house collectibleId=%d (%s)",houseId,outside and"outside"or"inside"))
    elseif mode=="account" then
        local owner=tokens[2]; if not owner or owner:sub(1,1)~="@" then rawMsg("Usage: /og dest account <@name>"); return end
        SV.defaultDestination={mode="ACCOUNT",owner=owner}
        rawMsg("Default dest set to "..owner.." primary")
    elseif mode=="specific" then
        local owner=tokens[2]; local id=tokens[3]
        if not owner or owner:sub(1,1)~="@" or not id then rawMsg("Usage: /og dest specific <@name> <houseId_or_collectibleId>"); return end
        local allow = (tokens[4] and tokens[4]:lower()=="allowselfoutside") or false
        SV.defaultDestination={mode="SPECIFIC",owner=owner,houseId=tonumber(id),allowSelfOutside=allow}
        rawMsg(string.format("Default dest = %s id=%s%s",owner,tostring(id), allow and " (allowSelfOutside)" or ""))
    elseif mode=="here" then
        local owner=tokens[2]
        if not owner or owner:sub(1,1)~="@" then rawMsg("Usage: /og dest here <@owner>"); return end
        local hid=getCurrentHouseId(); if not hid then rawMsg("You are not inside a house right now."); return end
        SV.defaultDestination={mode="SPECIFIC",owner=owner,houseId=hid,trueHouseId=hid}
        rawMsg(string.format("Default dest set to HERE → owner=%s, houseId=%d", owner, hid))
    else
        rawMsg("Usage: /og dest self|account|specific|here ...")
    end
end

SLASH_COMMANDS["/og"]=function(raw)
    local args={}; for w in (raw or""):gmatch("%S+") do table.insert(args,w) end
    local cmd=(args[1] or""):lower()

if cmd=="verify" then
    -- /og verify <collectibleId> <houseId>
    local cid = tonumber(args[2]); local hid = tonumber(args[3])
    if not cid or not hid then rawMsg("Usage: /og verify <collectibleId> <houseId>"); return end
    local okMap, whyMap = verifyCollectibleForHouse(hid, cid)
    rawMsg("verify map: "..whyMap)
    if type(IsCollectibleUnlocked)=="function" then
        rawMsg("verify own : "..tostring(IsCollectibleUnlocked(cid)))
    else
        rawMsg("verify own : (API missing)")
    end
    return
end


    if cmd=="" or cmd=="help" then ogHelp(); return end
    if cmd=="debug" then
        local val=(args[2] or ""):lower()
        SV.debug.enabled=(val=="on")
        rawMsg("Debug logging: "..(SV.debug.enabled and "ON" or "OFF"))
        return
    end
    if cmd=="on" then SV.enabled=true; rawMsg("Enabled"); return end
    if cmd=="off" then SV.enabled=false; rawMsg("Disabled"); return end
    if cmd=="list" then listTriggers(); return end
    if cmd=="houses" then listHouses(); return end
    if cmd=="add" then
        local sub=(args[2] or""):lower()
        if sub=="book" then addBook(); return end
        if sub=="chatter" then addChatter(table.concat(args," ",3)); return end
        rawMsg("Usage: /og add book|chatter ..."); return
    end

    if cmd=="del" then delTrigger(args[2]); return end

    if cmd=="dest" then setDefaultDest({args[2],args[3],args[4]}); return end

    if cmd=="setdest" then
        local idx = tonumber(args[2]); local sub=(args[3] or ""):lower()
        if not idx or not SV.triggers[idx] then rawMsg("Usage: /og setdest <index> here <@owner>"); return end
        if sub=="here" then
            local owner=args[4]; if not owner or owner:sub(1,1)~="@" then rawMsg("Usage: /og setdest <index> here <@owner>"); return end
            local hid=getCurrentHouseId(); if not hid then rawMsg("You are not inside a house right now."); return end
            SV.triggers[idx].dest = { mode="SPECIFIC", owner=owner, houseId=hid, trueHouseId=hid }
            rawMsg(string.format("Trigger #%d dest set to HERE → owner=%s, houseId=%d", idx, owner, hid))
            return
        end
        rawMsg("Usage: /og setdest <index> here <@owner>"); return
    end

    if cmd=="import" then
        local added, updated = doImportFromConfig(SV.preferredImportMode or "merge", true)
        rawMsg(string.format("Imported from config: %d added, %d updated.", added, updated))
        return
    end
    if cmd=="resetconfig" then
        local added, updated = doImportFromConfig("replace", true)
        rawMsg(string.format("Reset from config: %d added, %d updated.", added, updated))
        return
    end
    if cmd=="autoconfig" then
        local val=(args[2] or ""):lower()
        SV.autoImportOnLoad = (val=="on")
        rawMsg("Auto-import on load: "..(SV.autoImportOnLoad and "ON" or "OFF"))
        return
    end
    if cmd=="importmode" then
        local mode=(args[2] or ""):lower()
        if mode=="merge" or mode=="replace" then
            SV.preferredImportMode = mode
            rawMsg("Preferred import mode set to "..mode)
            return
        end
        rawMsg("Usage: /og importmode merge|replace"); return
    end
    if cmd=="configversion" then
        local n=tonumber(args[2]); if not n then rawMsg("Usage: /og configversion <number>"); return end
        SV.lastImportedConfigVersion = n
        rawMsg("Set lastImportedConfigVersion = "..n)
        return
    end

    ogHelp()
end

------------------------------------------------------------
-- Event wiring (BOOK + CHATTER only)
------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, onAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_SHOW_BOOK, onShowBook)
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CHATTER_BEGIN, onChatterBegin)
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_CHATTER_END, onChatterEnd)
-- NOTE: no interact-hook registration at all
