PBsUltraDetailedStats = { name = "PBsUltraDetailedStats", sceneName = "pbsUltraDetailedStats", title = "PB'S ULTRA DETAILED STATS" }
local P = PBsUltraDetailedStats
P.Data = {}
local D = P.Data

local function clean(text)
    return zo_strformat("<<1>>", text or "")
end
local function row(rows, key, name, value, detail, icon)
    rows[#rows + 1] = { key = key, name = clean(name), value = tostring(value or ""), detail = detail or "", icon = icon }
end
local function header(rows, key, name)
    row(rows, key, name, "", name)
    rows[#rows].header = true
end
local function number(value)
    return value and tostring(zo_round(value)) or "—"
end
-- Subclassing (API 101046 and later). Older clients have neither the points nor the function.
local function masteryPoints(lineId)
    if not GetNumClassMasteryPointsBySkillLineId then return 0 end
    return GetNumClassMasteryPointsBySkillLineId(lineId) or 0
end
D.Number = number

function D.Equipment()
    local rows = {}
    local slots = {
        {"HEAD", "頭"}, {"SHOULDERS", "肩"}, {"CHEST", "胴"}, {"HAND", "手"},
        {"WAIST", "腰"}, {"LEGS", "脚"}, {"FEET", "足"},
        {"RING1", "指輪 1"}, {"RING2", "指輪 2"}, {"NECK", "首"}, {"MAIN_HAND", "表・主武器"},
        {"OFF_HAND", "表・副武器"}, {"BACKUP_MAIN", "裏・主武器"}, {"BACKUP_OFF", "裏・副武器"},
        {"POISON", "表・毒"}, {"BACKUP_POISON", "裏・毒"}, {"COSTUME", "コスチューム"},
    }
    for _, slot in ipairs(slots) do
        local id = _G["EQUIP_SLOT_" .. slot[1]]
        if id then
            local link = GetItemLink(BAG_WORN, id, LINK_STYLE_DEFAULT)
            if link == "" then
                row(rows, slot[1], slot[2] .. "：未装備", "", "この部位は未装備です。")
            else
                local trait, traitDescription = GetItemLinkTraitInfo(link)
                local _, enchant, enchantDescription = GetItemLinkEnchantInfo(link)
                local hasSet, setName, bonuses, equipped, maxEquipped, _, perfected = GetItemLinkSetInfo(link, true)
                local quality = GetString("SI_ITEMDISPLAYQUALITY", GetItemLinkDisplayQuality(link))
                -- The *_NONE values name placeholder strings (翻訳しない, "do not translate") that the
                -- game never shows, so a jewel has no armour type line and armour no weapon type.
                local hasTrait = trait and trait ~= (ITEM_TRAIT_TYPE_NONE or 0)
                -- Two blocks, shown side by side: the item itself, and its set. The item name is
                -- already the description's title, so it is not repeated here.
                local detail = {}
                if hasTrait then detail[#detail + 1] = "特性：" .. GetString("SI_ITEMTRAITTYPE", trait) .. "　" .. (traitDescription or "") end
                if enchant and enchant ~= "" then detail[#detail + 1] = "付呪：" .. clean(enchant) .. "　" .. (enchantDescription or "") end
                -- Short facts share one line, each set apart so they cannot read as one word.
                local facts = {quality}
                local cp = GetItemLinkRequiredChampionPoints(link)
                facts[#facts + 1] = cp > 0 and ("CP " .. cp) or ("Lv " .. GetItemLinkRequiredLevel(link))
                facts[#facts + 1] = "状態 " .. number(GetItemCondition(BAG_WORN, id)) .. "%"
                local armor, power = GetItemLinkArmorRating(link, true), GetItemLinkWeaponPower(link)
                if armor > 0 then facts[#facts + 1] = "防御 " .. armor end
                if power > 0 then facts[#facts + 1] = "武器威力 " .. power end
                local armorType, weaponType = GetItemLinkArmorType(link), GetItemLinkWeaponType(link)
                if armorType and armorType ~= (ARMORTYPE_NONE or 0) then facts[#facts + 1] = GetString("SI_ARMORTYPE", armorType) end
                if weaponType and weaponType ~= (WEAPONTYPE_NONE or 0) then facts[#facts + 1] = GetString("SI_WEAPONTYPE", weaponType) end
                if DoesItemLinkHaveEnchantCharges(link) then
                    facts[#facts + 1] = "チャージ " .. GetItemLinkNumEnchantCharges(link) .. "/" .. GetItemLinkMaxEnchantCharges(link)
                end
                detail[#detail + 1] = table.concat(facts, "　／　")
                local setDetail
                if hasSet then
                    -- As the game's own tooltip (ZO_Tooltip:AddSet): the bonus text already carries its
                    -- item count, and a bonus not yet reached is drawn dimmed.
                    local total = math.min(equipped + (perfected or 0), maxEquipped)
                    setDetail = {"セット効果：" .. clean(setName) .. string.format("（%d/%d）", total, maxEquipped)}
                    for i = 1, bonuses do
                        local required, description, perfectedBonus = GetItemLinkSetBonusInfo(link, true, i)
                        if not (description:find("^%(") or description:find("^（")) then description = "(" .. required .. ") " .. description end
                        local active = (perfectedBonus and (perfected or 0) or total) >= required
                        setDetail[#setDetail + 1] = active and description or ("|c9EA6B0" .. description .. "|r")
                    end
                end
                row(rows, slot[1], slot[2] .. "：" .. clean(GetItemLinkName(link)), "", table.concat(detail, "\n"), GetItemInfo(BAG_WORN, id))
                local entry = rows[#rows]
                entry.detailSet = setDetail and table.concat(setDetail, "\n")
                entry.itemName = clean(GetItemLinkName(link))
                entry.quality = GetItemLinkDisplayQuality(link)
                entry.level = cp > 0 and ("CP " .. cp) or ("Lv " .. GetItemLinkRequiredLevel(link))
                -- Armour weight (軽装・中装・重装) first, then trait and enchantment. Weapons and
                -- jewellery have no armour type and start with the trait.
                local subline = {}
                if armorType and armorType ~= (ARMORTYPE_NONE or 0) then subline[#subline + 1] = GetString("SI_ARMORTYPE", armorType) end
                if hasTrait then subline[#subline + 1] = GetString("SI_ITEMTRAITTYPE", trait) end
                if enchant and enchant ~= "" then subline[#subline + 1] = clean(enchant) end
                entry.subline = table.concat(subline, "　")
                entry.setText = hasSet and ("Set " .. (equipped + (perfected or 0)) .. "/" .. maxEquipped) or ""
            end
            rows[#rows].slotLabel = slot[2]
        end
    end
    return rows
end

-- The numbers the header band shows: maximums, regeneration, the combat table and attribute
-- points. They are listed nowhere else, so a value appears on screen exactly once.
function D.Basics()
    local values = {}
    for _, key in ipairs({"HEALTH_MAX", "MAGICKA_MAX", "STAMINA_MAX", "HEALTH_REGEN_COMBAT", "MAGICKA_REGEN_COMBAT",
        "STAMINA_REGEN_COMBAT", "POWER", "SPELL_POWER", "CRITICAL_STRIKE", "SPELL_CRITICAL",
        "PHYSICAL_PENETRATION", "SPELL_PENETRATION", "PHYSICAL_RESIST", "SPELL_RESIST"}) do
        local id = _G["STAT_" .. key]
        if id then values[key] = GetPlayerStat(id, STAT_BONUS_OPTION_APPLY_BONUS) end
    end
    for _, key in ipairs({"HEALTH", "MAGICKA", "STAMINA"}) do
        values["attr" .. key] = GetAttributeSpentPoints(_G["ATTRIBUTE_" .. key])
    end
    return values
end

-- A critical rating with the chance it gives, as the game's own stats screen converts it.
function D.Critical(rating)
    if not rating then return "—" end
    if not GetCriticalStrikeChance then return number(rating) end
    return number(rating) .. string.format(" (%.1f%%)", GetCriticalStrikeChance(rating))
end

-- Everything from the first advanced category (コアアビリティ) on, and every active effect.
function D.Stats()
    local rows = {}
    for c = 1, GetNumAdvancedStatCategories() do
        local category = GetAdvancedStatsCategoryId(c)
        local name, count = GetAdvancedStatCategoryInfo(category)
        header(rows, "category" .. category, name)
        for i = 1, count do
            local stat, label, description, flatDescription, percentDescription = GetAdvancedStatInfo(category, i)
            local format, flat, percent = GetAdvancedStatValue(stat)
            local value = number(flat)
            if format == ADVANCED_STAT_DISPLAY_FORMAT_PERCENT or format == ADVANCED_STAT_DISPLAY_FORMAT_FLAT_OR_PERCENT then
                value = percent and string.format("%.1f%%", percent) or "—"
            elseif format == ADVANCED_STAT_DISPLAY_FORMAT_FLAT_AND_PERCENT then
                value = number(flat) .. " / " .. (percent and string.format("%.1f%%", percent) or "—")
            end
            row(rows, "stat" .. stat, label, value, table.concat({description or "", flatDescription or "", percentDescription or ""}, "\n"))
        end
    end
    header(rows, "effects", "ムンダス・食事・有効な効果")
    local mundus = {}
    for _, index in ipairs({GetUnitActiveMundusStoneBuffIndices("player")}) do mundus[index] = true end
    for i = 1, GetNumBuffs("player") do
        local name, _, ends, _, stacks, icon, _, _, _, _, ability = GetUnitBuffInfo("player", i)
        local remaining = ends > 0 and ("残り " .. math.max(0, math.ceil(ends - GetFrameTimeSeconds())) .. " 秒") or "時間制限なし"
        row(rows, "buff" .. ability .. ":" .. i, (mundus[i] and "ムンダス：" or "") .. clean(name), stacks > 1 and ("×" .. stacks) or "", remaining .. "\n" .. GetAbilityDescription(ability), icon)
    end
    return rows
end

local function group(rows, key, name, value, detail)
    row(rows, key, name, value, detail or name)
    rows[#rows].header = true
    return rows[#rows]
end

function D.Build(mastery, classLines)
    local rows = {}
    local first, last = GetAssignableChampionBarStartAndEndSlots()
    local order, slots = {}, {}
    for slot = first, last do
        local discipline = GetRequiredChampionDisciplineIdForSlot(slot, HOTBAR_CATEGORY_CHAMPION)
        if not slots[discipline] then slots[discipline] = {}; order[#order + 1] = discipline end
        table.insert(slots[discipline], slot)
    end
    -- gapBefore leaves a blank row between sections; breakBefore starts the next column.
    for n, discipline in ipairs(order) do
        local kind = GetChampionDisciplineType(discipline)
        local title = group(rows, "cpgroup" .. discipline, clean(GetChampionDisciplineName(discipline)), GetNumSpentChampionPoints(discipline))
        title.discipline, title.gapBefore = kind, n > 1
        for _, slot in ipairs(slots[discipline]) do
            local id = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
            if id and id > 0 then
                local points = GetNumPointsSpentOnChampionSkill(id)
                row(rows, "cpslot" .. slot, GetChampionSkillName(id), points, GetChampionSkillDescription(id, points))
            else
                row(rows, "cpslot" .. slot, "スロット " .. (slot - first + 1) .. "：未装備", "", "このスロットにはCPが装備されていません。")
            end
            rows[#rows].discipline = kind
        end
    end

    -- The selected class skill lines head the second column, directly above Class Mastery,
    -- which depends on them.
    classLines = classLines or {}
    group(rows, "classLines", "クラススキルライン", "", "現在選択しているクラススキルラインです。").breakBefore = true
    for n, line in ipairs(classLines) do
        row(rows, "classLine" .. n, line.name, (line.own and "" or "サブ ") .. "R" .. line.rank,
            line.own and "自分のクラスのスキルラインです。" or "サブクラスで選択しているスキルラインです。")
    end
    if #classLines == 0 then row(rows, "classLineNone", "なし", "", "") end

    mastery = mastery or {}
    group(rows, "mastery", "クラスマスタリー", mastery.subclassed and "選択不可" or string.format("取得 %d / 保有 %d", #mastery, mastery.points or 0),
        "クラスマスタリーは、有効なクラススキルラインがすべて自分のクラスのときだけ選択できます。").gapBefore = true
    for n, entry in ipairs(mastery) do
        row(rows, "mastery" .. n, entry.name, "R" .. entry.rank, entry.detail, entry.icon)
    end
    if mastery.subclassed then
        row(rows, "masteryNone", "サブクラス使用中", "", "自分のクラスのスキルラインだけの構成で選択できます。")
    elseif #mastery == 0 then
        row(rows, "masteryNone", (mastery.lines or 0) > 0 and "取得したパッシブなし" or "未解放", "", "")
    end

    group(rows, "mundus", "ムンダス", "").gapBefore = true
    local mundus = {GetUnitActiveMundusStoneBuffIndices("player")}
    for _, i in ipairs(mundus) do
        local name, _, _, _, _, icon, _, _, _, _, ability = GetUnitBuffInfo("player", i)
        row(rows, "mundus" .. i, name, "", GetAbilityDescription(ability), icon)
    end
    if #mundus == 0 then row(rows, "mundusNone", "なし", "", "ムンダスストーンの効果を受けていません。") end

    local curse = GetPlayerCurseType and GetPlayerCurseType() or CURSE_TYPE_NONE
    local curseName = (curse and curse ~= CURSE_TYPE_NONE) and clean(GetString("SI_CURSETYPE", curse)) or "なし"
    group(rows, "curse", "呪い", "").gapBefore = true
    row(rows, "curseType", curseName, "", "吸血症・人狼症の状態です。")
    return rows
end

function D.Champion(showAll)
    local rows, slotted = {}, {}
    rows.disciplines = {}
    local first, last = GetAssignableChampionBarStartAndEndSlots()
    header(rows, "slots", "装備中のCP・12スロット")
    for slot = first, last do
        local id = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
        if id and id > 0 then
            slotted[id] = true
            row(rows, "slot" .. slot, GetChampionSkillName(id), GetNumPointsSpentOnChampionSkill(id), GetChampionSkillDescription(id, GetNumPointsSpentOnChampionSkill(id)))
        else
            row(rows, "slot" .. slot, "スロット " .. (slot - first + 1), "未装備")
        end
        rows[#rows].disciplineId = GetRequiredChampionDisciplineIdForSlot(slot, HOTBAR_CATEGORY_CHAMPION)
    end
    for d = 1, GetNumChampionDisciplines() do
        local discipline = GetChampionDisciplineId(d)
        rows.disciplines[#rows.disciplines + 1] = {
            id = discipline, name = clean(GetChampionDisciplineName(discipline)),
            points = GetNumSpentChampionPoints(discipline), kind = GetChampionDisciplineType(discipline),
        }
        header(rows, "discipline" .. discipline, clean(GetChampionDisciplineName(discipline)) .. "  使用 " .. GetNumSpentChampionPoints(discipline) .. " / 未使用 " .. GetNumUnspentChampionPoints(discipline))
        for s = 1, GetNumChampionDisciplineSkills(d) do
            local id = GetChampionSkillId(d, s)
            local points = GetNumPointsSpentOnChampionSkill(id)
            if showAll or points > 0 then
                local slottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(id))
                local unlocked = WouldChampionSkillNodeBeUnlocked(id, points)
                local state = not unlocked and "未発動" or (slottable and (slotted[id] and "装備中" or "未装備") or "パッシブ")
                local details = state .. "\n" .. GetChampionSkillDescription(id, points) .. "\n" .. GetChampionSkillCurrentBonusText(id, points)
                row(rows, "cp" .. id, "[" .. state .. "] " .. clean(GetChampionSkillName(id)), points .. "/" .. GetChampionSkillMaxPoints(id), details)
            end
        end
    end
    return rows
end

function D.Skills(showAll)
    local rows = {}
    local bars = {{HOTBAR_CATEGORY_PRIMARY, "表バー"}, {HOTBAR_CATEGORY_BACKUP, "裏バー"}}
    local active = GetActiveHotbarCategory()
    if active ~= HOTBAR_CATEGORY_PRIMARY and active ~= HOTBAR_CATEGORY_BACKUP then bars[#bars + 1] = {active, "特殊バー"} end
    for _, bar in ipairs(bars) do
        header(rows, "bar" .. bar[1], bar[2] .. (active == bar[1] and "（使用中）" or ""))
        for slot = 3, 8 do
            local id = GetSlotBoundId(slot, bar[1])
            local description = "未装備"
            if id and id > 0 then
                if GetSlotType(slot, bar[1]) == ACTION_TYPE_CRAFTED_ABILITY then description = GetCraftedAbilityDescription(id)
                else description = GetAbilityDescription(id) end
            end
            row(rows, "bar" .. bar[1] .. ":" .. slot, id and id > 0 and GetSlotName(slot, bar[1]) or "未装備", slot == 8 and "ULT" or tostring(slot - 2), description, GetSlotTexture(slot, bar[1]))
        end
    end
    header(rows, "points", "スキルポイント：未使用 " .. GetAvailableSkillPoints())
    local mastery = {points = 0, lines = 0}
    rows.mastery = mastery
    -- Every class has a Class Mastery line and every one of them reports its own pool of points,
    -- whatever this character can actually use, so nothing here may be summed blindly. Class
    -- Mastery is only selectable while all three active class skill lines are this character's
    -- own class: the client deactivates the mastery lines as soon as one is subclassed
    -- (ZO_SkillsDataManager:DeactivateClassMasterySkillLinesForRespec).
    local masteryLines, activeClasses = {}, {}
    local activeClassLines, ownClassLines = 0, 0
    -- The (up to three) class skill lines currently selected, own class or subclassed.
    local classLines = {}
    rows.classLines = classLines
    for t = 1, GetNumSkillTypes() do
        for l = 1, GetNumSkillLines(t) do
            local lineId = GetSkillLineId(t, l)
            local rank, _, activeLine, discovered, _, _, classMastery = GetSkillLineDynamicInfo(t, l)
            local classId = GetSkillLineClassId and GetSkillLineClassId(t, l) or 0
            local masteryLine
            if classMastery then
                masteryLine = {classId = classId, points = masteryPoints(lineId), entries = {}}
                masteryLines[#masteryLines + 1] = masteryLine
            elseif classId and classId > 0 and activeLine and (not SKILL_TYPE_CLASS or t == SKILL_TYPE_CLASS) then
                activeClasses[classId] = true
                activeClassLines = activeClassLines + 1
                local own = not IsPlayerClassSkillLineById or IsPlayerClassSkillLineById(lineId)
                if own then ownClassLines = ownClassLines + 1 end
                classLines[#classLines + 1] = {name = clean(GetSkillLineNameById(lineId)), rank = rank, own = own}
            end
            -- Class Mastery lines read as undiscovered until a class line is at max rank.
            if discovered or showAll or classMastery then
                local entries = {}
                for s = 1, GetNumSkillAbilities(t, l) do
                    local name, icon, _, passive, ultimate, purchased, _, abilityRank = GetSkillAbilityInfo(t, l, s)
                    if purchased or showAll then
                        local id = GetSkillAbilityId(t, l, s, false)
                        local description
                        if IsCraftedAbilitySkill(t, l, s) then description = GetCraftedAbilityDescription(GetCraftedAbilitySkillCraftedAbilityId(t, l, s))
                        else description = GetAbilityDescription(id) end
                        local kind = passive and "パッシブ" or (ultimate and "ULT" or "アクティブ")
                        row(entries, "skill" .. t .. ":" .. l .. ":" .. s, name, purchased and ("R" .. abilityRank) or "未取得", kind .. (activeLine and "" or " / ライン非アクティブ") .. "\n" .. description, icon)
                        if masteryLine and purchased then
                            masteryLine.entries[#masteryLine.entries + 1] = {name = clean(name), rank = abilityRank, icon = icon, detail = description,
                                line = clean(GetSkillLineNameById(lineId))}
                        end
                    end
                end
                if #entries > 0 then
                    header(rows, "line" .. lineId, clean(GetSkillLineNameById(lineId)) .. "  R" .. rank ..
                        (classMastery and "（クラスマスタリー）" or "") .. (activeLine and "" or "（非アクティブ）"))
                    for _, entry in ipairs(entries) do rows[#rows + 1] = entry end
                end
            end
        end
    end
    mastery.subclassed = ownClassLines < activeClassLines
    if not mastery.subclassed then
        for _, masteryLine in ipairs(masteryLines) do
            if activeClasses[masteryLine.classId] then
                mastery.lines = mastery.lines + 1
                mastery.points = mastery.points + masteryLine.points
                for _, entry in ipairs(masteryLine.entries) do mastery[#mastery + 1] = entry end
            end
        end
    end
    return rows
end

function D.Identity()
    return clean(GetUnitName("player")) .. "   " .. clean(GetUnitRace("player")) .. " / " .. clean(GetUnitClass("player")) ..
        "   Lv " .. GetUnitLevel("player") .. "   CP " .. GetUnitChampionPoints("player") .. "   " .. clean(GetUnitTitle("player"))
end

local function safely(collector, ...)
    local ok, result = pcall(collector, ...)
    if ok then return result end
    return {{key = "error", name = "情報を取得できません", value = "", detail = tostring(result)}}
end

-- Areas: 1 equipment, 2 build summary (both on the first page), 3 detailed statistics,
-- 4 Champion Points, 5 skills. One failing collector never blanks the others.
function D.Collect(showAll)
    local skills = safely(D.Skills, showAll)
    local columns = {safely(D.Equipment), safely(D.Build, skills.mastery, skills.classLines), safely(D.Stats), safely(D.Champion, showAll), skills}
    local ok, basics = pcall(D.Basics)
    columns.basics = ok and basics or {}
    return columns
end
