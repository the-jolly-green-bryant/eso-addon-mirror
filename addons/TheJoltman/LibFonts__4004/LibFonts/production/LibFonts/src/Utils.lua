--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFriendlyVersion()

    local major = math.floor(LibFonts.Version / 10000)
    local minor = math.floor((LibFonts.Version % 10000) / 100)
    local revision = LibFonts.Version % 100

    return string.format("%d.%d.%d", major, minor, revision)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.DisplayVersionInfo()

    -- Display the current Version of our addon and the Version of the API used to communicate to the game
    LibFontsChat:SetTagColor("00e0ff"):Print("Version "..LibFonts.GetFriendlyVersion()..". APIVersion "..GetAPIVersion()..". by @TheJoltman")

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function GetFontStyleByIndex(index)

    for _, value in pairs(LibFonts.FontStyle) do

        if value.index == index then

            return value

        end

    end

    return nil -- Return nil if index is not found

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function GetFontStyleByName(name)

    for _, value in pairs(LibFonts.FontStyle) do

        if value.name == name then

            return value

        end

    end

    return nil -- Return nil if index is not found

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function GetFontStyleByFriendlyName(name)

    for _, value in pairs(LibFonts.FontStyle) do

        if value.friendlyName == name then

            return value

        end

    end

    return nil -- Return nil if index is not found

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFontCount()

    local count = 0

    for _ in pairs(LibFonts.FontStyle) do

        count = count + 1

    end

    return count

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFont(fontStyle)

    LibFontsLmp:Register("font", fontStyle.name, fontStyle.path);

    return LibFontsLmp:Fetch("font", fontStyle.name)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFontByIndex(index)

    local font = GetFontStyleByIndex(index)

    if font == nil then

        LibFontsLmp:Register("font", "ESO Standard Font", "EsoUI/Common/Fonts/univers57.slug");

        return LibFontsLmp:Fetch("font", "ESO Standard Font")

    else

        LibFontsLmp:Register("font", font.name, font.path);

        return LibFontsLmp:Fetch("font", font.name)

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFontByName(name)

    local font = GetFontStyleByName(name)

    if font == nil then

        LibFontsLmp:Register("font", "ESO Standard Font", "EsoUI/Common/Fonts/univers57.slug");

        return LibFontsLmp:Fetch("font", "ESO Standard Font")

    else

        LibFontsLmp:Register("font", font.name, font.path);

        return LibFontsLmp:Fetch("font", font.name)

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFontByFriendlyName(name)

    local font = GetFontStyleByFriendlyName(name)

    if font == nil then

        LibFontsLmp:Register("font", "ESO Standard Font", "EsoUI/Common/Fonts/univers57.slug");

        return LibFontsLmp:Fetch("font", "ESO Standard Font")

    else

        LibFontsLmp:Register("font", font.name, font.path);

        return LibFontsLmp:Fetch("font", font.name)

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LibFonts.GetFontNameList()

    local nameList = {}

    -- Collect the friendly names into nameList
    for _, v in pairs(LibFonts.FontStyle) do

        table.insert(nameList, v.friendlyName)

    end

    -- Sort nameList alphabetically
    table.sort(nameList, function(a, b)

        return a:lower() < b:lower()  -- Case-insensitive sort

    end)

    return nameList
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------