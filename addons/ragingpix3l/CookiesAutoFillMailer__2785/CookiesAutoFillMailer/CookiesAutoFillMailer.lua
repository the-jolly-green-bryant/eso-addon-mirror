-------------------------------------------------------------------------------
-- Author
-- ragingpix3l
--
-- Full terms
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------

COOKIEAUTOFILLMAILER = COOKIEAUTOFILLMAILER or {}
local cc = COOKIEAUTOFILLMAILER
cc.mh = cc.mh or {}

local mh = cc.mh

cc.AddonName    = "CookiesAutoFillMailer"
cc.version      = "0.02"



local AddonName = cc.AddonName
local isInitialized = false
local target = "";
local subject = "";

function cc.EnableHooks()
	ZO_PreHook(MAIL_SEND, "Send", function () 
		if isInitialized == false then
			isInitialized = true
			local lbl = MAIL_SEND.to:GetParent():CreateControl("resend", CT_LABEL);
			lbl:SetText("last target");
			lbl:SetDimensions(100,36);
			lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			lbl:SetFont('ZoFontGameShadow')
			lbl:SetHidden(false);
			lbl:SetAnchor(TOPLEFT,MAIL_SEND.to,TOPRIGHT, -300, -38);
			lbl:SetMouseEnabled(true);
			lbl:SetHandler("OnMouseUp", function ()
				MAIL_SEND.to:SetText(target);
				MAIL_SEND.subject:SetText(subject);
			end);
		end
		target = MAIL_SEND.to:GetText();
		subject = MAIL_SEND.subject:GetText()
	end)
end



function cc.Startup()
    --Load the hooks
    cc.EnableHooks()
end


function cc.H_PlayerDeactivated (eventCode)
    
end

function cc.H_PlayerActivated (eventCode)

    EVENT_MANAGER:UnregisterForEvent(AddonName, eventCode)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_DEACTIVATED, cc.H_PlayerDeactivated)
    cc.Startup()
end


local function onAddOnLoaded(eventCode, pAddonName)
    --Only run the code after this line for my own addon!

    if not pAddonName == AddonName then return end

    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)

    cc.savedData = ZO_SavedVars:NewAccountWide("CookiesAutoFillMailerData", 1, nil, {}, nil)

    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, cc.H_PlayerActivated)

end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)