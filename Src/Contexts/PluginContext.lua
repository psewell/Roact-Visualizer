--[[
	Roact context for accessing the Plugin object.
]]

local main = script.Parent.Parent.Parent
local Roact = require(main.Packages.Roact)
local PluginContext = Roact.createContext("Plugin")

function PluginContext:get(component)
	return component:__getContext(self.key).value
end

return PluginContext
