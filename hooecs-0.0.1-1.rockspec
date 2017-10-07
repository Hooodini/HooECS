package = 'HooECS'
version = '0.0.1-1'
source = {
  url = "git://github.com/Hooodini/HooECS",
  branch = "master"
}
description = {
  summary = 'A neat Entity-Component-System for Lua',
  detailed = [[
    HooECS is a full-featured game development framework, not only providing the core parts like Entity, Component and System classes but also containing a Publish-Subscribe messaging system as well as a Scene Graph, enabling you to build even complex games easily and in a structured way.
    Based on lovetoys with some additional features.
  ]],
  homepage = 'https://github.com/Hooodini/HooECS',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.1'
}
build = {
  type = 'builtin',
  modules = {
    ['HooECS.src.namespace']                           = 'src/namespace.lua',
    ['HooECS.lovetoys']                                = 'lovetoys.lua',
    ['HooECS.src.Component']                           = 'src/Component.lua',
    ['HooECS.src.Engine']                              = 'src/Engine.lua',
    ['HooECS.src.Entity']                              = 'src/Entity.lua',
    ['HooECS.src.EventManager']                        = 'src/EventManager.lua',
    ['HooECS.lib.middleclass']                         = 'lib/middleclass.lua',
    ['HooECS.src.System']                              = 'src/System.lua',
    ['HooECS.src.util']                                = 'src/util.lua',
    ['HooECS.src.events.ComponentAdded']               = 'src/events/ComponentAdded.lua',
    ['HooECS.src.events.ComponentRemoved']             = 'src/events/ComponentRemoved.lua',
  }
}
