local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Teste."
L.RollCallToss2			= "Croce."
L.RollCallToss3			= " lancia un Drake e atterra "
L.RollCallTossQ1		= "[Lanciare] Uso: /toss opzione"
L.RollCallTossQ2		= "[Lanciare] L'opzione valida è 2 (significa moneta a 2 facce)."
L.RollCallTossQ3		= "[Lanciare] Predefinito (quando nessun valore inserito/non valido) è 2."

--Strings for /roll.
L.RollCallRoll1			= "[Roll] di "
L.RollCallRoll2			= " su "
L.RollCallRoll3			= " di: "
L.RollCallRoll4			= " lancia "
L.RollCallRoll5			= " lancia un dado di legno e tira un "
L.RollCallRoll6			= " dadi di legno e tira "
L.RollCallRollQ1		= "[Tira] Uso: /roll opzione"
L.RollCallRollQ2		= "[Tira] Le opzioni valide sono 6, 10, 12, 18, 24, 50, 100 e 1000."
L.RollCallRollQ3		= "[Tira] Predefinito (quando nessun valore inserito/non valido) è 100. Vedere le opzioni."
L.RollCallRollQ4		= "[Tira] I valori 'speciali' sono 6, 12, 18 e 24."

--Settings panel strings.
L.RollCallCharOpt		= "Opzioni di carattere"
L.RollCallRollO			= "Opzione tira predefinita"
L.RollCallRollOD		= "Scegli il comportamento predefinito quando digiti /roll da solo senza un'opzione numerica. L'impostazione predefinita è un roll out standard di 100. Vedere le opzioni."
L.RollCallOpt1			= "Tira 1 dado"
L.RollCallOpt2			= "Tira 2 dadi."
L.RollCallOpt3			= "Tira 3 dadi."
L.RollCallOpt4			= "Tira 4 dadi."
L.RollCallOpt5			= "Tira / 10"
L.RollCallOpt6			= "Tira / 20"
L.RollCallOpt7			= "Tira / 50"
L.RollCallOpt8			= "Tira / 100"
L.RollCallOpt9			= "Tira / 1000"
L.RollCallDC			= "Disabilita in combattimento"
L.RollCallDCD			= "Impedisce a RollCall di rispondere ai ping se sei in combattimento. Evita lo spam indesiderato durante le lotte di gruppo in cui il ping delle mappe è frequente a causa dei componenti aggiuntivi di condivisione DPS."
L.RollCallCM			= "Abilita la modalità chat"
L.RollCallCMD			= "Abilita l'invio di output (senza grafica) alla chat attiva anziché al gruppo. NOTA: dovrai ancora premere manualmente invio per postare a causa delle limitazioni dell'API che impediscono lo spam delle chat tramite add-on."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
