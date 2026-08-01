DsRAutoINVUI = DsRAutoINVUI or {}
DsRAutoINVUI.fragmentEnabled = {}
local ui = DsRAutoINVUI.fragmentEnabled
local wm = WINDOW_MANAGER

function DsRAutoINVUI:CreateEnabledFragment()
    ui.main = wm:CreateControl("DsRAutoINVEnabled", DsRAI_SmallGroupList, CT_CONTROL) --ui.main = wm:CreateTopLevelWindow("DsRAutoINVEnabledFragment")
    ui.scroll = ui.main -- For using LAM controls
    ui.main:SetWidth(340)
    ui.panel = ui.main
    ui.panel.data = {}

    ui.refreshList = wm:CreateControlFromVirtual(nil, ui.main, "ZO_DefaultButton")
    ui.refreshList:SetAnchor(TOP, ZO_GroupList, TOP, 100, 110)
    -- ui.refreshList:SetAnchor(TOP, ZO_GroupList, TOP, -180, -30)
    ui.refreshList:SetWidth(180)
    ui.refreshList:SetText(GetString(SI_DsRAI_BTN_REFRESH))
    ui.refreshList:SetHandler("OnClicked", function() MINI_GROUP_LIST:RefreshData() end)
end
