SamisFishTrackerAddon = SamisFishTrackerAddon or {}

local SFT = SamisFishTrackerAddon

SFT.name = "SamisFishTracker"
SFT.version = "1.1.0"
SFT.author = "samihaize"

SFT.fishamount = 0
SFT.total_bag = 0
SFT.total_bank = 0

SFT.constants = {
  roeRate = 0.008,
  averageRateWindowSeconds = 300,
  windowHeightFull = 105,
  windowHeightCollapsed = 80,
  filletWindowHeight = 35,
  filletWindowWidth = 300,
  icons = {
    fish = "esoui/art/icons/crafting_fishing_perch.dds",
    bag = "esoui/art/tooltips/icon_bag.dds",
    bank = "esoui/art/tooltips/icon_bank.dds",
    roe = "/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds",
  },
  perfectRoeItemId = 64222,
  excludedFishItemIds = {
    [100393] = true,
    [100394] = true,
    [100395] = true,
  },
  visibility = {
    HIDE = 0,
    SHOW = 1,
    AUTO = 2,
  },
}
