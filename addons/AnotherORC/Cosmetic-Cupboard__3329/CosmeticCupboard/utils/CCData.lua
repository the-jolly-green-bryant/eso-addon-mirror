CC_Data = {}

CC_DATA_TYPE = {
  GLOBAL = 1,
  CHARACTER = 2
}

-- Create a new data handling object
function CC_Data:New(template)
  local class = template or {}
  setmetatable(class, self)
  self.__index = self

  self.profiles = {}

  return class
end

--- Loads saved data.
-- Stores all outfit information so it can be accessed later
-- @param variableVersion Version of data.
function CC_Data:LoadData(variableVersion)
  self.characterData = ZO_SavedVars:NewCharacterIdSettings("CosmeticCupboardVars", variableVersion, nil, CC.Default)
  self.globalData    = ZO_SavedVars:NewAccountWide("CosmeticCupboardVars", variableVersion, nil, CC.Default)

  for name, value in pairs(self.characterData.profiles) do
    self.profiles[name] = value
    self.profiles[name].isGlobal = false
  end

  for name, value in pairs(self.globalData.profiles) do
    self.profiles[name] = value
    self.profiles[name].isGlobal = true
  end
end

--- Store an outfit.
-- Stores an outfit so it can be retrieved later
-- @param name The outfits name.
-- @param quickSlotData The quickslot data.
-- @param collectibleData The collectible data.
-- @param costumeData The costume data.
function CC_Data:SaveProfile(name, collectibleData, quickSlotData, titleData, costumeData, isGlobal)

  -- Check to see if this profile is to be global
  local currentProfile = self:GetProfile(name)

  if currentProfile and not (currentProfile.isGlobal == isGlobal) then

    -- Was it previously global?
    -- Remove the old one.  A new save is being made!
    if currentProfile.isGlobal then
      self.globalData.profiles[name] = nil
    else
      self.characterData.profiles[name] = nil
    end

  end

  -- Data profile object
  local data = {
    collectibles = collectibleData,
    quickSlots   = quickSlotData,
    titleData    = titleData,
    outfitIndex  = costumeData
  }

  -- Store localy
  self.profiles[name] = data
  self.profiles[name].isGlobal = isGlobal

  -- Store the profile data
  if isGlobal then
    self.globalData.profiles[name] = data
  else
    self.characterData.profiles[name] = data
  end
end

--- Delete an outfit.
-- Removes an outfit from storage.  This action is not reversable.
-- @param name The outfits name.
function CC_Data:DeleteProfile(name)
  if not self:DoesOutfitExist(name) then return end

  -- Remove remote copy
  if self.profiles[name].isGlobal then
    self.globalData.profiles[name] = nil
  else
    self.characterData.profiles[name] = nil
  end

  -- Also remove the local copy of this
  self.profiles[name] = nil
end

--- Loads an outfit.
-- Retrieves an outfit from storage.
-- @param name The outfits name.
-- @return nil or profile.
function CC_Data:GetProfile(name)

  if not self:DoesOutfitExist(name) then return nil end

  local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
  end

  local profile = self.profiles[name]
  local newProfile = copy(profile)

  return newProfile
end

function CC_Data:GetProfiles()
  return self.profiles
end

--- Renames an outfit.
-- Rename an outfit.  Used to update outfit names.
-- Does nothing if no outfit was found.
-- @param oldName The old outfits name.
-- @param newName The new outfits name.
function CC_Data:RenameOutfit(oldName, newName)
  if not self:DoesOutfitExist(oldName) then return end
  local profile = self.profiles[oldName]

  if profile.isGlobal then
    self.globalData.profiles[newName] = self.globalData.profiles[oldName]
    self.globalData.profiles[oldName] = nil
  else
    self.characterData.profiles[newName] = self.characterData.profiles[oldName]
    self.characterData.profiles[oldName] = nil
  end

  self.profiles[newName] = self.profiles[oldName]
  self.profiles[oldName] = nil
end

--- Get a lit of outfits.
-- Returns a list of outfit names.
-- @return List of names.
function CC_Data:GetOutfitNameList()
  local data = {}
  local index = 0
  for i in pairs(self.globalData.profiles) do
    data[index] = i
    index = index  + 1
  end
  return data
end

--- Checks if an outfit exists.
-- Returns true or false deppending on if an outfit with the given name exists.
-- @param name The outfits name.
-- @return true or false.
function CC_Data:DoesOutfitExist(name)
  return self.profiles[name] ~= nil
end

function CC_Data:SetIconEnabled(value)
  self.globalData['iconEnabled'] = value
end

function CC_Data:GetIconEnabled()
  if self.globalData['iconEnabled'] == nil then return true end
  return self.globalData['iconEnabled']
end

function CC_Data:StorePosition(name, position)
  if not name or not position then return end
  if self.characterData.position == nil then self.characterData.position = {} end
  self.characterData.position[name] = position
end

function CC_Data:GetPanelPositions()
  if self.characterData.position == nil then return {} end
  return self.characterData.position
end
