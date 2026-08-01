local Addon = LarvalTearMod
local QuickslotProfiles = Addon.Modules.QuickslotProfiles
local QuickslotSnapshot = Addon.Modules.QuickslotSnapshot
local Util = Addon.Common.Util

local DEFAULT_PROFILE_NAME = "QuickSlot Profile"

local function NormalizeCharacterKey(characterKey)
    if characterKey ~= nil then
        return tostring(characterKey)
    end

    if type(GetCurrentCharacterId) ~= "function" then
        return nil
    end

    local ok, characterId = pcall(GetCurrentCharacterId)
    if ok and characterId ~= nil then
        return tostring(characterId)
    end

    return nil
end

local function GetProfileDisplayName(profile)
    if type(profile) ~= "table" then
        return nil
    end

    return Util:NormalizeDisplayName(profile.displayName) or Util:NormalizeDisplayName(profile.name)
end

local function NormalizeOptionalProfileId(profileId)
    if type(profileId) ~= "string" or profileId == "" or profileId == "none" then
        return nil
    end

    return profileId
end

local function BuildProfileFallbackName(profile, profileId)
    return GetProfileDisplayName(profile) or NormalizeOptionalProfileId(profileId) or DEFAULT_PROFILE_NAME
end

local function NormalizeProfileShape(profile)
    if type(profile) ~= "table" then
        return nil
    end

    local displayName = GetProfileDisplayName(profile)
    if displayName ~= nil then
        profile.displayName = displayName
    end
    profile.name = nil
    profile.ownerCharacterName = nil
    local normalizedSlots = {}
    if type(profile.slots) == "table" then
        for slotIndex, entry in pairs(profile.slots) do
            if type(entry) == "table"
                and (type(QuickslotSnapshot) ~= "table"
                    or type(QuickslotSnapshot.IsEmptyEntry) ~= "function"
                    or QuickslotSnapshot:IsEmptyEntry(entry) ~= true) then
                local normalizedEntry = Util:DeepCopy(entry)
                normalizedEntry.slotIndex = tonumber(normalizedEntry.slotIndex) or tonumber(slotIndex)
                normalizedEntry.actionTypeName = nil
                if type(normalizedEntry.slotIndex) == "number" then
                    normalizedSlots[normalizedEntry.slotIndex] = normalizedEntry
                end
            end
        end
    end
    profile.slots = normalizedSlots
    return profile
end

local function CollectSortedStringKeys(entries)
    local keys = {}

    for key, value in pairs(entries or {}) do
        if type(key) == "string" and key ~= "" and type(value) == "table" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys)
    return keys
end

local function NormalizeOrder(orderList, actualEntries)
    actualEntries = type(actualEntries) == "table" and actualEntries or {}

    local normalizedOrder = {}
    local seenIds = {}

    for _, id in ipairs(orderList or {}) do
        if type(actualEntries[id]) == "table" and not seenIds[id] then
            seenIds[id] = true
            normalizedOrder[#normalizedOrder + 1] = id
        end
    end

    for _, id in ipairs(CollectSortedStringKeys(actualEntries)) do
        if not seenIds[id] then
            seenIds[id] = true
            normalizedOrder[#normalizedOrder + 1] = id
        end
    end

    return normalizedOrder
end

local function NormalizeProfileOrder(bucket)
    bucket.profileOrder = NormalizeOrder(bucket.profileOrder, bucket.profiles or {})
end

local function NormalizeActiveProfileId(bucket)
    if type(bucket) ~= "table" then
        return
    end

    if type(bucket.activeProfileId) ~= "string"
        or type(bucket.profiles) ~= "table"
        or type(bucket.profiles[bucket.activeProfileId]) ~= "table" then
        bucket.activeProfileId = nil
    end
end

function QuickslotProfiles:Initialize(savedVars)
    self.savedVars = savedVars
end

function QuickslotProfiles:EnsureSavedVarsShape(readOnly)
    if type(self.savedVars) ~= "table" then
        return nil
    end

    if type(self.savedVars.quickslotProfilesByCharacter) ~= "table" then
        if readOnly then
            return nil
        end
        self.savedVars.quickslotProfilesByCharacter = {}
    end

    return self.savedVars
end

function QuickslotProfiles:GetCurrentCharacterKey()
    return NormalizeCharacterKey()
end

function QuickslotProfiles:GetCharacterBucket(characterKey, readOnly)
    if readOnly then
        return self:GetCharacterBucketReadonly(characterKey)
    end

    return self:EnsureCharacterBucketForWrite(characterKey)
end

function QuickslotProfiles:GetCharacterBucketReadonly(characterKey)
    local savedVars = self:EnsureSavedVarsShape(true)
    if type(savedVars) ~= "table" or type(savedVars.quickslotProfilesByCharacter) ~= "table" then
        return nil
    end

    characterKey = NormalizeCharacterKey(characterKey)
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.quickslotProfilesByCharacter[characterKey]
    if type(bucket) ~= "table" then
        return nil
    end

    bucket = Util:DeepCopy(bucket)
    if type(bucket.profiles) ~= "table" then
        bucket.profiles = {}
    end
    for profileId, profile in pairs(bucket.profiles) do
        if type(profileId) == "string" and type(profile) == "table" then
            bucket.profiles[profileId] = NormalizeProfileShape(profile)
        end
    end
    NormalizeProfileOrder(bucket)
    NormalizeActiveProfileId(bucket)

    return bucket
end

function QuickslotProfiles:EnsureCharacterBucketForWrite(characterKey)
    local savedVars = self:EnsureSavedVarsShape(false)
    if type(savedVars) ~= "table" then
        return nil
    end

    characterKey = NormalizeCharacterKey(characterKey)
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.quickslotProfilesByCharacter[characterKey]
    if type(bucket) ~= "table" then
        bucket = {
            profileOrder = {},
            profiles = {},
            ownerCharacterId = characterKey,
        }
        savedVars.quickslotProfilesByCharacter[characterKey] = bucket
    end

    if type(bucket.profiles) ~= "table" then
        bucket.profiles = {}
    end
    for profileId, profile in pairs(bucket.profiles) do
        if type(profileId) == "string" and type(profile) == "table" then
            bucket.profiles[profileId] = NormalizeProfileShape(profile)
        end
    end
    NormalizeProfileOrder(bucket)
    NormalizeActiveProfileId(bucket)

    bucket.ownerCharacterId = bucket.ownerCharacterId or characterKey
    bucket.ownerCharacterName = nil

    return bucket
end

function QuickslotProfiles:GenerateProfileId(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, false)
    local nextIndex = 1
    while type(bucket) == "table" do
        local profileId = string.format("quickslot_%04d", nextIndex)
        if type(bucket.profiles) ~= "table" or bucket.profiles[profileId] == nil then
            return profileId
        end
        nextIndex = nextIndex + 1
    end
    return nil
end

function QuickslotProfiles:GenerateProfileName(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, true)
    local nextIndex = 1
    local used = {}
    if type(bucket) == "table" and type(bucket.profiles) == "table" then
        for _, profile in pairs(bucket.profiles) do
            local displayName = GetProfileDisplayName(profile)
            if displayName ~= nil then
                used[displayName] = true
            end
        end
    end

    while true do
        local name = string.format("%s %d", DEFAULT_PROFILE_NAME, nextIndex)
        if not used[name] then
            return name
        end
        nextIndex = nextIndex + 1
    end
end

function QuickslotProfiles:CreateFromCurrent(name, characterKey)
    if type(QuickslotSnapshot) ~= "table" or type(QuickslotSnapshot.CaptureCurrent) ~= "function" then
        return nil, "quickslot_snapshot_unavailable"
    end

    characterKey = NormalizeCharacterKey(characterKey)
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil, "character_id_unavailable"
    end

    local snapshot, snapshotErr = QuickslotSnapshot:CaptureCurrent()
    if type(snapshot) ~= "table" then
        return nil, snapshotErr or "quickslot_snapshot_failed"
    end

    local bucket = self:GetCharacterBucket(characterKey, false)
    if type(bucket) ~= "table" then
        return nil, "quickslot_bucket_unavailable"
    end

    local profileId = self:GenerateProfileId(characterKey)
    local now = type(GetTimeStamp) == "function" and GetTimeStamp() or 0
    local profile = {
        id = profileId,
        displayName = Util:NormalizeDisplayName(name) or self:GenerateProfileName(characterKey),
        ownerCharacterId = characterKey,
        createdAt = now,
        updatedAt = now,
        slotCount = snapshot.slotCount,
        slots = QuickslotSnapshot:BuildProfileSlotsFromSnapshot(snapshot),
    }

    bucket.profiles[profileId] = NormalizeProfileShape(profile)
    bucket.profileOrder[#bucket.profileOrder + 1] = profileId
    return Util:DeepCopy(bucket.profiles[profileId])
end

function QuickslotProfiles:GetProfileList(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, true)
    local profiles = {}
    if type(bucket) ~= "table" or type(bucket.profiles) ~= "table" then
        return profiles
    end

    for _, profileId in ipairs(bucket.profileOrder or {}) do
        if type(bucket.profiles[profileId]) == "table" then
            local profile = Util:DeepCopy(bucket.profiles[profileId])
            profile.isActive = bucket.activeProfileId == profileId
            profiles[#profiles + 1] = profile
        end
    end

    return profiles
end

function QuickslotProfiles:GetProfileLinkOptions(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, true)
    local options = {}
    if type(bucket) ~= "table" or type(bucket.profiles) ~= "table" then
        return options
    end

    for _, profileId in ipairs(bucket.profileOrder or {}) do
        local profile = bucket.profiles[profileId]
        if type(profileId) == "string" and profileId ~= "" and type(profile) == "table" then
            options[#options + 1] = {
                id = profileId,
                displayName = BuildProfileFallbackName(profile, profileId),
            }
        end
    end

    return options
end

function QuickslotProfiles:GetProfileDisplayNameById(profileId, characterKey)
    profileId = NormalizeOptionalProfileId(profileId)
    if profileId == nil then
        return nil
    end

    local bucket = self:GetCharacterBucket(characterKey, true)
    local profile = type(bucket) == "table" and type(bucket.profiles) == "table" and bucket.profiles[profileId] or nil
    if type(profile) ~= "table" then
        return nil
    end

    return BuildProfileFallbackName(profile, profileId)
end

function QuickslotProfiles:HasProfile(profileId, characterKey)
    profileId = NormalizeOptionalProfileId(profileId)
    if profileId == nil then
        return false
    end

    local bucket = self:GetCharacterBucket(characterKey, true)
    return type(bucket) == "table"
        and type(bucket.profiles) == "table"
        and type(bucket.profiles[profileId]) == "table"
end

function QuickslotProfiles:GetActiveProfileId(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, true)
    return type(bucket) == "table" and bucket.activeProfileId or nil
end

function QuickslotProfiles:GetActiveProfile(characterKey)
    local bucket = self:GetCharacterBucket(characterKey, true)
    local profileId = type(bucket) == "table" and bucket.activeProfileId or nil
    local profile = type(bucket) == "table" and type(bucket.profiles) == "table" and bucket.profiles[profileId] or nil
    return type(profile) == "table" and Util:DeepCopy(profile) or nil
end

function QuickslotProfiles:SetActiveProfile(profileId, characterKey)
    if type(profileId) ~= "string" or profileId == "" then
        return nil, "quickslot_profile_not_found"
    end

    -- Check readonly first so missing profiles do not create empty write buckets.
    local existingBucket = self:GetCharacterBucket(characterKey, true)
    if type(existingBucket) ~= "table"
        or type(existingBucket.profiles) ~= "table"
        or type(existingBucket.profiles[profileId]) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    -- Re-check after opening the write bucket; the duplicate guard is intentional
    -- and prevents SavedVariables growth for missing character/profile paths.
    local bucket = self:GetCharacterBucket(characterKey, false)
    if type(bucket) ~= "table"
        or type(bucket.profiles) ~= "table"
        or type(bucket.profiles[profileId]) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    bucket.activeProfileId = profileId
    local profile = Util:DeepCopy(bucket.profiles[profileId])
    profile.isActive = true
    return profile
end

function QuickslotProfiles:ClearActiveProfile(profileId, characterKey)
    local existingBucket = self:GetCharacterBucket(characterKey, true)
    if type(existingBucket) ~= "table" then
        return false, "quickslot_bucket_unavailable"
    end

    local bucket = self:GetCharacterBucket(characterKey, false)
    if type(bucket) ~= "table" then
        return false, "quickslot_bucket_unavailable"
    end

    if profileId == nil or bucket.activeProfileId == profileId then
        bucket.activeProfileId = nil
        return true
    end

    return false, "quickslot_profile_not_active"
end

function QuickslotProfiles:DeleteProfile(profileId, characterKey)
    -- Check readonly first so deleting a missing profile does not create a bucket.
    local existingBucket = self:GetCharacterBucket(characterKey, true)
    if type(existingBucket) ~= "table"
        or type(existingBucket.profiles) ~= "table"
        or type(existingBucket.profiles[profileId]) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    -- Re-check after opening the write bucket; the duplicate guard is intentional
    -- and prevents SavedVariables growth for missing character/profile paths.
    local bucket = self:GetCharacterBucket(characterKey, false)
    if type(bucket) ~= "table" or type(bucket.profiles) ~= "table" or type(bucket.profiles[profileId]) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    local deleted = bucket.profiles[profileId]
    bucket.profiles[profileId] = nil
    local newOrder = {}
    for _, orderedId in ipairs(bucket.profileOrder or {}) do
        if orderedId ~= profileId then
            newOrder[#newOrder + 1] = orderedId
        end
    end
    bucket.profileOrder = newOrder
    if bucket.activeProfileId == profileId then
        bucket.activeProfileId = nil
    end

    return {
        deletedProfileId = profileId,
        deletedProfileName = GetProfileDisplayName(deleted) or profileId,
    }
end

function QuickslotProfiles:RenameProfile(profileId, newName, characterKey)
    local normalizedName = Util:NormalizeDisplayName(newName)
    if normalizedName == nil then
        return nil, "name_empty"
    end

    -- Check readonly first so renaming a missing profile does not create a bucket.
    local existingBucket = self:GetCharacterBucket(characterKey, true)
    if type(existingBucket) ~= "table"
        or type(existingBucket.profiles) ~= "table"
        or type(existingBucket.profiles[profileId]) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    -- Re-check after opening the write bucket; the duplicate guard is intentional
    -- and prevents SavedVariables growth for missing character/profile paths.
    local bucket = self:GetCharacterBucket(characterKey, false)
    local profile = type(bucket) == "table" and type(bucket.profiles) == "table" and bucket.profiles[profileId] or nil
    if type(profile) ~= "table" then
        return nil, "quickslot_profile_not_found"
    end

    profile.displayName = normalizedName
    profile.name = nil
    profile.updatedAt = type(GetTimeStamp) == "function" and GetTimeStamp() or profile.updatedAt
    return NormalizeProfileShape(Util:DeepCopy(profile))
end
