LibExoYsUtilities = LibExoYsUtilities or {}

local LibExoY = LibExoYsUtilities

local Dialogs = {}

-- exposed functions 
function LibExoY.WarningDialog(title, text)
    ESO_Dialogs[Dialogs.warning].title = {text = title}
    ESO_Dialogs[Dialogs.warning].mainText = {text = text}
     ZO_Dialogs_ShowDialog(Dialogs.warning)
end 



local function Initialize() 
    Dialogs = {
        warning = "LibExoYsUtilities_Dialog_Warning",
      }
    
    -- warning dialog 
    ESO_Dialogs[Dialogs.warning] = {
        uniqueIdentifier = Dialogs.warning,
        canQueue = true, 
        buttons = {
            [1] = {
                text = SI_OK,
                callback = function() end
            },
        },
    }
end

LibExoY.Dialogs_InitFunc = Initialize
