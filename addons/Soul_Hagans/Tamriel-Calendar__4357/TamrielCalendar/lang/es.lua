TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar

local es = {
    days = {"Sandas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"},
    shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
    months = {"Estrella del Alba", "Amanecer", "Semilla Primera", "Mano de Lluvia", "Segunda Semilla", "Mitad del Año", "Cénit del Sol", "Última Semilla", "Fuego del Hogar", "Helada", "Ocaso", "Estrella del Sur"},
    realMonths = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"},
    signs = {"El Ritual", "El Amante", "El Señor", "El Mago", "La Sombra", "El Corcel", "El Aprendiz", "El Guerrero", "La Dama", "La Tower", "El Atromach", "El Ladrón", "El Serpiente"},
    moonPhases = {"Luna nueva", "Luna creciente", "Cuarto creciente", "Gibosa creciente", "Luna llena", "Gibosa menguante", "Cuarto menguante", "Luna menguante"},
    yearSuffix = "2.ª Era",
    monthPrefix = "Mes de",
    signPrefix = "Signo:",
    stripFormat = "%s, %d de %s %d | %s | %02d:%02d",
    titleHoliday = "Festividad:",
    btnPrev = "Anterior",
    btnNext = "Siguiente",
    hNames = {
        nl = "Nueva Vida",
        hd = "Día del Corazón",
        aj = "Aniversario ESO",
        jd = "Día del Bufón",
        my = "Midyear",
        wf = "Festival de las Brujas"
    }
}

for k, v in pairs(es) do
    TC.L[k] = v
end