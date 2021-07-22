local main = script.Parent
local TestEZ = require(main.Packages.TestEZ)
local Roact = require(main.Packages.Roact)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local PluginContext = require(main.Src.Contexts.PluginContext)
local MainController = require(main.Src.Components.MainController)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		DynamicRequire.Require(workspace.TestScript)
		print("Finished")
	end
end)

Roact.mount(Roact.createElement(PluginContext.Provider, {
	value = plugin,
}, {
	MainController = Roact.createElement(MainController),
}))

-- Run tests if plugin is a child of workspace.
-- This means it is being worked on.
if script.Parent.Parent == workspace then
	TestEZ.TestBootstrap:run({
		script.Parent.Src.Util,
	})
end
