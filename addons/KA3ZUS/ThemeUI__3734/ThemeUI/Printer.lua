
local IS_PLURAL = true
local IS_UPPAER = false
local function chatPrinter(input)
    if Options_Gameplay_DefaultSoulGemDropdownDropdownScroll1Row1Label:IsControlHidden() == false then
        Options_Gameplay_DefaultSoulGemDropdownDropdownScroll1Row1Label:SetText("test12")
    end
    
end

SLASH_COMMANDS["/printer"] = chatPrinter