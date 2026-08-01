-- RdK Group Tool Util Beams
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.beams = RdKGToolUtil.beams or {}
local RdKGToolBeams = RdKGToolUtil.beams

RdKGToolBeams.constants = {}
RdKGToolBeams.constants.beams = {}
RdKGToolBeams.constants.beams.BEAM_1 = 1
RdKGToolBeams.constants.beams.BEAM_2 = 2
RdKGToolBeams.constants.beams.BEAM_3 = 3
RdKGToolBeams.constants.beams.BEAM_4 = 4
RdKGToolBeams.constants.beams.BEAM_5 = 5
RdKGToolBeams.constants.beams.BEAM_6 = 6
RdKGToolBeams.constants.beams.BEAM_7 = 7
RdKGToolBeams.constants.beams.BEAM_8 = 8
RdKGToolBeams.constants.beams.BEAM_9 = 9
RdKGToolBeams.constants.beams.BEAM_10 = 10
RdKGToolBeams.constants.BEAM = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].texture = "RdKGroupTool/Art/3DObjects/Beam1.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].height = 256
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].heightOffset = 0
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].texture = "RdKGroupTool/Art/3DObjects/Beam2.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].height = 256
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].heightOffset = 0
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].texture = "RdKGroupTool/Art/3DObjects/Beam3.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].height = 256
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].heightOffset = 0
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].texture = "RdKGroupTool/Art/3DObjects/Beam4.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].height = 256
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].heightOffset = 0
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].texture = "RdKGroupTool/Art/3DObjects/Circle1.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].ignoreSize = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].height = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].heightOffset = 4
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].texture = "RdKGroupTool/Art/3DObjects/Circle1.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].usesDepthBuffer = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].ignoreSize = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].height = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].heightOffset = 4
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].texture = "RdKGroupTool/Art/3DObjects/Circle2.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].ignoreSize = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].height = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].heightOffset = 4
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].texture = "RdKGroupTool/Art/3DObjects/Circle2.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].usesDepthBuffer = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].ignoreSize = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].height = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].heightOffset = 4
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].texture = "RdKGroupTool/Art/3DObjects/Arrows1.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].height = 128
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].heightOffset = -2
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10] = {}
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].texture = "RdKGroupTool/Art/3DObjects/Arrows2.dds"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].usesDepthBuffer = true
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].ignoreSize = false
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].height = 128
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].width = 1
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].heightOffset = -2

function RdKGToolBeams.GetBeamByBeamId(beamId)
	return RdKGToolBeams.constants.BEAM[beamId]
end

function RdKGToolBeams.GetBeamIds()
	return RdKGToolBeams.constants.beams
end

function RdKGToolBeams.GetBeams()
	return RdKGToolBeams.constants.BEAM
end

function RdKGToolBeams.GetBeamNames()
	local beams = {}
	for i = 1, #RdKGToolBeams.constants.BEAM do
		beams[i] = RdKGToolBeams.constants.BEAM[i].name
	end
	return beams
end

function RdKGToolBeams.GetBeamIdByName(name)
	local index = 0
	if name ~= nil then
		for i = 1, #RdKGToolBeams.constants.BEAM do
			if RdKGToolBeams.constants.BEAM[i].name == name then
				index = i
				break
			end
		end
	end
	return index
end