--------------------------------------------------
-- ShibUI Miscellaneous Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.Miscellaneous = SUI.Miscellaneous or {}
local Miscellaneous = SUI.Miscellaneous

local Log = function(...) SUI.Debug:Log("Miscellaneous", ...) end

--------------------------------------------------
-- Apply miscellaneous textures to blank textures.
--------------------------------------------------
local blankTexture = "/esoui/art/icons/heraldrycrests_misc_blank_01.dds"
local texturesToRedirect = {
    "/esoui/art/chatwindow/chat_minimized_mungebg.dds",
    "/esoui/art/itemtooltip/item_chargemeter.dds",
    "/esoui/art/performance/statusmetermunge.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_large_glow.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_large.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_small_glow.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_small.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_standard_glow.dds",
    "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_standard.dds",
}

local function TextureRedirect()
    for _, texturePath in ipairs(texturesToRedirect) do
        RedirectTexture(texturePath, blankTexture)
    end
end

function Miscellaneous:Initialize()
    sv = SUI.SavedVars.saved
    TextureRedirect()
    Log("Initialized")
end