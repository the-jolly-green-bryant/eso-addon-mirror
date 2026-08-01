LvxJournal = LvxJournal or {}
LvxJournal.Tools = LvxJournal.Tools or {}

local Tools = LvxJournal.Tools

local function Chat(message)
    if d then d("|cC79A4BLvx Journal:|r " .. tostring(message or "")) end
end

local function GetStamp()
    if GetTimeStamp then return GetTimeStamp() end
    return 0
end

local function GetPlayer()
    if GetUnitName then return GetUnitName("player") or "Unknown Character" end
    return "Unknown Character"
end

local function GetZone()
    if GetUnitZone then return GetUnitZone("player") or "Unknown Zone" end
    if GetMapName then return GetMapName() or "Unknown Zone" end
    return "Unknown Zone"
end

local function RandomIndex(count)
    if not count or count <= 1 then return 1 end
    if math and math.random then return math.random(1, count) end
    return 1
end

local function SetToolResultStyle(font, color, align)
    if not LvxJournal.toolsResultLabel then return end
    LvxJournal.toolsResultLabel:SetFont(font or "ZoFontBookPaper")
    if color then
        LvxJournal.toolsResultLabel:SetColor(color[1], color[2], color[3], color[4] or 1)
    else
        LvxJournal.toolsResultLabel:SetColor(0.16, 0.075, 0.018, 1)
    end
    if align and LvxJournal.toolsResultLabel.SetHorizontalAlignment then
        LvxJournal.toolsResultLabel:SetHorizontalAlignment(align)
    end
end

local function SetResult(title, body, texture, font, color, align)
    if LvxJournal.toolsTitle then LvxJournal.toolsTitle:SetText(title or "Tools") end
    if LvxJournal.toolsResultLabel then
        SetToolResultStyle(font, color, align)
        LvxJournal.toolsResultLabel:SetText(body or "")
    end
    if LvxJournal.toolsIcon and texture then LvxJournal.toolsIcon:SetTexture(texture) end
end

local function ConfigureButton(btn, text, callback, hidden, tooltip)
    if not btn then return end
    btn:SetHidden(hidden == true)
    btn:SetText(text or "")
    if btn.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    btn:SetHandler("OnClicked", callback or function() end)
    if SetJournalTooltip and GetJournalTooltipText then
        SetJournalTooltip(btn, tooltip or GetJournalTooltipText(text or ""))
    end
end

local oracleOpenTexture = "LvxJournal/ui/tools/oracle_eye.dds"
local oracleClosedTexture = "LvxJournal/ui/tools/oracle_eye_closed.dds"
local oracleTexture = oracleOpenTexture
local diceTexture = "LvxJournal/ui/tools/dice_bubble.dds"
local dieTextures = {
    [4] = "LvxJournal/ui/tools/die_d4.dds",
    [6] = "LvxJournal/ui/tools/die_d6.dds",
    [8] = "LvxJournal/ui/tools/die_d8.dds",
    [10] = "LvxJournal/ui/tools/die_d10.dds",
    [12] = "LvxJournal/ui/tools/die_d12.dds",
    [20] = "LvxJournal/ui/tools/die_d20.dds",
    [100] = "LvxJournal/ui/tools/die_d10.dds",
}
local dieAnimationProfiles = {
    [4] = { sizes = {148, 164, 182, 156, 172, 170}, offsets = { {-4,4}, {5,-6}, {-3,-4}, {4,5}, {-2,-3}, {0,0} } },
    [6] = { sizes = {154, 176, 160, 184, 166, 170}, offsets = { {-5,3}, {5,-5}, {-4,-4}, {4,5}, {-2,-2}, {0,0} } },
    [8] = { sizes = {150, 170, 186, 162, 174, 170}, offsets = { {-4,5}, {4,-5}, {-5,-3}, {4,4}, {-2,-2}, {0,0} } },
    [10] = { sizes = {146, 164, 180, 158, 172, 170}, offsets = { {-3,4}, {4,-6}, {-4,-4}, {5,4}, {-2,-1}, {0,0} } },
    [12] = { sizes = {152, 174, 188, 164, 176, 170}, offsets = { {-5,4}, {5,-4}, {-4,-5}, {4,4}, {-1,-2}, {0,0} } },
    [20] = { sizes = {148, 166, 184, 160, 176, 170}, offsets = { {-4,4}, {5,-5}, {-3,-4}, {4,4}, {-2,-2}, {0,0} } },
    [100] = { sizes = {146, 162, 178, 156, 170, 170}, offsets = { {-3,4}, {4,-5}, {-4,-4}, {4,4}, {-2,-2}, {0,0} } },
}
local destTexture = "LvxJournal/ui/tools/destination_bubble.dds"
local activityTexture = "LvxJournal/ui/tools/activity_bubble.dds"
local dailyTexture = "LvxJournal/ui/tools/daily_bubble.dds"
local exportTexture = "LvxJournal/ui/tools/export_bubble.dds"
local mapMarkTexture = "LvxJournal/ui/map/journal_map_pin.dds"
local coinHeadsTexture = "LvxJournal/ui/tools/coin_heads.dds"
local coinTailsTexture = "LvxJournal/ui/tools/coin_tails.dds"


local function ClearToolButtons()
    for i = 1, 10 do
        local btn = LvxJournal["toolButton" .. i]
        ConfigureButton(btn, "", nil, true)
    end
end

local function ShowToolButtons(definitions)
    ClearToolButtons()
    for i = 1, #definitions do
        local def = definitions[i]
        ConfigureButton(LvxJournal["toolButton" .. i], def.text, def.callback, false, def.tooltip)
    end
end

local function HideDiceNumberLabel()
    if LvxJournal.diceNumberLabel then
        LvxJournal.diceNumberLabel:SetHidden(true)
    end
end

local function EnsureDiceNumberLabel()
    if LvxJournal.diceNumberLabel then return LvxJournal.diceNumberLabel end
    if not LvxJournal.toolsIcon then return nil end

    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return nil end

    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 710, 270)
    label:SetDimensions(360, 72)
    label:SetFont("ZoFontWinH1")
    label:SetColor(0.70, 0.16, 0.02, 1)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHidden(true)

    LvxJournal.diceNumberLabel = label
    if LvxJournal.toolsControls then
        table.insert(LvxJournal.toolsControls, label)
    end
    return label
end

local function SetDiceNumberText(text)
    local label = EnsureDiceNumberLabel()
    if not label then return end

    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, label:GetParent(), TOPLEFT, 710, 270)
    label:SetDimensions(360, 72)
    label:SetText(tostring(text or ""))
    label:SetHidden(false)
end

local function ApplyDefaultToolButtonLayout()
    for i = 1, 10 do
        local btn = LvxJournal["toolButton" .. i]
        if btn then
            btn:ClearAnchors()
            btn:SetAnchor(TOPLEFT, btn:GetParent(), TOPLEFT, 710, 320 + ((i - 1) * 31))
        end
    end
end

local function ApplyOracleToolButtonLayout()
    ApplyDefaultToolButtonLayout()
    local btn = LvxJournal.toolButton1
    if btn then
        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, btn:GetParent(), TOPLEFT, 810, 505)
    end
end

local function ApplyCoinToolButtonLayout()
    ApplyDefaultToolButtonLayout()
    local btn = LvxJournal.toolButton1
    if btn then
        btn:ClearAnchors()
        btn:SetAnchor(TOPLEFT, btn:GetParent(), TOPLEFT, 760, 305)
        btn:SetDimensions(170, 28)
    end
end

local function SetMapMarkManagerInputsHidden(hidden)
    if LvxJournal.mapMarkNameLabel then LvxJournal.mapMarkNameLabel:SetHidden(hidden) end
    if LvxJournal.mapMarkNameBackdrop then LvxJournal.mapMarkNameBackdrop:SetHidden(hidden) end
    if LvxJournal.mapMarkNameBox then LvxJournal.mapMarkNameBox:SetHidden(hidden) end
    if LvxJournal.mapMarkNameHelp then LvxJournal.mapMarkNameHelp:SetHidden(hidden) end
end

local function ApplyDefaultToolLayout()
    if not LvxJournal.toolsIcon or not LvxJournal.toolsResultLabel then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    SetMapMarkManagerInputsHidden(true)
    HideDiceNumberLabel()
    ApplyDefaultToolButtonLayout()

    LvxJournal.toolsIcon:ClearAnchors()
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 710, 165)
    LvxJournal.toolsIcon:SetDimensions(128, 128)

    LvxJournal.toolsResultLabel:ClearAnchors()
    LvxJournal.toolsResultLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 840, 165)
    LvxJournal.toolsResultLabel:SetDimensions(270, 300)
    SetToolResultStyle("ZoFontWinH4", {0.16, 0.075, 0.018, 1})
end

local SetOracleEyeState

local function ApplyOracleToolLayout()
    if not LvxJournal.toolsIcon or not LvxJournal.toolsResultLabel then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    HideDiceNumberLabel()
    ApplyOracleToolButtonLayout()

    LvxJournal.toolsResultLabel:ClearAnchors()
    LvxJournal.toolsResultLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 770, 210)
    LvxJournal.toolsResultLabel:SetDimensions(340, 145)
    SetToolResultStyle("ZoFontWinH4", {0.16, 0.075, 0.018, 1})

    LvxJournal.toolsIcon:ClearAnchors()
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 835, 325)
    LvxJournal.toolsIcon:SetDimensions(150, 150)
    SetOracleEyeState(Tools.oracleEyeState or "open")
end

SetOracleEyeState = function(state)
    if not LvxJournal.toolsIcon then return end
    if state == "closed" then
        LvxJournal.toolsIcon:SetTexture(oracleClosedTexture)
        Tools.oracleEyeState = "closed"
    else
        LvxJournal.toolsIcon:SetTexture(oracleOpenTexture)
        Tools.oracleEyeState = "open"
    end
end

local function AnimateOracleReveal(finalText)
    if not LvxJournal.toolsIcon or not zo_callLater then
        SetOracleEyeState("open")
        if LvxJournal.toolsResultLabel then
            LvxJournal.toolsResultLabel:SetText(finalText or "")
        end
        return
    end

    if Tools.oracleInProgress then return end
    Tools.oracleInProgress = true

    local parent = LvxJournal.toolsIcon:GetParent()
    local baseX, baseY, baseSize = 835, 325, 150
    local frames = {
        { state = "closed", delay = 140 },
        { state = "closed", delay = 260 },
        { state = "open", delay = 160 },
    }
    local step = 1

    local function advance()
        if not LvxJournal.toolsIcon then
            Tools.oracleInProgress = false
            return
        end

        local frame = frames[step] or frames[#frames]
        SetOracleEyeState(frame.state)
        LvxJournal.toolsIcon:ClearAnchors()
        LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX, baseY)
        LvxJournal.toolsIcon:SetDimensions(baseSize, baseSize)

        step = step + 1
        if step <= #frames then
            zo_callLater(advance, frame.delay or 150)
        else
            LvxJournal.toolsIcon:ClearAnchors()
            LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX, baseY)
            LvxJournal.toolsIcon:SetDimensions(baseSize, baseSize)
            SetOracleEyeState("open")
            if LvxJournal.toolsResultLabel then
                LvxJournal.toolsResultLabel:SetText(finalText or "")
            end
            Tools.oracleInProgress = false
        end
    end

    if LvxJournal.toolsResultLabel then
        LvxJournal.toolsResultLabel:SetText("Consulting the oracle...")
    end
    advance()
end

local function ApplyCoinToolLayout()
    if not LvxJournal.toolsIcon or not LvxJournal.toolsResultLabel then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    SetMapMarkManagerInputsHidden(true)
    HideDiceNumberLabel()
    ApplyCoinToolButtonLayout()

    LvxJournal.toolsResultLabel:ClearAnchors()
    LvxJournal.toolsResultLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 710, 165)
    LvxJournal.toolsResultLabel:SetDimensions(360, 125)
    SetToolResultStyle("ZoFontWinH4", {0.16, 0.075, 0.018, 1})

    LvxJournal.toolsIcon:ClearAnchors()
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 812, 340)
    LvxJournal.toolsIcon:SetDimensions(180, 180)
end

local function ApplyMapMarksToolLayout()
    if not LvxJournal.toolsIcon or not LvxJournal.toolsResultLabel then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    HideDiceNumberLabel()
    ApplyDefaultToolButtonLayout()

    LvxJournal.toolsIcon:ClearAnchors()
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 710, 184)
    LvxJournal.toolsIcon:SetDimensions(64, 64)

    LvxJournal.toolsResultLabel:ClearAnchors()
    LvxJournal.toolsResultLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 790, 165)
    LvxJournal.toolsResultLabel:SetDimensions(330, 245)
    SetToolResultStyle("ZoFontGame", {0.16, 0.075, 0.018, 1})

    local positions = {
        [1] = {710, 515, 118, 28},
        [2] = {840, 515, 118, 28},
        [3] = {970, 515, 118, 28},
        [4] = {710, 552, 118, 28},
        [5] = {840, 552, 118, 28},
        [6] = {970, 552, 118, 28},
    }

    for i = 1, 6 do
        local btn = LvxJournal["toolButton" .. i]
        local info = positions[i]
        if btn and info then
            btn:ClearAnchors()
            btn:SetAnchor(TOPLEFT, parent, TOPLEFT, info[1], info[2])
            btn:SetDimensions(info[3], info[4])
        end
    end
end

local function HideMapMarkPositionButtons()
    for i = 7, 10 do
        local btn = LvxJournal["toolButton" .. i]
        ConfigureButton(btn, "", nil, true)
    end
end

local function UpdateMapMarkPositionButtons()
    if not LvxJournal.toolsIcon then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    HideMapMarkPositionButtons()

    -- Pos zoom links line up with the blank line directly under each saved mark's Zone line.
    -- These buttons are left-aligned so the visible Pos text starts at the same X as the mark text.
    local startX = 790
    local startY = 395
    local rowStep = 100

    for slot = 1, 1 do
        local btn = LvxJournal["toolButton" .. (6 + slot)]
        local mark = nil
        if LvxJournal.GetMapMarkOnCurrentPage then
            mark = LvxJournal.GetMapMarkOnCurrentPage(slot)
        end

        if btn and mark then
            local posText = string.format("Pos: %.2f, %.2f", (tonumber(mark.x) or 0) * 100, (tonumber(mark.y) or 0) * 100)
            ConfigureButton(btn, posText, function()
                if LvxJournal.ZoomMapMarkOnCurrentPage then
                    LvxJournal.ZoomMapMarkOnCurrentPage(slot)
                end
            end, false)
            if btn.SetHorizontalAlignment and TEXT_ALIGN_LEFT then
                btn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            end
            btn:ClearAnchors()
            btn:SetAnchor(TOPLEFT, parent, TOPLEFT, startX, startY + ((slot - 1) * rowStep))
            btn:SetDimensions(230, 24)
        end
    end
end

local function ApplyDiceToolLayout()
    if not LvxJournal.toolsIcon or not LvxJournal.toolsResultLabel then return end
    local parent = LvxJournal.toolsIcon:GetParent()
    if not parent then return end

    EnsureDiceNumberLabel()
    HideDiceNumberLabel()

    LvxJournal.toolsResultLabel:ClearAnchors()
    LvxJournal.toolsResultLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 710, 165)
    LvxJournal.toolsResultLabel:SetDimensions(355, 95)
    SetToolResultStyle("ZoFontWinH4", {0.16, 0.075, 0.018, 1})

    LvxJournal.toolsIcon:ClearAnchors()
    LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 892, 350)
    LvxJournal.toolsIcon:SetDimensions(170, 170)
end

local function SetDieFace(sides)
    if not LvxJournal.toolsIcon then return end
    local dieSides = tonumber(sides) or 20
    local texture = dieTextures[dieSides] or dieTextures[20]
    LvxJournal.toolsIcon:SetTexture(texture)
    Tools.currentDieSides = dieSides
end

local function AnimateDieRoll(displayTitle, sides, finalText, bigResult)
    if not LvxJournal.toolsIcon or not zo_callLater then
        SetDieFace(sides)
        if LvxJournal.toolsTitle then LvxJournal.toolsTitle:SetText(displayTitle or "Dice") end
        if LvxJournal.toolsResultLabel then LvxJournal.toolsResultLabel:SetText(finalText or "") end
        if bigResult then SetDiceNumberText(bigResult) else HideDiceNumberLabel() end
        return
    end

    if Tools.dieRollInProgress then return end
    Tools.dieRollInProgress = true

    local parent = LvxJournal.toolsIcon:GetParent()
    local baseX, baseY, baseSize = 892, 350, 170
    local dieSides = tonumber(sides) or 20
    local profile = dieAnimationProfiles[dieSides] or dieAnimationProfiles[20]
    local sizes = profile.sizes or {150, 170, 186, 160, 174, 170}
    local offsets = profile.offsets or { {-4,4}, {4,-4}, {-3,-3}, {3,4}, {-1,-2}, {0,0} }
    local step = 1

    local function advance()
        if not LvxJournal.toolsIcon then
            Tools.dieRollInProgress = false
            return
        end

        local size = sizes[step] or baseSize
        local off = offsets[step] or {0, 0}
        SetDieFace(dieSides)
        LvxJournal.toolsIcon:ClearAnchors()
        LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX + math.floor((baseSize - size) / 2) + off[1], baseY + off[2])
        LvxJournal.toolsIcon:SetDimensions(size, size)

        step = step + 1
        if step <= #sizes then
            zo_callLater(advance, 60)
        else
            LvxJournal.toolsIcon:ClearAnchors()
            LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX, baseY)
            LvxJournal.toolsIcon:SetDimensions(baseSize, baseSize)
            SetDieFace(dieSides)
            if LvxJournal.toolsTitle then LvxJournal.toolsTitle:SetText(displayTitle or "Dice") end
            if LvxJournal.toolsResultLabel then LvxJournal.toolsResultLabel:SetText(finalText or "") end
            if bigResult then SetDiceNumberText(bigResult) else HideDiceNumberLabel() end
            Tools.dieRollInProgress = false
        end
    end

    HideDiceNumberLabel()
    if LvxJournal.toolsTitle then LvxJournal.toolsTitle:SetText(displayTitle or "Dice") end
    if LvxJournal.toolsResultLabel then
        LvxJournal.toolsResultLabel:SetText("Rolling d" .. tostring(dieSides or 20) .. "...")
    end
    advance()
end

local function SetCoinFace(face)
    if not LvxJournal.toolsIcon then return end
    if face == "tails" then
        LvxJournal.toolsIcon:SetTexture(coinTailsTexture)
        Tools.currentCoinFace = "tails"
    else
        LvxJournal.toolsIcon:SetTexture(coinHeadsTexture)
        Tools.currentCoinFace = "heads"
    end
end

local function AnimateCoinFlip(resultFace, finalText)
    if not LvxJournal.toolsIcon or not zo_callLater then
        SetCoinFace(resultFace)
        if LvxJournal.toolsResultLabel then
            LvxJournal.toolsResultLabel:SetText(finalText or "")
        end
        return
    end

    if Tools.coinFlipInProgress then return end
    Tools.coinFlipInProgress = true

    local parent = LvxJournal.toolsIcon:GetParent()
    local baseX, baseY, baseH = 812, 340, 180
    local widths = {180, 132, 90, 46, 16, 46, 90, 132, 180}
    local step = 1

    local function advance()
        if not LvxJournal.toolsIcon then
            Tools.coinFlipInProgress = false
            return
        end

        local width = widths[step]
        LvxJournal.toolsIcon:ClearAnchors()
        LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX + math.floor((180 - width) / 2), baseY)
        LvxJournal.toolsIcon:SetDimensions(width, baseH)

        if step == 5 then
            SetCoinFace(resultFace)
        end

        step = step + 1
        if step <= #widths then
            zo_callLater(advance, 45)
        else
            LvxJournal.toolsIcon:ClearAnchors()
            LvxJournal.toolsIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, baseX, baseY)
            LvxJournal.toolsIcon:SetDimensions(180, 180)
            if LvxJournal.toolsResultLabel then
                LvxJournal.toolsResultLabel:SetText(finalText or "")
            end
            Tools.coinFlipInProgress = false
        end
    end

    if LvxJournal.toolsResultLabel then
        LvxJournal.toolsResultLabel:SetText("Flipping coin...")
    end
    advance()
end

Tools.oracleResults = {
    "Yes",
    "No",
    "Yes, but there is a complication.",
    "No, but another path opens.",
    "The signs point to yes.",
    "The omens say no.",
    "Unclear. Ask again later.",
    "The answer is hidden for now.",
    "Fate favors action.",
    "Wait and watch for a better moment.",
}

Tools.zones = {
    "Auridon", "Grahtwood", "Greenshade", "Malabal Tor", "Reaper's March",
    "Glenumbra", "Stormhaven", "Rivenspire", "Alik'r Desert", "Bangkorai",
    "Stonefalls", "Deshaan", "Shadowfen", "Eastmarch", "The Rift",
    "Coldharbour", "Craglorn", "Wrothgar", "Hew's Bane", "Gold Coast",
    "Vvardenfell", "Clockwork City", "Summerset", "Murkmire", "Northern Elsweyr",
    "Southern Elsweyr", "Western Skyrim", "The Reach", "Blackwood", "Deadlands",
    "High Isle", "Galen", "Telvanni Peninsula", "Apocrypha", "West Weald",
}

Tools.activities = {
    "Complete a delve.",
    "Clear a world boss.",
    "Run a public dungeon.",
    "Do crafting writs.",
    "Run a random dungeon.",
    "Run a random battleground.",
    "Complete a zone daily.",
    "Gather crafting materials.",
    "Work on antiquities.",
    "Go fishing in the next zone.",
    "Complete one main quest step.",
    "Do an Undaunted pledge.",
}

Tools.dailyTasks = {
    "Crafting Writs",
    "Undaunted Pledges",
    "Random Dungeon",
    "Random Battleground",
    "Zone Daily",
    "World Boss / Delve Daily",
}

function Tools.RollOracle()
    if Tools.oracleInProgress then return end
    local result = Tools.oracleResults[RandomIndex(#Tools.oracleResults)]
    if LvxJournal.toolsTitle then
        LvxJournal.toolsTitle:SetText("Oracle")
    end
    AnimateOracleReveal("|c5A2015Oracle says:|r" .. "\n\n" .. "|c3B160C" .. result .. "|r")
end

function Tools.RollDie(sides)
    sides = tonumber(sides) or 20
    local roll = RandomIndex(sides)
    AnimateDieRoll("Dice", sides, "Rolled d" .. tostring(sides), tostring(roll))
end

function Tools.FlipCoin()
    if Tools.coinFlipInProgress then return end

    local resultFace = "heads"
    local resultText = "Heads"
    if RandomIndex(2) == 2 then
        resultFace = "tails"
        resultText = "Tails"
    end

    if LvxJournal.toolsTitle then
        LvxJournal.toolsTitle:SetText("Coin Toss")
    end
    AnimateCoinFlip(resultFace, "|c5A2015Coin toss:|r" .. "\n\n" .. "|c3B160C" .. resultText .. "|r")
end

function Tools.RollD100()
    local roll = RandomIndex(100)
    AnimateDieRoll("Dice", 100, "Rolled d100", tostring(roll))
end

function Tools.RollAdvantage()
    local a = RandomIndex(20)
    local b = RandomIndex(20)
    local keep = math.max(a, b)
    AnimateDieRoll("Advantage d20", 20, "Rolls: " .. tostring(a) .. " and " .. tostring(b) .. "\nKept highest", tostring(keep))
end

function Tools.RollDisadvantage()
    local a = RandomIndex(20)
    local b = RandomIndex(20)
    local keep = math.min(a, b)
    AnimateDieRoll("Disadvantage d20", 20, "Rolls: " .. tostring(a) .. " and " .. tostring(b) .. "\nKept lowest", tostring(keep))
end

function Tools.RollPercentChance(chance)
    chance = tonumber(chance) or 50
    if chance < 1 then chance = 1 end
    if chance > 100 then chance = 100 end
    local roll = RandomIndex(100)
    local result = roll <= chance and "Success" or "Failure"
    AnimateDieRoll("Percent Chance", 100, tostring(chance) .. "% chance\nRolled: " .. tostring(roll), result == "Success" and "|c2F5F1ESuccess|r" or "|c6A1D14Failure|r")
end

function Tools.RollDestination()
    local zone = Tools.zones[RandomIndex(#Tools.zones)]
    SetResult("Random Destination", "Destination:\n\n" .. zone, destTexture)
end

function Tools.RollActivity()
    local activity = Tools.activities[RandomIndex(#Tools.activities)]
    SetResult("Random Activity", "Activity:\n\n" .. activity, activityTexture)
end

local function EnsureExportVars()
    LvxJournal.exportVars = LvxJournal.exportVars or { exports = {}, lastExport = 0 }
    LvxJournal.exportVars.exports = LvxJournal.exportVars.exports or {}
    return LvxJournal.exportVars
end

local function MakeExportEntry(entry, index)
    entry = entry or {}
    return {
        index = index or 0,
        title = entry.title or "Untitled Entry",
        body = entry.body or "",
        category = entry.category or "Manual",
        location = entry.location or GetZone(),
        created = entry.time or "",
        modified = entry.modified or "",
        favorite = entry.favorite and true or false,
        exportedBy = GetPlayer(),
        exportedFromZone = GetZone(),
        exportedAt = GetStamp(),
    }
end


local personalNotesExportFile = "Documents\\Elder Scrolls Online\\live\\SavedVariables\\LvxJournal_PersonalNotesBackup.lua"


local function ShowPersonalNotesReloadDialog(noteCount)
    local body = "Backup ready.\n\n" .. tostring(noteCount or 0) .. " notes copied.\n\nReload UI now to write the file?\n\n" .. personalNotesExportFile

    if ZO_Dialogs_RegisterCustomDialog and ZO_Dialogs_ShowDialog then
        if not LvxJournal.personalNotesBackupReloadDialogRegistered then
            ZO_Dialogs_RegisterCustomDialog("LVX_JOURNAL_PERSONAL_NOTES_BACKUP_RELOAD", {
                canQueue = true,
                title = {
                    text = "Personal Notes Backup",
                },
                mainText = {
                    text = function(dialog)
                        return LvxJournal.personalNotesBackupReloadDialogText or "Backup ready. Reload UI now?"
                    end,
                },
                buttons = {
                    [1] = {
                        text = "Reload UI",
                        callback = function()
                            if ReloadUI then ReloadUI() end
                        end,
                    },
                    [2] = {
                        text = "Cancel",
                    },
                },
            })
            LvxJournal.personalNotesBackupReloadDialogRegistered = true
        end

        LvxJournal.personalNotesBackupReloadDialogText = body
        ZO_Dialogs_ShowDialog("LVX_JOURNAL_PERSONAL_NOTES_BACKUP_RELOAD")
    else
        SetResult("Notes Backup", body, exportTexture)
        Chat("Use /reloadui to write the Personal Notes backup file.")
    end
end


local function ShowPersonalNotesMissingDialog()
    local body = "Backup addon missing.\n\nEnable the optional addon:\nLvxJournal_PersonalNotesBackup\n\nThen reload UI and try Backup again.\n\nBackup file will be written here:\n" .. personalNotesExportFile

    if ZO_Dialogs_RegisterCustomDialog and ZO_Dialogs_ShowDialog then
        if not LvxJournal.personalNotesBackupMissingDialogRegistered then
            ZO_Dialogs_RegisterCustomDialog("LVX_JOURNAL_PERSONAL_NOTES_BACKUP_MISSING", {
                canQueue = true,
                title = {
                    text = "Backup Addon Missing",
                },
                mainText = {
                    text = function(dialog)
                        return LvxJournal.personalNotesBackupMissingDialogText or "Backup addon missing."
                    end,
                },
                buttons = {
                    [1] = {
                        text = "OK",
                    },
                },
            })
            LvxJournal.personalNotesBackupMissingDialogRegistered = true
        end

        LvxJournal.personalNotesBackupMissingDialogText = body
        ZO_Dialogs_ShowDialog("LVX_JOURNAL_PERSONAL_NOTES_BACKUP_MISSING")
    else
        Chat("Backup addon missing. Enable LvxJournal_PersonalNotesBackup, then /reloadui.")
    end
end

local function GetPersonalNotesExportAddon()
    if _G and _G.LvxJournalPersonalNotesBackup and type(_G.LvxJournalPersonalNotesBackup.ExportPersonalNotes) == "function" then
        return _G.LvxJournalPersonalNotesBackup
    end
    if LvxJournalPersonalNotesBackup and type(LvxJournalPersonalNotesBackup.ExportPersonalNotes) == "function" then
        return LvxJournalPersonalNotesBackup
    end
    return nil
end

local function CollectPersonalNotes()
    local notes = {}
    local s = LvxJournal.savedVars or {}
    local entries = s.entries or {}
    for i = 1, #entries do
        local entry = entries[i]
        if entry and (entry.category == "Manual" or entry.category == "Personal Notes") then
            notes[#notes + 1] = MakeExportEntry(entry, i)
        end
    end
    return notes
end

function Tools.ExportPersonalNotes()
    if LvxJournal.AutoSaveCurrentEntry then LvxJournal.AutoSaveCurrentEntry(true) end

    local companion = GetPersonalNotesExportAddon()
    if not companion then
        local message = "Backup addon missing.\n\nEnable optional addon:\nLvxJournal_PersonalNotesBackup\n\nThen reload UI and try Backup again.\n\nFile location after backup:\n" .. personalNotesExportFile
        SetResult("Backup", message, exportTexture)
        Chat("Backup addon missing. Enable LvxJournal_PersonalNotesBackup, then /reloadui.")
        Chat("Backup file location: " .. personalNotesExportFile)
        ShowPersonalNotesMissingDialog()
        return
    end

    local notes = CollectPersonalNotes()
    companion.ExportPersonalNotes(notes, {
        addonVersion = LvxJournal.version or "2.4.06",
        sourceAddon = "LvxJournal",
        player = GetPlayer(),
        zone = GetZone(),
        exportedAt = GetStamp(),
    })

    local message = "Prepared Personal Notes backup:\n\n" .. tostring(#notes) .. " notes\n\nUse /reloadui, log out, or exit to write the SavedVariables file.\n\nBackup file location:\n" .. personalNotesExportFile
    SetResult("Export", message, exportTexture)
    Chat("Prepared " .. tostring(#notes) .. " Personal Notes for backup. Use /reloadui to write the file.")
    Chat("Backup file location: " .. personalNotesExportFile)
    ShowPersonalNotesReloadDialog(#notes)
end

function Tools.ClearPersonalNotesExport()
    local companion = GetPersonalNotesExportAddon()
    if not companion then
        local message = "Backup addon missing.\n\nEnable optional addon:\nLvxJournal_PersonalNotesBackup\n\nThen reload UI and try Clear Backup again.\n\nFile location after backup:\n" .. personalNotesExportFile
        SetResult("Backup", message, exportTexture)
        Chat("Backup addon missing. Enable LvxJournal_PersonalNotesBackup, then /reloadui.")
        ShowPersonalNotesMissingDialog()
        return
    end

    if companion.ClearExport then
        companion.ClearExport()
    end

    SetResult("Export", "Personal Notes backup data cleared.\n\nUse /reloadui, log out, or exit to update:\n" .. personalNotesExportFile, exportTexture)
    Chat("Personal Notes backup data cleared. Use /reloadui to update the backup file.")
end

function Tools.ExportCurrentEntry()
    if LvxJournal.AutoSaveCurrentEntry then LvxJournal.AutoSaveCurrentEntry(true) end
    local vars = EnsureExportVars()
    local s = LvxJournal.savedVars or {}
    local index = s.selectedIndex or 1
    local entry = s.entries and s.entries[index]
    if not entry then
        SetResult("Export", "No current entry selected to export.", exportTexture)
        return
    end
    table.insert(vars.exports, MakeExportEntry(entry, index))
    vars.lastExport = GetStamp()
    SetResult("Export", "Exported current entry:\n\n" .. tostring(entry.title or "Untitled Entry") .. "\n\nRun /reloadui, log out, or exit to write LvxJournalExportVars.lua.", activityTexture)
    Chat("Current entry exported. Run /reloadui, log out, or exit to write the SavedVariables file.")
end

function Tools.ExportAllEntries()
    if LvxJournal.AutoSaveCurrentEntry then LvxJournal.AutoSaveCurrentEntry(true) end
    local vars = EnsureExportVars()
    vars.exports = {}
    local s = LvxJournal.savedVars or {}
    local entries = s.entries or {}
    for i = 1, #entries do
        table.insert(vars.exports, MakeExportEntry(entries[i], i))
    end
    vars.lastExport = GetStamp()
    SetResult("Export", "Exported all entries:\n\n" .. tostring(#entries) .. " entries\n\nRun /reloadui, log out, or exit to write LvxJournalExportVars.lua.", activityTexture)
    Chat("Exported " .. tostring(#entries) .. " entries. Run /reloadui, log out, or exit to write the SavedVariables file.")
end

function Tools.ClearExportData()
    local vars = EnsureExportVars()
    vars.exports = {}
    vars.lastExport = GetStamp()
    SetResult("Export", "Export data cleared.\n\nRun /reloadui, log out, or exit to update LvxJournalExportVars.lua.", activityTexture)
    Chat("Export data cleared.")
end

local function EnsureDailyTable()
    local s = LvxJournal.savedVars or {}
    s.dailyTasks = s.dailyTasks or {}
    return s.dailyTasks
end

function Tools.ToggleDailyTask(taskName)
    local daily = EnsureDailyTable()
    daily[taskName] = not daily[taskName]
    Tools.RefreshPage()
end

function Tools.RefreshPage()
    local page = (LvxJournal.savedVars and LvxJournal.savedVars.toolsPage) or "main"

    if page == "coin" then
        SetMapMarkManagerInputsHidden(true)
        ApplyCoinToolLayout()
        SetCoinFace(Tools.currentCoinFace or "heads")
        local startTexture = ((Tools.currentCoinFace or "heads") == "tails") and coinTailsTexture or coinHeadsTexture
        SetResult("Coin Toss", "Press Flip Coin to toss heads or tails.", startTexture)
        ShowToolButtons({
            { text = "Flip Coin", callback = function() Tools.FlipCoin() end },
        })
        ApplyCoinToolButtonLayout()
    else
        ApplyDefaultToolLayout()

        if page == "oracle" then
        ApplyOracleToolLayout()
        SetResult("Oracle", "Ask your question, focus your thoughts, then press Roll Oracle.", oracleTexture)
        ShowToolButtons({
            { text = "Roll Oracle", callback = function() Tools.RollOracle() end },
        })
    elseif page == "dice" then
        ApplyDiceToolLayout()
        SetDieFace(Tools.currentDieSides or 20)
        local startSides = tonumber(Tools.currentDieSides) or 20
        SetResult("Dice", "Choose a die and press a roll button. The result will appear as a large ledger mark beside the die.", dieTextures[startSides] or dieTextures[20])
        ShowToolButtons({
            { text = "Roll d4", callback = function() Tools.RollDie(4) end },
            { text = "Roll d6", callback = function() Tools.RollDie(6) end },
            { text = "Roll d8", callback = function() Tools.RollDie(8) end },
            { text = "Roll d10", callback = function() Tools.RollDie(10) end },
            { text = "Roll d12", callback = function() Tools.RollDie(12) end },
            { text = "Roll d20", callback = function() Tools.RollDie(20) end },
            { text = "Roll d100", callback = function() Tools.RollD100() end },
            { text = "Advantage d20", callback = function() Tools.RollAdvantage() end },
            { text = "Disadvantage d20", callback = function() Tools.RollDisadvantage() end },
            { text = "50% Chance", callback = function() Tools.RollPercentChance(50) end },
        })
    elseif page == "mapMarks" then
        ApplyMapMarksToolLayout()
        local body = LvxJournal.GetMapMarksText and LvxJournal.GetMapMarksText() or "Map Marks unavailable."
        local iconTexture = LvxJournal.GetMapMarkIconTexture and LvxJournal.GetMapMarkIconTexture((LvxJournal.savedVars and LvxJournal.savedVars.mapMarkIcon) or "book") or mapMarkTexture
        SetResult("Map Marker Manager", body, iconTexture, "ZoFontGame", {0.16, 0.075, 0.018, 1})
        SetMapMarkManagerInputsHidden(false)
        if LvxJournal.mapMarkNameBox and LvxJournal.GetMapMarkOnCurrentPage then
            local currentMark = LvxJournal.GetMapMarkOnCurrentPage(1)
            if currentMark and LvxJournal.mapMarkNameBox.SetText then
                local isFocused = false
                if LvxJournal.mapMarkNameBox.HasFocus then
                    isFocused = LvxJournal.mapMarkNameBox:HasFocus()
                end
                if not isFocused then
                    LvxJournal.suppressMapMarkNameChange = true
                    LvxJournal.mapMarkNameBox:SetText(tostring(currentMark.pinName or currentMark.title or ""))
                    LvxJournal.suppressMapMarkNameChange = false
                end
            end
        end
        ShowToolButtons({
            { text = "New Mark", callback = function() LvxJournal.AddStandaloneMapMarkFromCurrentLocation() end, tooltip = "Save your current location as a new standalone map marker. The Mark Name box renames the marker shown live; New Mark creates a new marker with that name." },
            { text = "Prev Page", callback = function() LvxJournal.PrevMapMarkPage() end },
            { text = "Next Page", callback = function() LvxJournal.NextMapMarkPage() end },
            { text = "Delete Mark", callback = function() LvxJournal.DeleteShownMapMarks() end, tooltip = "Delete only the selected/visible map marker. This removes the pin/mark, not the linked journal entry." },
            { text = "Icon", callback = function() LvxJournal.NextMapMarkIcon() end },
            { text = "Refresh", callback = function() if LvxJournal.RefreshMapPins then LvxJournal.RefreshMapPins(true) end Tools.RefreshPage() end },
        })
        ApplyMapMarksToolLayout()
        UpdateMapMarkPositionButtons()
    elseif page == "destination" then
        SetResult("Random Destination", "Click below to choose a random ESO zone.", destTexture)
        ShowToolButtons({
            { text = "Roll Destination", callback = function() Tools.RollDestination() end },
        })
    elseif page == "activity" then
        SetResult("Random Activity", "Click below to choose a random activity.", activityTexture)
        ShowToolButtons({
            { text = "Roll Activity", callback = function() Tools.RollActivity() end },
        })
    elseif page == "daily" then
        local daily = EnsureDailyTable()
        SetResult("Daily Quests", "Click tasks to mark them complete. Completion is saved until you clear it.", dailyTexture)
        local defs = {}
        for i = 1, 6 do
            local taskName = Tools.dailyTasks[i]
            local prefix = daily[taskName] and "[X] " or "[ ] "
            defs[#defs + 1] = {
                text = prefix .. taskName,
                callback = function() Tools.ToggleDailyTask(taskName) end,
            }
        end
        ShowToolButtons(defs)
    elseif page == "personalExport" then
        SetResult("Notes Backup", "Backup\n\nCreates a readable Personal Notes backup.\n\nUse /reloadui when prompted to write the file.", exportTexture)
        ShowToolButtons({
            { text = "Backup", callback = function() Tools.ExportPersonalNotes() end },
            { text = "Clear Backup", callback = function() Tools.ClearPersonalNotesExport() end },
        })
    elseif page == "export" then
        SetResult("Export", "Backup\n\nCreates a readable Personal Notes backup.\n\nUse /reloadui when prompted to write the file.", exportTexture)
        ShowToolButtons({
            { text = "Backup", callback = function() Tools.ExportPersonalNotes() end },
            { text = "Clear Backup", callback = function() Tools.ClearPersonalNotesExport() end },
            { text = "Export Current", callback = function() Tools.ExportCurrentEntry() end },
            { text = "Export All", callback = function() Tools.ExportAllEntries() end },
            { text = "Clear Old Export", callback = function() Tools.ClearExportData() end },
        })
        else
            SetResult("Tools", "Select a tool from the left page.", oracleTexture)
            ClearToolButtons()
        end
    end
end


