--[[
-------------------------------------------------------------------------------
-- Darker Tamriel tomes, by @Masteroshi430 (EU)
-------------------------------------------------------------------------------
]]

local ADDON_NAME = "DarkerTamrielTomes"

DarkerTamrielTomes = DarkerTamrielTomes or {}

local function OnAddonLoaded(event, addonName)

	if addonName == ADDON_NAME then
    
	
		-- black
		RedirectTexture("/esoui/art/tamrieltomes/tome_rewards_title_bg.dds", "DarkerTamrielTomes/black/tome_rewards_title_bg.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_currency_backdrop.dds", "DarkerTamrielTomes/black/tome_currency_backdrop.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_page_selection_bg.dds", "DarkerTamrielTomes/black/tome_page_selection_bg.dds")
		--RedirectTexture("/esoui/art/tamrieltomes/selected_page_outline.dds", "DarkerTamrielTomes/black/selected_page_outline.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_bg_solid.dds", "DarkerTamrielTomes/black/tome_slot_bg_solid.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_currency_bg.dds", "DarkerTamrielTomes/black/tome_slot_currency_bg.dds")
		RedirectTexture("/esoui/art/tamrieltomes/tome_slot_outline_square.dds", "DarkerTamrielTomes/black/tome_slot_outline_square.dds")
		--RedirectTexture("/esoui/art/tamrieltomes/tome_slot_bg.dds", "DarkerTamrielTomes/black/tome_slot_bg.dds")
		RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_item_divider.dds", "DarkerTamrielTomes/black/upgrade_tome_item_divider.dds")
		RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_titlebar_bg.dds", "DarkerTamrielTomes/black/upgrade_tome_titlebar_bg.dds")
    
    -- golden
	  --RedirectTexture("/esoui/art/tamrieltomes/selected_page_outline.dds", "DarkerTamrielTomes/golden/selected_page_outline.dds")
		  RedirectTexture("/esoui/art/tamrieltomes/tome_slot_bg.dds", "DarkerTamrielTomes/golden/tome_slot_bg.dds")
      
    -- white
	  RedirectTexture("/esoui/art/tamrieltomes/selected_page_outline.dds", "DarkerTamrielTomes/white/selected_page_outline.dds")
  
  
    -- darker tomes
    RedirectTexture("EsoUI/Art/TamrielTomes/single_side_full_tome.dds", "DarkerTamrielTomes/tome/single_side_full_tome.dds")
    RedirectTexture("/esoui/art/tamrieltomes/upgrade_tome_bg.dds", "DarkerTamrielTomes/tome/upgrade_tome_bg.dds")
    RedirectTexture("/esoui/art/tamrieltomes/two_page_open_tome.dds", "DarkerTamrielTomes/tome/two_page_open_tome.dds")

      SecurePostHook(ZO_TamrielTomesIntroScreen_Shared, "OnShowing", DarkerTamrielTomes.ChangeFontColorsForIntro)
	end
end


-- Colors every Title/BodyText control inside a scroll-child container.
-- Walks children by index (GetChild) and resolves labels via GetNamedChild,
-- instead of rebuilding a global control-name string and hitting
-- WINDOW_MANAGER:GetControlByName for every single label. That avoids both
-- the per-frame string concatenation and the (much more expensive) lookup
-- against the game's global control-name table, which holds every control
-- in the UI, not just the ones we care about.
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

function DarkerTamrielTomes.ChangeFontColorsForIntro()

    -- Fetch the highlight color once instead of once per label (it never
    -- changes between calls), and reuse it for every control below.
    local r, g, b, a = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)

    local titleLabelKB = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_KeyboardTLTitle")
    if titleLabelKB then
        titleLabelKB:SetColor(r, g, b, a) -- addon modified color
    end

    local titleLabelGP = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_GamepadTLTitle")
    if titleLabelGP then
        titleLabelGP:SetColor(r, g, b, a) -- addon modified color
    end

    local rightPageTextControlKB = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_KeyboardTLHighlightsScrollChild")
    ColorEntries(rightPageTextControlKB, r, g, b, a)

    local rightPageTextControlGP = WINDOW_MANAGER:GetControlByName("ZO_TamrielTomesIntro_GamepadTLHighlightsScrollChild")
    ColorEntries(rightPageTextControlGP, r, g, b, a)

end 


EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
