tools = {}
function tools.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function tools.readOptions(file)
  local options = {}
  for line in love.filesystem.lines(file) do
    data = tools.split(line, "=")
    options [data [1]] = data [2]
  end
  return options
end
