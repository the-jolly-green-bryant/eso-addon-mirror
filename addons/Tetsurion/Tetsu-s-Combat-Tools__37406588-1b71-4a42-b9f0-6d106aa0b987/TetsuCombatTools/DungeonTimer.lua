TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local ADDON = "TetsuCombatToolsTimer"
local PREVIEW_MS = 10000
local HOLD_AFTER_MS = 12000

local root
local lab
local built = false
local ticking = false

local zoneKey = ""
local kind = "none" -- dungeon | raid | none
local startedAt = 0
local frozenMs = nil
local previewUntil = 0
local completeAt = 0
local sawCombat = false

local function Vars()
    return T.savedVars
end

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function TimerOn()
    local v = Vars()
    return v and v.timerEnabled == true
end

local function NowMs()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return (GetTimeStamp and GetTimeStamp() or 0) * 1000
end

local function SceneIsShowing(scene)
    if not scene or not scene.IsShowing then return false end
    local ok, showing = pcall(function()
        return scene:IsShowing()
    end)
    return ok and showing and true or false
end

local function WorldHudOpen()
    if HUD_SCENE or HUD_UI_SCENE then
        return SceneIsShowing(HUD_SCENE) or SceneIsShowing(HUD_UI_SCENE)
    end
    return true
end

local function DiffVeteran()
    if not GetCurrentZoneDungeonDifficulty then return false end
    local ok, d = pcall(GetCurrentZoneDungeonDifficulty)
    if not ok then return false end
    if DUNGEON_DIFFICULTY_VETERAN and d == DUNGEON_DIFFICULTY_VETERAN then
        return true
    end
    return false
end

local function InEndless()
    if IsPlayerInEndlessDungeon then
        local ok, v = pcall(IsPlayerInEndlessDungeon)
        if ok and v then return true end
    end
    if GetCurrentEndlessDungeonId then
        local ok, id = pcall(GetCurrentEndlessDungeonId)
        if ok and tonumber(id) and tonumber(id) > 0 then return true end
    end
    return false
end

local function InBg()
    if IsActiveWorldBattleground then
        local ok, v = pcall(IsActiveWorldBattleground)
        if ok and v then return true end
    end
    if IsPlayerInBattleground then
        local ok, v = pcall(IsPlayerInBattleground)
        if ok and v then return true end
    end
    return false
end

local function InDungeonFlag()
    if IsUnitInDungeon then
        local ok, v = pcall(IsUnitInDungeon, "player")
        if ok and v then return true end
    end
    return false
end

local function InRaidFlag()
    if IsPlayerInRaid then
        local ok, v = pcall(IsPlayerInRaid)
        if ok and v then return true end
    end
    if IsRaidInProgress then
        local ok, v = pcall(IsRaidInProgress)
        if ok and v then return true end
    end
    return false
end

local function InStaging()
    if IsPlayerInRaidStagingArea then
        local ok, v = pcall(IsPlayerInRaidStagingArea)
        if ok and v then return true end
    end
    return false
end

-- Veteran group dungeon / trial / arena. No normal, no archive, no BG.
local function InVetPve()
    if InBg() or InEndless() then return false end
    if not DiffVeteran() then return false end
    if InRaidFlag() or InDungeonFlag() then return true end
    return false
end

local function IsRaidKind()
    return InRaidFlag()
end

local ARENA_ZONES = {
    [635] = true,
    [677] = true,
    [1051] = true,
    [1082] = true,
    [1227] = true,
    [1228] = true,
}

local function ZoneIdNow()
    if GetZoneId and GetUnitZoneIndex then
        local ok, id = pcall(function()
            return GetZoneId(GetUnitZoneIndex("player"))
        end)
        if ok then return tonumber(id) or 0 end
    end
    return 0
end

local function GrabName(fn, a)
    if not fn then return "" end
    local ok, s
    if a ~= nil then
        ok, s = pcall(fn, a)
    else
        ok, s = pcall(fn)
    end
    if ok and type(s) == "string" then return s end
    return ""
end

local function ZoneHaystack()
    local z = ZoneIdNow()
    local parts = {
        GrabName(GetUnitZone, "player"),
        GrabName(GetZoneNameById, z),
        GrabName(GetMapName),
        GrabName(GetPlayerLocationName),
        GrabName(GetCurrentZoneName),
    }
    return string.lower(table.concat(parts, " "))
end

-- Official veteran speed minutes. zoneId is language-safe.
-- Names are a fallback for every shipped client language.
local SPEED_BY_ID = {
    -- base dungeons
    [11] = 20,   -- Vaults of Madness
    [22] = 20,   -- Volenfell
    [31] = 20,   -- Selene's Web
    [38] = 20,   -- Blackheart Haven
    [63] = 20,   -- Darkshade I
    [64] = 20,   -- Blessed Crucible
    [130] = 20,  -- Crypt of Hearts I (legacy)
    [131] = 20,  -- Tempest Island
    [144] = 20,  -- Spindleclutch I
    [146] = 15,  -- Wayrest I
    [148] = 20,  -- Arx Corinium
    [283] = 15,  -- Fungal I
    [380] = 20,  -- Banished I
    -- trials (confirmed from wiki.esoui / set data)
    [1121] = 30, -- Sunspire
    [1263] = 30, -- Rockgrove
    [1344] = 30, -- Dreadsail Reef
}

local SPEED_RULES = {
    {15, {
        "fungal grotto i", "грибной грот i", "pilzgrotte i", "grotte fongique i",
        "caverna hongo i", "wayrest sewers i", "канализация вэйреста i",
        "kanalisation von wegesruh i", "égouts d'ailegard i",
        "cloudrest", "клаудрест", "wolkenruh", "perchoir", "nubelia",
        "云栖", "云息", "クラウドレスト",
        "asylum sanctorium", "изоляционный", "asyl sanctorium", "asile sanctorium",
        "庇护圣所", "アサイラム",
    }},
    {20, {
        "fungal grotto ii", "грибной грот ii", "pilzgrotte ii", "grotte fongique ii",
        "wayrest sewers ii", "канализация вэйреста ii",
        "kanalisation von wegesruh ii",
    }},
    {30, {"city of ash ii", "город пепла ii", "stadt der asche ii", "cité des cendres ii"}},
    {20, {"city of ash", "город пепла", "stadt der asche", "cité des cendres"}},
    {30, {"crypt of hearts ii", "склеп сердец ii", "krypta der herzen ii", "crypte des cœurs ii"}},
    {20, {"crypt of hearts", "склеп сердец", "krypta der herzen", "crypte des cœurs"}},

    {45, {"ossein cage", "ossein", "оссеин", "ossein-käfig", "cage d'osseine", "osseinkäfig", "オセイン"}},
    {40, {
        "maw of lorkhaj", "пасть лорхадж", "лорхадж", "schlund von lorkhaj",
        "gueule de lorkhaj", "洛克汗", "ロルカジ",
        "halls of fabrication", "залы фабрикац", "залы изготов", "hallen der fertigung",
        "salles de fabrication", "制造大厅", "ファブリケーション",
    }},
    {35, {
        "kyne's aegis", "эгида кин", "kynes ägide", "égide de kyne", "кайне", "凯恩之盾", "カイネ",
        "lair of maarselok", "марселок", "horst des maarselok", "antre de maarselok",
    }},
    {33, {
        "aetherian archive", "этериан", "этериев", "ätherisches archiv", "archive étheriée",
        "艾瑟瑞", "エセリアン",
        "hel ra citadel", "хель-ра", "хель ра", "хел ра", "zitadelle von hel ra",
        "citadelle d'hel ra", "赫尔·拉", "ヘル・ラ",
        "sanctum ophidia", "святилище офид", "heiligtum von ophidia", "sanctuaire d'ophidia",
        "乌鞘蛇", "オフィディア",
    }},
    {15, {
        "cloudrest", "клаудрест", "wolkenruh", "perchoir", "nubelia", "云栖", "云息",
        "asylum sanctorium", "изоляционный", "asyl sanctorium", "asile sanctorium", "庇护圣所",
    }},
    {30, {
        "dreadsail reef", "dreadsail", "риф зловещ", "риф жутких", "зловещих парус", "жутких парус",
        "schreckenssegel", "voiles funestes", "velamuerte", "恐帆", "ドレッドセイル",
        "sunspire", "солнечный шпиль", "sonnenspitze", "flèche du soleil", "太阳尖顶", "サンスパイア",
        "lucent citadel", "люцент", "luzide zitadelle", "citadelle lucente", "ciudadela lucente",
        "цитадель люцент", "ルセント",
        "sanity's edge", "sanity", "край безумия", "грань безумия", "rand des wahnsinns",
        "fil de la raison", "filo de la cordura", "理智边缘",
        "rockgrove", "рокгроув", "felshain", "rocheroc", "石林", "ロックグローブ",
        "moongrave", "лунная могила", "mondgrab",
        "icereach", "ледяной предел", "eiswehr",
        "unhallowed", "неосвящ",
        "imperial city prison", "имперск", "kaiserstadtgefängnis", "prison de la cité impériale",
        "white-gold tower", "белозолот", "weißgoldturm", "tour d'or blanc",
    }},
    {25, {
        "red petal", "алый лепесток", "rotblütenbastion", "bastion du pétale rouge",
        "dread cellar", "погреб ужаса", "schreckenskeller", "caveau de l'effroi",
        "black drake villa", "вилла черного дракона", "schwarzdrakenvilla",
        "the cauldron", "котёл", "der kessel", "le chaudron",
        "castle thorn", "замок шипов", "schloss dorn", "château d'épine",
        "stone garden", "каменный сад", "steingarten", "jardin de pierre",
        "shipwright", "корабельн", "schiffbrüchigen",
        "coral aerie", "кораллов", "korallennest", "aire de corail",
        "earthen root", "землян", "erdenen wurzel", "enclave de la racine",
        "graven deep", "могильные глубины", "grabestiefe", "profondeurs graves",
        "bal sunnar", "бал суннар",
        "scrivener", "писц", "saal des schreibers",
        "oathsworn", "клятвохранимый",
        "bedlam veil", "завеса бедлама",
        "exiled redoubt", "оплот изгнан",
        "lep seclusa", "леп секлус",
    }},
    {20, {
        "banished cells", "темницы изгнанников", "verbotene zellen", "cellules de bannissement",
        "elden hollow", "элденская расщелина", "eldenhohl", "creux d'elden",
        "spindleclutch", "паутина сел", "spindeltiefen", "tressefuseau",
        "darkshade", "глубокая тень", "dunkelschatten", "cavernes d'ombre noire",
        "arx corinium", "аркс-кориниум",
        "volenfell", "воленфел",
        "blackheart haven", "гавань черного сердца", "schwarzherzhort",
        "direfrost", "лютый мороз", "grauenfrost",
        "blessed crucible", "священное горнило", "gesegnete feuerprobe",
        "selene", "селен", "selenes netz",
        "tempest island", "остров бурь", "tempestinsel",
        "vaults of madness", "своды безумия", "kammern des wahnsinns",
        "cradle of shadows", "колыбель теней", "wiege der schatten",
        "mazzatun", "маззатун",
        "falkreath", "фалкрит", "falkreathfeste",
        "bloodroot", "кровавый корень", "blutwurzschmiede",
        "fang lair", "логово клыка", "reißerhorst",
        "scalecaller", "чешуйчат", "schuppenruferspitze",
        "moon hunter", "лунный охотник", "mondjägerfeste",
        "march of sacrifices", "марш жертвоприношений", "marsch der aufopferung",
        "frostvault", "морозный склеп", "frostgewölbe",
        "depths of malatar", "глубины малатара", "tiefen von malatar",
    }},
}

local function HasNeedle(low, needle)
    return string.find(low, needle, 1, true) ~= nil
end

local function SpeedGoalMs()
    local v = Vars()
    if v and v.timerGoal == false then return nil end
    local z = ZoneIdNow()
    local seen = {}
    local cur = z
    for _ = 1, 4 do
        cur = tonumber(cur) or 0
        if cur <= 0 or seen[cur] then break end
        seen[cur] = true
        if SPEED_BY_ID[cur] then
            return SPEED_BY_ID[cur] * 60 * 1000
        end
        if GetParentZoneId then
            local ok, parent = pcall(GetParentZoneId, cur)
            if ok then
                cur = parent
            else
                break
            end
        else
            break
        end
    end
    local low = ZoneHaystack()
    if low == "" then return nil end
    for i = 1, #SPEED_RULES do
        local mins = SPEED_RULES[i][1]
        local list = SPEED_RULES[i][2]
        for j = 1, #list do
            if HasNeedle(low, list[j]) then
                return mins * 60 * 1000
            end
        end
    end
    return nil
end

local function NameLooksArena()
    local n = ""
    local z = ZoneIdNow()
    if GetZoneNameById and z > 0 then
        local ok, s = pcall(GetZoneNameById, z)
        if ok and type(s) == "string" then n = s end
    end
    if n == "" and GetMapName then
        local ok, s = pcall(GetMapName)
        if ok and type(s) == "string" then n = s end
    end
    n = string.lower(n)
    local keys = {
        "arena", "maelstrom", "dragonstar", "blackrose", "vateshran",
        "арена", "мельстрим", "драгонстар", "блекроуз", "ватешран",
    }
    for i = 1, #keys do
        if string.find(n, keys[i], 1, true) then return true end
    end
    return false
end

local function DetectKind()
    if not InVetPve() then return "none" end
    local z = ZoneIdNow()
    if ARENA_ZONES[z] or NameLooksArena() then return "arena" end
    if InRaidFlag() then return "trial" end
    return "dungeon"
end

local function KindOn(k)
    k = k or kind
    local v = Vars()
    if not v then return false end
    if k == "arena" then return v.timerArena ~= false end
    if k == "trial" then return v.timerTrial ~= false end
    if k == "dungeon" then return v.timerDungeon ~= false end
    return false
end



local function OfficialRaidMs()
    if InStaging() then return nil end
    if not GetCurrentRaidTime then return nil end
    local ok, t = pcall(GetCurrentRaidTime)
    if not ok then return nil end
    t = tonumber(t)
    if not t or t <= 0 then return nil end
    -- Seconds vs ms.
    if t < 100000 then
        return t * 1000
    end
    return t
end

local function CurrentZoneKey()
    local z = 0
    if GetZoneId and GetUnitZoneIndex then
        local ok, id = pcall(GetZoneId, GetUnitZoneIndex("player"))
        if ok then z = tonumber(id) or 0 end
    elseif GetCurrentMapId then
        local ok, id = pcall(GetCurrentMapId)
        if ok then z = tonumber(id) or 0 end
    end
    return tostring(z) .. ":" .. (DiffVeteran() and "v" or "n")
end

local function FormatMs(ms)
    ms = tonumber(ms) or 0
    if ms < 0 then ms = 0 end
    local sec = math.floor(ms / 1000)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
end

local function AttachFragment(control)
    if not control then return end
    local frag
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    if HUD_SCENE and HUD_SCENE.AddFragment then
        pcall(function() HUD_SCENE:AddFragment(frag) end)
    end
    if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then
        pcall(function() HUD_UI_SCENE:AddFragment(frag) end)
    end
end

local function Layout()
    if not root or not lab then return end
    local v = Vars()
    local ox = v and tonumber(v.timerOffsetX) or 0
    local oy = v and tonumber(v.timerOffsetY)
    if oy == nil then oy = -280 end
    local sc = tonumber(v and v.timerScale) or 100
    if sc < 40 then sc = 40 end
    if sc > 250 then sc = 250 end
    sc = sc / 100
    local px = math.floor(36 * sc + 0.5)
    if px < 16 then px = 16 end
    if px > 90 then px = 90 end
    local fontName = "$(GAMEPAD_BOLD_FONT)|" .. px .. "|soft-shadow-thick"
    root:SetClampedToScreen(false)
    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    root:SetDimensions(math.floor(520 * sc), math.floor(px + 18))
    lab:ClearAnchors()
    lab:SetAnchor(CENTER, root, CENTER, 0, 0)
    lab:SetDimensions(math.floor(520 * sc), math.floor(px + 18))
    local ok = pcall(function()
        lab:SetFont(fontName)
    end)
    if not ok then
        pcall(function()
            lab:SetFont("ZoFontGamepad34")
        end)
        pcall(function()
            lab:SetScale(sc)
        end)
    else
        pcall(function()
            lab:SetScale(1)
        end)
    end
end

local function ElapsedMs()
    local now = NowMs()
    if previewUntil > now then
        return now - (previewUntil - PREVIEW_MS)
    end
    if frozenMs ~= nil then
        return frozenMs
    end
    if kind == "trial" or kind == "arena" then
        local off = OfficialRaidMs()
        if off then return off end
    end
    if startedAt > 0 then
        return now - startedAt
    end
    return 0
end

local function ShouldShow()
    if not TimerOn() then return false end
    local now = NowMs()
    if previewUntil > now then
        return true
    end
    if not WorldHudOpen() then return false end
    if not InVetPve() then return false end
    if not KindOn(DetectKind()) then return false end
    if InStaging() then return false end
    return true
end

local function Paint()
    if not root or not lab then return end
    Layout()
    if not ShouldShow() then
        root:SetHidden(true)
        return
    end
    root:SetHidden(false)
    local ms = ElapsedMs()
    local now = NowMs()
    local goal = SpeedGoalMs()
    if previewUntil > now and not goal then
        goal = 20 * 60 * 1000
    end
    if frozenMs ~= nil then
        lab:SetColor(0.35, 0.92, 0.42, 1)
    elseif goal and ms > goal then
        lab:SetColor(0.95, 0.28, 0.22, 1)
    elseif previewUntil > now then
        lab:SetColor(1, 0.85, 0.25, 1)
    else
        lab:SetColor(1, 0.92, 0.55, 1)
    end
    if goal then
        lab:SetText(FormatMs(ms) .. " / " .. FormatMs(goal))
    else
        lab:SetText(FormatMs(ms))
    end
end

local function StartTick()
    if ticking then return end
    ticking = true
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Tick", 200, function()
        local now = NowMs()
        if frozenMs ~= nil and completeAt > 0 and (now - completeAt) > HOLD_AFTER_MS then
            -- Stay visible in the instance; only the color is frozen.
        end
        if previewUntil > 0 and now >= previewUntil then
            previewUntil = 0
        end
        if not TimerOn() and previewUntil <= now then
            EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Tick")
            ticking = false
            if root then root:SetHidden(true) end
            return
        end
        Paint()
    end)
end

local function ResetRun()
    startedAt = 0
    frozenMs = nil
    completeAt = 0
    sawCombat = false
end

local function BeginRun(fromRaid)
    if startedAt > 0 or frozenMs ~= nil then return end
    kind = DetectKind()
    if kind == "none" then
        kind = fromRaid and "trial" or "dungeon"
    end
    local off = fromRaid and OfficialRaidMs() or nil
    if off and off > 0 then
        startedAt = NowMs() - off
    else
        startedAt = NowMs()
    end
    frozenMs = nil
    StartTick()
    Paint()
end

local function FinishRun()
    if frozenMs ~= nil then return end
    if startedAt <= 0 and not OfficialRaidMs() then
        return
    end
    frozenMs = ElapsedMs()
    completeAt = NowMs()
    StartTick()
    Paint()
end

local function RefreshZone()
    local key = CurrentZoneKey()
    if key ~= zoneKey then
        local nowInside = InVetPve()
        zoneKey = key
        ResetRun()
        if nowInside and not InStaging() then
            kind = DetectKind()
            if KindOn(kind) then
                local off = OfficialRaidMs()
                -- Dungeon: leaving always kills the clock. Next pull is a new run.
                -- Trial/arena: official raid time continues if the instance is still alive.
                if kind ~= "dungeon" and off and off > 0 then
                    BeginRun(true)
                end
            end
        else
            kind = "none"
        end
    elseif InVetPve() then
        kind = DetectKind()
        if KindOn(kind) and (kind == "trial" or kind == "arena") then
            if startedAt <= 0 and frozenMs == nil and not InStaging() and OfficialRaidMs() then
                BeginRun(true)
            end
        end
    end
    Paint()
    if InVetPve() or previewUntil > NowMs() then
        StartTick()
    end
end

local function OnCombat(_, inCombat)
    if not TimerOn() then return end
    if not InVetPve() or InStaging() then return end
    kind = DetectKind()
    if not KindOn(kind) then return end
    if kind == "trial" or kind == "arena" then
        if startedAt <= 0 and frozenMs == nil then
            BeginRun(true)
        end
        return
    end
    if inCombat and not sawCombat then
        sawCombat = true
        BeginRun(false)
    end
end

local function OnRaidStarted()
    if not TimerOn() or not InVetPve() then return end
    kind = DetectKind()
    if not KindOn(kind) then return end
    if frozenMs == nil then
        startedAt = 0
        BeginRun(true)
    end
end

local function OnRaidComplete()
    if not TimerOn() then return end
    kind = DetectKind()
    FinishRun()
end

local function OnAnnounce(_, _p, _s, _i, _so, _life, category)
    if not TimerOn() then return end
    if CSA_CATEGORY_RAID_COMPLETE_TEXT and category == CSA_CATEGORY_RAID_COMPLETE_TEXT then
        FinishRun()
    end
end

local function Build()
    if built then return end
    root = WINDOW_MANAGER:CreateTopLevelWindow(ADDON .. "Root")
    root:SetClampedToScreen(false)
    root:SetMouseEnabled(false)
    root:SetHidden(true)
    lab = WINDOW_MANAGER:CreateControl(ADDON .. "Lab", root, CT_LABEL)
    lab:SetAnchor(CENTER, root, CENTER, 0, 0)
    lab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    lab:SetColor(1, 0.92, 0.55, 1)
    pcall(function()
        lab:SetFont("ZoFontGamepad34")
    end)
    lab:SetText("0:00")
    -- No HUD fragment: preview must stay visible over the settings menu.
    built = true
end

function T.TimerPreview()
    previewUntil = NowMs() + PREVIEW_MS
    Build()
    StartTick()
    Paint()
end

function T.TimerRefresh()
    Build()
    RefreshZone()
    Paint()
    if TimerOn() then
        StartTick()
    elseif root then
        root:SetHidden(true)
    end
end

function T.TimerStart()
    Build()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(RefreshZone, 400)
    end)
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_COMBAT_STATE, OnCombat)
    end
    if EVENT_RAID_TRIAL_STARTED then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_RAID_TRIAL_STARTED, OnRaidStarted)
    end
    if EVENT_RAID_TRIAL_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_RAID_TRIAL_COMPLETE, OnRaidComplete)
    end
    if EVENT_RAID_TIMER_STATE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_RAID_TIMER_STATE_UPDATE, function()
            if not TimerOn() then return end
            if HasRaidEnded then
                local ok, ended = pcall(HasRaidEnded)
                if ok and ended then
                    FinishRun()
                    return
                end
            end
            if IsRaidInProgress then
                local ok, prog = pcall(IsRaidInProgress)
                if ok and prog and startedAt <= 0 and frozenMs == nil then
                    OnRaidStarted()
                end
            end
        end)
    end
    if EVENT_DISPLAY_ANNOUNCEMENT then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_DISPLAY_ANNOUNCEMENT, OnAnnounce)
    end
    RefreshZone()
    StartTick()
end
