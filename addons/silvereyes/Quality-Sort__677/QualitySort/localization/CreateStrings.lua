for stringId, value in pairs(QUALITYSORT_STRINGS) do
    local stringValue
    if type(value) == "table" then
        for i=2,#value do
            if type(value[i]) == "string" then
                value[i] = _G[value[i]]
            end
            value[i] = GetString(value[i])
        end
        stringValue = zo_strformat(unpack(value))
    else
        stringValue = value
    end
    ZO_CreateStringId(stringId, stringValue)
end
QUALITYSORT_STRINGS = nil

ZO_CreateStringId("SI_QUALITYSORT_LEVEL", GetString(SI_ITEM_FORMAT_STR_LEVEL) .. GetString(SI_LIST_COMMA_SEPARATOR) .. GetString(SI_CAMPAIGNLEVELREQUIREMENTTYPE2))
ZO_CreateStringId("SI_QUALITYSORT_TRAIT", 
  GetString(SI_SPECIALIZEDITEMTYPE2000) 
  .. GetString(SI_LIST_COMMA_SEPARATOR) .. GetString(SI_SPECIALIZEDITEMTYPE2050) 
  .. GetString(SI_LIST_COMMA_SEPARATOR) .. GetString(SI_SPECIALIZEDITEMTYPE2950)
)