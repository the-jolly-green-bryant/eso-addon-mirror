
local strings = {
    NPNA_Looted                                     = 'Looted',

    NPNA_am_EnablePotentNirnAlert_name              = 'Enable Potent Nirncrux alert',
    NPNA_am_CustomItemAlert_name                    = 'Custom item alert',
    NPNA_am_EnableCustomItemAlert_name              = 'Enable custom item alert',
    NPNA_am_EnableCustomItemEditor_name             = 'Enable custom item editor',
    NPNA_am_CustomItem_name                         = 'Custom item',
    NPNA_am_SetItemName_name                        = 'Set item name',
    NPNA_am_SetItemName_warning                     = 'Will remove previously set custom item name',
    NPNA_am_button_create_name                      = 'Create item',
    NPNA_am_button_delete_name                      = 'Delete item',
    NPNA_am_ColorPicker_name                        = 'Custom items color picker',
    NPNA_am_ColorPicker_tooltip                     = 'Defines color for the custom items alert',
    NPNA_am_cmd_text                                = '"/pna" to open this menu',
}


for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
