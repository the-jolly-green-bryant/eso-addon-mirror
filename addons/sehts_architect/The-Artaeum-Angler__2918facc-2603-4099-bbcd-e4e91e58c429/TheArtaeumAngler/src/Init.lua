TheArtaeumAngler = TheArtaeumAngler or {}

local Addon = TheArtaeumAngler

Addon.Name = "TheArtaeumAngler"
Addon.EventNamespace = "TheArtaeumAngler"
Addon.Debug = {
    enabled = false,
    overlayTitle = "The Artaeum Angler Debug",
    offsetX = 24,
    offsetY = 180,
}
Addon.Strings = {
    selectBait = "Select Bait",
    setBait = "Set Bait",
    close = "Close",
    next = "Next",
    previous = "Previous",
    promptHint = "Secondary Action: Open Bait Wheel",
    reelHint = "Fish on the line",
    chooseBait = "Choose Bait",
    noBait = "No Bait Ready",
    reelReady = "Reel In",
}
Addon.StateColors = {
    ready = { 0.82, 0.95, 0.72 },
    reel = { 0.97, 0.89, 0.46 },
    unknown = { 0.96, 0.84, 0.51 },
    empty = { 0.93, 0.46, 0.41 },
}
Addon.WaterTypeLabels = {
    foul = "Foul Water",
    lake = "Lake Water",
    mystic = "Mystic Water",
    ocean = "Saltwater",
    oily = "Oily Water",
    river = "River Water",
    unknown = "Unknown Water",
}
Addon.Textures = {
    emptyBait = "EsoUI/Art/Fishing/bait_emptySlot.dds",
}
