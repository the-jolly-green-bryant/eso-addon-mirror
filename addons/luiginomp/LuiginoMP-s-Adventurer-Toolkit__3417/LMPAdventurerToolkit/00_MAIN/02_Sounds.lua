SOUNDS = {}

function SOUNDS.PlayAddonActivated()
    PlaySound("Dialog_Accept")
end

function SOUNDS.PlayAddonDeactivated()
    PlaySound("Dialog_Decline")
end

function SOUNDS.PlayAlert()
    PlaySound("Voice_Chat_Alert_Channel_Made_Active")
end

function SOUNDS.PlayError()
    PlaySound("General_Alert_Error")
end