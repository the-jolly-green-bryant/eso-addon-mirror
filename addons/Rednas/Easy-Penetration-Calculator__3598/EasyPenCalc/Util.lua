EPC = EPC or {}
EPC.Util = EPC.Util or {}

function EPC.Util.ClampNumber(numberToClamp, min, max)

	numberToClamp = numberToClamp > max and max or numberToClamp
	numberToClamp = numberToClamp < min and min or numberToClamp

	return numberToClamp
end

function EPC.Util.GetEsoRGBColorCodeFromArray(array)
	return array.r/255, array.g/255, array.b/255
end