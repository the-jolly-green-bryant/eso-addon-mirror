-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- English localization for Near's Quick Bind
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local strings = {
    SI_BINDING_NAME_NQB_bind    = 'Bind current item',
    NQB_BindLabel               = 'Bind',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
