if not DryzlerElderGeekNet then DryzlerElderGeekNet = {plugins = {}, libs={}} end
if not DryzlerElderGeekNet.libs then DryzlerElderGeekNet.libs = {} end

degLibRegisterLib = function(name, version, tbl)
  if DryzlerElderGeekNet.libs[name] then
    if DryzlerElderGeekNet.libs[name].version and DryzlerElderGeekNet.libs[name].version > version then
      return false
    end
  end  
  DryzlerElderGeekNet.libs[name] = tbl  
  return true
end

function degLib(libname, ...)
  return DryzlerElderGeekNet.libs[libname]:initialize(...)
end