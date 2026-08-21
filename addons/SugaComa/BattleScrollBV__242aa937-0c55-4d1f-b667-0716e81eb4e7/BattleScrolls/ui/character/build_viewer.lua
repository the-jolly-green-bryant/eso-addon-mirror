BattleScrolls = BattleScrolls or {}
BattleScrolls.buildViewer = BattleScrolls.buildViewer or {}

function BattleScrolls_BuildViewer_OnInitialized(control)
    local pane = control:GetNamedChild("OverviewPane")
    if pane and BattleScrolls_Journal_OverviewPanel then
        BattleScrolls.buildViewer.panel = BattleScrolls_Journal_OverviewPanel:New(pane)
    end
end
