local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Köpfe."
L.RollCallToss2			= "Schwänze."
L.RollCallToss3			= " wirft einen Drake und landet "
L.RollCallTossQ1		= "[Wirf] Benutzen: /toss option"
L.RollCallTossQ2		= "[Wirf] Gültige Option ist 2 (2-seitige Münze)."
L.RollCallTossQ3		= "[Wirf] Standardeinstellung (wenn kein/ungültiger Wert eingegeben wurde) ist 2."

--Strings for /roll.
L.RollCallRoll1			= "[Werfen] von "
L.RollCallRoll2			= " von "
L.RollCallRoll3			= " durch: "
L.RollCallRoll4			= " wirft "
L.RollCallRoll5			= " wirft einen Holzwürfel und würfelt mit "
L.RollCallRoll6			= " Holzwürfel und Brötchen "
L.RollCallRollQ1		= "[Werfen] Benutzen: /roll option"
L.RollCallRollQ2		= "[Werfen] Gültige Optionen sind 6, 10, 12, 18, 24, 50, 100 und 1000."
L.RollCallRollQ3		= "[Werfen] Standardeinstellung (wenn kein/ungültiger Wert eingegeben wurde) ist 100. Siehe Optionen."
L.RollCallRollQ4		= "[Werfen] 'Spezielle' Werte sind 6, 12, 18 und 24."

--Settings panel strings.
L.RollCallCharOpt		= "Zeichenoptionen"
L.RollCallRollO			= "Standardwürfeln Option"
L.RollCallRollOD		= "Wählen Sie das Standardverhalten, wenn Sie /roll ohne Zahloption eingeben. Standard ist ein Rollout von 100. Siehe Optionen."
L.RollCallOpt1			= "1 Würfel werfen."
L.RollCallOpt2			= "Wirf 2 Würfel."
L.RollCallOpt3			= "Wirf 3 Würfel."
L.RollCallOpt4			= "Wirf 4 Würfel."
L.RollCallOpt5			= "Werfen / 10"
L.RollCallOpt6			= "Werfen / 20"
L.RollCallOpt7			= "Werfen / 50"
L.RollCallOpt8			= "Werfen / 100"
L.RollCallOpt9			= "Werfen / 1000"
L.RollCallDC			= "Im Kampf deaktivieren"
L.RollCallDCD			= "Verhindert, dass RollCall auf Pings reagiert, wenn Sie sich im Kampf befinden. Verhindert unerwünschten Chat-Spam während Gruppenkämpfen, bei denen aufgrund von Add-Ons für die DPS-Funktion häufig Karten-Pinging ausgeführt wird."
L.RollCallCM			= "Chat-Modus aktivieren"
L.RollCallCMD			= "Aktivieren Sie das Senden der Ausgabe (ohne Grafik) an den aktiven Chat anstelle einer Gruppe. ANMERKUNG: Sie müssen immer noch die Eingabetaste drücken, um Beiträge zu posten, da die API-Beschränkungen den Chat-Spam über Add-Ons verhindern."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
