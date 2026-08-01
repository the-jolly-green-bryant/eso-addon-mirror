function OsseinAssist.PrintDevCommandHelp()
    d("Ossein Assist commands:")
    d("/ossein panel on|off")
    d("/ossein fake on|off")
    d("/ossein titan on|off|report|fights|reset|fake on|off  (tracks 7 titan damage skills)")
    d("/ossein searing on|off|status  (dev-only cast logger)")
    d("/ossein status")
    d("/ossein heatray ...  (legacy alias for /ossein titan)")
    d("/ossein show")
    d("/ossein settings")
    d("/ossein hp  (print target/reticle health debug)")
end

function OsseinAssist.PrintUnitTagHealthDebug(unitTag)
    local unitName = GetUnitName(unitTag)
    local exists = type(DoesUnitExist) ~= "function" or DoesUnitExist(unitTag)
    local hpTypeA = COMBAT_MECHANIC_FLAGS_HEALTH or POWERTYPE_HEALTH
    local curA, maxA = GetUnitPower(unitTag, hpTypeA)
    local curB, maxB = 0, 0
    if POWERTYPE_HEALTH ~= nil then
        curB, maxB = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    end
    local pct = nil
    if type(OsseinAssist.GetUnitTagHealthPercent) == "function" then
        pct = OsseinAssist.GetUnitTagHealthPercent(unitTag)
    end

    d(string.format(
        "Ossein Assist: [HP] %s exists=%s name=%s A(%s): %s/%s B(POWERTYPE_HEALTH): %s/%s pct=%s",
        tostring(unitTag),
        tostring(exists),
        tostring(unitName ~= "" and unitName or "<empty>"),
        tostring(hpTypeA),
        tostring(curA),
        tostring(maxA),
        tostring(curB),
        tostring(maxB),
        pct ~= nil and string.format("%.1f%%", pct) or "nil"
    ))
end

function OsseinAssist.PrintLocalHealthDebug()
    d("Ossein Assist: [HP] local health debug")
    OsseinAssist.PrintUnitTagHealthDebug("target")
    OsseinAssist.PrintUnitTagHealthDebug("reticleover")
end

function OsseinAssist.PrintStatus()
    d("Ossein Assist status:")
    d(string.format(" - Health panel: %s", OsseinAssist.healthPanelEnabled and "on" or "off"))
    d(string.format(" - Titan health tracker: %s", OsseinAssist.titanHealthLoggingEnabled and "on" or "off"))
    d(string.format(" - Heavy timer: %s", OsseinAssist.enableBashVisuals and "on" or "off"))
    d(string.format(" - Heavy start sound: %s", OsseinAssist.playHeavyStartSound and "on" or "off"))
    d(string.format(" - Searing assignment: %s", tostring(OsseinAssist.searingAssignment or "Not Assigned")))
    d(string.format(" - Searing logger: %s", OsseinAssist.searingCastLoggingEnabled and "on" or "off"))
    d(string.format(" - Boss health chat logs: %s", OsseinAssist.bossHealthChatLoggingEnabled and "on" or "off"))
    d(string.format(" - Titan health chat logs: %s", OsseinAssist.titanHealthChatLoggingEnabled and "on" or "off"))
    d(string.format(" - Aspect heavy chat logs: %s", OsseinAssist.aspectHeavyChatLoggingEnabled and "on" or "off"))
    d(string.format(" - Searing mechanic chat logs: %s", OsseinAssist.searingMechanicChatLoggingEnabled and "on" or "off"))
    if type(OsseinAssist.ShouldTrackSearingCombatEvents) == "function" then
        d(string.format(" - Searing event tracking active: %s", OsseinAssist.ShouldTrackSearingCombatEvents() and "yes" or "no"))
    end
end

function OsseinAssist.OnSlashCommand(args)
    local input = string.lower(zo_strtrim(args or ""))
    if input == "" or input == "help" then
        OsseinAssist.PrintDevCommandHelp()
        return
    end
    if input == "status" then
        OsseinAssist.PrintStatus()
        return
    end

    if input == "show" then
        OsseinAssist.SetHealthPanelEnabled(true)
        return
    end
    if input == "hp" then
        OsseinAssist.PrintLocalHealthDebug()
        return
    end
    if input == "settings" then
        OsseinAssist.OpenSettingsPanel()
        return
    end

    local command, option, extra = string.match(input, "^(%S+)%s+(%S+)%s*(%S*)$")
    if command == "panel" then
        if option == "on" then
            OsseinAssist.SetHealthPanelEnabled(true)
            return
        end
        if option == "off" then
            OsseinAssist.SetHealthPanelEnabled(false)
            return
        end
    elseif command == "fake" then
        if option == "on" then
            OsseinAssist.SetHealthPanelFakeModeEnabled(true)
            return
        end
        if option == "off" then
            OsseinAssist.SetHealthPanelFakeModeEnabled(false)
            return
        end
    elseif command == "titan" or command == "heatray" then
        if option == "on" then
            OsseinAssist.SetTitanHealthLoggingEnabled(true)
            return
        end
        if option == "off" then
            OsseinAssist.SetTitanHealthLoggingEnabled(false)
            return
        end
        if option == "report" then
            OsseinAssist.PrintTitanHealthStats()
            return
        end
        if option == "fights" then
            OsseinAssist.PrintTitanFightLogs()
            return
        end
        if option == "reset" then
            OsseinAssist.ResetTitanHealthStats()
            return
        end
        if option == "fake" and extra == "on" then
            if not OsseinAssist.IsDevUser() then
                d("Ossein Assist: titan fake data is developer-only.")
                return
            end
            OsseinAssist.SetTitanHealthFakeDataEnabled(true)
            return
        end
        if option == "fake" and extra == "off" then
            if not OsseinAssist.IsDevUser() then
                d("Ossein Assist: titan fake data is developer-only.")
                return
            end
            OsseinAssist.SetTitanHealthFakeDataEnabled(false)
            return
        end
    elseif command == "searing" then
        if not OsseinAssist.IsDevUser() then
            d("Ossein Assist: searing cast logger is developer-only.")
            return
        end
        if option == "on" then
            OsseinAssist.SetSearingCastLoggingEnabled(true)
            return
        end
        if option == "off" then
            OsseinAssist.SetSearingCastLoggingEnabled(false)
            return
        end
        if option == "status" then
            d(string.format(
                "Ossein Assist: searing cast logger is %s.",
                OsseinAssist.searingCastLoggingEnabled and "enabled" or "disabled"
            ))
            return
        end
    end

    OsseinAssist.PrintDevCommandHelp()
end
