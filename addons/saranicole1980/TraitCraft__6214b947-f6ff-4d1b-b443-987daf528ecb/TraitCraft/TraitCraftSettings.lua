local TC = TraitCraft

local LAM = LibHarvensAddonSettings

if not LibHarvensAddonSettings then
    d("LibHarvensAddonSettings is required!")
    return
end

local protocol = nil

local currentlyLoggedInCharId = TC.currentlyLoggedInCharId

local researcherLimit = 25
if IsInGamepadPreferredMode() then
  researcherLimit = 5
end

local MAIN_CRAFTER_NAME, MAIN_CRAFTER_ID, ACTIVELY_RESEARCHING_NAME, ACTIVELY_RESEARCHING_ID, RESEARCHER_TO_REMOVE_NAME, RESEARCHER_TO_REMOVE_ID
local BLACKSMITHING_CHARACTER_NAME, BLACKSMITHING_CHARACTER_ID, CLOTHING_CHARACTER_NAME, CLOTHING_CHARACTER_ID, WOODWORKING_CHARACTER_NAME, WOODWORKING_CHARACTER_ID, JEWELRY_CHARACTER_NAME, JEWELRY_CHARACTER_ID

--Icon
TC.IconList = {
  "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
  "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
  "/esoui/art/crafting/blueprints_tabicon_up.dds",
  "/esoui/art/crafting/designs_tabicon_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_aspect_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_potency_up.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_designs.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_fillet.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_improve.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_refine.dds",
  "/esoui/art/crafting/gamepad/gp_jewelry_tabicon_icon.dds",
  "/esoui/art/crafting/gamepad/gp_reconstruct_tabicon.dds",
  "/esoui/art/crafting/jewelryset_tabicon_icon_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_fish_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
  "/esoui/art/crafting/retrait_tabicon_up.dds",
  "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
  "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_equip_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_quests_up.dds",
  "/esoui/art/companion/keyboard/category_u30_companions_up.dds",
  "/esoui/art/collections/collections_categoryicon_unlocked_up.dds",
  "/esoui/art/collections/collections_tabicon_housing_up.dds",
  "/esoui/art/companion/keyboard/companion_character_up.dds",
  "/esoui/art/companion/keyboard/companion_skills_up.dds",
  "/esoui/art/companion/keyboard/companion_overview_up.dds",
  "/esoui/art/guildfinder/keyboard/guildbrowser_guildlist_additionalfilters_up.dds",
  "/esoui/art/help/help_tabicon_cs_up.dds",
  "/esoui/art/help/help_tabicon_tutorial_up.dds",
  "/esoui/art/lfg/lfg_any_up_64.dds",
  "/esoui/art/lfg/lfg_tank_up_64.dds",
  "/esoui/art/lfg/lfg_dps_up_64.dds",
  "/esoui/art/lfg/lfg_healer_up_64.dds",
  "/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
  "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
  "/esoui/art/lfg/lfg_indexicon_zonestories_up.dds",
  "/esoui/art/mail/mail_tabicon_inbox_up.dds",
  "/esoui/art/market/keyboard/tabicon_crownstore_up.dds",
  "/esoui/art/market/keyboard/tabicon_daily_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawplating_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
  "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
}

function TC.GetCharacterList()
  local characterList = {}
  for i = 1, GetNumCharacters() do
      local name, _, _, _, _, backupId, id = GetCharacterInfo(i)
      table.insert(characterList, { name = ZO_CachedStrFormat(SI_UNIT_NAME, name), data = id or backupId })
  end
  return characterList
end

function TC.GetNameFromId(characterList, charId)
  for _, value in ipairs(characterList) do
    if value.data == charId then
      return value.name
    end
  end
end

function TC.GetCurrentCharInfo(characters)
  if TC.currentlyLoggedInChar.name and TC.currentlyLoggedInChar.id then
    return TC.currentlyLoggedInChar.name, TC.currentlyLoggedInChar.id
  end
  for _, value in ipairs(characters) do
    if value.data == TC.currentlyLoggedInCharId then
      TC.currentlyLoggedInChar = { name = value.name, id = value.data }
      return value.name, value.id
    end
  end
return nil, nil
end

function TC.CurrentActivelyResearching()
  local summary = " "
  local separator = ""
  if ZO_IsConsoleUI() then
    separator = "\r\n  "
  else
    separator = "\r\n\n  "
  end
  for k, v in pairs(TC.AV.activelyResearchingCharacters) do
    local icon = v.icon or TC.IconList[1]
    summary = summary.."  |t40:40:"..icon.."|t  "..v.name.."|r"..separator
  end
  return summary
end

function TC.ResearchersToDropdown()
  local researchers = {}
  for k, v in pairs(TC.AV.activelyResearchingCharacters) do
    table.insert(researchers, { name = v.name, data = k } )
  end
  return researchers
end

function TC.unindexedCount(unindexed)
  local counter = 0
  for _, _ in pairs(unindexed) do
    counter = counter + 1
  end
  return counter
end

function TC.SetCrafterDefaults(characters)
  if not next(TC.AV.mainCrafter) and not MAIN_CRAFTER_NAME and not MAIN_CRAFTER_ID then
    MAIN_CRAFTER_NAME, MAIN_CRAFTER_ID  = TC.GetCurrentCharInfo(characters)
    TC.AV.mainCrafter = { name = MAIN_CRAFTER_NAME, data = MAIN_CRAFTER_ID }
    table.insert(TC.AV.allCrafterIds, MAIN_CRAFTER_ID)
  end
  if not TC.AV.allCrafters[CRAFTING_TYPE_BLACKSMITHING] and not BLACKSMITHING_CHARACTER_NAME and not BLACKSMITHING_CHARACTER_ID then
    BLACKSMITHING_CHARACTER_NAME, BLACKSMITHING_CHARACTER_ID  = TC.GetCurrentCharInfo(characters)
  end
  if not TC.AV.allCrafters[CRAFTING_TYPE_CLOTHIER] and not CLOTHING_CHARACTER_NAME and not CLOTHING_CHARACTER_ID then
    CLOTHING_CHARACTER_NAME, CLOTHING_CHARACTER_ID  = TC.GetCurrentCharInfo(characters)
  end
  if not TC.AV.allCrafters[CRAFTING_TYPE_WOODWORKING] and not WOODWORKING_CHARACTER_NAME and not WOODWORKING_CHARACTER_ID then
    WOODWORKING_CHARACTER_NAME, WOODWORKING_CHARACTER_ID  = TC.GetCurrentCharInfo(characters)
  end
  if not TC.AV.allCrafters[CRAFTING_TYPE_JEWELRYCRAFTING] and not JEWELRY_CHARACTER_NAME and not JEWELRY_CHARACTER_ID then
    JEWELRY_CHARACTER_NAME, JEWELRY_CHARACTER_ID  = TC.GetCurrentCharInfo(characters)
  end
end

local function checkLLCAbsent()
  return LibLazyCrafting == nil
end

function TC.BuildMenu()
  local characterList = TC.GetCharacterList()
  TC.SetCrafterDefaults(characterList)

  local IconName, Icon, LimitTraits

  local panel = LAM:AddAddon(TC.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = false    -- Enable automatic control updates
  })

  if TC.AV.settings.requestOption then
    panel:AddSetting({
      type = LAM.ST_SECTION,
      label = TC.Lang.RESEARCH_REQUESTS,
      tooltip = TC.Lang.RESEARCH_BELOW_TOOLTIP
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = TC.Lang.SEND_CRAFT_REQUEST,
        buttonText = TC.Lang.AUTOFILL_REQUEST,
        tooltip = TC.Lang.CRAFT_REQUEST_TOOLTIP,
        clickHandler = function(control)
          local bodyValues, csvValues = TC:ScanUnknownTraitsForRequesting()
          local to = TC.AV.settings.crafterRequestee
          local scope = TC.formatter.Scope({ advert = TC.Lang.TRAITCRAFT_ADVERTISE, todotpath = bodyValues, tocsv = csvValues, rep = string.rep("-", 30) })
          local encodedResearch = TC.formatter:format("{advert}\r\n{rep}{tocsv}", scope)
          TC.mailInstance:ComposeMail(to, TC.mailSubject, encodedResearch, true)
          TC.makeAnnouncement(TC.Lang.REQUEST_SENT, SOUNDS.MAIL_WINDOW_OPEN)
        end
    })
  end

  panel:AddSetting({
    type = LAM.ST_SECTION,
    label = TC.Lang.CRAFTER_SETTINGS,
  })

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.MAIN_CRAFTER,
    items = characterList,
    getFunction = function() return MAIN_CRAFTER_NAME or TC.AV.mainCrafter.name end,
    setFunction = function(var, itemName, itemData)
      MAIN_CRAFTER_NAME = itemName
      MAIN_CRAFTER_ID = itemData.data
    end
  }

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.BLACKSMITHING_CHARACTER,
    items = characterList,
    getFunction = function() return BLACKSMITHING_CHARACTER_NAME or TC.GetNameFromId(characterList, (TC.AV.allCrafters[CRAFTING_TYPE_BLACKSMITHING] or TC.AV.mainCrafter.data)) end,
    setFunction = function(var, itemName, itemData)
      BLACKSMITHING_CHARACTER_NAME = itemName
      BLACKSMITHING_CHARACTER_ID = itemData.data
    end
  }

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.CLOTHING_CHARACTER,
    items = characterList,
    getFunction = function() return CLOTHING_CHARACTER_NAME or TC.GetNameFromId(characterList, (TC.AV.allCrafters[CRAFTING_TYPE_CLOTHIER] or TC.AV.mainCrafter.data)) end,
    setFunction = function(var, itemName, itemData)
      CLOTHING_CHARACTER_NAME = itemName
      CLOTHING_CHARACTER_ID = itemData.data

    end
  }

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.WOODWORKING_CHARACTER,
    items = characterList,
    getFunction = function() return WOODWORKING_CHARACTER_NAME or TC.GetNameFromId(characterList, (TC.AV.allCrafters[CRAFTING_TYPE_WOODWORKING] or TC.AV.mainCrafter.data))  end,
    setFunction = function(var, itemName, itemData)
      WOODWORKING_CHARACTER_NAME = itemName
      WOODWORKING_CHARACTER_ID = itemData.data

    end
  }

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.JEWELRY_CHARACTER,
    items = characterList,
    getFunction = function() return JEWELRY_CHARACTER_NAME  or TC.GetNameFromId(characterList, (TC.AV.allCrafters[CRAFTING_TYPE_JEWELRYCRAFTING] or TC.AV.mainCrafter.data))  end,
    setFunction = function(var, itemName, itemData)
      JEWELRY_CHARACTER_NAME = itemName
      JEWELRY_CHARACTER_ID = itemData.data
    end
  }

  --Breakpoint
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = TC.Lang.DISPLAY_SETTINGS,
  }

  --Enable autocraft
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TC.Lang.ENABLE_AUTOCRAFT,
    getFunction = function() return TC.AV.settings.autoCraftOption end,
    setFunction = function(var)
      local oldOption = TC.AV.settings.autoCraftOption
      TC.AV.settings.autoCraftOption = var
      if var then
        if not TC.autocraft then
          TC.autocraft = TC_Autocraft:New(TC)
        end
      else
        if TC.autocraft then
          TC.autocraft:Destroy()
        end
      end
      if oldOption ~= var then
        ReloadUI("ingame")
      end
    end,
    default = false,
    disable = function()
      return checkLLCAbsent()
    end
  }

  --Whether to autocraft nirnhoned materials
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TC.Lang.ENABLE_NIRNHONED,
    getFunction = function() return TC.AV.settings.autoCraftNirnhoned end,
    setFunction = function(var)
      TC.AV.settings.autoCraftNirnhoned = var
    end,
    default = false,
    disable = function()
      return not TC.AV.settings.autoCraftOption or checkLLCAbsent()
    end
  }

  --Show known traits
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TC.Lang.SHOW_KNOWN_TRAITS,
    getFunction = function() return TC.AV.settings.showKnown end,
    setFunction = function(var)
      TC.AV.settings.showKnown = var
    end,
    default = false,
  }

  panel:AddSetting({
    type = LAM.ST_COLOR,
    label = TC.Lang.SELECT_KNOWN_COLOR,
    getFunction = function()
        return TC.AV.settings.knownColor.r, TC.AV.settings.knownColor.g,
               TC.AV.settings.knownColor.b
    end,
    setFunction = function(r, g, b)
        TC.AV.settings.knownColor = {r = r, g = g, b = b}
    end,
    default = TC.AV.settings.knownColor
})

  --Show unknown traits
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TC.Lang.SHOW_UNKNOWN_TRAITS,
    getFunction = function() return TC.AV.settings.showUnknown end,
    setFunction = function(var)
      TC.AV.settings.showUnknown = var
    end,
    default = TC.AV.settings.showUnknown,
  }

  panel:AddSetting({
    type = LAM.ST_COLOR,
    label = TC.Lang.SELECT_UNKNOWN_COLOR,
    getFunction = function()
        return TC.AV.settings.unknownColor.r, TC.AV.settings.unknownColor.g,
               TC.AV.settings.unknownColor.b
    end,
    setFunction = function(r, g, b)
        TC.AV.settings.unknownColor = {r = r, g = g, b = b}
    end,
    default = TC.AV.settings.unknownColor
  })

  --Show researching traits
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TC.Lang.SHOW_RESEARCHING,
    getFunction = function() return TC.AV.settings.showResearching end,
    setFunction = function(var)
      TC.AV.settings.showResearching = var
    end,
    default = TC.AV.settings.showResearching,
  }

  panel:AddSetting({
    type = LAM.ST_COLOR,
    label = TC.Lang.SELECT_RESEARCHING_COLOR,
    getFunction = function()
        return TC.AV.settings.researchingColor.r, TC.AV.settings.researchingColor.g,
               TC.AV.settings.researchingColor.b
    end,
    setFunction = function(r, g, b)
        TC.AV.settings.researchingColor = {r = r, g = g, b = b}
    end,
    default = TC.AV.settings.researchingColor
  })

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.SELECT_ACTIVELY_RESEARCHING,
    items = characterList,
    getFunction = function() return ACTIVELY_RESEARCHING_NAME end,
    setFunction = function(var, itemName, itemData)
      ACTIVELY_RESEARCHING_NAME = itemName
      ACTIVELY_RESEARCHING_ID = itemData.data
    end,
  }

 --Icon Select
  panel:AddSetting {
    type = LAM.ST_ICONPICKER,
    label = TC.Lang.CHARACTER_ICON,
    items = TC.IconList,
    getFunction = function() return Icon  end,
    setFunction = function(var, iconIndex, iconPath)
      IconName = iconPath
      Icon = iconIndex
    end,
  }

--Apply
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = TC.Lang.ACTIVE_APPLY,
    buttonText = TC.Lang.ACTIVE_APPLY,
    clickHandler  = function()
      TC.AV.allCrafterIds = {}
      if MAIN_CRAFTER_NAME and MAIN_CRAFTER_ID then
        TC.AV.mainCrafter = { name = MAIN_CRAFTER_NAME, data = MAIN_CRAFTER_ID }
        if not TC.isValueInTable(TC.AV.allCrafterIds, MAIN_CRAFTER_ID) then
          table.insert(TC.AV.allCrafterIds, MAIN_CRAFTER_ID)
        end
      end
      if BLACKSMITHING_CHARACTER_NAME and BLACKSMITHING_CHARACTER_ID then
        if not TC.AV.allCrafters[CRAFTING_TYPE_BLACKSMITHING] or TC.AV.allCrafters[CRAFTING_TYPE_BLACKSMITHING] ~= BLACKSMITHING_CHARACTER_ID then
          table.insert(TC.AV.allCrafterIds, BLACKSMITHING_CHARACTER_ID)
          TC.AV.allCrafters[CRAFTING_TYPE_BLACKSMITHING] = BLACKSMITHING_CHARACTER_ID
        end
      end
      if CLOTHING_CHARACTER_NAME and CLOTHING_CHARACTER_ID then
        if not TC.AV.allCrafters[CRAFTING_TYPE_CLOTHIER] or TC.AV.allCrafters[CRAFTING_TYPE_CLOTHIER] ~= CLOTHING_CHARACTER_ID then
          table.insert(TC.AV.allCrafterIds, CLOTHING_CHARACTER_ID)
          TC.AV.allCrafters[CRAFTING_TYPE_CLOTHIER] = CLOTHING_CHARACTER_ID
        end
      end
      if WOODWORKING_CHARACTER_NAME and WOODWORKING_CHARACTER_ID then
        if not TC.AV.allCrafters[CRAFTING_TYPE_WOODWORKING] or TC.AV.allCrafters[CRAFTING_TYPE_WOODWORKING] ~= WOODWORKING_CHARACTER_ID then
          table.insert(TC.AV.allCrafterIds, WOODWORKING_CHARACTER_ID)
          TC.AV.allCrafters[CRAFTING_TYPE_WOODWORKING] = WOODWORKING_CHARACTER_ID
        end
      end
      if JEWELRY_CHARACTER_NAME and JEWELRY_CHARACTER_ID then
        if not TC.AV.allCrafters[CRAFTING_TYPE_JEWELRYCRAFTING] or TC.AV.allCrafters[CRAFTING_TYPE_JEWELRYCRAFTING] ~= JEWELRY_CHARACTER_ID then
          table.insert(TC.AV.allCrafterIds, JEWELRY_CHARACTER_ID)
          TC.AV.allCrafters[CRAFTING_TYPE_JEWELRYCRAFTING] = JEWELRY_CHARACTER_ID
        end
      end
      if ACTIVELY_RESEARCHING_ID then
        if TC.unindexedCount(TC.AV.activelyResearchingCharacters) < researcherLimit then
          if not TC.AV.activelyResearchingCharacters[ACTIVELY_RESEARCHING_ID] then
            TC.AV.activelyResearchingCharacters[ACTIVELY_RESEARCHING_ID] = {}
          end
          TC.AV.activelyResearchingCharacters[ACTIVELY_RESEARCHING_ID].name = ACTIVELY_RESEARCHING_NAME
          TC.AV.activelyResearchingCharacters[ACTIVELY_RESEARCHING_ID].icon = IconName
          Status = TC.Lang.STATUS_ADDED
        else
          Status = TC.Lang.STATUS_EXCEEDED_RESEARCHERS..tostring(researcherLimit)
        end
      end
      Status = Status or TC.Lang.STATUS_ADDED
      panel:UpdateControls()
    end
  }

  --Status
  panel:AddSetting {
    type = LAM.ST_LABEL,
    label = function()
      return Status or " "
    end
  }

  --Breakpoint
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = TC.Lang.CHOICES_EDIT,
  }
  --Clear Researching Characters
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = TC.Lang.CLEAR_ACTIVELY_RESEARCHING,
    buttonText = TC.Lang.SHORT_CLEAR,
    clickHandler  = function()
      TC.AV.activelyResearchingCharacters = {}
      panel:UpdateControls()
    end
    }

  --Delete specific actively researching character
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = TC.Lang.REMOVE_RESEARCHER,
    items = TC.ResearchersToDropdown(),
    getFunction = function() return RESEARCHER_TO_REMOVE_NAME end,
    setFunction = function(var, itemName, itemData)
      RESEARCHER_TO_REMOVE_NAME = itemName
      RESEARCHER_TO_REMOVE_ID = itemData.data
    end,
    }

  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = TC.Lang.SHORT_REMOVE,
    buttonText = TC.Lang.SHORT_REMOVE,
    clickHandler  = function()
      if RESEARCHER_TO_REMOVE_ID and TC.AV.activelyResearchingCharacters[RESEARCHER_TO_REMOVE_ID] then
          TC.AV.activelyResearchingCharacters[RESEARCHER_TO_REMOVE_ID] = nil
      end
      Status = TC.Lang.STATUS_REMOVED
      panel:UpdateControls()
    end
    }
    -- Reload UI
    panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = TC.Lang.RELOAD_UI,
    buttonText = TC.Lang.SHORT_RELOAD_UI,
    clickHandler  = function()
      ReloadUI("ingame")
    end
    }
    --Configured
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = TC.Lang.ACTIVELY_RESEARCHING,
    }
    --Actively Researching Characters Summary
    panel:AddSetting {
      type = LAM.ST_LABEL,
      label = function()
        return TC.CurrentActivelyResearching()
      end
    }
    panel:AddSetting({
      type = LAM.ST_SECTION,
      label = TC.Lang.RESEARCH_REQUESTS,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = TC.Lang.SEND_CRAFT_REQUEST,
        buttonText = TC.Lang.AUTOFILL_REQUEST,
        tooltip = TC.Lang.CRAFT_REQUEST_TOOLTIP,
        clickHandler = function(control)
          local bodyValues, csvValues = TC:ScanUnknownTraitsForRequesting()
          local to = TC.AV.settings.crafterRequestee
          local scope = TC.formatter.Scope({ advert = TC.Lang.TRAITCRAFT_ADVERTISE, todotpath = bodyValues, tocsv = csvValues, rep = string.rep("-", 30) })
          local encodedResearch = TC.formatter:format("{advert}\r\n{rep}{tocsv}", scope)
          TC.mailInstance:ComposeMail(to, TC.mailSubject, encodedResearch, true)
          TC.makeAnnouncement(TC.Lang.REQUEST_SENT, SOUNDS.MAIL_WINDOW_OPEN)
        end
    })

    panel:AddSetting({
      type = LAM.ST_CHECKBOX,
      label = TC.Lang.ENABLE_BUTTON.." "..TC.Lang.RESEARCH_REQUESTS,
      getFunction = function() return TC.AV.settings.requestOption or false end,
      setFunction = function(var)
        TC.AV.settings.requestOption = var
        panel:UpdateControls()
      end
    })

    panel:AddSetting({
      type = LAM.ST_CHECKBOX,
      label = TC.Lang.ENABLE_BUTTON.." "..TC.Lang.FULFILL_REQUEST,
      getFunction = function() return TC.AV.settings.receiveOption or false end,
      setFunction = function(var)
        TC.AV.settings.receiveOption = var
      end
    })

    panel:AddSetting({
      type = LAM.ST_EDIT,
      label = TC.Lang.CRAFTER_REQUESTEE,
      getFunction = function() return TC.AV.settings.crafterRequestee or "" end,
      setFunction = function(value) TC.AV.settings.crafterRequestee = value end,
      default = ""
    })

    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = TC.Lang.ACTIVE_APPLY,
      buttonText = TC.Lang.ACTIVE_APPLY,
      clickHandler  = function()
        panel:UpdateControls()
        ReloadUI("ingame")
      end,
      tooltip = TC.Lang.REQUIRES_RELOAD.."; "..TC.Lang.REQUIRES_LIBRARY.."LibDynamicMail, LibTextFormat",
      disable = function()
        return not TC.AV.settings.requestOption
      end
    })

    panel:AddSetting({
      type = LAM.ST_LABEL,
      label = function()
          return TC.AV.settings.crafterRequestee or ""
      end,
      tooltip = TC.Lang.SEND_CRAFT_REQUEST
    })

    --Breakpoint
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = " ",
    }
end
