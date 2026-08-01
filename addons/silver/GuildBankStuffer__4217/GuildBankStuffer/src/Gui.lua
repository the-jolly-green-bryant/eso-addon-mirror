function GuildBankStuffer:InitGui()
    local index = 0;
    local window = self.GuildBankStufferWindowControl();

    for _, value in pairs(self.savedVariableLabels) do
        index = index + 1;
        local control = self.G.WINDOW_MANAGER:CreateControlFromVirtual("GuildBankStufferLabelControl" .. index, window, "GuildBankStufferLabelControlTemplate");
        control:SetAnchor(self.G.TOPLEFT, window, self.G.TOPLEFT, 15, 20 + index * 40);
        control:SetText(value.label);

        local button = control:GetChild(1);
        local function SetButtonText()
            if self.savedVariables[value.key] then button:SetText("ON") else button:SetText("OFF") end
        end;

        button:SetHandler("OnClicked", function()
            self.savedVariables[value.key] = not self.savedVariables[value.key];
            SetButtonText();
        end);
        SetButtonText();
    end

    for _, value in pairs(GuildBankStuffer.callables) do
        if value.showInGui then
            index = index + 1;
            local control = self.G.WINDOW_MANAGER:CreateControlFromVirtual("GuildBankStufferButtonControl" .. index, window, "ZO_DefaultButton");
            control:SetAnchor(self.G.TOPLEFT, window, self.G.TOPLEFT, 15, 20 + index * 40);
            control:SetWidth(200);
            control:SetText(value.label);
            control:SetHandler("OnClicked", function() value.callback() end);
        end
    end

    do
        local control = self.G.WINDOW_MANAGER:CreateControl("GuildBankStufferDescription", window, self.G.CT_LABEL);
        control:SetAnchor(self.G.BOTTOMLEFT, window, self.G.BOTTOMLEFT, 15, -15);
        control:SetFont("ZoFontGame")
        control:SetText([[
Set keyboard shortcut for "Mark deposit" (and "Unmark deposit").
Hover over items in your inventory and mark them for deposit using the shortcut.
Use buttons "Stack and deposit" or "Deposit only"
to automatically deposit and/or stack all items you have marked.]]);
    end

    local animation = self.G.ZO_AlphaAnimation:New(window);
    window.DoFadeIn = function()
        animation:FadeIn(0, 300);
    end;
    window.DoFadeOut = function()
        animation:FadeOut(0, 100);
        self.G.zo_callLater(function() window:SetHidden(true) end, 100);
    end;
end;
