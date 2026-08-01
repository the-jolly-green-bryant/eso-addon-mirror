local MSP = MSPAINTUI

local panel
local currentPageNum = 1
local totalPages = 0

local function CreatePage(num)
    local pagePanel = WINDOW_MANAGER:CreateControl("$(parent)Page" .. num, panel, CT_CONTROL)
    pagePanel:SetAnchorFill()
    if (num > 1) then
        pagePanel:SetHidden(true)
    end
    return pagePanel
end

local function NavigatePage(offset)
    local page = panel:GetNamedChild("Page" .. currentPageNum)
    page:SetHidden(true)

    currentPageNum = currentPageNum + offset
    page = panel:GetNamedChild("Page" .. currentPageNum)
    page:SetHidden(false)

    if (currentPageNum == 1) then
        panel:GetNamedChild("Previous"):SetEnabled(false)
    else
        panel:GetNamedChild("Previous"):SetEnabled(true)
    end
    if (currentPageNum < totalPages) then
        panel:GetNamedChild("Next"):SetEnabled(true)
    elseif (currentPageNum == totalPages) then
        panel:GetNamedChild("Next"):SetEnabled(false)
    end
end

local function PreviewIcons()
    if (panel) then
        panel:SetHidden(false)
        return
    end

    panel = WINDOW_MANAGER:CreateTopLevelWindow(MSP.name .. "PreviewPanel")
    panel:SetAnchor(TOP, GuiRoot, TOP, 0, 32)
    panel:SetWidth(GuiRoot:GetWidth() * 0.9)
    panel:SetHeight(GuiRoot:GetHeight() * 0.9)
    panel:SetMouseEnabled(true)

    local backdrop = WINDOW_MANAGER:CreateControl("$(parent)Backdrop", panel, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0, 0, 0, 0.9)

    local closeButton = WINDOW_MANAGER:CreateControl("$(parent)Close", panel, CT_BUTTON)
    ApplyTemplateToControl(closeButton, "ZO_DefaultButton")
    closeButton:SetText("Close")
    closeButton:SetHandler("OnClicked", function() panel:SetHidden(true) end)
    closeButton:SetAnchor(CENTER, panel, TOP, 0, 32)

    local nextButton = WINDOW_MANAGER:CreateControl("$(parent)Next", panel, CT_BUTTON)
    ApplyTemplateToControl(nextButton, "ZO_DefaultButton")
    nextButton:SetText("Next")
    nextButton:SetHandler("OnClicked", function() NavigatePage(1) end)
    nextButton:SetAnchor(LEFT, closeButton, RIGHT, 24, 0)

    local prevButton = WINDOW_MANAGER:CreateControl("$(parent)Previous", panel, CT_BUTTON)
    ApplyTemplateToControl(prevButton, "ZO_DefaultButton")
    prevButton:SetText("Previous")
    prevButton:SetHandler("OnClicked", function() NavigatePage(-1) end)
    prevButton:SetAnchor(RIGHT, closeButton, LEFT, -24, 0)

    local optionsOrder = {
        "Dragonknight",
        "Sorcerer",
        "Nightblade",
        "Templar",
        "Warden",
        "Necromancer",
        "Arcanist",
        "Weapon",
        "Armor",
        "World",
        "Guild",
        "Alliance War",
    }

    local MARGIN = 16
    local TOP_MARGIN = 64
    local maxRows = math.floor((GuiRoot:GetHeight() * 0.9 - MARGIN - TOP_MARGIN) / 67)
    local numPerRow = math.floor((GuiRoot:GetWidth() * 0.9 - MARGIN * 2) / 67)

    local currentPage

    local numRows = 0
    for groupIndex, groupName in ipairs(optionsOrder) do
        local groupTable = MSP.ABILITY_ICONS[groupName]
        local expectedRows = math.ceil(#groupTable / numPerRow)

        if (not currentPage or numRows + expectedRows > maxRows) then
            totalPages = totalPages + 1
            currentPage = CreatePage(totalPages)
            numRows = 0
        end

        for iconIndex, iconPath in ipairs(groupTable) do
            local texture = WINDOW_MANAGER:CreateControl("$(parent)" .. iconPath, currentPage, CT_TEXTURE)
            texture:SetDimensions(64, 64)
            texture:SetAnchor(TOPLEFT, currentPage, TOPLEFT,
                ((iconIndex - 1) % numPerRow) * 67 + MARGIN,
                (numRows + math.floor((iconIndex - 1) / numPerRow)) * 67 + TOP_MARGIN)
            texture:SetTexture("MSPAINTUI/art/abilities/" .. iconPath)
        end
        numRows = numRows + math.ceil(#groupTable / numPerRow)
    end

    NavigatePage(0) -- Just to enable/disable buttons
end
MSP.PreviewIcons = PreviewIcons
-- /script MSPAINTUI.PreviewIcons()
