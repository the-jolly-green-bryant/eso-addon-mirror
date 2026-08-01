-- Inspect Vestige by LuckyRome13
-- Window.lua -- builds and populates the inspect window interior.
--
-- Works identically for self / peer / cache / public loadouts:
--   * Gear   : text rows (slot -> set, trait, quality). Item icon shown when we have
--              the full itemLink (self/cache); set/trait come through for peers too.
--   * Skills : ability icons (GetAbilityIcon works from an id, so peers get real icons).
--   * Attrs/Mundus/CP/Food: text.

local IV = InspectVestige
IV.Window = IV.Window or {}
local Window = IV.Window

local WM = WINDOW_MANAGER

local win, content, titleLabel, subtitleLabel, statusLabel
local gearIcon, gearLabel, gearData = {}, {}, {}
local gearValue = {}                           -- Equipment view: the set-name value, split off gearLabel
                                              -- (the slot-name box) so values line up per group
local cosmeticData = {}                       -- parallel to gearData: [poolIndex] = tooltip info in Cosmetics mode
local poisonCtrl, poisonTex, poisonData = {}, {}, {}   -- [1]=front bar, [2]=back bar poison icon
local dyeSwatch = {}   -- [cell k][1..3] = { cell = <mouse-enabled CT_CONTROL>, bd = <CT_BACKDROP fill> }:
                       -- dye chips at the right edge of a Cosmetics row; hidden in the gear view
local dyeData   = {}   -- [cell k][1..3] = dye id, for the hover tooltip
local frontIcon, backIcon, skillData = {}, {}, {}
local attrsTitle, attrsLabel
local frontStats, backStats = {}, {}         -- per-bar stat labels {A,B,C}, aligned with the skill bars
local skillsShowWerewolf = false             -- Back-bar row toggle (true = show werewolf form bar)
local gearShowCosmetics = false              -- Equipment-header toggle (true = show the Cosmetics view)
local renderEquipment                        -- fwd decl (dispatches gear vs cosmetics; defined below)
local renderBackBar                          -- fwd decl (defined after populateBar; used in Init)
local mundusLabel, foodLabel, curseLabel, cpHeaderLabel
local mundusHeader, foodHeader, curseHeader, potionHeader   -- bold gold labels beside each value
local potionLabel                             -- quickslot-potion value (row under Food / Drink)
local classHeader                             -- "Class Mastery" / "Subclass" section header
local classCtrl, classIcon, classLabel, classData = {}, {}, {}, {}   -- per-entry pool (right column)
local classValue = {}                         -- subclass mode: the skill-line name, split off classLabel
                                              -- (the fixed-width class-name box) so the lines align
local gearHeader, frontHeader, backHeader   -- section titles (hidden in compact mode)
local setPanel, setPanelTitle, setPanelArmor, setColF, setColB   -- Equipment-header set-summary popup
local setRowName, setRowFront, setRowBack = {}, {}, {}           -- its columns: name | front | back
local cpStar, cpStarData = {}, {}          -- individually-hoverable CP star chips
local cpStarPoints = {}                     -- pool index -> the shown target's points in that star
local mundusData, foodData, curseData      -- ability ids for the mundus / food / curse rows
local potionData                            -- reconstructed item link for the potion row hover
local foodItemLink                          -- self: the food ITEM link (matched by icon) for a rich tooltip
local currentLoadout, currentSource        -- loadout being shown (for set-piece counting)
local cpBaseY = 0
local built = false

local COL_WIDTH    = 250
local GEAR_ROW_H   = 22
local BLANK_ROW_H  = 11     -- half-height spacer between gear groups
local TOP_PAD      = 20     -- whitespace above the Equipment section
local SECTION_PAD  = 12     -- whitespace after the Stats section
local GEAR_BASE_Y  = TOP_PAD + 26   -- y (within content) where gear cells begin, below the header
-- Height reserved for the gear block = the right column's worst case
-- (3 jewelry + blank + 2 front weapons + blank + 2 back weapons).
local GEAR_BLOCK_H = 3 * GEAR_ROW_H + BLANK_ROW_H + 2 * GEAR_ROW_H + BLANK_ROW_H + 2 * GEAR_ROW_H
-- Shared gear/cosmetics cell pool. The gear view uses at most 16 (one per equip slot); the COSMETICS
-- view can need more (up to ~11 slot appearances + 10 collectible rows incl. mount/pet), so size for it.
local GEAR_POOL_N  = 22
-- Cosmetic NAME tint: near-white, so names read apart from the khaki C5C29E slot/category labels
-- (the old E0D8B0 tan was too close to the label colour).
local COS_NAME_HEX = "E6E6E6"
local SKILL_SIZE   = 40
local SKILL_GAP    = 46
local ULT_GAP      = 20    -- extra whitespace before the ultimate (icon 6)
-- TWO-COLUMN body. LEFT (x 0, 500 wide): Equipment, skill bars, Champion Points (the wide sections).
-- RIGHT (x RIGHT_COL_X, RIGHT_COL_W wide): Attributes, Stats, Mundus/Food/Curse, Class/Subclass. The
-- name/subtitle header spans the full content width. Halves the window height vs the old single column.
local LEFT_COL_W    = 500
local RIGHT_COL_X   = 520
local RIGHT_COL_W   = 500                         -- same width as the left column
local LABELED_VALUE_X = 100                       -- value x-offset in a labeled row (clears the widest
                                                  -- header, "Food / Drink", so all values line up)
local CONTENT_W     = RIGHT_COL_X + RIGHT_COL_W   -- 1020 (matches Window.xml Content)
-- Centre the 6-icon bar (5 abilities + gap + ultimate) within the LEFT column.
local SKILL_START_X = (LEFT_COL_W - (5 * SKILL_GAP + ULT_GAP + SKILL_SIZE)) / 2
local FULL_HEIGHT    = 650   -- matches Window.xml; used when a build is shown (taller column + header)
local COMPACT_HEIGHT = 154   -- header + "no data" blurb only (public / nothing shared)
local FULL_WIDTH     = CONTENT_W + 40   -- 940 (matches Window.xml); the two-column build view
local COMPACT_WIDTH  = 540              -- narrow card for a public / no-data target (name + blurb only)

-- Resource colours (magicka/stamina/health) for the Attributes + Stats rows, and the
-- muted grey (matching the class/race/alliance subtitle) for dmg/crit/pen.
local COLOR_MAG  = "4d9fff"
local COLOR_STAM = "55dd55"
local COLOR_HP   = "ff5555"
local COLOR_STAT = "b48ce0"   -- dmg/crit/pen: light purple (distinct from gold title / white)

-- Equipment display grouping. Armor fills the left column; jewelry then weapons fill the
-- right column with blank-row separators. Each weapon bar's poison (if equipped) shows as a
-- small hoverable icon just right of that bar's weapon icon(s) -- see the poison-icon pool.
local GEAR_ARMOR         = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,
                             EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET }
local GEAR_JEWELRY       = { EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2 }
local GEAR_FRONT_WEAPONS = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
local GEAR_BACK_WEAPONS  = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }
-- The bar poison slot that pairs with each weapon slot (front weapons -> front poison, etc.).
local POISON_FOR_WEAPON  = {
    [EQUIP_SLOT_MAIN_HAND]   = EQUIP_SLOT_POISON,    [EQUIP_SLOT_OFF_HAND]    = EQUIP_SLOT_POISON,
    [EQUIP_SLOT_BACKUP_MAIN] = EQUIP_SLOT_BACKUP_POISON, [EQUIP_SLOT_BACKUP_OFF] = EQUIP_SLOT_BACKUP_POISON,
}
local POISON_SIZE    = 18   -- poison icon, sized to match a gear icon
local POISON_POOL_N  = 2    -- one poison icon per BAR (front/back): ESO has a single poison slot per
                            -- bar, so a dual-wield bar shows ONE icon centred across both weapon rows
                            -- (a per-row copy on each weapon read as two poisons -- tried + reverted).
local POISON_LABEL_X = 28   -- a poisoned weapon row's label gap after the icon (clears the poison icon:
                            -- ~4 base + 2 + POISON_SIZE + 4); normal weapon/gear rows use 4.
-- Fixed slot-name box widths (ZoFontGameSmall) per gear group, so the set-name VALUE lines up within
-- each group. Each clears its widest slot name -- armor "Shoulders", jewelry "Necklace", weapon
-- "Main (front)". Kept separate per group (armor / jewelry / weapons align independently).
local GEAR_NAME_W_ARMOR   = 64
local GEAR_NAME_W_JEWELRY = 68
local GEAR_NAME_W_WEAPON  = 68
local CLASS_ROW_H  = 28    -- Class/Subclass entry row height (a little space between rows)
local CLASS_POOL_N = 8     -- up to 3 subclass lines, or the equipped Class Mastery passives
local CLASS_NAME_W = 120   -- fixed class-name box (ZoFontGame) in subclass mode, so the skill-line
                           -- names line up; clears the longest class name ("Dragonknight")
local CP_LINE_H    = 20
local CP_GAP       = 4     -- horizontal gap after each star's trailing comma
local CP_LEFT_MARGIN = 16  -- left indent of each comma-delimited CP row
local CP_GROUP_GAP = 10    -- vertical whitespace between discipline-colour groups
-- CP rows are grouped by discipline colour, in this order: green (Craft), blue (Warfare),
-- red (Fitness). Hexes must match CP_DISCIPLINE_HEX (see buildCPColorTable).
local CP_GROUP_ORDER = { "55dd55", "4d9fff", "ff5555" }

local ARMOR_WEIGHT_NAME  = {}   -- ARMORTYPE_* -> label (built in Init, guarded)
local ARMOR_WEIGHT_ORDER = {}   -- display order (Light, Medium, Heavy)
-- Set-summary popup geometry -- REAL columns via fixed x positions, so no GetTextWidth measurement.
local SET_PAD      = 16
local SET_NAME_W   = 232
local SET_FRONT_X  = SET_PAD + SET_NAME_W + 8
local SET_COL_W    = 48
local SET_BACK_X   = SET_FRONT_X + SET_COL_W
local SET_PANEL_W  = SET_BACK_X + SET_COL_W + SET_PAD
local SET_ROW_H    = 24
local SET_HEADER_Y = SET_PAD + 6 --24    -- column headers (Front/Back), below the title
local SET_ROW0_Y   = SET_PAD + 28 --46    -- first set row

local QUALITY_HEX = {}         -- filled at Init (constants may not all exist)
local CP_DISCIPLINE_HEX = {}   -- champion discipline colour by type (filled at Init)

--------------------------------------------------------------------------------
-- Name / colour resolvers (all guarded)
--------------------------------------------------------------------------------
local function resolveSetName(setId)
    if not setId or setId == 0 then return nil end
    local name = IV.safeCall(GetItemSetName, setId)
    if name and name ~= "" then return zo_strformat("<<1>>", name) end
    return "Set #" .. tostring(setId)
end

local function resolveTraitName(trait)
    if not trait or trait == 0 then return nil end
    local base = _G.SI_ITEMTRAITTYPE
    if base then
        local s = IV.safeCall(GetString, base, trait)
        if s and s ~= "" then return s end
    end
    return nil
end

local function resolveAbilityName(id)
    if not id or id == 0 then return nil end
    local name = IV.safeCall(GetAbilityName, id)
    if name and name ~= "" then return zo_strformat("<<1>>", name) end
    return nil
end

-- Returns a champion star's display name and its discipline colour hex.
-- Colours: Warfare=blue, Fitness=red, Craft=green (verified against ESO's CP UI).
local function resolveCPStar(id)
    if not id or id == 0 then return nil, nil end
    local name = IV.safeCall(GetChampionSkillName, id)
    local hex
    if _G.CHAMPION_DATA_MANAGER then
        local data = IV.safeCall(function() return CHAMPION_DATA_MANAGER:GetChampionSkillData(id) end)
        if data then
            if not name or name == "" then
                name = IV.safeCall(function() return data:GetName() end)
            end
            local dtype = IV.safeCall(function()
                return data:GetChampionDisciplineData():GetType()
            end)
            if dtype then hex = CP_DISCIPLINE_HEX[dtype] end
        end
    end
    if name and name ~= "" then return zo_strformat("<<1>>", name), hex end
    return nil, hex
end

local function qualityHex(q)
    return QUALITY_HEX[q] or "ffffff"
end

-- A dimmed/desaturated version of a rarity hex -- for a non-set piece's item name, so it
-- still hints at the rarity colour without competing with the vivid set-name colours.
local function mutedHex(hex)
    local function mix(i)
        local c = tonumber(hex:sub(i, i + 1), 16) or 128
        return math.floor(c * 0.3 + 90)   -- blend ~70% toward mid-grey (just a faint tint)
    end
    return string.format("%02x%02x%02x", mix(1), mix(3), mix(5))
end

-- Crit rating -> chance %. Prefer the game's OWN converter: it's exact, and it's a pure function of
-- the rating (no unit/player context), so it works on a peer's transmitted rating too. Verified on a
-- real client: rating 9593 -> 43.7797%, i.e. the true constant is ~219.12 rating per 1%, not a round
-- 219 (which we used before, and which drifts enough to flip the rounded display at the boundary).
-- The rating ALREADY includes the inherent ~10% base every character has -- do NOT add 10 on top.
local CRIT_RATING_PER_PCT = 219.12   -- fallback only, if the API ever goes away
local function critPct(rating)
    rating = rating or 0
    local ok, pct = pcall(GetCriticalStrikeChance, rating)
    if not ok or type(pct) ~= "number" then pct = rating / CRIT_RATING_PER_PCT end
    return string.format("%d%%", math.floor(pct + 0.5))
end

-- Ensure a gear entry has a display item link + set info. Peer entries arrive with only
-- an itemId; rebuild a link so the icon, set name, and the real item tooltip all work.
-- Returns the link (or nil).
local function ensureGearLink(g)
    if not g then return nil end
    if (not g.itemLink or g.itemLink == "") and g.itemId and g.itemId ~= 0 then
        g.itemLink = IV.ReconstructItemLink(g.itemId, g.subtype, g.level,
                                            g.enchantId, g.enchantSub, g.enchantLevel, g.condCharge)
    end
    if g.itemLink and g.itemLink ~= "" then
        if g.setId == nil then
            local hasSet, _, _, _, maxEquipped, setId = GetItemLinkSetInfo(g.itemLink, false)
            g.hasSet, g.setId, g.setMax = hasSet, setId or 0, maxEquipped
        end
        if g.quality == nil then  -- peer: derive rarity from the rebuilt link
            g.quality = IV.safeCall(GetItemLinkFunctionalQuality, g.itemLink)
                        or ITEM_FUNCTIONAL_QUALITY_NORMAL
        end
    end
    return g.itemLink
end

-- Per-bar set-piece tally of `setId` across the shown target's gear. Both weapon bars are
-- transmitted, and ESO only counts the ACTIVE bar's weapons toward a set, so we return the
-- pieces separately: armor + jewelry (active on both bars), front weapons, back weapons. A
-- two-handed weapon counts as 2, matching how the game tallies set bonuses. Callers form the
-- per-bar totals as (aj + front) and (aj + back).
local function setPieceCounts(setId)
    local aj, front, back = 0, 0, 0
    local gear = currentLoadout and currentLoadout.gear
    if setId and setId ~= 0 and gear then
        for _, g in pairs(gear) do
            ensureGearLink(g)   -- populates g.setId (and g.itemLink) for peer entries
            if g.setId == setId then
                local pieces = (g.itemLink and IV.safeCall(GetItemLinkEquipType, g.itemLink) == EQUIP_TYPE_TWO_HAND) and 2 or 1
                local s = g.slot
                if s == EQUIP_SLOT_MAIN_HAND or s == EQUIP_SLOT_OFF_HAND then
                    front = front + pieces
                elseif s == EQUIP_SLOT_BACKUP_MAIN or s == EQUIP_SLOT_BACKUP_OFF then
                    back = back + pieces
                else
                    aj = aj + pieces
                end
            end
        end
    end
    return aj, front, back
end

--------------------------------------------------------------------------------
-- Tooltip dispatchers
--------------------------------------------------------------------------------
function Window.OnGearEnter(i)
    if gearShowCosmetics then return Window.OnCosmeticEnter(i) end   -- same pool, different tooltip
    local data = gearData[i]
    if not data then return end
    -- Anchor off the VALUE label (the set-name box), not the slot-name box -- its LEFT edge sits at the
    -- END of the set-name space, so the tooltip (anchored to its RIGHT) never covers the item's name.
    local anchor = gearValue[i] or gearLabel[i]
    local link = ensureGearLink(data)
    if link and link ~= "" then
        InitializeTooltip(ItemTooltip, anchor, LEFT, 6, 0)
        pcall(function() ItemTooltip:SetLink(link) end)
        -- The rebuilt peer link carries no trait, so append it.
        if currentSource ~= "self" then
            local traitName = resolveTraitName(data.trait)
            if traitName then ItemTooltip:AddLine(traitName) end
        end
        -- ESO renders the set-bonus block inside SetLink from the VIEWER's equipped gear (self:
        -- only the active bar; a peer: 0 of their sets), C-side with no Lua hook -- so that block
        -- can't reflect the target's real loadout. Append the target's true per-bar set counts so
        -- they're always visible. Only the active bar's weapons count toward a set, so the front
        -- total is (armor/jewelry + front weapons) and the back total is (armor/jewelry + back).
        if data.setId and data.setId ~= 0 then
            local aj, front, back = setPieceCounts(data.setId)
            local _, _, _, _, maxEq = GetItemLinkSetInfo(link, false)
            maxEq = maxEq or 0
            local fCount, bCount = aj + front, aj + back
            if maxEq > 0 then   -- ESO caps active bonuses at maxEq, so never show N > M
                fCount, bCount = math.min(fCount, maxEq), math.min(bCount, maxEq)
            end
            local setName = resolveSetName(data.setId) or IV.L.SET_PIECES
            local text
            if fCount == bCount then
                text = string.format("%s: %d/%d", setName, fCount, maxEq)
            else
                text = string.format("%s: %s %d/%d \194\183 %s %d/%d",
                    setName, IV.L.STAT_BAR_FRONT, fCount, maxEq, IV.L.STAT_BAR_BACK, bCount, maxEq)
            end
            ItemTooltip:AddLine(" ")   -- spacer so our line doesn't crowd the set bonuses
            ItemTooltip:AddLine("|cFFD700" .. text .. "|r", "ZoFontWinH4")
        end
    else
        InitializeTooltip(InformationTooltip, anchor, LEFT, 6, 0)
        local setName = resolveSetName(data.setId)
        if setName then InformationTooltip:AddLine(setName, "ZoFontWinH4") end
        local traitName = resolveTraitName(data.trait)
        if traitName then InformationTooltip:AddLine(traitName) end
    end
end

function Window.OnGearExit()
    ClearTooltip(ItemTooltip)
    ClearTooltip(InformationTooltip)
end

-- Poison hover: the full item tooltip, anchored on the poison icon. Poisons aren't set gear
-- (no set/trait line to append), so this is just SetLink.
function Window.OnPoisonEnter(idx)
    local g = poisonData[idx]
    if not g then return end
    local link = ensureGearLink(g)
    if link and link ~= "" then
        InitializeTooltip(ItemTooltip, poisonCtrl[idx], LEFT, 6, 0)
        pcall(function() ItemTooltip:SetLink(link) end)
    end
end

function Window.OnPoisonExit()
    ClearTooltip(ItemTooltip)
end

-- A small [colour chip][dye name] caption shown just BELOW the achievement tooltip (which carries no
-- dye colour/name itself). It's a CHILD of the tooltip -- so it draws at the tooltip's high layer and
-- is actually visible (a GuiRoot-parented panel renders BEHIND the inspect window and vanishes) -- but
-- flagged SetExcludeFromResizeToFitExtents so the tooltip does NOT count it in its own size. That's the
-- key: a normal child anchored to the auto-sizing tooltip's bottom cycles (tooltip size <-> child pos);
-- excluding it from the size breaks that loop, so we can live-anchor to BOTTOMLEFT (no GetHeight guess).
-- Embedding a control INTO the tooltip's line flow isn't possible -- SetAchievement builds a custom
-- centred layout and AddControl doesn't fold an external control in (it flew to the screen corner).
-- The chip is a filled CT_BACKDROP (the only reliable solid fill: ESO's swatches are fileless textures
-- + SetColor, and the font has no filled square glyph) with a grey border so dark dyes read. Fixed
-- dimensions (resize-to-fit collapsed to 0); dye names fit, ellipsized if long.
local dyeCaption
local function ensureDyeCaption(achTip)
    if dyeCaption then return dyeCaption end
    local root = WM:CreateControl(nil, achTip, CT_CONTROL)
    if root.SetExcludeFromResizeToFitExtents then root:SetExcludeFromResizeToFitExtents(true) end
    root:SetHidden(true)
    root:SetHeight(28)   -- width comes from anchoring to both tooltip bottom corners at show time
    -- No explicit SetDrawLayer/Tier: inherit the tooltip's (very high) draw context, so we're IN FRONT
    -- of the inspect window. Forcing DL_OVERLAY dropped us into a lower stratum, behind it.
    -- Border + background: ESO's own tooltip backdrop template (UI-Border edge + UI-TooltipCenter +
    -- munge overlay) as a fill child -> pixel-identical to the tooltip, not approximated colours.
    WM:CreateControlFromVirtual("IV_DyeCaptionBg", root, "ZO_DefaultBackdrop")
    -- The name auto-sizes to its text and is CENTRED in the caption; the chip anchors to the name's
    -- LEFT edge so it sits right beside the (centred) name -- the layout engine resolves the name's
    -- width, so no stale GetTextWidth. (Label is created BEFORE the chip so the chip can anchor to it.)
    local label = WM:CreateControl(nil, root, CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetAnchor(CENTER, root, CENTER, 0, 0)
    label:SetMaxLineCount(1)
    local chip = WM:CreateControl(nil, root, CT_CONTROL)
    chip:SetDimensions(14, 14)
    chip:SetAnchor(RIGHT, label, LEFT, -6, 0)   -- right beside the name's left edge
    local border = WM:CreateControl(nil, chip, CT_BACKDROP)
    border:SetAnchor(TOPLEFT, chip, TOPLEFT, 0, 0)
    border:SetAnchor(BOTTOMRIGHT, chip, BOTTOMRIGHT, 0, 0)
    border:SetCenterColor(0.55, 0.55, 0.55, 0.9)
    local fill = WM:CreateControl(nil, chip, CT_BACKDROP)
    fill:SetAnchor(TOPLEFT, chip, TOPLEFT, 1, 1)
    fill:SetAnchor(BOTTOMRIGHT, chip, BOTTOMRIGHT, -1, -1)
    fill:SetCenterColor(0, 0, 0, 1)
    dyeCaption = { root = root, fill = fill, label = label }
    return dyeCaption
end

-- Dye-chip hover. If the dye is unlocked by an ACHIEVEMENT, show that achievement's rich tooltip
-- (its own progress / reward / description) -- more useful than the bare dye name -- with a small
-- [chip][name] caption attached just below it. Otherwise fall back to ESO's own dye-swatch tooltip
-- (localized name + "how you obtain it"), then a plain name. Chips sit at the window's right edge, so
-- tooltips anchor to the LEFT.
function Window.OnDyeEnter(k, c)
    local dyeId = dyeData[k] and dyeData[k][c]
    if not dyeId or dyeId == 0 then return end
    local cell = dyeSwatch[k] and dyeSwatch[k][c] and dyeSwatch[k][c].cell
    if not cell then return end
    if dyeCaption then dyeCaption.root:SetHidden(true) end   -- only the achievement path shows it
    local ok, name, known, _, _, achId = pcall(GetDyeInfoById, dyeId)
    if not ok or not name or name == "" then return end

    -- Achievement-unlocked dye -> that achievement's tooltip + a [chip][name] caption below it.
    local achTip = rawget(_G, "AchievementTooltip")
    if achId and achId ~= 0 and achTip and type(achTip.SetAchievement) == "function" then
        InitializeTooltip(achTip, cell, RIGHT, -6, 0, LEFT)
        if pcall(function() achTip:SetAchievement(achId) end) then
            local cap = ensureDyeCaption(achTip)
            local okc, _, _, _, _, _, r, g, b = pcall(GetDyeInfoById, dyeId)
            if okc and type(r) == "number" then cap.fill:SetCenterColor(r, g, b, 1) end
            cap.label:SetText(zo_strformat("<<1>>", name))
            cap.label:SetColor(1, 1, 1, 1)
            cap.root:ClearAnchors()
            -- Anchor BOTH bottom corners of the tooltip -> caption spans the tooltip's exact width.
            -- Excluded from the tooltip's extents, so this doesn't cycle. Child of tooltip -> draws high.
            cap.root:SetAnchor(TOPLEFT, achTip, BOTTOMLEFT, 8, 2)
            cap.root:SetAnchor(TOPRIGHT, achTip, BOTTOMRIGHT, -8, 2)
            cap.root:SetHidden(false)
            return
        end
        ClearTooltip(achTip)
    end

    -- Otherwise ESO's own dye-swatch tooltip (isRightAnchored=true -> to the LEFT), then a plain name.
    local native = rawget(_G, "ZO_Dyeing_CreateTooltipOnMouseEnter")
    if type(native) == "function" and pcall(native, cell, name, known, achId, false, true) then
        return
    end
    InitializeTooltip(InformationTooltip, cell, RIGHT, -6, 0, LEFT)
    InformationTooltip:AddLine(zo_strformat("<<1>>", name), "ZoFontWinH4")
end

function Window.OnDyeExit()
    ClearTooltip(InformationTooltip)
    local achTip = rawget(_G, "AchievementTooltip")
    if achTip then ClearTooltip(achTip) end
    if dyeCaption then dyeCaption.root:SetHidden(true) end
end

-- Cosmetics-view hover (OnGearEnter dispatches here in Cosmetics mode). A collectible gets its full
-- collectible tooltip (fallback to its link, then a plain name); a base motif gets a name line.
function Window.OnCosmeticEnter(i)
    local tip = cosmeticData[i]
    if not tip then return end
    local anchor = gearLabel[i]
    if tip.kind == "collectible" then
        InitializeTooltip(ItemTooltip, anchor, LEFT, 6, 0)
        local ok = pcall(function() ItemTooltip:SetCollectible(tip.id) end)
        if not ok then
            local link = IV.safeCall(GetCollectibleLink, tip.id, LINK_STYLE_DEFAULT)
            if link and link ~= "" then pcall(function() ItemTooltip:SetLink(link) end) end
        end
    elseif tip.kind == "item" then   -- base motif: no rich style tooltip exists, so show the styled item
        InitializeTooltip(ItemTooltip, anchor, LEFT, 6, 0)
        pcall(function() ItemTooltip:SetLink(tip.link) end)
    else   -- "style" fallback (no item link): just the style name
        local nm = IV.safeCall(GetItemStyleName, tip.id)
        if nm and nm ~= "" then
            InitializeTooltip(InformationTooltip, anchor, LEFT, 6, 0)
            InformationTooltip:AddLine(zo_strformat("<<1>>", nm), "ZoFontWinH4")
        end
    end
end

-- Right-click a hoverable ITEM/COLLECTIBLE to link it to chat (the standard link menu -- same as
-- right-clicking an item link in chat/inventory). `getLink` returns the chat link, or nil. ESO has no
-- chat link for abilities/skills/champion stars/buffs, so those rows stay hover-only.
local function linkToChatOnRightClick(control, getLink)
    if not control then return end
    control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
        local link = getLink()
        if link and link ~= "" and ZO_LinkHandler_OnLinkMouseUp then
            pcall(ZO_LinkHandler_OnLinkMouseUp, link, button, ctrl)
        end
    end)
end

-- Insert PLAIN TEXT into chat (for things with no chat link -- e.g. champion stars). Into the active
-- chat entry if open, else opens the chat input with it. Both calls guarded (pcall) -- no C-side risk.
local function insertTextToChat(text)
    if not text or text == "" then return end
    if ZO_LinkHandler_InsertLink and ZO_LinkHandler_InsertLink(text) then return end
    if StartChatInput then pcall(StartChatInput, text) end
end

-- Right-click a control with NO chat link to get a "Link to Chat" menu that inserts `getText()` as
-- plain text. Used for champion stars, which ESO can't chat-link.
local function nameToChatOnRightClick(control, getText)
    if not control then return end
    control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
        local text = getText()
        if not text or text == "" then return end
        ClearMenu()
        AddMenuItem(IV.L.LINK_TO_CHAT, function() insertTextToChat(text) end)
        ShowMenu(ctrl)
    end)
end

-- Dye swatch right-click: one "Link to Chat" that sends "<dye name>: <achievement link>" -- the dye's
-- own name plus a real link to its unlocking achievement. Dyes with no achievement fall back to the
-- name + its hex value (colours have no chat link). Fields from GetDyeInfoById (name, known, rarity,
-- hueCat, achId, r, g, b).
function Window.OnDyeRightClick(k, c)
    local dyeId = dyeData[k] and dyeData[k][c]
    if not dyeId or dyeId == 0 then return end
    local cell = dyeSwatch[k] and dyeSwatch[k][c] and dyeSwatch[k][c].cell
    if not cell then return end
    local ok, name, _, _, _, achId, r, g, b = pcall(GetDyeInfoById, dyeId)
    if not ok or not name or name == "" then return end
    name = zo_strformat("<<1>>", name)

    ClearMenu()
    AddMenuItem(IV.L.LINK_TO_CHAT, function()
        local link = (achId and achId ~= 0) and IV.safeCall(GetAchievementLink, achId, LINK_STYLE_DEFAULT)
        local text
        if link and link ~= "" then
            text = string.format("%s: %s", name, link)          -- "<colour>: <achievement link>"
        elseif type(r) == "number" and type(g) == "number" and type(b) == "number" then
            text = string.format("%s (#%02X%02X%02X)", name,    -- no achievement -> name + hex
                math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
        else
            text = name
        end
        insertTextToChat(text)
    end)
    ShowMenu(cell)
end

-- Chat link for an ability id (skills, mundus, curse, class-mastery passives). Guarded -- returns nil
-- if unavailable, so the right-click just no-ops.
local function abilityLink(id)
    if not id or id == 0 then return nil end
    local link = IV.safeCall(GetAbilityLink, id, LINK_STYLE_DEFAULT)
    return (link and link ~= "") and link or nil
end

-- The chat link for gear cell `i`, honoring the current Equipment/Cosmetics mode (an equipped item, a
-- collectible cosmetic, or a base-motif styled item; a bare style name has no link).
local function gearCellLink(i)
    if gearShowCosmetics then
        local tip = cosmeticData[i]
        if not tip then return nil end
        if tip.kind == "collectible" then return IV.safeCall(GetCollectibleLink, tip.id, LINK_STYLE_DEFAULT) end
        if tip.kind == "item" then return tip.link end
        return nil
    end
    local data = gearData[i]
    return data and ensureGearLink(data) or nil
end

-- Gather the shown loadout's item sets (with per-bar counts, reusing setPieceCounts) and its
-- armor-weight breakdown, for the Equipment-header summary popup.
local function collectSetSummary()
    local gear = currentLoadout and currentLoadout.gear
    local rows, weight = {}, {}
    if not gear then return rows, weight end
    local maxBySet, order = {}, {}
    for _, g in pairs(gear) do
        ensureGearLink(g)                       -- rebuilds g.itemLink / g.setId for peer entries
        if g.setId and g.setId ~= 0 and maxBySet[g.setId] == nil and g.itemLink then
            -- Read maxEquipped from the link (g.setMax isn't set for self: readGearSlot drops it).
            local _, _, _, _, maxEq = GetItemLinkSetInfo(g.itemLink, false)
            maxBySet[g.setId] = maxEq or 0
            order[#order + 1] = g.setId
        end
    end
    for _, setId in ipairs(order) do
        local aj, front, back = setPieceCounts(setId)
        local maxEq = maxBySet[setId] or 0
        local fCount, bCount = aj + front, aj + back
        if maxEq > 0 then fCount, bCount = math.min(fCount, maxEq), math.min(bCount, maxEq) end
        rows[#rows + 1] = { name = resolveSetName(setId) or ("Set #" .. setId),
                            front = fCount, back = bCount, max = maxEq }
    end
    for _, slot in ipairs(GEAR_ARMOR) do
        local g = gear[slot]
        if g then
            ensureGearLink(g)
            local at = g.itemLink and IV.safeCall(GetItemLinkArmorType, g.itemLink)
            if at and ARMOR_WEIGHT_NAME[at] then weight[at] = (weight[at] or 0) + 1 end
        end
    end
    return rows, weight
end

local function armorSummaryString(weight)
    local parts = {}
    for _, at in ipairs(ARMOR_WEIGHT_ORDER) do
        local n = weight[at]
        if n and n > 0 then parts[#parts + 1] = n .. " " .. ARMOR_WEIGHT_NAME[at] end
    end
    if #parts == 0 then return nil end
    return IV.L.ARMOR_LABEL .. ":  " .. table.concat(parts, " \194\183 ")
end

-- Populate + show the set-summary popup on hovering the Equipment header (Equipment mode only --
-- sets don't apply to the Cosmetics view).
function Window.OnGearHeaderEnter()
    if not setPanel or gearShowCosmetics then return end
    local rows, weight = collectSetSummary()
    local armorStr = armorSummaryString(weight)
    if #rows == 0 and not armorStr then return end
    local nrows = math.min(#rows, #setRowName)
    for i = 1, #setRowName do
        local r, show = rows[i], (i <= nrows)
        setRowName[i]:SetHidden(not show)
        setRowFront[i]:SetHidden(not show)
        setRowBack[i]:SetHidden(not show)
        if show then
            setRowName[i]:SetText(r.name)
            local function put(lbl, n, m)
                lbl:SetText(string.format("%d/%d", n, m))
                if m > 0 and n >= m then lbl:SetColor(0.35, 0.85, 0.40, 1)   -- complete = green
                else lbl:SetColor(0.68, 0.68, 0.68, 1) end                    -- partial = grey
            end
            put(setRowFront[i], r.front, r.max)
            put(setRowBack[i], r.back, r.max)
        end
    end
    local hasSets = nrows > 0
    setColF:SetHidden(not hasSets)
    setColB:SetHidden(not hasSets)
    local armorY = SET_ROW0_Y + nrows * SET_ROW_H + (hasSets and 6 or 0)
    if armorStr then
        setPanelArmor:ClearAnchors()
        setPanelArmor:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_PAD, armorY)
        setPanelArmor:SetText(armorStr)
        setPanelArmor:SetHidden(false)
    else
        setPanelArmor:SetHidden(true)
    end
    setPanel:SetHeight(armorY + (armorStr and SET_ROW_H or 0) + SET_PAD)
    setPanel:SetHidden(false)
end

function Window.OnGearHeaderExit()
    if setPanel then setPanel:SetHidden(true) end
end

local function tipAnchor(tt, control, point, ox, oy, relPoint)
    ClearTooltip(tt)
    InitializeTooltip(tt, control, point or TOP, ox or 0, oy or 4, relPoint)
end

-- Anchor a tooltip's RIGHT edge to the LEFT of `header` (opens to the left of the row's section header,
-- clear of the row content it describes). 6px gap.
local function tipLeftOfHeader(tt, header)
    tipAnchor(tt, header, RIGHT, -6, 0, LEFT)
end

local function hideAllTooltips()
    ClearTooltip(GameTooltip)
    ClearTooltip(InformationTooltip)
    if _G.ChampionSkillTooltip then ClearTooltip(ChampionSkillTooltip) end
end

local ROMAN = { "I", "II", "III", "IV" }

-- Ability tooltip for a skill: the game's own ability tooltip (GameTooltip:SetAbilityId), with a
-- plain name/description fallback. (The target's core stats live in the Stats section.) The rank
-- numeral SetAbilityId shows is the VIEWER's, and rank isn't recoverable from the ability id, so
-- for a peer we append the TARGET's rank -- transmitted as skills.ranks[id] (Loadout.abilityRank)
-- -- styled like the gear set line.
local function showAbilityTooltip(control, id, point, ox, oy, relPoint)
    if not id or id == 0 then return end
    tipAnchor(GameTooltip, control, point, ox, oy, relPoint)
    if pcall(function() GameTooltip:SetAbilityId(id) end) then
        if currentSource ~= "self" then
            local ranks = currentLoadout and currentLoadout.skills and currentLoadout.skills.ranks
            local rank  = ranks and ranks[id]
            if rank then
                -- Separate pcalls so a missing AddVerticalPadding never drops the line itself.
                -- A TRAILING AddVerticalPadding is trimmed by the tooltip (it's the last element),
                -- so the after-gap is an actual blank line (small font) -- the only thing that renders.
                pcall(function() GameTooltip:AddVerticalPadding(12) end)
                pcall(function()
                    GameTooltip:AddLine("|cFFD700" .. IV.L.SKILL_TARGET_LEVEL .. " " .. (ROMAN[rank] or rank) .. "|r", "ZoFontWinH4")
                end)
                pcall(function() GameTooltip:AddLine(" ", "ZoFontGameSmall") end)
            end
        end
        return
    end
    tipAnchor(InformationTooltip, control, point, ox, oy)
    local name = resolveAbilityName(id)
    if name then InformationTooltip:AddLine(name, "ZoFontWinH4") end
    local desc = IV.safeCall(GetAbilityDescription, id)
    if desc and desc ~= "" then InformationTooltip:AddLine(zo_strformat("<<1>>", desc)) end
end

function Window.OnSkillEnter(control)
    -- Anchor the tooltip's LEFT to the icon's RIGHT, so it opens to the right of the skill pic.
    showAbilityTooltip(control, skillData[control], LEFT, 6, 0, RIGHT)
end
Window.OnSkillExit = hideAllTooltips

-- Resolve a class skill line's name from its (transmitted) id, on the viewer's client.
local function classLineName(skillLineId)
    local sdm = rawget(_G, "SKILLS_DATA_MANAGER")
    if type(sdm) == "table" and type(sdm.GetSkillLineDataById) == "function" then
        local ok, data = pcall(sdm.GetSkillLineDataById, sdm, skillLineId)
        if ok and type(data) == "table" and type(data.GetName) == "function" then
            local ok2, nm = pcall(data.GetName, data)
            if ok2 and nm and nm ~= "" then return zo_strformat("<<1>>", nm) end
        end
    end
    return nil
end

-- Class / Subclass section (right column). Pure -> the equipped Class Mastery passives (icon + name,
-- hover = ability tooltip). Subclassing -> the 3 chosen class skill lines ("<Class>: <line>", class
-- icon if available). Everything resolves from transmitted ids, so a peer renders it too.
local function populateClass(loadout)
    for i = 1, CLASS_POOL_N do
        classCtrl[i]:SetHidden(true)
        classData[i] = nil
    end
    local ci = loadout.class
    local hasLines   = ci and ci.lines and #ci.lines > 0
    local hasMastery = ci and ci.mastery and #ci.mastery > 0
    if not ci or (ci.pure and not hasMastery) or (not ci.pure and not hasLines) then
        classHeader:SetHidden(true)
        return
    end
    classHeader:SetHidden(false)

    if ci.pure then
        classHeader:SetText(IV.L.LABEL_CLASS_MASTERY)
        for i, aid in ipairs(ci.mastery) do
            local ctrl, icon, label, value = classCtrl[i], classIcon[i], classLabel[i], classValue[i]
            if not ctrl then break end
            icon:SetTexture(IV.safeCall(GetAbilityIcon, aid) or "")
            icon:SetColor(1, 1, 1, 1)
            icon:SetHidden(false)
            local nm = IV.safeCall(GetAbilityName, aid)
            label:SetWidth(RIGHT_COL_W - 34)   -- full width; no value column in pure mode
            label:SetText(zo_strformat("<<1>>", (nm and nm ~= "") and nm or "?"))
            value:SetHidden(true)
            classData[i] = aid   -- hoverable -> ability tooltip
            ctrl:SetHidden(false)
        end
    else
        classHeader:SetText(IV.L.LABEL_SUBCLASS)
        local gender = IV.safeCall(GetUnitGender, "player") or 0

        -- Pre-pass: resolve the class names and MEASURE the widest (in the row's own font, via the
        -- label's GetStringWidth -- non-destructive, no stale-SetText width issue), so the name box
        -- fits the ACTUAL 3 names snugly. 3 short names don't leave a big gap. Falls back to the fixed
        -- CLASS_NAME_W if the measurement isn't available.
        local names, widest = {}, 0
        for i, l in ipairs(ci.lines) do
            local cn = IV.safeCall(GetClassName, gender, l.cl)
            names[i] = (cn and cn ~= "") and zo_strformat("<<1>>", cn) or nil
            local lbl = classLabel[i]
            if names[i] and lbl then
                local w = IV.safeCall(function() return lbl:GetStringWidth(names[i]) end)
                if type(w) == "number" and w > widest then widest = w end
            end
        end
        -- +14 gap; clamped so a bad measurement can't starve the skill-line column (keeps >= ~140px).
        local boxW = (widest > 0) and math.min(math.ceil(widest) + 14, RIGHT_COL_W - 34 - 140) or CLASS_NAME_W

        for i, l in ipairs(ci.lines) do
            local ctrl, icon, label, value = classCtrl[i], classIcon[i], classLabel[i], classValue[i]
            if not ctrl then break end
            local cicon = IV.safeCall(GetClassIcon, l.cl)
            if cicon and cicon ~= "" then icon:SetTexture(cicon); icon:SetColor(1, 1, 1, 1); icon:SetHidden(false)
            else icon:SetHidden(true) end
            local lineNm = classLineName(l.sl) or "?"
            if names[i] then
                -- Class name in the measured box, skill line in the value column -> the lines align.
                label:SetWidth(boxW)
                label:SetText(string.format("|cC5C29E%s|r", names[i]))
                value:ClearAnchors()
                value:SetAnchor(LEFT, label, LEFT, boxW, 0)
                value:SetWidth(RIGHT_COL_W - 34 - boxW)
                value:SetText(lineNm)
                value:SetHidden(false)
            else
                label:SetWidth(RIGHT_COL_W - 34)   -- no class name -> the line name fills the label
                label:SetText(lineNm)
                value:SetHidden(true)
            end
            ctrl:SetHidden(false)   -- classData stays nil: no ability tooltip for a skill line
        end
    end
end

function Window.OnClassEntryEnter(i)
    local aid = classData[i]
    if aid then showAbilityTooltip(classHeader, aid, RIGHT, -6, 0, LEFT) end
end
Window.OnClassEntryExit = hideAllTooltips

-- Mundus boons and food/drink scale their magnitude at runtime, so only the LIVE
-- active-effect tooltip carries the real numbers (matching the Character sheet's
-- Active Effects). Find the active buff by ability id and lay out its live tooltip.
-- SetBuff takes the buff's *slot* (GetUnitBuffInfo's 4th return) -- NOT the loop
-- index; passing the index selects the wrong effect. Falls back to the generic
-- ability tooltip if the buff isn't on us (e.g. inspecting a peer).
local function showLiveBuffTooltip(anchor, id, point, ox, oy, relPoint)
    if not id or id == 0 then return end
    for i = 1, (GetNumBuffs("player") or 0) do
        local _, _, _, buffSlot, _, _, _, _, _, _, bid = GetUnitBuffInfo("player", i)
        if bid == id and buffSlot then
            tipAnchor(GameTooltip, anchor, point, ox, oy, relPoint)
            if pcall(function() GameTooltip:SetBuff(buffSlot, "player") end) then return end
            ClearTooltip(GameTooltip)
            break
        end
    end
    showAbilityTooltip(anchor, id, point, ox, oy, relPoint)
end

function Window.OnMundusEnter()
    if mundusData then showLiveBuffTooltip(mundusHeader, mundusData, RIGHT, -6, 0, LEFT) end
end
Window.OnMundusExit = hideAllTooltips

-- Food row: prefer the real food-ITEM tooltip (rich effects) when we resolved the item (self: matched
-- in the backpack by the buff's icon); else fall back to the live buff tooltip (runtime-scaled numbers).
function Window.OnFoodEnter()
    if foodItemLink and foodItemLink ~= "" then
        tipLeftOfHeader(ItemTooltip, foodHeader)
        pcall(function() ItemTooltip:SetLink(foodItemLink) end)
    elseif foodData then
        showLiveBuffTooltip(foodHeader, foodData, RIGHT, -6, 0, LEFT)
    end
end
Window.OnFoodExit = function() ClearTooltip(ItemTooltip); hideAllTooltips() end

-- Potion row: the real item tooltip (SetLink). potionData is the display link (self = the worn link;
-- peer = reconstructed incl. the crafted-data fields, so effects show). A potion isn't set gear, so
-- no appended line.
function Window.OnPotionEnter()
    if not potionData or potionData == "" then return end
    tipLeftOfHeader(ItemTooltip, potionHeader)
    pcall(function() ItemTooltip:SetLink(potionData) end)
end
Window.OnPotionExit = function() ClearTooltip(ItemTooltip) end

-- Curse row: vampires carry a live stage buff (real numbers). Werewolves in human
-- form have no persistent buff, so curseData is nil and the hover is inert.
function Window.OnCurseEnter()
    if curseData then showLiveBuffTooltip(curseHeader, curseData, RIGHT, -6, 0, LEFT) end
end
Window.OnCurseExit = hideAllTooltips

-- CP star tooltip -- ESO's own champion-skill tooltip (full description), falling back
-- to name + discipline text.
function Window.OnCPEnter(i)
    local id = cpStarData[i]
    local control = cpStar[i]
    if not id or not control then return end
    if _G.ChampionSkillTooltip and _G.CHAMPION_DATA_MANAGER then
        local ok = pcall(function()
            local data = CHAMPION_DATA_MANAGER:GetChampionSkillData(id)
            -- Use the shown TARGET's invested points (transmitted per star) so the tooltip
            -- shows THEIR numbers, not the viewer's. Falls back to the viewer's points when
            -- unknown (self, or a legacy peer that didn't send points).
            local points = cpStarPoints[i]
            if type(points) ~= "number" then
                points = (GetNumPointsSpentOnChampionSkill and GetNumPointsSpentOnChampionSkill(id)) or 0
            end
            local nextJump = (data and data.GetNextJumpPoint) and data:GetNextJumpPoint(points) or nil
            tipLeftOfHeader(ChampionSkillTooltip, cpHeaderLabel)
            ChampionSkillTooltip:SetChampionSkill(id, points, nextJump, true)
        end)
        if ok then return end
        ClearTooltip(ChampionSkillTooltip)
    end
    tipLeftOfHeader(InformationTooltip, cpHeaderLabel)
    local nm, hex = resolveCPStar(id)
    if nm then InformationTooltip:AddLine(nm, "ZoFontWinH4") end
    if _G.CHAMPION_DATA_MANAGER then
        local disc = IV.safeCall(function()
            return CHAMPION_DATA_MANAGER:GetChampionSkillData(id):GetChampionDisciplineData():GetName()
        end)
        if disc and disc ~= "" then InformationTooltip:AddLine(zo_strformat("<<1>>", disc)) end
    end
end
Window.OnCPExit = hideAllTooltips

--------------------------------------------------------------------------------
-- Build the static interior once
--------------------------------------------------------------------------------
-- x0 (column left, default 0) lets a control live in the LEFT (0) or RIGHT (RIGHT_COL_X) body column.
local function makeHeader(text, y, x0)
    local h = WM:CreateControl(nil, content, CT_LABEL)
    h:SetFont("ZoFontWinH4")
    h:SetColor(0.77, 0.76, 0.62, 1)
    h:SetText(text)
    h:SetAnchor(TOPLEFT, content, TOPLEFT, x0 or 0, y)
    return h
end

local function makeValue(y, x0, w)
    local l = WM:CreateControl(nil, content, CT_LABEL)
    l:SetFont("ZoFontGame")
    l:SetColor(0.9, 0.9, 0.9, 1)
    l:SetAnchor(TOPLEFT, content, TOPLEFT, x0 or 0, y)
    l:SetWidth(w or LEFT_COL_W)
    return l
end

-- Column-width, centre-aligned value label (for the Attributes / Stats rows, whose values
-- are spread across the row centred on it).
local function makeCenteredValue(y, x0, w)
    local l = makeValue(y, x0, w)
    l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    return l
end

-- Right-column "Header  value" row: a BOLD gold header (same font as the section headers) with a
-- normal-weight value to its right, both on one line. Returns header, value. Both are mouse-enabled
-- and share the hover handlers so hovering anywhere on the row works.
local function makeLabeledRow(y, headerText, onEnter, onExit)
    local h = makeHeader(headerText, y, RIGHT_COL_X)
    local v = WM:CreateControl(nil, content, CT_LABEL)
    v:SetFont("ZoFontGame")
    v:SetColor(0.9, 0.9, 0.9, 1)
    -- Fixed x-offset from the header's LEFT (not its RIGHT), so every row's value starts at the same
    -- spot regardless of header width; LEFT anchor also keeps it vertically centred on the bold header.
    v:SetAnchor(LEFT, h, LEFT, LABELED_VALUE_X, 0)
    for _, c in ipairs({ h, v }) do
        c:SetMouseEnabled(true)
        c:SetHandler("OnMouseEnter", onEnter)
        c:SetHandler("OnMouseExit", onExit)
    end
    return h, v
end

-- X position for skill icon i in the centred bar (icon 6 = ultimate gets extra spacing).
local function skillIconX(i)
    local x = SKILL_START_X + (i - 1) * SKILL_GAP
    if i == 6 then x = x + ULT_GAP end
    return x
end

-- Skill slot = a mouse-enabled container (which reliably fires hover, unlike a bare
-- texture) with the ability icon as a non-mouse child. Returns the icon texture; the
-- hover handler is on the container but reports the icon (the skillData key).
local function makeSkillIcon(i, y)
    local btn = WM:CreateControl(nil, content, CT_CONTROL)
    btn:SetDimensions(SKILL_SIZE, SKILL_SIZE)
    btn:SetAnchor(TOPLEFT, content, TOPLEFT, skillIconX(i), y)
    btn:SetMouseEnabled(true)

    local icon = WM:CreateControl(nil, btn, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, btn, TOPLEFT, 0, 0)
    icon:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, 0, 0)
    icon:SetMouseEnabled(false)

    btn:SetHandler("OnMouseEnter", function() Window.OnSkillEnter(icon) end)
    btn:SetHandler("OnMouseExit", Window.OnSkillExit)
    linkToChatOnRightClick(btn, function() return abilityLink(skillData[icon]) end)
    return icon
end

local function buildQualityTable()
    local function put(const, hex) if const ~= nil then QUALITY_HEX[const] = hex end end
    put(ITEM_FUNCTIONAL_QUALITY_TRASH,     "9d9d9d")
    put(ITEM_FUNCTIONAL_QUALITY_NORMAL,    "ffffff")
    put(ITEM_FUNCTIONAL_QUALITY_MAGIC,     "2dc50e")
    put(ITEM_FUNCTIONAL_QUALITY_ARCANE,    "3a92ff")
    put(ITEM_FUNCTIONAL_QUALITY_ARTIFACT,  "a02ef7")
    put(ITEM_FUNCTIONAL_QUALITY_LEGENDARY, "ceac21")
end

local function buildCPColorTable()
    local function put(const, hex) if const ~= nil then CP_DISCIPLINE_HEX[const] = hex end end
    put(CHAMPION_DISCIPLINE_TYPE_COMBAT,       "4d9fff")  -- Warfare (blue)
    put(CHAMPION_DISCIPLINE_TYPE_CONDITIONING, "ff5555")  -- Fitness (red)
    put(CHAMPION_DISCIPLINE_TYPE_WORLD,        "55dd55")  -- Craft (green)
end

-- Per-bar stats, shown BESIDE the corresponding skill bar (front stats align with the Front bar row,
-- back stats with the Back bar row) -- no toggle, both bars at once. Each block is 3 lines: resources /
-- dmg+pen / crit. An all-zero bar (healthMax 0 -- captured before stats were ready, or an older peer's
-- empty transmit) shows the "swap once to capture this bar" hint instead of a wall of zeros.
local function fillStatBlock(block, sel, haveStats)
    block.header:SetHidden(not haveStats)   -- hide "Front/Back bar stats" when this loadout has no stats at all
    if sel and (sel.healthMax or 0) > 0 then
        block[1]:SetText(string.format(
            "|c%s%s %s|r  \226\128\162  |c%s%s %s|r  \226\128\162  |c%s%s %s|r",
            COLOR_MAG,  IV.L.STAT_MAX_MAG,  ZO_CommaDelimitNumber(sel.magMax or 0),
            COLOR_HP,   IV.L.STAT_MAX_HP,   ZO_CommaDelimitNumber(sel.healthMax or 0),
            COLOR_STAM, IV.L.STAT_MAX_STAM, ZO_CommaDelimitNumber(sel.stamMax or 0)))
        block[2]:SetText(string.format(
            "|c%s%s %s|r  \226\128\162  |c%s%s %s|r",
            COLOR_STAT, IV.L.STAT_DMG, ZO_CommaDelimitNumber(sel.dmg or 0),
            COLOR_STAT, IV.L.STAT_PEN, ZO_CommaDelimitNumber(sel.pen or 0)))
        local parts = { string.format("|c%s%s %s|r", COLOR_STAT, IV.L.STAT_CRIT, critPct(sel.crit)) }
        if sel.critDmg and sel.critDmg > 0 then
            parts[#parts + 1] = string.format("|c%s%s %d%%|r", COLOR_STAT, IV.L.STAT_CRIT_DMG, sel.critDmg)
        end
        block[3]:SetText(table.concat(parts, "  \226\128\162  "))
    elseif haveStats then
        local hint = (currentSource == "self") and IV.L.STAT_BAR_HINT_SELF or IV.L.STAT_BAR_HINT_PEER
        block[1]:SetText("|c999999" .. hint .. "|r"); block[2]:SetText(""); block[3]:SetText("")
    else
        block[1]:SetText(""); block[2]:SetText(""); block[3]:SetText("")
    end
end

local function renderStats()
    local st = currentLoadout and currentLoadout.stats
    fillStatBlock(frontStats, st and st.front, st ~= nil)
    fillStatBlock(backStats,  st and st.back,  st ~= nil)
end

-- Live-refresh: when a weapon swap captures a bar's stats (Loadout fires this), re-read our
-- own stats into the OPEN self-inspect so the newly-available bar fills in without reopening.
function Window.OnBarsCaptured()
    if not win or win:IsHidden() then return end
    if currentSource ~= "self" or not currentLoadout then return end
    if IV.GetOwnStats then currentLoadout.stats = IV.GetOwnStats() end
    renderStats()
end

-- True if the window is open and showing this @account -- lets Comms live-refresh the open
-- window when an unsolicited peer update for that player arrives.
function Window.IsShowingAccount(atAccount)
    if not atAccount or atAccount == "" then return false end
    if not win or win:IsHidden() then return false end
    local m = currentLoadout and currentLoadout.meta
    return (m and m.atAccount == atAccount) or false
end

-- The loadout currently on screen (or nil) -- lets Comms fold a late-arriving cosmetics payload
-- into the open card and re-render without rebuilding the whole loadout.
function Window.GetShown()
    if not win or win:IsHidden() then return nil end
    return currentLoadout
end

function Window.Init()
    if built then return end
    win           = InspectVestigeWindow
    if not win then return end
    -- Register with the scene manager so ESC hides the window instead of opening the
    -- game menu (and it enters cursor/UI mode while shown). Show/hide route through
    -- showWindow()/hideWindow() below.
    if SCENE_MANAGER and SCENE_MANAGER.RegisterTopLevel then
        SCENE_MANAGER:RegisterTopLevel(win, false)
    end
    -- "." (ESO's default Toggle Cursor bind) EXITS UI mode, and the scene manager hides EVERY shown
    -- top-level as part of that (SetInUIMode(false) -> HideTopLevels) -- so "." closed the inspect
    -- window. We can't just exempt the window from HideTopLevel globally: ESC-to-close runs through
    -- the SAME sweep (OnToggleGameMenuBinding -> HideTopLevels), and that must keep working. So flag
    -- ONLY the cursor-toggle flow (OnToggleHUDUIBinding) and skip OUR window inside it: "." now
    -- toggles the cursor as normal and the window stays put -- a build reference you can play
    -- against ("." again to get the cursor back and interact). ESC / the X still close it.
    -- Internal-method wraps, so both are existence-checked: if a ZOS rename breaks them, "." simply
    -- reverts to closing the window (no error).
    if SCENE_MANAGER and type(SCENE_MANAGER.OnToggleHUDUIBinding) == "function"
       and type(SCENE_MANAGER.HideTopLevel) == "function" then
        local inCursorToggle = false
        local origToggle = SCENE_MANAGER.OnToggleHUDUIBinding
        SCENE_MANAGER.OnToggleHUDUIBinding = function(sm, ...)
            inCursorToggle = true
            local ok, err = pcall(origToggle, sm, ...)
            inCursorToggle = false   -- ALWAYS clear, even on error, or ESC-close would break forever
            if not ok then error(err) end
        end
        local origHideTL = SCENE_MANAGER.HideTopLevel
        SCENE_MANAGER.HideTopLevel = function(sm, topLevel, ...)
            if inCursorToggle and topLevel == win and not win:IsHidden() then return end
            return origHideTL(sm, topLevel, ...)
        end
    end
    content       = InspectVestigeWindowContent
    titleLabel    = InspectVestigeWindowTitle
    subtitleLabel = InspectVestigeWindowSubtitle
    statusLabel   = InspectVestigeWindowStatus
    buildQualityTable()
    buildCPColorTable()

    -- Small credit/version watermark in the top-left corner (muted, unobtrusive).
    local watermark = WM:CreateControl(nil, win, CT_LABEL)
    watermark:SetFont("ZoFontGameSmall")
    watermark:SetColor(0.6, 0.6, 0.6, 0.5)
    watermark:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 8)
    watermark:SetText(("Inspect Vestige by %s v%s"):format(IV.author or "LuckyRome13", IV.version or "1.0.0"))

    local y = TOP_PAD   -- whitespace above the Equipment section

    -- Equipment. A pool of cells; each is positioned per-loadout in populateGear
    -- (grouped: armor left, jewelry + weapons right). Labels anchor to their icon, so
    -- re-anchoring the icon moves the pair.
    -- Equipment header: a click-toggle between the Equipment and Cosmetics views (like the Back-bar /
    -- Werewolf header), and a hover for the set-summary popup in Equipment mode ("(i)" hint -- the
    -- circled-i glyph isn't in ESO's fonts and renders as a box).
    gearHeader = makeHeader(IV.L.LABEL_GEAR .. " |c8a8a8a(i)|r", y)
    gearHeader:SetMouseEnabled(true)
    gearHeader:SetHandler("OnMouseEnter", Window.OnGearHeaderEnter)
    gearHeader:SetHandler("OnMouseExit", Window.OnGearHeaderExit)
    gearHeader:SetHandler("OnMouseUp", function()
        if not currentLoadout then return end
        Window.OnGearHeaderExit()          -- drop the set-summary popup before switching views
        gearShowCosmetics = not gearShowCosmetics
        renderEquipment(currentLoadout)
    end)
    for i = 1, GEAR_POOL_N do
        local icon = WM:CreateControl(nil, content, CT_TEXTURE)
        icon:SetDimensions(18, 18)
        gearIcon[i] = icon

        local label = WM:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGameSmall")
        label:SetAnchor(LEFT, icon, RIGHT, 4, 0)
        label:SetWidth(COL_WIDTH - 26)
        -- A long gear/style name must NOT wrap to a second line (rows are fixed-height, so two lines
        -- crammed into the cell); ellipsize it instead. The full name is always in the hover tooltip.
        -- NB the wrap mode alone is NOT enough: it only ellipsizes once the text can't fit the label's
        -- BOX, and an unconstrained-height label just grows a second line -- so cap it to one line too.
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        if label.SetMaxLineCount then label:SetMaxLineCount(1) else label:SetHeight(18) end
        label:SetMouseEnabled(true)
        label:SetHandler("OnMouseEnter", function() Window.OnGearEnter(i) end)
        label:SetHandler("OnMouseExit", Window.OnGearExit)
        linkToChatOnRightClick(label, function() return gearCellLink(i) end)
        gearLabel[i] = label

        -- Equipment view only: the set-name value, in its own label anchored after the fixed-width
        -- slot-name box (so values line up per group). Hidden in the Cosmetics view (which keeps the
        -- combined gearLabel). Hover routes to the same cell tooltip.
        local value = WM:CreateControl(nil, content, CT_LABEL)
        value:SetFont("ZoFontGameSmall")
        value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        if value.SetMaxLineCount then value:SetMaxLineCount(1) else value:SetHeight(18) end
        value:SetMouseEnabled(true)
        value:SetHandler("OnMouseEnter", function() Window.OnGearEnter(i) end)
        value:SetHandler("OnMouseExit", Window.OnGearExit)
        linkToChatOnRightClick(value, function() return gearCellLink(i) end)
        value:SetHidden(true)
        gearValue[i] = value

        -- Up to 3 dye chips per Cosmetics row. A mouse-enabled CT_CONTROL (a bare backdrop/texture
        -- won't fire hover -- same gotcha as the poison/skill icons) wraps a CT_BACKDROP that fills a
        -- solid colour from SetCenterColor with NO texture path (the dye UI's swatch .dds is a hollow
        -- frame, not a fill), so there's nothing to mis-name; a thin dark edge sets each chip off.
        dyeSwatch[i], dyeData[i] = {}, {}
        for c = 1, 3 do
            local cell = WM:CreateControl(nil, content, CT_CONTROL)
            cell:SetDimensions(16, 16)
            cell:SetMouseEnabled(true)
            cell:SetHidden(true)
            -- Soft-grey outline = a grey backdrop filling the cell, with the colour fill inset 1px on
            -- top (a CT_BACKDROP's SetEdgeColor needs an edge TEXTURE to draw, so a solid under-layer is
            -- the reliable, texture-free way to get a border). Muted + semi-transparent so it frames the
            -- chip without competing with the colour.
            local border = WM:CreateControl(nil, cell, CT_BACKDROP)
            border:SetAnchor(TOPLEFT, cell, TOPLEFT, 0, 0)
            border:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, 0, 0)
            border:SetCenterColor(0.55, 0.55, 0.55, 0.7)   -- soft muted grey
            border:SetMouseEnabled(false)
            local bd = WM:CreateControl(nil, cell, CT_BACKDROP)   -- created after -> drawn on top
            bd:SetAnchor(TOPLEFT, cell, TOPLEFT, 1, 1)
            bd:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -1, -1)
            bd:SetCenterColor(0, 0, 0, 1)
            bd:SetMouseEnabled(false)
            local ii, cc = i, c
            cell:SetHandler("OnMouseEnter", function() Window.OnDyeEnter(ii, cc) end)
            cell:SetHandler("OnMouseExit", Window.OnDyeExit)
            cell:SetHandler("OnMouseUp", function(_, button, upInside)
                if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then Window.OnDyeRightClick(ii, cc) end
            end)
            dyeSwatch[i][c] = { cell = cell, bd = bd }
        end
    end

    -- Poison icons (front bar = 1, back bar = 2): a mouse-enabled container (a bare texture won't
    -- fire hover) with a non-mouse child texture. Positioned + shown per-loadout in populateGear.
    for i = 1, POISON_POOL_N do
        local btn = WM:CreateControl(nil, content, CT_CONTROL)
        btn:SetDimensions(POISON_SIZE, POISON_SIZE)
        btn:SetMouseEnabled(true)
        btn:SetHidden(true)
        local tex = WM:CreateControl(nil, btn, CT_TEXTURE)
        tex:SetAnchor(TOPLEFT, btn, TOPLEFT, 0, 0)
        tex:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, 0, 0)
        tex:SetMouseEnabled(false)
        local idx = i
        btn:SetHandler("OnMouseEnter", function() Window.OnPoisonEnter(idx) end)
        btn:SetHandler("OnMouseExit", Window.OnPoisonExit)
        linkToChatOnRightClick(btn, function() return poisonData[idx] and ensureGearLink(poisonData[idx]) or nil end)
        poisonCtrl[i], poisonTex[i] = btn, tex
    end

    -- Set-summary popup: floats below the Equipment header, drawn above the gear cells. Columns
    -- (name | front | back) sit at fixed x, so there's no stale-GetTextWidth problem (cf. CP row).
    do
        for _, w in ipairs({ { rawget(_G, "ARMORTYPE_LIGHT"), "Light" },
                             { rawget(_G, "ARMORTYPE_MEDIUM"), "Medium" },
                             { rawget(_G, "ARMORTYPE_HEAVY"), "Heavy" } }) do
            if w[1] then
                ARMOR_WEIGHT_NAME[w[1]] = w[2]
                ARMOR_WEIGHT_ORDER[#ARMOR_WEIGHT_ORDER + 1] = w[1]
            end
        end

        -- Child of `content` (same parent as the gear cells) + top draw tier/layer, so it renders
        -- ABOVE them -- otherwise the armor/jewelry/weapon rows draw on top of the popup.
        setPanel = WM:CreateControl(nil, content, CT_CONTROL)
        setPanel:SetHidden(true)
        setPanel:SetMouseEnabled(false)
        setPanel:SetDrawTier(DT_HIGH)
        setPanel:SetDrawLayer(DL_OVERLAY)
        setPanel:SetDrawLevel(5)
        setPanel:SetWidth(SET_PANEL_W)
        setPanel:SetAnchor(TOPLEFT, gearHeader, BOTTOMLEFT, 0, 6)
        -- Use the game's TOOLTIP backdrop textures (opaque dark centre + ornate border) so the gear
        -- behind doesn't bleed through -- ZO_DefaultBackdrop's centre texture is too transparent here.
        local sbg = WM:CreateControl(nil, setPanel, CT_BACKDROP)
        sbg:SetAnchor(TOPLEFT, setPanel, TOPLEFT, 0, 0)
        sbg:SetAnchor(BOTTOMRIGHT, setPanel, BOTTOMRIGHT, 0, 0)
        sbg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
        sbg:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
        sbg:SetInsets(16, 16, -16, -16)

        setPanelTitle = WM:CreateControl(nil, setPanel, CT_LABEL)
        setPanelTitle:SetFont("ZoFontWinH4")
        setPanelTitle:SetColor(0.77, 0.76, 0.62, 1)
        setPanelTitle:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_PAD, SET_PAD)
        setPanelTitle:SetText(IV.L.SETS_TITLE)

        setColF = WM:CreateControl(nil, setPanel, CT_LABEL)
        setColF:SetFont("ZoFontGameSmall"); setColF:SetColor(0.6, 0.6, 0.6, 1)
        setColF:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_FRONT_X, SET_HEADER_Y)
        setColF:SetText(IV.L.STAT_BAR_FRONT)
        setColB = WM:CreateControl(nil, setPanel, CT_LABEL)
        setColB:SetFont("ZoFontGameSmall"); setColB:SetColor(0.6, 0.6, 0.6, 1)
        setColB:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_BACK_X, SET_HEADER_Y)
        setColB:SetText(IV.L.STAT_BAR_BACK)

        for i = 1, 14 do
            local ry = SET_ROW0_Y + (i - 1) * SET_ROW_H
            local n = WM:CreateControl(nil, setPanel, CT_LABEL)
            n:SetFont("ZoFontGame"); n:SetColor(1, 1, 1, 1)
            n:SetDimensions(SET_NAME_W, SET_ROW_H)      -- fixed box so a long name truncates,
            n:SetMaxLineCount(1)                        -- doesn't wrap to a 2nd line and break rows
            n:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            n:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_PAD, ry)
            local f = WM:CreateControl(nil, setPanel, CT_LABEL)
            f:SetFont("ZoFontGame"); f:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_FRONT_X, ry)
            local b = WM:CreateControl(nil, setPanel, CT_LABEL)
            b:SetFont("ZoFontGame"); b:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_BACK_X, ry)
            setRowName[i], setRowFront[i], setRowBack[i] = n, f, b
        end

        setPanelArmor = WM:CreateControl(nil, setPanel, CT_LABEL)
        setPanelArmor:SetFont("ZoFontGame"); setPanelArmor:SetColor(0.85, 0.85, 0.85, 1)
        setPanelArmor:SetAnchor(TOPLEFT, setPanel, TOPLEFT, SET_PAD, SET_ROW0_Y)
    end

    -- ===== LEFT column (x 0, 500 wide): skill bars, then Champion Points, below the gear block. =====
    local yL = GEAR_BASE_Y + GEAR_BLOCK_H - 10

    -- Front bar (+ capture its Y so the front-bar stats align beside it in the right column).
    -- The trailing gap is a touch wider so the right-column stat block (header + 3 lines) beside
    -- this bar clears the Back bar header below.
    local yFront = yL
    frontHeader = makeHeader(IV.L.LABEL_FRONT_BAR, yL)
    yL = yL + 24
    for i = 1, 6 do
        frontIcon[i] = makeSkillIcon(i, yL)
    end
    yL = yL + SKILL_SIZE + 30

    -- Back bar. For a werewolf, the header doubles as a "Back bar / Werewolf" toggle that
    -- swaps this row to their transformation bar.
    local yBack = yL
    backHeader = makeHeader(IV.L.LABEL_BACK_BAR, yL)
    backHeader:SetMouseEnabled(true)
    backHeader:SetHandler("OnMouseUp", function()
        local skills = currentLoadout and currentLoadout.skills
        if skills and skills.werewolf then
            skillsShowWerewolf = not skillsShowWerewolf
            renderBackBar()
        end
    end)
    yL = yL + 24
    for i = 1, 6 do
        backIcon[i] = makeSkillIcon(i, yL)
    end
    yL = yL + SKILL_SIZE + 30

    -- ===== RIGHT column (x RIGHT_COL_X, RIGHT_COL_W wide) =====
    -- Mundus / Food / Potion / Curse / Attributes fill the top-right, beside the gear block (so the
    -- column isn't blank there). Each is a bold gold header + value; the rows are spaced generously.
    local RC_ROW_H = 32
    local yRTop = GEAR_BASE_Y
    mundusHeader, mundusLabel = makeLabeledRow(yRTop, IV.L.LABEL_MUNDUS, Window.OnMundusEnter, Window.OnMundusExit); yRTop = yRTop + RC_ROW_H
    foodHeader,   foodLabel   = makeLabeledRow(yRTop, IV.L.LABEL_FOOD,   Window.OnFoodEnter,   Window.OnFoodExit);   yRTop = yRTop + RC_ROW_H
    potionHeader, potionLabel = makeLabeledRow(yRTop, IV.L.LABEL_POTION, Window.OnPotionEnter, Window.OnPotionExit); yRTop = yRTop + RC_ROW_H
    curseHeader,  curseLabel  = makeLabeledRow(yRTop, IV.L.LABEL_CURSE,  Window.OnCurseEnter,  Window.OnCurseExit);  yRTop = yRTop + RC_ROW_H
    -- Right-click any of these rows to link to chat (both the header and value hover, so wire both):
    -- food/potion are ITEM links; mundus/curse are ABILITY links.
    for _, c in ipairs({ foodHeader, foodLabel })     do linkToChatOnRightClick(c, function() return foodItemLink end) end
    for _, c in ipairs({ potionHeader, potionLabel }) do linkToChatOnRightClick(c, function() return potionData end) end
    for _, c in ipairs({ mundusHeader, mundusLabel }) do linkToChatOnRightClick(c, function() return abilityLink(mundusData) end) end
    for _, c in ipairs({ curseHeader, curseLabel })   do linkToChatOnRightClick(c, function() return abilityLink(curseData) end) end

    -- Attributes: bold gold header (like the others) with a centre-spread values row.
    attrsTitle  = makeHeader(IV.L.LABEL_ATTRS, yRTop, RIGHT_COL_X)
    attrsLabel  = makeCenteredValue(yRTop, RIGHT_COL_X, RIGHT_COL_W)

    -- Per-bar STATS, aligned beside the skill bars: front stats level with the Front bar row, back
    -- stats level with the Back bar row -- both shown, no toggle. Each block is a header
    -- ("Front bar stats" / "Back bar stats", styled exactly like the "Front bar"/"Back bar" section
    -- headers -- bold, left-justified in the column) plus 3 centred lines (resources / dmg+pen / crit).
    -- The target's real scaling, since skill tooltips can't be rendered for another character.
    local function statBlock(y0, headerText)
        return { header = makeHeader(headerText, y0, RIGHT_COL_X),
                 makeCenteredValue(y0 + 26, RIGHT_COL_X, RIGHT_COL_W),
                 makeCenteredValue(y0 + 48, RIGHT_COL_X, RIGHT_COL_W),
                 makeCenteredValue(y0 + 70, RIGHT_COL_X, RIGHT_COL_W) }
    end
    frontStats = statBlock(yFront, IV.L.LABEL_FRONT_STATS)
    backStats  = statBlock(yBack,  IV.L.LABEL_BACK_STATS)

    -- Class / Subclass -- below the skill bars: a "Class Mastery" list of equipped passives (pure) or
    -- the 3 chosen class skill lines + their class (subclassing). Text set per-loadout in populateClass.
    local yR = yL
    classHeader = makeHeader("", yR, RIGHT_COL_X)
    yR = yR + 30   -- 8px gap below the header, matching the Champion Points header/row spacing
    for i = 1, CLASS_POOL_N do
        local ctrl = WM:CreateControl(nil, content, CT_CONTROL)
        ctrl:SetDimensions(RIGHT_COL_W, CLASS_ROW_H)
        ctrl:SetAnchor(TOPLEFT, content, TOPLEFT, RIGHT_COL_X, yR + (i - 1) * CLASS_ROW_H)
        ctrl:SetMouseEnabled(true)
        ctrl:SetHidden(true)
        local icon = WM:CreateControl(nil, ctrl, CT_TEXTURE)
        icon:SetDimensions(22, 22)
        icon:SetAnchor(LEFT, ctrl, LEFT, 2, 0)
        local label = WM:CreateControl(nil, ctrl, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetColor(0.9, 0.9, 0.9, 1)
        label:SetAnchor(LEFT, icon, RIGHT, 8, 0)
        label:SetWidth(RIGHT_COL_W - 34)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetMaxLineCount(1)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        -- Subclass mode only: the skill-line name, anchored after the fixed-width class-name box so
        -- the lines align. Hidden in pure (Class Mastery) mode, where the label holds the full name.
        local value = WM:CreateControl(nil, ctrl, CT_LABEL)
        value:SetFont("ZoFontGame")
        value:SetColor(0.9, 0.9, 0.9, 1)
        value:SetAnchor(LEFT, label, LEFT, CLASS_NAME_W, 0)
        value:SetWidth(RIGHT_COL_W - 34 - CLASS_NAME_W)
        value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        value:SetMaxLineCount(1)
        value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        value:SetHidden(true)
        local idx = i
        ctrl:SetHandler("OnMouseEnter", function() Window.OnClassEntryEnter(idx) end)
        ctrl:SetHandler("OnMouseExit", Window.OnClassEntryExit)
        linkToChatOnRightClick(ctrl, function() return abilityLink(classData[idx]) end)   -- mastery passives (not subclass lines)
        classCtrl[i], classIcon[i], classLabel[i], classValue[i] = ctrl, icon, label, value
    end

    -- Champion Points: LEFT column, below the skill bars (its comma-delimited star rows need the width).
    cpHeaderLabel = makeValue(yL)
    cpHeaderLabel:SetFont("ZoFontWinH4")   -- bold, matching the other section headers
    cpBaseY = yL + 30   -- 8px gap below the header (matches the Class section)
    for i = 1, 16 do
        local star = WM:CreateControl(nil, content, CT_LABEL)
        star:SetFont("ZoFontGame")
        star:SetMouseEnabled(true)
        star:SetHidden(true)
        local idx = i
        star:SetHandler("OnMouseEnter", function() Window.OnCPEnter(idx) end)
        star:SetHandler("OnMouseExit", Window.OnCPExit)
        -- CP stars can't be chat-linked, so right-click inserts the star's NAME as text instead.
        nameToChatOnRightClick(star, function() return resolveCPStar(cpStarData[idx]) end)
        cpStar[i] = star
    end

    built = true
end

--------------------------------------------------------------------------------
-- Populate helpers
--------------------------------------------------------------------------------
local function metaSubtitle(meta)
    local parts = {}
    if meta.class and meta.class ~= "" then parts[#parts + 1] = zo_strformat("<<1>>", meta.class) end
    if meta.race and meta.race ~= "" then parts[#parts + 1] = zo_strformat("<<1>>", meta.race) end
    if meta.alliance then
        local a = IV.safeCall(GetAllianceName, meta.alliance)
        if a and a ~= "" then parts[#parts + 1] = zo_strformat("<<1>>", a) end
    end
    if meta.cp and meta.cp > 0 then parts[#parts + 1] = "CP " .. meta.cp
    elseif meta.level and meta.level > 0 then parts[#parts + 1] = "Level " .. meta.level end
    return table.concat(parts, "  \226\128\162  ")
end

local function statusText(meta)
    local src = meta.source
    if src == "self" then return IV.L.SOURCE_SELF
    elseif src == "peer" then return "|c33cc33" .. IV.L.SOURCE_PEER .. "|r"
    elseif src == "cache" then
        local rel = IV.safeCall(ZO_FormatDurationAgo, GetTimeStamp() - (meta.ts or GetTimeStamp())) or ""
        return string.format(IV.L.SOURCE_CACHE, rel)
    else return "|c999999" .. IV.L.SOURCE_PUBLIC .. "|r" end
end

-- A slot is "occupied" iff a gear entry exists for it (nil == empty for self, and
-- Serialize only includes occupied slots for peers).
local function gearOccupied(loadout, slot)
    return loadout.gear ~= nil and loadout.gear[slot] ~= nil
end

-- Build the ordered {slot, col, y} placement list for the current loadout (y is a
-- pixel offset within the gear block, so blank spacers can be half a row tall):
--   left column  : armor (always reserved, so empty slots leave a gap, as before)
--   right column : jewelry, [half-blank], front weapon(s), [half-blank], back weapon(s)
-- Weapon rows collapse -- only occupied weapon slots get a row.
local function buildGearPlacements(loadout)
    local placements = {}

    for r, slot in ipairs(GEAR_ARMOR) do
        placements[#placements + 1] = { slot = slot, col = 0, y = (r - 1) * GEAR_ROW_H }
    end

    local yoff = 0
    for _, slot in ipairs(GEAR_JEWELRY) do
        placements[#placements + 1] = { slot = slot, col = 1, y = yoff }
        yoff = yoff + GEAR_ROW_H
    end
    yoff = yoff + BLANK_ROW_H  -- half-height blank after jewelry

    local frontCount = 0
    for _, slot in ipairs(GEAR_FRONT_WEAPONS) do
        if gearOccupied(loadout, slot) then
            placements[#placements + 1] = { slot = slot, col = 1, y = yoff }
            yoff = yoff + GEAR_ROW_H
            frontCount = frontCount + 1
        end
    end

    local back = {}
    for _, slot in ipairs(GEAR_BACK_WEAPONS) do
        if gearOccupied(loadout, slot) then back[#back + 1] = slot end
    end
    if #back > 0 then
        if frontCount > 0 then yoff = yoff + BLANK_ROW_H end  -- half-height blank between groups
        for _, slot in ipairs(back) do
            placements[#placements + 1] = { slot = slot, col = 1, y = yoff }
            yoff = yoff + GEAR_ROW_H
        end
    end

    return placements
end

-- Fixed slot-name box width for a gear slot's group (armor / jewelry / weapons), so the set-name
-- value that follows lines up within each group.
local function gearNameBoxWidth(slot)
    if slot == EQUIP_SLOT_NECK or slot == EQUIP_SLOT_RING1 or slot == EQUIP_SLOT_RING2 then
        return GEAR_NAME_W_JEWELRY
    elseif slot == EQUIP_SLOT_MAIN_HAND or slot == EQUIP_SLOT_OFF_HAND
        or slot == EQUIP_SLOT_BACKUP_MAIN or slot == EQUIP_SLOT_BACKUP_OFF then
        return GEAR_NAME_W_WEAPON
    end
    return GEAR_NAME_W_ARMOR
end

-- Show bar `idx`'s poison as a small icon just right of that bar's weapon icon(s), vertically
-- centred ACROSS them (`ys` = that bar's weapon-row y offsets) -- ESO has ONE poison slot per bar,
-- so dual wield gets a single icon spanning both rows. Shown ONLY when a poison is actually
-- equipped (real, hoverable item icon); with none equipped -- or no weapon rows to sit beside --
-- no icon at all, and populateGear keeps that bar's labels at the normal offset (no dead gap).
local function placePoisonIcon(idx, poisonSlot, loadout, ys)
    local ctrl = poisonCtrl[idx]
    if not ctrl then return end
    local g = loadout.gear and loadout.gear[poisonSlot]
    local link = g and ensureGearLink(g)
    if #ys == 0 or not (g and link and link ~= "") then   -- nothing to sit beside / no poison
        ctrl:SetHidden(true)
        poisonData[idx] = nil
        return
    end
    local minY, maxY = ys[1], ys[#ys]
    -- Centre the icon on the weapon rows (rows span minY .. maxY+GEAR_ROW_H).
    local topY = GEAR_BASE_Y + minY + (maxY - minY + GEAR_ROW_H - POISON_SIZE) / 2
    ctrl:ClearAnchors()
    -- Right column icon x (COL_WIDTH) + gear-icon width (18) + a 2px gap.
    ctrl:SetAnchor(TOPLEFT, content, TOPLEFT, COL_WIDTH + 18 + 2, topY)
    poisonTex[idx]:SetTexture(GetItemLinkIcon(link))
    poisonTex[idx]:SetColor(1, 1, 1, 1)
    poisonData[idx] = g          -- equipped -> hoverable
    ctrl:SetHidden(false)
end

local function populateGear(loadout)
    -- reset the whole pool + the poison icons + the (cosmetics-only) dye swatches
    for k = 1, GEAR_POOL_N do
        gearData[k] = nil
        if gearIcon[k] then gearIcon[k]:SetHidden(true) end
        if gearLabel[k] then gearLabel[k]:SetHidden(true) end
        if gearValue[k] then gearValue[k]:SetHidden(true) end
        if dyeSwatch[k] then for c = 1, 3 do dyeSwatch[k][c].cell:SetHidden(true); dyeData[k][c] = nil end end
    end
    for i = 1, POISON_POOL_N do
        poisonData[i] = nil
        if poisonCtrl[i] then poisonCtrl[i]:SetHidden(true) end
    end

    local wpnYs = { [EQUIP_SLOT_POISON] = {}, [EQUIP_SLOT_BACKUP_POISON] = {} }   -- weapon-row y's per bar

    local hasAnyGear = false
    for k, p in ipairs(buildGearPlacements(loadout)) do
        local icon, label, value = gearIcon[k], gearLabel[k], gearValue[k]
        if not icon then break end

        icon:ClearAnchors()
        icon:SetDimensions(18, 18)   -- the cosmetics view may have compressed the shared pool's icons
        icon:SetAnchor(TOPLEFT, content, TOPLEFT, p.col * COL_WIDTH, GEAR_BASE_Y + p.y)

        -- A weapon row shifts its label right to clear the poison icon ONLY when that bar actually
        -- has a poison equipped -- no poison means no icon (hidden, not a placeholder), so the label
        -- sits at the normal offset with no dead gap. (Set every row so reused cells reset.)
        local poisonSlot = POISON_FOR_WEAPON[p.slot]
        if poisonSlot then wpnYs[poisonSlot][#wpnYs[poisonSlot] + 1] = p.y end
        local off = (poisonSlot and loadout.gear and loadout.gear[poisonSlot]) and POISON_LABEL_X or 4

        -- Slot name goes in a FIXED-width box (per group) so the value that follows lines up within
        -- the group (armor / jewelry / weapons each align independently).
        local nameW = gearNameBoxWidth(p.slot)
        label:ClearAnchors()
        label:SetAnchor(LEFT, icon, RIGHT, off, 0)
        label:SetWidth(nameW)
        value:ClearAnchors()
        value:SetAnchor(LEFT, label, RIGHT, 4, 0)
        value:SetWidth(COL_WIDTH - 22 - off - nameW - 4)

        local g = loadout.gear and loadout.gear[p.slot]
        local slotName = IV.GEAR_SLOT_NAMES[p.slot] or ""
        label:SetText(string.format(" |cC5C29E%s|r", slotName))
        label:SetHidden(false)
        if g then
            hasAnyGear = true
            gearData[k] = g
            local link = ensureGearLink(g)   -- rebuilds link + set info for peer gear
            if link and link ~= "" then
                icon:SetTexture(GetItemLinkIcon(link))
                icon:SetHidden(false)
            else
                icon:SetHidden(true)
            end
            local setName = resolveSetName(g.setId)
            if setName then
                value:SetText(string.format("|c%s%s|r", qualityHex(g.quality), setName))
            else
                -- No set: a faintly rarity-tinted "Non-set item", so it reads as intentional
                -- rather than a bare "-" that looks like a bug.
                value:SetText(string.format("|c%s%s|r", mutedHex(qualityHex(g.quality)), IV.L.GEAR_NO_SET))
            end
        else
            -- Empty armor/jewelry slot: the character-sheet silhouette + "None".
            local emptyTex = IV.safeCall(ZO_Character_GetEmptyEquipSlotTexture, p.slot)
            if emptyTex and emptyTex ~= "" then
                icon:SetTexture(emptyTex)
                icon:SetHidden(false)
            else
                icon:SetHidden(true)
            end
            value:SetText(string.format("|c555555%s|r", IV.L.SLOT_EMPTY))
        end
        value:SetHidden(false)
    end

    -- Each bar's (single) poison sits beside that bar's weapon icon(s), centred across its rows.
    placePoisonIcon(1, EQUIP_SLOT_POISON, loadout, wpnYs[EQUIP_SLOT_POISON])
    placePoisonIcon(2, EQUIP_SLOT_BACKUP_POISON, loadout, wpnYs[EQUIP_SLOT_BACKUP_POISON])

    return hasAnyGear
end

--------------------------------------------------------------------------------
-- Cosmetics view (the Equipment header toggles to it). Reuses the gear cell pool: per armor/weapon
-- slot the applied appearance (outfit style collectible, else the item's base motif; armor reads
-- "Hidden by costume" when a costume is worn), then the active collectible cosmetics as rows. Tooltips
-- go through cosmeticData[i] + Window.OnCosmeticEnter (OnGearEnter dispatches to it in this mode).
--------------------------------------------------------------------------------
local COSMETIC_ROWS = {   -- collectible cosmetics, in display order (key on loadout.cosmetics; label)
    -- NB: "hat" is intentionally absent -- a worn hat replaces the helmet and shows in the HEAD slot.
    { key = "costume",       label = "Costume" },
    { key = "skin",          label = "Skin" },
    { key = "personality",   label = "Personality" },
    { key = "polymorph",     label = "Polymorph" },
    { key = "faceAdornment", label = "Adornment" },
    { key = "piercing",      label = "Piercing" },
    { key = "headMarking",   label = "Head marking" },
    { key = "bodyMarking",   label = "Body marking" },
    { key = "mount",         label = "Mount" },
    { key = "pet",           label = "Pet" },
}
local WEAPON_SLOTS = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }

local function isWeaponSlot(slot)
    return slot == EQUIP_SLOT_MAIN_HAND or slot == EQUIP_SLOT_OFF_HAND
        or slot == EQUIP_SLOT_BACKUP_MAIN or slot == EQUIP_SLOT_BACKUP_OFF
end

-- Resolve one slot's appearance -> { tex, value (coloured), tip {kind,id}, dim } or nil.
local function resolveSlotAppearance(loadout, slot)
    local cos = loadout.cosmetics
    if not cos then return nil end
    -- HEAD: a worn Hat collectible replaces the helmet's appearance entirely (shown even with no
    -- helmet equipped), so it takes this slot instead of appearing in the collectibles list below.
    -- (A hat hidden by the active layer was already dropped upstream by the visual-layer query, so a
    -- non-nil cos.hat is genuinely visible -- e.g. a polymorph with its show-helm option on.)
    if slot == EQUIP_SLOT_HEAD and cos.hat and cos.hat ~= 0 then
        local nm = IV.safeCall(GetCollectibleName, cos.hat)
        return { tex = IV.safeCall(GetCollectibleIcon, cos.hat),
                 value = string.format("|c%s%s|r", COS_NAME_HEX, (nm and nm ~= "") and zo_strformat("<<1>>", nm) or "?"),
                 tip = { kind = "collectible", id = cos.hat }, dyes = cos.hatDyes }
    end
    local s = cos.slots and cos.slots[slot]
    if not s then return nil end
    -- A POLYMORPH also hides the HELMET outfit style (it replaces the whole head) -- a costume does NOT
    -- (you keep your helmet/hat under a costume). Weapon styles stay visible under both.
    if slot == EQUIP_SLOT_HEAD and cos.polymorph then return nil end
    -- A costume OR polymorph hides BODY armor (not the head -- handled above -- and not weapons), so
    -- those rows are skipped; the costume/polymorph itself shows in the collectibles list. Keyed on
    -- either because a polymorph also hides the outfit AND hides the costume (so cos.costume is dropped
    -- by the visual-layer query under a polymorph -- cos.polymorph then carries the hiding).
    -- (Hidden COLLECTIBLES -- markings/skin/etc. -- are already omitted upstream by that same query.)
    if (cos.costume or cos.polymorph) and not isWeaponSlot(slot) and slot ~= EQUIP_SLOT_HEAD then return nil end
    -- Resolve the style collectible HERE (display time), so a peer-receiver resolves too: an outfit
    -- override is already a collectible; a base style's osid maps via the shared enumeration.
    local coll = (s.ocoll and s.ocoll ~= 0) and s.ocoll or nil
    local isOverride = coll ~= nil
    if not coll and s.osid and s.osid ~= 0 then coll = IV.StyleCollectibleForOsid(s.osid) end
    if coll and coll ~= 0 then                        -- a style collectible (rich tooltip). An override
        -- reads as its per-piece collectible name; a base style reads cleaner as its style-family name
        -- (the item motif) -- "Lucent Sentinel" not "Lucent Sentinel Jack".
        local nm = isOverride and IV.safeCall(GetCollectibleName, coll)
                   or (s.motif and IV.safeCall(GetItemStyleName, s.motif)) or IV.safeCall(GetCollectibleName, coll)
        return { tex = IV.safeCall(GetCollectibleIcon, coll),
                 value = string.format("|c%s%s|r", COS_NAME_HEX, (nm and nm ~= "") and zo_strformat("<<1>>", nm) or "?"),
                 tip = { kind = "collectible", id = coll }, dyes = s.dyes }
    end
    if s.motif and s.motif ~= 0 then                 -- style with no collectible (e.g. some monster
        local nm = IV.safeCall(GetItemStyleName, s.motif)    -- styles): name + the item's own tooltip
        local g = loadout.gear and loadout.gear[slot]
        local link = g and ensureGearLink(g)
        local tip = (link and link ~= "") and { kind = "item", link = link } or { kind = "style", id = s.motif }
        return { tex = (link and link ~= "" and GetItemLinkIcon(link)) or nil,
                 value = string.format("|cb9b9b9%s|r", (nm and nm ~= "") and zo_strformat("<<1>>", nm) or "?"),
                 tip = tip, dyes = s.dyes }
    end
    return nil
end

-- Placement list for the Cosmetics view: armor appearances (left), weapon appearances (right), then
-- the active collectibles filling whichever column is currently SHORTER -- so the block stays
-- balanced and doesn't overflow one side (a worn costume empties the armor column entirely). Same
-- pixel-offset scheme as buildGearPlacements, EXCEPT the row height is dynamic: the section below
-- (Front bar) sits at a FIXED y, and a full cosmetics list (no costume hiding armor, plus
-- skin/markings/adornments/mount/pet) can exceed the gear block's 7-row budget -- so rows compress
-- just enough to fit rather than spilling over the skills section. Returns placements + the rowH.
local function buildCosmeticPlacements(loadout)
    local out = {}
    local lrows, rrows = 0, 0
    for _, slot in ipairs(GEAR_ARMOR) do
        if resolveSlotAppearance(loadout, slot) then
            out[#out + 1] = { kind = "slot", slot = slot, col = 0, row = lrows }; lrows = lrows + 1
        end
    end
    for _, slot in ipairs(WEAPON_SLOTS) do
        if resolveSlotAppearance(loadout, slot) then
            out[#out + 1] = { kind = "slot", slot = slot, col = 1, row = rrows }; rrows = rrows + 1
        end
    end
    for _, row in ipairs(COSMETIC_ROWS) do
        local id = loadout.cosmetics and loadout.cosmetics[row.key]
        if id then
            local col, r
            if lrows <= rrows then col, r, lrows = 0, lrows, lrows + 1 else col, r, rrows = 1, rrows, rrows + 1 end
            out[#out + 1] = { kind = "collectible", key = row.key, label = row.label, id = id, col = col, row = r }
        end
    end
    local maxRows = math.max(lrows, rrows, 1)
    local rowH = math.min(GEAR_ROW_H, math.floor((GEAR_BLOCK_H - 10) / maxRows))
    for _, p in ipairs(out) do p.y = p.row * rowH end
    return out, rowH
end

local function populateCosmetics(loadout)
    for k = 1, GEAR_POOL_N do
        gearData[k], cosmeticData[k] = nil, nil
        if gearIcon[k] then gearIcon[k]:SetHidden(true) end
        if gearLabel[k] then gearLabel[k]:SetHidden(true) end
        if gearValue[k] then gearValue[k]:SetHidden(true) end   -- Equipment-only split label; unused here
        if dyeSwatch[k] then for c = 1, 3 do dyeSwatch[k][c].cell:SetHidden(true); dyeData[k][c] = nil end end
    end
    for i = 1, POISON_POOL_N do
        poisonData[i] = nil
        if poisonCtrl[i] then poisonCtrl[i]:SetHidden(true) end   -- poisons belong to the gear view only
    end

    local placements, rowH = buildCosmeticPlacements(loadout)
    local iconSz = math.min(18, rowH - 3)   -- shrink icons with the rows so they never overlap
    local swSz = math.max(9, math.min(16, rowH - 3))   -- dye chips, scaled with the row height
    for k, p in ipairs(placements) do
        local icon, label = gearIcon[k], gearLabel[k]
        if not icon then break end

        -- Resolve the row's content + its dyes FIRST -- the label width depends on the swatch block.
        local a, dyes
        if p.kind == "slot" then
            a = resolveSlotAppearance(loadout, p.slot)
            dyes = a and a.dyes
        elseif p.key == "costume" then
            dyes = loadout.cosmetics and loadout.cosmetics.costumeDyes
        end

        icon:ClearAnchors()
        icon:SetDimensions(iconSz, iconSz)
        icon:SetAnchor(TOPLEFT, content, TOPLEFT, p.col * COL_WIDTH, GEAR_BASE_Y + p.y)
        icon:SetColor(1, 1, 1, 1)
        label:ClearAnchors()
        label:SetAnchor(LEFT, icon, RIGHT, 4, 0)
        label:SetWidth(COL_WIDTH - 26 - (dyes and (3 * (swSz + 2) + 4) or 0))

        if p.kind == "slot" then
            icon:SetTexture((a and a.tex) or "/esoui/art/icons/icon_missing.dds")
            if a and a.dim then icon:SetColor(1, 1, 1, 0.5) end
            icon:SetHidden(false)
            label:SetText(string.format("|cC5C29E%s|r  %s", IV.GEAR_SLOT_NAMES[p.slot] or "", (a and a.value) or ""))
            label:SetHidden(false)
            cosmeticData[k] = a and a.tip
        else
            local nm = IV.safeCall(GetCollectibleName, p.id)
            icon:SetTexture(IV.safeCall(GetCollectibleIcon, p.id) or "/esoui/art/icons/icon_missing.dds")
            icon:SetHidden(false)
            label:SetText(string.format("|cC5C29E%s|r  |c%s%s|r", p.label, COS_NAME_HEX,
                (nm and nm ~= "") and zo_strformat("<<1>>", nm) or "?"))
            label:SetHidden(false)
            cosmeticData[k] = { kind = "collectible", id = p.id }
        end

        -- Dye swatches at the row's right edge, tinted from the (global) dye ids -- resolved on the
        -- VIEWER via GetDyeInfoById (name, known, rarity, hueCat, achId, r, g, b, ...), like every
        -- other id in this view. An unknown/0 channel simply shows no swatch.
        if dyes then
            local baseX = p.col * COL_WIDTH + COL_WIDTH - 4 - 3 * (swSz + 2)
            local swY = GEAR_BASE_Y + p.y + (rowH - swSz) / 2
            for c = 1, 3 do
                local sw = dyeSwatch[k] and dyeSwatch[k][c]
                local dyeId = dyes[c] or 0
                if sw and dyeId ~= 0 then
                    -- GetDyeInfoById -> name, known, rarity, hueCategory, achievementId, r, g, b, sortKey
                    -- (r/g/b are 0-1, confirmed via /ivdump). r is the 6th value after pcall's ok.
                    local ok, _, _, _, _, _, r, g, b = pcall(GetDyeInfoById, dyeId)
                    if ok and type(r) == "number" then
                        sw.cell:ClearAnchors()
                        sw.cell:SetDimensions(swSz, swSz)
                        sw.cell:SetAnchor(TOPLEFT, content, TOPLEFT, baseX + (c - 1) * (swSz + 2), swY)
                        sw.bd:SetCenterColor(r, g, b, 1)
                        sw.cell:SetHidden(false)
                        dyeData[k][c] = dyeId   -- hoverable -> tooltip
                    end
                end
            end
        end
    end
end

-- Dispatch the Equipment section to the gear or cosmetics view, and set the header's toggle text.
-- Assigned to the forward-declared local. Returns hasAnyGear (for Show's "not sharing" check).
renderEquipment = function(loadout)
    local eHex = gearShowCosmetics and "808080" or "C5C29E"
    local cHex = gearShowCosmetics and "C5C29E" or "808080"
    -- The "(i)" set-summary hint stays in BOTH modes (it vanishing on toggle looked like a glitch);
    -- in Cosmetics mode it just isn't hoverable (OnGearHeaderEnter bails), and dims with "Equipment".
    local iHint = gearShowCosmetics and " |c5a5a5a(i)|r" or " |c8a8a8a(i)|r"
    gearHeader:SetText(string.format("|c%s%s|r%s |c606060/|r |c%s%s|r",
        eHex, IV.L.LABEL_GEAR, iHint, cHex, IV.L.LABEL_COSMETICS))
    if gearShowCosmetics then
        populateCosmetics(loadout)
        return true
    end
    return populateGear(loadout)
end

local function populateBar(icons, ids)
    for i = 1, 6 do
        local icon = icons[i]
        icon:SetHidden(false)   -- undo compact-mode hiding
        local id = ids and ids[i]
        if id and id ~= 0 then
            icon:SetTexture(GetAbilityIcon(id))
            icon:SetColor(1, 1, 1, 1)
            skillData[icon] = id
        else
            icon:SetTexture("/esoui/art/icons/icon_missing.dds")
            icon:SetColor(1, 1, 1, 0.15)
            skillData[icon] = nil
        end
    end
end

-- Populate the back-bar row with either the backup bar or (when toggled) the werewolf
-- transformation bar, and set the header: a "Back bar / Werewolf" clickable toggle when a
-- werewolf bar exists, or a plain "Back bar" otherwise. Assigned to the forward-declared local.
renderBackBar = function()
    local skills = currentLoadout and currentLoadout.skills
    local hasWW = skills and skills.werewolf
    if not hasWW then skillsShowWerewolf = false end
    populateBar(backIcon, (skillsShowWerewolf and skills.werewolf) or (skills and skills.backup))
    if hasWW then
        local bHex = skillsShowWerewolf and "808080" or "C5C29E"
        local wHex = skillsShowWerewolf and "C5C29E" or "808080"
        backHeader:SetText(string.format("|c%s%s|r |c606060/|r |c%s%s|r",
            bHex, IV.L.LABEL_BACK_BAR, wHex, IV.L.LABEL_WEREWOLF_BAR))
    else
        backHeader:SetText(IV.L.LABEL_BACK_BAR)
    end
end

local function hideCPStars()
    for i = 1, #cpStar do
        if cpStar[i] then cpStar[i]:SetHidden(true) end
        cpStarData[i] = nil
        cpStarPoints[i] = nil
    end
end

-- Lay out one discipline-colour group as a left-aligned, comma-delimited row. Each star stays
-- its own auto-sized label (so it keeps a hover tooltip), anchored to the PREVIOUS star's right
-- edge -- the layout engine resolves the real text widths at draw time, so nothing overlaps.
-- (The old approach measured GetTextWidth right after SetText, which is stale for a reused label
-- and made chips clip/overlap -- worst when switching between self and a peer.) No fixed widths
-- are set, so the labels always size to their current text.
local function assignCPGroup(group, rowY, startIdx)
    local prev
    for k, cell in ipairs(group) do
        local star = cpStar[startIdx + k - 1]
        if not star then break end
        star:SetText(cell.text)
        star:SetHidden(false)
        star:ClearAnchors()
        if prev then
            star:SetAnchor(TOPLEFT, prev, TOPRIGHT, CP_GAP, 0)
        else
            star:SetAnchor(TOPLEFT, content, TOPLEFT, CP_LEFT_MARGIN, rowY)
        end
        prev = star
        cpStarData[startIdx + k - 1]   = cell.id
        cpStarPoints[startIdx + k - 1] = cell.points
    end
    return rowY + CP_LINE_H, startIdx + #group
end

-- Hide every build section AND its section titles/skill icons -- used for the compact
-- "no data" window, where nothing but the header card is shown.
local function hideBuildControls()
    for _, h in ipairs({ gearHeader, frontHeader, backHeader }) do
        if h then h:SetHidden(true) end
    end
    gearShowCosmetics = false
    for i = 1, GEAR_POOL_N do
        if gearIcon[i] then gearIcon[i]:SetHidden(true) end
        if gearLabel[i] then gearLabel[i]:SetHidden(true) end
        if gearValue[i] then gearValue[i]:SetHidden(true) end
        if dyeSwatch[i] then for c = 1, 3 do dyeSwatch[i][c].cell:SetHidden(true); dyeData[i][c] = nil end end
        gearData[i], cosmeticData[i] = nil, nil
    end
    for i = 1, POISON_POOL_N do
        if poisonCtrl[i] then poisonCtrl[i]:SetHidden(true) end
        poisonData[i] = nil
    end
    for i = 1, 6 do
        for _, icon in ipairs({ frontIcon[i], backIcon[i] }) do
            if icon then icon:SetHidden(true); skillData[icon] = nil end
        end
    end
    mundusData, foodData, curseData, potionData, foodItemLink = nil, nil, nil, nil, nil
    hideCPStars()
    if classHeader then classHeader:SetHidden(true) end
    for i = 1, CLASS_POOL_N do
        if classCtrl[i] then classCtrl[i]:SetHidden(true) end
        classData[i] = nil
    end
    -- Static-text headers: hide (don't clear, or the text is lost).
    for _, h in ipairs({ mundusHeader, foodHeader, potionHeader, curseHeader }) do
        if h then h:SetHidden(true) end
    end
    if frontStats.header then frontStats.header:SetHidden(true) end
    if backStats.header  then backStats.header:SetHidden(true)  end
    for _, l in ipairs({ attrsTitle, attrsLabel, mundusLabel, foodLabel, potionLabel, curseLabel, cpHeaderLabel,
                         frontStats[1], frontStats[2], frontStats[3], backStats[1], backStats[2], backStats[3] }) do
        if l then l:SetText("") end
    end
end

-- Re-show the section titles for the full build view (skill icons re-shown by populateBar).
local function showBuildChrome()
    for _, h in ipairs({ gearHeader, frontHeader, backHeader, mundusHeader, foodHeader, potionHeader, curseHeader }) do
        if h then h:SetHidden(false) end
    end
end

-- Is there any build to display (vs. public-only info / nothing shared)?
local function hasAnyBuild(loadout)
    if not loadout then return false end
    if loadout.meta and loadout.meta.source == "public" then return false end
    if next(loadout.gear or {}) ~= nil then return true end
    local sk = loadout.skills or {}
    for _, bar in ipairs({ sk.primary or {}, sk.backup or {} }) do
        for _, id in ipairs(bar) do
            if id and id ~= 0 then return true end
        end
    end
    return false
end

-- Show/hide via the scene manager (so ESC closes the window); fall back to plain
-- hidden-state toggling if the scene-manager methods aren't available.
local function showWindow()
    if not win then return end
    if SCENE_MANAGER and SCENE_MANAGER.ShowTopLevel then
        SCENE_MANAGER:ShowTopLevel(win)
    else
        win:SetHidden(false)
    end
    win:BringWindowToTop()
end

local function hideWindow()
    if not win then return end
    if SCENE_MANAGER and SCENE_MANAGER.HideTopLevel then
        SCENE_MANAGER:HideTopLevel(win)
    else
        win:SetHidden(true)
    end
end

--------------------------------------------------------------------------------
-- Public: show a loadout
--------------------------------------------------------------------------------
function Window.Show(loadout)
    Window.Init()
    if not win or not loadout then return end
    if setPanel then setPanel:SetHidden(true) end   -- reset the set-summary popup on any re-render
    local meta = loadout.meta or {}
    currentLoadout, currentSource = loadout, meta.source

    local displayName = (meta.name and meta.name ~= "") and meta.name
                        or (meta.atAccount and meta.atAccount ~= "") and meta.atAccount
                        or "?"
    titleLabel:SetText(zo_strformat("<<1>>", displayName))
    subtitleLabel:SetText(metaSubtitle(meta))

    -- Nothing to show beyond public info (public-only target, or a peer/cache that shared
    -- no build): collapse to a compact window with just the header card + a short blurb.
    if not hasAnyBuild(loadout) then
        hideBuildControls()
        local msg = (meta.source == "public") and IV.L.STATUS_UNAVAILABLE or IV.L.STATUS_NOT_SHARING
        statusLabel:SetText("|c999999" .. msg .. "|r")
        win:SetDimensions(COMPACT_WIDTH, COMPACT_HEIGHT)   -- narrow card, not the full two-column width
        subtitleLabel:SetWidth(COMPACT_WIDTH - 40)
        statusLabel:SetWidth(COMPACT_WIDTH - 40)
        showWindow()
        return
    end

    -- Full build view (two columns).
    showBuildChrome()
    win:SetDimensions(FULL_WIDTH, FULL_HEIGHT)
    subtitleLabel:SetWidth(CONTENT_W)
    statusLabel:SetWidth(CONTENT_W)
    statusLabel:SetText(statusText(meta))

    gearShowCosmetics = false                 -- every inspect opens on the Equipment view
    local hasGear   = renderEquipment(loadout)
    populateBar(frontIcon, loadout.skills and loadout.skills.primary)
    skillsShowWerewolf = false   -- start on the back bar each inspect
    renderBackBar()

    -- Attributes (bold header + centre-spread coloured values; header control is already gold)
    local a = loadout.attrs or {}
    if a.magicka or a.health or a.stamina then
        attrsTitle:SetText(IV.L.LABEL_ATTRS)
        attrsLabel:SetText(string.format(
            "|c%s%s %d|r      \226\128\162      |c%s%s %d|r      \226\128\162      |c%s%s %d|r",
            COLOR_MAG,  IV.L.ATTR_MAGICKA, a.magicka or 0,
            COLOR_HP,   IV.L.ATTR_HEALTH,  a.health or 0,
            COLOR_STAM, IV.L.ATTR_STAMINA, a.stamina or 0))
    else
        attrsTitle:SetText("")
        attrsLabel:SetText("")
    end

    -- Core stats: per-bar (resources / dmg+pen / crit) shown BESIDE each skill bar -- front stats
    -- beside the Front bar, back stats beside the Back bar (renderStats fills both; an uncaptured
    -- bar shows the "swap once" hint).
    renderStats()

    -- Mundus (whole row hoverable via mundusData)
    mundusData = loadout.mundus and loadout.mundus.id
    local mundusText = IV.L.LABEL_NONE
    if loadout.mundus then
        mundusText = loadout.mundus.name or resolveAbilityName(loadout.mundus.id) or IV.L.LABEL_NONE
    end
    mundusLabel:SetText(mundusText)

    -- Food (whole row hoverable via foodData). The food ITEM is resolved in the reader (self: last-eaten
    -- cache or a backpack scan, matched to the buff by icon) and its fields ride the build -- so self
    -- renders the real link and a peer reconstructs one. Hover = the rich item tooltip when resolved,
    -- else the live buff tooltip.
    foodData = loadout.food and loadout.food.id
    foodItemLink = nil
    local foodText = IV.L.LABEL_NONE
    if loadout.food then
        foodText = loadout.food.name or resolveAbilityName(loadout.food.id) or IV.L.LABEL_NONE
        local fi = loadout.food.itemId
        if fi and fi ~= 0 then
            foodItemLink = (loadout.food.itemLink and loadout.food.itemLink ~= "" and loadout.food.itemLink)
                           or IV.ReconstructItemLink(fi, loadout.food.subtype, loadout.food.level, 0, 0, 0, 0)
            if foodItemLink then   -- show the food ITEM name (not the buff name) once resolved
                local nm = GetItemLinkName(foodItemLink)
                if nm and nm ~= "" then foodText = zo_strformat("<<1>>", nm) end
            end
        end
    end
    foodLabel:SetText(foodText)

    -- Potion (active quickslot potion; hover -> item tooltip). Self renders the real worn link;
    -- a peer/cache reconstructs one from the transmitted item fields (itemId carries the effects).
    potionData = nil
    local potionText = IV.L.SLOT_EMPTY
    local pot = loadout.potion
    if pot then
        local link = (pot.itemLink and pot.itemLink ~= "" and pot.itemLink)
                     or IV.ReconstructPotionLink(pot.itemId, pot.subtype, pot.level, pot.pd1, pot.pd2)
        potionData = link
        local nm = pot.name
        if (not nm or nm == "") and link then nm = GetItemLinkName(link) end
        potionText = (nm and nm ~= "") and zo_strformat("<<1>>", nm) or IV.L.SLOT_EMPTY
    end
    potionLabel:SetText(potionText)

    -- Vampire / Werewolf (row hoverable via curseData -- vampire stage buff)
    curseData = loadout.curse and loadout.curse.id
    local curseText = IV.L.SLOT_EMPTY
    if loadout.curse then
        if loadout.curse.type == "werewolf" then
            curseText = IV.L.CURSE_WEREWOLF
        elseif loadout.curse.type == "vampire" then
            curseText = string.format(IV.L.CURSE_VAMPIRE_STAGE, loadout.curse.stage or 1)
        end
    end
    curseLabel:SetText(curseText)

    -- Class / Subclass (right column, below Curse)
    populateClass(loadout)

    -- Champion Points -- stars grouped by discipline colour, each colour on its own
    -- centred line (like the Attributes/Stats rows) with a gap between colours. Each star
    -- is its own hoverable chip; commas (default/white) separate stars within a colour.
    hideCPStars()
    local slotted = loadout.cp and loadout.cp.slotted or {}
    if #slotted == 0 then
        cpHeaderLabel:SetText(string.format("|cC5C29E%s|r  %s", IV.L.LABEL_CP, IV.L.LABEL_NONE))
    else
        cpHeaderLabel:SetText(string.format("|cC5C29E%s|r", IV.L.LABEL_CP))
        -- Bucket the slotted stars by discipline colour (preserving first-seen order for
        -- any colour outside the fixed order below).
        local cpPoints = loadout.cp and loadout.cp.points
        local buckets, seen = {}, {}
        for i, starId in ipairs(slotted) do
            local nm, hex = resolveCPStar(starId)
            nm  = nm or ("#" .. starId)
            hex = hex or "ffffff"
            if not buckets[hex] then buckets[hex] = {}; seen[#seen + 1] = hex end
            local g = buckets[hex]
            g[#g + 1] = { id = starId, name = nm, hex = hex, points = cpPoints and cpPoints[i] }
        end
        -- Comma-separate stars within each colour (comma left in the default/white colour,
        -- like the Stats-row separators).
        for _, hex in ipairs(seen) do
            local g = buckets[hex]
            for k, cell in ipairs(g) do
                cell.text = string.format("|c%s%s|r%s", cell.hex, cell.name, (k < #g) and "," or "")
            end
        end
        -- Emit each colour group on its own centred line with a gap between colours, in a
        -- fixed order (green, blue, red), then any colours not in that order.
        local rowY, idx, done = cpBaseY, 1, {}
        local function emit(hex)
            local g = buckets[hex]
            if g and #g > 0 and not done[hex] then
                done[hex] = true
                rowY, idx = assignCPGroup(g, rowY, idx)
                rowY = rowY + CP_GROUP_GAP
            end
        end
        for _, hex in ipairs(CP_GROUP_ORDER) do emit(hex) end
        for _, hex in ipairs(seen) do emit(hex) end
    end

    -- A peer/cache result that arrived with no gear (e.g. target shared nothing).
    if not hasGear then
        statusLabel:SetText("|ccc6666" .. IV.L.STATUS_NOT_SHARING .. "|r")
    end

    showWindow()
end

-- Show the window immediately in a "syncing" state while a peer request is in flight.
function Window.ShowSyncing(loadout)
    Window.Show(loadout)
    if statusLabel then statusLabel:SetText("|cffcc33" .. IV.L.STATUS_SYNCING .. "|r") end
end

function Window.SetStatus(text)
    if statusLabel then statusLabel:SetText(text) end
end

function Window.Hide()
    hideWindow()
end

function Window.Toggle(loadout)
    if win and not win:IsHidden() then
        Window.Hide()
    else
        Window.Show(loadout)
    end
end
