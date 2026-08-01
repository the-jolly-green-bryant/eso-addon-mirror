DsRAutoINVUI = DsRAutoINVUI or {}
local ui = DsRAutoINVUI

function DsRAutoINVUI.refresh()
    -- ui.fragmentEnabled.enabled:UpdateValue()
    -- ui.fragmentEnabled.text:UpdateValue()
    ui.fragmentOptions.enabled:UpdateValue()
    ui.fragmentOptions.text:UpdateValue()
    ui.fragmentOptions.cyr:UpdateValue()
    ui.fragmentOptions.restart:UpdateValue()
    ui.fragmentOptions.kick:UpdateValue()
    ui.fragmentOptions.kickTime:UpdateValue()
    ui.fragmentOptions.max:UpdateValue()
end

function DsRAutoINVUI.init()
    if ui.created then return end
    ui.created = true
    DsRAutoINVUI:CreateEnabledFragment()
    DsRAutoINVUI:CreateOptionFragment()
    DsRAutoINVUI:CreateScene()
end
