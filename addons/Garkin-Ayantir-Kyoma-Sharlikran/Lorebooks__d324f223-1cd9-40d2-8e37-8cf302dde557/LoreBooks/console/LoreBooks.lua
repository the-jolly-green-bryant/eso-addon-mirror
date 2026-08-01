--[[
-------------------------------------------------------------------------------
-- LoreBooks, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

--Libraries--------------------------------------------------------------------
local LMP = LibMapPins
local LoreBooks = _G["LoreBooks"]
local internal = _G["LoreBooks_Internal"]

-------------------------------------------------
----- Logger Function                       -----
-------------------------------------------------
internal.show_log = true
internal.loggerName = internal.ADDON_NAME

if LibDebugLogger then
  internal.logger = LibDebugLogger.Create(internal.loggerName)
end

local logger = LibDebugLogger ~= nil
local viewer = DebugLogViewer ~= nil

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if logger and log_type == "Info" then
    internal.logger:Info(log_content)
  end
  if not internal.show_log then return end
  if logger and log_type == "Debug" then
    internal.logger:Debug(log_content)
  elseif logger and log_type == "Verbose" then
    internal.logger:Verbose(log_content)
  elseif logger and log_type == "Warn" then
    internal.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if text == "" then text = "[Empty String]" end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if not t then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end
  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  for k, v in pairs(t) do
    local vType = type(v)
    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))
    if vType == "table" then
      if table_history[v] then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

local function emit_userdata(log_type, udata)
  local function_limit = 5
  local total_limit = 10
  local function_count = 0
  local entry_count = 0

  emit_message(log_type, "Userdata: " .. tostring(udata))

  local meta = getmetatable(udata)
  if meta and meta.__index then
    for k, v in pairs(meta.__index) do
      if type(v) == "function" then
        if function_count < function_limit then
          emit_message(log_type, "  Function: " .. tostring(k))
          function_count = function_count + 1
          entry_count = entry_count + 1
        end
      else
        emit_message(log_type, "  " .. tostring(k) .. ": " .. tostring(v))
        entry_count = entry_count + 1
      end
      if entry_count >= total_limit then
        emit_message(log_type, "  ... (output truncated due to limit)")
        break
      end
    end
  else
    emit_message(log_type, "  (No detailed metadata available)")
  end
end

local function contains_placeholders(str)
  return type(str) == "string" and str:find("<<%d+>>")
end

function internal:dm(log_type, ...)
  if not internal.show_log and log_type ~= "Info" then
    return
  end

  local num_args = select("#", ...)
  local first_arg = select(1, ...)

  if type(first_arg) == "string" and contains_placeholders(first_arg) then
    local remaining_args = { select(2, ...) }
    local formatted = ZO_CachedStrFormat(first_arg, unpack(remaining_args))
    emit_message(log_type, formatted)
  else
    for i = 1, num_args do
      local value = select(i, ...)
      if type(value) == "userdata" then
        emit_userdata(log_type, value)
      elseif type(value) == "table" then
        emit_table(log_type, value)
      else
        emit_message(log_type, tostring(value))
      end
    end
  end
end

--Local variables -------------------------------------------------------------
local INFORMATION_TOOLTIP

--prints message to chat
local function MyPrint(...)
  local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
  if (not ChatEditControl:HasFocus()) then StartChatInput() end
  ChatEditControl:InsertText(...)
end

local function IsCurrentMapGlobal()
  return GetMapType() > MAPTYPE_ZONE
end

local function GetZoneMapIdFromZoneId(zoneId)
  local zoneMapZoneId = GetParentZoneId(zoneId)
  local zoneMapMapId = GetMapIdByZoneId(zoneMapZoneId)
  return zoneMapMapId
end

-- Pins -----------------------------------------------------------------------
local function GetPinTextureBookshelf(mapPinObject)
  -- internal:dm("Info", "GetPinTextureBookshelf")
  local fallback = internal.icon_list_zoneid[1261]
  if type(mapPinObject) ~= "table" then return fallback end

  local pinTag = mapPinObject.m_PinTag
  if type(pinTag) ~= "table" then return fallback end

  local zoneId = pinTag.z and GetParentZoneId(pinTag.z)
  -- internal:dm("Info", internal.icon_list_zoneid[zoneId] or fallback)
  return internal.icon_list_zoneid[zoneId] or fallback
end

local function GetPinTexture(mapPinObject)
  -- internal:dm("Debug", "GetPinTexture")
  local pinTag = mapPinObject.m_PinTag
  if not pinTag or not pinTag[internal.SHALIDOR_COLLECTIONINDEX] or not pinTag[internal.SHALIDOR_BOOKINDEX] then
    return internal.PLACEHOLDER_TEXTURE
  end

  local _, texture, known = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX], pinTag[internal.SHALIDOR_BOOKINDEX])
  local textureType = LoreBooks.db.pinTexture.type

  if texture == internal.MISSING_TEXTURE then
    texture = internal.PLACEHOLDER_TEXTURE
  end

  return (textureType == internal.PIN_ICON_REAL) and texture or internal.PIN_TEXTURES[textureType][known and 1 or 2]
end

local function IsShaliPinGrayscale()
  return LoreBooks.db.pinTexture.type == internal.PIN_ICON_REAL and LoreBooks.db.pinGrayscale
end

--[[Tooltip creator for the Shalidor Map Pins]]--
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(mapPinObject)
  if type(mapPinObject) ~= "table" or type(mapPinObject.m_PinTag) ~= "table" then
    internal:dm("Warn", "Invalid Shalidor mapPinObject or missing m_PinTag in tooltip")
    internal.a_debug_missing_tag = mapPinObject
    return
  end

  local pinTag = mapPinObject.m_PinTag
  local title, icon, known, bookId = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX], pinTag[internal.SHALIDOR_BOOKINDEX])
  local collectionName = GetLoreCollectionInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX])
  local moreinfo = {}

  if icon == internal.MISSING_TEXTURE then icon = internal.PLACEHOLDER_TEXTURE end

  local fakePin = false
  if pinTag.ld then
    for _, details in pairs(pinTag.ld) do
      if details == internal.SHALIDOR_MOREINFO_BREADCRUMB then
        fakePin = true
      end
      if details and not fakePin then
        table.insert(moreinfo, "[" .. zo_strformat(LoreBooks.locationDetails[details]) .. "]")
      end
    end
  end

  if pinTag[internal.SHALIDOR_ZONEID] then
    table.insert(moreinfo, "[" .. zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(pinTag[internal.SHALIDOR_ZONEID])) .. "]")
  end

  local bookColor = known and ZO_SUCCEEDED_TEXT or ZO_HIGHLIGHT_TEXT

  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collectionName), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, icon, bookColor:Colorize(title), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(moreinfo, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
    end
  else
    INFORMATION_TOOLTIP:AddLine(zo_strformat(collectionName), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
    ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", bookColor:UnpackRGB())
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:AddLine(table.concat(moreinfo, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end
  end
end

--[[Tooltip creator for the Bookshelf Pins]]--
local pinTooltipCreatorBookshelf = {}
pinTooltipCreatorBookshelf.tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
pinTooltipCreatorBookshelf.creator = function(mapPinObject)
  if type(mapPinObject) ~= "table" or type(mapPinObject.m_PinTag) ~= "table" then
    internal:dm("Warn", "Invalid Bookshelf mapPinObject or missing m_PinTag in tooltip")
    internal.a_debug_missing_tag = mapPinObject
    return
  end

  local pinTag = mapPinObject.m_PinTag
  local title = pinTag.pinName or GetString(LBOOKS_BOOKSHELF)
  local icon = GetPinTextureBookshelf(mapPinObject)
  local moreinfo = {}

  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, icon, title, { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(moreinfo, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
    end
  else
    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    if #moreinfo > 0 then
      INFORMATION_TOOLTIP:AddLine(table.concat(moreinfo, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end
  end
end

local lastZoneShalidor = ""
local lastMapIpShalidor = 0
local lastZoneBookshelf = ""
local lastMapIpBookshelf = 0

local lorebooks
local bookshelves

local function GetCurrentMapIdentity()
  return GetCurrentMapId(), LMP:GetZoneAndSubzone(true, false, true)
end

local function UpdateShalidorLorebooksData(mapId)
  local mapIdCurrent, mapTexture = GetCurrentMapIdentity()
  if lastZoneShalidor ~= mapTexture or lastMapIpShalidor ~= mapIdCurrent then
    lastZoneShalidor = mapTexture
    lastMapIpShalidor = mapIdCurrent
    lorebooks = LoreBooks_GetLocalData(mapId)
    COMPASS_PINS:RefreshPins(internal.PINS_COMPASS)
  end
end

local function UpdateBookshelfLorebooksData(mapId)
  local mapIdCurrent, mapTexture = GetCurrentMapIdentity()
  if lastZoneBookshelf ~= mapTexture or lastMapIpBookshelf ~= mapIdCurrent then
    -- internal:dm("Info", "Updating Bookshelf Data!")
    lastZoneBookshelf = mapTexture
    lastMapIpBookshelf = mapIdCurrent
    bookshelves = LoreBooks_GetBookshelfDataFromMapId(mapId)
    COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_BOOKSHELF)
  end
end

local function ShalidorCompassCallback()
  if IsCurrentMapGlobal() then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "ShalidorCompassCallback")

  if lorebooks then
    for _, pinData in ipairs(lorebooks) do
      local _, _, known = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinData[3], pinData[4])
      if not known and LoreBooks.db.filters[internal.PINS_COMPASS] then
        COMPASS_PINS.pinManager:CreatePin(internal.PINS_COMPASS, pinData, pinData[1], pinData[2])
      end
    end
  end
end

local function BookshelfCompassCallback()
  if IsCurrentMapGlobal() then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Info", "BookshelfCompassCallback")

  if bookshelves then
    -- internal:dm("Info", "There is Compass Bookshelf Data")
    -- internal:dm("Info", bookshelves)
    for _, pinData in ipairs(bookshelves) do
      if LoreBooks.db.filters[internal.PINS_COMPASS_BOOKSHELF] then
        COMPASS_PINS.pinManager:CreatePin(internal.PINS_COMPASS_BOOKSHELF, pinData, pinData.x, pinData.y)
      end
    end
  end
end

local function MapCallbackCreateShalidorPins(pinType)
  if IsCurrentMapGlobal() then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "MapCallbackCreateShalidorPins: " .. pinType)

  local mapId = GetCurrentMapId()
  UpdateShalidorLorebooksData(mapId)

  -- Shalidor's Books
  if lorebooks then
    for _, pinData in ipairs(lorebooks) do
      local _, _, known = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinData[3], pinData[4])
      -- Shalidor's Books Collected
      if pinType == internal.PINS_COLLECTED then
        if known and LMP:IsEnabled(internal.PINS_COLLECTED) then
          LMP:CreatePin(internal.PINS_COLLECTED, pinData, pinData[1], pinData[2])
        end
      end
      -- Shalidor's Books Unknown
      if pinType == internal.PINS_UNKNOWN then
        if not known and LMP:IsEnabled(internal.PINS_UNKNOWN) then
          LMP:CreatePin(internal.PINS_UNKNOWN, pinData, pinData[1], pinData[2])
        end
      end
    end
  end

end

local function MapCallbackCreateBookshelfPins(pinType)
  if IsCurrentMapGlobal() then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Info", "MapCallbackCreateBookshelfPins")

  local mapId = GetCurrentMapId()
  UpdateBookshelfLorebooksData(mapId)

  -- Bookshelves
  if pinType == internal.PINS_BOOKSHELF and LMP:IsEnabled(internal.PINS_BOOKSHELF) then
    if bookshelves then
      -- internal:dm("Info", "There is Map Pin Bookshelf Data")
      -- internal:dm("Debug", "bookshelves PINS_BOOKSHELF")
      for _, pinData in ipairs(bookshelves) do
        pinData.texture = GetPinTextureBookshelf(pinData)
        pinData.pinName = GetString(LBOOKS_BOOKSHELF)
        LMP:CreatePin(internal.PINS_BOOKSHELF, pinData, pinData.x, pinData.y)
      end
    end
  end

end

local function InitializePins()

  local pinTextures = internal.PIN_TEXTURES
  local pinTextureLevel = LoreBooks.db.pinTexture.level
  local pinTextureSize = LoreBooks.db.pinTexture.size
  local invertedTextureFromTable = 2

  local mapPinLayout_unknown = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize }
  local mapPinLayout_collected = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize, grayscale = IsShaliPinGrayscale }
  local mapPinLayout_bookshelf = { level = pinTextureLevel, texture = GetPinTextureBookshelf, size = pinTextureSize }

  local compassTextureType = LoreBooks.db.pinTexture.type
  local compassMaxDistance = LoreBooks.db.compassMaxDistance
  local compassLayoutTexture = pinTextures[compassTextureType][invertedTextureFromTable] or internal.MISSING_TEXTURE
  local compassPinLayout = {
    maxDistance = compassMaxDistance,
    texture = compassLayoutTexture,
    sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
      if zo_abs(normalizedAngle) > 0.25 then
        pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
      else
        pin:SetDimensions(48, 48)
      end
    end,
    additionalLayout = {
      [CUSTOM_COMPASS_LAYOUT_UPDATE] = function(pin)
        if (LoreBooks.db.pinTexture.type == internal.PIN_ICON_REAL) then
          -- replace icon with icon from LoreLibrary
          local _, texture = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.pinTag[3], pin.pinTag[4])
          local icon = pin:GetNamedChild("Background")
          if icon == internal.MISSING_TEXTURE then icon = internal.PLACEHOLDER_TEXTURE end
          icon:SetTexture(texture)
        end
      end,
    },
    mapPinTypeString = internal.PINS_UNKNOWN,
    onToggleCallback = function(compassPinType, enabled)
      COMPASS_PINS:SetCompassPinEnabled(compassPinType, enabled)
      COMPASS_PINS:RefreshPins(compassPinType)
    end,
  }
  local compassPinLayoutBookshelf = {
    maxDistance = compassMaxDistance,
    texture = internal.icon_list_zoneid[1261],
    sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
      local size = zo_abs(normalizedAngle) > 0.25 and (54 - 24 * zo_abs(normalizedAngle)) or 48
      pin:SetDimensions(size, size)
    end,
    additionalLayout = {
      [CUSTOM_COMPASS_LAYOUT_UPDATE] = function(pin)
        local zoneId = 1261 -- fallback
        if pin.pinTag and pin.pinTag.z then
          zoneId = GetParentZoneId(pin.pinTag.z)
        end
        local tex = internal.icon_list_zoneid[zoneId] or internal.icon_list_zoneid[1261]
        local icon = pin:GetNamedChild("Background")
        if icon then
          icon:SetTexture(tex)
        end
      end,
    },
    mapPinTypeString = internal.PINS_BOOKSHELF,
    onToggleCallback = function(compassPinType, enabled)
      COMPASS_PINS:SetCompassPinEnabled(compassPinType, enabled)
      COMPASS_PINS:RefreshPins(compassPinType)
    end,
  }

  -- initialize map pins
  LMP:AddPinType(internal.PINS_UNKNOWN, function() MapCallbackCreateShalidorPins(internal.PINS_UNKNOWN) end, nil, mapPinLayout_unknown, pinTooltipCreator)
  LMP:AddPinType(internal.PINS_COLLECTED, function() MapCallbackCreateShalidorPins(internal.PINS_COLLECTED) end, nil, mapPinLayout_collected, pinTooltipCreator)
  LMP:AddPinType(internal.PINS_BOOKSHELF, function() MapCallbackCreateBookshelfPins(internal.PINS_BOOKSHELF) end, nil, mapPinLayout_bookshelf, pinTooltipCreatorBookshelf)

  LMP:AddPinFilter(internal.PINS_UNKNOWN, GetString(LBOOKS_FILTER_UNKNOWN), true, LoreBooks.db.filters, internal.PINS_UNKNOWN)
  LMP:AddPinFilter(internal.PINS_COLLECTED, GetString(LBOOKS_FILTER_COLLECTED), true, LoreBooks.db.filters, internal.PINS_COLLECTED)
  LMP:AddPinFilter(internal.PINS_BOOKSHELF, GetString(LBOOKS_FILTER_BOOKSHELF), true, LoreBooks.db.filters, internal.PINS_BOOKSHELF)

  LMP:SetPinFilterHidden(internal.PINS_UNKNOWN, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_COLLECTED, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_BOOKSHELF, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)

  -- add handler for the left click
  LMP:SetClickHandlers(internal.PINS_UNKNOWN, {
    [1] = {
      name = function(pin)
        local title = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.m_PinTag[3], pin.m_PinTag[4])
        return zo_strformat(LBOOKS_SET_WAYPOINT, title)
      end,
      show = function(pin)
        local _, _, known = LoreBooks_GetNewShalidorBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.m_PinTag[3], pin.m_PinTag[4])
        return LoreBooks.db.showClickMenu and not known
      end,
      duplicates = function(pin1, pin2)
        return (pin1.m_PinTag[3] == pin2.m_PinTag[3] and pin1.m_PinTag[4] == pin2.m_PinTag[4])
      end,
      callback = function(pin)
        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY)
      end,
    }
  })

  -- initialize compass pins
  COMPASS_PINS:AddCustomPin(internal.PINS_COMPASS, function() ShalidorCompassCallback() end, compassPinLayout, LoreBooks.db.filters)
  COMPASS_PINS:AddCustomPin(internal.PINS_COMPASS_BOOKSHELF, function() BookshelfCompassCallback() end, compassPinLayoutBookshelf, LoreBooks.db.filters)
  COMPASS_PINS:RefreshPins(internal.PINS_COMPASS)
  COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_BOOKSHELF)
end

local function OnBookLearned(eventCode, categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
  local cacheKey = categoryIndex .. ":" .. collectionIndex
  if internal.collectionInfoCache then
    internal.collectionInfoCache[cacheKey] = nil
  end

  if categoryIndex ~= internal.LORE_LIBRARY_CRAFTING then
    if categoryIndex == internal.LORE_LIBRARY_SHALIDOR then
      LMP:RefreshPins(internal.PINS_UNKNOWN)
      LMP:RefreshPins(internal.PINS_COLLECTED)
      COMPASS_PINS:RefreshPins(internal.PINS_COMPASS)
    elseif categoryIndex == internal.LORE_LIBRARY_EIDETIC then
      LMP:RefreshPins(internal.PINS_EIDETIC)
      LMP:RefreshPins(internal.PINS_EIDETIC_COLLECTED)
      LMP:RefreshPins(internal.PINS_BOOKSHELF)
      COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_EIDETIC)
      COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_BOOKSHELF)
    end
  end
end

local function OnGamepadPreferredModeChanged()
  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
  else
    INFORMATION_TOOLTIP = InformationTooltip
  end
end

local function OnLoad(eventCode, name)

  if name == internal.ADDON_NAME then

    EVENT_MANAGER:UnregisterForEvent(internal.ADDON_NAME, EVENT_ADD_ON_LOADED)

    LoreBooks.db = ZO_SavedVars:NewAccountWide("LBooks_SavedVariables", internal.SAVEDVARIABLES_VERSION, nil, LoreBooks.defaults)

    -- Tooltip Mode
    OnGamepadPreferredModeChanged()

    -- LibMapPins
    InitializePins()

    --events
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_LORE_BOOK_LEARNED, OnBookLearned)
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

  end

end
EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)
