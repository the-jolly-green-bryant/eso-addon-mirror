-- PetKennel: Put away your bear while in town!
--

local PetKennel = _G['PetKennel']

PetKennel.name              = "PetKennel"
PetKennel.version           = "5.1.5"
PetKennel.saved_var_version = 2

PetKennel.default = {
                        -- Unless explicitly listed here, all "enable"
                        -- settings default to "on".
    enable = { DUNGEON = { combat = false, non_combat = false } }
}

local Log = PetKennel.Log

-- Pet -----------------------------------------------------------------------

-- PET_ABILITY_ID array copied from Dolgubon's Lazy Writ Creator DismissPets()
PetKennel.PET_ABILITY_ID = {
[23304]=true, [30631]=true, [30636]=true, [30641]=true, [23319]=true, [30647]=true,
[30652]=true, [30657]=true, [23316]=true, [30664]=true, [30669]=true, [30674]=true,
[24613]=true, [30581]=true, [30584]=true, [30587]=true, [24636]=true, [30592]=true,
[30595]=true, [30598]=true, [24639]=true, [30618]=true, [30622]=true, [30626]=true,
[85982]=true, [85983]=true, [85984]=true, [85985]=true, [85986]=true, [85987]=true,
[85988]=true, [85989]=true, [85990]=true, [85991]=true, [85992]=true, [85993]=true,
}
-- 85986 = Eternal Guardian warden bear

local function caret_strip(s)
    return zo_strformat("<<1>>",s)
end

function PetKennel:HidePet()
    Log.Debug("HidePet")
    self:HidePetsIf(PetKennel.SETTINGS.KEY_BINDING.key)
end

-- Hide combat and/or non-combat pets if settings enabled.
function PetKennel:HidePetsIf(setting_name)
    if PetKennel.IsInPlayerHousing() then
        -- Log.Info("Skipped: player housing")
        return
    end
    local sv = self.saved_vars.enable[setting_name] or {}
    if sv.combat ~= false then
        self:HideCombatPet()
    end
    if sv.non_combat ~= false then
        self:HideVanityPet()
    end
end

function PetKennel:HideCombatPet()
    for i = 1, GetNumBuffs("player") do
        local o = { GetUnitBuffInfo("player", i) }
        local buff_index = o[ 4]
        local buff_name  = o[ 1]
        local ability_id = o[11]
        if PetKennel.PET_ABILITY_ID[ability_id] then
            Log.Info("Hiding pet: %s", caret_strip(o[1]))
            CancelBuff(buff_index)
        end
    end
end

function PetKennel:HideVanityPet()
    local vanity_pet_coll_id, pet_name = self.FindActiveVanityPetCollectibleId()
    if vanity_pet_coll_id then
        Log.Info("Hiding pet: %s", caret_strip(pet_name))
        UseCollectible(vanity_pet_coll_id)
    end
end

function PetKennel:FindActiveVanityPetCollectibleId()
    local cctype  = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
    local coll_ct = GetTotalCollectiblesByCategoryType(cctype)
    -- Log:StartNewEvent("FindVanity")
    for i = 1,coll_ct do
        local coll_id = GetCollectibleIdFromType(cctype, i)
                        -- Assume ALL pets are "renamable" and
                        -- non-pets are not.
        if IsCollectibleRenameable(coll_id) then
            local o = { GetCollectibleInfo(coll_id) }
            -- Log:Add(o)
            local is_active = o[7]
            if is_active then
                local pet_name = o[1]
                return coll_id, pet_name
            end
        else
            -- Log:Add(coll_id)
        end
    end
    -- Log:EndEvent()
end

function PetKennel:DumpPets()
    local list = {}
    for k,_ in pairs(self.PET_ABILITY_ID) do
        table.insert(list, k)
    end
    table.sort(list)
    Log:StartNewEvent("Dumping all pet abilities...")
    for _,ability_id in ipairs(list) do
        local n = GetAbilityName(ability_id)
        Log:Add(string.format("%5d %s", ability_id, n))
    end
    Log:EndEvent()

    Log:StartNewEvent("Dumping all buffs")
    for i = 1, GetNumBuffs("player") do
        local o = { GetUnitBuffInfo("player", i) }
        Log:Add(string.format( "ability_id:%d can_click_off:%s %s"
                             , o[11]
                             , tostring(o[12])
                             , o[ 1]
                             ))

    end
    Log:EndEvent()
end

-- Event Listeners -----------------------------------------------------------

function PetKennel:RegisterListeners()
    Log.Debug("RegisterCraftListener")

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_CRAFTING_STATION_INTERACT
        , PetKennel.OnCraftingStationInteract
        )

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_OPEN_BANK
        , PetKennel.OnOpenBank
        )

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_OPEN_STORE
        , PetKennel.OnOpenStore
        )

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_OPEN_TRADING_HOUSE
        , PetKennel.OnOpenTradingHouse
        )

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_CHATTER_BEGIN
        , PetKennel.OnChatterBegin
        )

    EVENT_MANAGER:RegisterForEvent(self.name
        , EVENT_PLAYER_ACTIVATED
        , PetKennel.OnPlayerActivated
        )

end

function PetKennel.OnCraftingStationInteract(event, station_id, same_station)
    PetKennel:HidePetsIf(PetKennel.SETTINGS.CRAFTING_STATION.key)
end

function PetKennel.OnOpenBank(event, station_id, bag_id)
    local is_assistant = IsInteractingWithMyAssistant()
    if not is_assistant then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.BANKER.key)
    end
end

function PetKennel.OnOpenStore(event)
    local is_assistant = IsInteractingWithMyAssistant()
    if not is_assistant then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.MERCHANT.key)
    end
end

                        -- Treat Guild Store same as NPC Merchant.
                        -- Pets get in the way while shopping guild stores.
function PetKennel.OnOpenTradingHouse(event)
    PetKennel:HidePetsIf(PetKennel.SETTINGS.MERCHANT.key)
end

function PetKennel.OnChatterBegin(option_ct)
    local self = PetKennel
    local dialog_title = self:GetDialogTitle()

    local is_writ_board = LibCraftText.DailyDialogTitleIsWritBoard(dialog_title)
    if is_writ_board then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.WRIT_BOARD.key)
        return
    end

    local is_turn_in = LibCraftText.DailyDialogTurnInTitleToCraftingType(dialog_title)
    if is_turn_in then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.TURN_IN_CRATE.key)
        return
    end

    local is_rolis = LibCraftText.MASTER.DIALOG.TITLE_ROLIS == dialog_title
    if is_rolis then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.ROLIS.key)
        return
    end
end

function PetKennel:GetDialogTitle()
    return ZO_InteractWindowTargetAreaTitle:GetText()
end

function PetKennel.OnPlayerActivated()
    local self = PetKennel
    local is_d = IsUnitInDungeon("player")
    if is_d then
        PetKennel:HidePetsIf(PetKennel.SETTINGS.DUNGEON.key)
    end
end

function PetKennel.IsInPlayerHousing()
    local house_owner  = GetCurrentHouseOwner()
    return house_owner and (house_owner ~= "")
end

-- Key Binding ---------------------------------------------------------------

function PetKennel.KeyBindingHidePet()
    PetKennel:HidePet()
end

-- Init ----------------------------------------------------------------------

function PetKennel.OnAddOnLoaded(event, addonName)
    if addonName == PetKennel.name then
        if not PetKennel.version then return end
        PetKennel:Initialize()
    end
end

function PetKennel:Initialize()
    self.saved_vars = ZO_SavedVars:New(
                              "PetKennelVars"
                            , self.saved_var_version
                            , nil
                            , self.default
                            )
    self:CreateSettingsUI()

    self:RegisterListeners()
end

-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( PetKennel.name
                              , EVENT_ADD_ON_LOADED
                              , PetKennel.OnAddOnLoaded
                              )

                        -- Key binding strings must be defined earlier than
                        -- OnAddOnLoaded() time or the key binding will not
                        -- appear in Controls/Keybindings.
                        --
                        -- Category string is locked at file-load time and
                        -- cannot be changed. That's okay, we don't translate
                        -- our add-on name anyway.
                        --
                        -- Individual key binds can and should be replaced with
                        -- i18n strings later, once we've loaded savedVariables
                        -- and know which language the user prefers.

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_PET_KENNEL",    "PetKennel")
ZO_CreateStringId("SI_BINDING_NAME_PetKennel_HidePet",     "Hide Pet")
