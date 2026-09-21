local A = ESOBuildTracker

-- Extracted from Cranius_PvP_Addon_Target.xml. No ownership is assumed.
function A.LoadCraniusTarget()
    for _, saved in ipairs(A.saved.builds) do
        if saved.presetKey == "cranius_pvp_v1" then
            A.saved.activeBuildId = saved.id; A.ShowTab(1); A.Notify("Cranius PvP target selected; your edits were preserved."); return saved
        end
    end
    local build, err = A.CreateBuild("Cranius PvP")
    if not build then A.Notify(err); return end
    build.presetKey = "cranius_pvp_v1"
    build.notes = "Rallying Cry / Wretched Vitality / Bloodspawn. Equipped-item comparison only. Glyph targets require confirmation using an actual tooltip heading. Skill morph names are compared; rank is not checked."
    build.gear.head = { status = "equipped", setName = "Bloodspawn", trait = ITEM_TRAIT_TYPE_ARMOR_REINFORCED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Prismatic Defense", armorType = ARMORTYPE_HEAVY }
    build.gear.shoulders = { status = "equipped", setName = "Bloodspawn", trait = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Magicka", armorType = ARMORTYPE_MEDIUM }
    build.gear.chest = { status = "equipped", setName = "Wretched Vitality", trait = ITEM_TRAIT_TYPE_ARMOR_REINFORCED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Prismatic Defense", armorType = ARMORTYPE_HEAVY }
    build.gear.hands = { status = "equipped", setName = "Wretched Vitality", trait = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Magicka", armorType = ARMORTYPE_LIGHT }
    build.gear.waist = { status = "equipped", setName = "Wretched Vitality", trait = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Magicka", armorType = ARMORTYPE_LIGHT }
    build.gear.legs = { status = "equipped", setName = "Wretched Vitality", trait = ITEM_TRAIT_TYPE_ARMOR_REINFORCED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Prismatic Defense", armorType = ARMORTYPE_HEAVY }
    build.gear.feet = { status = "equipped", setName = "Wretched Vitality", trait = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Magicka", armorType = ARMORTYPE_MEDIUM }
    build.gear.neck = { status = "equipped", setName = "Rallying Cry", trait = ITEM_TRAIT_TYPE_JEWELRY_INFUSED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Increase Magical Harm" }
    build.gear.ring1 = { status = "equipped", setName = "Rallying Cry", trait = ITEM_TRAIT_TYPE_JEWELRY_INFUSED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Increase Magical Harm" }
    build.gear.ring2 = { status = "equipped", setName = "Rallying Cry", trait = ITEM_TRAIT_TYPE_JEWELRY_INFUSED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Magicka Recovery" }
    build.gear.frontMain = { status = "equipped", setName = "Rallying Cry", trait = ITEM_TRAIT_TYPE_WEAPON_SHARPENED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Flame", weaponType = WEAPONTYPE_FIRE_STAFF }
    build.gear.backMain = { status = "equipped", setName = "Rallying Cry", trait = ITEM_TRAIT_TYPE_WEAPON_POWERED, quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT, requiredCP = 160, requiredLevel = 50, enchantGlyph = "Glyph of Weapon Damage", weaponType = WEAPONTYPE_HEALING_STAFF }
    build.gear.frontOff = { status = "empty" }
    build.gear.backOff = { status = "empty" }
    build.gear.frontPoison = { status = "empty" }
    build.gear.backPoison = { status = "empty" }
    build.skills[1][1] = { status = "slotted", name = "Escalating Runeblades" }
    build.skills[1][2] = { status = "slotted", name = "Elemental Susceptibility" }
    build.skills[1][3] = { status = "slotted", name = "Destructive Clench", alternateName = "Flame Clench" }
    build.skills[1][4] = { status = "slotted", name = "Radiant Oppression" }
    build.skills[1][5] = { status = "slotted", name = "Inspired Scholarship" }
    build.skills[1][6] = { status = "slotted", name = "The Tide King's Gaze" }
    build.skills[2][1] = { status = "slotted", name = "Honor the Dead" }
    build.skills[2][2] = { status = "slotted", name = "Extended Ritual" }
    build.skills[2][3] = { status = "slotted", name = "Channeled Focus" }
    build.skills[2][4] = { status = "slotted", name = "Resolving Vigor" }
    build.skills[2][5] = { status = "slotted", name = "Race Against Time" }
    build.skills[2][6] = { status = "slotted", name = "Life Giver" }
    A.ShowTab(1)
    A.Notify("PvP target loaded. Builds > Still needed lists unmet requirements.")
    return build
end

function A.ShowStillNeeded()
    local build, snapshot = A.ActiveBuild(), A.GetViewedSnapshot()
    if not build or not snapshot then A.Notify("Select a target and refresh first."); return end
    local rows, oldTab = {}, A.tabIndex
    for tab = 1, 2 do
        A.tabIndex = tab
        for _, row in ipairs(A.TabRows()) do
            if row.status ~= "Match" and row.status ~= "Untracked" then rows[#rows + 1] = row end
        end
    end
    A.tabIndex = oldTab
    if #rows == 0 then rows[1] = A.Row("All tracked slots match", "Equipped gear and slotted skills", "This does not check bank ownership, glyph strength or skill rank.") end
    A.OpenMenu("Still needed - " .. build.name, rows)
end
