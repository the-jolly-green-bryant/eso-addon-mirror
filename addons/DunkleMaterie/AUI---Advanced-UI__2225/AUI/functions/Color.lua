local CLASS_COLOR_TEMPLAR = "#fed51c"
local CLASS_COLOR_NIGHTBLADE = "#ff6178"
local CLASS_COLOR_SORCERER = "#de90ff"
local CLASS_COLOR_DRAGONKNIGHT = "#ffd3ab"
local CLASS_COLOR_WARDEN = "#0cd702"

AUI.Color = {}

function AUI.Color.GetColor(_color)
	if _color then
		if _color and type(_color) == "function" then
			return _color()
		end
	end
	
	return _color
end

function AUI.Color.GetClassColor(_classId)
	local color = "#ffffff"

	if _classId == 1 then
		color = CLASS_COLOR_DRAGONKNIGHT
	elseif _classId == 2 then
		color = CLASS_COLOR_SORCERER
	elseif _classId == 3 then
		color = CLASS_COLOR_NIGHTBLADE
	elseif _classId == 4 then
		color = CLASS_COLOR_WARDEN			
	elseif _classId == 6 then
		color = CLASS_COLOR_TEMPLAR	
	end
	
	return color
end

function AUI.Color.ConvertHexToRGBA(hexCode, a)
   local alpha = 1

   if a then
      alpha = a  
   end
   
   assert(#hexCode == 7, "The hex value must be passed in the form of #XXXXXX");
   local hexCode = hexCode:gsub("#","")
   
   local r = tonumber("0x" .. hexCode:sub(1,2)) / 255
   local g = tonumber("0x" .. hexCode:sub(3,4)) / 255
   local b = tonumber("0x" .. hexCode:sub(5,6)) / 255
   local a = alpha

   return ZO_ColorDef:New(r, g, b, a)
end


function AUI.Color.GetColorDefFromNamedRGBA(list)
	if not list then
		return nil
	end

	return ZO_ColorDef:New(list.r, list.g, list.b, list.a)
end

function AUI.Color.GetColorDef(_color)
	if not _color or not _color[1] or not _color[2] then
		return nil
	end

	return {AUI.Color.GetColorDefFromNamedRGBA(_color[1]), AUI.Color.GetColorDefFromNamedRGBA(_color[2])}
end