-------------------------------------------------------------------------------
--[[License:
LootWall by Vicodine ("add-on")

"Add-on" is provided to anyone, free of charge
Anyone obtaining a digital copy of "Contents" of the add-on is hereby granted permission of use and/or modification of any of the "Contents"
"Contents" of the "Add-On" package are source code, and documentation of the "Add-On", excluding libraries included in the package's sub-directories with their own respective licenses, which may vary
--]]
--[[CHANGELOG:
v0.7
      + added circonian's LibNeed4Research
      + added presets for Researchable Cloth, WW and BS
      + added defaults for Researchable
      + added trait text to prompt window
v0.6.1 Hotfix Release
      - Removed message ignoreSource meant as debug
      + added Vendor Trash and Fishing Bait presets
v0.6  + Locale/Default.lua
      + Preparation for translations
      + On/Off for "Keep x" replaced with choices of Prompt/Destroy/Junk/Keep
      + Versioning of savedVariablesVersion
      + Update to SavedVars version 2 to migrate checkboxes to dropdowns
      + LootWall:PresetToAction(preset) returns action
      + LootWall:IsInRange(value,range) for checking whether parameter value is contained in range, useful for options
      + better starting window position (200,200 instead of 0,0)
      * rewritten LootWall:DefaultActionForLink(itemLink) to accomodate for dropdowns instead of true/false
      * moved config initialization a bit up in execution
      bug: cursor dissapears by moving window after being toggled on by the add-on
      bug: if you junk a stolen item, it will always try to sell and fail at vendor until you get rid of the stolen item at fence/by hand
v0.5 - proof-read, ready for public release, can't hide the cursor, it just breaks everything, but still can show it
v0.4 - Defaults, DeleteRules,ShowCursor option, keep x_proffesion mats option, keep nirn,ornate,intricate, keep racial
v0.3 - Settings complete and working, AutoSell junk, quality thresholds, update only each 250ms for slower machines
v0.2 - added LibAddonMenu-2 and LibStub, ItemType, ItemSubtype, SellValue in tooltip, buffer for displaying items, display when out of combat
v0.1 - first try, the initial layout
--]]
-------------------------------------------------------------------------------
--The DroppedItem 
--@itemLink
--@bagId
--@slotId
LWDroppedItem = {}
-------------------------------------------------------------------------------
--the constructor
--inItemLink - the looted item item link, duh
--inBagId - the looted item bagId, should be player`s inventory
--inSlotId - the slot in given bagId where the item has gone
function LWDroppedItem:new(inItemLink,inBagId,inSlotId)
  local self = setmetatable({},LWDroppedItem)
  self.itemLink = inItemLink
  self.bagId=inBagId
  self.slotId=inSlotId
  return self
end
-------------------------------------------------------------------------------
--unused - nevermind :)
function LWDroppedItem:setItemLink(inItemLink)
  self.itemLink = inItemLink
end
-------------------------------------------------------------------------------
--unused - nevermind :)
function LWDroppedItem:setBagId(inBagId)
  self.bagId=inBagId
end
-------------------------------------------------------------------------------
--unused - nevermind :)
function LWDroppedItem:setSlotId(inSlotId)
  self.slotId=inSlotId
end
-------------------------------------------------------------------------------
--unused - nevermind :)
function LWDroppedItem:getItemName()
  return GetItemLinkName(self.itemLink)
end
-------------------------------------------------------------------------------
--unused - nevermind :)
function LWDroppedItem:getItemNameF(format)
  if format=="" then
    format = "<<t:1>>"
  end

  return zo_strformat(format,self:getItemName())
end
-------------------------------------------------------------------------------
--the main class container (table)
-------------------------------------------------------------------------------
--variables
LootWall = {}
--LootWall.currentWidnowID = 0 --nope
LootWall.name = "LootWall"
LootWall.version = "0.7"
LootWall.savedVarsVersion = 4
LootWall.Window={}
LootWall.Buffer={}
LootWall.LAM = LibStub("LibAddonMenu-2.0")
LootWall.NfR = LibStub("LibNeed4Research") 
LootWall.gameCameraInactive = false
LootWall.ignoreLoot = false
-------------------------------------------------------------------------------
--"constants"
local LW_CONF_IGNORE_BANK = "ignoreBank"
local LW_CONF_IGNORE_GUILDBANK = "ignoreGuildBank"
local LW_CONF_IGNORE_FENCE = "ignoreFence"
local LW_CONF_IGNORE_SHOP = "ignoreMerchants"
local LW_CONF_IGNORE_CRAFT = "ignoreCrafting"
local LW_CONF_IGNORE_MAIL = "ignoreMail"

local LW_UPDATE_INTERVAL
--button actions
local LW_ACTION_UNDEFINED = 0
local LW_ACTION_KEEP_ALWAYS = 10
local LW_ACTION_KEEP_NOW = 11
local LW_ACTION_TRASH_ALWAYS = 20
local LW_ACTION_TRASH_NOW = 21
local LW_ACTION_DESTROY_ALWAYS = 30
local LW_ACTION_DESTROY_NOW = 31

local LW_CONF_QUALITY_THRESHOLD = "qualityThreshold"
local LW_CONF_KEEPORNATE = "keepOrnate"
local LW_CONF_KEEPNIRN = "keepNirnhoned"
local LW_CONF_KEEPINSP = "keepInspired"
local LW_CONF_SELLJUNK = "sellJunk"
local LW_CONF_KEEPCLOTHMAT = "keepClothingMaterials"
local LW_CONF_KEEPBSMAT = "keepBlacksmithMaterials"
local LW_CONF_KEEPALCHMAT = "keepAlchemyMaterials"
local LW_CONF_KEEPENCHMAT = "keepEnchantingMaterials"
local LW_CONF_KEEPPROVMAT = "keepPrivisioningMaterials"
local LW_CONF_KEEPWWMAT = "keepWoodworkingMaterials"
local LW_CONF_KEEPSTYLEMATS = "keepStyleMaterials"
local LW_CONF_SHOWCURSOR = "showIngameCursor"
--+0.6.1
local LW_CONF_KEEPTRASH = "keepTrash"
local LW_CONF_KEEPBAIT = "keepBait"
--*0.6.1
--+0.7
local LW_CONF_KEEPRES_CLOTH = "keepClothierResearch"
local LW_CONF_KEEPRES_WW = "keepWoodworkResearch"
local LW_CONF_KEEPRES_BS = "keepBlacksmithResearch"
--*0.7

local LW_PRESET_ACTION_PROMPT = 0
local LW_PRESET_ACTION_DESTROY = 1
local LW_PRESET_ACTION_JUNK = 2
local LW_PRESET_ACTION_KEEP = 3

local LW_PRESET_ACTION_STRING = {
  [0] = GetString(LWS_PRESET_CHOICE_PROMPT),
  [1] = GetString(LWS_PRESET_CHOICE_DESTROY),
  [2] = GetString(LWS_PRESET_CHOICE_JUNK),
  [3] = GetString(LWS_PRESET_CHOICE_KEEP)
}


local LW_CONF_TRANSLATE_QUALITY = {
  [ITEM_QUALITY_ARCANE]=GetItemQualityColor(ITEM_QUALITY_ARCANE):Colorize("Arcane"),
  [ITEM_QUALITY_ARTIFACT]=GetItemQualityColor(ITEM_QUALITY_ARTIFACT):Colorize("Artifact"),
  [ITEM_QUALITY_MAGIC]=GetItemQualityColor(ITEM_QUALITY_MAGIC):Colorize("Magic"),
  [ITEM_QUALITY_LEGENDARY]=GetItemQualityColor(ITEM_QUALITY_LEGENDARY):Colorize("Legendary"),
  [ITEM_QUALITY_NORMAL]=GetItemQualityColor(ITEM_QUALITY_NORMAL):Colorize("Normal"),
  [ITEM_QUALITY_TRASH]=GetItemQualityColor(ITEM_QUALITY_TRASH):Colorize("Trash")
}

local LW_CONF_DEFAULTS = {
  [LW_CONF_QUALITY_THRESHOLD] = ITEM_QUALITY_ARCANE,
  [LW_CONF_KEEPORNATE] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPNIRN] = LW_PRESET_ACTION_KEEP,
  [LW_CONF_KEEPINSP] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_SELLJUNK] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPCLOTHMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPBSMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPALCHMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPENCHMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPPROVMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPWWMAT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPSTYLEMATS] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_SHOWCURSOR] = true,
  [LW_CONF_IGNORE_BANK] = true,
  [LW_CONF_IGNORE_GUILDBANK] = true,
  [LW_CONF_IGNORE_CRAFT] = true,
  [LW_CONF_IGNORE_FENCE] = true,
  [LW_CONF_IGNORE_MAIL] = true,
  [LW_CONF_IGNORE_SHOP] = true,
  [LW_CONF_KEEPBAIT] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPTRASH] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPRES_CLOTH] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPRES_WW] = LW_PRESET_ACTION_PROMPT,
  [LW_CONF_KEEPRES_BS] = LW_PRESET_ACTION_PROMPT
}
-------------------------------------------------------------------------------
function LootWall:Initialize()
  self.savedVariables = ZO_SavedVars:New("LWSavedVars", 1, nil, {})

  if self.savedVariables.conf == nil then
    self.savedVariables.conf = {}
    self:DefaultConfig()
    self.savedVariables.conf.version = self.savedVarsVersion
    self.savedVariables.wLeft = 200
    self.savedVariables.wTop = 200
  end

  local svVersion
  if self.savedVariables.conf.version == nil then
    svVersion = 0
  else
    svVersion = self.savedVariables.conf.version
  end

  if svVersion < self.savedVarsVersion then
    --update to version 2
    if svVersion < 2 then
      self.savedVariables.conf[LW_CONF_KEEPORNATE] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPORNATE])
      self.savedVariables.conf[LW_CONF_KEEPNIRN] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPNIRN])
      self.savedVariables.conf[LW_CONF_KEEPINSP] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPINSP])
      self.savedVariables.conf[LW_CONF_SELLJUNK] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_SELLJUNK])
      self.savedVariables.conf[LW_CONF_KEEPCLOTHMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPCLOTHMAT])
      self.savedVariables.conf[LW_CONF_KEEPBSMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPBSMAT])
      self.savedVariables.conf[LW_CONF_KEEPALCHMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPALCHMAT])
      self.savedVariables.conf[LW_CONF_KEEPENCHMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPENCHMAT])
      self.savedVariables.conf[LW_CONF_KEEPPROVMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPPROVMAT])
      self.savedVariables.conf[LW_CONF_KEEPWWMAT] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPWWMAT])
      self.savedVariables.conf[LW_CONF_KEEPSTYLEMATS] = self:ConvertToV2(self.savedVariables.conf[LW_CONF_KEEPSTYLEMATS])
      self.savedVariables.conf[LW_CONF_SHOWCURSOR] = true
      self.savedVariables.conf[LW_CONF_IGNORE_BANK] = true
      self.savedVariables.conf[LW_CONF_IGNORE_GUILDBANK] = true
      self.savedVariables.conf[LW_CONF_IGNORE_CRAFT] = true
      self.savedVariables.conf[LW_CONF_IGNORE_FENCE] = true
      self.savedVariables.conf[LW_CONF_IGNORE_MAIL] = true
      self.savedVariables.conf[LW_CONF_IGNORE_SHOP] = true
      --d(GetString(LWS_TEXT_SETTINGSCHANGED))
    end
    
    if svVersion < 3 then
      self.savedVariables.conf[LW_CONF_KEEPBAIT] = LW_CONF_DEFAULTS[LW_CONF_KEEPBAIT]
      self.savedVariables.conf[LW_CONF_KEEPTRASH] = LW_CONF_DEFAULTS[LW_CONF_KEEPTRASH]
    end
    
    if svVersion < 4 then
      self.savedVariables.conf[LW_CONF_KEEPRES_BS] = LW_CONF_DEFAULTS[LW_CONF_KEEPRES_BS]
      self.savedVariables.conf[LW_CONF_KEEPRES_CLOTH] = LW_CONF_DEFAULTS[LW_CONF_KEEPRES_CLOTH]
      self.savedVariables.conf[LW_CONF_KEEPRES_WW] = LW_CONF_DEFAULTS[LW_CONF_KEEPRES_WW]
    end
    
    self.savedVariables.conf.version = self.savedVarsVersion
  end
  --LAM
  local panelData = {
    type = "panel",
    name = "LootWall",
    author = "Vicodine",
    slashCommand = "/lootwall",
    version = self.version,
    registerForDefaults = true,
    resetFunc = function() self:DefaultConfig() end
  }
  self.LAM:RegisterAddonPanel("LootWallOptions", panelData)

  local optionsControls = {
    [1]={
      type = "description",
      title = GetString(LWS_DESCRIPTION_TITLE),
      text = GetString(LWS_DESCRIPTION)
    },
    [2]={
      type = "header",
      name = GetString(LWS_GENERAL_SETTINGS),
    },
    [3]={
      type = "dropdown",
      name = GetString(LWS_QUALITY_THRESHOLD),
      tooltip = GetString(LWS_QUALITY_THRESHOLD_TOOLTIP),
      choices = {LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_TRASH],LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_NORMAL],LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_MAGIC],LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_ARCANE],LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_ARTIFACT],LW_CONF_TRANSLATE_QUALITY[ITEM_QUALITY_LEGENDARY]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_QUALITY_THRESHOLD) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_QUALITY_THRESHOLD,value) end
    },
    [4]={
      type = "dropdown",
      name = GetString(LWS_PRESET_ORNATE),
      tooltip = GetString(LWS_PRESET_ORNATE_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPORNATE) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPORNATE,value) end
    },
    [5]={
      type = "dropdown",
      name = GetString(LWS_PRESET_INTRICATE),
      tooltip = GetString(LWS_PRESET_INTRICATE_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPINSP) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPINSP,value) end
    },
    [6]={
      type = "dropdown",
      name = GetString(LWS_PRESET_NIRNHONED),
      tooltip = GetString(LWS_PRESET_NIRNHONED_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPNIRN) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPNIRN,value) end
    },
    [7]={
      type = "dropdown",
      name = GetString(LWS_PRESET_TRASH),
      tooltip = GetString(LWS_PRESET_TRASH_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPTRASH) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPTRASH,value) end
    },
    [8]={
      type = "dropdown",
      name = GetString(LWS_PRESET_BAIT),
      tooltip = GetString(LWS_PRESET_BAIT_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPBAIT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPBAIT,value) end
    },
    [9]={
      type = "checkbox",
      name = GetString(LWS_PRESET_SELLJUNK),
      tooltip = GetString(LWS_PRESET_SELLJUNK_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_SELLJUNK) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_SELLJUNK,value) end
    },
    [10]={
      type = "checkbox",
      name = GetString(LWS_PRESET_SHOWCURSOR),
      tooltip = GetString(LWS_PRESET_SHOWCURSOR_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_SHOWCURSOR) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_SHOWCURSOR,value) end
    },
    [11]={
      type = "header",
      name = GetString(LWS_CRAFTING_RESOURCES),
    },
    [12]={
      type = "dropdown",
      name = GetString(LWS_PRESET_STYLEMATS),
      tooltip = GetString(LWS_PRESET_STYLEMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPSTYLEMATS) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPSTYLEMATS,value) end
    },
    [13]={
      type = "dropdown",
      name = GetString(LWS_PRESET_ALCHEMYMATS),
      tooltip = GetString(LWS_PRESET_ALCHEMYMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPALCHMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPALCHMAT,value) end
    },
    [14]={
      type = "dropdown",
      name = GetString(LWS_PRESET_ENCHANTINGMATS),
      tooltip = GetString(LWS_PRESET_ENCHANTINGMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPENCHMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPENCHMAT,value) end
    },
    [15]={
      type = "dropdown",
      name = GetString(LWS_PRESET_PROVISIONMATS),
      tooltip = GetString(LWS_PRESET_PROVISIONMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPPROVMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPPROVMAT,value) end
    },
    [16]={
      type = "dropdown",
      name = GetString(LWS_PRESET_CLOTHINGMATS),
      tooltip = GetString(LWS_PRESET_CLOTHINGMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPCLOTHMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPCLOTHMAT,value) end
    },
    [17]={
      type = "dropdown",
      name = GetString(LWS_PRESET_BLACKSMITHMATS),
      tooltip = GetString(LWS_PRESET_BLACKSMITHMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPBSMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPBSMAT,value) end
    },
    [18]={
      type = "dropdown",
      name = GetString(LWS_PRESET_WOODWORKMATS),
      tooltip = GetString(LWS_PRESET_WOODWORKMATS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPWWMAT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPWWMAT,value) end
    },
    [19]={
      type = "header",
      name = GetString(LWS_HDR_RESEARCH),
    },
    [20]={
      type = "dropdown",
      name = GetString(LWS_PRESET_RESEARCH_BS),
      tooltip = GetString(LWS_PRESET_RESEARCH_BS_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPRES_BS) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPRES_BS,value) end
    },
    [21]={
      type = "dropdown",
      name = GetString(LWS_PRESET_RESEARCH_CLOTH),
      tooltip = GetString(LWS_PRESET_RESEARCH_CLOTH_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPRES_CLOTH) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPRES_CLOTH,value) end
    },
    [22]={
      type = "dropdown",
      name = GetString(LWS_PRESET_RESEARCH_WWORK),
      tooltip = GetString(LWS_PRESET_RESEARCH_WWORK_TOOLTIP),
      choices = {LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_PROMPT],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_DESTROY],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_JUNK],LW_PRESET_ACTION_STRING[LW_PRESET_ACTION_KEEP]},
      getFunc = function() return self:GetConfValueForKey(LW_CONF_KEEPRES_WW) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_KEEPRES_WW,value) end
    },
    [23]={
      type = "header",
      name = GetString(LWS_HEADER_IGNORES),
    },
    [24]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNOREBANK),
      tooltip = GetString(LWS_PRESET_IGNOREBANK_TOOLTIP),
      disabled = true,
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_BANK) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_BANK,value) end
    },
    [25]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNOREGUILDBANK),
      tooltip = GetString(LWS_PRESET_IGNOREGUILDBANK_TOOLTIP),
      disabled = true,
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_GUILDBANK) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_GUILDBANK,value) end
    },
    [26]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNORESTORE),
      tooltip = GetString(LWS_PRESET_IGNORESTORE_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_SHOP) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_SHOP,value) end
    },
    [27]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNOREMAIL),
      tooltip = GetString(LWS_PRESET_IGNOREMAIL_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_MAIL) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_MAIL,value) end
    },
    [28]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNORECRAFT),
      tooltip = GetString(LWS_PRESET_IGNORECRAFT_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_CRAFT) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_CRAFT,value) end
    },
    [29]={
      type = "checkbox",
      name = GetString(LWS_PRESET_IGNOREFENCE),
      tooltip = GetString(LWS_PRESET_IGNOREFENCE_TOOLTIP),
      getFunc = function() return self:GetConfValueForKey(LW_CONF_IGNORE_FENCE) end,
      setFunc = function(value) self:SetConfValueForKey(LW_CONF_IGNORE_FENCE,value) end
    },
    [30]={
      type = "header",
      name = GetString(LWS_STORED_RULES),
    },
    [31]={
      type = "description",
      title = GetString(LWS_STORED_RULES_TITLE),
      text = GetString(LWS_STORED_RULES_DESCRIPTION)
    },
    [32]={
      type = "button",
      name = GetString(LWS_BUTTON_DELETEALL),
      tooltip = GetString(LWS_BUTTON_DELETEALL_TOOLTIP),
      func = function() self:RemoveAllRules() end
    },
  }

  self.LAM:RegisterOptionControls("LootWallOptions", optionsControls)

  --end of LAM
  self.Window.control=CreateControlFromVirtual("LootWallLootable",LootWallControl,"LootWallLootable",1)
  self.Window.label = self.Window.control:GetNamedChild('_Name')
  self.Window.icon = self.Window.control:GetNamedChild('_Icon')
  self.Window.itemType = self.Window.control:GetNamedChild('_Type')
  self.Window.itemSubType = self.Window.control:GetNamedChild('_SubType')
  self.Window.itemValue = self.Window.control:GetNamedChild('_Value')
  self.Window.shown = false
  self.Window.research = self.Window.control:GetNamedChild('_Research')
  self.Window.control:SetHidden(true)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:OnInventoryUpdate(...) end)--
  EVENT_MANAGER:RegisterForUpdate(self.name,250,function(...) self:OnUpdate(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_OPEN_STORE,function(_,...) self:StoreOpened(...) self:StartLootIgnore(LW_CONF_IGNORE_SHOP) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_OPEN_BANK,function(_,...) self:StartLootIgnore(LW_CONF_IGNORE_BANK) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CLOSE_BANK,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_BANK) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_OPEN_FENCE,function(_,...) self:StartLootIgnore(LW_CONF_IGNORE_FENCE) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CLOSE_FENCE,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_FENCE) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_OPEN_GUILD_BANK,function(_,...) self:StartLootIgnore(LW_CONF_IGNORE_GUILDBANK) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CLOSE_GUILD_BANK,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_GUILDBANK) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_MAIL_OPEN_MAILBOX,function(_,...) self:StartLootIgnore(LW_CONF_IGNORE_MAIL) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_MAIL_CLOSE_MAILBOX,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_MAIL) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CLOSE_STORE,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_SHOP) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_CRAFTING_STATION_INTERACT,function(_,_,_,...) self:StartLootIgnore(LW_CONF_IGNORE_CRAFT) end)
  EVENT_MANAGER:RegisterForEvent(self.name,EVENT_END_CRAFTING_STATION_INTERACT,function(_,...) self:EndLootIgnore(LW_CONF_IGNORE_CRAFT) end)
  --[[
      EVENT_CLOSE_BANK (integer eventCode)
      EVENT_OPEN_BANK (integer eventCode)
      EVENT_CLOSE_FENCE (integer eventCode)
      EVENT_OPEN_FENCE (integer eventCode)
      EVENT_OPEN_GUILD_BANK (integer eventCode)
      EVENT_CLOSE_GUILD_BANK (integer eventCode)
      EVENT_MAIL_OPEN_MAILBOX (integer eventCode)
      EVENT_MAIL_CLOSE_MAILBOX (integer eventCode)
      EVENT_CLOSE_STORE (integer eventCode)
      EVENT_OPEN_STORE (integer eventCode)
      EVENT_CRAFTING_STATION_INTERACT (integer eventCode, integer craftSkill, bool sameStation)
      EVENT_END_CRAFTING_STATION_INTERACT (integer eventCode)
   ]]--

  if(self.savedVariables.itemList == nil)then
    self.savedVariables.itemList = {}
  end

  if(self.savedVariables.wLeft ~= nil)and(self.savedVariables.wTop ~= nil)then
    self:RestorePosition()
  end
end
-------------------------------------------------------------------------------
function LootWall:ConvertToV2(value)
  if(value == true)then
    return LW_PRESET_ACTION_KEEP
  else
    return LW_PRESET_ACTION_PROMPT
  end
end
-------------------------------------------------------------------------------
function LootWall:MakeItemStringId(itemLink)
  local itemName = GetItemLinkName(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)
  local itemTrait,traitText = GetItemLinkTraitInfo(itemLink)
  local itemStyle = GetItemLinkItemStyle(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local itemLevel = GetItemLinkRequiredLevel(itemLink)
  if GetItemLinkRequiredVeteranRank(itemLink)>0 then
    itemLevel = 49 + GetItemLinkRequiredVeteranRank( itemLink)
  end
  local equipType = GetItemLinkEquipType(itemLink)

  return string.format("%s:%d:%d:%d:%d:%d:%d",itemName,itemLevel,itemQuality,itemType,equipType,itemTrait,itemStyle)

end
-------------------------------------------------------------------------------
function LootWall:PresetToAction(preset)
  if preset == LW_PRESET_ACTION_DESTROY then
    return LW_ACTION_DESTROY_NOW
  elseif preset == LW_PRESET_ACTION_JUNK then
    return LW_ACTION_TRASH_NOW
  elseif preset == LW_PRESET_ACTION_KEEP then
    return LW_ACTION_KEEP_NOW
  end
end
-------------------------------------------------------------------------------
function LootWall:DefaultActionForLink(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)
  local itemTrait,traitText = GetItemLinkTraitInfo(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  local researchNeeded,craftskillType = self.NfR:DoesPlayerNeedTrait(GetUnitName("player"),itemLink,nil)
  if tonumber(itemQuality) >= tonumber(self.savedVariables.conf[LW_CONF_QUALITY_THRESHOLD]) then
    return LW_ACTION_KEEP_ALWAYS
  end

  if (itemQuality == ITEM_QUALITY_TRASH)and(self.savedVariables.conf[LW_CONF_KEEPTRASH] > LW_PRESET_ACTION_PROMPT)then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPTRASH])
  end

  if (itemType == ITEMTYPE_LURE)and(self.savedVariables.conf[LW_CONF_KEEPBAIT] > LW_PRESET_ACTION_PROMPT)then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPBAIT])
  end

  if (self.savedVariables.conf[LW_CONF_KEEPINSP] > LW_PRESET_ACTION_PROMPT)then
    if(itemTrait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE)or(itemTrait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPINSP])
    end
  end

  if (self.savedVariables.conf[LW_CONF_KEEPORNATE] > LW_PRESET_ACTION_PROMPT)then
    if(itemTrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE)or(itemTrait == ITEM_TRAIT_TYPE_WEAPON_ORNATE)or(itemTrait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPORNATE])
    end
  end

  if (self.savedVariables.conf[LW_CONF_KEEPNIRN] > LW_PRESET_ACTION_PROMPT)then
    if(itemTrait == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)or(itemTrait == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)or(itemTrait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPNIRN])
    end
  end
  
  if researchNeeded == true then
    if(craftskillType == CRAFTING_TYPE_BLACKSMITHING)and(self.savedVariables.conf[LW_CONF_KEEPRES_BS] > LW_PRESET_ACTION_PROMPT) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPRES_BS])
    end
    
    if(craftskillType == CRAFTING_TYPE_CLOTHIER)and(self.savedVariables.conf[LW_CONF_KEEPRES_CLOTH] > LW_PRESET_ACTION_PROMPT) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPRES_CLOTH])
    end
    
    if(craftskillType == CRAFTING_TYPE_WOODWORKING)and(self.savedVariables.conf[LW_CONF_KEEPRES_WW] > LW_PRESET_ACTION_PROMPT) then
      return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPRES_WW])
    end
  end

  if(self.savedVariables.conf[LW_CONF_KEEPSTYLEMATS] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_STYLE_MATERIAL}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPSTYLEMATS])
  end

  if(self.savedVariables.conf[LW_CONF_KEEPALCHMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_REAGENT, ITEMTYPE_ALCHEMY_BASE}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPALCHMAT])
  end

  if(self.savedVariables.conf[LW_CONF_KEEPBSMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_WEAPON_TRAIT,ITEMTYPE_ARMOR_TRAIT,ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPBSMAT])
  end
  if(self.savedVariables.conf[LW_CONF_KEEPCLOTHMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_CLOTHIER_MATERIAL,ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPCLOTHMAT])
  end
  if(self.savedVariables.conf[LW_CONF_KEEPENCHMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPENCHMAT])
  end
  if(self.savedVariables.conf[LW_CONF_KEEPWWMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_WEAPON_TRAIT,ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPWWMAT])
  end
  if(self.savedVariables.conf[LW_CONF_KEEPPROVMAT] > LW_PRESET_ACTION_PROMPT)and(self:IsItemOfType(itemLink,{ITEMTYPE_INGREDIENT}))then
    return self:PresetToAction(self.savedVariables.conf[LW_CONF_KEEPPROVMAT])
  end    
  return LW_ACTION_UNDEFINED
end
-------------------------------------------------------------------------------
function LootWall:IsItemOfType(itemLink,itemTypeTable)
  local itemType = GetItemLinkItemType(itemLink)
  for k,v in pairs(itemTypeTable)do
  if(itemType == v)then
    return true
  end
end
return false
end
-------------------------------------------------------------------------------
function LootWall:IsInRange(value,range)
  for k,v in pairs(range)do
  if(value == v)then
    return true
  end
end
return false
end
-------------------------------------------------------------------------------
function LootWall:RemoveAllRules()
  self.savedVariables.itemList = {}
end
-------------------------------------------------------------------------------
function LootWall:DefaultConfig()
  self.savedVariables.conf = LW_CONF_DEFAULTS
end
-------------------------------------------------------------------------------
function LootWall:GetConfValueForKey(key)
  --handle dropboxes
  if key == LW_CONF_QUALITY_THRESHOLD then
    local qualityValue = self.savedVariables.conf[key]
    return LW_CONF_TRANSLATE_QUALITY[tonumber(qualityValue)]
  end

  if self:IsInRange(key, {LW_CONF_KEEPALCHMAT,LW_CONF_KEEPBSMAT,LW_CONF_KEEPCLOTHMAT,LW_CONF_KEEPENCHMAT,LW_CONF_KEEPINSP,LW_CONF_KEEPNIRN,LW_CONF_KEEPORNATE,LW_CONF_KEEPSTYLEMATS,LW_CONF_KEEPWWMAT,LW_CONF_KEEPPROVMAT,LW_CONF_KEEPBAIT,LW_CONF_KEEPTRASH,LW_CONF_KEEPRES_BS,LW_CONF_KEEPRES_CLOTH,LW_CONF_KEEPRES_WW}) then
    return LW_PRESET_ACTION_STRING[self.savedVariables.conf[key]]
  end 

  return self.savedVariables.conf[key]
end
-------------------------------------------------------------------------------
function LootWall:SetConfValueForKey(key,value)
  --handle dropboxes
  if key == LW_CONF_QUALITY_THRESHOLD then
    self.savedVariables.conf[key] = self:KeyForValue(LW_CONF_TRANSLATE_QUALITY,value)
  elseif self:IsInRange(key, {LW_CONF_KEEPALCHMAT,LW_CONF_KEEPBSMAT,LW_CONF_KEEPCLOTHMAT,LW_CONF_KEEPENCHMAT,LW_CONF_KEEPINSP,LW_CONF_KEEPNIRN,LW_CONF_KEEPORNATE,LW_CONF_KEEPSTYLEMATS,LW_CONF_KEEPWWMAT,LW_CONF_KEEPPROVMAT,LW_CONF_KEEPBAIT,LW_CONF_KEEPTRASH,LW_CONF_KEEPRES_BS,LW_CONF_KEEPRES_CLOTH,LW_CONF_KEEPRES_WW}) then
    self.savedVariables.conf[key] = self:KeyForValue(LW_PRESET_ACTION_STRING,value)
  else
    self.savedVariables.conf[key] = value 
  end
end
-------------------------------------------------------------------------------
function LootWall:KeyForValue( t, value )
  for k,v in pairs(t) do
    if v==value then 
      return tonumber(k)
    end
  end
  return nil
end
-------------------------------------------------------------------------------
--just a function to restore window to player moved pos
function LootWall:RestorePosition()
  local wLeft = self.savedVariables.wLeft
  local wTop = self.savedVariables.wTop

  self.Window.control:ClearAnchors()
  self.Window.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wLeft, wTop)

end
-------------------------------------------------------------------------------
--check whether the given itemLink has a rule saved, or if it was just one time rule
function LootWall:ItemHasRule(itemLink)
  local itemName = GetItemLinkName(itemLink)
  local itemRule = self.savedVariables.itemList[self:MakeItemStringId(itemLink)]

  if (itemRule == nil)or(itemRule == LW_ACTION_UNDEFINED)or(itemRule==LW_ACTION_DESTROY_NOW)or(itemRule==LW_ACTION_KEEP_NOW)or(itemRule == LW_ACTION_TRASH_NOW) then
    return false
  else
    return true
  end

end
-------------------------------------------------------------------------------
--the messy function to display the loot "tooltip"
--TODO: write this shit better
function LootWall:ConstructAndShowWindow(itemToDisplay)
  self.Window.shown=true
  self.Window.displayItem = itemToDisplay

  local itemLink = itemToDisplay.itemLink

  local itemName = zo_strformat("<<t:1>>",GetItemLinkName(itemLink))
  local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo( itemLink )
  local color = GetItemQualityColor(GetItemLinkQuality(itemLink))

  local itemTrait,traitText = GetItemLinkTraitInfo(itemLink)
  
  traitText = GetString("SI_ITEMTRAITTYPE",itemTrait)

  self.Window.itemValue:SetText("Value: " .. sellPrice)

  if equipType ~= EQUIP_TYPE_INVALID then
    local equipTypeString = GetString("SI_EQUIPTYPE",equipType)
    local itemType = GetItemType(itemToDisplay.bagId,itemToDisplay.slotId)
    local itemTypeString = ""
    if itemType == ITEMTYPE_WEAPON then
      local weaponType = GetItemWeaponType(itemToDisplay.bagId,itemToDisplay.slotId)
      itemTypeString = GetString("SI_WEAPONTYPE",weaponType) or "Weapon"
    elseif itemType == ITEMTYPE_ARMOR then
      local armorType = GetItemArmorType(itemToDisplay.bagId,itemToDisplay.slotId)
      itemTypeString = GetString("SI_ARMORTYPE",armorType) or "Armor"
    else
      itemTypeString = GetString("SI_ITEMTYPE",itemType) or ""
    end 
    self.Window.itemType:SetText(equipTypeString)
    if itemTypeString ~= "" then
      self.Window.itemSubType:SetText("("..itemTypeString..")")
    else
      self.Window.itemSubType:SetText("")
    end
  else
    local itemType = GetItemType(itemToDisplay.bagId,itemToDisplay.slotId)
    local itemTypeString = GetString("SI_ITEMTYPE",itemType) or ""
    self.Window.itemType:SetText(itemTypeString)
    self.Window.itemSubType:SetText("")
  end
  
  if itemTrait ~= ITEM_TRAIT_TYPE_NONE then
    local researchNeeded,_,_,_ = self.NfR:DoesPlayerNeedTrait(GetUnitName("player",itemLink,nil))
    if researchNeeded then
      self.Window.research:SetText(zo_strformat("<<t:1>> (<<2>>)",traitText,GetString(LWS_UNKNOWN_TRAIT)))
    else
      self.Window.research:SetText(zo_strformat("<<t:1>>",traitText))
    end         
  else
    self.Window.research:SetText("")
  end

  self.Window.icon:SetTexture(icon)
  self.Window.label:SetText(itemName)
  self.Window.label:SetColor(color.r,color.g,color.b,color.a)

  self.Window.control:SetHidden(false)  

  if(self.savedVariables.conf[LW_CONF_SHOWCURSOR]==true)then
    SetGameCameraUIMode(true)
  end
end
-------------------------------------------------------------------------------
--hide and cleanup the window
function LootWall:HideWindow()
  self.Window.control:SetHidden(true)
  self.Window.shown=false
  self.Window.displayItem = nil
  --self.gameCameraInactive = false
  --SetGameCameraUIMode(false)
end
-------------------------------------------------------------------------------
--apply a rule to the looted item
--rule = int, constant, ACTION_x_x
--itemBagId = int, the bagId
--itemSlotId = int, the slotId of bag with bagId
function LootWall:ApplyRuleToItem(rule,itemBagId,itemSlotId)
  if (rule == LW_ACTION_TRASH_ALWAYS)or(rule == LW_ACTION_TRASH_NOW)then
    SetItemIsJunk(itemBagId,itemSlotId,true)
  elseif(rule == LW_ACTION_DESTROY_ALWAYS)or(rule == LW_ACTION_DESTROY_NOW)then
    DestroyItem(itemBagId,itemSlotId)
  end
end
-------------------------------------------------------------------------------
--Button OnClick Action Functions
-------------------------------------------------------------------------------
--Destroy (now) button action
--$(parent)_BDestroyNow
function LootWall:DestroyNowAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_DESTROY_NOW
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
-------------------------------------------------------------------------------
--Destroy (Always) button action
--$(parent)_BDestroyAlways
function LootWall:DestroyAlwaysAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_DESTROY_ALWAYS
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
-------------------------------------------------------------------------------
--Keep (now) button action
--$(parent)_BKeepNow
function LootWall:KeepNowAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_KEEP_NOW
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
-------------------------------------------------------------------------------
--Keep (Always) button action
--$(parent)_BKeepAlways
function LootWall:KeepAlwaysAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_KEEP_ALWAYS
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
-------------------------------------------------------------------------------
--Junk (now) button action
--$(parent)_BTrashNow
function LootWall:TrashNowAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_TRASH_NOW
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
-------------------------------------------------------------------------------
--Junk (Always) button action
--$(parent)_BTrashAlways
function LootWall:TrashAlwaysAction()
  local displayedItem = self.Window.displayItem

  local itemName = GetItemLinkName(displayedItem.itemLink)

  self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)]=LW_ACTION_TRASH_ALWAYS
  self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(displayedItem.itemLink)],displayedItem.bagId,displayedItem.slotId)
  self:HideWindow()
end
--end of Button Actions


-------------------------------------------------------------------------------
--This is not used, but it was a start
function LootWall:OnItemLooted(eventCode, lootedBy, itemLink, quantity, itemSound, lootType, isSelf, isPickpocketLoot)
  if ((not isSelf)or(isPickPocketLoot)) then 
    return
  end


  local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo( itemLink )
  local trueName = GetItemLinkName(itemLink)
  d(itemLink)
  d(icon)
  self.Window.label:SetText(trueName)
  self.Window.icon:SetTexture(icon)
end
-------------------------------------------------------------------------------
--called when an item is added to the inventory
function LootWall:OnInventoryUpdate(eventCode,bagId,slotId,isNewItem,itemSoundCategory,updateReason)
  if (not isNewItem) then
    return
  end

  if (GetItemFilterTypeInfo(bagId,slotId) == ITEMFILTERTYPE_QUEST)then
    return
  end

  if bagId ~= BAG_BACKPACK then
    return
  end

  if self.ignoreLoot == true then
    return
  end

  local itemLink = GetItemLink(bagId,slotId,LINK_STYLE_DEFAULT)

  local itemName = GetItemLinkName(itemLink)


  if self:DefaultActionForLink(itemLink) ~= LW_ACTION_UNDEFINED then
    self:ApplyRuleToItem(self:DefaultActionForLink(itemLink),bagId,slotId)
  elseif self:ItemHasRule(itemLink) then
    self:ApplyRuleToItem(self.savedVariables.itemList[self:MakeItemStringId(itemLink)],bagId,slotId)
  else
    local droppedItem = LWDroppedItem:new(itemLink,bagId,slotId)
    table.insert(self.Buffer,1,droppedItem)
  end
end
-------------------------------------------------------------------------------
--the OnLoad event handler
function LootWall:OnAddOnLoaded(event, addonName)

  if addonName == LootWall.name then
    LootWall:Initialize()
  end
end
-------------------------------------------------------------------------------
--the window was moved, let`s save the values of where it went, so I don`t loose it
function LootWall:OnWindowMoveStop()
  self.savedVariables.wLeft = self.Window.control:GetLeft()
  self.savedVariables.wTop = self.Window.control:GetTop() 
end
-------------------------------------------------------------------------------
--called every 250ms, if not in combat and have an looted item in buffer, display id
--v 0.2: check if rule was not set after adding item to buffer
function LootWall:OnUpdate()
  if (self.Window.shown == false)and(IsUnitInCombat("player") == false) then
    local itemToShow = table.remove(LootWall.Buffer)
    if itemToShow ~= nil then
      --+v 0.2 check if rule wasn't created in the mean time
      if(not self:ItemHasRule(itemToShow.itemLink)) then
        self:ConstructAndShowWindow(itemToShow)
      end
    end
  end

end
-------------------------------------------------------------------------------
function LootWall:GameCameraDeactivated()
  if self.gameCameraInactive == false then
    self.gameCameraInactive = true
    SetGameCameraUIMode(true)
  end
end
-------------------------------------------------------------------------------
--EVENT_GAME_CAMERA_ACTIVATED
function LootWall:GameCameraActivated()
  if self.gameCameraInactive == true then
    self.gameCameraInactive = false
    SetGameCameraUIMode(false)
  end
end
-------------------------------------------------------------------------------
function LootWall:StartLootIgnore(ignoreSource)
  if (self.savedVariables.conf[ignoreSource] == true)then
    self.ignoreLoot = true
  end
end
-------------------------------------------------------------------------------
function LootWall:EndLootIgnore(ignoreSource)
  self.ignoreLoot = false
end
-------------------------------------------------------------------------------
function LootWall:StoreOpened()
  local sellJunk = self.savedVariables.conf[LW_CONF_SELLJUNK] or false
  if (sellJunk)and(HasAnyJunk(BAG_BACKPACK)) then
    SellAllJunk()
    d("|cFF0000[LootWall]|cFFFFFFSold all junk.|r")
  end
end
-------------------------------------------------------------------------------
--Register for load event
EVENT_MANAGER:RegisterForEvent(LootWall.name, EVENT_ADD_ON_LOADED, function( ... ) LootWall:OnAddOnLoaded( ... ) end )
