-- Create namespace
DsRGuildfonts = {}
local DsRGuildfonts = DsRGuildfonts  or {}

DsRGuildfonts.name = "DsRGuildfonts"

DsRGuildfonts.constants = {}
DsRGuildfonts.constants.COMPLEX_FONT = "$(%s)|$(%s_%d)|%s"
DsRGuildfonts.constants.SIMPLE_FONT = "$(%s)|$(%s_%d)"

DsRGuildfonts.constants.INPUT_KB = 1
DsRGuildfonts.constants.INPUT_GP = 2

DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THICK = 1
DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THIN = 2
DsRGuildfonts.constants.WEIGHT_THICK_OUTLINE = 3

DsRGuildfonts.constants.MEDIUM_FONT = 1
DsRGuildfonts.constants.BOLD_FONT = 2
DsRGuildfonts.constants.CHAT_FONT = 3
DsRGuildfonts.constants.GAMEPAD_LIGHT_FONT = 4
DsRGuildfonts.constants.GAMEPAD_MEDIUM_FONT = 5
DsRGuildfonts.constants.GAMEPAD_BOLD_FONT = 6
DsRGuildfonts.constants.ANTIQUE_FONT = 7
DsRGuildfonts.constants.HANDWRITTEN_FONT = 8
DsRGuildfonts.constants.STONE_TABLET_FONT = 9


DsRGuildfonts.config = {}
DsRGuildfonts.config.sizes = {}
DsRGuildfonts.config.sizes.names = {}
DsRGuildfonts.config.sizes.names[DsRGuildfonts.constants.INPUT_KB] = "KB"
DsRGuildfonts.config.sizes.names[DsRGuildfonts.constants.INPUT_GP] = "GP"
DsRGuildfonts.config.sizes.kb = {}
DsRGuildfonts.config.sizes.kb[1] = 8
DsRGuildfonts.config.sizes.kb[2] = 9
DsRGuildfonts.config.sizes.kb[3] = 10
DsRGuildfonts.config.sizes.kb[4] = 11
DsRGuildfonts.config.sizes.kb[5] = 12
DsRGuildfonts.config.sizes.kb[6] = 13
DsRGuildfonts.config.sizes.kb[7] = 14
DsRGuildfonts.config.sizes.kb[8] = 15
DsRGuildfonts.config.sizes.kb[9] = 16
DsRGuildfonts.config.sizes.kb[10] = 17
DsRGuildfonts.config.sizes.kb[11] = 18
DsRGuildfonts.config.sizes.kb[12] = 19
DsRGuildfonts.config.sizes.kb[13] = 20
DsRGuildfonts.config.sizes.kb[14] = 21
DsRGuildfonts.config.sizes.kb[15] = 22
DsRGuildfonts.config.sizes.kb[16] = 23
DsRGuildfonts.config.sizes.kb[17] = 24
DsRGuildfonts.config.sizes.kb[18] = 25
DsRGuildfonts.config.sizes.kb[19] = 26
DsRGuildfonts.config.sizes.kb[20] = 28
DsRGuildfonts.config.sizes.kb[21] = 30
DsRGuildfonts.config.sizes.kb[22] = 32
DsRGuildfonts.config.sizes.kb[23] = 34
DsRGuildfonts.config.sizes.kb[24] = 36
DsRGuildfonts.config.sizes.kb[25] = 40
DsRGuildfonts.config.sizes.kb[26] = 48
DsRGuildfonts.config.sizes.kb[27] = 54

DsRGuildfonts.config.sizes.gp = {}
DsRGuildfonts.config.sizes.gp[1] = 18
DsRGuildfonts.config.sizes.gp[2] = 20
DsRGuildfonts.config.sizes.gp[3] = 22
DsRGuildfonts.config.sizes.gp[4] = 25
DsRGuildfonts.config.sizes.gp[5] = 27
DsRGuildfonts.config.sizes.gp[6] = 30
DsRGuildfonts.config.sizes.gp[7] = 34
DsRGuildfonts.config.sizes.gp[8] = 36
DsRGuildfonts.config.sizes.gp[9] = 42
DsRGuildfonts.config.sizes.gp[10] = 45
DsRGuildfonts.config.sizes.gp[11] = 48
DsRGuildfonts.config.sizes.gp[12] = 54
DsRGuildfonts.config.sizes.gp[13] = 61

DsRGuildfonts.config.styles = {}
DsRGuildfonts.config.styles[DsRGuildfonts.constants.MEDIUM_FONT] = "MEDIUM_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.BOLD_FONT] = "BOLD_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.CHAT_FONT] = "CHAT_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.GAMEPAD_LIGHT_FONT] = "GAMEPAD_LIGHT_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.GAMEPAD_MEDIUM_FONT] = "GAMEPAD_MEDIUM_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.GAMEPAD_BOLD_FONT] = "GAMEPAD_BOLD_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.ANTIQUE_FONT] = "ANTIQUE_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.HANDWRITTEN_FONT] = "HANDWRITTEN_FONT"
DsRGuildfonts.config.styles[DsRGuildfonts.constants.STONE_TABLET_FONT] = "STONE_TABLET_FONT"


DsRGuildfonts.config.weights = {}
DsRGuildfonts.config.weights[DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THICK] = "soft-shadow-thick"
DsRGuildfonts.config.weights[DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THIN] = "soft-shadow-thin"
DsRGuildfonts.config.weights[DsRGuildfonts.constants.WEIGHT_THICK_OUTLINE] = "thick-outline"

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildfonts.CreateFontString(style, inputType, size, weight)
	local fontString = nil
	if style ~= nil and inputType ~= nil and size ~= nil then
		style = DsRGuildfonts.config.styles[style]
		local inputTypeString = DsRGuildfonts.config.sizes.names[inputType]
		if style ~= nil and inputTypeString ~= nil then
			local sizes = nil
			if inputType == DsRGuildfonts.constants.INPUT_KB then
				sizes = DsRGuildfonts.config.sizes.kb
			elseif inputType == DsRGuildfonts.constants.INPUT_GP then
				sizes = DsRGuildfonts.config.sizes.gp
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
					weight = DsRGuildfonts.config.weights[weight]
					if weight ~= nil then
						fontString = string.format(DsRGuildfonts.constants.COMPLEX_FONT, style, inputTypeString, size, weight)
					end
				else
					fontString = string.format(DsRGuildfonts.constants.SIMPLE_FONT, style, inputTypeString, size)
				end
			end
		end
	end
	return fontString
end

