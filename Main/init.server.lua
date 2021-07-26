local main = script:FindFirstAncestor("Roact-Visualizer")
local TestEZ = require(main.Packages.TestEZ)
local Roact = require(main.Packages.Roact)
local PluginContext = require(main.Src.Contexts.PluginContext)
local MainController = require(main.Src.Components.MainController)

local Main = {}
Main.__index = Main

function Main.new()
	local self = {
		Handle = nil,
	}

	self.Handle = Roact.mount(Roact.createElement(PluginContext.Provider, {
		value = plugin,
	}, {
		MainController = Roact.createElement(MainController),
	}))

	plugin.Unloading:Connect(function()
		Roact.unmount(self.Handle)
	end)

	setmetatable(self, Main)
	return self
end

Main.new()

--[[
-- Run tests if plugin is a child of workspace.
-- This means it is being worked on.
if script.Parent.Parent == workspace then
	TestEZ.TestBootstrap:run({
		script.Parent.Src.Util,
	})
end
]]