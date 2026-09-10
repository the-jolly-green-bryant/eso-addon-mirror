PoppysHardmodeReminder = {}
local addon = PoppysHardmodeReminder
local window
local generation = 0

function addon.ShowWarning()
    if not window then
        window = WINDOW_MANAGER:CreateTopLevelWindow("PoppysHardmodeReminderWarning")
        window:SetDimensions(900, 200)
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        window:SetMouseEnabled(false)
        window:SetDrawTier(DT_HIGH)

        local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
        title:SetDimensions(900, 90)
        title:SetAnchor(TOP, window, TOP, 0, 0)
        title:SetFont("$(BOLD_FONT)|64|thick-outline")
        title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        title:SetColor(1, 0.25, 0.1, 1)
        title:SetText("! HARDMODE !")

        local subtitle = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
        subtitle:SetDimensions(900, 70)
        subtitle:SetAnchor(TOP, title, BOTTOM, 0, 8)
        subtitle:SetFont("$(BOLD_FONT)|40|thick-outline")
        subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        subtitle:SetColor(1, 0.85, 0.2, 1)
        subtitle:SetText("POPPY. DO THE THING.")
    end

    window:SetHidden(false)
    if SOUNDS and SOUNDS.GENERAL_ALERT_ERROR then
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
    -- A repeated test gets a full five seconds; older timers cannot hide it.
    generation = generation + 1
    local thisGeneration = generation
    zo_callLater(function()
        if generation == thisGeneration then
            window:SetHidden(true)
        end
    end, 5000)
end
