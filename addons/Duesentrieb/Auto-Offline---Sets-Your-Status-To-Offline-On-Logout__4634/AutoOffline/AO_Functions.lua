local AO = AutoOffline

---------------------------------------------------------------------------
-- LOGOUT
---------------------------------------------------------------------------
function AO.OnLogout()
    if AO.SV.enableAddon and AO.SV.enableOnLogout then
        SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
    end
    return false
end

---------------------------------------------------------------------------
-- DIALOG
---------------------------------------------------------------------------
function AO.RegisterDialog()
    ZO_Dialogs_RegisterCustomDialog("AUTOOFFLINE_LOGIN_PROMPT", {
        customControl = nil,
        title = { text = "|cFF7F00Auto|r |cFFFFFFOffline|r" },
        mainText = { text = "Currently Offline. Change status to Online?\nAsk again: [<<1>>]", align = TEXT_ALIGN_CENTER, },
        buttons = {
            [1] = {
                text = "|c00FF00Online|r", keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    SelectPlayerStatus(PLAYER_STATUS_ONLINE)
                    d(string.format("%s Status changed to |c00FF00Online!|r", AO.CHAT))
                end,
            },
            [2] = {
                text = "|cFF0000Offline|r", keybind = "DIALOG_NEGATIVE",
            }
        }
    })
end

---------------------------------------------------------------------------
-- DELAYED CHECK
---------------------------------------------------------------------------
function AO.CheckStatusDelayed()
    if not AO.SV.enableAddon or AO.SV.promptFrequency == "Disabled" then return end

    if GetPlayerStatus() == PLAYER_STATUS_OFFLINE then
        if IsUnitInCombat("player") then
            zo_callLater(AO.CheckStatusDelayed, 10000)
            return
        end

        local currentTime = GetTimeStamp()
        local currentDate = GetDateStringFromTimestamp(currentTime)
        local showDialog = false

        if AO.SV.promptFrequency == "On Every Login" then
            showDialog = true
        elseif AO.SV.promptFrequency == "Once Per Hour On Login" or AO.SV.promptFrequency == "Every Hour" then
            if (currentTime - AO.SV.lastPromptTime) >= 3600 then
                showDialog = true
            end
        elseif AO.SV.promptFrequency == "Once Per Day On Login" then
            if AO.SV.lastPromptDate ~= currentDate then
                showDialog = true
            end
        end

        if showDialog then
            AO.SV.lastPromptTime = currentTime
            AO.SV.lastPromptDate = currentDate
            ZO_Dialogs_ShowDialog("AUTOOFFLINE_LOGIN_PROMPT", nil, {mainTextParams = {AO.SV.promptFrequency}})
        end
    end
end

---------------------------------------------------------------------------
-- PLAYER ACTIVATED
---------------------------------------------------------------------------
function AO.OnPlayerActivated()
    if not AO.SV.enableAddon then return end

    if not AO.isLogin then
        AO.isLogin = true

        EVENT_MANAGER:UnregisterForUpdate(AO.NAME .. "HOURLY_CHECK")
        if AO.SV.promptFrequency == "Every Hour" then
            EVENT_MANAGER:RegisterForUpdate(AO.NAME .. "HOURLY_CHECK", 3600000, AO.CheckStatusDelayed)
        end

        zo_callLater(AO.CheckStatusDelayed, AO.SV.delayPromt)
    end
end