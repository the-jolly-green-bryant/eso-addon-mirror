LibExoYsUtilities = LibExoYsUtilities or {} 

local LibExoY = LibExoYsUtilities


function LibExoY.FeedbackSubmenu( name, esoui)
    local submenu = {
        type = "submenu", 
        name = LibExoY.AddIconToString(LIB_EXOY_FEEDBACK_SETTINGS, "esoui/art/icons/achievement_update11_dungeons_004.dds", 36, "front"),
        controls = {},
    }

    table.insert(submenu.controls,   {
        type = "description",
        text = LIB_EXOY_FEEDBACK_DONATION_TEXT,
        width = "half",
    } )
    table.insert(submenu.controls,   {
        type = "button",
        name = LIB_EXOY_FEEDBACK_DONATION_BUTTON,
        tooltip = LIB_EXOY_FEEDBACK_DONATION_TT,
        func = function()
          RequestOpenUnsafeURL( "https://www.buymeacoffee.com/exoy" )
        end,
        width = "half",
        --warning = LIB_EXOY_FEEDBACK_URL_WARNING,
    } )

    table.insert(submenu.controls, { type = "divider" } )

    if esoui then
        table.insert(submenu.controls,   {
            type = "description",
            text = LIB_EXOY_FEEDBACK_ESOUI_TEXT,
            width = "half",
        } )
        table.insert(submenu.controls,   {
            type = "button",
            name = LIB_EXOY_FEEDBACK_ESOUI_BUTTON,
            tooltip = "",
            func = function()
            RequestOpenUnsafeURL( "https://www.esoui.com/downloads/"..esoui )
            end,
            width = "half",
            --warning = LIB_EXOY_FEEDBACK_URL_WARNING,
        } )
    end

    table.insert(submenu.controls,   {
        type = "description",
        text = LIB_EXOY_FEEDBACK_TEXT,
        width = "full",
    } )
    table.insert(submenu.controls,   {
        type = "button",
        name = LIB_EXOY_FEEDBACK_DISCORD_BUTTON,
        --tooltip = LIB_EXOY_FEEDBACK_DISCORD_TT,
        func = function()
          RequestOpenUnsafeURL( "https://discord.com/invite/MjfPKsJAS9" )
        end,
        width = "half",
        --warning = LIB_EXOY_FEEDBACK_URL_WARNING,
    } )
    table.insert(submenu.controls,   {
        type = "button",
        name = LIB_EXOY_FEEDBACK_INGAME_MAIL_BUTTON,
        tooltip = "",
        disabled = function() return GetWorldName() ~= "EU Megaserver" end,
        func = function()
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function() 
                    ZO_MailSendToField:SetText("@Exoy94")
                    ZO_MailSendSubjectField:SetText( name )
                    ZO_MailSendBodyField:TakeFocus()   
                end, 250)
        end,
        width = "half",
        tooltip = GetWorldName() ~= "EU Megaserver" and LIB_EXOY_FEEDBACK_INGAME_MAIL_WARNING or LIB_EXOY_FEEDBACK_INGAME_MAIL_LANGUAGE,
    } )
    return submenu
end




function LibExoY.ExeFunc(...) 
    LibExoY.CallFunc(...)
end 


--[[ ------------------- ]]
--[[ -- Feedback Menu -- ]]
--[[ ------------------- ]]

LIB_EXOY_FEEDBACK_SETTINGS = "Feedback & Donation"
LIB_EXOY_FEEDBACK_TEXT = "You can also join my dedicated |c00ff00discord|r server or send me an |c00ff00ingame mail|r." 

LIB_EXOY_FEEDBACK_INGAME_MAIL_BUTTON = "Ingame Mail"
LIB_EXOY_FEEDBACK_INGAME_MAIL_SERVER = "Only enabled on |c00ff00PC(EU)|r."
LIB_EXOY_FEEDBACK_INGAME_MAIL_LANGUAGE = "English or German"

LIB_EXOY_FEEDBACK_DONATION_TEXT = "If you enjoy my work, you can |c00ff00Buy me a coffee|r to support me :)"
LIB_EXOY_FEEDBACK_DONATION_BUTTON = "Buy me a coffee"
LIB_EXOY_FEEDBACK_DONATION_TT = "Thank you :)"

LIB_EXOY_FEEDBACK_ESOUI_TEXT = "For |cFF8800bug reports|r, |cFF8800feedback|r and |cFF8800information|r visit esoui.com "
LIB_EXOY_FEEDBACK_ESOUI_BUTTON = "Website"

LIB_EXOY_FEEDBACK_DISCORD_BUTTON = "Discord" 


--- renamed
function LibExoY.CheckTrigger( t )
    if LibExoY.IsFunc( t ) and LibExoY.IsBool( t() ) then return t() end
    if LibExoY.IsBool( t ) then return t end
    return 
  end


--- renamed
function LibExoY.CallFuncWithTrigger(t, f, p) 
    if LibExoY.CheckTrigger( t ) then 
      LibExoY.CallFunc(f,p) 
    end
  end 


--- unnessesary 
  function LibExoY.CallFunc( f, ... ) 
    if LibExoY.IsFunc(f) then 
      return f(...) 
    end
  end


  --[[ -- String Functions -- ]]
--- renamed
-- todo, function to check if strings begins with a space 
function LibExoY.IsFirstCharacterSpace(s)
    if not LibExoY.IsString(s) then return end
    return string.sub(s,1,1) == " "
  end
  -- 
  
  --- renamed
  -- todo, check if string only consists of spaces 
  function LibExoY.IsStringEmpty(s) 
    return s == ""
  end


