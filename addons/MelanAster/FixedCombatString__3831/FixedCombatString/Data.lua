--Basic info
FIXCS = {}
FIXCS.name = "FixedCombatString"
FIXCS.title = "FixedCombatString"
FIXCS.author = "@MelanAster,"
FIXCS.version = "0.21"
FIXCS.Dault = {
  IsFirstTime = true,
  ItemAdjust = 0,
}
------------
--Variable
------------
--For fine-tune for every control with robfun
FIXCS.AdjustValue = 0
--When ItemTooltip do something, store the worn ItemLink here for Comparate
FIXCS.MatchedComp = { 
  ["ComparativeTooltip1"] = "",
  ["ComparativeTooltip2"] = "",
}
--The changed no-name controls in last round
FIXCS.LastContorl = {
  ["SkillTooltip"] = {},
  ["ChampionSkillTooltip"] = {},
  ["ItemTooltip"] = {},
  ["PopupTooltip"] = {},
  ["ComparativeTooltip1"] = {},
  ["ComparativeTooltip2"] = {},
  ["ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip"] = {},
  ["ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip"] = {},
  ["ZO_SmithingTopLevelCreationPanelResultTooltip"] = {},
  ["ZO_SmithingTopLevelImprovementPanelResultTooltip"] = {},
  --Compatible with other addons
  ["HarvensSkillTooltipMorph1"] = {},
  ["HarvensSkillTooltipMorph2"] = {},
}
--To set Tooltips with standard way, and get no-name controls
FIXCS.MagicSpell = {
  ["SkillTooltip"] = function() SkillTooltip:SetActiveSkill(2,5,3,1,true,false,false,8,false,false,false,false,nil,39073) end,
  ["ChampionSkillTooltip"] = function() ChampionSkillTooltip:SetChampionSkill(92,100,100,false) end,
  ["ItemTooltip"] = function() ItemTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["PopupTooltip"] = function() PopupTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ComparativeTooltip1"] = function() ComparativeTooltip1:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ComparativeTooltip2"] = function() ComparativeTooltip2:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip"] = function() ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip"] = function() ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ZO_SmithingTopLevelCreationPanelResultTooltip"] = function() ZO_SmithingTopLevelCreationPanelResultTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  ["ZO_SmithingTopLevelImprovementPanelResultTooltip"] = function() ZO_SmithingTopLevelImprovementPanelResultTooltip:SetLink("|H0:item:75063:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h") end,
  --Compatible with other addons
  ["HarvensSkillTooltipMorph1"] = function() HarvensSkillTooltipMorph1:SetActiveSkill(2,5,3,1,true,false,false,8,false,false,false,false,nil,39073) end,
  ["HarvensSkillTooltipMorph2"] = function() HarvensSkillTooltipMorph2:SetActiveSkill(2,5,3,1,true,false,false,8,false,false,false,false,nil,39073) end,
}
--Hold all no-name controls in different Tooltips
FIXCS.ODC = {
--[[
  ["SkillTooltip"] = {16 controls}  
    [10-X] for ability desc with X lines info. For example, [5] for ability with 5 lines info
    [13] for passive ability desc, 12 for weapon passive skill
  ["ChampionSkillTooltip"] = {11 controls}
    [8] Desc
    [6] Now effect
  ["ItemTooltip/PopupTooltip/..."] = {26+ controls}
    [?] SetName line. Basic 12, Cant't collected +1, No bar +1, No enchat +2, No trait +2.
    [-1] 
    [-2] 
    [-3] 
    [-4]
    [-5]
    Trait station, -1
    Only SetID effect, from 22
]]
}