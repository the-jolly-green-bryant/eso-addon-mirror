local strings = {
	DICE_ROLLEDVERBOSE			= "Dice rolled <<1>> with <<2>>. Results : <<3>>",
	DICE_ROLLED					= "Dice rolled <<1>>.",
	DICE_UNKNOWNCOMMAND			= "Dice : Unknown Command : ''<<1>>''."
}


for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
