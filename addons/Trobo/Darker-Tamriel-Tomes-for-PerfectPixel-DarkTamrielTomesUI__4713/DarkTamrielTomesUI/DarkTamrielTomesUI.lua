--[[
-------------------------------------------------------------------------------
-- Dark Tamriel Tomes UI, by @Masteroshi430, @Trobo (EU)
-------------------------------------------------------------------------------
]]

local ADDON_NAME = "DarkTamrielTomesUI"

DarkTamrielTomesUI = DarkTamrielTomesUI or {}

local function OnAddonLoaded(event, addonName)

    if addonName == ADDON_NAME then
    
		-- black
		RedirectTexture("/esoui/art/tamrieltomes/tome_page_selection_bg.dds", "DarkTamrielTomesUI/black/tome_page_selection_bg_blk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_bg.dds", "DarkTamrielTomesUI/black/tome_slot_bg_blk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_bg_solid.dds", "DarkTamrielTomesUI/black/tome_slot_bg_solid_blk.dds")
		
		-- khaki
		RedirectTexture("/esoui/art/tamrieltomes/selected_page_outline.dds", "DarkTamrielTomesUI/khaki/selected_page_outline_khk.dds")
		RedirectTexture("/esoui/Art/TamrielTomes/single_side_full_tome.dds", "DarkTamrielTomesUI/khaki/single_side_full_tome_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_group_premium_slots_border.dds", "DarkTamrielTomesUI/khaki/tome_group_premium_slots_border_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_outline.dds", "DarkTamrielTomesUI/khaki/tome_slot_outline_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_outline_square.dds", "DarkTamrielTomesUI/khaki/tome_slot_outline_square_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/two_page_open_tome.dds", "DarkTamrielTomesUI/khaki/two_page_open_tome_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_bg.dds", "DarkTamrielTomesUI/khaki/upgrade_tome_bg_khk.dds")
		RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_item_divider.dds", "DarkTamrielTomesUI/khaki/upgrade_tome_item_divider_khk.dds")
		
		-- orange
		RedirectTexture("/esoui/art/tamrieltomes/tome_premium_bg.dds", "DarkTamrielTomesUI/orange/tome_premium_bg_org.dds")
		
		-- transparent
		RedirectTexture("/esoui/art/tamrieltomes/tome_currency_backdrop.dds", "DarkTamrielTomesUI/trans/tome_currency_backdrop_tra.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_points_remaining_to_unlock_page_bg.dds", "DarkTamrielTomesUI/trans/tome_points_remaining_to_unlock_page_bg_tra.dds")
        RedirectTexture("/esoui/art/tamrieltomes/tome_rewards_title_bg.dds", "DarkTamrielTomesUI/trans/tome_rewards_title_bg_tra.dds")
        RedirectTexture("/esoui/art/tamrieltomes/tome_slot_currency_bg.dds", "DarkTamrielTomesUI/trans/tome_slot_currency_bg_tra.dds")
		RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_item_container.dds", "DarkTamrielTomesUI/trans/upgrade_tome_item_container_tra.dds")
        RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_titlebar_bg.dds", "DarkTamrielTomesUI/trans/upgrade_tome_titlebar_bg_tra.dds")
		
		SecurePostHook(ZO_TamrielTomesIntroScreen_Shared, "OnShowing", DarkTamrielTomesUI.ChangeFontColorsForIntro)
    end
end


local function ColorEntries(scrollChild, r, g, b, a)
    if not scrollChild then return end

    local numChildren = scrollChild:GetNumChildren()
    for i = 0, numChildren  do
        local entry = scrollChild:GetChild(i)
        if entry then
            local title = entry:GetNamedChild("Title")
            if title then
                title:SetColor(r, g, b, a)
            end

            local bodyText = entry:GetNamedChild("BodyText")
            if bodyText then
                bodyText:SetColor(r, g, b, a)
            end
        end
    end
end

function DarkTamrielTomesUI.ChangeFontColorsForIntro()

    local r, g, b, a = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)

    local titleLabelKB = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_KeyboardTLTitle")
    if titleLabelKB then
        titleLabelKB:SetColor(r, g, b, a)
    end

    local titleLabelGP = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_GamepadTLTitle")
    if titleLabelGP then
        titleLabelGP:SetColor(r, g, b, a)
    end

    local rightPageTextControlKB = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_KeyboardTLHighlightsScrollChild")
    ColorEntries(rightPageTextControlKB, r, g, b, a)

    local rightPageTextControlGP = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_GamepadTLHighlightsScrollChild")
    ColorEntries(rightPageTextControlGP, r, g, b, a)

end 


EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)