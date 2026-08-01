-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- LIBCHECK: A simple API to check to see if player has specified addon libraries installed 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.1.0 by Teebow Ganx
-- Copyright (c) 2023 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--
-- Put up a dialog if one or more of the addon's required libraries aren't loaded 
-- rather than just silently failing to load the addon so the player knows to go 
-- download and install the required library or libraries.
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

local LIBCHECK_VERSION = 1

if not LIBCHECK or not LIBCHECK.version or LIBCHECK.version < LIBCHECK_VERSION then
    
    LIBCHECK = {

        version = LIBCHECK_VERSION,
        dlogName = nil,

            checkForLibraries = function(inLibsT, inAddonName, inMissingLibsStr, inDownloadLibsStr) 

            -- The lib table should contain the name and object reference for each library required by the addon
            -- Example: 
            --
            -- local requiredLibsT = {
            --		{ name="LibAddonMenu", lib=LibAddonMenu2 },
            --		{ name="LibGPS", lib=LibGPS3 },
            --		{ name="LibMapPins", lib=LibMapPins },
            -- }
            --
            -- If one or more required libraries are not present, it tells the player in a dialog.

            -- inMissingLibsStr & inDownloadLibsStr are localised strings which you must provide!
            -- USE LOCALISED VERSIONS OF THESE STRINGS!
            -- 
            -- inMissingLibsStr = "WARNING: The addon \"%s\" is missing the following required libraries:\n\n"
            -- inDownloadLibsStr = "\nPlease download and install all missing libraries from esoui.com or by using Minion and then reload UI."
            --
            -- Then in your EVENT_ADD_ON_LOADED event handler, check the value of this function,
            -- and if it returns 'true' then all required libraries are present.
            -- If it returns false, then your addon should stop loading things which require
            -- one of the libraries.

            assert(inLibsT ~= nil, "ASSERTION FAILED: Cannot call LIB_Check() with no library table!")
            assert(#inLibsT > 0, "ASSERTION FAILED: Cannot call LIB_Check() with an empty library table!")

            local emptyLibs = {}

            for k, v in pairs(inLibsT) do
                if not v.lib then table.insert(emptyLibs, v.name) end
            end

            if #emptyLibs == 0 then return true end -- All required libraries are present

            local missingLibString = ""
            local CR = "\n"

            for _, libName in pairs(emptyLibs) do
                missingLibString = missingLibString.."\t"..libName.."\n"
            end

            -- Provide localised versions of these strings if you want them to display in another supported language of your addon!
            inMissingLibsStr = inMissingLibsStr or "WARNING: The addon \"%s\" is missing the following required libraries:\n\n"
            inDownloadLibsStr = inDownloadLibsStr or "\nPlease download and install all missing libraries from esoui.com or by using Minion and then reload UI."

            inMissingLibsStr = string.format(inMissingLibsStr, inAddonName)
            missingLibString = inMissingLibsStr..missingLibString
            missingLibString = missingLibString..inDownloadLibsStr

            -- Queue up the dialog to display after the EVENT_ADD_ON_LOADED handler completes for the addon

            zo_callLater(function()

                if not LIBCHECK.dlogName then

                    math.randomseed(os.time())
                    LIBCHECK.dlogName = "LIB_Check_DLOG_"..tostring(math.random(11111,99999))

                    ZO_Dialogs_RegisterCustomDialog(LIBCHECK.dlogName,
                    {
                        gamepadInfo =
                        {
                            dialogType = GAMEPAD_DIALOGS.BASIC,
                        },
                        title =
                        {
                            text = "REQUIRED LIBRARIES MISSING",
                        },
                        mainText =
                        {
                            text = missingLibString,
                        },
                        buttons =
                        {
                            {
                                text = "OK",
                                callback = function(dialog)
                                end,
                            },
                        }
                    })
                
                end

                ZO_Dialogs_ShowPlatformDialog(LIBCHECK.dlogName)

            end, 500) -- half second delay should work. Make it longer if you want.

            return false
        end,
    }
end