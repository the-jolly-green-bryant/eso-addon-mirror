-- @Origami: A few shortcuts to shorten some debug messages.
local sf = string.format
local zo_str = zo_strformat

-- @Origami: Create our object.
local RM_Object = ZO_Object:Subclass()
function RM_Object:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

-- @Origami: Initialize the addon details.
function RM_Object:Initialize()
    self.ADDON_NAME = "RandomMount"
    self.ADDON_VERSION = "3.7"
    self.account = {}
    self.settings = {}
    self.player_activated = false
    self.mountChanged = GetTimeStamp()
    self.petChanged = self.mountChanged
    self.skinChanged = self.mountChanged
    self.panel = nil
    self.settingsCreated = false
end

-- @Origami: Legacy bug fixes. Used to wipe out unused settings. Might be removable.
function RM_Object:StructureAndFix()
    -- @Weolo: Fix any data bugs or add new patch features
    -- @Weolo: Setup the data structures to contain the expected data
    self.account.toCharacterId = nil -- @Weolo: only existed in v1.7
    self.settings.toCharacterId = nil
    self.settings.on = nil
    local data = {self.account.mounts, self.account.pets, self.account.skins, self.settings.mounts, self.settings.pets,
                  self.settings.skins}
    for k, v in pairs(data) do
        for id, c in pairs(v) do
            c.collectibleName = nil -- @Weolo: removed v1.8
        end
    end
end

-- @Origami: Gets current configuration/settings based on whether account-wide or character-specific is enabled.
-- @Origami: This is used in a LOT of places, careful with modification.
function RM_Object:GetKey()
    return (RandomMount.settings.useAccountWide and "account" or "settings")
end

-- @Origami: Used to gather and display data about available mounts.
function RM_Object:GetMountOptions()
    local mounts = {}
    for id, obj in pairs(self.account.mounts) do
        mounts[#mounts + 1] = {
            type = "prettybox",
            width = "half",
            name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(id)),
            getFunc = function()
                local key = self:GetKey()
                if self[key].mounts[id] then
                    return self[key].mounts[id].use
                else
                    return false
                end
            end,
            setFunc = function(value)
                self[self:GetKey()].mounts[id].use = value
            end,
            disabled = function()
                local key = self:GetKey()
                if self[key].mounts[id] then
                    return not self[key].mount.enable
                else
                    return true
                end
            end,
            default = true,
            reference = sf("%s_Mount%d", self.ADDON_NAME, id),
            image = GetCollectibleIcon(id)
        }
    end
    table.sort(mounts, function(a, b)
        return a.name < b.name
    end)
    return mounts
end

-- @Origami: Used to gather and display data about available pets.
function RM_Object:GetPetOptions()
    local pets = {}
    for id, obj in pairs(self.account.pets) do
        pets[#pets + 1] = {
            type = "prettybox",
            width = "half",
            name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(id)),
            getFunc = function()
                local key = self:GetKey()
                if self[key].pets[id] then
                    return self[key].pets[id].use
                else
                    return false
                end
            end,
            setFunc = function(value)
                self[self:GetKey()].pets[id].use = value
            end,
            disabled = function()
                local key = self:GetKey()
                if self[key].pets[id] then
                    return not self[key].pet.enable
                else
                    return true
                end
            end,
            default = true,
            reference = sf("%s_Pet%d", self.ADDON_NAME, id),
            image = GetCollectibleIcon(id)
        }
    end
    table.sort(pets, function(a, b)
        return a.name < b.name
    end)
    return pets
end

-- @Origami: Used to gather and display data about available skins.
function RM_Object:GetSkinOptions()
    local skins = {}
    for id, obj in pairs(self.account.skins) do
        skins[#skins + 1] = {
            type = "prettybox",
            width = "half",
            name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(id)),
            getFunc = function()
                local key = self:GetKey()
                if self[key].skins[id] then
                    return self[key].skins[id].use
                else
                    return false
                end
            end,
            setFunc = function(value)
                self[self:GetKey()].skins[id].use = value
            end,
            disabled = function()
                local key = self:GetKey()
                if self[key].skins[id] then
                    return not self[key].skin.enable
                else
                    return true
                end
            end,
            default = true,
            reference = sf("%s_Skin%d", self.ADDON_NAME, id),
            image = GetCollectibleIcon(id)
        }
    end
    table.sort(skins, function(a, b)
        return a.name < b.name
    end)
    return skins
end

-- @Origami: Build and display settings menu using LibAddonMenu v2.
function RM_Object:CreateSettingsMenu()
    if (not LibAddonMenu2) or self.panel then
        return
    end
    -- if not LibAddonMenu2 then return end
    -- if self.panel then return end

    local defaults = {}
    defaults.account = self:DefaultAccount()
    defaults.settings = self:DefaultSettings()
    local optionsName = "RandomMountOptions"
    local panelData = {
        type = "panel",
        name = self.ADDON_NAME,
        displayName = sf("|cff8800%s|r", self.ADDON_NAME),
        author = "Weolo, Origami",
        version = self.ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
        slashCommand = "/randommountoptions",
        website = "http://www.esoui.com/downloads/info1984-RandomMount.html",
        feedback = "https://www.esoui.com/downloads/info1984-RandomMount.html#comments",
        donation = "https://www.esoui.com/downloads/info1984-RandomMount.html#donate"
    }
    self.panel = LibAddonMenu2:RegisterAddonPanel(optionsName, panelData)
    self:AddSettingsOptions(optionsName, defaults)
end

-- @Origami: Build options menu.
function RM_Object:AddSettingsOptions(optionsName, defaults)
    local optionsData = {{ -- @Origami: General options.
        type = "checkbox",
        name = RM_OP_ACCOUNT,
        getFunc = function()
            return self.settings.useAccountWide
        end,
        setFunc = function(value)
            self.settings.useAccountWide = value
        end,
        default = defaults.settings.useAccountWide
    }, {
        type = "slider",
        name = RM_OP_DELAY,
        tooltip = RM_OP_DELAY_TT,
        getFunc = function()
            return self[self:GetKey()].delay
        end,
        setFunc = function(value)
            self[self:GetKey()].delay = value
        end,
        min = 1,
        max = 7,
        step = 1,
        default = defaults[self:GetKey()].delay
    }, { -- @Origami: Mount options start here.
        type = "header",
        name = RM_OP_HEADING1
    }, {
        type = "checkbox",
        name = RM_OP_MOUNTS_ENABLE,
        getFunc = function()
            return self[self:GetKey()].mount.enable
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.enable = value
        end,
        default = defaults[self:GetKey()].mount.enable
    }, {
        type = "checkbox",
        name = RM_OP_MOUNTS_ENABLE_PVP,
        getFunc = function()
            return self[self:GetKey()].mount.enable_pvp
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.enable_pvp = value
        end,
        disabled = function()
            return not self[self:GetKey()].mount.enable
        end,
        default = function()
            return defaults[self:GetKey()].mount.enable_pvp
        end
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_ZONE,
        getFunc = function()
            return self[self:GetKey()].mount.zone
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.zone = value
        end,
        disabled = function()
            return not self[self:GetKey()].mount.enable
        end,
        default = defaults[self:GetKey()].mount.zone
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_DISMOUNT,
        getFunc = function()
            return self[self:GetKey()].mount.dismount
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.dismount = value
        end,
        disabled = function()
            return not self[self:GetKey()].mount.enable
        end,
        default = defaults[self:GetKey()].mount.dismount
    }, {
        type = "checkbox",
        name = RM_OP_MOUNTS_MULTI_GROUPED,
        getFunc = function()
            return self[self:GetKey()].mount.preferMultiWhenGrouped
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.preferMultiWhenGrouped = value
        end,
        disabled = function()
            return not self[self:GetKey()].mount.enable
        end,
        default = defaults[self:GetKey()].mount.preferMultiWhenGrouped
    }, {
        type = "checkbox",
        name = RM_OP_MOUNTS_MULTI_COMPANION,
        getFunc = function()
            return self[self:GetKey()].mount.preferMultiWhenCompanionOut
        end,
        setFunc = function(value)
            self[self:GetKey()].mount.preferMultiWhenCompanionOut = value
        end,
        disabled = function()
            return not self[self:GetKey()].mount.enable
        end,
        default = defaults[self:GetKey()].mount.preferMultiWhenCompanionOut
    }, {
        type = "submenu",
        name = RM_OP_HEADING3,
        controls = self:GetMountOptions(),
        disabledLabel = function()
            return not self[self:GetKey()].mount.enable
        end,
        icon = "/esoui/art/treeicons/store_indexicon_mounts_down.dds",
        reference = sf("%s_Mounts", self.ADDON_NAME)
    }, { -- @Origami: Pet options start here.
        type = "header",
        name = RM_OP_HEADING2
    }, {
        type = "checkbox",
        name = RM_OP_PETS_ENABLE,
        getFunc = function()
            return self[self:GetKey()].pet.enable
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.enable = value
        end,
        default = defaults[self:GetKey()].pet.enable
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_ZONE,
        getFunc = function()
            return self[self:GetKey()].pet.zone
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.zone = value
        end,
        disabled = function()
            return not self[self:GetKey()].pet.enable
        end,
        default = defaults[self:GetKey()].pet.zone
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_DISMOUNT,
        getFunc = function()
            return self[self:GetKey()].pet.dismount
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.dismount = value
        end,
        disabled = function()
            return not self[self:GetKey()].pet.enable
        end,
        default = defaults[self:GetKey()].pet.dismount
    }, {
        type = "checkbox",
        name = RM_OP_PETS_UNSUMMON_PVP,
        getFunc = function()
            return self[self:GetKey()].pet.unsummonpvp
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.unsummonpvp = value
        end,
        disabled = function()
            if ((self[self:GetKey()].pet.enable) and (self[self:GetKey()].pet.zone)) then
                return false
            else
                return true
            end
        end,
        default = defaults[self:GetKey()].pet.unsummonpvp
    }, {
        type = "checkbox",
        name = RM_OP_PETS_UNSUMMON_DUNGEON,
        getFunc = function()
            return self[self:GetKey()].pet.unsummondungeon
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.unsummondungeon = value
        end,
        disabled = function()
            if ((self[self:GetKey()].pet.enable) and (self[self:GetKey()].pet.zone)) then
                return false
            else
                return true
            end
        end,
        default = defaults[self:GetKey()].pet.unsummondungeon
    }, {
        type = "checkbox",
        name = RM_OP_PETS_UNSUMMON_GROUP,
        getFunc = function()
            return self[self:GetKey()].pet.unsummongroup
        end,
        setFunc = function(value)
            self[self:GetKey()].pet.unsummongroup = value
        end,
        disabled = function()
            if ((self[self:GetKey()].pet.enable) and (self[self:GetKey()].pet.zone)) then
                return false
            else
                return true
            end
        end,
        default = defaults[self:GetKey()].pet.unsummongroup
    }, {
        type = "submenu",
        name = RM_OP_HEADING4,
        controls = self:GetPetOptions(),
        disabledLabel = function()
            return not self[self:GetKey()].pet.enable
        end,
        icon = "/esoui/art/treeicons/store_indexicon_vanitypets_down.dds",
        reference = sf("%s_Pets", self.ADDON_NAME)
    }, { -- @Origami: Skin options start here.
        type = "header",
        name = RM_OP_HEADING6
    }, {
        type = "checkbox",
        name = RM_OP_SKINS_ENABLE,
        getFunc = function()
            return self[self:GetKey()].skin.enable
        end,
        setFunc = function(value)
            self[self:GetKey()].skin.enable = value
        end,
        default = defaults[self:GetKey()].skin.enable
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_ZONE,
        getFunc = function()
            return self[self:GetKey()].skin.zone
        end,
        setFunc = function(value)
            self[self:GetKey()].skin.zone = value
        end,
        disabled = function()
            return not self[self:GetKey()].skin.enable
        end,
        default = defaults[self:GetKey()].skin.zone
    }, {
        type = "checkbox",
        name = RM_OP_ACTIVATE_DISMOUNT,
        getFunc = function()
            return self[self:GetKey()].skin.dismount
        end,
        setFunc = function(value)
            self[self:GetKey()].skin.dismount = value
        end,
        disabled = function()
            return not self[self:GetKey()].skin.enable
        end,
        default = defaults[self:GetKey()].skin.dismount
    }, {
        type = "checkbox",
        name = RM_OP_ALLOW_DEFAULT,
        getFunc = function()
            return self[self:GetKey()].skin.allowDefault
        end,
        setFunc = function(value)
            self[self:GetKey()].skin.allowDefault = value
        end,
        disabled = function()
            return not self[self:GetKey()].skin.enable
        end,
        default = defaults[self:GetKey()].skin.allowDefault
    }, {
        type = "submenu",
        name = RM_OP_HEADING7,
        controls = self:GetSkinOptions(),
        disabledLabel = function()
            return not self[self:GetKey()].skin.enable
        end,
        icon = "/esoui/art/treeicons/collection_indexicon_abilityskins_down.dds",
        reference = sf("%s_Skins", self.ADDON_NAME)
    }}
    LibAddonMenu2:RegisterOptionControls(optionsName, optionsData)
end

-- @Origami: Sorts through collectible data for specifics.
function RM_Object:GetData()
    -- @Weolo: Categories (ZO_CollectibleCategoryData) containing Sub Category Data and then collectable data (ZO_CollectibleData)
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataByIndicies(categoryIndex)
        local numSubcategories = categoryData:GetNumSubcategories()
        -- @Weolo: Mounts and pets are now in sub categories, so ignore all numCollectibles on Category
        -- @Weolo: One odd exception is Dragonguard Cat is in IsTopLevelCategory, categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, numCollectibles>0
        for subcategoryIndex = 1, numSubcategories do
            local subcategoryData = categoryData:GetSubcategoryData(subcategoryIndex)
            if subcategoryData then
                local numCollectibles = subcategoryData:GetNumCollectibles()
                for collectibleIndex = 1, numCollectibles do
                    local collectibleData = subcategoryData:GetCollectibleDataByIndex(collectibleIndex)
                    if collectibleData:IsUnlocked() then
                        local categoryType = collectibleData:GetCategoryType()
                        if categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT then
                            local id = collectibleData:GetId()
                            self.account.mounts[id] = self.account.mounts[id] or {
                                use = true
                            }
                            self.settings.mounts[id] = self.settings.mounts[id] or {
                                use = true
                            }
                        end
                        if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
                            local id = collectibleData:GetId()
                            self.account.pets[id] = self.account.pets[id] or {
                                use = true
                            }
                            self.settings.pets[id] = self.settings.pets[id] or {
                                use = true
                            }
                        end
                        if categoryType == COLLECTIBLE_CATEGORY_TYPE_SKIN then
                            local id = collectibleData:GetId()
                            self.account.skins[id] = self.account.skins[id] or {
                                use = true
                            }
                            self.settings.skins[id] = self.settings.skins[id] or {
                                use = true
                            }
                        end
                    else
                        if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) then
                            -- @Weolo: The mount was unlocked once, must have been removed when it transformed into another event mount
                            local id = collectibleData:GetId()
                            if self.account.mounts[id] then
                                self.account.mounts[id] = nil
                            end
                            if self.settings.mounts[id] then
                                self.settings.mounts[id] = nil
                            end
                        end
                    end
                end
            end
        end
    end
end

-- @Origami: Triggered by ZOS event. Keeps collections updated when they change (unlocks/transforms/etc).
function RM_Object:OnCollectionUpdated(...)
    self:GetData()
    if self.panel then
        self:GetData()
        self.panel:RefreshPanel()
    end
end

-- @Origami: Triggered by ZOS event. Triggers whenever mount status changes (mount/dismount), but should be ignored whenever mounting.
function RM_Object:OnMountedStateChanged(isMounted)
    if self[self:GetKey()].mount.dismount then
        if not isMounted then
            zo_callLater(function()
                self:SummonMount()
            end, 1000)
        end
    end
    if self[self:GetKey()].pet.dismount then
        if not isMounted then
            zo_callLater(function()
                self:SummonPet()
            end, 1000)
        end
    end
    if self[self:GetKey()].skin.dismount then
        if not isMounted then
            zo_callLater(function()
                self:ChangeSkin()
            end, 1000)
        end
    end
end

-- @Origami: Triggered by ZOS event. Triggers whenever a zone change is detected.
-- @Origami: Additionally, this is technically called upon player activation (i.e., load complete). This is because ZOS zone change event triggers on subzones and isn't reliable on actual zone changes.
function RM_Object:OnZone(...)
    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
    if self[self:GetKey()].currentZoneId ~= currentZoneId then
        self[self:GetKey()].currentZoneId = currentZoneId
        local currentZoneType = GetMapContentType()
        if self[self:GetKey()].mount.zone then
            if not isMounted then
                zo_callLater(function()
                    self:SummonMount()
                end, 1000)
            end
        end
        if self[self:GetKey()].pet.zone then
            if (self[self:GetKey()].pet.unsummonpvp and currentZoneType ~= MAP_CONTENT_NONE and currentZoneType ~=
                MAP_CONTENT_DUNGEON) then
                zo_callLater(function()
                    self:UnsummonPet()
                end, 1000)
            elseif (self[self:GetKey()].pet.unsummondungeon and currentZoneType == MAP_CONTENT_DUNGEON) then
                zo_callLater(function()
                    self:UnsummonPet()
                end, 1000)
            else
                if not isMounted then
                    zo_callLater(function()
                        self:SummonPet()
                    end, 1000)
                end
            end
        end
        if self[self:GetKey()].skin.zone then
            if not isMounted then
                zo_callLater(function()
                    self:ChangeSkin()
                end, 1000)
            end
        end
    end
end

-- @Origami: Trigger group state change events.
function RM_Object:OnGroupStateChange()
    if (IsUnitGrouped("player") and self[self:GetKey()].pet.unsummongroup) then
        zo_callLater(function()
            self:UnsummonPet()
        end, 1000)
    end
    if ((not IsUnitGrouped("player")) and self[self:GetKey()].pet.unsummongroup) then
        zo_callLater(function()
            self:SummonPet()
        end, 1000)
    end
end

-- @Origami: Default account-wide settings.
function RM_Object:DefaultAccount()
    return {
        mount = {
            enable = true,
            enable_pvp = true,
            zone = true,
            dismount = true,
            preferMultiWhenGrouped = true,
            preferMultiWhenCompanionOut = true
        },
        pet = {
            enable = true,
            zone = true,
            dismount = true,
            unsummonpvp = false,
            unsummondungeon = false,
            unsummongroup = false
        },
        skin = {
            enable = false,
            zone = true,
            dismount = true,
            allowDefault = true
        },
        currentZoneId = 0,
        mounts = {},
        pets = {},
        skins = {},
        delay = 2,
        mountCategories = {
            [0] = sf("%s", SI_AUDIOSPEAKERCONFIGURATIONS0)
        },
        petCategories = {
            [0] = sf("%s", SI_AUDIOSPEAKERCONFIGURATIONS0)
        },
        skinCategories = {
            [0] = sf("%s", SI_AUDIOSPEAKERCONFIGURATIONS0)
        },
        nextMountCategoryID = 1,
        nextPetCategoryID = 1,
        nextSkinCategoryID = 1,
        currentMountCategory = 0,
        currentPetCategory = 0,
        currentSkinCategory = 0
    }
end

-- @Origami: Default character-specific settings.
function RM_Object:DefaultSettings()
    return {
        mount = {
            enable = true,
            enable_pvp = true,
            zone = true,
            dismount = true,
            preferMultiWhenGrouped = true,
            preferMultiWhenCompanionOut = true
        },
        pet = {
            enable = true,
            zone = true,
            dismount = true,
            unsummonpvp = false,
            unsummondungeon = false,
            unsummongroup = false
        },
        skin = {
            enable = false,
            zone = true,
            dismount = true,
            allowDefault = true
        },
        currentZoneId = 0,
        mounts = {},
        pets = {},
        skins = {},
        useAccountWide = true,
        delay = 2
    }
end

-- @Origami: Returns boolean whether or not assistant is out (merchant/banker/etc).
function RM_Object:IsAssistantOut()
    return (GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT) ~= 0)
end

-- @Origami: Returns boolean whether or not companion is out (combat companion). Used for multi-rider mount support.
function RM_Object:IsCompanionOut()
    return (GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION) ~= 0)
end

-- @Origami: Returns array of useable mounts. This can be determined by multi-rider settings and mount selection in settings.
function RM_Object:GetUseableMounts()
    local k = self:GetKey()
    local t = {}
    for id, obj in pairs(self.account.mounts) do
        if self[k].mounts[id] then
            if self[k].mounts[id].use == true then
                if self[k].mount.preferMultiWhenCompanionOut and self:IsCompanionOut() then
                    if self:IsMultiRider(id) then
                        t[#t + 1] = id
                    end
                elseif self[k].mount.preferMultiWhenGrouped and IsUnitGrouped("player") then
                    if self:IsMultiRider(id) then
                        t[#t + 1] = id
                    end
                else
                    t[#t + 1] = id
                end
            end
        end
    end
    if #t == 0 and (self[k].mount.preferMultiWhenCompanionOut or self[k].mount.preferMultiWhenGrouped) then
        for id, obj in pairs(self.account.mounts) do
            if self[k].mounts[id] then
                if self[k].mounts[id].use == true then
                    t[#t + 1] = id
                end
            end
        end
    end
    return t
end

-- @Origami: Returns boolean whether the mount ID being inspected supports multiple riders.
function RM_Object:IsMultiRider(id)
    local k = self:GetKey()
    local isMultiRider = false
    local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(id).categoryData
    local subCategoryName = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataByIndicies(categoryData.categoryIndex,
                                categoryData.subcategoryIndex).name
    if (subCategoryName == 'Multi-Rider') then
        isMultiRider = true
    end
    return isMultiRider
end

-- @Origami: This triggers based on change settings and it will change the active mount randomly.
function RM_Object:SummonMount()
    local k = self:GetKey()
    if self[k].mount.enable then
        local currentMount = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
        if self:InPvP() and self[k].mount.enable_pvp == false then
            return
        end
        local useable = self:GetUseableMounts()
        if #useable > 0 then
            local newMount = useable[math.random(1, #useable)]
            if (#useable > 1) then
                while (newMount == currentMount) do
                    newMount = useable[math.random(1, #useable)]
                end
            end
            local timeBetweenChange = GetDiffBetweenTimeStamps(GetTimeStamp(), self.mountChanged)
            local delay = self[self:GetKey()].delay
            if timeBetweenChange > delay then
                if (not IsMounted()) and (not IsCollectibleActive(newMount)) and (not IsUnitInCombat("player")) then
                    if not IsCollectibleUsable(newMount) then
                        zo_callLater(function()
                            UseCollectible(newMount)
                        end, self[k].delay * 1000)
                    else
                        UseCollectible(newMount)
                    end
                    self.mountChanged = GetTimeStamp()
                else
                    zo_callLater(function()
                        UseCollectible(newMount)
                    end, self[k].delay * 270)
                end
            end
        end
    end
end

-- @Origami: Returns array of useable skins.
function RM_Object:GetUseableSkins()
    local k = self:GetKey()
    local t = {}
    for id, obj in pairs(self.account.skins) do
        if self[k].skins[id] then
            if self[k].skins[id].use == true then
                t[#t + 1] = id
            end
        end
    end
    if self[k].skin.allowDefault then
        t[#t + 1] = -1
    end
    return t
end

-- @Origami: This triggers based on change settings and it will change the active skin randomly.
function RM_Object:ChangeSkin()
    local k = self:GetKey()
    -- @Origami: Checking no active skin return...
    if self[k].skin.enable then
        if self:InPvP() then
            return
        end
        local useable = self:GetUseableSkins()
        local currentSkin = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)
        if (currentSkin == 0) then
            currentSkin = -1
        end
        if #useable > 0 then
            local newSkin = useable[math.random(1, #useable)]
            if (#useable > 1) then
                while (newSkin == currentSkin) do
                    newSkin = useable[math.random(1, #useable)]
                end
            end
            local timeBetweenChange = GetDiffBetweenTimeStamps(GetTimeStamp(), self.skinChanged)
            local delay = self[self:GetKey()].delay
            if timeBetweenChange > delay then
                if (not self:IsAssistantOut()) and (not IsCollectibleActive(newSkin)) and (not IsUnitInCombat("player")) then
                    if newSkin == -1 then
                        UseCollectible(currentSkin)
                        self.skinChanged = GetTimeStamp()
                    elseif IsCollectibleUsable(newSkin) then
                        UseCollectible(newSkin)
                        self.skinChanged = GetTimeStamp()
                    end
                end
            end
        end
    end
end

-- @Origami: Returns array of useable pets.
function RM_Object:GetUseablePets()
    local k = self:GetKey()
    local t = {}
    for id, obj in pairs(self.account.pets) do
        if self[k].pets[id] then
            if self[k].pets[id].use == true then
                t[#t + 1] = id
            end
        end
    end
    return t
end

-- @Origami: This triggers based on change settings and it will change the active pet randomly.
function RM_Object:SummonPet()
    local k = self:GetKey()
    if self[k].pet.enable then
        if self:InPvP() then
            return
        end
        local useable = self:GetUseablePets()
        local currentPet = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
        if #useable > 0 then
            local newPet = useable[math.random(1, #useable)]
            if (#useable > 1) then
                while (newPet == currentPet) do
                    newPet = useable[math.random(1, #useable)]
                end
            end
            local timeBetweenChange = GetDiffBetweenTimeStamps(GetTimeStamp(), self.petChanged)
            local delay = self[self:GetKey()].delay
            if timeBetweenChange > delay then
                if (not self:IsAssistantOut()) and (not IsCollectibleActive(newPet)) and IsCollectibleUsable(newPet) and
                    (not IsUnitInCombat("player")) then
                    UseCollectible(newPet)
                    self.petChanged = GetTimeStamp()
                end
            end
        end
    end
end

function RM_Object:UnsummonPet()
    local k = self:GetKey()
    if self[k].pet.enable then
        if self:InPvP() then
            return
        end
        local currentPet = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
        local timeBetweenChange = GetDiffBetweenTimeStamps(GetTimeStamp(), self.petChanged)
        local delay = self[self:GetKey()].delay
        if timeBetweenChange > delay then
            if IsCollectibleUsable(currentPet) and (not IsUnitInCombat("player")) then
                UseCollectible(currentPet)
                self.petChanged = GetTimeStamp()
            end
        end
    end
end

-- @Origami: Returns boolean based on whether player is in PvP.
function RM_Object:InPvP()
    return IsInAvAZone() or IsUnitPvPFlagged("player") or IsActiveWorldBattleground()
end

-- @Origami: Triggers when settings panel is opened?
function RM_Object:OnSettingsControlsCreated(panel)
    -- @Weolo: Each time an options panel is created, once for each addon viewed
    if panel:GetName() == "RandomMountOptions" then
        self.settingsCreated = true
    end
end

-- @Origami: On first player activation, configure everything.
function RM_Object:OnPlayerActivated()
    if self.player_activated then
        return
    end -- @Weolo: Only the first time
    self.player_activated = true
    EVENT_MANAGER:UnregisterForEvent(self.ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    self:StructureAndFix()
    self:GetData()
    self:CreateSettingsMenu()
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_ZONE_CHANGED, function()
        zo_callLater(function()
            self:OnZone()
        end, 2000)
    end)
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            self:OnZone()
        end, 2000)
    end)
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, function()
        self:OnGroupStateChange()
    end)
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, function()
        self:OnGroupStateChange()
    end)
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_COLLECTION_UPDATED, function(...)
        self:OnCollectionUpdated()
    end) -- @Weolo: Full refresh
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_COLLECTIBLES_UPDATED, function(...)
        self:OnCollectionUpdated()
    end) -- @Origami: Another way to check for updates
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(...)
        self:OnCollectionUpdated()
    end) -- @Weolo: Need to check more
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME, EVENT_MOUNTED_STATE_CHANGED, function(_, isMounted)
        self:OnMountedStateChanged(isMounted)
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        self:OnSettingsControlsCreated(panel)
    end)
end

-- @Origami: On addon load completion, register events.
function RM_Object:OnLoaded(addonName)
    local name = self.ADDON_NAME
    if addonName ~= name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
    self.account = ZO_SavedVars:NewAccountWide("RandomMountSettings", 1, nil, self:DefaultAccount()) -- @Weolo: v1.8
    self.settings = ZO_SavedVars:NewCharacterIdSettings("RandomMountSettings", 1, nil, self:DefaultSettings())
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerActivated()
    end)
end

-- @Origami: Create our object container and register for load.
RandomMount = RM_Object:New()
EVENT_MANAGER:RegisterForEvent(RandomMount.ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    RandomMount:OnLoaded(addonName)
end)
