FarmingPartyPlusFishingSyncLookup = FarmingPartyPlusFishingSyncLookup or {}

local entries = {
  { code = 1, key = 'dhufish', name = 'Dhufish', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 2, key = 'longfin', name = 'Longfin', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 3, key = 'spadetail', name = 'Spadetail', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 4, key = 'silverside perch', name = 'Silverside Perch', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 5, key = 'slaughterfish', name = 'Slaughterfish', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 6, key = 'trophy fish', name = 'Trophy Fish', quality = ITEM_QUALITY_MAGIC, kind = 'common_fish' },
  { code = 7, key = 'salmon', name = 'Salmon', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 8, key = 'river clariid', name = 'River Clariid', quality = ITEM_QUALITY_NORMAL, kind = 'common_fish' },
  { code = 9, key = 'fish', name = 'Fish', quality = ITEM_QUALITY_NORMAL, kind = 'output', canonicalLink = "|H0:item:33753:25:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" },
  { code = 10, key = 'perfect roe', name = 'Perfect Roe', quality = ITEM_QUALITY_LEGENDARY, kind = 'output', canonicalLink = "|H0:item:64222:29:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }
}

local byCode = {}
local byKey = {}
for _, entry in ipairs(entries) do
  byCode[entry.code] = entry
  byKey[entry.key] = entry
end

function FarmingPartyPlusFishingSyncLookup:GetByCode(code)
  return byCode[tonumber(code) or 0]
end

function FarmingPartyPlusFishingSyncLookup:GetByNormalizedName(normalizedName)
  if normalizedName == nil then
    return nil
  end
  return byKey[zo_strlower(zo_strformat('<<z:1>>', normalizedName))]
end

function FarmingPartyPlusFishingSyncLookup:GetCodeByNormalizedName(normalizedName)
  local entry = self:GetByNormalizedName(normalizedName)
  return entry ~= nil and entry.code or 0
end

function FarmingPartyPlusFishingSyncLookup:GetCanonicalLinkByCode(code)
  local entry = self:GetByCode(code)
  return entry ~= nil and entry.canonicalLink or nil
end
