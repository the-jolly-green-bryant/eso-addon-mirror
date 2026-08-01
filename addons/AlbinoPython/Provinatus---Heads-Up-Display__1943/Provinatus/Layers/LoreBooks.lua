--[[
  Some of the code below is adapted from:
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
ProvinatusLoreBooks = ZO_Object:Subclass()
local LOREBOOKS_ADDON_LOADED = LoreBooks_GetLocalData ~= nil
local X_INDEX = 1
local Y_INDEX = 2
local COLLECTION_INDEX = 3
local BOOK_INDEX = 4
local CATEGORY_INDEX = 5
local EIDETIC_CATEGORY = 3
local LORE_CATEGORY = 1

local CurrentMap, CurrentZone, CurrentEideticPins

local function InsertLoreBooks(Books)
  local LoreBooks = {}
  Books[LORE_CATEGORY] = {}
  if LOREBOOKS_ADDON_LOADED then
    LoreBooks = LoreBooks_GetLocalData(GetCurrentMapId())
  else
    LoreBooks = ProvinatusLoreBooksData[Provinatus.Subzone]
  end

  if LoreBooks then
    for _, Data in pairs(LoreBooks) do
      table.insert(Books[LORE_CATEGORY], Data)
    end
  end
end

-- Adapted from LoreBooks
local function GetMapInfo()
  local MapIndex = GetCurrentMapIndex()
  local MapContentType = GetMapContentType()
  local ZoneId = GetZoneId(GetUnitZoneIndex("player"))
  local UsePrecalculatedCoords = true
  local EideticBooks

  if not MapIndex then
    UsePrecalculatedCoords = false
    if ZoneId == 643 then --IC Sewers
      MapIndex = GetImperialCityMapIndex()
    elseif MapContentType ~= MAP_CONTENT_DUNGEON then
      MapIndex = LibGPS3:GetCurrentMapMeasurement().MapIndex
    end
  end

  return MapIndex, ZoneId, UsePrecalculatedCoords
end

local function InsertEideticBooks(Books)
  local MapId = LibMapData.mapId
  local ZoneId = LibMapData.zoneId

  if MapId ~= CurrentMap or ZoneId ~= CurrentZone or not CurrentEideticPins then
    CurrentEideticPins = {}
    CurrentMap = MapId
    CurrentZone = ZoneId
    local EideticBooks = LoreBooks_GetEideticData(MapId, MapId)
    if EideticBooks then
      for _, pinData in ipairs(EideticBooks) do
        local _, _, known = GetLoreBookInfo(3, pinData.c, pinData.b)
        if MapId == pinData.pm and (not known or Provinatus.SavedVars.LoreBooks.ShowCollected) then
          local xLoc, yLoc
          if pinData.px and pinData.py then
            xLoc, yLoc = LibGPS3:GlobalToLocal(pinData.px, pinData.py)
          elseif pinData.pnx and pinData.pny then
            xLoc = pinData.pnx
            yLoc = pinData.pny
          end
          table.insert(
            CurrentEideticPins,
            {
              [X_INDEX] = xLoc,
              [Y_INDEX] = yLoc,
              [COLLECTION_INDEX] = pinData.c,
              [BOOK_INDEX] = pinData.b,
              [CATEGORY_INDEX] = 3
            }
          )
        end
      end
    end
  end

  Books[EIDETIC_CATEGORY] = {}
  for _, Pin in pairs(CurrentEideticPins) do
    table.insert(Books[EIDETIC_CATEGORY], Pin)
  end
end

local function GetBooks()
  local Books = {}
  if LOREBOOKS_ADDON_LOADED then
    if Provinatus.SavedVars.LoreBooks.Enabled then
      InsertLoreBooks(Books)
    end

    if Provinatus.SavedVars.LoreBooks.EideticMemory then
      InsertEideticBooks(Books)
    end
  end

  return Books
end

function ProvinatusLoreBooks:Update()
  local Elements = {}
  if Provinatus.SavedVars.LoreBooks.EideticMemory or Provinatus.SavedVars.LoreBooks.Enabled then
    for Category, Books in pairs(GetBooks()) do
      for _, Book in pairs(Books) do
        local _, Texture, Known = GetLoreBookInfo(Category, Book[COLLECTION_INDEX], Book[BOOK_INDEX])
        if not Known or Provinatus.SavedVars.LoreBooks.ShowCollected then
          local Element = {
            X = Book[X_INDEX],
            Y = Book[Y_INDEX],
            Texture = Texture,
            Alpha = Provinatus.SavedVars.LoreBooks.Alpha,
            Height = Provinatus.SavedVars.LoreBooks.Size,
            Width = Provinatus.SavedVars.LoreBooks.Size
          }

          table.insert(Elements, Element)
        end
      end
    end
  end

  Provinatus:DrawElements(self, Elements)
end

function ProvinatusLoreBooks:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_LORE_BOOKS,
    reference = "ProvinatusLoreBooksMenu",
    icon = "/esoui/art/icons/magickalore_book1.dds",
    controls = {
      {
        type = "checkbox",
        name = PROVINATUS_LORE_BOOKS_ENABLED,
        getFunc = function()
          return Provinatus.SavedVars.LoreBooks.Enabled
        end,
        setFunc = function(value)
          Provinatus.SavedVars.LoreBooks.Enabled = value
        end,
        width = "full",
        default = ProvinatusConfig.LoreBooks.Enabled
      },
      {
        type = "checkbox",
        name = PROVINATUS_LORE_BOOKS_SHOW_KNOWN,
        getFunc = function()
          return Provinatus.SavedVars.LoreBooks.ShowCollected
        end,
        setFunc = function(value)
          Provinatus.SavedVars.LoreBooks.ShowCollected = value
        end,
        tooltip = "",
        width = "full",
        default = ProvinatusConfig.LoreBooks.ShowCollected
      },
      {
        type = "checkbox",
        name = PROVINATUS_LORE_BOOKS_EIDETIC,
        getFunc = function()
          return Provinatus.SavedVars.LoreBooks.EideticMemory
        end,
        setFunc = function(value)
          Provinatus.SavedVars.LoreBooks.EideticMemory = value
        end,
        width = "full",
        default = ProvinatusConfig.LoreBooks.EideticMemory
      },
      {
        type = "submenu",
        name = PROVINATUS_ICON_SETTINGS,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          "",
          function()
            return Provinatus.SavedVars.LoreBooks.Size
          end,
          function(value)
            Provinatus.SavedVars.LoreBooks.Size = value
          end,
          function()
            return Provinatus.SavedVars.LoreBooks.Alpha * 100
          end,
          function(value)
            Provinatus.SavedVars.LoreBooks.Alpha = value / 100
          end,
          ProvinatusConfig.LoreBooks.Size,
          ProvinatusConfig.LoreBooks.Alpha * 100,
          function()
            return not Provinatus.SavedVars.LoreBooks.Enabled
          end
        )
      }
    },
    disabled = not LOREBOOKS_ADDON_LOADED
  }
end
