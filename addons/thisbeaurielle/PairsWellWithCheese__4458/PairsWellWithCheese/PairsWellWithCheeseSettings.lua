local IFTTT = PairsWellWithCheese

local LAM = LibHarvensAddonSettings

if not LibHarvensAddonSettings then
    return
end

IFTTT.triggerSelected = {}
IFTTT.commitTrigger = {}
IFTTT.outcomeSelected = {}
IFTTT.deleteSelected = {}
IFTTT.subcategorySettings = {}
IFTTT.collectibleSettings = {}
IFTTT.labelSettings = {}

IFTTT.deleteFunc = function() 
  local deleteItems = {}
  for key, linkItem in pairs(IFTTT.Links.savedVarsAcc.links) do
    table.insert(deleteItems, { name = IFTTT.Lang.ACCOUNT.."   "..key.."   "..linkItem.trigger.name.." → "..linkItem.outcome.name, data = IFTTT.Lang.ACCOUNT.."-"..key.."-"..linkItem.trigger.data })
  end
  for key, linkItem in pairs(IFTTT.Links.savedVarsChar.links) do
    table.insert(deleteItems, { name = IFTTT.Lang.CHARACTER.."   "..key.."   "..linkItem.trigger.name.." → "..linkItem.outcome.name, data = IFTTT.Lang.CHARACTER.."-"..key.."-"..linkItem.trigger.data })
  end
  return deleteItems
end


local function warnMessage(commitTrigger, commitEffect)
  local problem = ""
  if commitTrigger and next(commitTrigger) and commitEffect and next(commitEffect) then return problem end
  problem = "|cff0000"..IFTTT.Name.."|r "..IFTTT.Lang.PLEASE_SELECT.." "
  if not commitTrigger or (type(commitTrigger) == "table" and not next(commitTrigger)) then
    problem = problem..IFTTT.Lang.TRIGGER.." "
  end
  if not commitEffect or (type(commitEffect) == "table" and not next(commitEffect)) then
    if not commitTrigger or (type(commitTrigger) == "table" and not next(commitTrigger)) then
      problem = problem..IFTTT.Lang.AND.." "
    end
    problem =  problem..IFTTT.Lang.EFFECT
  end
  return problem
end

local function RefreshSetting(setting, previousSibling, triggerOrEffect)
  if IsInGamepadPreferredMode() or IsConsoleUI() then
    setting:UpdateControl()
  else
    setting:UpdateControl(previousSibling)
  end
  if triggerOrEffect == "effect" then
    IFTTT.outcomeSelected = setting.items()[1]
  elseif triggerOrEffect == "trigger" then
    IFTTT.triggerSelected = setting.items()[1]
  end
end

local function RefreshHeight(numlines)
  if not (IsInGamepadPreferredMode() or IsConsoleUI()) then
    LAM:SetContainerHeightPercentage(1 + (0.1 * numlines))
  end
end

function IFTTT:BuildMenu()
  local panel = LAM:AddAddon(self.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = false    -- Enable automatic control updates
  })

  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = string.rep("·", 10).." "..IFTTT.Lang.TRIGGER_HEADING.." "..string.rep("·", 10)
  }
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = IFTTT.Lang.MOUNT_HEADING
  }
  
  local triggerMountItem = IFTTT.Triggers.items.TriggerMounts

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = IFTTT.Lang.MOUNT_HEADING,
    items = triggerMountItem.subcategories,
    getFunction = function() 
      return triggerMountItem.selectedSubcategory.name or ""
    end,
    setFunction = function(control, itemName, itemData)
      triggerMountItem.selectedSubcategory = { name = itemName, data = itemData.data }
      triggerMountItem:GetCollectibles()
      RefreshSetting(self.collectibleSettings["TriggerMounts"], control, "trigger")
    end,
  }
    self.collectibleSettings["TriggerMounts"] = panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.COLLECTIBLE_HEADING,
      items = function()
        return triggerMountItem.collectibles
      end,
      getFunction = function() 
        if next(triggerMountItem.selected) then
          return triggerMountItem.selected.name
        end
        if triggerMountItem.collectibles and next(triggerMountItem.collectibles) then
          local index, first = next(select(1, triggerMountItem.collectibles))
          return first.name
        end
      end,
      setFunction = function(var, itemName, itemData)
        local selected = {name=itemName, data=itemData.data}
        triggerMountItem.selected = selected
        self.triggerSelected = selected
      end,
    }
  local triggerCollectibleItem = IFTTT.Triggers.items.TriggerCollectibles
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = IFTTT.Lang.TRIGGERCOLLECTIBLE_HEADING
  }

  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = IFTTT.Lang.TRIGGERCOLLECTIBLE_HEADING,
    items = triggerCollectibleItem.categories,
    getFunction = function() 
      return triggerCollectibleItem.selectedCategory.name or triggerCollectibleItem.categories[1].name or ""
    end,
    setFunction = function(setting, itemName, itemData)
      triggerCollectibleItem.selectedCategory = { name = itemName, data = itemData.data }
      local control
      if setting.m_container then
        control = setting.m_container:GetParent()
      end
      RefreshSetting(self.subcategorySettings["TriggerCollectibles"], control)
      RefreshSetting(self.collectibleSettings["TriggerCollectibles"], self.subcategorySettings["TriggerCollectibles"].control, "trigger")
    end,
  }

    IFTTT.subcategorySettings["TriggerCollectibles"] = panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.SUBCATEGORY,
      items = function()
        return triggerCollectibleItem:GetSubcategoryNames()
      end,
      getFunction = function() 
        if triggerCollectibleItem.selectedSubcategory then
          return triggerCollectibleItem.selectedSubcategory.name
        end
        return ""
      end,
      setFunction = function(setting, itemName, itemData)
        triggerCollectibleItem.selectedSubcategory = { name = itemName, data = itemData.data }
        local control
        if setting.m_container then
          control = setting.m_container:GetParent()
        end
        RefreshSetting(self.collectibleSettings["TriggerCollectibles"], control, "trigger")
      end,
    }
    self.collectibleSettings["TriggerCollectibles"] = panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.COLLECTIBLE_HEADING,
      items = function()
        return triggerCollectibleItem:GetCollectibles()
      end,
      getFunction = function() 
        if triggerCollectibleItem.collectibles and next(triggerCollectibleItem.collectibles) then
          return triggerCollectibleItem.selected.name or triggerCollectibleItem.collectibles[1].name
        end
        return  ""
      end,
      setFunction = function(var, itemName, itemData)
        local selected = {name=itemName, data=itemData.data}
        triggerCollectibleItem.selected = selected
        self.triggerSelected = selected
      end,
    }
  for k, triggerItem in pairs(IFTTT.Triggers.items) do
    if k ~= "TriggerCollectibles" and k ~= "TriggerMounts" then
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang[string.upper(k).."_HEADING"]
    }
    panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang[string.upper(k).."_HEADING"],
      items = function()
        return triggerItem.available
      end,
      getFunction = function() 
        if next(triggerItem.selected) then
          return triggerItem.selected.name
        end
        return triggerItem.available[1].name or ""
      end,
      setFunction = function(var, itemName, itemData)
        local selected = {name=itemName, data=itemData.data}
        triggerItem.selected = selected
        self.triggerSelected = selected
      end,
      default = "",
    }
    end
  end
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang.COMMIT
    }
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.SELECT_TRIGGER,
      buttonText = IFTTT.Lang.SELECT_TRIGGER,
      clickHandler = function(control)
        if self.triggerSelected then
          self.commitTrigger = self.triggerSelected
          local dataParts = self.Split(self.triggerSelected.data)
          panel:UpdateControls()
        end
      end
    })
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.CLEAR.." "..IFTTT.Lang.TRIGGER,
      buttonText = IFTTT.Lang.CLEAR.." "..IFTTT.Lang.TRIGGER,
      clickHandler = function(control)
        self.commitTrigger = nil
        panel:UpdateControls()
      end
    })
    IFTTT.labelSettings["selected"] = panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang.SELECTED_TRIGGER
    }
    IFTTT.labelSettings["trigger"] = panel:AddSetting {
      type = LAM.ST_LABEL,
      label = function()
        if self.commitTrigger and next(self.commitTrigger) then
          return "|cebc034"..self.commitTrigger.name.."|r"
        end
        return "" 
      end
    }
  panel:AddSetting {
      type = LAM.ST_SECTION,
      label = string.rep("·", 10).." "..IFTTT.Lang.EFFECT_HEADING.." "..string.rep("·", 10)
    }
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = ""
    }
    for k, collectibleItem in pairs(IFTTT.Outcomes.items) do
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang[string.upper(k).."_HEADING"]
    }
    panel:AddSetting({
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.CATEGORY,
      items = collectibleItem.categories,
      getFunction = function() 
        return collectibleItem.selectedCategory.name or collectibleItem.categories[1].name or ""
      end,
      setFunction = function(setting, itemName, itemData)
        collectibleItem.selectedCategory = { name = itemName, data = itemData.data }
        local control
        if setting.m_container then
          control = setting.m_container:GetParent()
        end
        RefreshSetting(self.subcategorySettings[k], control)
        RefreshSetting(self.collectibleSettings[k], self.subcategorySettings[k].control, "effect")
      end,
    })

    self.subcategorySettings[k] = panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.SUBCATEGORY,
      items = function()
        return collectibleItem:GetSubcategoryNames()
      end,
      getFunction = function() 
        if collectibleItem.selectedSubcategory then
          return collectibleItem.selectedSubcategory.name
        end
        return ""
      end,
      setFunction = function(setting, itemName, itemData)
        collectibleItem.selectedSubcategory = { name = itemName, data = itemData.data }
        local control
        if setting.m_container then
          control = setting.m_container:GetParent()
        end
        RefreshSetting(self.collectibleSettings[k], control, "effect")
      end,
    }
    self.collectibleSettings[k] = panel:AddSetting {
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang[string.upper(k).."_HEADING"],
      items = function()
        return collectibleItem:GetCollectibles()
      end,
      getFunction = function() 
        if collectibleItem.collectibles and next(collectibleItem.collectibles) then
          return collectibleItem.selected.name or collectibleItem.collectibles[1].name
        end
        return  ""
      end,
      setFunction = function(var, itemName, itemData)
        local selected = {name=itemName, data=itemData.data}
        collectibleItem.selected = selected
        self.outcomeSelected = selected
      end,
    }
  end
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang.COMMIT
    }
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.SELECT_EFFECT,
      buttonText = "|cffffff"..IFTTT.Lang.SELECT_EFFECT.."|r",
      clickHandler = function()
        self.commitEffect = self.outcomeSelected
        panel:UpdateControls()
      end
    })
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.CLEAR.." "..IFTTT.Lang.EFFECT,
      buttonText = "|cffffff"..IFTTT.Lang.CLEAR.." "..IFTTT.Lang.EFFECT.."|r",
      clickHandler = function()
        self.commitEffect = nil
        panel:UpdateControls()
      end
    })
    self.labelSettings["selectedEffectHeader"] = panel:AddSetting {
      type = LAM.ST_SECTION,
      label = IFTTT.Lang.SELECTED_EFFECT
    }
    self.labelSettings["effect"] = panel:AddSetting {
      type = LAM.ST_LABEL,
      label = function()
        if self.commitEffect and next(self.commitEffect) then
          return "|cebc034"..self.commitEffect.name.."|r"
        end
        return "" 
      end
    }
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = ""
    }
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.ADD_LINK,
      buttonText = IFTTT.Lang.ADD,
      tooltip = IFTTT.Lang.ADD_TOOLTIP,
      clickHandler = function()
        local warn = warnMessage(self.commitTrigger, self.commitEffect)
        if warn ~= "" then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, warn)
          return
        end
        local linkTrigger = { trigger = self.commitTrigger, outcome = self.commitEffect }
        table.insert(self.Links.savedVarsChar.links, linkTrigger)
        self.commitTrigger = nil
        self.commitEffect = nil
        self.triggerSelected = nil
        self.outcomeSelected = nil
        self:AddCallbacks()
        panel:UpdateControls()
      end
    })
    panel:AddSetting({
      type = LAM.ST_BUTTON,
      label = IFTTT.Lang.ACC_ADD_LINK,
      buttonText = IFTTT.Lang.ACC_ADD,
      tooltip = IFTTT.Lang.ACC_ADD_TOOLTIP,
      clickHandler = function()
        local warn = warnMessage(self.commitTrigger, self.commitEffect)
        if warn ~= "" then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, warn)
          return
        end
        local linkTrigger = { trigger = self.commitTrigger, outcome = self.commitEffect }
        table.insert(self.Links.savedVarsAcc.links, linkTrigger)
        self.commitTrigger = nil
        self.commitEffect = nil
        self.triggerSelected = nil
        self.outcomeSelected = nil
        self:AddCallbacks()
        panel:UpdateControls()

      end
    })
  panel:AddSetting({
    type = LAM.ST_SECTION,
    label = string.rep("·", 10).." "..IFTTT.Lang.EXISTING_LINKS.." "..string.rep("·", 10)
  })
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = ""
    }
  panel:AddSetting({
    type = LAM.ST_LABEL,
    label = function()
      local linkText = ""
      local linkCounter = 1
      for key, linkItem in pairs(self.Links.savedVarsChar.links) do
        linkText = linkText.."\n"..IFTTT.Lang.CHARACTER.."   "..key.."   "..linkItem.trigger.name.."|r |cf2a705 → |r |c05f2a7"..linkItem.outcome.name
        linkCounter = linkCounter + 1
      end
      RefreshHeight(linkCounter)
      return "|c05f2a7"..linkText.."|r"
    end
  })
  panel:AddSetting({
    type = LAM.ST_LABEL,
    label = function()
      local linkText = ""
      local linkCounter = 1
      for key, linkItem in pairs(self.Links.savedVarsAcc.links) do
        linkText = linkText.."\n"..IFTTT.Lang.ACCOUNT.."   "..key.."   "..linkItem.trigger.name.."|r |c05f2a7 → |r |cf29f05"..linkItem.outcome.name
        linkCounter = linkCounter + 1
      end
      RefreshHeight(linkCounter)
      return "|cf29f05"..linkText.."|r"
    end
  })
  panel:AddSetting({
      type = LAM.ST_DROPDOWN,
      label = IFTTT.Lang.COLLECTIBLE_HEADING,
      items = self.deleteFunc,
      getFunction = function() 
        return self.deleteSelected.name or ""
      end,
      setFunction = function(var, itemName, itemData)
        self.deleteSelected.name = itemName
        self.deleteSelected.data = itemData.data
      end,
  })
  panel:AddSetting({
    type = LAM.ST_BUTTON,
    label = IFTTT.Lang.REMOVE_LINK,
    buttonText = IFTTT.Lang.REMOVE,
    tooltip = IFTTT.Lang.REMOVE_LINK,
    clickHandler = function()
      if not next(self.deleteSelected) then
        self.deleteSelected = self.deleteFunc()[1]
      end
      local deleteParts = self.Split(self.deleteSelected.data)
      if deleteParts[1] == IFTTT.Lang.ACCOUNT then
        self.Links.savedVarsAcc.links[tonumber(deleteParts[2])] = nil
      end
      if deleteParts[1] == IFTTT.Lang.CHARACTER then
        self.Links.savedVarsChar.links[tonumber(deleteParts[2])] = nil
      end
      self.deleteSelected = {}
      panel:UpdateControls()
    end
  })
  panel:AddSetting({
    type = LAM.ST_BUTTON,
    label = IFTTT.Lang.CLEAR_ALL,
    buttonText = IFTTT.Lang.CLEAR,
    tooltip = IFTTT.Lang.CLEAR_ALL,
    clickHandler = function()
      self:RemoveCallbacks()
      self.Links.savedVarsChar.links = {}
      self.Links.savedVarsAcc.links = {}
      panel:UpdateControls()
    end
  })
  self.panel = panel
end
