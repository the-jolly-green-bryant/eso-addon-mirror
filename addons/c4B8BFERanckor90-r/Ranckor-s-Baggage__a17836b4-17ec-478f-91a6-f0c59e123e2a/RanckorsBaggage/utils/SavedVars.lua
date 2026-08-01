local RB = RanckorsBaggage

function RB:InitializeSavedVars()
    self.saved = ZO_SavedVars:NewAccountWide(self.name .. "SavedVars", 1, nil, self.defaults)
    self.hasShownCurrencyWarning = false

    local pos = self.saved.position or self.defaults.position or { x = 0, y = 100 }
    self.saved.position = ZO_DeepTableCopy(pos)

    local ds = self.saved.displaySettings or self.defaults.displaySettings or {}
    self.saved.displaySettings = ZO_DeepTableCopy(ds)

    if self.saved.uiScale == nil then
        self.saved.uiScale = self.defaults.uiScale or 100
    end

    if self.saved.size and (not self.saved.size.w or not self.saved.size.h) then
        self.saved.size = nil
    end

    self.saved.backgroundStyle = self.saved.backgroundStyle or (self.defaults.backgroundStyle or "clear")
end