--[[
-------------------------------------------------------------------------------
-- LoreBooks
-------------------------------------------------------------------------------
-- Original author: Ales Machat (Garkin), started 2014-04-18
--
-- Maintainers:
--    Ayantir (contributions starting 2015-11-07)
--    Kyoma (contributions starting 2018-05-30)
--    Sharlikran (current maintainer, contributions starting 2022-11-12)
--
-------------------------------------------------------------------------------
-- This addon includes contributions licensed under two Creative Commons licenses
-- and the original MIT license:
--
-- MIT License (Garkin, 2014–2015):
--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the conditions in the LICENSE file.
--
-- Creative Commons BY-NC-SA 4.0 (Ayantir, 2015–2020 and Sharlikran, 2022–present):
--   You are free to share and adapt the material with attribution, but not for
--   commercial purposes. Derivatives must be licensed under the same terms.
--   Full terms at: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
--
-------------------------------------------------------------------------------
-- Maintainer Notice:
-- Redistribution of this addon outside of ESOUI.com or GitHub is discouraged
-- unless authorized by the current maintainer. While the original MIT license
-- permits wide redistribution, uncoordinated uploads may cause version
-- fragmentation or confusion. Please respect the intent of the maintainers and
-- the ESO addon ecosystem.
-- ----------------------------------------------------------------------------
-- Data Integrity and Attribution Notice:
-- While individual book positions are discoverable via the ESO API, the
-- comprehensive dataset included in LoreBooks is the result of years of
-- community effort and contributions from multiple players. Recreating this
-- dataset independently requires extensive time and dedication.
--
-- Direct reuse, extraction, or redistribution of the compiled data tables,
-- either in whole or substantial part, without permission from the current
-- maintainer, is prohibited. Claiming ownership or sole authorship over
-- derived works that include this dataset is considered a violation of the
-- contributors' efforts and the licenses under which this project is shared.
--
-- If you wish to use this data in your own addon or tool, please contact the
-- current maintainer for appropriate guidance and permission.
-- ----------------------------------------------------------------------------
]]
--Libraries--------------------------------------------------------------------
local LMP = LibMapPins
local LMD = LibMapData
local LMDI = LibMapData_Internal
local GPS = LibGPS3
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
local loreLibraryReportKeybind
local eideticModeAsked
local reportShown
local copyReport

--prints message to chat
local function MyPrint(...)
  local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
  if (not ChatEditControl:HasFocus()) then StartChatInput() end
  ChatEditControl:InsertText(...)
end

-- Pins -----------------------------------------------------------------------
local function GetPinTextureBookshelf(mapPinObject)
  -- internal:dm("Debug", "GetPinTextureBookshelf")
  local fallback = internal.icon_list_zoneid[1261]
  if type(mapPinObject) ~= "table" then return fallback end

  local pinTag = mapPinObject.m_PinTag
  if type(pinTag) ~= "table" then return fallback end

  local zoneId = pinTag.z and GetParentZoneId(pinTag.z)
  return internal.icon_list_zoneid[zoneId] or fallback
end

local function GetPinTexture(mapPinObject)
  -- internal:dm("Debug", "GetPinTexture")
  local pinTag = mapPinObject.m_PinTag
  if not pinTag or not pinTag[internal.SHALIDOR_COLLECTIONINDEX] or not pinTag[internal.SHALIDOR_BOOKINDEX] then
    return internal.PLACEHOLDER_TEXTURE
  end

  local _, texture, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX], pinTag[internal.SHALIDOR_BOOKINDEX])
  local textureType = LoreBooks.db.pinTexture.type

  if texture == internal.MISSING_TEXTURE then
    texture = internal.PLACEHOLDER_TEXTURE
  end

  return (textureType == internal.PIN_ICON_REAL) and texture or internal.PIN_TEXTURES[textureType][known and 1 or 2]
end

local function GetPinTextureEidetic(mapPinObject)
  -- internal:dm("Debug", "GetPinTextureEidetic")
  local pinTag = mapPinObject.m_PinTag
  if not pinTag or not pinTag.c or not pinTag.b then
    return internal.PLACEHOLDER_TEXTURE
  end

  local _, texture, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pinTag.c, pinTag.b)
  local textureType = LoreBooks.db.pinTextureEidetic

  if texture == internal.MISSING_TEXTURE then
    texture = internal.PLACEHOLDER_TEXTURE
  end

  return (textureType == internal.PIN_ICON_REAL) and texture or internal.PIN_TEXTURES[textureType][known and 1 or 2]
end

local function IsShaliPinGrayscale()
  return LoreBooks.db.pinTexture.type == internal.PIN_ICON_REAL and LoreBooks.db.pinGrayscale
end

local function IsEideticPinGrayscale()
  return LoreBooks.db.pinTextureEidetic == internal.PIN_ICON_REAL and LoreBooks.db.pinGrayscaleEidetic
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
  local title, icon, known, bookId = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX], pinTag[internal.SHALIDOR_BOOKINDEX])
  local collectionName = LoreBooks_GetNewLoreCollectionInfo(internal.LORE_LIBRARY_SHALIDOR, pinTag[internal.SHALIDOR_COLLECTIONINDEX])
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

local function GetQuestLocation(questId)
  local zoneId = GetQuestZoneId(questId)
  if zoneId == 0 then return "" end
  return zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameById(zoneId))
end

--[[Tooltip creator for the Eidetic Memory Map Pins]]--
local pinTooltipCreatorEidetic = {}
pinTooltipCreatorEidetic.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreatorEidetic.creator = function(mapPinObject)
  if type(mapPinObject) ~= "table" or type(mapPinObject.m_PinTag) ~= "table" then
    internal:dm("Warn", "Invalid Eidetic mapPinObject or missing m_PinTag in tooltip")
    internal.a_debug_missing_tag = mapPinObject
    return
  end

  local pinTag = mapPinObject.m_PinTag

  local title, icon, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pinTag.c, pinTag.b)
  local collectionName = LoreBooks_GetNewLoreCollectionInfo(internal.LORE_LIBRARY_EIDETIC, pinTag.c)
  if icon == internal.MISSING_TEXTURE then icon = internal.PLACEHOLDER_TEXTURE end
  local dungeonMapId = pinTag.pm
  local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(dungeonMapId))

  local bookColor = ZO_HIGHLIGHT_TEXT
  if known then
    bookColor = ZO_SUCCEEDED_TEXT
  end

  if IsInGamepadPreferredMode() then
    -- Gamepad Mode
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(collectionName), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
    INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, bookColor:Colorize(title), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })

    if pinTag.q and LoreBooks.db.showQuestName then
      local questName = GetQuestName(pinTag.q)
      local questDetails = GetQuestLocation(pinTag.q)
      local questInfo
      if questDetails ~= "" then
        questInfo = string.format(GetString(LBOOKS_QUEST_BOOK_ZONENAME), questDetails, questName)
      else
        questInfo = string.format(GetString(LBOOKS_QUEST_BOOK), questDetails, questName)
      end
      if questName then
        INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, questInfo, { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
      end
    end

    if pinTag.d and LoreBooks.db.showDungeonTag and mapName then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, string.format("[%s]", mapName), { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 })
    end

    if pinTag.ld then
      local pinNote = "[" .. zo_strformat(LoreBooks.locationDetails[pinTag.ld]) .. "]"
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, pinNote, INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
    end

  else
    -- Keyboard Mode
    INFORMATION_TOOLTIP:AddLine(zo_strformat(collectionName), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
    ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
    INFORMATION_TOOLTIP:AddLine(zo_iconTextFormat(icon, 32, 32, title), "", bookColor:UnpackRGB())

    if pinTag.q and LoreBooks.db.showQuestName then
      local questName = GetQuestName(pinTag.q)
      local questDetails = GetQuestLocation(pinTag.q)
      local questInfo
      if questDetails ~= "" then
        questInfo = string.format(GetString(LBOOKS_QUEST_BOOK_ZONENAME), questDetails, questName)
      else
        questInfo = string.format(GetString(LBOOKS_QUEST_BOOK), questDetails, questName)
      end
      if questName then
        INFORMATION_TOOLTIP:AddLine(questInfo, "", ZO_SELECTED_TEXT:UnpackRGB())
      end
    end

    if pinTag.d and LoreBooks.db.showDungeonTag and mapName then
      INFORMATION_TOOLTIP:AddLine(string.format("[%s]", mapName), "", ZO_SELECTED_TEXT:UnpackRGB())
    end

    if pinTag.ld then
      local pinNote = "[" .. zo_strformat(LoreBooks.locationDetails[pinTag.ld]) .. "]"
      INFORMATION_TOOLTIP:AddLine(pinNote, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    end
  end
end

local function ShouldDisplayLoreBooks()

  if LoreBooks.db.immersiveMode == internal.LBOOKS_IMMERSIVE_DISABLED then
    return true
  end

  local mapIndex = LMD.mapIndex

  if mapIndex then
    if LoreBooks.db.immersiveMode == internal.LBOOKS_IMMERSIVE_ZONEMAINQUEST then
      -- MainQuest

      local conditionData = LoreBooks_GetImmersiveModeCondition(LoreBooks.db.immersiveMode, mapIndex)
      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif LoreBooks.db.immersiveMode == internal.LBOOKS_IMMERSIVE_WAYSHRINES then
      -- Wayshrines

      if mapIndex ~= GetCyrodiilMapIndex() then
        -- It is impossible to unlock all Wayshrines in Cyrodiil
        local conditionData = LoreBooks_GetImmersiveModeCondition(LoreBooks.db.immersiveMode, mapIndex)
        return conditionData
      end

    elseif LoreBooks.db.immersiveMode == internal.LBOOKS_IMMERSIVE_EXPLORATION then
      -- Exploration

      local conditionData = LoreBooks_GetImmersiveModeCondition(LoreBooks.db.immersiveMode, mapIndex)
      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif LoreBooks.db.immersiveMode == internal.LBOOKS_IMMERSIVE_ZONEQUESTS then
      -- Zone Quests

      local conditionData = LoreBooks_GetImmersiveModeCondition(LoreBooks.db.immersiveMode, mapIndex)

      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    end
  end

  return true

end

local lastZoneShalidor = ""
local lastMapIpShalidor = 0
local lastZoneBookshelf = ""
local lastMapIpBookshelf = 0
local lastZoneEidetic = ""
local lastMapIpEidetic = 0

LoreBooks.lorebooks = nil
local bookshelves
local eideticBooks

local function UpdateShalidorLorebooksData(mapId, zoneMapId)
  -- internal:dm("Debug", "UpdateShalidorLorebooksData")
  if not LMD.mapId or not LMD.mapTexture then return end
  if LMD.mapTexture ~= lastZoneShalidor or LMD.mapId ~= lastMapIpShalidor then
    -- internal:dm("Warn", "Shalidor Books Updated")
    lastZoneShalidor = LMD.mapTexture
    lastMapIpShalidor = LMD.mapId
    LoreBooks.lorebooks = LoreBooks_GetLocalData(mapId) -- Shalidor
    COMPASS_PINS:RefreshPins(internal.PINS_COMPASS)
    return
  end
end

local function UpdateBookshelfLorebooksData(mapId, zoneMapId)
  -- internal:dm("Debug", "UpdateBookshelfLorebooksData")
  if not LMD.mapId or not LMD.mapTexture then return end
  if LMD.mapTexture ~= lastZoneBookshelf or LMD.mapId ~= lastMapIpBookshelf then
    -- internal:dm("Warn", "Bookshelf Data Updated")
    lastZoneBookshelf = LMD.mapTexture
    lastMapIpBookshelf = LMD.mapId
    bookshelves = LoreBooks_GetBookshelfDataFromMapId(mapId) -- Bookshelf
    COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_BOOKSHELF)
    return
  end
end

local function UpdateEideticLorebooksData(mapId, zoneMapId)
  -- internal:dm("Debug", "UpdateEideticLorebooksData")
  if not LMD.mapId or not LMD.mapTexture then return end
  if LMD.mapTexture ~= lastZoneEidetic or LMD.mapId ~= lastMapIpEidetic then
    -- internal:dm("Warn", "EideticBooks Updated")
    lastZoneEidetic = LMD.mapTexture
    lastMapIpEidetic = LMD.mapId
    eideticBooks = LoreBooks_GetEideticData(mapId, zoneMapId) -- All Eidetic Books in Zone
    COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_EIDETIC)
    return
  end
end

local function ShalidorCompassCallback()
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "ShalidorCompassCallback")

  if LoreBooks.lorebooks then
    for _, pinData in ipairs(LoreBooks.lorebooks) do
      local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinData[3], pinData[4])
      if not known and LoreBooks.db.filters[internal.PINS_COMPASS] then
        COMPASS_PINS.pinManager:CreatePin(internal.PINS_COMPASS, pinData, pinData[1], pinData[2])
      end
    end
  end
end

local function BookshelfCompassCallback()
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "BookshelfCompassCallback")

  if bookshelves then
    for _, pinData in ipairs(bookshelves) do
      if LoreBooks.db.filters[internal.PINS_COMPASS_BOOKSHELF] then
        COMPASS_PINS.pinManager:CreatePin(internal.PINS_COMPASS_BOOKSHELF, pinData, pinData.x, pinData.y)
      end
    end
  end
end

local function EideticMemoryCompassCallback()
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "EideticMemoryCompassCallback")

  local mapId = LMD.mapId
  if eideticBooks then
    for _, pinData in ipairs(eideticBooks) do
      local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pinData.c, pinData.b)
      local libgpsCoordinates = pinData.px and pinData.py
      local normalizedCoordinates = pinData.pnx and pinData.pny
      local usePrimaryLibgpsCoordinates = LMD.mapId == pinData.pm and libgpsCoordinates
      local usePrimaryNormalizedCoordinates = LMD.mapId == pinData.pm and normalizedCoordinates
      local fakePinInfo = pinData.fp and LMD.mapId ~= pinData.pm

      local xLoc, yLoc = nil, nil
      if usePrimaryLibgpsCoordinates and not usePrimaryNormalizedCoordinates then
        xLoc, yLoc = GPS:GlobalToLocal(pinData.px, pinData.py)
      elseif not usePrimaryLibgpsCoordinates and usePrimaryNormalizedCoordinates then
        xLoc, yLoc = pinData.pnx, pinData.pny
      end

      local hasQuestInfo = pinData.q
      local hasRequiredQuestInProgress = pinData.qp
      local hasRequiredQuestCompleted = pinData.qc
      local questNotInProgress = hasQuestInfo and hasRequiredQuestInProgress and not HasQuest(pinData.q)
      local questNotCompleted = hasQuestInfo and hasRequiredQuestCompleted and not HasCompletedQuest(pinData.q)
      --[[Does not meet requirements for quest pin, set the location information to nil]]--
      if (questNotInProgress ~= nil and questNotInProgress) or (questNotCompleted ~= nil and questNotCompleted) then
        xLoc, yLoc = nil, nil
      end

      local hasLocation = xLoc ~= nil and yLoc ~= nil
      local displayPin = hasLocation and not fakePinInfo and not known and LoreBooks.db.filters[internal.PINS_COMPASS_EIDETIC]
      if displayPin then
        COMPASS_PINS.pinManager:CreatePin(internal.PINS_COMPASS_EIDETIC, pinData, xLoc, yLoc)
      end -- end of mapId,  not known, filters PINS_COMPASS_EIDETIC
    end -- end of for loop
  end
end

local function MapCallbackCreateShalidorPins(pinType)
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "MapCallbackCreateShalidorPins: " .. pinType)

  local mapId = LMD.mapId
  local zoneMapId = LMD:GetParentMapIdFromZoneId(LMD.zoneId)
  UpdateShalidorLorebooksData(mapId, zoneMapId)
  local shouldDisplay = ShouldDisplayLoreBooks()

  -- Shalidor's Books
  if LoreBooks.lorebooks then
    for _, pinData in ipairs(LoreBooks.lorebooks) do
      local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pinData[3], pinData[4])
      -- Shalidor's Books Collected
      if pinType == internal.PINS_COLLECTED then
        if known and LMP:IsEnabled(internal.PINS_COLLECTED) then
          LMP:CreatePin(internal.PINS_COLLECTED, pinData, pinData[1], pinData[2])
        end
      end
      -- Shalidor's Books Unknown
      if pinType == internal.PINS_UNKNOWN then
        if not known and shouldDisplay and LMP:IsEnabled(internal.PINS_UNKNOWN) then
          LMP:CreatePin(internal.PINS_UNKNOWN, pinData, pinData[1], pinData[2])
        end
      end
    end
  end

end

local function MapCallbackCreateBookshelfPins(pinType)
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "MapCallbackCreateBookshelfPins")

  local mapId = LMD.mapId
  local zoneMapId = LMD:GetParentMapIdFromZoneId(LMD.zoneId)
  UpdateBookshelfLorebooksData(mapId, zoneMapId)

  -- Bookshelves
  if pinType == internal.PINS_BOOKSHELF and LMP:IsEnabled(internal.PINS_BOOKSHELF) then
    if bookshelves then
      -- internal:dm("Debug", "bookshelves PINS_BOOKSHELF")
      for _, pinData in ipairs(bookshelves) do
        pinData.texture = GetPinTextureBookshelf(pinData)
        pinData.pinName = GetString(LBOOKS_BOOKSHELF)
        LMP:CreatePin(internal.PINS_BOOKSHELF, pinData, pinData.x, pinData.y)
      end
    end
  end

end

local function MapCallbackCreateEideticPins(pinType)
  if LMD.isMacroMap then
    -- internal:dm("Debug", "Tamriel or Aurbis reached, stopped")
    return
  end
  -- internal:dm("Debug", "MapCallbackCreateEideticPins: " .. pinType)

  local zoneMapId = LMD:GetParentMapIdFromZoneId(LMD.zoneId)
  UpdateEideticLorebooksData(LMD.mapId, zoneMapId)
  local isDungeon = LMD.isDungeon
  local shouldDisplay = ShouldDisplayLoreBooks()

  -- Eidetic Memory Books
  if eideticBooks then
    for _, pinData in ipairs(eideticBooks) do
      local fakePinInfo = pinData.fp
      local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pinData.c, pinData.b)
      local libgpsCoordinates = pinData.px and pinData.py
      local libgpsZoneCoordinates = pinData.zx and pinData.zy
      local normalizedCoordinates = pinData.pnx and pinData.pny
      local normalizedZoneCoordinates = pinData.znx and pinData.zny
      local hasSourceMapId = pinData.sm
      local modifiedLibGpsCoordinateX, modifiedLibGpsCoordinateY = nil, nil
      if hasSourceMapId then
        local measurement = GPS:GetMapMeasurementByMapId(hasSourceMapId)
        if measurement and libgpsCoordinates then
          modifiedLibGpsCoordinateX, modifiedLibGpsCoordinateY = measurement:ToLocal(pinData.px, pinData.py)
        elseif measurement and libgpsZoneCoordinates then
          modifiedLibGpsCoordinateX, modifiedLibGpsCoordinateY = measurement:ToLocal(pinData.zx, pinData.zy)
        end
      end
      local hasPrimaryMapId = pinData.pm
      local hasZoneMapId = pinData.zm
      local usePrimaryMapId = LMD.mapId == pinData.pm
      local useZoneMapId = LMD.mapId == zoneMapId and pinData.zm == zoneMapId
      -- dualMapIds are for Cities where the px, and py are used for both maps
      local dualMapIds = zoneMapId == pinData.zm and LMD.mapId ~= pinData.pm and (not libgpsZoneCoordinates and not normalizedZoneCoordinates)
      --[[usePrimaryLibgpsCoordinates and usePrimaryNormalizedCoordinates
      useZoneLibgpsCoordinates and useZoneNormalizedCoordinates

      Are for pins that require both mapIds and separate Coordinates
      ]]--
      local usePrimaryLibgpsCoordinates = LMD.mapId == pinData.pm and (hasZoneMapId and zoneMapId ~= pinData.zm) and libgpsCoordinates
      local usePrimaryNormalizedCoordinates = LMD.mapId == pinData.pm and (hasZoneMapId and zoneMapId ~= pinData.zm) and normalizedCoordinates

      local useZoneLibgpsCoordinates = (hasZoneMapId and LMD.mapId == pinData.zm) and LMD.mapId ~= pinData.pm and libgpsZoneCoordinates
      local useZoneNormalizedCoordinates = (hasZoneMapId and LMD.mapId == pinData.zm) and LMD.mapId ~= pinData.pm and normalizedZoneCoordinates

      -- Special case that may not be needed anymore because of LibGPS updates
      local usePrimaryNormalizedSingleMapId = LMD.mapId == pinData.pm and normalizedCoordinates

      local dualMapIdsDungeonPin = hasPrimaryMapId and hasZoneMapId and (not isDungeon and pinData.d) and (hasZoneMapId and LMD.mapId == pinData.zm)

      pinData.xLoc, pinData.yLoc = nil, nil
      if (usePrimaryMapId or dualMapIds or usePrimaryLibgpsCoordinates) and libgpsCoordinates then
        if hasSourceMapId then pinData.xLoc, pinData.yLoc = modifiedLibGpsCoordinateX, modifiedLibGpsCoordinateY
        else pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.px, pinData.py) end
      elseif (usePrimaryMapId or dualMapIds or usePrimaryNormalizedCoordinates or usePrimaryNormalizedSingleMapId) and normalizedCoordinates then
        pinData.xLoc, pinData.yLoc = pinData.pnx, pinData.pny
      elseif (useZoneMapId or useZoneLibgpsCoordinates) and libgpsZoneCoordinates then
        if hasSourceMapId then pinData.xLoc, pinData.yLoc = modifiedLibGpsCoordinateX, modifiedLibGpsCoordinateY
        else pinData.xLoc, pinData.yLoc = GPS:GlobalToLocal(pinData.zx, pinData.zy) end
      elseif (useZoneMapId or useZoneNormalizedCoordinates) and normalizedZoneCoordinates then
        pinData.xLoc, pinData.yLoc = pinData.znx, pinData.zny
      end

      local hasQuestInfo = pinData.q
      local hasRequiredQuestInProgress = pinData.qp
      local hasRequiredQuestCompleted = pinData.qc
      local questNotInProgress = hasQuestInfo and hasRequiredQuestInProgress and not HasQuest(pinData.q)
      local questNotCompleted = hasQuestInfo and hasRequiredQuestCompleted and not HasCompletedQuest(pinData.q)
      --[[Does not meet requirements for quest pin, set the location information to nil]]--
      if ((questNotInProgress ~= nil and questNotInProgress) and not known) or (questNotCompleted ~= nil and questNotCompleted) then
        pinData.xLoc, pinData.yLoc = nil, nil
      end
      local hasLocation = pinData.xLoc ~= nil and pinData.yLoc ~= nil
      local meetsPinCriteria = (isDungeon and pinData.d) or (not isDungeon and not pinData.d) or fakePinInfo or dualMapIdsDungeonPin
      local displayKnownPin = hasLocation and meetsPinCriteria and pinType == internal.PINS_EIDETIC_COLLECTED and known and LMP:IsEnabled(internal.PINS_EIDETIC_COLLECTED)
      local displayUnnownPin = hasLocation and meetsPinCriteria and pinType == internal.PINS_EIDETIC and not known and shouldDisplay and LMP:IsEnabled(internal.PINS_EIDETIC)

      -- Eidetic Memory Collected
      if displayKnownPin then
        LMP:CreatePin(internal.PINS_EIDETIC_COLLECTED, pinData, pinData.xLoc, pinData.yLoc)
      end
      -- Eidetic Memory Unknown
      if displayUnnownPin then
        LMP:CreatePin(internal.PINS_EIDETIC, pinData, pinData.xLoc, pinData.yLoc)
      end

    end
  end

end

local function InitializePins()

  local pinTextures = internal.PIN_TEXTURES
  local pinTextureLevel = LoreBooks.db.pinTexture.level
  local pinTextureSize = LoreBooks.db.pinTexture.size
  local invertedTextureFromTable = 2

  local mapPinLayout_eidetic = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize, grayscale = IsEideticPinGrayscale }
  local mapPinLayout_eideticCollected = { level = pinTextureLevel, texture = GetPinTextureEidetic, size = pinTextureSize }
  local mapPinLayout_unknown = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize }
  local mapPinLayout_collected = { level = pinTextureLevel, texture = GetPinTexture, size = pinTextureSize, grayscale = IsShaliPinGrayscale }
  local mapPinLayout_bookshelf = { level = pinTextureLevel, texture = GetPinTextureBookshelf, size = pinTextureSize }

  local compassTextureType = LoreBooks.db.pinTexture.type
  local compassEideticTextureType = LoreBooks.db.pinTextureEidetic
  local compassMaxDistance = LoreBooks.db.compassMaxDistance
  local compassLayoutTexture = pinTextures[compassTextureType][invertedTextureFromTable] or internal.MISSING_TEXTURE
  local compassEideticLayoutTexture = pinTextures[compassEideticTextureType][invertedTextureFromTable] or internal.MISSING_TEXTURE
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
          local _, texture = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.pinTag[3], pin.pinTag[4])
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
  local compassPinLayoutEidetic = {
    maxDistance = compassMaxDistance,
    texture = compassEideticLayoutTexture,
    sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
      if zo_abs(normalizedAngle) > 0.25 then
        pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
      else
        pin:SetDimensions(48, 48)
      end
    end,
    additionalLayout = {
      [CUSTOM_COMPASS_LAYOUT_UPDATE] = function(pin)
        if (LoreBooks.db.pinTextureEidetic == internal.PIN_ICON_REAL) then
          -- replace icon with icon from LoreLibrary
          local _, texture = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pin.pinTag.c, pin.pinTag.b)
          local icon = pin:GetNamedChild("Background")
          if icon == internal.MISSING_TEXTURE then icon = internal.PLACEHOLDER_TEXTURE end
          icon:SetTexture(texture)
        end
      end,
    },
    mapPinTypeString = internal.PINS_EIDETIC,
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
  LMP:AddPinType(internal.PINS_EIDETIC, function() MapCallbackCreateEideticPins(internal.PINS_EIDETIC) end, nil, mapPinLayout_eidetic, pinTooltipCreatorEidetic)
  LMP:AddPinType(internal.PINS_EIDETIC_COLLECTED, function() MapCallbackCreateEideticPins(internal.PINS_EIDETIC_COLLECTED) end, nil, mapPinLayout_eideticCollected, pinTooltipCreatorEidetic)
  LMP:AddPinType(internal.PINS_BOOKSHELF, function() MapCallbackCreateBookshelfPins(internal.PINS_BOOKSHELF) end, nil, mapPinLayout_bookshelf, pinTooltipCreatorBookshelf)

  -- add map filters
  local eideticPinCollected = zo_strformat(LBOOKS_FILTER_COLLECTED_FORMATTER, GetLoreCategoryInfo(internal.LORE_LIBRARY_EIDETIC))

  LMP:AddPinFilter(internal.PINS_UNKNOWN, GetString(LBOOKS_FILTER_UNKNOWN), true, LoreBooks.db.filters, internal.PINS_UNKNOWN)
  LMP:AddPinFilter(internal.PINS_COLLECTED, GetString(LBOOKS_FILTER_COLLECTED), true, LoreBooks.db.filters, internal.PINS_COLLECTED)
  LMP:AddPinFilter(internal.PINS_EIDETIC, GetLoreCategoryInfo(internal.LORE_LIBRARY_EIDETIC), true, LoreBooks.db.filters, internal.PINS_EIDETIC)
  LMP:AddPinFilter(internal.PINS_EIDETIC_COLLECTED, eideticPinCollected, true, LoreBooks.db.filters, internal.PINS_EIDETIC_COLLECTED)
  LMP:AddPinFilter(internal.PINS_BOOKSHELF, GetString(LBOOKS_FILTER_BOOKSHELF), true, LoreBooks.db.filters, internal.PINS_BOOKSHELF)

  LMP:SetPinFilterHidden(internal.PINS_UNKNOWN, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_COLLECTED, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_EIDETIC, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_EIDETIC_COLLECTED, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)
  LMP:SetPinFilterHidden(internal.PINS_BOOKSHELF, LIBMAPPINS_BATTLEGROUND_MAPGROUP, true)

  -- add handler for the left click
  LMP:SetClickHandlers(internal.PINS_UNKNOWN, {
    [1] = {
      name = function(pin)
        local title = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.m_PinTag[3], pin.m_PinTag[4])
        return zo_strformat(LBOOKS_SET_WAYPOINT, title)
      end,
      show = function(pin)
        local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_SHALIDOR, pin.m_PinTag[3], pin.m_PinTag[4])
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

  LMP:SetClickHandlers(internal.PINS_EIDETIC, {
    [1] = {
      name = function(pin)
        local title = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pin.m_PinTag.c, pin.m_PinTag.b)
        return zo_strformat(LBOOKS_SET_WAYPOINT, title)
      end,
      show = function(pin)
        local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pin.m_PinTag.c, pin.m_PinTag.b)
        return LoreBooks.db.showClickMenu and not known
      end,
      duplicates = function(pin1, pin2)
        return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b)
      end,
      callback = function(pin)
        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY)
      end,
    }
  })
  LMP:SetClickHandlers(internal.PINS_EIDETIC_COLLECTED, {
    [1] = {
      name = function(pin)
        local title = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pin.m_PinTag.c, pin.m_PinTag.b)
        return zo_strformat(LBOOKS_SET_WAYPOINT, title)
      end,
      show = function(pin)
        local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, pin.m_PinTag.c, pin.m_PinTag.b)
        return LoreBooks.db.showClickMenu and known == true
      end,
      duplicates = function(pin1, pin2)
        return (pin1.m_PinTag.b == pin2.m_PinTag.c and pin1.m_PinTag.b == pin2.m_PinTag.b)
      end,
      callback = function(pin)
        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY)
      end,
    }
  })

  -- initialize compass pins
  COMPASS_PINS:AddCustomPin(internal.PINS_COMPASS, function() ShalidorCompassCallback() end, compassPinLayout, LoreBooks.db.filters)
  COMPASS_PINS:AddCustomPin(internal.PINS_COMPASS_EIDETIC, function() EideticMemoryCompassCallback() end, compassPinLayoutEidetic, LoreBooks.db.filters)
  COMPASS_PINS:AddCustomPin(internal.PINS_COMPASS_BOOKSHELF, function() BookshelfCompassCallback() end, compassPinLayoutBookshelf, LoreBooks.db.filters)
  COMPASS_PINS:RefreshPins(internal.PINS_COMPASS)
  COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_EIDETIC)
  COMPASS_PINS:RefreshPins(internal.PINS_COMPASS_BOOKSHELF)
end

local function OnGamepadPreferredModeChanged()
  if IsInGamepadPreferredMode() then
    INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
  else
    INFORMATION_TOOLTIP = InformationTooltip
  end
end

local function OnSearchTextChanged(self)

  ZO_EditDefaultText_OnTextChanged(self)

  local search = self:GetText()
  LORE_LIBRARY.search = search

  LORE_LIBRARY.navigationTree:ClearSelectedNode()
  LORE_LIBRARY:BuildCategoryList()
  LORE_LIBRARY:BuildBookList()

end

local function NameSorter(left, right)
  return left.name < right.name
end

local function Sanitize(value)
  return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
end

local function IsFoundInLoreLibrary(search, data)

  if string.find(string.lower(data.name), search) then
    return true
  end

  for bookIndex = 1, data.totalBooks do
    local title = LoreBooks_GetNewLoreBookInfo(data.categoryIndex, data.collectionIndex, bookIndex)
    if string.find(string.lower(title), search) then
      return true
    end
  end

  return false

end

local function IsFoundInMailList(search, mailList)
  if mailList.name and string.find(string.lower(mailList.name), search) then
    return true
  end

  local numMessages = select(1, GetNumUnlockedMailsInMailList(mailList.mailListIndex))
  for messageIndex = 1, numMessages do
    local _, subject = GetMailInfoFromMailList(mailList.mailListIndex, messageIndex)
    if subject and string.find(string.lower(subject), search) then
      return true
    end
  end

  return false

end

local function ShowLoreLibraryReport(forceHide)

  LoreBooksCopyReport:SetHidden(true)
  if forceHide then
    reportShown = false
    LoreBooksReport:SetHidden(forceHide)
  else
    if ZO_LoreLibrary:IsHidden() then
      LoreBooksReport:SetHidden(true)
      ZO_LoreLibrary:SetHidden(false)
      reportShown = false
    else
      LoreBooksReport:SetHidden(false)
      ZO_LoreLibrary:SetHidden(true)
      reportShown = true
    end
  end

  KEYBIND_STRIP:UpdateKeybindButtonGroup(loreLibraryReportKeybind)

end

local function ShowLoreLibraryCopyReport()

  LoreBooksReport:SetHidden(true)

  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SelectAll()
  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):TakeFocus()
  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetTopLineIndex(1)

  LoreBooksCopyReport:SetHidden(false)

end

local function IsReportShown()
  return reportShown
end

local function BuildShalidorReport()

  local function DisplayCollectionsReport(collectionsData)

    local yCollectionIndex = 48

    table.sort(collectionsData, function(a, b)
      return a.totalBooks - a.numKnownBooks < b.totalBooks - b.numKnownBooks
    end)

    local lastObject = 0
    for collectionIndex, data in pairs(collectionsData) do

      local shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
      local shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)

      if data.numKnownBooks ~= data.totalBooks then

        --[[TODO why was this a local assignment shadowed above and why is it here? ]]--
        shalidorCollectionName = GetControl(LoreBooksReportContainerScrollChild, "CollectionName" .. collectionIndex)
        shalidorCollectionValue = GetControl(LoreBooksReportContainerScrollChild, "CollectionValue" .. collectionIndex)

        if not shalidorCollectionName then
          shalidorCollectionName = CreateControlFromVirtual("$(parent)CollectionName", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionName_Template", collectionIndex)
          shalidorCollectionValue = CreateControlFromVirtual("$(parent)CollectionValue", LoreBooksReportContainerScrollChild, "Lorebook_ShaliCollectionValue_Template", collectionIndex)
        end

        shalidorCollectionValue:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 20, yCollectionIndex)
        shalidorCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 70, yCollectionIndex)

        yCollectionIndex = yCollectionIndex + 32

        shalidorCollectionName:SetText(data.name)
        shalidorCollectionValue:SetText(zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks))

        copyReport = copyReport .. "\n\n" .. data.name .. " :\n" .. zo_strformat("<<1>>/<<2>>", data.numKnownBooks, data.totalBooks)
        lastObject = yCollectionIndex
      elseif shalidorCollectionName then
        -- Dirty trick
        shalidorCollectionName:SetHidden(true)
        shalidorCollectionValue:SetHidden(true)
      end

    end

    return lastObject + 10

  end

  local POINTS_FOR_RANK_MAX = 1380

  local totalKnown = 0
  local points = 0
  local booksInShalidor = 0

  local collectionsData = {}
  local _, numCollections = GetLoreCategoryInfo(internal.LORE_LIBRARY_SHALIDOR)
  for collectionIndex = 1, numCollections do
    local collectionName, _, numKnownBooks, totalBooks, hidden = LoreBooks_GetNewLoreCollectionInfo(1, collectionIndex)
    if not hidden then
      totalKnown = totalKnown + numKnownBooks
      booksInShalidor = booksInShalidor + totalBooks
      points = points + numKnownBooks * 5
      collectionsData[collectionIndex] = { name = collectionName, numKnownBooks = numKnownBooks, totalBooks = totalBooks }
      if numKnownBooks == totalBooks then
        points = points + 20
      end
    end
  end

  local shalidorHeaderText = GetControl(LoreBooksReport, "ShalidorHeaderText")
  local lastObject = 52

  if points < POINTS_FOR_RANK_MAX then
    copyReport = GetString(LBOOKS_RS_FEW_BOOKS_MISSING)
    shalidorHeaderText:SetText(copyReport)
    lastObject = DisplayCollectionsReport(collectionsData)
  elseif totalKnown < booksInShalidor then
    copyReport = GetString(LBOOKS_RS_MDONE_BOOKS_MISSING)
    shalidorHeaderText:SetText(copyReport)
    lastObject = DisplayCollectionsReport(collectionsData)
  else
    copyReport = GetString(LBOOKS_RS_GOT_ALL_BOOKS)
    shalidorHeaderText:SetText(copyReport)
  end

  return lastObject

end

local function AllowEideticReport()
  return LORE_LIBRARY.eideticPossibleCollected - (LORE_LIBRARY.eideticCurrentlyCollected or 0) <= 225
end

--[[TODO BuildEideticReportPerMap uses mapIndex which was ["mn"] which is no longer used

Added GetMapIdByIndex to get the main zone's MapId and use that to at least get
some books. This probably needs more updating.
]]--
local function BuildEideticReportPerMap(lastObject)

  local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
  eideticHeaderText:ClearAnchors()

  eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)

  if AllowEideticReport() then

    eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)

    local eideticData = {}
    local eideticSeen = {}
    local yCollectionIndex = lastObject + 48

    for mapIndex = 1, GetNumMaps() do

      eideticData[mapIndex] = {}
      local mapId = GetMapIdByIndex(mapIndex)
      eideticBooks = LoreBooks_GetEideticData(mapId, mapId)

      if eideticBooks then

        for _, bookData in ipairs(eideticBooks) do
          local _, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, bookData.c, bookData.b)

          if not known and not eideticSeen[bookData.c .. "-" .. bookData.b] then
            table.insert(eideticData[mapIndex], bookData)
            eideticSeen[bookData.c .. "-" .. bookData.b] = true
          end

        end

        -- Create controls

        local eideticBooksInMap = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInMap" .. mapIndex)
        local eideticMapName = GetControl(LoreBooksReportContainerScrollChild, "EideticMapName" .. mapIndex)
        local eideticReportForMap = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForMap" .. mapIndex)

        if not eideticMapName then
          eideticBooksInMap = CreateControlFromVirtual("$(parent)EideticBooksInMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInMap_Template", mapIndex)
          eideticMapName = CreateControlFromVirtual("$(parent)EideticMapName", LoreBooksReportContainerScrollChild, "Lorebook_EideticMapName_Template", mapIndex)
          eideticReportForMap = CreateControlFromVirtual("$(parent)EideticReportForMap", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForMap_Template", mapIndex)
        else
          eideticBooksInMap:SetHidden(false)
          eideticMapName:SetHidden(false)
          eideticReportForMap:SetHidden(false)
        end

        local missingInMap = #eideticData[mapIndex]
        if missingInMap > 0 then

          eideticBooksInMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
          eideticMapName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
          eideticReportForMap:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)

          eideticBooksInMap:SetText(missingInMap)
          eideticMapName:SetText(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)))

          local eideticReport = ""
          for index, data in ipairs(eideticData[mapIndex]) do
            local bookName = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, data.c, data.b)
            eideticReport = zo_strjoin(" ; ", bookName, eideticReport)
          end

          if string.len(eideticReport) > 0 then
            eideticReport = string.sub(eideticReport, 0, -3)
          end

          eideticReportForMap:SetText(eideticReport)
          copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameByIndex(mapIndex)), missingInMap, eideticReport)

          eideticReportForMap:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.

          yCollectionIndex = yCollectionIndex + eideticReportForMap:GetHeight() + 32

        end

      end
    end

  else
    eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
  end

end

local function BuildEideticReportPerCollection(lastObject)

  local eideticHeaderText = GetControl(LoreBooksReport, "EideticHeaderText")
  eideticHeaderText:ClearAnchors()

  eideticHeaderText:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 4, lastObject)

  if AllowEideticReport() then

    eideticHeaderText:SetText(GetString(LBOOKS_RE_FEW_BOOKS_MISSING))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_FEW_BOOKS_MISSING)

    local totalBooks = 0
    local eideticData = {}
    local yCollectionIndex = lastObject + 48

    local categoryName, numCollections = GetLoreCategoryInfo(internal.LORE_LIBRARY_EIDETIC)

    for collectionIndex = 1, numCollections do

      eideticData[collectionIndex] = {}

      local collectionName, _, _, totalBooksInCollection, hidden = LoreBooks_GetNewLoreCollectionInfo(internal.LORE_LIBRARY_EIDETIC, collectionIndex)

      if not hidden then

        for bookIndex = 1, totalBooksInCollection do
          local bookName, _, known = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, collectionIndex, bookIndex)

          if not known then
            eideticData[collectionIndex][bookIndex] = bookName
          end
        end

        -- Create controls

        local missingInCollection = NonContiguousCount(eideticData[collectionIndex])
        if missingInCollection > 0 then

          local eideticReport = ""

          local eideticBooksInCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticBooksInCollection" .. collectionIndex)
          local eideticCollectionName = GetControl(LoreBooksReportContainerScrollChild, "EideticCollectionName" .. collectionIndex)
          local eideticReportForCollection = GetControl(LoreBooksReportContainerScrollChild, "EideticReportForCollection" .. collectionIndex)

          if not eideticCollectionName then
            eideticBooksInCollection = CreateControlFromVirtual("$(parent)EideticBooksInCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticBooksInCollection_Template", collectionIndex)
            eideticCollectionName = CreateControlFromVirtual("$(parent)EideticCollectionName", LoreBooksReportContainerScrollChild, "Lorebook_EideticCollectionName_Template", collectionIndex)
            eideticReportForCollection = CreateControlFromVirtual("$(parent)EideticReportForCollection", LoreBooksReportContainerScrollChild, "Lorebook_EideticReportForCollection_Template", collectionIndex)
          else
            eideticBooksInCollection:SetHidden(false)
            eideticCollectionName:SetHidden(false)
            eideticReportForCollection:SetHidden(false)
          end

          eideticBooksInCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 0, yCollectionIndex)
          eideticCollectionName:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 25, yCollectionIndex)
          eideticReportForCollection:SetAnchor(TOPLEFT, LoreBooksReportContainerScrollChild, TOPLEFT, 50, yCollectionIndex + 24)

          eideticBooksInCollection:SetText(missingInCollection)
          eideticCollectionName:SetText(collectionName)

          for bookIndex, bookName in pairs(eideticData[collectionIndex]) do

            local bookLocation = ""
            local bookData = LoreBooks_GetNewEideticData(internal.LORE_LIBRARY_EIDETIC, collectionIndex, bookIndex) -- specific book by book ID
            if bookData then
              if bookData.r then
                -- ReportPerCollection
                bookLocation = "[B] "
              elseif bookData.e then
                if bookData.e[1] then
                  bookLocation = string.format("[%s] ", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(bookData.e[1].pm)))
                else
                  bookLocation = "[Q] "
                end
              end
            end

            eideticReport = zo_strjoin("; ", bookLocation .. bookName, eideticReport)

          end

          if string.len(eideticReport) > 0 then
            eideticReport = string.sub(eideticReport, 0, -3)
          end
          eideticReportForCollection:SetText(eideticReport)

          copyReport = copyReport .. "\n\n" .. zo_strformat("<<1>> (<<2>>):\n<<3>>", collectionName, missingInCollection, eideticReport)

          eideticReportForCollection:GetHeight() -- Needed to let the UI recalculate the correct value. Anchors could be optimized.

          yCollectionIndex = yCollectionIndex + eideticReportForCollection:GetHeight() + 32

          totalBooks = totalBooks + missingInCollection
        end
      end
    end

  else
    eideticHeaderText:SetText(GetString(LBOOKS_RE_THREESHOLD_ERROR))
    copyReport = copyReport .. "\n\n" .. GetString(LBOOKS_RE_THREESHOLD_ERROR)
  end

end

local function BuildEideticReport(lastObject)

  if eideticModeAsked == 2 then
    BuildEideticReportPerCollection(lastObject)
  else
    BuildEideticReportPerMap(lastObject)
  end

end

local function HidePreviousReport()
  for childIndex = 1, LoreBooksReportContainerScrollChild:GetNumChildren() do
    local childObject = LoreBooksReportContainerScrollChild:GetChild(childIndex)
    local childName = childObject:GetName()
    if childName ~= "LoreBooksReportEideticHeaderText" and string.find(childName, "Eidetic") then
      childObject:SetHidden(true)
    end
  end
end

--[[TODO: use ZO_ScrollList. Difficulty : height is not the same]]--
local function BuildLoreBookSummary()

  HidePreviousReport()

  local lastObject = BuildShalidorReport()

  BuildEideticReport(lastObject)

  LoreBooksCopyReport:GetNamedChild("Content"):GetNamedChild("Edit"):SetText(copyReport)

end

local function SwitchLoreLibraryReportMode()

  if not eideticModeAsked or eideticModeAsked == 1 then
    eideticModeAsked = 2
  else
    eideticModeAsked = 1
  end

  BuildLoreBookSummary()

end

local function BuildCategoryList(self)

  if self.control:IsControlHidden() then
    self.dirty = true
    return
  end

  self.totalCurrentlyCollected = 0
  self.totalPossibleCollected = 0
  self.motifsCurrentlyCollected = 0
  self.motifsPossibleCollected = 0
  self.shalidorCurrentlyCollected = 0
  self.shalidorPossibleCollected = 0
  self.eideticCurrentlyCollected = 0
  self.eideticPossibleCollected = 0

  self.navigationTree:Reset()

  local lbcategories = {}

  for categoryIndex = 1, GetNumLoreCategories() do
    local categoryName, numCollections = GetLoreCategoryInfo(categoryIndex)
    for collectionIndex = 1, numCollections do
      local collectionName, _, _, _, hidden = LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex)
      if collectionName and (not hidden) then
        lbcategories[#lbcategories + 1] = { categoryIndex = categoryIndex, name = categoryName, numCollections = numCollections }
        break --Don't really understand why ZOS added this.
      end
    end
  end

  table.sort(lbcategories, NameSorter)
  local firstNode = nil
  local collectionNodeToSelect = nil
  for i, categoryData in ipairs(lbcategories) do
    local parent = self.navigationTree:AddNode("ZO_LabelHeader", categoryData)

    local categoryIndex = categoryData.categoryIndex
    local numCollections = categoryData.numCollections

    lbcategories[i].lbcollections = {}

    for collectionIndex = 1, numCollections do
      local collectionName, description, numKnownBooks, totalBooks, hidden, gamepadIcon, collectionId = LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex)
      if collectionName and collectionName ~= "" then
        lbcategories[i].lbcollections[#lbcategories[i].lbcollections + 1] = { categoryIndex = categoryIndex, collectionIndex = collectionIndex, name = collectionName, description = description, numKnownBooks = numKnownBooks, totalBooks = totalBooks, collectionId = collectionId }
        self.totalCurrentlyCollected = self.totalCurrentlyCollected + numKnownBooks
        self.totalPossibleCollected = self.totalPossibleCollected + totalBooks

        if categoryIndex == internal.LORE_LIBRARY_CRAFTING then
          -- CRAFTING
          self.motifsCurrentlyCollected = self.motifsCurrentlyCollected + numKnownBooks
          self.motifsPossibleCollected = self.motifsPossibleCollected + totalBooks
        elseif categoryIndex == internal.LORE_LIBRARY_EIDETIC then
          --
          self.eideticCurrentlyCollected = self.eideticCurrentlyCollected + numKnownBooks
          self.eideticPossibleCollected = self.eideticPossibleCollected + totalBooks
        end
      end
    end

    table.sort(lbcategories[i].lbcollections, NameSorter)

    local searchText = LORE_LIBRARY.search or ""
    local search = Sanitize(string.lower(searchText))
    local searchActive = search ~= "" and string.len(searchText) >= 2

    for _, collectionData in ipairs(lbcategories[i].lbcollections) do
      local node = self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", collectionData, parent)
      if not firstNode then firstNode = node end
      if searchActive then
        if IsFoundInLoreLibrary(search, collectionData) then
          collectionNodeToSelect = node
        end
      elseif self.collectionIdToSelect and self.collectionIdToSelect == collectionData.collectionId then
        collectionNodeToSelect = node
      end
    end

  end

  local mailListParent = self.navigationTree:AddNode("ZO_LabelHeader", { name = GetString(SI_LORE_LIBRARY_MAIL_LIST_HEADER) })
  local mailLists = ZO_LoreLibrary_GetSortedMailLists()
  local searchText = LORE_LIBRARY.search or ""
  local search = Sanitize(string.lower(searchText))
  local searchActive = search ~= "" and string.len(searchText) >= 2
  local mailListNodeToSelect = nil

  for _, mailList in ipairs(mailLists) do
    if mailList.total > 0 then
      local node = self.navigationTree:AddNode("ZO_LoreLibraryNavigationEntry", mailList, mailListParent)
      if searchActive and IsFoundInMailList(search, mailList) then
        mailListNodeToSelect = node
      end
    end
  end

  if mailListNodeToSelect then
    collectionNodeToSelect = mailListNodeToSelect
  elseif not collectionNodeToSelect then
    collectionNodeToSelect = firstNode
  end

  self.navigationTree:Commit(collectionNodeToSelect, true)
  self:RefreshCollectedInfo()

  KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

  self.collectionIdToSelect = nil
  self.dirty = false

  return true

end

local function GetMailListMessages(mailListIndex)
  local numMessages = select(1, GetNumUnlockedMailsInMailList(mailListIndex))
  local messages = {}
  for messageIndex = 1, numMessages do
    local sender, subject, body, icon = GetMailInfoFromMailList(mailListIndex, messageIndex)
    local title = zo_strformat(SI_LORE_LIBRARY_MAIL_ENTRY_FORMATTER, subject, messageIndex)
    table.insert(messages, {
      mailListIndex = mailListIndex,
      messageIndex = messageIndex,
      title = title,
      subject = subject,
      body = body,
      icon = icon,
      sender = sender,
    })
  end
  return messages
end

local function FilterScrollList(self)

  local BOOK_DATA_TYPE = 1
  local MAIL_DATA_TYPE = 2
  local MAIL_HEADER_TYPE = 3

  local categoryData = self.owner.navigationTree:GetSelectedData()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ScrollList_Clear(self.list)

  local searchText = LORE_LIBRARY.search or ""
  local search = Sanitize(string.lower(searchText))
  local searchActive = search ~= "" and string.len(searchText) >= 2

  if categoryData and categoryData.mailListIndex ~= nil then
    local currentMailSenderLower = ""
    local messages = GetMailListMessages(categoryData.mailListIndex)
    for index, messageData in ipairs(messages) do
      local matchesSearch = not searchActive
        or string.find(string.lower(messageData.title), search)
        or (messageData.subject and string.find(string.lower(messageData.subject), search))
        or (messageData.sender and string.find(zo_strlower(messageData.sender), search))

      if matchesSearch then
        local nextSender = messageData.sender
        local nextSenderLower = zo_strlower(nextSender)
        if currentMailSenderLower ~= nextSenderLower then
          currentMailSenderLower = nextSenderLower
          local senderClean = zo_strIsUpper(nextSender) and nextSenderLower or nextSender
          table.insert(scrollData, ZO_ScrollList_CreateDataEntry(MAIL_HEADER_TYPE, {
            mailListIndex = messageData.mailListIndex,
            name = zo_strformat(SI_LORE_LIBRARY_MAIL_SENDER_FORMATTER, senderClean),
            sortOrder = index,
          }))
        end
        messageData.sortOrder = index
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(MAIL_DATA_TYPE, messageData))
      end
    end
  elseif categoryData then
    local categoryIndex = self.owner:GetSelectedCategoryIndex()
    local collectionIndex = self.owner:GetSelectedCollectionIndex()
    local totalBooks = select(4, LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex))

    if searchActive then
      for bookIndex = 1, totalBooks do
        local bookName = LoreBooks_GetNewLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
        if string.find(string.lower(bookName), search) then
          scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BOOK_DATA_TYPE, { categoryIndex = categoryIndex, collectionIndex = collectionIndex, bookIndex = bookIndex })
        end
      end
    else
      for bookIndex = 1, totalBooks do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(BOOK_DATA_TYPE, { categoryIndex = categoryIndex, collectionIndex = collectionIndex, bookIndex = bookIndex })
      end
    end
  end

  return true
end

--[[TODO Update Right Click coordinates menu from Lore Library ]]--
local function OnRowMouseUp(control, button)
  if button == MOUSE_BUTTON_INDEX_RIGHT then
    ClearMenu()

    -- Cannot access to self. (and self ~= control here)
    --SetMenuHiddenCallback(function() self:UnlockSelection() end)
    --self:LockSelection()

    if control.bookIndex ~= nil and control.known then
      AddMenuItem(GetString(SI_LORE_LIBRARY_READ), function() ZO_LoreLibrary_ReadBook(control.categoryIndex, control.collectionIndex, control.bookIndex) end)
    end

    if control.bookIndex ~= nil and IsChatSystemAvailableForCurrentPlatform() then
      AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
        local link = ZO_LinkHandler_CreateChatLink(GetLoreBookLink, control.categoryIndex, control.collectionIndex, control.bookIndex)
        ZO_LinkHandler_InsertLink(link)
      end)
    end

    if control.bookIndex ~= nil and control.categoryIndex == internal.LORE_LIBRARY_SHALIDOR then
      local lorebookInfoOnBook = LoreBooks_GetDataOfBook(control.categoryIndex, control.collectionIndex, control.bookIndex)
      for resultEntry, resultData in ipairs(lorebookInfoOnBook) do
        local fakePin = false
        if resultData.data[5] and resultData.data[5] == 9999 then fakePin = true end

        if resultData.mapId and not fakePin then
          AddMenuItem(zo_strformat("<<1>> : <<2>>x<<3>>", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(resultData.mapId)), (resultData.locX * 100), (resultData.locY * 100)),
            function()
              SetMapToMapId(resultData.mapId)
              GPS:SetPlayerChoseCurrentMap()
              CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
              PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)
              PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, resultData.locX, resultData.locY)
              if (not ZO_WorldMap_IsWorldMapShowing()) then
                if IsInGamepadPreferredMode() then
                  SCENE_MANAGER:Push("gamepad_worldMap")
                else
                  MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
                end
                zo_callLater(function() ZO_WorldMap_GetPanAndZoom():PanToNormalizedPosition(resultData.locX, resultData.locY) end, 1000)
              end
            end)
        end

      end
    elseif control.bookIndex ~= nil and control.categoryIndex == internal.LORE_LIBRARY_EIDETIC then

      local bookData = LoreBooks_GetNewEideticData(control.categoryIndex, control.collectionIndex, control.bookIndex) -- [coordinates] specific book by book ID
      local hasEideticBooks = bookData and bookData.c and NonContiguousCount(bookData.e) >= 1

      if hasEideticBooks then

        for index, data in ipairs(bookData.e) do
          local mapId = data.pm
          local mapName = GetMapNameById(mapId)
          local libgpsCoordinates = data.px and data.py
          local normalizedCoordinates = data.pnx and data.pny

          if not data.r and not data.fp and (libgpsCoordinates or normalizedCoordinates) and not data.zt then
            -- right click from lore library menu

            local xLoc, yLoc
            if libgpsCoordinates then
              local measurement = GPS:GetMapMeasurementByMapId(mapId)
              if measurement then
                xLoc, yLoc = measurement:ToLocal(data.px, data.py)
              end
            end
            if normalizedCoordinates then
              xLoc = data.pnx
              yLoc = data.pny
            end
            local xTooltip = ("%0.02f"):format(zo_round(xLoc * 10000) / 100)
            local yTooltip = ("%0.02f"):format(zo_round(yLoc * 10000) / 100)
            AddMenuItem(zo_strformat("<<1>> (<<2>>x<<3>>)", zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, mapName), xTooltip, yTooltip),
              function()
                SetMapToMapId(mapId)
                GPS:SetPlayerChoseCurrentMap()
                CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
                PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, xLoc, yLoc)
                PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, xLoc, yLoc)
                if (not ZO_WorldMap_IsWorldMapShowing()) then
                  if IsInGamepadPreferredMode() then
                    SCENE_MANAGER:Push("gamepad_worldMap")
                  else
                    MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
                  end
                  zo_callLater(function() ZO_WorldMap_GetPanAndZoom():PanToNormalizedPosition(xLoc, yLoc) end, 1000)
                end
              end)

          end -- end if
        end -- end for loop on ["e"]
      end -- end if has ["c"] and ["e"]

    end

    ShowMenu(control)

  end
end

--[[TODO Update Mouse Hover tooltip for Lore Library ]]--
local function OnMouseEnter(self, categoryIndex, collectionIndex, bookIndex)
  --d("we are here")

  -- No LORE_LIBRARY_SHALIDOR for now.
  if categoryIndex == internal.LORE_LIBRARY_EIDETIC then

    local bookData = LoreBooks_GetNewEideticData(categoryIndex, collectionIndex, bookIndex) -- [all tooltips] specific book by book ID
    --d(bookData)
    local hasEideticData = bookData and bookData.c
    if hasEideticData then
      --d("first c or cn")
      local bookName = LoreBooks_GetNewLoreBookInfo(categoryIndex, collectionIndex, bookIndex) -- Could be retrieved automatically
      InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, 0, TOPRIGHT)
      InformationTooltip:AddLine(bookName, "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
      ZO_Tooltip_AddDivider(InformationTooltip)

      local addDivider = false
      local entryWeight = {}
      if bookData.q then
        local questName = GetQuestName(bookData.q)
        local questDetails = GetQuestLocation(bookData.q)
        local questInfo
        if questDetails ~= "" then questInfo = string.format(GetString(LBOOKS_QUEST_BOOK_ZONENAME), questDetails, questName)
        else questInfo = string.format(GetString(LBOOKS_QUEST_BOOK), questDetails, questName) end
        if questName then
          InformationTooltip:AddLine(questInfo, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        end
      elseif bookData.r and bookData.m and NonContiguousCount(bookData.m) >= 1 then
        -- mouse hover over for tooltip
        --d("third r and m")

        InformationTooltip:AddLine(GetString(LBOOKS_RANDOM_POSITION), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        ZO_Tooltip_AddDivider(InformationTooltip)

        for mapId, _ in pairs(bookData.m) do
          -- builds tooltips from all the locations
          InformationTooltip:AddLine(zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(mapId)), "", ZO_SELECTED_TEXT:UnpackRGB())
        end

      else
        --d("the else")
        for _, data in ipairs(bookData.e) do
          local isFakePin = data and data.fp
          if not isFakePin then
            local insert = true
            local isRandom = data.r -- mouse hover over for tooltip
            local inDungeon = data.d
            local hasZoneTag = data.zt

            local mapId = data.pm
            local name, _, _, zoneIndex, _ = GetMapInfoById(mapId)
            local zoneNameZondId = nil
            if hasZoneTag then
              zoneNameZondId = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameById(data.zt))
            end
            --d(name)
            --d(zoneIndex)

            local weight = 0
            if isRandom then
              weight = weight + 1
            end
            if inDungeon then
              weight = weight + 2
            end

            local zoneName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetZoneNameByIndex(zoneIndex))
            local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapNameById(mapId))

            local bookPosition
            if zoneName ~= mapName and not hasZoneTag then
              bookPosition = zo_strformat("<<1>> - <<2>>", mapName, zoneName)
              if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
                insert = false
              end
            else
              if hasZoneTag then
                bookPosition = zoneNameZondId
              else
                bookPosition = mapName
              end
              if entryWeight[bookPosition] and entryWeight[bookPosition][weight] then
                insert = false
              end
            end

            if not entryWeight[bookPosition] then entryWeight[bookPosition] = {} end
            entryWeight[bookPosition][weight] = true

            if insert then
              if addDivider then
                ZO_Tooltip_AddDivider(InformationTooltip)
              end
              addDivider = true

              InformationTooltip:AddLine(bookPosition, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())

              if hasZoneTag then
                InformationTooltip:AddLine(GetString(LBOOKS_PIN_UPDATE), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
              end

            end

          end -- end not isFakePin
        end -- end for do on bookData.e

      end -- end else

    end -- end hasEideticData

  end -- categoryIndex = Eidetic

  self.owner:EnterRow(self)

end

local function OnMouseExit(self)
  ClearTooltip(InformationTooltip)
  self.owner:ExitRow(self)
end

function BuildBookListPostHook()
  local orgCallback = LORE_LIBRARY.list.list.dataTypes[1].setupCallback
  LORE_LIBRARY.list.list.dataTypes[1].setupCallback = function(control, data)
    orgCallback(control, data)
    if not control.lbhooked then
      control.lbhooked = true
      control:SetHandler("OnMouseUp", OnRowMouseUp)
      control:SetHandler("OnMouseEnter", function(control) OnMouseEnter(control, control.categoryIndex, control.collectionIndex, control.bookIndex) end)
      control:SetHandler("OnMouseExit", function(control) OnMouseExit(control) end)
      control:GetNamedChild("Text"):SetMouseEnabled(false)
    end
  end
end

function LoreBooks:IsMotifButtonChecked(control)
  return ZO_CheckButton_IsChecked(control)
end

local function RebuildLoreLibrary()
  loreLibraryReportKeybind = {
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_RPRT),
      keybind = "UI_SHORTCUT_QUINARY",
      callback = ShowLoreLibraryReport,
    },
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_SWITCH),
      keybind = "UI_SHORTCUT_QUATERNARY",
      callback = SwitchLoreLibraryReportMode,
      visible = IsReportShown,
    },
    {
      alignment = KEYBIND_STRIP_ALIGN_LEFT,
      name = GetString(LBOOKS_REPORT_KEYBIND_COPY),
      keybind = "UI_SHORTCUT_TERTIARY",
      callback = ShowLoreLibraryCopyReport,
      visible = IsReportShown,
    },
  }

  local function OnStateChanged(oldState, newState)
    if newState == SCENE_SHOWING then
      KEYBIND_STRIP:AddKeybindButtonGroup(loreLibraryReportKeybind)
    elseif newState == SCENE_HIDDEN then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(loreLibraryReportKeybind)
      ShowLoreLibraryReport(true)
    end
  end

  LORE_LIBRARY_SCENE:RegisterCallback("StateChange", OnStateChanged)

  LORE_LIBRARY.search = LORE_LIBRARY.search or ""

  local lorebookResearch = WINDOW_MANAGER:CreateControlFromVirtual("Lorebook_Research", ZO_LoreLibrary, "Lorebook_Research_Template")
  lorebookResearch.searchBox = GetControl(lorebookResearch, "Box")
  lorebookResearch.searchBox:SetHandler("OnTextChanged", OnSearchTextChanged)

  ZO_PreHook(LORE_LIBRARY, "BuildCategoryList", BuildCategoryList)
  ZO_PreHook(LORE_LIBRARY.list, "FilterScrollList", FilterScrollList)

  local origLoreLibraryBuildBookList = LORE_LIBRARY.BuildBookList
  LORE_LIBRARY.BuildBookList = function(self, ...)
    origLoreLibraryBuildBookList(self, ...)
    BuildBookListPostHook()
  end

  local includeMotifsCheckbox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)IncludeMotifs", LORE_LIBRARY.totalCollectedLabel, "ZO_CheckButton")

  includeMotifsCheckbox:SetAnchor(LEFT, LORE_LIBRARY.totalCollectedLabel, RIGHT, 85, 0)

  ZO_CheckButton_SetLabelText(includeMotifsCheckbox, GetString(LBOOKS_INCLUDE_MOTIFS_CHECKBOX))
  ZO_CheckButton_SetToggleFunction(includeMotifsCheckbox, function()
    LORE_LIBRARY:RefreshCollectedInfo()
    LoreBooks.callbackObject:FireCallbacks(LoreBooks.callbackType.MOTIF_CHECKBOX_CHANGED)
  end)

  LORE_LIBRARY.RefreshCollectedInfo = function(library)
    local currentlyCollected = library.totalCurrentlyCollected
    local possibleCollected = library.totalPossibleCollected

    if not LoreBooks:IsMotifButtonChecked(includeMotifsCheckbox) then
      currentlyCollected = currentlyCollected - library.motifsCurrentlyCollected
      possibleCollected = possibleCollected - library.motifsPossibleCollected
    end
    library.totalCollectedLabel:SetText(zo_strformat(SI_LORE_LIBRARY_TOTAL_COLLECTED, currentlyCollected, possibleCollected))
  end
end

local lastReadBook
local shownBookId
local currentOpenBook
local function OnShowBook(eventCode, bookTitle, body, medium, showTitle, bookId)
  lastReadBook = bookTitle
  currentOpenBook = bookTitle
  shownBookId = bookId
end

local function OnHideBook(eventCode)
  currentOpenBook = nil
  shownBookId = nil
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

-- slash commands -------------------------------------------------------------

--/script SetCVar("Language.2", "fr")
local bookShelfLocalization = {
  ["en"] = "Bookshelf",
  ["de"] = "Bücherregal",
  ["fr"] = "Étagère de livres",
  ["ru"] = "Книжная полка",
}
local bookStackLocalization = {
  ["en"] = "Book Stack",
  ["de"] = "Bücherstapel",
  ["fr"] = "Pile de livres",
  ["ru"] = "Стопка книг",
}
local bookLocalization = {
  ["en"] = "Book",
  ["de"] = "Buch",
  ["fr"] = "Livre",
  ["ru"] = "Книга",
}

local function CreateEideticLorebookLocation()
  SetMapToPlayerLocation()
  CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
  LMDI:UpdateMapInfo()
  local zone = LMP:GetZoneAndSubzone(true, false, true)
  local outText = GetString(LBOOKS_LBPOS_ERROR)
  local zoneId = LMD.zoneId
  local worldX, worldY, worldZ = LMD.worldX, LMD.worldY, LMD.worldZ
  local x, y = LMD.normalizedX, LMD.normalizedY
  local xpos, ypos = LMD.libGPSX, LMD.libGPSY
  local mapIndex = LMD.mapIndex
  local mapId = LMD.mapId
  local parentZoneMapId = LMD.parentZoneMapId
  local isMainZone = LMD.isMainZone
  local isDungeon = LMD.isDungeon
  local bookName = ""
  local categoryIndex = 0
  local collectionIndex = ""
  local bookIndex = ""
  local bookId
  local isBookshelf
  if LMD.reticleInteractionName and not isBookshelf then
    isBookshelf = LMD.reticleInteractionName == bookShelfLocalization[internal.current_bookshelf_locale]
  end
  if LMD.reticleInteractionName and not isBookshelf then
    isBookshelf = LMD.reticleInteractionName == bookStackLocalization[internal.current_bookshelf_locale]
  end
  if LMD.reticleInteractionName and not isBookshelf then
    isBookshelf = LMD.reticleInteractionName == bookLocalization[internal.current_bookshelf_locale]
  end
  --d(isBookshelf)
  if currentOpenBook then
    bookName = currentOpenBook
  end
  --d(currentOpenBook)
  --d(shownBookId)
  if not shownBookId then
    d(GetString(LBOOKS_LBPOS_OPEN_BOOK))
    return
  end
  if shownBookId then
    categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(shownBookId)
  end
  if collectionIndex and bookIndex then
    _, _, _, bookId = LoreBooks_GetNewLoreBookInfo(internal.LORE_LIBRARY_EIDETIC, collectionIndex, bookIndex)
  end
  local collectionName = LoreBooks_GetNewLoreCollectionInfo(categoryIndex, collectionIndex)
  -- /script d({GetLoreBookIndicesFromBookId(151)})
  -- /script d({LoreBooks_GetNewLoreBookInfo(3, 21, 1)})
  if categoryIndex and categoryIndex == internal.LORE_LIBRARY_SHALIDOR then
    outText = string.format("[%d] = { %ds, %ds, %d, %s, %s, moreInfo }, -- %s, %s", mapId, worldX, worldY, worldZ, collectionIndex, bookIndex, bookName, zone)
  elseif categoryIndex and categoryIndex == internal.LORE_LIBRARY_EIDETIC then
    local cnf = '"cn"' -- used for Collection Name
    local nf = '"n"' -- used for Book Name
    local ef = '"e"'
    local df = '"d"' -- inDungeon
    local mdf = '"pm"' -- mapId
    local smf = '"sm"' -- mapId of the map the measurement was taken from
    local pxf = '"px"' -- LibGPS x
    local pyf = '"py"' -- LibGPS y
    local xf = '"x"' -- used for zone bookshelf
    local yf = '"y"' -- used for zone bookshelf
    local pnxf = '"pnx"' -- normal x cord
    local pnyf = '"pny"' -- normal y cord
    local mf = '"m"' -- used for zone booklist
    local zf = '"z"' -- used for zone bookshelf
    if isDungeon then
      outText = string.format("[%d] = { [%s] = %s, [%s] = %s, [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, [%s] = %s, }, }, }, { [%s] = %d, [%s] = %.10f, [%s] = %.10f }, -- %s",
        shownBookId, cnf, '"' .. collectionName .. '"', nf, '"' .. bookName .. '"', ef, pxf, xpos, pyf, ypos, mdf, mapId, df, tostring(isDungeon), smf, mapId, pnxf, x, pnyf, y, zone)
    else
      outText = string.format("[%d] = { [%s] = %s, [%s] = %s, [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, }, }, }, { [%s] = %d, [%s] = %.10f, [%s] = %.10f }, -- %s",
        shownBookId, cnf, '"' .. collectionName .. '"', nf, '"' .. bookName .. '"', ef, pxf, xpos, pyf, ypos, mdf, mapId, smf, mapId, pnxf, x, pnyf, y, zone)
    end
    -- the bookshelf data uses the zoneId to determine the icon
    if isBookshelf then
      outText = string.format("[%d] = { [%s] = { [%d] = 1, }, }, [%d] = { { [%s] = %.10f, [%s] = %.10f, [%s] = %d, }, },  -- Bookshelf: %s, %s",
        shownBookId, mf, parentZoneMapId, mapId, xf, x, yf, y, zf, zoneId, bookName, zone)
    end
  end
  MyPrint(outText)
end

local function CreateFakeEideticLorebookLocation()
  LMDI:UpdateMapInfo()
  local zone = LMP:GetZoneAndSubzone(true, false, true)
  local x, y = LMD.normalizedX, LMD.normalizedY
  local xpos, ypos = LMD.libGPSX, LMD.libGPSY
  local mapId = LMD.mapId

  local ef = '"e"'
  local mdf = '"pm"' -- mapId
  local smf = '"sm"' -- mapId of the map the measurement was taken from
  local pxf = '"px"' -- LibGPS x
  local pyf = '"py"' -- LibGPS y
  local fpf = '"fp"' -- used for zone booklist
  local pnxf = '"pnx"' -- normal x cord
  local pnyf = '"pny"' -- normal y cord
  local shownBookId = "fake"
  local bookName = "fake Eidetic Memory location"
  local outText = string.format("[%s] = { [%s] = { [1] = { [%s] = %.10f, [%s] = %.10f, [%s] = %d, [%s] = true, }, }, }, { [%s] = %d, [%s] = %.10f, [%s] = %.10f }, -- %s, %s",
    shownBookId, ef, pxf, xpos, pyf, ypos, mdf, mapId, fpf, smf, mapId, pnxf, x, pnyf, y, bookName, zone)
  MyPrint(outText)
end

local function CreateFakeLorebookPin()
  LMDI:UpdateMapInfo()
  local zone = LMP:GetZoneAndSubzone(true, false, true)
  local x, y = LMD.normalizedX, LMD.normalizedY
  local xpos, ypos = LMD.libGPSX, LMD.libGPSY
  local mapId = LMD.mapId

  local shownBookId = "fake"
  local bookName = "fake Shalidor's Library location"
  local outText = string.format("[%s] = { %.10f, %.10f, 0, 0, moreinfo }, -- %s, %s",
    mapId, x, y, bookName, zone)
  MyPrint(outText)
end

local function is_empty_or_nil(t)
  if t == nil or t == "" then return true end
  return type(t) == "table" and ZO_IsTableEmpty(t) or false
end

local function is_in(search_value, search_table)
  if is_empty_or_nil(search_value) then return false end
  for k, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if string.find(string.lower(v), string.lower(search_value)) then return true end
    end
  end
  return false
end

function InitializeLocales()
  internal.supported_locales = { "en", "es", "de", "fr", "ru", "zh", "br", "it", "pl" }
  internal.supported_bookshelf_locales = { "en", "de", "fr", "ru" }

  internal.current_locale = GetCVar("Language.2")
  internal.current_bookshelf_locale = GetCVar("Language.2")

  if not is_in(internal.current_locale, internal.supported_locales) then
    internal.current_locale = "en"
  end

  if not is_in(internal.current_bookshelf_locale, internal.supported_bookshelf_locales) then
    internal.current_bookshelf_locale = "en"
  end
end

local function OnLoad(eventCode, name)

  if name == internal.ADDON_NAME then

    EVENT_MANAGER:UnregisterForEvent(internal.ADDON_NAME, EVENT_ADD_ON_LOADED)

    LoreBooks.db = ZO_SavedVars:NewAccountWide("LBooks_SavedVariables", internal.SAVEDVARIABLES_VERSION, nil, LoreBooks.defaults)

    InitializeLocales()

    LoreBooks:CreateLamPanel()

    -- Lorelibrary
    RebuildLoreLibrary()

    -- Tooltip Mode
    OnGamepadPreferredModeChanged()

    -- LibMapPins
    InitializePins()

    -- slash commands
    SLASH_COMMANDS["/lbpos"] = function() CreateEideticLorebookLocation() end

    SLASH_COMMANDS["/lbfake"] = function() CreateFakeEideticLorebookLocation() end

    SLASH_COMMANDS["/lbfakebook"] = function() CreateFakeLorebookPin() end

    --events
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_SHOW_BOOK, OnShowBook)
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_HIDE_BOOK, OnHideBook)
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_LORE_BOOK_LEARNED, OnBookLearned)
    EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)

  end

end
EVENT_MANAGER:RegisterForEvent(internal.ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)
