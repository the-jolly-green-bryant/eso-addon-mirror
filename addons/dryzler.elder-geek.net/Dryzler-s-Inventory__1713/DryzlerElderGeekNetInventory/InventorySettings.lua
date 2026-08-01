local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(...)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(...)
end

local LAM2 = LibAddonMenu2

local Obj = {
  initialized = false,
  Addon = nil,
}

Obj.RESEARCH_SMITHING_WEAPON = GetString(SI_ITEMFILTERTYPE13) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_WEAPONS)
Obj.RESEARCH_SMITHING_ARMOR = GetString(SI_ITEMFILTERTYPE13) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_ARMOR)
Obj.RESEARCH_CLOTHIER_LIGHT = GetString(SI_ITEMFILTERTYPE14) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_LIGHT)
Obj.RESEARCH_CLOTHIER_MEDIUM = GetString(SI_ITEMFILTERTYPE14) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_MEDIUM)
Obj.RESEARCH_WOOD_WEAPON = GetString(SI_ITEMFILTERTYPE15) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_WEAPONS)
Obj.RESEARCH_WOOD_ARMOR = GetString(SI_ITEMFILTERTYPE15) .. "-" .. GetString(SI_DEG_OPT_TRAITSRESEARCHDEATIL_ARMOR)
Obj.RESEARCH_JEWEL = GetString(SI_ITEMFILTERTYPE24)


Obj.toggleAllResearchLineMode = {}
Obj.toggleAllResearchLineMode[1] = "on"
Obj.toggleAllResearchLineMode[2] = "on"
Obj.toggleAllResearchLineMode[3] = "on"
Obj.toggleAllResearchLineMode[4] = "on"
Obj.toggleAllResearchLineMode[5] = "on"
Obj.toggleAllResearchLineMode[6] = "on"
Obj.toggleAllResearchLineMode[7] = "on"

Obj.toggleAllTraitLineMode = {}
Obj.toggleAllTraitLineMode[1] = "on"
Obj.toggleAllTraitLineMode[2] = "on"
Obj.toggleAllTraitLineMode[3] = "on"
Obj.toggleAllTraitLineMode[4] = "on"
Obj.toggleAllTraitLineMode[5] = "on"
Obj.toggleAllTraitLineMode[6] = "on"
Obj.toggleAllTraitLineMode[7] = "on"
Obj.toggleAllTraitLineMode[8] = "on"
Obj.toggleAllTraitLineMode[9] = "on"


Obj.colHeaderControls = {}
Obj.rowHeaderControls = {}
Obj.cellControls = {}
Obj.cellControlsButtons = {}

function Obj:activateCraftingTypeForChar(charId, craftingType)
  local knowledgeType = "Blacksmithing"
  if craftingType == CRAFTING_TYPE_CLOTHIER then
    knowledgeType = "Clothier"
  end
  if craftingType == CRAFTING_TYPE_WOODWORKING then
    knowledgeType = "Woodworking"
  end
  if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
    knowledgeType = "Jewelry"
  end
       
--  d("activateCraftingTypeForChar;"..tostring(charId)..";")
       
  --d("control="..tostring()  
  local refCheckBoxControl = _G["DEGInventorySettingWantsKnowledge" .. knowledgeType..charId]
   
  --refCheckBoxControl:UpdateValue(false, true)
  refCheckBoxControl.data.setFunc(true, true)
  --refCheckBoxControl.data.setFunc(true, true)
  LAM2.util.RequestRefreshIfNeeded(self.optionsPanel)
end
  

function Obj:updateResearchGrid(craftingTypeLong, charName, boolNoChange)  
  if boolNoChange then
  
  elseif (craftingTypeLong) then
    self.currentCraftingType = craftingTypeLong
  else
    self.currentChar = charName
  end
  
  local charId = self.charNameToCharId[self.currentChar]
--  local numLines = GetNumSmithingResearchLines(craftingType)  
  local numColumnToNumCraftingLine = {}

  numColumnToNumCraftingLine[1] = 1
  numColumnToNumCraftingLine[2] = 2
  numColumnToNumCraftingLine[3] = 3
  numColumnToNumCraftingLine[4] = 4
  numColumnToNumCraftingLine[5] = 5
  numColumnToNumCraftingLine[6] = 6
  numColumnToNumCraftingLine[7] = 7
  
  
  local bAdjustNumColumnToNumCraftingLine = false
  local craftingType = CRAFTING_TYPE_BLACKSMITHING
  
  if self.currentCraftingType == self.RESEARCH_SMITHING_ARMOR then
    craftingType = CRAFTING_TYPE_BLACKSMITHING
    bAdjustNumColumnToNumCraftingLine = true
  end  
  
  if self.currentCraftingType == self.RESEARCH_CLOTHIER_LIGHT then
    craftingType = CRAFTING_TYPE_CLOTHIER
  end
  if self.currentCraftingType == self.RESEARCH_CLOTHIER_MEDIUM then
    craftingType = CRAFTING_TYPE_CLOTHIER
    bAdjustNumColumnToNumCraftingLine = true
  end
  
  if self.currentCraftingType == self.RESEARCH_WOOD_WEAPON then
    craftingType = CRAFTING_TYPE_WOODWORKING
  end
  if self.currentCraftingType == self.RESEARCH_WOOD_ARMOR then
    craftingType = CRAFTING_TYPE_WOODWORKING
--    bAdjustNumColumnToNumCraftingLine = true
    numColumnToNumCraftingLine[1] = 6
    numColumnToNumCraftingLine[2] = 7
    numColumnToNumCraftingLine[3] = 8
    numColumnToNumCraftingLine[4] = 9
    numColumnToNumCraftingLine[5] = 10
    numColumnToNumCraftingLine[6] = 11
    numColumnToNumCraftingLine[7] = 12
  end 
  
  if self.currentCraftingType == self.RESEARCH_JEWEL then
    craftingType = CRAFTING_TYPE_JEWELRYCRAFTING  
  end

  if (bAdjustNumColumnToNumCraftingLine) then
    numColumnToNumCraftingLine[1] = 8
    numColumnToNumCraftingLine[2] = 9
    numColumnToNumCraftingLine[3] = 10
    numColumnToNumCraftingLine[4] = 11
    numColumnToNumCraftingLine[5] = 12
    numColumnToNumCraftingLine[6] = 13
    numColumnToNumCraftingLine[7] = 14  
  end

  --paint workload columns --------------------------------------------------------------------------------------------
  local maxColumns = 7
  local maxRows = 9  
  
  for numColumn = 1, maxColumns do
    local doColumn = true  
    if self.currentCraftingType == self.RESEARCH_WOOD_WEAPON then
      if numColumn > 5 then
        doColumn = false
      end
    end 
    
    local researchLineIndex = numColumnToNumCraftingLine[numColumn]
    
    --paint columnHeader    
    local control = self.colHeaderControls[numColumn]
    local name, icon, _, _ = GetSmithingResearchLineInfo(craftingType, researchLineIndex)  -- Get info on that specific item

    control.craftingType = craftingType
    control.researchLineIndex = researchLineIndex
    control.text = zo_strformat("<<1:C>>", name)

    local bColumnIsValid = true
    if (icon ~= "/esoui/art/icons/icon_missing.dds" and doColumn) then
      control:SetNormalTexture(icon)
      control:SetHidden(false)
    else 
      control:SetNormalTexture("")
      control:SetHidden(true)
      bColumnIsValid = false
    end
    
    for numRow = 1, maxRows do
      local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLineIndex,numRow) -- weapons
        
      local control = self.cellControls[numColumn][numRow]      
      local controlButton = self.cellControlsButtons[numColumn][numRow]
      
      controlButton.craftingType = craftingType
      controlButton.researchLineIndex = researchLineIndex
      controlButton.tType = tType
      
      control.craftingType = craftingType
      control.researchLineIndex = researchLineIndex
      control.tType = tType
      control.isDegSetup = true
      
      control:SetColor(1, 1, 1, 0.4)      
      if tType then
        if self.Addon:traitWanted(craftingType, researchLineIndex, tType, charId) then
          control:SetColor(0, 1, 1, 1)
        end
      end
      
      if bColumnIsValid then
        control:SetHidden(false)
        controlButton:SetHidden(false)
        
        local controlRowHeader = self.rowHeaderControls[numRow]    
        
        controlRowHeader.craftingType = craftingType
        controlRowHeader.nTrait = tType
        
        local _,name,icon =  GetSmithingTraitItemInfo(tType + 1)
--        control.text = name
        --controlRowHeader.text = zo_strformat("<<1:C>>", tDesc)
        
        controlRowHeader.text = GetString("SI_ITEMTRAITTYPE", tType) .. "\n\n" ..zo_strformat("<<1:C>>", tDesc) 
        controlRowHeader:SetNormalTexture(icon)
      else
        control:SetHidden(true)
        controlButton:SetHidden(true)
      end
    end
  end
end

function Obj:toggleResearchLineWanted(theButton)
  d("toggleResearchLineWanted: "..tostring(theButton.craftingType))

  local maxColumns = 7
  local maxRows = 9
  
  local craftingType = theButton.craftingType
  local researchLineIndex = theButton.researchLineIndex
  local numColumn = theButton.numColumn
  --controlRowHeader.craftingType = craftingType
  --controlRowHeader.researchLineIndex = researchLineIndex       
  
  local charId = self.charNameToCharId[self.currentChar]
  
  local boolWantsTrait = false
  if self.toggleAllResearchLineMode[numColumn] == "on" then
    boolWantsTrait = true
    self.toggleAllResearchLineMode[numColumn] = "off"
  else    
    self.toggleAllResearchLineMode[numColumn] = "on"    
  end
  
  if boolWantsTrait then
    self:activateCraftingTypeForChar(charId,craftingType)
  end
  
  for numRow = 1, maxRows do
    local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLineIndex,numRow) -- weapons
    self.Addon:setTraitWanted(craftingType, researchLineIndex, tType, charId, boolWantsTrait)
  end
  
  self:updateResearchGrid(nil, nil, true)
end

function Obj:toggleTraitLineWanted(theButton)
  d("toggleTraitLineWanted: "..tostring(theButton.craftingType))

  local maxColumns = 7
  local maxRows = 9
  
  local craftingType = theButton.craftingType
  local tType = theButton.nTrait
  local numRow = theButton.numRow
  --controlRowHeader.craftingType = craftingType
  --controlRowHeader.researchLineIndex = researchLineIndex       
  
  local charId = self.charNameToCharId[self.currentChar]
  
  local boolWantsTrait = false
  if self.toggleAllTraitLineMode[numRow] == "on" then
    boolWantsTrait = true
    self.toggleAllTraitLineMode[numRow] = "off"
  else    
    self.toggleAllTraitLineMode[numRow] = "on"    
  end
  
  if boolWantsTrait then
    self:activateCraftingTypeForChar(charId,craftingType)
  end  
  
  for numColumn = 1, maxColumns do
--    local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLineIndex,numRow) -- weapons
    local control = self.cellControls[numColumn][numRow]
    self.Addon:setTraitWanted(craftingType, control.researchLineIndex, tType, charId, boolWantsTrait)
  end
  
  self:updateResearchGrid(nil, nil, true)
end

function Obj:toggleTraitWanted(theButton)
  d("toggleTraitWanted: craftingType="..tostring(theButton.craftingType))
  d("toggleTraitWanted: researchLineIndex="..tostring(theButton.researchLineIndex))
  d("toggleTraitWanted: tType="..tostring(theButton.tType))
  
--      controlButton.craftingType = craftingType
--      controlButton.researchLineIndex = researchLineIndex
--      controlButton.tType = tType  

  local charId = self.charNameToCharId[self.currentChar]
  
  local lastValue = self.Addon:traitWanted(theButton.craftingType, theButton.researchLineIndex, theButton.tType, charId)
  
  if (lastValue) then
    self.Addon:setTraitWanted(theButton.craftingType, theButton.researchLineIndex, theButton.tType, charId, false)
  else
    self.Addon:setTraitWanted(theButton.craftingType, theButton.researchLineIndex, theButton.tType, charId, true)
    self:activateCraftingTypeForChar(charId, theButton.craftingType)
  end
  
  self:updateResearchGrid(nil, nil, true)
end

function Obj:initializeResearchGrid()
  --local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, DEGSettingsResearchGrid, "ZO_DefaultButton")
  --button:SetDimensions(100, 100)
  --button:SetWidth(100)
  --button:SetText("huhu")
  --button:SetAnchor(CENTER, DEGSettingsResearchGrid, CENTER, 0, 0)
        
  local maxColumns = 7
  local maxRows = 9
  
  local width = 30
  local height = 30
  local offset = 10


  --local craftingType = CRAFTING_TYPE_BLACKSMITHING 

  local numLines = GetNumSmithingResearchLines(craftingType)
  --d("numLines="..tostring(numLines))



  --paint top left
--  local control =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_TEXTURE)
--  control:SetDimensions(width, height)
  --button:SetAnchor(TOP, 0, BOTTOM, 0)
--  control:SetAnchor(TOPLEFT, DEGSettingsResearchGrid, 0, 0)
--  control:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box

  --paint column headers -------------------------------------------------------------------------------------------- 
  for numColumn = 1, maxColumns do
--      local researchLineIndex = numColumnToNumCraftingLine[numColumn]
      local x = numColumn
      local y = 0
      local offsetX = x * offset
      local offsetY = y * offset
        
                
      local control =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_BUTTON)
      control:SetDimensions(width, height)
      control:SetAnchor(TOPLEFT, DEGSettingsResearchGrid, TOPLEFT, x * width + offsetX, y * height + offsetY)
      control:SetMouseOverTexture("esoui/art/buttons/generic_highlight.dds")
      control:SetHandler("OnClicked", function (self)
        Obj:toggleResearchLineWanted(self)
      end)      
      control:SetHandler("OnMouseEnter", function (self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, self.text)
      end)
      control:SetHandler("OnMouseExit", function (self)
        ZO_Tooltips_HideTextTooltip()
      end)      
      
      control.numColumn = numColumn
      
      self.colHeaderControls[numColumn] = control
        
  end
      
  --paint row headers --------------------------------------------------------------------------------------------
  for numRow = 1, maxRows do
--      local researchLineIndex = numColumnToNumCraftingLine[1] 
      local x = 0
      local y = numRow
      local offsetX = x * offset
      local offsetY = y * offset
        
--      local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLineIndex,numRow) -- weapons
--      local _,_,icon = GetSmithingTraitItemInfo(tType + 1)
                       
      local control =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_BUTTON )
      control:SetDimensions(width, height)
      control:SetAnchor(TOPLEFT, DEGSettingsResearchGrid, TOPLEFT, x * width + offsetX, y * height + offsetY)
--      control:SetTexture(icon)
      control:SetMouseOverTexture("esoui/art/buttons/generic_highlight.dds")
      
      control:SetHandler("OnClicked", function (self)
        Obj:toggleTraitLineWanted(self)
      end)
            
      control:SetHandler("OnMouseEnter", function (self)
        --Obj.colHeaderControls[numColumn]
        ZO_Tooltips_ShowTextTooltip(self, TOP, self.text)
      end)
      control:SetHandler("OnMouseExit", function (self)
        ZO_Tooltips_HideTextTooltip()
--        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_ROTATE)
      end)

      control.numRow = numRow

      self.rowHeaderControls[numRow] = control
  end

  --paint workload columns --------------------------------------------------------------------------------------------
  for numColumn = 1, maxColumns do  
--    local researchLineIndex = numColumnToNumCraftingLine[numColumn]
    for numRow = 1, maxRows do
--      local tType, tDesc, bKnown = GetSmithingResearchLineTraitInfo(craftingType,researchLineIndex,numRow) -- weapons
      local x = numColumn
      local y = numRow - 1 + 1      
            
      local offsetX = x * offset
      local offsetY = y * offset
    
             
      local control =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_BUTTON)
      control:SetDimensions(width, height)
      control:SetAnchor(TOPLEFT, DEGSettingsResearchGrid, TOPLEFT, x * width + offsetX, y * height + offsetY)
      control:SetMouseOverTexture("esoui/art/buttons/generic_highlight.dds")      
      control:SetHandler("OnClicked", function (self)
        Obj:toggleTraitWanted(self)
      end)      
      control:SetHandler("OnMouseEnter", function (self)
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_ERASE)
      end)
      control:SetHandler("OnMouseExit", function (self)
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DEFAULT_CURSOR)      
      end)      
      
      
      local control1 =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_TEXTURE)
      control1:SetDimensions(width, height)
      control1:SetAnchor(TOPLEFT, DEGSettingsResearchGrid, TOPLEFT, x * width + offsetX, y * height + offsetY)
      control1:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box
      control1:SetColor(1, 1, 1, 0.4)
      
      if (not Obj.cellControls[numColumn]) then
        Obj.cellControls[numColumn]={}
      end
      if (not Obj.cellControls[numColumn][numRow]) then
        Obj.cellControls[numColumn][numRow] = {}
      end
      Obj.cellControls[numColumn][numRow] = control1

      if (not Obj.cellControlsButtons[numColumn]) then
        Obj.cellControlsButtons[numColumn]={}
      end
      if (not Obj.cellControlsButtons[numColumn][numRow]) then
        Obj.cellControlsButtons[numColumn][numRow] = {}
      end
      Obj.cellControlsButtons[numColumn][numRow] = control      

      --local inside =WINDOW_MANAGER:CreateControl(nil, DEGSettingsResearchGrid, CT_TEXTURE)
      --inside:SetDimensions(width, height)
      --button:SetAnchor(TOP, 0, BOTTOM, 0)
      --inside:SetAnchor(CENTER, control, CENTER, 0, 0)
      --inside:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box
      --inside:SetColor(0, 1, 1, 1)
      
    end
  end 
end



function Obj:makeSubControlsForChars(knowledgeType)
  --knowledgeType == "provisioning" || 
  local subcontrols = {}
  
  for charid,tblChar in pairs(self.Addon.savedVariablesChars.chars) do
    table.insert(subcontrols, {
        type = "checkbox",
        name = tblChar.name,
        default = true,
        getFunc = function()
          return self.Addon:wantsKnowledge(knowledgeType, charid) 
        end,
        setFunc = function(newValue, bIsFromMe) 
          self.Addon:setWantsKnowledge(knowledgeType, charid, newValue, bIsFromMe)
          --if not bIsFromMe then
          self:updateResearchGrid(nil, nil, true)
          --end
        end,
        reference = "DEGInventorySettingWantsKnowledge" .. knowledgeType..charid,
        requiresReload = false,
        registerForRefresh = true
    })
  end
  
  return subcontrols
end

function Obj:initialize()
  if self.initialized then return end
  
  self.Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
              
  local optionsPanelConfig  = {
    type = "panel",
    name = "Dryzler's Inventory",
    displayName = "|c3f95ffDryzler's|r |cEFEBBEInventory|r",
    author = "|cEFEBBEDryzler|r",
    website = "https://dryzler.com/",
    version = self.Addon.versionString,
    slashCommand = "/dryinv",
    registerForRefresh = true,
    registerForDefaults = false,
  }

  self.optionsPanel = LAM2:RegisterAddonPanel(self.Addon.name, optionsPanelConfig)
  
  local optionsPanelControls = {}
        
  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_RECIPES)..", "..GetString(SI_DEG_STYLES).." & "..GetString(SI_RECIPECRAFTINGSYSTEM2),
  })  
  table.insert(optionsPanelControls, {
      type = "description",
      text = GetString(SI_DEG_RECIPES_STYLES_DESCRIPTION),
  })
    
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_DEG_STYLES),
    controls = self:makeSubControlsForChars("Styles")
  })  
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE13),
    controls = self:makeSubControlsForChars("Blacksmithing")
  })  
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE14),
    controls = self:makeSubControlsForChars("Clothier")
  })
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE15),
    controls = self:makeSubControlsForChars("Woodworking")
  })  
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE16),
    controls = self:makeSubControlsForChars("Alchemy")
  })
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE17),
    controls = self:makeSubControlsForChars("Enchanting")
  })
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE18),
    controls = self:makeSubControlsForChars("Provisioning")
  })
  table.insert(optionsPanelControls, {
    type = "submenu",
    name = GetString(SI_ITEMFILTERTYPE24),
    controls = self:makeSubControlsForChars("Jewelry")
  })


  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_OPT_MISC_HEADER),
  })
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_SELLORNATE_LABEL),
      default = self.Addon.savedVariablesAccount.settings.sellOrnate,
      getFunc = function()
        return not self.Addon.savedVariablesAccount.settings.sellOrnate == false 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.sellOrnate = newValue
      end,
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_SELLTRAITLESS_LABEL),
      default = self.Addon.savedVariablesAccount.settings.sellTraitless,
      getFunc = function()
        return not self.Addon.savedVariablesAccount.settings.sellTraitless == false 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.sellTraitless = newValue
      end,
  })
  
      table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_SELLSTOLEN_LABEL),
      default = self.Addon.savedVariablesAccount.settings.sellStolen,
      getFunc = function()
        return not self.Addon.savedVariablesAccount.settings.sellStolen == false 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.sellStolen = newValue
      end,
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_DECOMP_LABEL),
      default = self.Addon.savedVariablesAccount.settings.decompAll,
      getFunc = function()
        return not self.Addon.savedVariablesAccount.settings.decompAll == false 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.decompAll = newValue
      end,
  })
  
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_DECOMPTRAITLESS_LABEL),
    default = self.Addon.savedVariablesAccount.settings.decompTraitless,
    getFunc = function()
      return not self.Addon.savedVariablesAccount.settings.decompTraitless == false 
    end,
    setFunc = function(newValue)
      self.Addon.savedVariablesAccount.settings.decompTraitless = newValue
    end,
  })
  
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_DECOMPORNATE_LABEL),
    default = self.Addon.savedVariablesAccount.settings.decompOrnate,
    getFunc = function()
      return not self.Addon.savedVariablesAccount.settings.decompOrnate == false 
    end,
    setFunc = function(newValue)
      self.Addon.savedVariablesAccount.settings.decompOrnate = newValue
    end,
  })  
  

--  table.insert(optionsPanelControls, {
--    type = "checkbox",
--    name = GetString(SI_DEG_OPT_DECOMPTRAITSKNOWN_LABEL),
--    --@todo tooltip
--    default = self.Addon.savedVariablesAccount.settings.decompTraitsResearched,
--    getFunc = function()
--      return self.Addon.savedVariablesAccount.settings.decompTraitsResearched 
--    end,
--    setFunc = function(newValue)
--      self.Addon.savedVariablesAccount.settings.decompTraitsResearched = newValue
--      --muss reloaden
--    end,
--  })
  
  
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_ICONS_LABEL),
    default = self.Addon.savedVariablesAccount.settings.icons,
    getFunc = function()
      return not self.Addon.savedVariablesAccount.settings.icons == false 
    end,
    setFunc = function(newValue)
      self.Addon.savedVariablesAccount.settings.icons = newValue
    end,
  })
    
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_KNOWLEDGE_LABEL),
    default = self.Addon.savedVariablesAccount.settings.knowledge,
    getFunc = function()
      return not self.Addon.savedVariablesAccount.settings.knowledge == false 
    end,
    setFunc = function(newValue)
      self.Addon.savedVariablesAccount.settings.knowledge = newValue
    end,
  })
  
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_KNOWLEDGETT_LABEL),
    default = self.Addon.savedVariablesAccount.settings.knowledgeTooltip,
    getFunc = function()
      return not self.Addon.savedVariablesAccount.settings.knowledgeTooltip == false 
    end,
    setFunc = function(newValue)
      self.Addon.savedVariablesAccount.settings.knowledgeTooltip = newValue
    end,
  })  
  
  table.insert(optionsPanelControls, {
    type = "checkbox",
    name = GetString(SI_DEG_OPT_AIRG_LABEL),
    default = true,
    getFunc = function()
      return self.Addon:getAIRG() 
    end,
    setFunc = function(newValue)
      self.Addon:setAIRG(newValue)
    end,
  })  

  
  table.insert(optionsPanelControls, {
      type = "header",
      name = GetString(SI_DEG_OPT_TRAITSRESEARCHDEATILSDETAILS_HEADER),
  })  
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_TRAITSRESEARCH),
      default = self.Addon.vars.defaultsAccount.settings.traitResearch,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.traitResearch 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.traitResearch = newValue
      end,
  })                         
  
  table.insert(optionsPanelControls, {
      type = "checkbox",
      name = GetString(SI_DEG_OPT_TRAITSRESEARCH_TOOLTIP),
      default = self.Addon.vars.defaultsAccount.settings.traitsTooltip,
      getFunc = function()
        return self.Addon.savedVariablesAccount.settings.traitsTooltip 
      end,
      setFunc = function(newValue)
        self.Addon.savedVariablesAccount.settings.traitsTooltip = newValue
      end,
  })  
     
  table.insert(optionsPanelControls, {
      type = "description",
      text = GetString(SI_DEG_OPT_TRAITSRESEARCHDEATILS_DESC),
  })  
  
  self.currentCraftingType = Obj.RESEARCH_SMITHING_WEAPON
  self.currentChar = Obj.RESEARCH_SMITHING_WEAPON

  local choices = {}
  table.insert(choices, self.RESEARCH_SMITHING_WEAPON)
  table.insert(choices, self.RESEARCH_SMITHING_ARMOR)
  
  table.insert(choices, self.RESEARCH_CLOTHIER_LIGHT)
  table.insert(choices, self.RESEARCH_CLOTHIER_MEDIUM)
  
  table.insert(choices, self.RESEARCH_WOOD_WEAPON)
  table.insert(choices, self.RESEARCH_WOOD_ARMOR)
  
  table.insert(choices, self.RESEARCH_JEWEL)
  
  
  table.insert(optionsPanelControls, {
    type = "dropdown",
    name = "Skill",
    choices = choices,
    getFunc = function()
      return Obj.currentCraftingType
    end,
    setFunc = function(newValue)
      self:updateResearchGrid(newValue)
    end,
    default = function()
      return self.RESEARCH_SMITHING_WEAPON
    end,
    width = "half",
    disabled = function() 
      return false
    end,
    reference = "DEGInvSettingDropSkill"
  })

  local choices = {}
  --table.insert(choices, GetString(SI_DEG_OPT_ALL))
  
  self.charNameToCharId = {}
  self.charNameToCharId[GetString(SI_DEG_OPT_ALL)] = nil
--  self.currentChar = GetString(SI_DEG_OPT_ALL)
  self.currentChar = nil
  
  for i=1,GetNumCharacters() do
    local charName, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo(i)
    charName = charName:sub(1, charName:find("%^") - 1)
    table.insert(choices, charName)
    self.charNameToCharId[charName] = charId
    if not self.currentChar then
      self.currentChar = charName
    end    
  end

  table.insert(optionsPanelControls, {
    type = "dropdown",
    name = "Character",
    choices = choices,
    getFunc = function()
      return self.currentChar
    end,
    setFunc = function(newValue)
      self:updateResearchGrid(nil, newValue)
    end,
    default = function()
      return GetString(SI_DEG_OPT_ALL)
    end,
    width = "half",
    disabled = function() 
      return false
    end,
  })

  table.insert(optionsPanelControls, {
    type = "custom",
    reference = "DEGSettingsResearchGrid", -- unique name for your control to use as reference (optional)
    refreshFunc = function(control) 
      d("refresh")         
                        
    end,
    width = "full"
  })


  LAM2:RegisterOptionControls(self.Addon.name, optionsPanelControls)
  
  self.initialized = true
end


local function addonMenuOnLoadCallback(panel)
  if panel == Obj.optionsPanel then
    --UnRegister the callback for the LAM2 panel created function
    
    Obj:initializeResearchGrid()
    Obj:updateResearchGrid(Obj.RESEARCH_SMITHING_WEAPON)
        
    CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)   
  end
end
CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)

_G[_G["DEG_CURRENT_ADDON"].ADDON_NAME.."Settings"] = Obj