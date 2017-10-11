-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local HooECS = require(folderOfThisFile .. 'namespace')
local System = HooECS.class("System")

function System:initialize()
    -- List of all entities, which have the RequiredComponents of this Systems
    self.targets = {}
    self.active = true
end

function System:requires() return {} end

function System:addEntity(entity, category)
    -- If there are multiple requirement lists, the added entities will
    -- be added to their respetive list.
    if category then
        if entity.active then
            self.targets[category][entity.id] = entity
        end
    else
        -- Otherwise they'll be added to the normal self.targets list
        if entity.active then
            self.targets[entity.id] = entity
        end
    end

    if self.onAddEntity then self:onAddEntity(entity) end
end

function System:removeEntity(entity, component)
    -- Get the first element and check if it's a component name
    -- In case it is an Entity, we know that this System doesn't have multiple
    -- Requirements. Otherwise we remove the Entity from each category.
    local firstIndex, _ = next(self.targets)
    if firstIndex then
        if type(firstIndex) == "string" then
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                self.targets[index][entity.id] = nil
                if self.onRemoveEntity then self:onRemoveEntity(entity, index) end
            end

        else
            self.targets[entity.id] = nil
            if self.onRemoveEntity then self:onRemoveEntity(entity) end
        end
    end
end

function System:componentRemoved(entity, component)
    -- Get the first element and check if it's a component name
    -- In case a System has multiple requirements we need to check for
    -- each requirement category if the entity has to be removed.
    local firstIndex, _ = next(self.targets)
    if firstIndex then
        if type(firstIndex) == "string" then
            -- Removing entities from their respective category target list.
            for index, _ in pairs(self.targets) do
                for _, req in pairs(self:requires()[index]) do
                    if req == component then
                        self.targets[index][entity.id] = nil
                        if self.onRemoveEntity then self:onRemoveEntity(entity, index) end
                        break
                    end
                end
            end
        else
            self.targets[entity.id] = nil
            if self.onRemoveEntity then self:onRemoveEntity(entity) end
        end
    end
end

function System:pickRequiredComponents(entity)
    local components = {}
    local requirements = self:requires()

    if type(HooECS.util.firstElement(requirements)) == "string" then
        for _, componentName in pairs(requirements) do
            table.insert(components, entity:get(componentName))
        end
    elseif type(HooECS.util.firstElement(requirements)) == "table" then
        HooECS.debug("System: :pickRequiredComponents() is not supported for systems with multiple component constellations")
        return nil
    end
    return unpack(components)
end

return System
