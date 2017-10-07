-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local HooECS = require(folderOfThisFile .. 'namespace')
local Entity = HooECS.class("Entity")

function Entity:initialize(parent, name, active)
    self.components = {}
    self.eventManager = nil
    self.active = active or true
    self.alive = false
    if parent then
        self:setParent(parent)
    else
        parent = nil
    end
    self.name = name
    self.children = {}
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:add(component)
    local name = component.class.name
    if self.components[name] then
        HooECS.debug("Entity: Trying to add Component '" .. name .. "', but it's already existing. Please use Entity:set to overwrite a component in an entity.")
    else
        self.components[name] = component
        if self.eventManager then
            self.eventManager:fireEvent(HooECS.ComponentAdded(self, name))
        end
    end
end

function Entity:set(component)
    local name = component.class.name
    if self.components[name] == nil then
        self:add(component)
    else
        self.components[name] = component
    end
end

function Entity:addMultiple(componentList)
    for _, component in  pairs(componentList) do
        self:add(component)
    end
end

-- Removes a component from the entity.
function Entity:remove(name)
    if self.components[name] then
        if self.components[name].onComponentRemoved then self.components[name].onComponentRemoved() end
        self.components[name] = nil
    else
        HooECS.debug("Entity: Trying to remove unexisting component " .. name .. " from Entity. Please fix this")
    end
    if self.eventManager then
        self.eventManager:fireEvent(HooECS.ComponentRemoved(self, name))
    end
end

function Entity:setParent(parent)
    if self.parent then self.parent.children[self.id] = nil end
    self.parent = parent
    self:registerAsChild()
end

function Entity:getParent()
    return self.parent
end

function Entity:registerAsChild()
    if self.id then self.parent.children[self.id] = self end
end

function Entity:get(name)
    return self.components[name]
end

function Entity:has(name)
    return not not self.components[name]
end

function Entity:getComponents()
    return self.components
end

function Entity:getRootEntity()
    local entity = self
    while entity.getParent do
        local parent = entity:getParent()
        if parent.engine then
            return parent
        else
            entity = parent
        end
    end
end

function Entity:getEngine()
    return self:getRootEntity().engine
end

function Entity:activate()
    if not self.active then
        self.active = true
        self.eventManager:fireEvent(HooECS.EntityActivated(self))
    end
end

function Entity:deactivate()
    if self.active then
        self.active = false
        self.eventManager:fireEvent(HooECS.EntityDeactivated(self))
    end
end

return Entity
