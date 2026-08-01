local AGS = AwesomeGuildStore
if not AGS then return end

local FILTER_ID = AGS.data.FILTER_ID
local filterId = FILTER_ID.WRIT_TO_STYLE_REQUIRED_FILTER or 109 --Temporary

local MultiChoiceFilterBase = AGS.class.MultiChoiceFilterBase
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local WritRequiredMotifFilter = MultiChoiceFilterBase:Subclass()
AGS.class.WritRequiredMotifFilter = WritRequiredMotifFilter

local gettext = AGS.internal.gettext

function WritRequiredMotifFilter:New(...)
  return MultiChoiceFilterBase.New(self, ...)
end

function WritRequiredMotifFilter:Initialize()
  MultiChoiceFilterBase.Initialize(self, filterId, AGS.class.FilterBase.GROUP_LOCAL, "Writ2Style", 
    {
      {
        id = true,
        label = "|t20:20:esoui/art/icons/master_writ_alchemy.dds|t -> |t20:20:esoui/art/icons/quest_letter_002.dds|t",
        icon = "EsoUI/Art/Crafting/reconstruct_tabicon_%s.dds",
      },
    })
    self:SetEnabledSubcategories({
      [SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = true,
    })
end

local cacheRequiredMotifs = {
--  timeStamp = ,
--  [itemLink] = true,
--  ...
}

local function IsItemLinkRequiredMotif(itemLink)
  --Update cache
  local cacheTimeStamp = cacheRequiredMotifs.timeStamp or 0
  local nowTimeStamp = GetTimeStamp()
  if (nowTimeStamp - cacheTimeStamp) > 10 then
    cacheRequiredMotifs = {}
    cacheRequiredMotifs.timeStamp = nowTimeStamp
    for i = 0, GetBagSize(1) do
      local writItemLink = GetItemLink(1, i)
      local motifItemLink = Writ2StyleByLink(writItemLink)
      if motifItemLink then
        cacheRequiredMotifs[motifItemLink] = true
      end
    end
  end
  --Is itemLink required motif
  return cacheRequiredMotifs[itemLink] or false
end

function WritRequiredMotifFilter:FilterLocalResult(itemData)
  local id = IsItemLinkRequiredMotif(itemData.itemLink)
  local value = self.valueById[id]
  return self.localSelection[value]
end

AGS:RegisterCallback(AGS.callback.AFTER_FILTER_SETUP, 
  function()
    AGS:RegisterFilter(WritRequiredMotifFilter:New())
    AGS:RegisterFilterFragment(AGS.class.MultiButtonFilterFragment:New(filterId))
  end
)