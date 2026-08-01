--[[
Combat Indicator. See the LICENSE file for details

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]--

if PL_CombatIndicator then return end
PL_CombatIndicator = {}
PL_CombatIndicator.version = 1.8
-- Changing settingsVersion will require players to redo the settings
PL_CombatIndicator.settingsVersion = 1.8
PL_CombatIndicator.name = "PL_CombatIndicator"

PL_CombatIndicator.Strings = {en={}, de={}, fr={}}
local L = PL_CombatIndicator.Strings
setmetatable(PL_CombatIndicator.Strings, { __index = function(t, k)
    local lang = GetCVar("language.2")
    local str = t[lang] ~= nil and t[lang][k]
    if not str then
      local fallback = t.en[k]
      if fallback == nil then
        local proto = lang .. "." .. k
        --d("|cff0000PL Combat Indicator: Missing string " .. proto .. ".")
        str = proto
      else
        str = fallback
      end
    end
  return str
end})

-- English Localisation
L.en.settingsTitle = "Combat Indicator"
L.en.settingCheckboxEnabled = "Enable Combat Indicator"
L.en.settingTooltipCheckboxEnabled = "Enable or disable all functionality (no reloadUI necessary)"
L.en.settingCheckboxDisguiseEnabled = "Enable Danger State (while disguised)"
L.en.settingTooltipCheckboxDisguiseEnabled = "Enables a third state with its own color, when you are disguised and in danger of being discovered"
L.en.settingColorNormal = "Non-Combat Compass Color"
L.en.settingTooltipColorNormal = "Compass overlay color to use while not in combat or in disguise"
L.en.settingColorCombat = "Combat Compass Color"
L.en.settingTooltipColorCombat = "Compass overlay color to use while in combat"
L.en.settingColorDisguiseDanger = "Danger State Compass Color (while disguised)"
L.en.settingTooltipColorDisguiseDanger = "Compass overlay color to use when you are in danger of being discovered while disguised"
L.en.settingCheckboxOptimiseForSmallUI = "Small UI Optimizations"
L.en.settingTooltipCheckboxOptimiseForSmallUI = "Enables some small tweaks to make the Combat Indicator clearer at all UI scales, but intended for use at lower UI scales (<0.75)"

-- German Localisation (slightly out of date from english - 1.8.2)
L.de = {}
L.de.settingsTitle = "Combat Indicator"
L.de.settingCheckboxEnabled = "Aktiviere Combat Indicator"
L.de.settingTooltipCheckboxEnabled = "Aktiviert oder deaktiviert alle Funktionen (ohne dass die Benutzeroberfläche neu geladen werden muss)."
L.de.settingCheckboxDisguiseEnabled = "Aktiviere Gefahranzeige wenn verkleidet"
L.de.settingTooltipCheckboxDisguiseEnabled = "Enables a third state with its own colour, when you are disguised and in danger of being discovered."
L.de.settingColorNormal = "Normale Kompassfarbe"
L.de.settingTooltipColorNormal = "Kompassfarbe die außerhalb von Kämpfen benutzt wird"
L.de.settingColorCombat = "Kampf-Kompassfarbe"
L.de.settingTooltipColorCombat = "Kompassfarbe die während Kämpfen benutz wird"
L.de.settingColorDisguiseDanger = "Gefahranzeige (wenn verkleidet)"
L.de.settingTooltipColorDisguiseDanger = "Kompassfarbe die benutzt wird wenn gefahr besteht, in einer Verkleidung entdeckt zu werden"
L.de.settingCheckboxOptimiseForSmallUI = "Optimiere für kleine UI Skalierung"
L.de.settingTooltipCheckboxOptimiseForSmallUI = "Aktiviert einige kleine Verbesserungen um die Zustandsanzeige mit allen Skalierungen klarer darzustellen, aber ist für niedrige Skalierungen gedacht (<0.75)"

-- French Localisation (slightly out of date from english - 1.8.2)
L.fr = {}
L.fr.settingsTitle = "Combat Indicator"
L.fr.settingCheckboxEnabled = "Activer l'indicateur de combat"
L.fr.settingTooltipCheckboxEnabled = "Active les fonctionnalités de l'extension."
L.fr.settingCheckboxDisguiseEnabled = "Activer l'alerte de danger lorsque déguisé"
L.fr.settingTooltipCheckboxDisguiseEnabled = "Active un troisème état doté de sa propre couleur lorsque le personnage est déguisé et risque d'être démasqué."
L.fr.settingColorNormal = "Couleur standard"
L.fr.settingTooltipColorNormal = "Détermine la couleur appliquée par défaut à la boussole."
L.fr.settingColorCombat = "Couleur en combat"
L.fr.settingTooltipColorCombat = "Détermine la couleur appliquée à la boussole lorsque le personnage est en combat."
L.fr.settingColorDisguiseDanger = "Couleur en danger"
L.fr.settingTooltipColorDisguiseDanger = "Détermine la couleur appliquée à la boussole lorsque le personnage est déguisé et risque d'être démasqué."
L.fr.settingCheckboxOptimiseForSmallUI = "Optimiser pour les interfaces à échelle réduite"
L.fr.settingTooltipCheckboxOptimiseForSmallUI = "Active des optimisations pour rendre l'indicateur plus clair lorsque les ennemis entre en état aggressif. Ce réglage est surtout indiqué pour les tailles d'interface inférieures à 0.75."
