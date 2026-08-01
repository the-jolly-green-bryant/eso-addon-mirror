-- Shissu Framework: Fileintegrity
-- -------------------------------
-- 
-- Desc:        Funktionen zur Überprüfung der Datei Integrität, der einzelnen Module. Bereitstellung innerhalb einer Liste zur Auswertung
-- Filename:    function/fileintegrity.lua
-- Last Update: 18.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _addon = {}
_addon.Name = "ShissuFramework"

local _fileIntegrity = {}
_fileIntegrity["data"] = {}

function _fileIntegrity.check(fileList)
  local _P = ShissuFramework["functions"]["chat"].print
  local _L = ShissuFramework["func"]._L(_addon.Name)
  local fileDate = _fileIntegrity["data"]

  for filename, checkFunction in pairs(fileList) do
    if(not checkFunction()) then
      _fileIntegrity["data"][#_fileIntegrity["data"] + 1] = {filename, false}
      _P(_L("MISSING"), {filename}, _addon.Name, _L("ERR"), true) 
    else
      _fileIntegrity["data"][#_fileIntegrity["data"] + 1] = {filename, true}
    end
  end
end

ShissuFramework["fileIntegrity"] = _fileIntegrity