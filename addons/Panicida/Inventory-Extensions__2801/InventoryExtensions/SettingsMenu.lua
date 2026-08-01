local IE = InventoryExtensions
local LAM = LibAddonMenu2
local LS = LibSets

IE.SettingsMenu = {}

function IE.SettingsMenu.Init()
    local saveData = IE.SavedVars -- TODO this should be a reference to your actual saved variables table
    local panelName = IE.name.."_SettingsPanel" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!

    local qualityChoices = {}
    local invertQualityChoices = {}
	for i = 0, ITEM_QUALITY_ARTIFACT do
		local color = GetItemQualityColor(i)
		local qualityName = color:Colorize(GetString("SI_ITEMQUALITY", i))
        qualityChoices[i] = qualityName
        invertQualityChoices[qualityName] = i
    end

    local monsterSets = {}
    local dungeonSets = {}
    local trialSets = {}
    local arenaSets = {}
    local overlandSets = {}
    local cyrodiilSets = {}
    local battlegroundSets = {}
    local imperialCitySets = {}
    local specialSets = {}

    local setIds = LS.GetAllSetIds()
    for setId, isActive in pairs(setIds) do
        if isActive then
            local control = {
                type = "checkbox",
                name = LS.GetSetName(setId),
                getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludedSets[setId] or false end,
                setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludedSets[setId] = value or nil end
            }

            if LS.IsMonsterSet(setId) then
                table.insert(monsterSets, control)
            elseif LS.IsDungeonSet(setId) then
                table.insert(dungeonSets, control)
            elseif LS.IsTrialSet(setId) then
                table.insert(trialSets, control)
            elseif LS.IsArenaSet(setId) then
                table.insert(arenaSets, control)
            elseif LS.IsOverlandSet(setId) then
                table.insert(overlandSets, control)
            elseif LS.IsCyrodiilSet(setId) then
                table.insert(cyrodiilSets, control)
            elseif LS.IsBattlegroundSet(setId) then
                table.insert(battlegroundSets, control)
            elseif LS.IsImperialCitySet(setId) then
                table.insert(imperialCitySets, control)
            elseif LS.IsSpecialSet(setId) then
                table.insert(specialSets, control)
            end
        end
    end

    local ignoredConsumibles = {}
    for itemInstanceId, linkName in pairs (saveData.autoJunk.ignored) do
        local control = {
            type = "checkbox",
            name = linkName,
            getFunc = function() return saveData.autoJunk.ignored[itemInstanceId] ~= nil end,
            setFunc = function(value) saveData.autoJunk.ignored[itemInstanceId] = (value and linkName) or nil end
        }
        table.insert(ignoredConsumibles, control)
    end

    local panelData = {
        type = "panel",
        name = "Inventory Extensions",
        author = "Panicida",
    }
    local optionsData = {
        {
            type = "description",
            text = IE.Loc("Settings_GlobalSettings")
        },
        {
            type = "submenu",
            name = IE.Loc("Settings_WeaponsArmorsJewelry"),
            controls = {
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_MarkWeaponsArmorsJewelry"),
                    getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.enabled end,
                    setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.enabled = value end
                },
                {
                    type = "dropdown",
                    name = IE.Loc("Settings_ArmorWeaponQuality"),
                    tooltip = IE.Loc("Settings_QualityTooltip"),
                    choices = qualityChoices,
                    getFunc = function() return qualityChoices[saveData.autoJunk.weaponsArmorJewelry.armorWeaponQuality] end,
                    setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.armorWeaponQuality = invertQualityChoices[value] end,
                },
                {
                    type = "dropdown",
                    name = IE.Loc("Settings_JewelryQuality"),
                    tooltip = IE.Loc("Settings_QualityTooltip"),
                    choices = qualityChoices,
                    getFunc = function() return qualityChoices[saveData.autoJunk.weaponsArmorJewelry.jewelryQuality] end,
                    setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.jewelryQuality = invertQualityChoices[value] end,
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_ExcludeResearchableItems"),
                    getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeResearchable end,
                    setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeResearchable = value end
                },
                {
                    type = "divider"
                },
                {
                    type = "description",
                    text = IE.Loc("Settings_ExcludeTraits")
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_Armors"),
                    controls = {
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorIntrincate"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorDivine"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_DIVINES] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorImpenetrable"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorInfused"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_INFUSED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorNirnhoned"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorProsperous"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorReinforced"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorSturdy"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_STURDY] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_STURDY] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorTraining"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_TRAINING] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitArmorWellFitted"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = value end
                        }
                    }
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_Weapons"),
                    controls = {
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponIntrincate"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponCharged"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_CHARGED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponDecisive"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponDefending"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponInfused"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_INFUSED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponNirnhoned"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponPowered"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_POWERED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_POWERED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponPrecise"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_PRECISE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponSharpened"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitWeaponTraning"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_TRAINING] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = value end
                        }
                    }
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_Jewelry"),
                    controls = {
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryIntrincate"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryArcane"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryBloodthirsty"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryHarmony"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryHealthy"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryInfused"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryProtective"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryRobust"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelrySwift"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = value end
                        },
                        {
                            type = "checkbox",
                            name = IE.Loc("Settings_TraitJewelryTriune"),
                            getFunc = function() return saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] end,
                            setFunc = function(value) saveData.autoJunk.weaponsArmorJewelry.excludeTrait[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = value end
                        }
                    }
                },
                {
                    type = "divider"
                },
                {
                    type = "description",
                    text = IE.Loc("Settings_ExcludeSets")
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_MonsterSets"),
                    controls = monsterSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_DungeonSets"),
                    controls = dungeonSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_TrialSets"),
                    controls = trialSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_ArenaSets"),
                    controls = arenaSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_OverlandSets"),
                    controls = overlandSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_CyrodiilSets"),
                    controls = cyrodiilSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_BattlegroundSets"),
                    controls = battlegroundSets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_ImperialCitySets"),
                    controls = imperialCitySets
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_SpecialSets"),
                    controls = specialSets
                },
                -- { NEVER MARK MYTHICS
                --     type = "submenu",
                --     name = IE.Loc("Settings_MythicSets"),
                --     controls = mythicSets
                -- }
            }
        },
        {
            type = "submenu",
            name = IE.Loc("Settings_Consumibles"),
            controls = {
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_FoodAndDrinks"),
                    getFunc = function() return saveData.autoJunk.consumibles.foodAndDrinks end,
                    setFunc = function(value) saveData.autoJunk.consumibles.foodAndDrinks = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_PotionsAndPoisons"),
                    getFunc = function() return saveData.autoJunk.consumibles.potionsAndPoisons end,
                    setFunc = function(value) saveData.autoJunk.consumibles.potionsAndPoisons = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_JunkIgnoreCrafted"),
                    getFunc = function() return saveData.autoJunk.consumibles.ignoreCrafted end,
                    setFunc = function(value) saveData.autoJunk.consumibles.ignoreCrafted = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_JunkIgnoreBound"),
                    getFunc = function() return saveData.autoJunk.consumibles.ignoreBound end,
                    setFunc = function(value) saveData.autoJunk.consumibles.ignoreBound = value end
                },
                {
                    type = "submenu",
                    name = IE.Loc("Settings_IgnoredItems"),
                    controls = ignoredConsumibles
                },
            }
        },
        {
            type = "submenu",
            name = IE.Loc("Settings_Miscellaneous"),
            controls = {
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_MarkMonsterTrophies"),
                    getFunc = function() return saveData.autoJunk.miscellaneous.monsterTropies end,
                    setFunc = function(value) saveData.autoJunk.miscellaneous.monsterTropies = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_MarkTreasures"),
                    getFunc = function() return saveData.autoJunk.miscellaneous.treasures end,
                    setFunc = function(value) saveData.autoJunk.miscellaneous.treasures = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_MarkTreasureMaps"),
                    getFunc = function() return saveData.autoJunk.miscellaneous.treasureMaps end,
                    setFunc = function(value) saveData.autoJunk.miscellaneous.treasureMaps = value end
                },
                {
                    type = "checkbox",
                    name = IE.Loc("Settings_MarkTrash"),
                    getFunc = function() return saveData.autoJunk.miscellaneous.trash end,
                    setFunc = function(value) saveData.autoJunk.miscellaneous.trash = value end
                },
            },
        }
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsData)
end