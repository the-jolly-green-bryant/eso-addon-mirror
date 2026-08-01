local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Opciones de autoshuamiento"
L.RPOTRACK_GOpts		= "Opciones de rastreador de grupo"

-- Self Tracker Options
L.RPOTRACK_Show			= "Rastreador de espectáculos"
L.RPOTRACK_ShowD		= "Muestre el rastreador de estado RotPO equipado para el reproductor."
L.RPOTRACK_Lock			= "Rastreador de bloqueo"
L.RPOTRACK_LockD		= "Cuando se desbloquee, puede mover el rastreador para guardar una nueva posición."
L.RPOTRACK_ShowG		= "Mostrar agrupado"
L.RPOTRACK_ShowGD		= "Muestre el rastreador de estado RotPO equipado para el jugador cuando se agrupe."
L.RPOTRACK_ShowBG		= "Mostrar fondo"
L.RPOTRACK_ShowBGD		= "Muestre un fondo negro detrás del ícono del rastreador RotPO."
L.RPOTRACK_Label		= "Etiqueta de espectáculo"
L.RPOTRACK_LabelD		= "Muestre una etiqueta de texto que indica la fuerza porcentual RotPO basada en el número de miembros del grupo presentes."
L.RPOTRACK_TScale		= "Escala de rastreador"
L.RPOTRACK_TScaleD		= "Escala las dimensiones para el icono del rastreador."
L.RPOTRACK_LScale		= "Escala de etiqueta"
L.RPOTRACK_LScaleD		= "Escala las dimensiones para la etiqueta de texto."
L.RPOTRACK_LabelX		= "Etiqueta compensación horizontal"
L.RPOTRACK_LabelXD		= "Ajuste la posición de la etiqueta de texto RotPO de izquierda a derecha."
L.RPOTRACK_LabelY		= "Etiqueta de compensación vertical"
L.RPOTRACK_LabelYD		= "Ajuste la posición de la etiqueta de texto RotPO hacia arriba y hacia abajo."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Monitorear cuadros de grupo"
L.RPOTRACK_SGFD			= "Mostrar RotPO ícono para marcos de unidades grupales."
L.RPOTRACK_SRF			= "Monitorear marcos de redadas"
L.RPOTRACK_SRFD			= "Mostrar RotPO ícono en los marcos de la unidad redadas."
L.RPOTRACK_GIS			= "Tamaño del icono de grupo"
L.RPOTRACK_GISD			= "Tamaño del icono RotPO cuando se muestra en marcos de grupo estándar."
L.RPOTRACK_RIS			= "Tamaño del icono de redadas"
L.RPOTRACK_RISD			= "Tamaño del icono RotPO cuando se muestra en marcos de redadas estándar."
L.RPOTRACK_GXIO			= "Compensación de icono horizontal de grupo"
L.RPOTRACK_GXIOD		= "Ajuste la posición del ícono del marco del grupo RotPO de izquierda a derecha."
L.RPOTRACK_GYIO			= "Compensación de icono vertical grupal"
L.RPOTRACK_GYIOD		= "Ajuste la posición del icono del marco del grupo RotPO hacia arriba y hacia abajo."
L.RPOTRACK_RXIO			= "Desplazamiento de icono horizontal de redadas"
L.RPOTRACK_RXIOD		= "Ajuste la posición del ícono redadas RotPO de izquierda a derecha."
L.RPOTRACK_RYIO			= "Desplazamiento de icono vertical redadas"
L.RPOTRACK_RYIOD		= "Ajuste la posición del icono redadas Frame RotPO hacia arriba y hacia abajo."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "Defecto"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
