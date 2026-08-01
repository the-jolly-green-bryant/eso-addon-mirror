----------------------------------------
-- Polish localization for Inventory Grid View --
-- Translated by Skrybowie Tamriel --
----------------------------------------
local strings = {
    ["SI_INVENTORYGRIDVIEW_ADDON_NAME"] = "Widok siatki ekwipunku",

    ["SI_INVENTORYGRIDVIEW_OFFSETITEMTOOLTIPS_CHECKBOX_LABEL"] = "Przesunięcie opisów przedmiotów.",
    ["SI_INVENTORYGRIDVIEW_OFFSETITEMTOOLTIPS_CHECKBOX_TOOLTIP"] = "Przesuwa opis przedmiotu na lewo listy, by nie zasłaniał siatki.",
	
    ["SI_INVENTORYGRIDVIEW_SKIN_DROPDOWN_LABEL"] = "Skórka",
    ["SI_INVENTORYGRIDVIEW_SKIN_DROPDOWN_TOOLTIP"] = "Zestaw tekstur do użycia w widoku siatki.",

    ["SI_INVENTORYGRIDVIEW_QUALITYOUTLINES_CHECKBOX_LABEL"] = "Obramówki jakości",
    ["SI_INVENTORYGRIDVIEW_QUALITYOUTLINES_CHECKBOX_TOOLTIP"] = "Widoczna obramówka do ikon siatki.",

    ["SI_INVENTORYGRIDVIEW_MINOUTLINEQUALITY_DROPDOWN_LABEL"] = "Minimalna jakość obramówki.",
    ["SI_INVENTORYGRIDVIEW_MINOUTLINEQUALITY_DROPDOWN_TOOLTIP"] = "Obramówki jakości będą wyświetlane tylko na przedmiotach o tej samej, lub wyższej jakości.", 

    ["SI_INVENTORYGRIDVIEW_GRIDICONSIZE_SLIDER_LABEL"] = "Rozmiar ikon",
    ["SI_INVENTORYGRIDVIEW_GRIDICONSIZE_SLIDER_TOOLTIP"] = "Ustawia jak duże będą ikony. Obszar ikony to kwadrat tej liczby.",

    ["SI_INVENTORYGRIDVIEW_ICONZOOMLEVEL_SLIDER_LABEL"] = "Poziom przybliżenia ikon",
    ["SI_INVENTORYGRIDVIEW_ICONZOOMLEVEL_SLIDER_TOOLTIP"] = "Zmienia poziom przybliżenia ikon (na myszy) od żadnego do domyślnego.",

    ["SI_BINDING_NAME_INVENTORYGRIDVIEW_TOGGLE"] = "Przełącz widok siatka/lista",
    
    ["SI_BINDING_NAME_INVENTORYGRIDVIEW_DEBUG"] = "Debugowanie",
    ["SI_BINDING_NAME_INVENTORYGRIDVIEW_DEBUG_TOOLTIP"] = "Odblokowuje/blokuje debugowanie.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end