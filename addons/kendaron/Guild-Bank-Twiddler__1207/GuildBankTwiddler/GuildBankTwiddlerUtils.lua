
GuildBankTwiddlerUtils = {}

GuildBankTwiddlerUtils.traceEnabled = false

local function trace(msg)
  if GuildBankTwiddlerUtils.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

---------------------------------------------------------------------
-- Function: Trace
--
-- This function outputs a trace message to chat window
---------------------------------------------------------------------
function GuildBankTwiddlerUtils:Trace(msg)
  d(GetTimeString()..":"..msg)
end

---------------------------------------------------------------------
-- Function: SetupTooltip
--
-- This function sets up standard tooltips for a control
---------------------------------------------------------------------
function GuildBankTwiddlerUtils:SetupTooltip(control, text)
  
  control:SetHandler("OnMouseEnter", function(control)
      ZO_Tooltips_ShowTextTooltip(control, TOP, text)
      
    end)
  control:SetHandler("OnMouseExit", function(control)
        ZO_Tooltips_HideTextTooltip() 
    end)
end