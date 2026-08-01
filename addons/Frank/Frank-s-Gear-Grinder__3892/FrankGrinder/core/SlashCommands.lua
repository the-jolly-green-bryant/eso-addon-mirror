function FrankGrinder:RegisterSlashCommands()
    SLASH_COMMANDS["/fgg"] = function(arg)
        arg = zo_strlower(tostring(arg or ""))

        if arg == "" then
            self:ToggleWindow()
            return
        end

        if arg == "debug" then
            self:SetDebugEnabled(not self:IsDebugEnabled())
            self:ChatMsg("Debug: " .. tostring(self:IsDebugEnabled()))
            return
        end

        if arg == "debug on" then
            self:SetDebugEnabled(true)
            self:ChatMsg("Debug: true")
            return
        end

        if arg == "debug off" then
            self:SetDebugEnabled(false)
            self:ChatMsg("Debug: false")
            return
        end

        local charId = GetCurrentCharacterId()

        if arg == "all" then
            for trialKey in pairs(self.Trials) do
                self:PrintTrialTimes(trialKey, charId)
            end
            return
        end

        local trialKey = string.upper(arg)
        if self.Trials[trialKey] then
            self:PrintTrialTimes(trialKey, charId)
        end
    end

    SLASH_COMMANDS["/fgg_nmkeyfarm"] = function(arg)
        arg = zo_strlower(tostring(arg or ""))
        if arg == "" then
            self:ToggleNMKeyFarmAutomation(nil)
        elseif arg == "on" then
            self:ToggleNMKeyFarmAutomation(true)
        elseif arg == "off" then
            self:ToggleNMKeyFarmAutomation(false)
        else
            self:ChatMsg("Usage: /fgg_nmkeyfarm [on|off]")
        end
    end


end
