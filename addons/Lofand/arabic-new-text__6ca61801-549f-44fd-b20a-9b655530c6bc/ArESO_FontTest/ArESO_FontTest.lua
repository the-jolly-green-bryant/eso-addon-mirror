local FONT_PATH = "ArESO_FontTest/fonts/ArESO_Arabic.slug"

-- Pre-shaped visual-order Arabic (presentation forms), generated at build time.
local SALAM   = "ﻡﻼﺳ"                     -- سلام
local WELCOME = "ﺔﺒﻌﻠﻟﺍ ﻞﺧﺍﺩ ﻞﻤﻌﻳ ﺐﻳﺮﻌﺘﻟﺍ"  -- التعريب يعمل داخل اللعبة
local MIXED   = "Salaam (" .. SALAM .. ")"
local NPCDEMO = "Chamberlain Weller (" .. "ﺮﻠﻳﻭ ﺐﺟﺎﺤﻟﺍ" .. ")"

local function RunTest()
    local FONT = FONT_PATH .. "|24|soft-shadow-thin"

    -- (a) label with per-control font: custom font loads, PF codepoints render
    local tlw = ArESO_FontTestTLW
    if tlw == nil then
        tlw = WINDOW_MANAGER:CreateTopLevelWindow("ArESO_FontTestTLW")
        tlw:SetDimensions(700, 120)
        tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, -250)
        tlw:SetMouseEnabled(true)
        tlw:SetMovable(true)

        local bg = WINDOW_MANAGER:CreateControl("ArESO_FontTestBG", tlw, CT_BACKDROP)
        bg:SetAnchorFill(tlw)
        bg:SetCenterColor(0, 0, 0, 0.7)
        bg:SetEdgeColor(1, 0.84, 0, 1)
        bg:SetEdgeTexture("", 1, 1, 1)

        local label = WINDOW_MANAGER:CreateControl("ArESO_FontTestLabel", tlw, CT_LABEL)
        label:SetAnchor(TOP, tlw, TOP, 0, 12)
        label:SetFont(FONT)
        label:SetText(MIXED)

        local label2 = WINDOW_MANAGER:CreateControl("ArESO_FontTestLabel2", tlw, CT_LABEL)
        label2:SetAnchor(TOP, label, BOTTOM, 0, 8)
        label2:SetFont(FONT)
        label2:SetText(NPCDEMO)

        local label3 = WINDOW_MANAGER:CreateControl("ArESO_FontTestLabel3", tlw, CT_LABEL)
        label3:SetAnchor(TOP, label2, BOTTOM, 0, 8)
        label3:SetFont(FONT)
        label3:SetText(WELCOME)
    end
    tlw:SetHidden(false)

    -- (b) chat: repoint chat font objects, then print
    local chatFont = FONT_PATH .. "|$(KB_15)|soft-shadow-thin"
    if ZoFontChat then ZoFontChat:SetFont(chatFont) end
    if ZoFontEditChat then ZoFontEditChat:SetFont(chatFont) end
    if CHAT_SYSTEM and CHAT_SYSTEM.containers then
        for _, container in pairs(CHAT_SYSTEM.containers) do
            for _, window in ipairs(container.windows or {}) do
                if window.buffer then window.buffer:SetFont(chatFont) end
            end
        end
    end
    CHAT_ROUTER:AddSystemMessage("ArESO chat test: " .. MIXED)

    -- (c) tooltips: override all ZoFont* objects, swap the item-name format
    for key, value in zo_insecurePairs(_G) do
        if type(key) == "string" and key:find("^ZoFont") and type(value) == "userdata" and value.SetFont then
            value:SetFont(FONT_PATH .. "|$(KB_18)|soft-shadow-thin")
        end
    end
    SafeAddString(SI_TOOLTIP_ITEM_NAME, "<<1>> (" .. SALAM .. ")", 10)
    CHAT_ROUTER:AddSystemMessage("ArESO: now hover any inventory item — its name should end with (" .. SALAM .. "). /reloadui reverts everything.")
end

SLASH_COMMANDS["/aresotest"] = RunTest

EVENT_MANAGER:RegisterForEvent("ArESO_FontTest", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent("ArESO_FontTest", EVENT_PLAYER_ACTIVATED)
    d("|cFFD700ArESO Font Test|r loaded — type /aresotest")
end)
