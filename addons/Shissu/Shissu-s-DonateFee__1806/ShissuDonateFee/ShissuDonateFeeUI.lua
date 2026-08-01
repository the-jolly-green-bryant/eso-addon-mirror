SHISSUDONATEFEEUI_MASTER = {}

local ShissuDonateFeeUI = ZO_SocialListKeyboard:Subclass()

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local goldSymbol = _globals["goldSymbol"]
local white = _globals["white"]

local _addon = {}
_addon.Name = "ShissuDonateFee"
_addon.Version = "1.0.11"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Donate/Fee"

ShissuDonateFeeUI.SORT_KEYS = {
  ["date"] = {},
  ["index"] = {},
  ["guild"] = {tiebreaker = "date", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["gold"] = {tiebreaker = "date", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["affirmed"] = {},

}

local _L = ShissuFramework["func"]._L(_addon.Name)
local RGBtoHex = ShissuFramework["func"].RGBtoHex
local createFlatWindow = ShissuFramework["interface"].createFlatWindow

function ShissuDonateFeeUI:New(...)
  return ZO_SocialListKeyboard.New(self, ...)
end

function ShissuDonateFeeUI:Initialize(control)     
  ZO_SocialListKeyboard.Initialize(self, control)

  control:SetHandler("OnEffectivelyHidden", function() self:OnEffectivelyHidden() end)

  ZO_ScrollList_AddDataType(self.list, 1, "ShissuDonateFeeUIRow", 30, function(control, data) self:SetupRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder) end
  self:SetAlternateRowBackgrounds(true)
  self:SetEmptyText("NO DATA")
  self.sortHeaderGroup:SelectHeaderByKey("date") 
end

function ShissuDonateFeeUI:BuildMasterList()
  self.masterList = {} 
  
  local numGuild = GetNumGuilds()
  local maxGold = {}

  for guildId = 1, numGuild do
    local guildName = GetGuildName(guildId)  

    maxGold[guildName] = 0

    if ( shissuDonateFee[guildName] ~= nil ) then
      local data = shissuDonateFee[guildName]["data"]

      if (data ~= nil) then
        local dataLength = #data

        for dataId=1, dataLength do
          local rowData = {}
          
          rowData["index"] = dataId
          rowData["date"] = data[dataId][1]
          rowData["gold"] = data[dataId][2]
          rowData["guild"] = guildName

          maxGold[guildName] = maxGold[guildName] + data[dataId][2]

          if ( data[dataId][4] ~= nil ) then
            rowData["affirmed"] = 1
          else
            rowData["affirmed"] = 0
          end

          table.insert(self.masterList, rowData)
        end

        local rowData = {}
        rowData["index"] = "G"
        rowData["date"] = "G"
        rowData["gold"] = maxGold[guildName]
        rowData["guild"] = guildName
        rowData["affirmed"] = 0

        if ( maxGold[guildName] ~= 0 ) then
          table.insert(self.masterList, rowData)   
        end 
      end
    end
  end
end

function ShissuDonateFeeUI:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
    
  for i = 1, #self.masterList do
    if ((self.masterList[i].hidden == nil) or (self.masterList[i].hidden == false)) then
      local entry = self.masterList[i]
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1,  entry))
     end
  end
end

function ShissuDonateFeeUI:GetGuildColor(guildName)
  local color = ""

  if ((guildName == nil) or (guildName == "")) then
    return color
	end

  local guildChatCategories = {}
  guildChatCategories[1] = CHAT_CATEGORY_GUILD_1
  guildChatCategories[2] = CHAT_CATEGORY_GUILD_2
  guildChatCategories[3] = CHAT_CATEGORY_GUILD_3
  guildChatCategories[4] = CHAT_CATEGORY_GUILD_4
  guildChatCategories[5] = CHAT_CATEGORY_GUILD_5

  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
      if (GetGuildName(guildId) == guildName) then
        color = ZO_ColorDef:New(1, 1, 1, 1)
        color:SetRGB(GetChatCategoryColor(guildChatCategories[i]))
        
        color = RGBtoHex(color["r"], color["g"], color["b"])
        break
      end
  end

  return color
end

function ShissuDonateFeeUI:SetupRow(control, data)
  local color = ""
  control.data = data

  local indexControl = control:GetNamedChild('Index')
  indexControl:SetText(data.index)

  local guildControl = control:GetNamedChild('Guild')
  color = ShissuDonateFeeUI:GetGuildColor(data.guild)
  guildControl:SetText(color .. data.guild) 

  local dateControl = control:GetNamedChild('Date')

  if data.date == "G" then
    dateControl:SetText(color .. _L("SUM"))
  else
    dateControl:SetText(os.date('%d.%m.%Y %H:%M:%S', data.date))
  end

  local goldControl = control:GetNamedChild('Gold')
  goldControl:SetText(ZO_LocalizeDecimalNumber(data.gold) .. " " .. goldSymbol) 
  
  local affirmedControl = control:GetNamedChild('Affirmed')
  affirmedControl:SetTexture("/esoui/art/buttons/accept_up.dds") --SetText("|t16:16:/esoui/art/buttons/accept_up.dds|t") 
  affirmedControl:SetColor( ShissuFramework["interface"].getThemeColor())
  affirmedControl:SetDimensions(28, 28)

  if ( data.affirmed == 1 ) then
    affirmedControl:SetHidden(false)
    
    affirmedControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT,  _L("AFFIRMED")) end)     
    affirmedControl:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)  
  else
    affirmedControl:SetHidden(true)
  end
end
        
function ShissuDonateFeeUI:SortScrollList()
  if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
  end
end

function ShissuDonateFeeUI:Refresh()
  self:BuildMasterList()
  self:RefreshData()
end

function ShissuDonateFeeUI:UnlockSelection()
  ZO_SortFilterList.UnlockSelection(self)
  self:RefreshVisible()
end

function ShissuDonateFeeUI:OnEffectivelyHidden()
  ClearMenu()
end

-- * Initialisierung                                                                         
function _addon.initialized()
  local control = GetControl("ShissuDonateFeeUI")

  createFlatWindow(
    "ShissuDonateFeeUI",
    control,  
    {580, 480}, 
    function() control:SetHidden(true) end,
    _L("TITLE")
  ) 
  
  ShissuDonateFeeUI_Version:SetText(_addon.formattedName .. " " .. _addon.Version)

  SLASH_COMMANDS["/sdf"] = function()
    local control = GetControl("ShissuDonateFeeUI")

    if ( control:IsHidden() ) then
      control:SetHidden(false)
    else
      control:SetHidden(true)
    end
  end
  
  ShissuDonateFeeUIHeadersDateName:SetText(stdColor .. _L("DATE"))
  ShissuDonateFeeUIHeadersGuildName:SetText(stdColor .. _L("GUILD"))
  ShissuDonateFeeUIHeadersGoldName:SetText(stdColor .. _L("GOLD"))

  ShissuDonateFeeUI = ShissuDonateFeeUI:New(control)
  ShissuDonateFeeUI:BuildMasterList()
  ShissuDonateFeeUI:Refresh()     

  SHISSUDONATEFEEUI_MASTER = ShissuDonateFeeUI
end

function _addon.waitToSaveVar()
  shissuDonateFee = shissuDonateFee or {}

  if (shissuDonateFee == {}) then
    zo_callLater(_addon.waitToSaveVar, 1000)
  else 
    _addon.initialized()
  end 
end

zo_callLater(_addon.waitToSaveVar, 5000)