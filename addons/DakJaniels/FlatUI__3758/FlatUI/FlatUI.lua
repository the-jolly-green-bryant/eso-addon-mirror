local FlatUI = {
  AddonName = "FlatUI",
  major = "1",
  minor = "0",
  patch = "0",
  build = "0",
  current_api = 101040,
  future_api = 101041,
}

FlatUI.MakeThemFlat = function ()

local textureRedirects = {
    ["esoui/art/unitframes/unitframe_group_left.dds"]                                              = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitframes/unitframe_group_outline_left.dds"]                                      = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitframes/unitframe_group_outline_right.dds"]                                     = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitframes/unitframe_group_right.dds"]                                             = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitframes/unitframe_group_withcompanion.dds"]                                     = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/performance/statusmetermunge.dds"]                                                 = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable_munge.dds"]              = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_invulnerable_munge.dds"]   = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/itemtooltip/item_chargemeter_bar_genericfill_gloss.dds"]                           = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/itemtooltip/item_chargemeter_bar_leadingedge_gloss.dds"]                           = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_championbar_fill_gloss.dds"]                              = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_championbar_leadingedge_gloss.dds"]                       = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar30_gloss.dds"]                                  = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar30_leadingedge_gloss.dds"]                      = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_extralarge_genericfill_gloss.dds"]             = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_extralarge_genericfill_leadingedge_gloss.dds"] = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_gloss.dds"]                             = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_leadingedge_gloss.dds"]                 = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/progressbar_genericfill_gloss.dds"]                                  = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds"]                      = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/progressbar_large_genericfill_gloss.dds"]                            = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/progressbar_large_genericfill_leadingedge_gloss.dds"]                = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/timerbar_genericfill_gloss.dds"]                                     = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/miscellaneous/timerbar_genericfill_leadingedge_gloss.dds"]                         = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds"]                      = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds"]               = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds"]                 = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds"]            = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_fill_gloss.dds"]           = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_leadingedge_gloss.dds"]    = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_fill_center_gloss.dds"]      = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_fill_leadingedge_gloss.dds"] = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_fill_gloss.dds"]              = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_leadingedge_gloss.dds"]       = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/targetbar_dynamic_fill_gloss.dds"]                         = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
    ["esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge_gloss.dds"]                  = "esoui/art/icons/heraldrycrests_misc_blank_01.dds",
}

for originalTexture, newTexture in pairs(textureRedirects) do
    RedirectTexture(originalTexture, newTexture)
end

end

FlatUI.EnableHooks = function ()
    SetCVar("PPFXOverlaysEnabled", "0")
    ZO_ActionBar1KeybindBG:SetHidden(true)
    ZO_ProvisionerTopLevelTooltipGlow:SetHidden(true)
    PopupTooltipBGMungeOverlay:SetHidden(true)
    ZO_MailInboxMessageBGLeft:SetHidden(true)
    ZO_MailInboxMessageBGRight:SetHidden(true)
    ZO_EnchantingTopLevelTooltipBGMungeOverlay:SetBlendMode(1)
    ZO_SmithingTopLevelCreationPanelResultTooltipBGMungeOverlay:SetBlendMode(1)
end

FlatUI.Startup = function ()
    FlatUI.EnableHooks()
    FlatUI.MakeThemFlat()
end

FlatUI.PlayerActivated = function (eventCode)
    EVENT_MANAGER:UnregisterForEvent(FlatUI.AddonName, eventCode)
    FlatUI.Startup()
end

FlatUI.OnAddOnLoaded = function (eventCode, AddonName)
    if AddonName ~= FlatUI.AddonName then
        EVENT_MANAGER:UnregisterForEvent(FlatUI.AddonName, EVENT_ADD_ON_LOADED)
        EVENT_MANAGER:RegisterForEvent(FlatUI.AddonName, EVENT_PLAYER_ACTIVATED, FlatUI.PlayerActivated)
    end
end

EVENT_MANAGER:RegisterForEvent(FlatUI.AddonName, EVENT_ADD_ON_LOADED, FlatUI.OnAddOnLoaded)
