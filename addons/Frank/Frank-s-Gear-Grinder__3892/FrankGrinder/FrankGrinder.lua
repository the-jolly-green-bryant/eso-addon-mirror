local EM = EVENT_MANAGER





function FrankGrinder:DelayedStart()
    local ready = false
    local LCK = LibCharacterKnowledge

    if (LCK and self._lckIsLoaded == true) or (not LCK) then
        ready = true
    end

    if not ready then return end

    EM:UnregisterForUpdate(self.name .. ".DelayedStart")

    self:InitializeLeadWarning()

    self:InitializeGroupFinderNotifications()

    if self:GetSettingOverridePAKnown() then
        self:PA_Install()
    end

    self:InitializeLeadWarningHook()

    self:InitializeMailer()

    self:InitializeNightMarket()
    
    self:OnStart()
end

function FrankGrinder:Initialize(eventCode, addonName)
    if addonName ~= self.name then return end
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    if FrankGrinder.A() then
        ZO_CreateStringId("SI_BINDING_NAME_FRANKGRINDER_TOGGLE", GetString(GG_SHOW_WINDOW))
        ZO_CreateStringId("SI_BINDING_NAME_FRANKGRINDER_TOGGLEZONE", GetString(GG_TOGGLE_LOCATION_TRACKER))
        ZO_CreateStringId("SI_BINDING_NAME_FRANKGRINDER_NMKEYFARM", GetString(GG_NM_GROUP_AUTOMATION_KEYBIND))

        local world = GetWorldName()
        self:InitSavedVars(world)

        EM:RegisterForEvent(self.name, EVENT_QUEST_REMOVED, function(...) self:UpdateTime(...) end)

        self:BuildMenu()
        self:RegisterSlashCommands()

        self:LeadWarnings_ResetState()

        EM:RegisterForUpdate(self.name .. ".DelayedStart", 500, function() self:DelayedStart() end)
    end
end

EM:RegisterForEvent(FrankGrinder.name, EVENT_ADD_ON_LOADED, function(...) FrankGrinder:Initialize(...) end)

do
    local LCK = LibCharacterKnowledge
    if LCK then
        LCK.RegisterForCallback(FrankGrinder.name, LCK.EVENT_INITIALIZED, function()
            FrankGrinder._lckIsLoaded = true
            FrankGrinder:PA_ClearCaches()
        end)
    end
end
