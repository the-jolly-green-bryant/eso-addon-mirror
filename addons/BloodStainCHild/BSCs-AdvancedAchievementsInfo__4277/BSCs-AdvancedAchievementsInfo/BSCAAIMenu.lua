BSCAAchievemntsInfo = BSCAAchievemntsInfo or {}
local BSCAAI = BSCAAchievemntsInfo

local optionsTable = {}

local DEFAULT_TRACKING_FONT_SIZE = 18
local MIN_TRACKING_FONT_SIZE = 12
local MAX_TRACKING_FONT_SIZE = 54

local function GetValidTrackingFontSize(value)
    value = math.floor(zo_clamp(tonumber(value) or DEFAULT_TRACKING_FONT_SIZE, MIN_TRACKING_FONT_SIZE, MAX_TRACKING_FONT_SIZE) + 0.5)

    if BSCAAI.FontCheck then
        return BSCAAI.FontCheck(value)
    end

    return value
end

local function QueueFavWidgetUpdate(delay)
    if BSCAAI.QueueFavWidgetUpdate then
        BSCAAI.QueueFavWidgetUpdate(delay or 1)
    elseif BSCAAI.UpdateFavWidget then
        BSCAAI.UpdateFavWidget()
    end
end

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
            local function PrefillMail()
                ZO_MailSendToField:SetText(BSCAAI.Author)
                ZO_MailSendSubjectField:SetText(BSCAAI.NameSpaced)
                ZO_MailSendBodyField:TakeFocus()
            end
            SCENE_MANAGER:Show("mailSend")
            zo_callLater(PrefillMail, 250)
        end,
        width = "half",
        warning = "",
    })
end

local function AddSettings()
    table.insert(optionsTable, {
        type = "header",
        name = "Tracking UI",
    })
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Tracking UI",
        getFunc = function() return BSCAAI.SV_CHAR.UI_ENABLE end,
        setFunc = function(value)
            if BSCAAI.SetTrackingWindowEnabled then
                BSCAAI:SetTrackingWindowEnabled(value)
            else
                BSCAAI.SV_CHAR.UI_ENABLE = value
                BSCAAI:UpdateSettings()
                QueueFavWidgetUpdate(1)
            end
        end,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Hide Completed Criteria",
        tooltip = "Hide completed criterion lines in the tracking UI.",
        getFunc = function()
            return BSCAAI.SV_CHAR.UI_HIDE_COMPLETED_CRITERIA ~= false
        end,
        setFunc = function(value)
            BSCAAI.SV_CHAR.UI_HIDE_COMPLETED_CRITERIA = value and true or false
            QueueFavWidgetUpdate(1)
        end,
        default = true,
    })

    table.insert(optionsTable, {
        type = "slider",
        name = "Tracking UI Font Size",
        tooltip = "Adjust the font size used by the tracking UI.",
        min = MIN_TRACKING_FONT_SIZE,
        max = MAX_TRACKING_FONT_SIZE,
        step = 1,
        getFunc = function()
            return GetValidTrackingFontSize(BSCAAI.SV_CHAR.UI_FONT_SIZE)
        end,
        setFunc = function(value)
            BSCAAI.SV_CHAR.UI_FONT_SIZE = GetValidTrackingFontSize(value)
            BSCAAI._trackingFonts = nil

            if BSCAAI.AdjustTrackingLayout then
                BSCAAI:AdjustTrackingLayout()
            end

            QueueFavWidgetUpdate(1)
        end,
        default = DEFAULT_TRACKING_FONT_SIZE,
    })
end

function BSCAAI:InitMenu()
    if not LibAddonMenu2 then return end

    local panelData = {
        type = "panel",
        name = BSCAAI.Name,
        displayName = BSCAAI.NameSpaced,
        author = BSCAAI.Author,
        version = BSCAAI.VersionDisplay,
        registerForRefresh = true,
    }

    AddSendFeedBack()
    AddSettings()

    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCAAI.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCAAI.NameSpaced, optionsTable)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel)
        if addonpanel ~= currentpanel then return end
        BSCAAI._menuPanelOpen = true
        BSCAAI_FavWidget:SetHidden(false)
        QueueFavWidgetUpdate(1)
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel)
        if addonpanel ~= currentpanel then return end
        BSCAAI._menuPanelOpen = false

        if BSCAAI.SV_CHAR.UI_ENABLE then
            QueueFavWidgetUpdate(1)
        else
            BSCAAI_FavWidget:SetHidden(true)
        end
    end)
end
