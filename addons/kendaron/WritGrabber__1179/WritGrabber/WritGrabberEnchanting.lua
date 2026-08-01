
local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local invalidLinkFormat = "|H1:item:%u:20:51:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local glyphQuality = {
  { quality = 20, level = 1 },
  { quality = 20, level = 6 },
  { quality = 20, level = 11 },
  { quality = 20, level = 16 },
  { quality = 20, level = 21 },
  { quality = 20, level = 26 },
  { quality = 20, level = 31 },
  { quality = 20, level = 36 },
  { quality = 20, level = 41 },
  { quality = 20, level = 50 },
  { quality = 112, level = 50 },
  { quality = 113, level = 36 },
  { quality = 115, level = 36 },
  { quality = 118, level = 36 },
  { quality = 120, level = 36 }
  }

local runes
local glyphs

WritGrabberEnchanting = {}
WritGrabberEnchanting.name = "WritGrabberEnchanting"
WritGrabberEnchanting.isInitalised = false

local function trace(msg)
  if WritGrabber.traceEnabled then
    WritGrabber:Trace(msg)
  end
end

function WritGrabberEnchanting:Initialise()
  local lang = GetCVar("language.2")
  
  for i = 1, #runes do
    local rune = runes[i]
    rune.link = string.format(testLinkFormat, rune.id)
    rune.name = zo_strformat("<<1>>", GetItemLinkName(rune.link)):lower()
  end
  
  local replaceText
  local replaceWith
  if lang == "en" then
    replaceText = "trifling "
    replaceWith = ".-%%s"
  elseif lang == "de" then
    replaceText = "unbedeutende "
    replaceWith = ".-%%s"
  elseif lang == "fr" then
    replaceText = "insignifiant"    
    replaceWith = ".-"
  end   

  for i = 1, #glyphs do
    local glyph = glyphs[i]
    glyph.link = string.format(testLinkFormat, glyph.id)
    glyph.name = zo_strformat("<<1>>", GetItemLinkName(glyph.link)):lower()
    if replaceText then
      glyph.matchName = string.gsub(glyph.name, replaceText, replaceWith, 1)
    end
    glyph.baseName = zo_strformat("<<1>>", glyph.link):lower()
    glyph.invalidLink = string.format(invalidLinkFormat, glyph.id)
    glyph.invalidName = GetItemLinkName(glyph.invalidLink)
    glyph.invalidBaseName = zo_strformat("<<1>>", glyph.invalidLink):lower()
  end
  
  self.isInitalised = true
end

function WritGrabberEnchanting:DumpGlyphs(nameOnly)
  for i = 1, #glyphs do
    local glyph = glyphs[i]
    if nameOnly then
      d(glyph.name)
    else    
      d(glyph)
    end
  end
end

function WritGrabberEnchanting:DumpRunes()
  for i = 1, #runes do
    local rune = runes[i]
    d(rune)
  end
end

function WritGrabberEnchanting:FindRune(text)
  
  if not self.isInitalised then
    self:Initialise()
  end
  
  local textLower = text:lower()
  for i = 1, #runes do
    local rune = runes[i]
    local startindex, endIndex = text:find(rune.name, 1, true)
    if startindex then
      return startindex, endIndex, rune
    end
  end
end

function WritGrabberEnchanting:FindGlyph(text)
  
  if not self.isInitalised then
    self:Initialise()
  end
  
  local textLower = text:lower()
  
  for i = 1, #glyphs do
    local glyph = glyphs[i]
    --trace("- Checking for "..glyph.name)
    local match = textLower:match(glyph.matchName)
    if match then
      return match, glyph
    end
  end
  --[[
  for i = 1, #glyphs do
    local glyph = glyphs[i]
    trace("- Checking for "..glyph.baseName)
    local startindex, endIndex = text:find(glyph.baseName)
    if startindex then
      return startindex, endIndex, glyph
    end
  end
  ]]--
end

runes  = 
                    {
                        [1] = 
                        {
                            ["id"] = 45839,
                        },
                        [2] = 
                        {
                            ["id"] = 45838,
                        },
                        [3] = 
                        {
                            ["id"] = 68342,
                        },
                        [4] = 
                        {
                            ["id"] = 45835,
                        },
                        [5] = 
                        {
                            ["id"] = 45848,
                        },
                        [6] = 
                        {
                            ["id"] = 45847,
                        },
                        [7] = 
                        {
                            ["id"] = 45842,
                        },
                        [8] = 
                        {
                            ["id"] = 45836,
                        },
                        [9] = 
                        {
                            ["id"] = 45806,
                        },
                        [10] = 
                        {
                            ["id"] = 68341,
                        },
                        [11] = 
                        {
                            ["id"] = 64509,
                        },
                        [12] = 
                        {
                            ["id"] = 45856,
                        },
                        [13] = 
                        {
                            ["id"] = 64508,
                        },
                        [14] = 
                        {
                            ["id"] = 45828,
                        },
                        [15] = 
                        {
                            ["id"] = 45852,
                        },
                        [16] = 
                        {
                            ["id"] = 45851,
                        },
                        [17] = 
                        {
                            ["id"] = 45853,
                        },
                        [18] = 
                        {
                            ["id"] = 45849,
                        },
                        [19] = 
                        {
                            ["id"] = 45824,
                        },
                        [20] = 
                        {
                            ["id"] = 45815,
                        },
                        [21] = 
                        {
                            ["id"] = 45814,
                        },
                        [22] = 
                        {
                            ["id"] = 45812,
                        },
                        [23] = 
                        {
                            ["id"] = 45818,
                        },
                        [24] = 
                        {
                            ["id"] = 45823,
                        },
                        [25] = 
                        {
                            ["id"] = 45808,
                        },
                        [26] = 
                        {
                            ["id"] = 68340,
                        },
                        [27] = 
                        {
                            ["id"] = 45841,
                        },
                        [28] = 
                        {
                            ["id"] = 45834,
                        },
                        [29] = 
                        {
                            ["id"] = 45844,
                        },
                        [30] = 
                        {
                            ["id"] = 45810,
                        },
                        [31] = 
                        {
                            ["id"] = 45809,
                        },
                        [32] = 
                        {
                            ["id"] = 45843,
                        },
                        [33] = 
                        {
                            ["id"] = 45832,
                        },
                        [34] = 
                        {
                            ["id"] = 45826,
                        },
                        [35] = 
                        {
                            ["id"] = 45822,
                        },
                        [36] = 
                        {
                            ["id"] = 45821,
                        },
                        [37] = 
                        {
                            ["id"] = 45837,
                        },
                        [38] = 
                        {
                            ["id"] = 45813,
                        },
                        [39] = 
                        {
                            ["id"] = 45811,
                        },
                        [40] = 
                        {
                            ["id"] = 45827,
                        },
                        [41] = 
                        {
                            ["id"] = 45855,
                        },
                        [42] = 
                        {
                            ["id"] = 45857,
                        },
                        [43] = 
                        {
                            ["id"] = 45830,
                        },
                        [44] = 
                        {
                            ["id"] = 45854,
                        },
                        [45] = 
                        {
                            ["id"] = 45833,
                        },
                        [46] = 
                        {
                            ["id"] = 45840,
                        },
                        [47] = 
                        {
                            ["id"] = 45820,
                        },
                        [48] = 
                        {
                            ["id"] = 45845,
                        },
                        [49] = 
                        {
                            ["id"] = 45817,
                        },
                        [50] = 
                        {
                            ["id"] = 45807,
                        },
                        [51] = 
                        {
                            ["id"] = 45816,
                        },
                        [52] = 
                        {
                            ["id"] = 45825,
                        },
                        [53] = 
                        {
                            ["id"] = 45829,
                        },
                        [54] = 
                        {
                            ["id"] = 45819,
                        },
                        [55] = 
                        {
                            ["id"] = 45846,
                        },
                        [56] = 
                        {
                            ["id"] = 45831,
                        },
                        [57] = 
                        {
                            ["id"] = 45850,
                        },
                    }
                    
glyphs = 
{
                        [1] = 
                        {
                            ["id"] = 54484,
                        },
                        [2] = 
                        {
                            ["id"] = 26591,
                        },
                        [3] = 
                        {
                            ["id"] = 26589,
                        },
                        [4] = 
                        {
                            ["id"] = 26588,
                        },
                        [5] = 
                        {
                            ["id"] = 43570,
                        },
                        [6] = 
                        {
                            ["id"] = 26844,
                        },
                        [7] = 
                        {
                            ["id"] = 45873,
                        },
                        [8] = 
                        {
                            ["id"] = 45870,
                        },
                        [9] = 
                        {
                            ["id"] = 45871,
                        },
                        [10] = 
                        {
                            ["id"] = 68344,
                        },
                        [11] = 
                        {
                            ["id"] = 68343,
                        },
                        [12] = 
                        {
                            ["id"] = 45875,
                        },
                        [13] = 
                        {
                            ["id"] = 45874,
                        },
                        [14] = 
                        {
                            ["id"] = 26586,
                        },
                        [15] = 
                        {
                            ["id"] = 26587,
                        },
                        [16] = 
                        {
                            ["id"] = 26583,
                        },
                        [17] = 
                        {
                            ["id"] = 26582,
                        },
                        [18] = 
                        {
                            ["id"] = 45883,
                        },
                        [19] = 
                        {
                            ["id"] = 45884,
                        },
                        [20] = 
                        {
                            ["id"] = 26581,
                        },
                        [21] = 
                        {
                            ["id"] = 26580,
                        },
                        [22] = 
                        {
                            ["id"] = 5366,
                        },
                        [23] = 
                        {
                            ["id"] = 5364,
                        },
                        [24] = 
                        {
                            ["id"] = 5365,
                        },
                        [25] = 
                        {
                            ["id"] = 26841,
                        },
                        [26] = 
                        {
                            ["id"] = 26849,
                        },
                        [27] = 
                        {
                            ["id"] = 26848,
                        },
                        [28] = 
                        {
                            ["id"] = 26847,
                        },
                        [29] = 
                        {
                            ["id"] = 45886,
                        },
                        [30] = 
                        {
                            ["id"] = 45885,
                        },
                        [31] = 
                        {
                            ["id"] = 45869,
                        },
                        [32] = 
                        {
                            ["id"] = 26845,
                        },
                        [33] = 
                        {
                            ["id"] = 45872,
                        },
                        [34] = 
                        {
                            ["id"] = 45867,
                        },
                        [35] = 
                        {
                            ["id"] = 45868,
                        },
                        [36] = 
                        {
                            ["id"] = 43573,
                        }
                    }