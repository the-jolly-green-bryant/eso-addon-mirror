local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Cara."
L.RollCallToss2			= "Cruz."
L.RollCallToss3			= " lanza un Drake y aterriza "
L.RollCallTossQ1		= "[Lanza] Utilizar: /toss opción"
L.RollCallTossQ2		= "[Lanza] La opción válida es 2 (que significa moneda de 2 caras)."
L.RollCallTossQ3		= "[Lanza] El valor predeterminado (cuando no/un valor no válido) es 2."

--Strings for /roll.
L.RollCallRoll1			= "[Tirar] de "
L.RollCallRoll2			= " de "
L.RollCallRoll3			= " por: "
L.RollCallRoll4			= " lanza "
L.RollCallRoll5			= " lanza un dado de madera y tira un "
L.RollCallRoll6			= " dados de madera y rollos "
L.RollCallRollQ1		= "[Tirar] Utilizar: /roll opción"
L.RollCallRollQ2		= "[Tirar] Las opciones válidas son 6, 10, 12, 18, 24, 50, 100 y 1000."
L.RollCallRollQ3		= "[Tirar] El valor predeterminado (cuando no/un valor no válido) es 100. Ver opciones."
L.RollCallRollQ4		= "[Tirar] Los valores 'especiales' son 6, 12, 18 y 24."

--Settings panel strings.
L.RollCallCharOpt		= "Opciones de personaje"
L.RollCallRollO			= "Opción de rollo por defecto"
L.RollCallRollOD		= "Elija el comportamiento predeterminado al escribir /roll por sí mismo sin una opción de número. El valor predeterminado es un lanzamiento estándar de 100. Consulte las opciones."
L.RollCallOpt1			= "Tirar 1 dado."
L.RollCallOpt2			= "Tirar 2 dados."
L.RollCallOpt3			= "Tirar 3 dados."
L.RollCallOpt4			= "Tirar 4 dados."
L.RollCallOpt5			= "Tirar / 10"
L.RollCallOpt6			= "Tirar / 20"
L.RollCallOpt7			= "Tirar / 50"
L.RollCallOpt8			= "Tirar / 100"
L.RollCallOpt9			= "Tirar / 1000"
L.RollCallDC			= "Deshabilitar en combate"
L.RollCallDCD			= "Evita que RollCall responda a pings si estás en combate. Evita el spam no deseado en el chat durante las peleas de grupo donde el ping del mapa es frecuente debido a que los DPS comparten complementos."
L.RollCallCM			= "Habilitar el modo de chat"
L.RollCallCMD			= "Habilite el envío de resultados (sin gráficos) al chat activo en lugar de al grupo. NOTA: aún tendrá que presionar manualmente para ingresar debido a las limitaciones de la API que impiden el spam de chat a través de complementos."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
