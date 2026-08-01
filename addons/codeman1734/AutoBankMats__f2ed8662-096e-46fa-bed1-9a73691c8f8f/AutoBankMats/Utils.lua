function AutoBank:Debug(message)
    if self.savedVars.debug then
        d("|c00FF00[AutoBank]|r " .. tostring(message))
    end
end
