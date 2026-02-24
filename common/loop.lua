-- ~/.config/conky/common/loop.lua

function conky_updates()
  if type(conky_parse) ~= "function" then return 0 end
  local n = tonumber(conky_parse("${updates}"))
  return n or 0
end
