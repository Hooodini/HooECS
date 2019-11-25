-- Getting folder that contains our src
local folderOfThisFile = (...)
if #folderOfThisFile >= 6 then
    folderOfThisFile = folderOfThisFile .. "."
else
    folderOfThisFile = ""
end

local HooECS = require(folderOfThisFile .. 'src.namespace')

function HooECS.debug(message)
    if HooECS.config.debug then
        print(message)
    end
end

local function populateNamespace(ns)
    -- Requiring class
    ns.class = require(folderOfThisFile .. 'lib.middleclass')

    -- Requiring util functions
    ns.util = require(folderOfThisFile .. "src.util")

    -- Requiring all Events
    ns.ComponentAdded = require(folderOfThisFile .. "src.events.ComponentAdded")
    ns.ComponentRemoved = require(folderOfThisFile .. "src.events.ComponentRemoved")
    ns.EntityActivated = require(folderOfThisFile .. "src.events.EntityActivated")
    ns.EntityDeactivated = require(folderOfThisFile .. "src.events.EntityDeactivated")

    -- Requiring HooECS
    ns.Entity = require(folderOfThisFile .. "src.Entity")
    ns.Engine = require(folderOfThisFile .. "src.Engine")
    ns.System = require(folderOfThisFile .. "src.System")
    ns.EventManager = require(folderOfThisFile .. "src.EventManager")
    ns.Component = require(folderOfThisFile .. "src.Component")
end

function HooECS.initialize(opts)
    if opts == nil then opts = {} end
    if not HooECS.initialized then
        HooECS.config = {
            debug = false,
            globals = false
        }

        for name, val in pairs(opts) do
            HooECS.config[name] = val
        end

        populateNamespace(HooECS)

        if HooECS.config.globals then
            populateNamespace(_G)
        end
        HooECS.initialized = true
    else
        print('HooECS is already initialized.')
    end
end

return HooECS
