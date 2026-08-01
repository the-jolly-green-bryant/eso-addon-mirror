if not VOTANS_ACHIEVEMENTS then return end

local compatibility = {}

function compatibility:HideSummary()
    self.SummaryInset = ZO_AchievementsContents:GetNamedChild("SummaryInset")
    self.RecentScrollList = self.SummaryInset:GetNamedChild("VotansAchievementsList")

    self.ProgressBarsScrollChildTotal = self.SummaryInset:GetNamedChild("ProgressBarsScrollChildTotal")

    d(QUANTUMPIES_GA.svSettings.settingsUseVotansWindow)
    if QUANTUMPIES_GA.svSettings.settingsUseVotansWindow then
        self.SummaryInset:GetNamedChild("QuantumsGAProgressBars"):SetHidden(true)
    else
        self.RecentScrollList:SetHidden(true)
        self.ProgressBarsScrollChildTotal:SetAlpha(0)

    end
end

local orgShowCategoryTooltip = VOTANS_ACHIEVEMENTS.ShowCategoryTooltip
function VOTANS_ACHIEVEMENTS:ShowCategoryTooltip(data)
    if data.categoryIndex ~= "QP_GA_GROUP" then
        orgShowCategoryTooltip(self, data)
    end
end

local function AddLine(tooltip, text, color, alignment)
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, alignment, alignment ~= TEXT_ALIGN_LEFT)
end

local function AddLineCenter(tooltip, text, color)
    if not color then
        color = ZO_TOOLTIP_DEFAULT_COLOR
    end
    AddLine(tooltip, text, color, TEXT_ALIGN_CENTER)
end

local percentText = {}
local function GetPercentText(earnedPointsSum, totalPointsSum)
    local percent = zo_round(100 * earnedPointsSum / totalPointsSum)
    if not percentText[percent] then
        percentText[percent] = string.format("%s%%", percent)
    end
    return percentText[percent]
end

local nameText = {}
local function GetCategory(categoryIndex)
    local name, numSubCategories, _, earnedPointsSum, totalPointsSum = GetAchievementCategoryInfo(categoryIndex)

    if not nameText[name] then
        local icon = GetAchievementCategoryKeyboardIcons(categoryIndex)
        nameText[name] = string.format("|t32:32:%s|t %s", icon, zo_strformat(SI_ACHIEVEMENTS_NAME, name))
    end

    AddLineCenter(AchievementTooltip, string.format("%s |cfafafa%s|r", nameText[name], GetPercentText(earnedPointsSum, totalPointsSum)))
end

function VOTANS_ACHIEVEMENTS:ShowSummaryTooltip()
    AchievementTooltip:VotanClearStatusBars()
    local rootNode, data = ACHIEVEMENTS.categoryTree.rootNode
    for _, category in ipairs(rootNode:GetChildren()) do
        data = category:GetData()
        if not data.summary and data.categoryIndex ~= "QP_GA_GROUP" then
            GetCategory(ACHIEVEMENTS:GetCategoryIndicesFromData(data))
        end
    end
end

QUANTUMPIES_GA_COMPATIBILITY_VOTANS = compatibility