--Addon libraries
AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters
local util = AF.util

--Load the libraries and output error messages if anything is missing -> Loaded in EVENT_ADD_ON_LOADED
AF.dependenciesLoaded = false

--Load the libraries and show error message if load failed (only if parameter calledFromEventPlayerActivated == true as
--then the chat is ready for output!)
function AF.loadLibraries(calledFromEventPlayerActivated)
    calledFromEventPlayerActivated = calledFromEventPlayerActivated or false
    local strings = AF.strings
    local libMissingString = strings.errorLibraryMissing

    ------------------------------------------------------------------------------------------------------------------------
    --LibFilters-3.0
    util.LibFilters = LibFilters3
    if not util.LibFilters and calledFromEventPlayerActivated then d(string.format(libMissingString, "LibFilters-3.0")) return end

    --LibAddonMenu-2.0
    AF.LAM = LibAddonMenu2
    if not AF.LAM and calledFromEventPlayerActivated then d(string.format(libMissingString, "LibAddonMenu-2.0")) return end
    ------------------------------------------------------------------------------------------------------------------------
    --LibMotifCategories
    util.LibMotifCategories = LibMotifCategories

    --LibScrollableMenu
    AF.LSM = LibScrollableMenu

    AF.dependenciesLoaded = true
end

--Add localized library dependent texts to the global string table
function AF.addLibrariesStrings()
    --LibMotifCategories
    if util.LibMotifCategories ~= nil then
        AF.strings.NormalStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_NORMAL)
        AF.strings.RareStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_RARE)
        AF.strings.AllianceStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_ALLIANCE)
        AF.strings.ExoticStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_EXOTIC)
        AF.strings.DroppedStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_DROPPED)
        AF.strings.CrownStyle = util.LibMotifCategories:GetLocalizedCategoryName(LMC_MOTIF_CATEGORY_CROWN)
    else
        AF.strings.NormalStyle = "Normal"
        AF.strings.RareStyle = "Rare"
        AF.strings.AllianceStyle = "Alliance"
        AF.strings.ExoticStyle = "Exotic"
        AF.strings.DroppedStyle = "Dropped"
        AF.strings.CrownStyle = "Crown"
    end
end

--Check if needed libraries are given -> Chat is NOT activated here so we cannot see error messages in chat, but we need to
--create the libraries already in order to use them in plugins and other data loaded in main.lua or the AdvancedFilters.txt
--extra filters!
if AF.dependenciesLoaded == false then AF.loadLibraries(false) end
--Libraries were loaded properly?
if AF.dependenciesLoaded == true then AF.addLibrariesStrings() end
