local inspect = require 'lib/inspect'

function mergeTables(a, b)
  for k,v in pairs(b) do a[k] = v end
  return a
end

function toRadians(degrees)
  return (degrees * math.pi) / 180
end

function pinspect(table)
  print(inspect(table))
end
