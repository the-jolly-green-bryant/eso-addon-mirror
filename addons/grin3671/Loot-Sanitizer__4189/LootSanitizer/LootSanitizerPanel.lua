function LootSanitizer:AddSettingsMenu (defaults)
  local panelName = "LootSanitizerSettings"

  -- MAIN HEADER
  self.settingsPanel = LibAddonMenu2:RegisterAddonPanel(panelName, {
    type = "panel",
    name = self.name,
    version = self.version,
    author = self.author,
    slashCommand = "/lss",
  })

  -- itemLinks are provided for examples in descriptions
  --item quality colorized names
  local ITEM_Q1 = GetItemQualityColor(1):Colorize(GetString("SI_ITEMDISPLAYQUALITY", 1)) -- white
  local ITEM_Q2 = GetItemQualityColor(2):Colorize(GetString("SI_ITEMDISPLAYQUALITY", 2)) -- green
  local ITEM_Q3 = GetItemQualityColor(3):Colorize(GetString("SI_ITEMDISPLAYQUALITY", 3)) -- blue
  local ITEM_Q4 = GetItemQualityColor(4):Colorize(GetString("SI_ITEMDISPLAYQUALITY", 4)) -- purple
  -- gray trash
  local FINGERLESS_GAUNTLETS = "|H1:item:64057:1:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"
  local SPOILED_FOOD = "|H0:item:57660:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  -- craft
  local RUNE_HAKEIJO = "|H0:item:68342:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  local RUNE_INDEKO = "|H0:item:166045:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  local RUNE_RAKEIPA = "|H0:item:45838:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  local RUNE_OKO = "|H0:item:45831:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  local RUNE_MAKKO = "|H0:item:45832:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  local RUNE_DENI = "|H0:item:45833:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
  -- gold icon
  local goldIcon = zo_iconFormat(ZO_CURRENCIES_DATA[CURT_MONEY].gamepadTexture, ZO_CURRENCIES_DATA[CURT_MONEY].gamepadPercentOfLineSize, ZO_CURRENCIES_DATA[CURT_MONEY].gamepadPercentOfLineSize)
  -- colorized text
  local function ColorText(hex, text)
    return "|c" .. hex .. text .. "|r"
  end
  -- insert gold icon
  local function FormattedPrice(text)
    return zo_strformat("|r<<1>> <<2>>|cc5c29e", ColorText("ffffff", tostring(text)), goldIcon)
  end


  -- TODO: Auto Burned Items List
  local RemoveList = {}
  local RemoveListControl = nil
  RemoveList.Setup = function(list)
    d(list)
  end
  local function InitializeList(control, ...)
    RemoveList.control = WINDOW_MANAGER:CreateControl("RemoveListControl", control, CT_CONTROL)
    RemoveList.control:SetAnchorFill()
    RemoveList.backdrop = WINDOW_MANAGER:CreateControlFromVirtual("RemoveListControlBg", RemoveList.control, "ZO_DefaultBackdrop")
    RemoveList.backdrop:SetAnchorFill()
  end

  local optionsData = {
    {
      type = "description",
      text = GetString(LOOTSANITIZER_WARNING),
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_WORKMODE_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_WORKMODE_CONTROL_NO),
        GetString(LOOTSANITIZER_WORKMODE_CONTROL_AUTOLOOT),
        GetString(LOOTSANITIZER_WORKMODE_CONTROL_ALWAYS)
      },
      choicesValues = {0, 1, 2},
      default = defaults.workMode,
      getFunc = function() return self.settings.workMode end,
      setFunc = function(value) self.settings.workMode = value end,
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_CHAT_NOTIFY),
      choices = {
        GetString(LOOTSANITIZER_CHAT_NOTIFY_NO),
        GetString(LOOTSANITIZER_CHAT_NOTIFY_DELETE),
        GetString(LOOTSANITIZER_CHAT_NOTIFY_DEV)
      },
      choicesValues = {0, 1, 2},
      default = defaults.chatMode,
      getFunc = function() return self.settings.chatMode end,
      setFunc = function(value) self.settings.chatMode = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_SOUND_CONTROL),
      default = defaults.playSound,
      getFunc = function() return self.settings.playSound end,
      setFunc = function(value) self.settings.playSound = value end,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_armor_up.dds|t " .. GetString(LOOTSANITIZER_EQUIPMENT_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_EQUIPMENT_CONTROL),
      default = defaults.burnEquipment,
      getFunc = function() return self.settings.burnEquipment end,
      setFunc = function(value) self.settings.burnEquipment = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. zo_strformat(GetString(LOOTSANITIZER_EQUIPMENT_DESCRIPTION), FormattedPrice("1")) .. "|r\n",
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_SIMPLECLOTHES_CONTROL),
      default = defaults.burnEquipment,
      getFunc = function() return self.settings.burnSimpleClothes end,
      setFunc = function(value) self.settings.burnSimpleClothes = value end,
    },
    {
      type = "description",
      text = ColorText("c5c29e", zo_strformat(GetString(LOOTSANITIZER_SIMPLECLOTHES_DESCRIPTION), FormattedPrice("10"), FINGERLESS_GAUNTLETS)),
      enableLinks = true,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    -- SETS ITEMS
    {
      type = "header",
      name = "|t36:36:EsoUI/Art/Collections/collections_tabIcon_itemSets_up.dds|t " .. GetString(LOOTSANITIZER_SETS_HEADER),
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_SETS_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_SETS_CONTROL_NO),
        zo_strformat(GetString(LOOTSANITIZER_SETS_CONTROL_GREEN), ITEM_Q2),
        zo_strformat(GetString(LOOTSANITIZER_SETS_CONTROL_BLUE), ITEM_Q3),
        zo_strformat(GetString(LOOTSANITIZER_SETS_CONTROL_PURPLE), ITEM_Q4)
      },
      choicesValues = {0, 2, 3, 4},
      default = defaults.autoBindQuality,
      getFunc = function() return self.settings.autoBindQuality end,
      setFunc = function(value) self.settings.autoBindQuality = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_SETS_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    -- COMPANION ITEMS
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_companion_up.dds:inheritcolor|t " .. GetString(LOOTSANITIZER_COMPANION_HEADER),
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_COMPANION_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_COMPANION_CONTROL_NO),
        zo_strformat(GetString(LOOTSANITIZER_COMPANION_CONTROL_WHITE), ITEM_Q1),
        zo_strformat(GetString(LOOTSANITIZER_COMPANION_CONTROL_GREEN), ITEM_Q2),
        zo_strformat(GetString(LOOTSANITIZER_COMPANION_CONTROL_BLUE), ITEM_Q3)
      },
      choicesValues = {0, 1, 2, 3},
      default = defaults.burnCompanionItems,
      getFunc = function() return self.settings.burnCompanionItems end,
      setFunc = function(value) self.settings.burnCompanionItems = value end,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    -- MATERIALS
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_Craftbag_styleMaterial_up.dds:inheritcolor|t " .. GetString(LOOTSANITIZER_MATERIALMOTIF_HEADER),
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_MATERIAL_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_MATERIAL_CONTROL_NO),
        GetString(LOOTSANITIZER_MATERIAL_CONTROL_COMMON),
        GetString(LOOTSANITIZER_MATERIAL_CONTROL_RARE)
      },
      choicesValues = {0, 1, 2},
      default = defaults.burnRaceMaterial,
      getFunc = function() return self.settings.burnRaceMaterial end,
      setFunc = function(value) self.settings.burnRaceMaterial = value end,
    },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_MOTIF_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_MOTIF_CONTROL_NO),
        GetString(LOOTSANITIZER_MOTIF_CONTROL_COMMON),
        GetString(LOOTSANITIZER_MOTIF_CONTROL_RARE)
      },
      choicesValues = {0, 1, 2},
      default = defaults.burnRaceMotif,
      getFunc = function() return self.settings.burnRaceMotif end,
      setFunc = function(value) self.settings.burnRaceMotif = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_MOTIFLEARN_CONTROL),
      tooltip = GetString(LOOTSANITIZER_MOTIFLEARN_CONTROL_TOOLTIP),
      default = defaults.autoLearnRaceMotif,
      getFunc = function() return self.settings.autoLearnRaceMotif end,
      setFunc = function(value) self.settings.autoLearnRaceMotif = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_MATERIALMOTIF_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_MATERIALSTOP_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_Craftbag_itemTrait_up.dds|t " .. GetString(LOOTSANITIZER_TRAIT_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_TRAIT_CONTROL),
      tooltip = GetString(LOOTSANITIZER_TRAIT_CONTROL_TOOLTIP),
      default = defaults.burnTraitMaterial,
      getFunc = function() return self.settings.burnTraitMaterial end,
      setFunc = function(value) self.settings.burnTraitMaterial = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_TRAIT_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_Craftbag_provisioning_up.dds|t " .. GetString(LOOTSANITIZER_INGREDIENT_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_INGREDIENT_CONTROL),
      tooltip = GetString(LOOTSANITIZER_INGREDIENT_CONTROL_TOOLTIP),
      default = defaults.burnIngredient,
      getFunc = function() return self.settings.burnIngredient end,
      setFunc = function(value) self.settings.burnIngredient = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_INGREDIENT_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_tool_up.dds|t " .. GetString(LOOTSANITIZER_LOCKPICK_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_LOCKPICK_CONTROL),
      default = defaults.burnLockpick,
      getFunc = function() return self.settings.burnLockpick end,
      setFunc = function(value) self.settings.burnLockpick = value end,
    },
    {
      type = "slider",
      name = GetString(LOOTSANITIZER_LOCKPICK_SLIDER),
      tooltip = GetString(LOOTSANITIZER_LOCKPICK_SLIDER_TOOLTIP),
      min = 0,
      max = 20,
      default = defaults.burnLockpickStackSaved,
      getFunc = function() return self.settings.burnLockpickStackSaved end,
      setFunc = function(value) self.settings.burnLockpickStackSaved = value end,
      disabled = function() return self.settings.burnLockpick == false end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_LOCKPICK_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_bait_up.dds|t " .. GetString(LOOTSANITIZER_BAIT_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_BAIT_CONTROL),
      default = defaults.burnBait,
      getFunc = function() return self.settings.burnBait end,
      setFunc = function(value) self.settings.burnBait = value end,
    },
    {
      type = "slider",
      name = GetString(LOOTSANITIZER_BAIT_SLIDER),
      tooltip = GetString(LOOTSANITIZER_BAIT_SLIDER_TOOLTIP),
      min = 0,
      max = 20,
      default = defaults.burnBaitStackSaved,
      getFunc = function() return self.settings.burnBaitStackSaved end,
      setFunc = function(value) self.settings.burnBaitStackSaved = value end,
      disabled = function() return self.settings.burnBait == false end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_BAIT_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/TradingHouse/Tradinghouse_Glyphs_Trio_up.dds|t " .. GetString(LOOTSANITIZER_GLYPH_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_GLYPH_CONTROL),
      default = defaults.burnCommonGlyph,
      getFunc = function() return self.settings.burnCommonGlyph end,
      setFunc = function(value) self.settings.burnCommonGlyph = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_GLYPH_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds|t " .. GetString(LOOTSANITIZER_RUNE_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_RUNE_POTENCY_CONTROL),
      default = defaults.burnRunePotency,
      getFunc = function() return self.settings.burnRunePotency end,
      setFunc = function(value) self.settings.burnRunePotency = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_RUNE_ESSENCE_CONTROL),
      default = defaults.burnRuneEssence,
      getFunc = function() return self.settings.burnRuneEssence end,
      setFunc = function(value) self.settings.burnRuneEssence = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_RUNE_DAILY_CONTROL),
      default = defaults.saveRuneEssenceForDaily,
      getFunc = function() return self.settings.saveRuneEssenceForDaily end,
      setFunc = function(value) self.settings.saveRuneEssenceForDaily = value end,
      disabled = function() return not self.settings.burnRuneEssence end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. zo_strformat(GetString(LOOTSANITIZER_RUNE_DESCRIPTION), RUNE_HAKEIJO, RUNE_INDEKO, RUNE_RAKEIPA, RUNE_OKO, RUNE_MAKKO, RUNE_DENI) .. "|r",
      enableLinks = true,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t " .. GetString(LOOTSANITIZER_TRASH_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_TRASH_CONTROL),
      default = defaults.burnJunk,
      getFunc = function() return self.settings.burnJunk end,
      setFunc = function(value) self.settings.burnJunk = value end,
    },
    {
      type = "description",
      text = "|cc5c29e" .. zo_strformat(GetString(LOOTSANITIZER_TRASH_DESCRIPTION), FormattedPrice("1"), SPOILED_FOOD) .. "|r",
      enableLinks = true,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_junk_up.dds|t " .. GetString(LOOTSANITIZER_JUNK_HEADER),
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_JUNK_DESCRIPTION) .. "|r",
    },
    -- {
    --   type = "checkbox",
    --   name = GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL),
    --   tooltip = GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_TOOLTIP),
    --   default = defaults.junkNormalEquipment,
    --   getFunc = function() return self.settings.junkNormalEquipment end,
    --   setFunc = function(value) self.settings.junkNormalEquipment = value end,
    -- },
    {
      type = "dropdown",
      name = GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL),
      choices = {
        GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_OFF),
        zo_strformat(GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_NORMAL), ITEM_Q1),
        zo_strformat(GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_UNCOMMON), ITEM_Q2),
        zo_strformat(GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_RARE), ITEM_Q3),
        zo_strformat(GetString(LOOTSANITIZER_JUNK_COMMON_CONTROL_EPIC), ITEM_Q4)
      },
      choicesValues = {0, 1, 2, 3, 4},
      default = defaults.junkNormalEquipmentQuality,
      getFunc = function() return self.settings.junkNormalEquipmentQuality end,
      setFunc = function(value) self.settings.junkNormalEquipmentQuality = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_ORNATE_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_ORNATE_CONTROL_TOOLTIP),
      default = defaults.junkOrnateEquipment,
      getFunc = function() return self.settings.junkOrnateEquipment end,
      setFunc = function(value) self.settings.junkOrnateEquipment = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_MIDDLE_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_MIDDLE_CONTROL_TOOLTIP),
      default = defaults.junkMiddleRawAndMaterial,
      getFunc = function() return self.settings.junkMiddleRawAndMaterial end,
      setFunc = function(value) self.settings.junkMiddleRawAndMaterial = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_NOCRPT_CONTROL),
      default = defaults.junkNotCraftedPotion,
      getFunc = function() return self.settings.junkNotCraftedPotion end,
      setFunc = function(value) self.settings.junkNotCraftedPotion = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_NOCRPS_CONTROL),
      default = defaults.junkNotCraftedPoison,
      getFunc = function() return self.settings.junkNotCraftedPoison end,
      setFunc = function(value) self.settings.junkNotCraftedPoison = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_NOCRFD_CONTROL),
      default = defaults.junkNotCraftedFood,
      getFunc = function() return self.settings.junkNotCraftedFood end,
      setFunc = function(value) self.settings.junkNotCraftedFood = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_NOCRDR_CONTROL),
      default = defaults.junkNotCraftedDrink,
      getFunc = function() return self.settings.junkNotCraftedDrink end,
      setFunc = function(value) self.settings.junkNotCraftedDrink = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_SLVNPT_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_SLVNPT_CONTROL_TOOLTIP),
      default = defaults.junkPotionSolvent,
      getFunc = function() return self.settings.junkPotionSolvent end,
      setFunc = function(value) self.settings.junkPotionSolvent = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_SLVNPS_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_SLVNPS_CONTROL_TOOLTIP),
      default = defaults.junkPoisonSolvent,
      getFunc = function() return self.settings.junkPoisonSolvent end,
      setFunc = function(value) self.settings.junkPoisonSolvent = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_TRASH_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_TRASH_CONTROL_TOOLTIP),
      default = defaults.junkTrashItem,
      getFunc = function() return self.settings.junkTrashItem end,
      setFunc = function(value) self.settings.junkTrashItem = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_TROVE_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_TROVE_CONTROL_TOOLTIP),
      default = defaults.junkTreasureItem,
      getFunc = function() return self.settings.junkTreasureItem end,
      setFunc = function(value) self.settings.junkTreasureItem = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_RFISH_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_RFISH_CONTROL_TOOLTIP),
      default = defaults.junkRareFish,
      getFunc = function() return self.settings.junkRareFish end,
      setFunc = function(value) self.settings.junkRareFish = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_BAIT_CONTROL),
      default = defaults.junkBait,
      getFunc = function() return self.settings.junkBait end,
      setFunc = function(value) self.settings.junkBait = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_TROPHY_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_TROPHY_CONTROL_TOOLTIP),
      default = defaults.junkMonsterTrophy,
      getFunc = function() return self.settings.junkMonsterTrophy end,
      setFunc = function(value) self.settings.junkMonsterTrophy = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_TOOLTIP),
      default = defaults.junkExcessRepairKit,
      getFunc = function() return self.settings.junkExcessRepairKit end,
      setFunc = function(value) self.settings.junkExcessRepairKit = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_EXCESS_SOULGEM_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_EXCESS_SOULGEM_TOOLTIP),
      default = defaults.junkExcessSoulgem,
      getFunc = function() return self.settings.junkExcessSoulgem end,
      setFunc = function(value) self.settings.junkExcessSoulgem = value end,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_JUNK_AUTO_DESCRIPTION) .. "|r",
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_AUTOSELL_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_AUTOSELL_TOOLTIP),
      default = defaults.autoJunkSell,
      getFunc = function() return self.settings.autoJunkSell end,
      setFunc = function(value) self.settings.autoJunkSell = value end,
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_CONTROL),
      tooltip = GetString(LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_TOOLTIP),
      default = defaults.autoLearnJunkRecipes,
      getFunc = function() return self.settings.autoLearnJunkRecipes end,
      setFunc = function(value) self.settings.autoLearnJunkRecipes = value end,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t " .. GetString(LOOTSANITIZER_AUTOBURN_HEADER),
    },
    {
      type = "checkbox",
      name = GetString(LOOTSANITIZER_DISPLAY_AUTOBURN_ACTION_CONTROL),
      default = defaults.displayAutoBurnAction,
      getFunc = function() return self.settings.displayAutoBurnAction end,
      setFunc = function(value) self.settings.displayAutoBurnAction = value end,
      disabled = true,
    },
    {
      type = "custom",
      reference = "LootSanitizerCustomPanelList",
      createFunc = function(control)
        -- call when panel created
        d("[LootSanitizer]: Create Conrtol triggered!")
        InitializeList(control)
      end,
      refreshFunc = function(control)
        -- (optional) call when panel/controls refresh
        d("[LootSanitizer]: Refresh Conrtol triggered!")
      end,
      minHeight = 50,
      maxHeight = 300,
    },
    {
      type = "description",
      text = [[
      ]],
    },
    {
      type = "header",
      name = "|t36:36:esoui/art/inventory/inventory_tabIcon_quickslot_up.dds:inheritcolor|t " .. GetString(LOOTSANITIZER_COMMAND_HEADER),
    },
    {
      type = "description",
      text = "|cc5c29e" .. GetString(LOOTSANITIZER_COMMAND_DESCRIPTION) .. "|r",
    },
    {
      type = "description",
      text = "/lss |cc5c29e— " .. GetString(LOOTSANITIZER_COMMAND_SETTINGS) .. "|r",
    },
    {
      type = "description",
      text = "/lootsanitizer |cc5c29e— " .. GetString(LOOTSANITIZER_COMMAND_SETTINGS_ALT) .. "|r",
    },
    {
      type = "description",
      text = "/lsstats |cc5c29e— " .. GetString(LOOTSANITIZER_COMMAND_STATISTICS) .. "|r",
    },
    {
      type = "description",
      text = [[
      ]],
    },
  }
  self.controlsPanel = LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end
