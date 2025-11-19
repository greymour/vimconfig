-- have to define globals before `require`ing anything, as if the `require`d files rely on the global functions, they'll
-- error due to them executing prior to the functions being defined
-- something something hoisting
-- #region global functions
function Trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. Dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- #endregion

-- #region require whatever else here
require("greymour")
-- #endregion
