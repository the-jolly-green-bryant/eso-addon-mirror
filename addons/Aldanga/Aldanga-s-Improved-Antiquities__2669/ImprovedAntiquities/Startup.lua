ImprovedAntiquities = ZO_Object:Subclass()

ImprovedAntiquities.NAME = "ImprovedAntiquities"
ImprovedAntiquities.Modules = {}
ImprovedAntiquities.savedVariables = {}

function ImprovedAntiquities:Initialize()
end

function ImprovedAntiquities:OnAddOnLoaded(event, addonName)
    if (addonName ~= self.NAME) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    self:Initialize()


    ZO_PostHook(ZO_AntiquityTile_Keyboard, 'Initialize', function(self, control) 
        self.actions = {
            ["showOnMap"] = {
            label = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
            visible = function(self)
                return self.tileData:HasDiscoveredDigSites()
            end,
            execute = function(self)
                local antiquityId = self:GetAntiquityId()
                SetTrackedAntiquityId(antiquityId)
                WORLD_MAP_MANAGER:ShowAntiquityOnMap(antiquityId)
            end,
        },
        ["negative"] = {
            label = GetString(SI_ANTIQUITY_ABANDON),
            visible = function(self)
                return self.tileData:HasDiscoveredDigSites()
            end,
            execute = function(self)
                ZO_Dialogs_ShowDialog("CONFIRM_ABANDON_ANTIQUITY_SCRYING_PROGRESS", { antiquityId = self:GetAntiquityId() })
            end,
        },
        ["tertiary"] = {
            label = GetString(SI_ANTIQUITY_LOG_BOOK),
            visible = function(self)
                return self.tileData:HasDiscovered() and self.tileData:GetNumLoreEntries() > 0
            end,
            execute = function(self)
                ANTIQUITY_LORE_KEYBOARD:ShowAntiquity(self:GetAntiquityId())
            end,
        },
        ["primary"] = {
            label = GetString(SI_ANTIQUITY_SCRY),
            enabled = function(self)
                local canScry, scryResultMessage = self.tileData:CanScry()
                return canScry, scryResultMessage
            end,
            visible = function(self)
                return self.tileData:HasDiscovered()
            end,
            execute = function(self)
                ScryForAntiquity(self:GetAntiquityId())
            end,
        },
        }
    end)
end

function ImprovedAntiquities:ConsoleCommands()
    SLASH_COMMANDS["/scq"] = function(args)
        local multiplier = tonumber(args) or 1
        self:SetCraftingQueue(multiplier)
    end
    SLASH_COMMANDS["/clearqueue"] = function()
        self.Modules.Queue:Clear()
    end
end

EVENT_MANAGER:RegisterForEvent(
    ImprovedAntiquities.NAME,
    EVENT_ADD_ON_LOADED,
    function(...)
        ImprovedAntiquities:OnAddOnLoaded(...)
    end
)
