LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities


--[[ ----------- ]]
--[[ -- FONTs -- ]]
--[[ ----------- ]]

local fonts = {
  [1] = "Univers57",
  [2] = "Univers67", 
  [3] = "ProseAntique",
  [4] = "Handwritten",
  [5] = "StoneTablet",
  [6] = "FuturaLight",
  [7] = "FuturaMedium",
  [8] = "FuturaBold",
}

local fontPath = {
  ["Univers57"] = "EsoUI/Common/Fonts/Univers57.otf", 
  ["Univers67"] = "EsoUI/Common/Fonts/Univers67.otf",
  ["ProseAntique"] = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
  ["Handwritten"] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
  ["StoneTablet"] = "EsoUI/Common/Fonts/TrajanPro-Regular.otf", 
  ["FuturaLight"] = "EsoUI/Common/Fonts/FTN47.otf", 
  ["FuturaMedium"] = "EsoUI/Common/Fonts/FTN57.otf", 
  ["FuturaBold"] = "EsoUI/Common/Fonts/FTN87.otf",
}

local outlines = {
  [1] = "soft-shadow-thin",
  [2] = "soft-shadow-thick", 
  [3] = "thick-outline", 
}

local defaultFont = 2     -- Univers67
local defaultOutline = 2  -- soft-shadow-thick
local defaultSize = 18

local defaultFontData = {
  size = defaultSize, 
  font = fonts[defaultFont], 
  outline = outlines[defaultOutline],
}
local function GetDefaultFontData() 
  return ZO_ShallowTableCopy(defaultFontData)
end

--[[ ------------------------------- ]]
--[[ -- Exposed Functions (Fonts) -- ]]
--[[ ------------------------------- ]]

-- TributesEnhancementMenu.lua

function LibExoY.GetFontList() 
  return ZO_ShallowTableCopy(fonts)
end


function LibExoY.GetOutlineList() 
  return ZO_ShallowTableCopy(outlines)
end


function LibExoY.GetDefaultFontData() 
  return ZO_ShallowTableCopy(defaultFontData)
end


function LibExoY.GetOutlineNumber(outline)
  return LibExoY.FindNumericKey(outlines, outline, defaultOutline) 
end


function LibExoY.GetFontNumber(font) 
  return LibExoY.FindNumericKey(fonts, font, defaultFont)
end


-- TributesEnhancementGui.lua
-- ExoYsUserInterface
-- CruxTracker

function LibExoY.GetFont(param)
  local data = GetDefaultFontData()

  if LibExoY.IsTable(param) then 
    data = param
  end
  if LibExoY.IsNumber(param) then 
      data.size = param
  end
  return string.format( "%s|%d|%s", fontPath[data.font] , data.size , data.outline )

end 

--[[ --------------------------- ]]
--[[ -- Implementation (Font) -- ]] 
--[[ --------------------------- ]]

---------------------------------
-- How to create font selection --
----------------------------------
--[[

*MenuEntry =
{
  type = "dropdown",
  choices = Lib.GetFontList()
  getFunc = function() return store.data.font end,
  setFunc = function(selection)
    store.data.font = selection
    Gui:SetFont( store.data )
  end,
}

]]
