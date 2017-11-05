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

    if component.addedToEntity then component:addedToEntity(self) end

    return self
end

function Entity:set(component)
    local name = component.class.name
    if self.components[name] == nil then
        self:add(component)
    else
        if self.components[name].addedToEntity ~= component.addedToEntity and component.addedToEntity then
            component:addedToEntity(self)
        end
        self.components[name] = component
    end
end

function Entity:addMultiple(componentList)
    for _, component in  pairs(componentList) do
        self:add(component)
    end
end

function Entity:setMultiple(componentList)
    for _, component in pairs(componentList) do
        self:set(component)
    end
end

-- Removes a component from the entity.
function Entity:remove(name)
    if self.components[name] then
        if self.components[name].removedFromEntity then
            self.components[name]:removedFromEntity(self)
        end

        self.components[name] = nil
    else
        HooECS.debug("Entity: Trying to remove unexisting component " .. name .. " from Entity. Please fix this")
    end
    if self.eventManager then
        self.eventManager:fireEvent(HooECS.ComponentRemoved(self, name))
    end

    return self
end

function Entity:setParent(parent)
    if self.parent then self.parent.children[self.id] = nil end
    self.parent = parent
    self:registerAsChild()
end

function Entity:getParent()
    return self.parent
end

function Entity:getChildren()
    if next(self.children) then
        return self.children
    end
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

function Entity:isActive()
    return self.active
end

function Entity:setUpdate(newUpdateFunction)
    if type(newUpdateFunction) == "function" then
        self.update = newUpdateFunction
        local engine = self:getEngine()
        if engine then
            engine:addUpdateEntity(self)
        end
    elseif type(newUpdateFunction) == "nil" then
        self.update = nil
        local engine = self:getEngine()
        if engine then
            engine:removeUpdateEntity(self)
        end
    end
end

-- Returns an entity with all components deeply copied.
function Entity:copy(componentList)
    function deepCopy(obj, seen)
        -- Handle non-tables and previously-seen tables.
        if type(obj) ~= 'table' then return obj end
        if seen and seen[obj] then return seen[obj] end

        -- New table; mark it as seen an copy recursively.
        local s = seen or {}
        local res = setmetatable({}, getmetatable(obj))
        s[obj] = res
        local k, v = next(obj)
        while k do
            res[deepCopy(k, s)] = deepCopy(v, s) 
            k, v = next(obj, k)
        end
        return res
    end

    local newEntity = Entity()
    newEntity.components = deepCopy(self.components)

    if componentList then
        if type(componentList) == "table" then
            newEntity:setMultiple(componentList)
        else
            HooECS.debug("Entity:copy() componentList is not a table!")
        end
    end

    return newEntity
end

-- Returns an entity with references to the components. 
-- Modifying a component of the origin entity will result in the returned entity being modified too.
function Entity:shallowCopy(componentList)
    function shallowCopy(obj)
        if type(obj) ~= 'table' then return obj end
        local res = setmetatable({}, getmetatable(obj))
        local k, v = next(obj)
        while k do
            res[k] = v
            k, v = next(obj, k)
        end

        return res
    end

    local newEntity = Entity()
    newEntity.components = shallowCopy(self.components)

    if componentList then
        if type(componentList) == "table" then
            newEntity:setMultiple(componentList)
        else
            HooECS.debug("Entity:shallowCopy() componentList is not a table!")
        end
    end

    return newEntity
end

return Entity
