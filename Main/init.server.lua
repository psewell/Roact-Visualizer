local main = script:FindFirstAncestor("Roact-Visualizer")
local TestEZ = require(main.Packages.TestEZ)
local Roact = require(main.Packages.Roact)
local Rodux = require(main.Packages.Rodux)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local PluginContext = require(main.Src.Contexts.PluginContext)
local MainController = require(main.Src.Components.MainController)
local MainReducer = require(main.Src.Reducers.MainReducer)
local Initialize = require(main.Src.Reducers.Initialize)
local Teardown = require(main.Src.Reducers.Teardown)

local Main = {}
Main.__index = Main

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		DynamicRequire.Require(workspace.TestScript)
		print("Finished")
	end
end)

local function createMiddlewares()
	local middlewares = {
		Rodux.thunkMiddleware,
	}
	return middlewares
end

function Main.new()
	local middlewares = createMiddlewares()
	local store = Rodux.Store.new(MainReducer, nil, middlewares)
	local self = {
		Store = store,
		Handle = nil,
	}

	self.Store:dispatch(Initialize(plugin))
	self.Handle = Roact.mount(Roact.createElement(PluginContext.Provider, {
		value = plugin,
	}, {
		StoreProvider = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			MainController = Roact.createElement(MainController),
		})
	}))

	plugin.Unloading:Connect(function()
		Roact.unmount(self.Handle)
		self.Store:dispatch(Teardown(plugin))
		self.Store:flush()
		self.Store:destruct()
	end)

	setmetatable(self, Main)
	return self
end

Main.new()

-- Run tests if plugin is a child of workspace.
-- This means it is being worked on.
if script.Parent.Parent == workspace then
	TestEZ.TestBootstrap:run({
		script.Parent.Src.Util,
	})
end
