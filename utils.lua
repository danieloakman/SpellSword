function mergeTables(a, b)
  for k,v in pairs(b) do a[k] = v end
  return a
end

function degreesToRadians(degrees)
  return (degrees * math.pi) / 180
end
