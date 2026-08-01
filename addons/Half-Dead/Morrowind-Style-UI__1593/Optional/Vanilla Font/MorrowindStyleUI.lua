msi = {}
msi.appName = "MorrowindStyleUI"

local ADDON_VERSION = "1.14"

function msivanilla()

		RedirectTexture("esoui/art/interaction/conversation_textbg.dds", "esoui/art/interaction/conversation_textbg.dds")
		RedirectTexture("esoui/art/interaction/conversation_verticalborder.dds", "esoui/art/interaction/conversation_verticalborder.dds")
		RedirectTexture("esoui/art/loot/loot_windowbg.dds", "esoui/art/loot/loot_windowbg.dds")
		RedirectTexture("esoui/art/tooltips/ui-border.dds", "esoui/art/tooltips/ui-border.dds")
		RedirectTexture("esoui/art/tooltips/ui-tooltipcenter.dds", "esoui/art/tooltips/ui-tooltipcenter.dds")
		RedirectTexture("esoui/art/tooltips/ui-border-red.dds", "esoui/art/tooltips/ui-border-red.dds")
		RedirectTexture("esoui/art/miscellaneous/centerscreen_left.dds", "esoui/art/miscellaneous/centerscreen_left.dds")
		RedirectTexture("esoui/art/miscellaneous/centerscreen_right.dds", "esoui/art/miscellaneous/centerscreen_right.dds")
		RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "esoui/art/miscellaneous/bottom_bar.dds")
		RedirectTexture("esoui/art/miscellaneous/top_bar.dds", "esoui/art/miscellaneous/top_bar.dds")
		RedirectTexture("esoui/art/reticle/reticleanim.dds", "esoui/art/reticle/reticleanim.dds")
		RedirectTexture("esoui/art/compass/compass.dds", "/esoui/art/compass/compass.dds")
		RedirectTexture("esoui/art/miscellaneous/interactkeyframe_center.dds", "esoui/art/miscellaneous/interactkeyframe_center.dds")
		RedirectTexture("esoui/art/miscellaneous/interactkeyframe_edge.dds", "esoui/art/miscellaneous/interactkeyframe_edge.dds")
		RedirectTexture("MorrowindStyleUI/media/topbar.dds", "MorrowindStyleUI/media/blank.dds")
		RedirectTexture("MorrowindStyleUI/media/border.dds", "MorrowindStyleUI/media/blank.dds")
		RedirectTexture("MorrowindStyleUI/media/interactwindow.dds", "MorrowindStyleUI/media/blank.dds")

		end

function msiMorrowind()

		RedirectTexture("esoui/art/loot/loot_windowbg.dds", "MorrowindStyleUI/media/cont_background.dds")
		RedirectTexture("esoui/art/tooltips/ui-border.dds", "MorrowindStyleUI/media/tooltip_border.dds")
		RedirectTexture("esoui/art/tooltips/ui-tooltipcenter.dds", "MorrowindStyleUI/media/tooltip.dds")
		RedirectTexture("esoui/art/tooltips/ui-border-red.dds", "MorrowindStyleUI/media/tooltip_border_2.dds")
		RedirectTexture("esoui/art/miscellaneous/centerscreen_left.dds", "/MorrowindStyleUI/media/background.dds")
		RedirectTexture("esoui/art/miscellaneous/centerscreen_right.dds", "/MorrowindStyleUI/media/blank.dds")
		RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "/MorrowindStyleUI/media/blank.dds")
		RedirectTexture("esoui/art/miscellaneous/top_bar.dds", "/MorrowindStyleUI/media/blank.dds")
		RedirectTexture("esoui/art/reticle/reticleanim.dds", "/MorrowindStyleUI/media/crosshair.dds")
		RedirectTexture("/esoui/art/compass/compass.dds", "/MorrowindStyleUI/media/compass_c.dds")
		RedirectTexture("esoui/art/miscellaneous/interactkeyframe_center.dds", "MorrowindStyleUI/media/keycenter.dds")
		RedirectTexture("esoui/art/miscellaneous/interactkeyframe_edge.dds", "MorrowindStyleUI/media/key.dds")
		RedirectTexture("MorrowindStyleUI/media/topbar.dds", "MorrowindStyleUI/media/topbar.dds")
		RedirectTexture("MorrowindStyleUI/media/border.dds", "MorrowindStyleUI/media/border.dds")

	

	end

	
function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= msi.appName then return end
	
	local defaults = {
		Icon = "Morrowind Style UI"
	}

    msi.SV = ZO_SavedVars:NewAccountWide("MorrowindStyleUI_SavedVariables", ADDON_VERSION, defaults, nil)
	
	if msi.SV.Icon == "Vanilla UI" then
		msivanilla()
	elseif msi.SV.Icon == "Morrowind Style UI" then
		msiMorrowind()
	end
	
	msi:initLAM()
	
end
  
EVENT_MANAGER:RegisterForEvent(msi.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)