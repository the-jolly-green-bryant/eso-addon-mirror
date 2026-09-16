PBsSuperStar = { name = "PBsSuperStar", sceneName = "pbsSuperStar", title = "PB'S SUPERSTAR" }
local P = PBsSuperStar
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
                local detail = { link, quality .. "  Lv " .. GetItemLinkRequiredLevel(link) .. " / CP " .. GetItemLinkRequiredChampionPoints(link),
                    "特性：" .. GetString("SI_ITEMTRAITTYPE", trait) .. "  " .. (traitDescription or ""),
                    (enchant or "") .. "  " .. (enchantDescription or ""),
                    "状態：" .. number(GetItemCondition(BAG_WORN, id)) .. "%",
                    "防御 " .. GetItemLinkArmorRating(link, true) .. " / 武器威力 " .. GetItemLinkWeaponPower(link),
                    GetString("SI_ARMORTYPE", GetItemLinkArmorType(link)) .. "  " .. GetString("SI_WEAPONTYPE", GetItemLinkWeaponType(link)) }
                if DoesItemLinkHaveEnchantCharges(link) then
                    detail[#detail + 1] = "付呪チャージ：" .. GetItemLinkNumEnchantCharges(link) .. "/" .. GetItemLinkMaxEnchantCharges(link)
                end
                if hasSet then
                    detail[#detail + 1] = "セット：" .. clean(setName) .. "（通常 " .. equipped .. " / 完全 " .. (perfected or 0) .. "）"
                    for i = 1, bonuses do
                        local required, description = GetItemLinkSetBonusInfo(link, true, i)
                        detail[#detail + 1] = "(" .. required .. ") " .. description
                    end
                end
                row(rows, slot[1], slot[2] .. "：" .. clean(GetItemLinkName(link)), "", table.concat(detail, "\n"), GetItemInfo(BAG_WORN, id))
                local entry = rows[#rows]
                entry.itemName = clean(GetItemLinkName(link))
                entry.quality = GetItemLinkDisplayQuality(link)
                local cp = GetItemLinkRequiredChampionPoints(link)
                entry.level = cp > 0 and ("CP " .. cp) or ("Lv " .. GetItemLinkRequiredLevel(link))
                entry.subline = GetString("SI_ITEMTRAITTYPE", trait) .. "   " .. clean(enchant)
                entry.setText = hasSet and ("Set " .. (equipped + (perfected or 0)) .. "/" .. maxEquipped) or ""
            end
            rows[#rows].slotLabel = slot[2]
        end
    end
    return rows
end

function D.Stats()
    local rows = {}
    local basics = {
        {"HEALTH_MAX", "最大体力"}, {"MAGICKA_MAX", "最大マジカ"}, {"STAMINA_MAX", "最大スタミナ"},
        {"HEALTH_REGEN_COMBAT", "体力再生（戦闘）"}, {"MAGICKA_REGEN_COMBAT", "マジカ再生（戦闘）"},
        {"STAMINA_REGEN_COMBAT", "スタミナ再生（戦闘）"}, {"POWER", "武器ダメージ"}, {"SPELL_POWER", "呪文ダメージ"},
        {"CRITICAL_STRIKE", "武器クリティカル値"}, {"SPELL_CRITICAL", "呪文クリティカル値"},
        {"PHYSICAL_PENETRATION", "物理貫通"}, {"SPELL_PENETRATION", "呪文貫通"},
        {"PHYSICAL_RESIST", "物理耐性"}, {"SPELL_RESIST", "呪文耐性"},
    }
    for _, stat in ipairs(basics) do
        local id = _G["STAT_" .. stat[1]]
        if id then row(rows, stat[1], stat[2], number(GetPlayerStat(id, STAT_BONUS_OPTION_APPLY_BONUS)), "現在の武器バー・有効な効果を反映した値です。クリティカル値はレーティングです。") end
    end
    header(rows, "attributes", "能力ポイント")
    for _, a in ipairs({{"HEALTH", "体力"}, {"MAGICKA", "マジカ"}, {"STAMINA", "スタミナ"}}) do
        row(rows, "attr" .. a[1], a[2], GetAttributeSpentPoints(_G["ATTRIBUTE_" .. a[1]]))
    end
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
    for t = 1, GetNumSkillTypes() do
        for l = 1, GetNumSkillLines(t) do
            local lineId = GetSkillLineId(t, l)
            local rank, _, activeLine, discovered = GetSkillLineDynamicInfo(t, l)
            if discovered or showAll then
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
                    end
                end
                if #entries > 0 then
                    header(rows, "line" .. lineId, clean(GetSkillLineNameById(lineId)) .. "  R" .. rank .. (activeLine and "" or "（非アクティブ）"))
                    for _, entry in ipairs(entries) do rows[#rows + 1] = entry end
                end
            end
        end
    end
    return rows
end

function D.Identity()
    return clean(GetUnitName("player")) .. "   " .. clean(GetUnitRace("player")) .. " / " .. clean(GetUnitClass("player")) ..
        "   Lv " .. GetUnitLevel("player") .. "   CP " .. GetUnitChampionPoints("player") .. "   " .. clean(GetUnitTitle("player"))
end

function D.Collect(showAll)
    local columns = {}
    for i, collector in ipairs({D.Equipment, D.Stats, D.Champion, D.Skills}) do
        local ok, result = pcall(collector, showAll)
        if ok then columns[i] = result else
            columns[i] = {{key = "error", name = "情報を取得できません", value = "", detail = tostring(result)}}
        end
    end
    return columns
end
