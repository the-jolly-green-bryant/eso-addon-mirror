local GuildEvents = _G["GuildEvents"]
GuildEventsUI = GuildEventsUI or {}
GuildEventsUI.create = {}

local ui = GuildEventsUI.create
local wm = WINDOW_MANAGER
local L = GuildEvents.GetLocale()

------------------------------------------------
--- Methods
------------------------------------------------
function GuildEventsUI:Create()

    -- Special Font-Attributes for Labels
    local labelFontPath = "EsoUI/Common/Fonts/univers67.otf"
    local labelFontSize = 18
    local labelFontOutline = "soft-shadow-thin"

    --Check each of the text fields if they are empty and show the info text again then
    local function checkAndResetTextFields(currentCtrl)
        if currentCtrl == nil or currentCtrl ~= ui.txtEventAdd_ID then
            if ui.txtEventAdd_ID:GetText() == "" then
                ui.txtEventAdd_ID:SetText(L.eventAddId)
            end
        end
        if currentCtrl == nil or currentCtrl ~= ui.txtEventAdd_Title then
            if ui.txtEventAdd_Title:GetText() == "" then
                ui.txtEventAdd_Title:SetText(L.eventAddTitle)
            end
        end
        if currentCtrl == nil or currentCtrl ~= ui.txtEventAdd_Date then
            if ui.txtEventAdd_Date:GetText() == "" then
                ui.txtEventAdd_Date:SetText(L.eventAddDate)
            end
        end
        if currentCtrl == nil or currentCtrl ~= ui.txtEventAdd_Info then
            if ui.txtEventAdd_Info:GetText() == "" then
                ui.txtEventAdd_Info:SetText(L.eventAddInfo)
            end
        end
    end

    ui.main = wm:CreateTopLevelWindow("GuildEventsCreateFragment")
    ui.main:SetAnchor(TOPLEFT, ZO_GroupList, TOPLEFT, -350, 0)
    ui.main:SetHidden(true)
    ui.main:SetWidth(400)

    --Create event
    ui.lblEventAdd_Header = wm:CreateControl("GuildEvents_lblEventAdd_Header", ui.main, CT_LABEL)
    ui.lblEventAdd_ID = wm:CreateControl("GuildEvents_lblEventAdd_ID", ui.main, CT_LABEL)
    ui.lblEventAdd_Title = wm:CreateControl("GuildEvents_lblEventAdd_Title", ui.main, CT_LABEL)
    ui.lblEventAdd_Date = wm:CreateControl("GuildEvents_lblEventAdd_Date", ui.main, CT_LABEL)
    ui.lblEventAdd_Info = wm:CreateControl("GuildEvents_lblEventAdd_Info", ui.main, CT_LABEL)
    ui.btnEventAdd_Save = wm:CreateControl("GuildEvents_btnEventAdd_Save", ui.main, CT_BUTTON)
    ui.btnEventAdd_Cancel = wm:CreateControl("GuildEvents_btnEventAdd_Cancel", ui.main, CT_BUTTON)
    ui.bdEventAdd_ID = wm:CreateControlFromVirtual("GuildEvents_bdEventAdd_ID", ui.main, "ZO_EditBackdrop")
    ui.bdEventAdd_Title = wm:CreateControlFromVirtual("GuildEvents_bdEventAdd_Title", ui.main, "ZO_EditBackdrop")
    ui.bdEventAdd_Date = wm:CreateControlFromVirtual("GuildEvents_bdEventAdd_Date", ui.main, "ZO_EditBackdrop")
    ui.bdEventAdd_Info = wm:CreateControlFromVirtual("GuildEvents_bdEventAdd_Info", ui.main, "ZO_EditBackdrop")
    ui.txtEventAdd_ID = wm:CreateControlFromVirtual("GuildEvents_txtEventAdd_ID", ui.bdEventAdd_ID, "ZO_DefaultEditForBackdrop")
    ui.txtEventAdd_Title = wm:CreateControlFromVirtual("GuildEvents_txtEventAdd_Title", ui.bdEventAdd_Title, "ZO_DefaultEditForBackdrop")
    ui.txtEventAdd_Date = wm:CreateControlFromVirtual("GuildEvents_txtEventAdd_Date", ui.bdEventAdd_Date, "ZO_DefaultEditForBackdrop")
    ui.txtEventAdd_Info = wm:CreateControlFromVirtual("GuildEvents_txtEventAdd_Info", ui.bdEventAdd_Info, "ZO_DefaultEditForBackdrop")

    ui.lblEventAdd_Header:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEventAdd_Header:SetFont("ZoFontHeader3")
    ui.lblEventAdd_Header:SetScale(1)
    ui.lblEventAdd_Header:SetDrawLayer(3)
    ui.lblEventAdd_Header:SetAnchor(TOP, ui.main, TOP, -40, 0)
    ui.lblEventAdd_Header:SetDimensions(0, 20)
    ui.lblEventAdd_Header:SetText(L.eventCreate)

    ui.lblEventAdd_ID:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEventAdd_ID:SetFont("ZoFontHeader")
    ui.lblEventAdd_ID:SetScale(1)
    ui.lblEventAdd_ID:SetDrawLayer(3)
    ui.lblEventAdd_ID:SetAnchor(TOPLEFT, ui.lblEventAdd_Header, BOTTOMLEFT, 0, 20)
    ui.lblEventAdd_ID:SetText(L.eventAddIdLabel)

    ui.bdEventAdd_ID:SetDimensions(200,30)
    ui.bdEventAdd_ID:SetCenterColor(.4,.4,.4,0)
    ui.bdEventAdd_ID:SetEdgeColor(0,0,0,0)
    ui.bdEventAdd_ID:SetEdgeTexture("",1,1,2,5)
    ui.bdEventAdd_ID:SetAlpha(1)
    ui.bdEventAdd_ID:SetScale(1)
    ui.bdEventAdd_ID:SetDrawLayer(3)
    ui.bdEventAdd_ID:SetInsets(0,0,0,0)
    ui.bdEventAdd_ID:SetAnchor(TOPLEFT, ui.lblEventAdd_ID, BOTTOMLEFT, 0, 0)

    ui.txtEventAdd_ID:SetText(L.eventAddId)
    ui.txtEventAdd_ID:SetFont("ZoFontEdit")
    ui.txtEventAdd_ID:SetColor(0.8, 0.8, 0.8, 1)
    ui.txtEventAdd_ID:SetMaxInputChars(1)
    ui.txtEventAdd_ID:SetScale(1)
    ui.txtEventAdd_ID:SetDrawLayer(3)
    ui.txtEventAdd_ID:SetHandler("OnTab", function()
        ui.txtEventAdd_Title:TakeFocus()
        checkAndResetTextFields(ui.txtEventAdd_Title)
        if ui.txtEventAdd_Title:GetText() == L.eventAddTitle then
            ui.txtEventAdd_Title:SetText("")
        end
    end)
    ui.txtEventAdd_ID:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if upInside then
            checkAndResetTextFields(ctrl)
            if ui.txtEventAdd_ID:GetText() == L.eventAddId then
                ui.txtEventAdd_ID:SetText("")
            end
        end
    end)
    ZO_PreHook(ui.txtEventAdd_ID, "LoseFocus", function(ctrl) checkAndResetTextFields() end)

    ui.lblEventAdd_Title:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEventAdd_Title:SetFont("ZoFontHeader")
    ui.lblEventAdd_Title:SetDrawLayer(3)
    ui.lblEventAdd_Title:SetAnchor(TOPLEFT, ui.bdEventAdd_ID, BOTTOMLEFT, 0, 10)
    ui.lblEventAdd_Title:SetText(L.eventAddTitleLabel)

    ui.bdEventAdd_Title:SetDimensions(200,30)
    ui.bdEventAdd_Title:SetCenterColor(.4,.4,.4,0)
    ui.bdEventAdd_Title:SetEdgeColor(0,0,0,0)
    ui.bdEventAdd_Title:SetEdgeTexture("",1,1,2,5)
    ui.bdEventAdd_Title:SetAlpha(1)
    ui.bdEventAdd_Title:SetScale(1)
    ui.bdEventAdd_Title:SetDrawLayer(3)
    ui.bdEventAdd_Title:SetInsets(0,0,0,0)
    ui.bdEventAdd_Title:SetAnchor(TOPLEFT, ui.lblEventAdd_Title, BOTTOMLEFT, 0, 0)

    ui.txtEventAdd_Title:SetText(L.eventAddTitle)
    ui.txtEventAdd_Title:SetFont("ZoFontEdit")
    ui.txtEventAdd_Title:SetColor(0.8, 0.8, 0.8, 1)
    ui.txtEventAdd_Title:SetMaxInputChars(40)
    ui.txtEventAdd_Title:SetScale(1)
    ui.txtEventAdd_Title:SetDrawLayer(3)
    ui.txtEventAdd_Title:SetHandler("OnTab", function()
        ui.txtEventAdd_Date:TakeFocus()
        checkAndResetTextFields(ui.txtEventAdd_Date)
        if ui.txtEventAdd_Date:GetText() == L.eventAddDate then
            ui.txtEventAdd_Date:SetText("")
        end
    end)
    ui.txtEventAdd_Title:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if upInside then
            checkAndResetTextFields(ctrl)
            if ui.txtEventAdd_Title:GetText() == L.eventAddTitle then
                ui.txtEventAdd_Title:SetText("")
            end
        end
    end)
    ZO_PreHook(ui.txtEventAdd_Title, "LoseFocus", function(ctrl) checkAndResetTextFields() end)

    ui.lblEventAdd_Date:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEventAdd_Date:SetFont("ZoFontHeader")
    ui.lblEventAdd_Date:SetScale(1)
    ui.lblEventAdd_Date:SetDrawLayer(3)
    ui.lblEventAdd_Date:SetAnchor(TOPLEFT, ui.bdEventAdd_Title, BOTTOMLEFT, 0, 10)
    ui.lblEventAdd_Date:SetText(L.eventAddDateLabel)

    ui.bdEventAdd_Date:SetDimensions(300,30)
    ui.bdEventAdd_Date:SetCenterColor(.4,.4,.4,0)
    ui.bdEventAdd_Date:SetEdgeColor(0,0,0,0)
    ui.bdEventAdd_Date:SetEdgeTexture("",1,1,2,5)
    ui.bdEventAdd_Date:SetAlpha(1)
    ui.bdEventAdd_Date:SetScale(1)
    ui.bdEventAdd_Date:SetDrawLayer(3)
    ui.bdEventAdd_Date:SetInsets(0,0,0,0)
    ui.bdEventAdd_Date:SetAnchor(TOPLEFT, ui.lblEventAdd_Date, BOTTOMLEFT, 0, 0)

    ui.txtEventAdd_Date:SetText(L.eventAddDate)
    ui.txtEventAdd_Date:SetFont("ZoFontEdit")
    ui.txtEventAdd_Date:SetColor(0.8, 0.8, 0.8, 1)
    ui.txtEventAdd_Date:SetMaxInputChars(20)
    ui.txtEventAdd_Date:SetScale(1)
    ui.txtEventAdd_Date:SetDrawLayer(3)
    ui.txtEventAdd_Date:SetHandler("OnTab", function()
        ui.txtEventAdd_Info:TakeFocus()
        checkAndResetTextFields(ui.txtEventAdd_Info)
        if ui.txtEventAdd_Info:GetText() == L.eventAddInfo then
            ui.txtEventAdd_Info:SetText("")
        end
    end)
    ui.txtEventAdd_Date:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if upInside then
            checkAndResetTextFields(ctrl)
            if ui.txtEventAdd_Date:GetText() == L.eventAddDate then
                ui.txtEventAdd_Date:SetText("")
            end
        end
    end)
    ZO_PreHook(ui.txtEventAdd_Date, "LoseFocus", function(ctrl) checkAndResetTextFields() end)

    ui.lblEventAdd_Info:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEventAdd_Info:SetFont("ZoFontHeader")
    ui.lblEventAdd_Info:SetScale(1)
    ui.lblEventAdd_Info:SetDrawLayer(3)
    ui.lblEventAdd_Info:SetAnchor(TOPLEFT, ui.bdEventAdd_Date, BOTTOMLEFT, 0, 10)
    ui.lblEventAdd_Info:SetText(L.eventAddInfoLabel)

    ui.bdEventAdd_Info:SetDimensions(200,30)
    ui.bdEventAdd_Info:SetCenterColor(.4,.4,.4,0)
    ui.bdEventAdd_Info:SetEdgeColor(0,0,0,0)
    ui.bdEventAdd_Info:SetEdgeTexture("",1,1,2,5)
    ui.bdEventAdd_Info:SetAlpha(1)
    ui.bdEventAdd_Info:SetScale(1)
    ui.bdEventAdd_Info:SetDrawLayer(3)
    ui.bdEventAdd_Info:SetInsets(0,0,0,0)
    ui.bdEventAdd_Info:SetAnchor(TOPLEFT, ui.lblEventAdd_Info, BOTTOMLEFT, 0, 0)

    ui.txtEventAdd_Info:SetText(L.eventAddInfo)
    ui.txtEventAdd_Info:SetFont("ZoFontEdit")
    ui.txtEventAdd_Info:SetColor(0.8, 0.8, 0.8, 1)
    ui.txtEventAdd_Info:SetMaxInputChars(20)
    ui.txtEventAdd_Info:SetScale(1)
    ui.txtEventAdd_Info:SetDrawLayer(3)
    ui.txtEventAdd_Info:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if upInside then
            checkAndResetTextFields(ctrl)
            if ui.txtEventAdd_Info:GetText() == L.eventAddInfo then
                ui.txtEventAdd_Info:SetText("")
            end
        end
    end)
    ZO_PreHook(ui.txtEventAdd_Info, "LoseFocus", function(ctrl) checkAndResetTextFields() end)

    ui.btnEventAdd_Save:SetDimensions(40,40)
    ui.btnEventAdd_Save:SetAnchor(TOPLEFT, ui.bdEventAdd_Info, BOTTOMLEFT, 0, 10)
    ui.btnEventAdd_Save:SetAlpha(1)
    ui.btnEventAdd_Save:SetDrawLayer(3)
    ui.btnEventAdd_Save:SetFont("ZoFontAlert")
    ui.btnEventAdd_Save:SetScale(1)
    ui.btnEventAdd_Save:SetNormalTexture("/esoui/art/buttons/accept_up.dds")
    ui.btnEventAdd_Save:SetMouseOverTexture("/esoui/art/buttons/accept_over.dds")
    ui.btnEventAdd_Save:SetHandler("OnClicked", function(h)
        GuildEventsUI:createEvent()
    end)

    ui.btnEventAdd_Cancel:SetDimensions(40,40)
    ui.btnEventAdd_Cancel:SetAnchor(TOPLEFT, ui.btnEventAdd_Save, TOPRIGHT, 20, 0)
    ui.btnEventAdd_Cancel:SetAlpha(1)
    ui.btnEventAdd_Cancel:SetDrawLayer(2)
    ui.btnEventAdd_Cancel:SetFont("ZoFontAlert")
    ui.btnEventAdd_Cancel:SetScale(1)
    ui.btnEventAdd_Cancel:SetNormalTexture("/esoui/art/buttons/cancel_up.dds")
    ui.btnEventAdd_Cancel:SetMouseOverTexture("/esoui/art/buttons/cancel_over.dds")
    ui.btnEventAdd_Cancel:SetHidden(true)
    ui.btnEventAdd_Cancel:SetHandler("OnClicked", function(h)
    end)

    GUILD_EVENTS_CREATE_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)

    GuildEventsUI.create:refresh()
end

function GuildEventsUI.create:refresh()
    --Only show if user has permissions
    local memberIsAdmin = DoesPlayerHaveGuildPermission(GuildEventsUI.selectedGuildId, 6)
    if memberIsAdmin then
        ui.lblEventAdd_Header:SetHidden(false)
        ui.lblEventAdd_ID:SetHidden(false)
        ui.lblEventAdd_Title:SetHidden(false)
        ui.lblEventAdd_Date:SetHidden(false)
        ui.lblEventAdd_Info:SetHidden(false)
        ui.btnEventAdd_Save:SetHidden(false)
        ui.bdEventAdd_ID:SetHidden(false)
        ui.bdEventAdd_Title:SetHidden(false)
        ui.bdEventAdd_Date:SetHidden(false)
        ui.bdEventAdd_Info:SetHidden(false)
        ui.txtEventAdd_ID:SetHidden(false)
        ui.txtEventAdd_Title:SetHidden(false)
        ui.txtEventAdd_Date:SetHidden(false)
        ui.txtEventAdd_Info:SetHidden(false)
    else
        ui.lblEventAdd_Header:SetHidden(true)
        ui.lblEventAdd_ID:SetHidden(true)
        ui.lblEventAdd_Title:SetHidden(true)
        ui.lblEventAdd_Date:SetHidden(true)
        ui.lblEventAdd_Info:SetHidden(true)
        ui.btnEventAdd_Save:SetHidden(true)
        ui.btnEventAdd_Cancel:SetHidden(true)
        ui.bdEventAdd_ID:SetHidden(true)
        ui.bdEventAdd_Title:SetHidden(true)
        ui.bdEventAdd_Date:SetHidden(true)
        ui.bdEventAdd_Info:SetHidden(true)
        ui.txtEventAdd_ID:SetHidden(true)
        ui.txtEventAdd_Title:SetHidden(true)
        ui.txtEventAdd_Date:SetHidden(true)
        ui.txtEventAdd_Info:SetHidden(true)
    end
end

function GuildEventsUI:createEvent()
    local eventCount = table.getn(GuildEventsUI.events.events) + 1

    if eventCount <= GuildEvents.maxEvents then
        local event = ui.txtEventAdd_ID:GetText().."-"..ui.txtEventAdd_Title:GetText().."\n"..ui.txtEventAdd_Date:GetText().."\n"..ui.txtEventAdd_Info:GetText()--.."\n"..ui.txtEventAdd_MaxAttendees:GetText()
        GuildEventsUI.events.events[eventCount] = event
        GuildEventsUI:saveEvents()

        --Reset texts
        ui.txtEventAdd_ID:SetText(L.eventAddId)
        ui.txtEventAdd_Title:SetText(L.eventAddTitle)
        ui.txtEventAdd_Date:SetText(L.eventAddDate)
        ui.txtEventAdd_Info:SetText(L.eventAddInfo)
    end
end
