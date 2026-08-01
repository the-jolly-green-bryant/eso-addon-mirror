local logActive = false;
function BUIE.Color(r, g, b, a)
  if a == nil then return { r / 255, g / 255, b / 255, 1 } end
  return { r / 255, g / 255, b / 255, a / 100 }
end

function BUIE.Log(object)
  if logActive then
    d(object)
  end
end