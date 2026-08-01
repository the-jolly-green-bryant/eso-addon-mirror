M00SIE = M00SIE or {
    name = "m00SupportIconsExtension",
    version = "1.1.0",
}

local function Initialize()
    if OSI and OSI.AddCustomIconPack then
        OSI.AddCustomIconPack( M00SIE.icons )
    end
end

EVENT_MANAGER:RegisterForEvent(M00SIE.name, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= M00SIE.name then return end

    EVENT_MANAGER:UnregisterForEvent(M00SIE.name, EVENT_ADD_ON_LOADED)
    Initialize()
end)




