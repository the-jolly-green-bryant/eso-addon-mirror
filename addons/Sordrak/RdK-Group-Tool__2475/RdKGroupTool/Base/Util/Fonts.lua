-- RdK Group Tool Fonts
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts

RdKGToolFonts.constants = {}
RdKGToolFonts.constants.COMPLEX_FONT = "$(%s)|$(%s_%d)|%s"
RdKGToolFonts.constants.SIMPLE_FONT = "$(%s)|$(%s_%d)"

RdKGToolFonts.constants.INPUT_KB = 1
RdKGToolFonts.constants.INPUT_GP = 2

RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK = 1
RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN = 2
RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE = 3

RdKGToolFonts.constants.MEDIUM_FONT = 1
RdKGToolFonts.constants.BOLD_FONT = 2
RdKGToolFonts.constants.CHAT_FONT = 3
RdKGToolFonts.constants.GAMEPAD_LIGHT_FONT = 4
RdKGToolFonts.constants.GAMEPAD_MEDIUM_FONT = 5
RdKGToolFonts.constants.GAMEPAD_BOLD_FONT = 6
RdKGToolFonts.constants.ANTIQUE_FONT = 7
RdKGToolFonts.constants.HANDWRITTEN_FONT = 8
RdKGToolFonts.constants.STONE_TABLET_FONT = 9


RdKGToolFonts.config = {}
RdKGToolFonts.config.sizes = {}
RdKGToolFonts.config.sizes.names = {}
RdKGToolFonts.config.sizes.names[RdKGToolFonts.constants.INPUT_KB] = "KB"
RdKGToolFonts.config.sizes.names[RdKGToolFonts.constants.INPUT_GP] = "GP"
RdKGToolFonts.config.sizes.kb = {}
RdKGToolFonts.config.sizes.kb[1] = 8
RdKGToolFonts.config.sizes.kb[2] = 9
RdKGToolFonts.config.sizes.kb[3] = 10
RdKGToolFonts.config.sizes.kb[4] = 11
RdKGToolFonts.config.sizes.kb[5] = 12
RdKGToolFonts.config.sizes.kb[6] = 13
RdKGToolFonts.config.sizes.kb[7] = 14
RdKGToolFonts.config.sizes.kb[8] = 15
RdKGToolFonts.config.sizes.kb[9] = 16
RdKGToolFonts.config.sizes.kb[10] = 17
RdKGToolFonts.config.sizes.kb[11] = 18
RdKGToolFonts.config.sizes.kb[12] = 19
RdKGToolFonts.config.sizes.kb[13] = 20
RdKGToolFonts.config.sizes.kb[14] = 21
RdKGToolFonts.config.sizes.kb[15] = 22
RdKGToolFonts.config.sizes.kb[16] = 23
RdKGToolFonts.config.sizes.kb[17] = 24
RdKGToolFonts.config.sizes.kb[18] = 25
RdKGToolFonts.config.sizes.kb[19] = 26
RdKGToolFonts.config.sizes.kb[20] = 28
RdKGToolFonts.config.sizes.kb[21] = 30
RdKGToolFonts.config.sizes.kb[22] = 32
RdKGToolFonts.config.sizes.kb[23] = 34
RdKGToolFonts.config.sizes.kb[24] = 36
RdKGToolFonts.config.sizes.kb[25] = 40
RdKGToolFonts.config.sizes.kb[26] = 48
RdKGToolFonts.config.sizes.kb[27] = 54

RdKGToolFonts.config.sizes.gp = {}
RdKGToolFonts.config.sizes.gp[1] = 18
RdKGToolFonts.config.sizes.gp[2] = 20
RdKGToolFonts.config.sizes.gp[3] = 22
RdKGToolFonts.config.sizes.gp[4] = 25
RdKGToolFonts.config.sizes.gp[5] = 27
RdKGToolFonts.config.sizes.gp[6] = 30
RdKGToolFonts.config.sizes.gp[7] = 34
RdKGToolFonts.config.sizes.gp[8] = 36
RdKGToolFonts.config.sizes.gp[9] = 42
RdKGToolFonts.config.sizes.gp[10] = 45
RdKGToolFonts.config.sizes.gp[11] = 48
RdKGToolFonts.config.sizes.gp[12] = 54
RdKGToolFonts.config.sizes.gp[13] = 61

RdKGToolFonts.config.styles = {}
RdKGToolFonts.config.styles[RdKGToolFonts.constants.MEDIUM_FONT] = "MEDIUM_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.BOLD_FONT] = "BOLD_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.CHAT_FONT] = "CHAT_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.GAMEPAD_LIGHT_FONT] = "GAMEPAD_LIGHT_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.GAMEPAD_MEDIUM_FONT] = "GAMEPAD_MEDIUM_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.GAMEPAD_BOLD_FONT] = "GAMEPAD_BOLD_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.ANTIQUE_FONT] = "ANTIQUE_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.HANDWRITTEN_FONT] = "HANDWRITTEN_FONT"
RdKGToolFonts.config.styles[RdKGToolFonts.constants.STONE_TABLET_FONT] = "STONE_TABLET_FONT"


RdKGToolFonts.config.weights = {}
RdKGToolFonts.config.weights[RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK] = "soft-shadow-thick"
RdKGToolFonts.config.weights[RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN] = "soft-shadow-thin"
RdKGToolFonts.config.weights[RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE] = "thick-outline"

function RdKGToolFonts.CreateFontString(style, inputType, size, weight)
	local fontString = nil
	if style ~= nil and inputType ~= nil and size ~= nil then
		style = RdKGToolFonts.config.styles[style]
		local inputTypeString = RdKGToolFonts.config.sizes.names[inputType]
		if style ~= nil and inputTypeString ~= nil then
			local sizes = nil
			if inputType == RdKGToolFonts.constants.INPUT_KB then
				sizes = RdKGToolFonts.config.sizes.kb
			elseif inputType == RdKGToolFonts.constants.INPUT_GP then
				sizes = RdKGToolFonts.config.sizes.gp
			end
			if sizes ~= nil then
				for i = 1, #sizes do
					if i == 1 and sizes[1] > size then
						size = sizes[1]
						break
					elseif sizes[i] == size then
						break
					elseif sizes[i] > size then
						size = sizes[i - 1]
						break
					elseif sizes[i + 1] == nil then
						size = sizes[i]
					end
				end
				if weight ~= nil then
					weight = RdKGToolFonts.config.weights[weight]
					if weight ~= nil then
						fontString = string.format(RdKGToolFonts.constants.COMPLEX_FONT, style, inputTypeString, size, weight)
					end
				else
					fontString = string.format(RdKGToolFonts.constants.SIMPLE_FONT, style, inputTypeString, size)
				end
			end
		end
	end
	return fontString
end

