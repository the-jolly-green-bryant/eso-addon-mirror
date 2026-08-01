LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities

--[[ ---------------- ]]
--[[ -- Panel Data -- ]]
--[[ ---------------- ]]

local function GetMenuPanelData( param )

    local isServerEU = GetWorldName() == "EU Megaserver"
    local displayName = param.displayName and param.displayName or param.name

    local function SendIngameMail() 
        SCENE_MANAGER:Show('mailSend')
        zo_callLater(function() 
                ZO_MailSendToField:SetText("@Exoy94")
                ZO_MailSendSubjectField:SetText( param.name )
                ZO_MailSendBodyField:TakeFocus()   
            end, 250)
    end


    local function FeedbackButton() 
        ClearMenu() 
        if isServerEU then 
            AddCustomMenuItem("Ingame Mail", SendIngameMail)
        end
        AddCustomMenuItem("Esoui.com", function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/"..param.esoui) end )  
        AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.com/invite/MjfPKsJAS9") end )  

        ShowMenu() 
    end

    local function DonationButton() 
        ClearMenu() 
        if isServerEU then 
            AddCustomMenuItem("Ingame Mail", SendIngameMail)
        end
        AddCustomMenuItem("Buy Me a Coffee!", function() RequestOpenUnsafeURL("https://www.buymeacoffee.com/exoy") end )  
        ShowMenu() 
    end



    return    
    {
        type                = "panel",
        name                = displayName,
        displayName         = displayName,
        author              = LibExoY.ColorString( "ExoY", "00FF00").." (PC/EU)",
        version             = LibExoY.ColorString( param.version, "FF8800") ,
        feedback            = FeedbackButton, 
        donation            = isServerEU and DonationButton or "https://www.buymeacoffee.com/exoy",
        registerForRefresh = true,
        registerForUpdate = true,
    }
end

--[[ ---------------------- ]]
--[[ -- Exposed Function -- ]]
--[[ ---------------------- ]]

function LibExoY.CreateSettingsMenu( param ) 
    local LAM2 = LibAddonMenu2  

    local optionControls = {param.profiles}
    if LibExoY.IsTable(param.controls) then 
        for k,v in ipairs(param.controls) do 
            table.insert(optionControls, v) 
        end
    end
    --table.insert(optionsControls, param.profile)
    --table.insert(optionsControls, param.controls) 


    LAM2:RegisterAddonPanel(param.name.."Menu", GetMenuPanelData(param) )
    LAM2:RegisterOptionControls(param.name.."Menu", optionControls)
end