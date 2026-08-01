local strings = {
  DW_ARPB_STR_ADDON_NAME = "Alliance Rank Progress",
  DW_ARPB_STR_TO_NEXT_RANK = " AP until next rank",
  DW_ARPB_STR_SETTINGS = "Settings",
  DW_ARPB_STR_COLOUR_SCHEME = "Colour scheme",
  DW_ARPB_STR_COLOUR_SCHEME_WH = "White",
  DW_ARPB_STR_COLOUR_SCHEME_AL = "Alliance",
  DW_ARPB_STR_COLOUR_SCHEME_GR = "AP Green",
  DW_ARPB_STR_METER_TYPE = "Meter type",
  DW_ARPB_STR_METER_TYPE_NN = "# / #",
  DW_ARPB_STR_METER_TYPE_TONEXT = "# until next rank",
  DW_ARPB_STR_SHOW_IN_AVA = "Show only in PvP zones",
  DW_ARPB_STR_SWAP_ICONS = "Swap rank and alliance icon positions",
  DW_ARPB_STR_POS_X = "X Position",
  DW_ARPB_STR_POS_Y = "Y Position"
  -- DW_ARPB_STR_ = "",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
