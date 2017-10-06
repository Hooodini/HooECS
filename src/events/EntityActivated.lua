-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

path = {}
for i in string.gmatch(folderOfThisFile, '.[^.]*') do
    table.insert(path, i)
end
table.remove(path, #path)
table.remove(path, #path)
folderOfThisFile = table.concat(path)

local EntityActivated = require(folderOfThisFile .. '.namespace').class("EntityActivated")

function EntityActivated:initialize(entity)
    self.entity = entity
end

return EntityActivated