-- Inspect Vestige by LuckyRome13
-- Main.lua -- init, saved variables, slash commands, and the single inspect router
-- that every entry point (keybind, list menus, wheel, slash) funnels through.

local IV = InspectVestige

-- Account-wide settings (carry across servers). The received-build CACHE is server-specific and
-- lives in its own per-world SV -- see IV.InitCache below.
local SV_DEFAULTS = {
    respondToRequests = true,   -- privacy: answer inspect requests from group addon users
    friendsOnly       = false,  -- privacy: only share with group members on your friends list
    proactiveShare    = true,   -- auto-share on join/change (presence-gated); off = on-demand only
    wheelInject       = true,   -- inject into the hold-interact radial
    debug             = false,
}

--------------------------------------------------------------------------------
-- Small utilities
--------------------------------------------------------------------------------
function IV.Msg(text)
    d("|cFFD700[Inspect Vestige]|r " .. tostring(text))
end

function IV.Debug(msg)
    if IV.sv and IV.sv.debug then d("|cFFD700[IV]|r " .. tostring(msg)) end
end

--------------------------------------------------------------------------------
-- Inspect router -- resolves a target to the best available data source:
--   self -> fresh cache (instant) -> live peer refresh -> public card.
-- Proactive group broadcasts (Comms.InitAutoShare) keep the cache current, so a
-- recent cache is shown immediately and we skip the live request.
--------------------------------------------------------------------------------
local CACHE_FRESH_SECS = 120

local function inspectResolved(unitTag, atAccount, fallbackName)
    -- Self shortcut.
    if unitTag and DoesUnitExist(unitTag) and AreUnitsEqual(unitTag, "player") then
        IV.InspectSelf()
        return
    end
    if atAccount and atAccount == GetDisplayName() then
        IV.InspectSelf()
        return
    end

    -- Fill in the missing identifier where we can.
    if not atAccount and unitTag and DoesUnitExist(unitTag) then
        atAccount = GetUnitDisplayName(unitTag)
    end
    local groupTag = (unitTag and unitTag:find("^group%d")) and unitTag or nil
    if not groupTag and atAccount then
        groupTag = IV.FindGroupUnitTagByAccount(atAccount)
    end

    -- A live tag (reticle target / group unit) gives the public meta line we can always
    -- show; base is that card, or name-only when no live tag exists.
    local liveTag = (unitTag and DoesUnitExist(unitTag)) and unitTag or groupTag
    local acc     = atAccount or (groupTag and GetUnitDisplayName(groupTag))
    local base    = (liveTag and IV.BuildPublicInfo(liveTag))
                    or IV.BuildNameOnlyInfo(acc, fallbackName)

    -- 1. Show a cached build immediately (carries live public meta + "Cached <x> ago").
    local cached = acc and IV.Comms.GetCached(acc, liveTag)
    if cached then
        IV.Window.Show(cached)
    end

    -- 2. Grouped + peer sync -> refresh, but only when the cache is missing or stale.
    if groupTag and IV.Comms.ready then
        local cacheTs = acc and IV.Comms.GetCacheTimestamp(acc)
        local fresh   = cacheTs and (GetTimeStamp() - cacheTs) < CACHE_FRESH_SECS
        if not cached then IV.Window.ShowSyncing(base) end
        if not fresh then
            IV.Comms.RequestLoadout(acc, groupTag,
                function(loadout) IV.Window.Show(loadout) end,      -- success
                function()                                          -- timeout
                    if not cached then
                        IV.Window.Show(base)
                        IV.Window.SetStatus("|ccc6666" .. IV.L.STATUS_NOT_SHARING .. "|r")
                    end
                end,
                function()                                          -- they share with friends only
                    if not cached then IV.Window.Show(base) end
                    IV.Window.SetStatus("|ccc6666" .. IV.L.STATUS_FRIENDS_ONLY .. "|r")
                end)
        end
        -- Cosmetics ride their own channel (protocol 421); fetch them if we don't already hold them.
        -- Fire-and-forget: the reply merges into the open window when it lands (Comms.onCosmeticsReceived).
        if acc and IV.Comms.RequestCosmetics and not IV.Comms.HasCachedCosmetics(acc) then
            IV.Comms.RequestCosmetics(acc, groupTag)
        end
        return
    end

    -- 3. No transport (not grouped / LGB missing): show cache (already shown) or public.
    if not cached then
        IV.Window.Show(base)
        if base.meta.source == "public" then
            IV.Window.SetStatus("|c999999" .. IV.L.STATUS_NOT_SHARING .. "|r")
        end
    end
end

--------------------------------------------------------------------------------
-- Public entry points (called by menus, wheel, keybind, slash)
--------------------------------------------------------------------------------
function IV.InspectSelf()
    IV.Window.Show(IV.BuildOwnLoadout())
end

function IV.InspectUnitTag(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then
        IV.Msg(IV.L.STATUS_NO_TARGET)
        return
    end
    inspectResolved(unitTag, nil, nil)
end

function IV.InspectByAccount(atAccount, characterName)
    if not atAccount or atAccount == "" then
        IV.Msg("No player selected.")
        return
    end
    inspectResolved(nil, atAccount, characterName)
end

-- Bound in Bindings.xml.
function InspectVestige.OnReticleKeybind()
    IV.InspectUnitTag("reticleover")
end

--------------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------------
local function onSlash(args)
    local arg = zo_strlower(zo_strtrim(args or ""))
    if arg == "" then
        IV.InspectSelf()
    elseif arg == "settings" or arg == "config" or arg == "options" then
        if IV.settingsPanel and LibAddonMenu2 then
            LibAddonMenu2:OpenToPanel(IV.settingsPanel)
        else
            IV.Msg("Settings unavailable (LibAddonMenu-2.0 not loaded).")
        end
    elseif arg:sub(1, 1) == "@" then
        IV.InspectByAccount(zo_strtrim(args))
    else
        IV.Msg(IV.L.SLASH_USAGE)
    end
end

--------------------------------------------------------------------------------
-- Diagnostics (/ivdump) -- captures ground truth for the parts we can't verify
-- headlessly: active buffs (mundus/food live here), the food-type gate, and the
-- champion bar slots. Lines are printed to chat AND saved to
-- IV.sv.lastDump so they persist to the SavedVariables file after a /reloadui
-- (SavedVariables/InspectVestige.lua) -- which can be read directly, no copy/paste.
--------------------------------------------------------------------------------
function IV.RunDiagnostics()
    local lines = {}
    local function out(s)
        lines[#lines + 1] = s
        d(s)
    end

    out("== Inspect Vestige diagnostics ==")
    out(("GetActiveFoodTypeBonus() = %s"):format(tostring(GetActiveFoodTypeBonus and GetActiveFoodTypeBonus())))

    -- Champion bar
    if type(GetAssignableChampionBarStartAndEndSlots) == "function" then
        local s, e = GetAssignableChampionBarStartAndEndSlots()
        out(("CP bar slots %s..%s  HOTBAR_CATEGORY_CHAMPION=%s"):format(
            tostring(s), tostring(e), tostring(HOTBAR_CATEGORY_CHAMPION)))
        if s and e then
            for slot = s, e do
                local id = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
                local nm = (id and id ~= 0 and GetChampionSkillName) and GetChampionSkillName(id) or ""
                out(("  slot %d: id=%s  %s"):format(slot, tostring(id), tostring(nm)))
            end
        end
    else
        out("GetAssignableChampionBarStartAndEndSlots not found")
    end

    -- Active buffs (mundus = timeEnding 0; food = a long timed buff)
    local n = GetNumBuffs("player") or 0
    out(("Active buffs on player: %d"):format(n))
    for i = 1, n do
        local name, tStart, tEnd, buffSlot, _, icon, buffType, effectType, _, _, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo("player", i)
        out(("  [%d] slot=%s end=%s self=%s clickoff=%s bt=%s et=%s id=%s name=%s icon=%s"):format(
            i, tostring(buffSlot),
            tostring(tEnd == 0 and "PERM" or math.floor((tEnd or 0) - (tStart or 0))),
            tostring(castByPlayer), tostring(canClickOff), tostring(buffType), tostring(effectType),
            tostring(abilityId), tostring(name), tostring(icon)))
    end
    -- World skill line probe (werewolf false-positive): dump every WORLD skill line with ALL
    -- returns of GetSkillLineInfo, so we can see the werewolf line's discovered/unlocked flag
    -- on a curse-free character.
    pcall(function()
        out("-- world skill lines --")
        out(("IsPlayerInWerewolfForm=%s"):format(tostring(IsPlayerInWerewolfForm and IsPlayerInWerewolfForm())))
        local function packRets(...)
            local c = select("#", ...)
            local t = {}
            for j = 1, c do t[j] = tostring((select(j, ...))) end
            return table.concat(t, " | ")
        end
        local n = (GetNumSkillLines and GetNumSkillLines(SKILL_TYPE_WORLD)) or 0
        out(("GetNumSkillLines(WORLD)=%s"):format(tostring(n)))
        for i = 1, n do
            out(("  [%d] %s"):format(i, packRets(pcall(GetSkillLineInfo, SKILL_TYPE_WORLD, i))))
        end
    end)

    -- Gear probe: compare each worn item's REAL link fields vs the link we RECONSTRUCT for
    -- peers (which zeroes fields 7-22). Any field non-zero in real but zero in recon is what
    -- we're dropping -- e.g. durability/condition + enchant charge. Also dump condition/charges.
    pcall(function()
        out("-- gear durability/charge probe --")
        local function fields(link)
            local f = {}
            for num in link:gmatch(":(%-?%d+)") do f[#f + 1] = num end
            return f
        end
        for _, slot in ipairs(IV.GEAR_SLOTS) do
            local link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
            if link and link ~= "" then
                local nm = IV.GEAR_SLOT_NAMES[slot] or "?"
                local f = fields(link)
                local recon = IV.ReconstructItemLink(tonumber(f[1]), tonumber(f[2]), tonumber(f[3]),
                                  tonumber(f[4]), tonumber(f[5]), tonumber(f[6]))
                out(("%s real cond=%s charges=%s f=[%s]"):format(nm,
                    tostring(IV.safeCall(GetItemLinkCondition, link)),
                    tostring(IV.safeCall(GetItemLinkNumEnchantCharges, link)), table.concat(f, ",")))
                if recon then
                    out(("  recon cond=%s charges=%s f=[%s]"):format(
                        tostring(IV.safeCall(GetItemLinkCondition, recon)),
                        tostring(IV.safeCall(GetItemLinkNumEnchantCharges, recon)),
                        table.concat(fields(recon), ",")))
                end
            end
        end
    end)

    -- Skill bars + scribing probe: scribed/crafted abilities (Gold Road) render as a red '?'
    -- because GetAbilityIcon/SetAbilityId don't resolve the slotted id. Dump each slot's bound
    -- id, whether it's a crafted ability, its icon/name, and the raw slot texture, so we can
    -- see what the client actually returns for a scribed slot.
    pcall(function()
        out("-- skill bar / scribing probe --")
        local function has(nm) return type(rawget(_G, nm)) == "function" end
        local function call(nm, ...)
            local fn = rawget(_G, nm)
            if type(fn) ~= "function" then return "no-fn" end
            local r = { pcall(fn, ...) }
            return r[1] and tostring(r[2]) or "err"
        end
        out(("HOTBAR_CATEGORY_WEREWOLF=%s"):format(tostring(rawget(_G, "HOTBAR_CATEGORY_WEREWOLF"))))
        for _, hb in ipairs({ { "P", HOTBAR_CATEGORY_PRIMARY }, { "B", HOTBAR_CATEGORY_BACKUP },
                              { "W", rawget(_G, "HOTBAR_CATEGORY_WEREWOLF") } }) do
            if hb[2] == nil then break end
            for slot = 3, 8 do
                local id = GetSlotBoundId(slot, hb[2]) or 0
                local realId = call("GetAbilityIdForCraftedAbilityId", id)   -- crafted -> real ability
                local realN, realI = "", ""
                local rn = tonumber(realId)
                if rn and rn ~= 0 then realN = GetAbilityName(rn) or ""; realI = GetAbilityIcon(rn) or "" end
                out(("%s%d id=%s name='%s' | realId=%s realName='%s' realIcon='%s' | cName='%s' cIcon='%s'"):format(
                    hb[1], slot, tostring(id), (id ~= 0) and tostring(GetAbilityName(id) or "") or "",
                    realId, tostring(realN), tostring(realI),
                    call("GetCraftedAbilityDisplayName", id), call("GetCraftedAbilityIcon", id)))
            end
        end
        for _, nm in ipairs({ "IsCraftedAbilityId", "GetCraftedAbilityIdForAbilityId",
            "GetAbilityIdForCraftedAbilityId", "GetCraftedAbilityIcon", "GetCraftedAbilityDisplayName",
            "GetCraftedAbilityInfo", "GetSlotTexture", "GetCraftedAbilityActiveScriptIds",
            "GetActiveCraftedAbilityId", "GetCraftedAbilityIds", "GetCraftedAbilityIdForSlot" }) do
            out(("  fn %s = %s"):format(nm, has(nm) and "yes" or "no"))
        end
    end)

    -- Crit-damage / advanced-stat discovery (Part 0). Crit chance has a known accessor
    -- (GetCriticalStrikeChance); crit DAMAGE does not, so scan _G for any global whose
    -- name references crit / advanced-stats / derived-stats to find the real accessor +
    -- enum values, and log a crit-chance sanity value.
    -- NB: do NOT iterate pairs(_G) in ESO -- next() taints the callstack the moment it
    -- yields a PROTECTED function (StartWorldEffectOnPlayer, etc.) and aborts. Probe named
    -- candidates directly (rawget is safe for reads of non-protected globals), all wrapped
    -- so a surprise never kills the dump.
    pcall(function()
        out("-- crit / advanced-stat probe --")
        local function pget(fn, ...)
            if type(fn) ~= "function" then return "no-fn" end
            local ok, v = pcall(fn, ...)
            return ok and tostring(v) or ("err:" .. tostring(v))
        end
        local critRating = 0
        pcall(function() critRating = GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS) or 0 end)
        out(("STAT_SPELL_CRITICAL rating=%s  GetCriticalStrikeChance=%s")
            :format(tostring(critRating), pget(rawget(_G, "GetCriticalStrikeChance"), critRating)))
        out(("GetActiveWeaponPairInfo=%s  MAIN=%s BACKUP=%s")
            :format(pget(rawget(_G, "GetActiveWeaponPairInfo")),
                    tostring(rawget(_G, "ACTIVE_WEAPON_PAIR_MAIN")),
                    tostring(rawget(_G, "ACTIVE_WEAPON_PAIR_BACKUP"))))
        -- Candidate accessors/constants for crit DAMAGE (existence + value where numeric).
        local candidates = {
            "GetAdvancedStatValue", "GetNumAdvancedStatCategories", "GetAdvancedStatCategoryInfo",
            "GetAdvancedStatInfo", "GetAdvancedStatsList", "GetNumAdvancedStats",
            "GetPlayerCriticalDamage", "GetCriticalDamage",
            "DERIVEDSTATS_CRITICAL_DAMAGE", "DERIVEDSTATS_CRITICAL_STRIKE",
            "DERIVEDSTATS_CRITICAL_HEALING", "STAT_CRITICAL_STRIKE", "STAT_CRITICAL_DAMAGE",
            "STAT_CRITICAL_DAMAGE_DONE", "STAT_CRITICAL_HEALING",
            "ADVANCED_STAT_DISPLAY_TYPE_PERCENT",
        }
        for _, nm in ipairs(candidates) do
            local v = rawget(_G, nm)
            out(("  %s = <%s>%s"):format(nm, type(v),
                (type(v) == "number") and ("=" .. tostring(v)) or ""))
        end
        -- Advanced-stats enumeration exists -- dump every category's stats (all returns of
        -- each call, since the signatures are unknown) to find Critical Damage's id/value.
        local function packStr(...)
            local n = select("#", ...)
            if n == 0 then return "(none)" end
            local t = {}
            for i = 1, n do t[i] = tostring((select(i, ...))) end
            return table.concat(t, " | ")
        end
        if type(rawget(_G, "GetNumAdvancedStatCategories")) == "function" then
            pcall(function()
                for c = 1, (GetNumAdvancedStatCategories() or 0) do
                    local name, numStats = GetAdvancedStatCategoryInfo(c)
                    out(("advCat %d '%s' numStats=%s"):format(c, tostring(name), tostring(numStats)))
                    for si = 1, (tonumber(numStats) or 0) do
                        local info = { pcall(GetAdvancedStatInfo, c, si) }
                        out(("  info[%d.%d]: %s"):format(c, si, packStr(unpack(info, 2))))
                        local statType = info[2]   -- first real return (after pcall's ok)
                        if statType ~= nil then
                            out(("    val: %s"):format(packStr(pcall(GetAdvancedStatValue, statType))))
                        end
                    end
                end
            end)
        end
    end)

    -- Group-member buff probe (B5): can a RECEIVER derive mundus / food / vampire from a grouped
    -- member's unit tag instead of us transmitting them? ESO generally hides other players' buffs
    -- (the whole reason this addon exists), but the reviewer suggested some may be locally readable.
    -- This settles it empirically: for each OTHER group member, dump GetNumBuffs + every buff, and
    -- classify each the SAME way readBuffs/readCurse do (mundus: icon "mundus"; food: canClickOff;
    -- vampire: icon "vampire"). Also report online/range/zone, since visibility likely needs proximity.
    -- Stand next to a grouped addon-or-not member, ideally with a known mundus + food + vampire, and
    -- read the counts back from SavedVariables. If GetNumBuffs is 0 (or classification never fires)
    -- for members, we MUST keep transmitting those fields. Werewolf can't be derived either way
    -- (IsPlayerInWerewolfForm / the skill-line flag are player-only), so it stays transmitted regardless.
    pcall(function()
        out("-- group-member buff probe (B5) --")
        local size = (GetGroupSize and GetGroupSize()) or 0
        out(("GetGroupSize=%d"):format(size))
        if size <= 1 then
            out("  (not grouped with anyone -- join a group and stand near a member to get useful data)")
            return
        end
        local function lc(s) return (type(s) == "string") and s:lower() or "" end
        for i = 1, size do
            local tag = GetGroupUnitTagByIndex(i)
            if tag and not AreUnitsEqual(tag, "player") then
                local nBuffs = (GetNumBuffs and GetNumBuffs(tag)) or 0
                out(("[%s] name='%s' acct='%s' online=%s inSupportRange=%s sameZone=%s GetNumBuffs=%d"):format(
                    tostring(tag), tostring(GetUnitName(tag)), tostring(GetUnitDisplayName(tag)),
                    tostring(IV.safeCall(IsUnitOnline, tag)),
                    tostring(IV.safeCall(IsUnitInGroupSupportRange, tag)),
                    tostring(GetUnitZone(tag) == GetUnitZone("player")),
                    nBuffs))
                for b = 1, nBuffs do
                    local name, tStart, tEnd, buffSlot, _, icon, buffType, effectType, _, _, abilityId, canClickOff, castByPlayer =
                        GetUnitBuffInfo(tag, b)
                    local mundus = (lc(icon):find("mundus") ~= nil) and "MUNDUS" or ""
                    local food   = (canClickOff == true) and "FOOD?" or ""
                    local vamp   = (lc(icon):find("vampire") ~= nil) and "VAMP" or ""
                    out(("    [%d] %s%s%s name='%s' clickoff=%s self=%s end=%s id=%s icon=%s"):format(
                        b, mundus, food, vamp, tostring(name),
                        tostring(canClickOff), tostring(castByPlayer),
                        tostring(tEnd == 0 and "PERM" or math.floor((tEnd or 0) - (tStart or 0))),
                        tostring(abilityId), tostring(icon)))
                end
            end
        end
    end)

    out("== end ==")

    if IV.sv then
        IV.sv.lastDump = lines
        d("|cFFD700[Inspect Vestige]|r saved to SavedVariables -- now type /reloadui")
    end
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
local function onAddOnLoaded(_, addOnName)
    if addOnName ~= IV.name then return end
    EVENT_MANAGER:UnregisterForEvent(IV.name, EVENT_ADD_ON_LOADED)

    -- Settings: account-wide, shared across servers (preferences should carry everywhere).
    IV.sv = ZO_SavedVars:NewAccountWide("InspectVestige_SavedVariables", 1, nil, SV_DEFAULTS)
    IV.sv.cache = nil   -- one-time cleanup: the cache moved out of this file (was IV.sv.cache)
    -- Cache of received builds: PER-SERVER (passing GetWorldName() as the profile), since the
    -- @accounts you meet on NA aren't the ones on EU/PTS. Own file so it never crosses servers.
    IV.cache = ZO_SavedVars:NewAccountWide("InspectVestige_Cache", 1, nil, { entries = {} }, GetWorldName())
    if type(IV.cache.entries) ~= "table" then IV.cache.entries = {} end

    IV.Window.Init()
    IV.InitStatCapture()       -- capture per-bar offense stats on weapon swap
    IV.InitConsumableTracking() -- cache the character's last-used potion + last-eaten food/drink
    IV.Comms.Init()
    IV.Comms.InitAutoShare()   -- push our loadout to the group on join / change
    IV.Menus.Init()
    IV.SetupSettings()

    SLASH_COMMANDS["/iv"] = onSlash
    SLASH_COMMANDS["/inspectvestige"] = onSlash
    SLASH_COMMANDS["/ivdump"] = IV.RunDiagnostics
    SLASH_COMMANDS["/ivtestgroup"] = function() IV.Comms.TestGroupInspect() end

    IV.Debug(("loaded v%s (peerSync=%s, listMenus=%s, wheel=%s)"):format(
        IV.version, tostring(IV.Comms.ready),
        tostring(IV.Menus.listMenusReady), tostring(IV.Menus.wheelReady)))
end

EVENT_MANAGER:RegisterForEvent(IV.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
