-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

path = {}
for i in string.gmatch(folderOfThisFile, '.[^.]*') do
    table.insert(path, i)
end
table.remove(path, #path)
table.remove(path, #path)
folderOfThisFile = table.concat(path)

local EntityDeactivated = require(folderOfThisFile .. '.namespace').class("EntityDeactivated")

function EntityDeactivated:initialize(entity)
    self.entity = entity
end

return EntityDeactivated