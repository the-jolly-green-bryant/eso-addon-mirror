-----------------------------------------------------------
-- ArabicNumberMerge | API: 101049
-- Number display helper for Arabic / English digits
-----------------------------------------------------------
ArabicNumberMerge = {
    name = "ArabicNumberMerge",
    version = "1.2.0",
    defaults = {
        enabled = true,
        mode = "en", -- en = Western digits, ar = Arabic-Indic digits
    },
}

local EM = EVENT_MANAGER

local toEnglish = {
    ["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4",
    ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9",
    ["۰"]="0", ["۱"]="1", ["۲"]="2", ["۳"]="3", ["۴"]="4",
    ["۵"]="5", ["۶"]="6", ["۷"]="7", ["۸"]="8", ["۹"]="9",
}

local toArabic = {
    ["0"]="٠", ["1"]="١", ["2"]="٢", ["3"]="٣", ["4"]="٤",
    ["5"]="٥", ["6"]="٦", ["7"]="٧", ["8"]="٨", ["9"]="٩",
}

local function ConvertByMap(text, map)
    if type(text) ~= "string" or text == "" then return text end
    return (text:gsub("[%z\1-\127\194-\244][\128-\191]*", function(ch)
        return map[ch] or ch
    end))
end

function ArabicNumberMerge:ToEnglishDigits(text)
    return ConvertByMap(text, toEnglish)
end

function ArabicNumberMerge:ToArabicDigits(text)
    return ConvertByMap(text, toArabic)
end

function ArabicNumberMerge:ConvertDigits(text)
    if not self.saved or not self.saved.enabled then
        return text
    end
    if self.saved.mode == "ar" then
        return self:ToArabicDigits(text)
    end
    return self:ToEnglishDigits(text)
end

function ArabicNumberMerge:Log(msg)
    local s = string.format("|c66CCFF[%s]|r %s", self.name, tostring(msg))
    if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage(s) else d(s) end
end

function ArabicNumberMerge:GetModeLabel()
    if not self.saved or not self.saved.enabled then
        return "off"
    end
    return self.saved.mode or "en"
end

function ArabicNumberMerge:SetMode(mode)
    mode = zo_strlower(tostring(mode or ""))

    if mode == "off" or mode == "no" then
        self.saved.enabled = false
        self:Log("Number conversion: off")
        return
    end

    if mode ~= "en" and mode ~= "ar" then
        self:Log("Usage: /numlang en | ar | off")
        return
    end

    self.saved.enabled = true
    self.saved.mode = mode
    self:Log("Number conversion: " .. mode)
end

function ArabicNumberMerge:RegisterSettingsMenu()
    local LAM = LibStub and LibStub("LibAddonMenu-2.0", true)
    if not LAM then
        self:Log("Settings menu unavailable: LibAddonMenu-2.0 not loaded.")
        return
    end

    local panelData = {
        type = "panel",
        name = self.name,
        displayName = "Arabic Number Merge",
        author = "You",
        version = self.version,
        slashCommand = "/numsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local choices = {"English", "Arabic", "Off"}
    local choiceToMode = {
        English = "en",
        Arabic = "ar",
        Off = "off",
    }
    local modeToChoice = {
        en = "English",
        ar = "Arabic",
        off = "Off",
    }

    local optionsTable = {
        {
            type = "header",
            name = "Number Mode",
            width = "full",
        },
        {
            type = "description",
            text = "Choose how numbers should appear: English digits, Arabic digits, or Off.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Digits",
            tooltip = "Switch between English numbers, Arabic numbers, or disable conversion.",
            choices = choices,
            getFunc = function()
                return modeToChoice[self:GetModeLabel()] or "English"
            end,
            setFunc = function(choice)
                self:SetMode(choiceToMode[choice])
            end,
            width = "half",
            warning = "May require reopening UI elements to see all changes.",
        },
        {
            type = "button",
            name = "Show Status",
            tooltip = "Print the current number mode in chat.",
            func = function()
                self:Log("Number conversion mode: " .. self:GetModeLabel())
            end,
            width = "half",
        },
    }

    LAM:RegisterAddonPanel(self.name, panelData)
    LAM:RegisterOptionControls(self.name, optionsTable)
end

local function SlashConvert(arg)
    if not ArabicNumberMerge.saved or not ArabicNumberMerge.saved.enabled then
        ArabicNumberMerge:Log("Disabled. Use /numlang en, /numlang ar, or /numlang off.")
        return
    end
    arg = arg or ""
    ArabicNumberMerge:Log(ArabicNumberMerge:ConvertDigits(arg))
end

local function SlashTest()
    local sample = "Test: 1234567890 + ١٢٣٤٥٦٧٨٩٠ + ۱۲۳۴۵۶۷۸۹۰"
    ArabicNumberMerge:Log("Mode: " .. ArabicNumberMerge:GetModeLabel())
    ArabicNumberMerge:Log("IN : " .. sample)
    ArabicNumberMerge:Log("OUT: " .. ArabicNumberMerge:ConvertDigits(sample))
end

local function SlashMode(arg)
    ArabicNumberMerge:SetMode(arg)
end

local function SlashStatus()
    ArabicNumberMerge:Log("Number conversion mode: " .. ArabicNumberMerge:GetModeLabel())
end

local function SlashOn()
    ArabicNumberMerge:SetMode("en")
end

local function SlashOff()
    ArabicNumberMerge:SetMode("off")
end

function ArabicNumberMerge:OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= self.name then return end
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self.saved = ZO_SavedVars:NewAccountWide("ArabicNumberMergeSaved", 1, nil, self.defaults)
    if self.saved.mode ~= "en" and self.saved.mode ~= "ar" then
        self.saved.mode = "en"
    end

    SLASH_COMMANDS["/num"] = SlashConvert
    SLASH_COMMANDS["/numtest"] = SlashTest
    SLASH_COMMANDS["/numlang"] = SlashMode
    SLASH_COMMANDS["/numstatus"] = SlashStatus
    SLASH_COMMANDS["/numsettings"] = function() end
    SLASH_COMMANDS["/numon"] = SlashOn
    SLASH_COMMANDS["/numoff"] = SlashOff

    self:RegisterSettingsMenu()
    self:Log("Loaded v" .. self.version .. " | open Settings > Addons > Arabic Number Merge")
end

EM:RegisterForEvent(ArabicNumberMerge.name, EVENT_ADD_ON_LOADED, function(...) ArabicNumberMerge:OnAddOnLoaded(...) end)
