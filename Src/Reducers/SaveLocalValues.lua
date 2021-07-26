--[[
	Saves local values to ServerStorage.
]]

local ServerStorage = game:GetService("ServerStorage")
local LOCAL_KEY = "ROACT-VISUALIZER-VALUES"

return function(plugin)
	return function(store)
		local values = ServerStorage:FindFirstChild(LOCAL_KEY)
		if values == nil then
			values = Instance.new("Configuration")
			values.Name = LOCAL_KEY
			values.Parent = ServerStorage
		end

		local state = store:getState()
		local roact = state.PluginState.RoactInstall
		local roactValue = values:FindFirstChild("RoactInstall")
		if roact and roactValue == nil then
			roactValue = Instance.new("ObjectValue")
			roactValue.Name = "RoactInstall"
			roactValue.Parent = values
		elseif roact == nil and roactValue then
			roactValue:Destroy()
		end
		if roact then
			roactValue.Value = roact
		end

		local rootModule = state.PluginState.RootModule
		local rootModuleValue = values:FindFirstChild("RootModule")
		if rootModule and rootModuleValue == nil then
			rootModuleValue = Instance.new("ObjectValue")
			rootModuleValue.Name = "RootModule"
			rootModuleValue.Parent = values
		elseif rootModule == nil and rootModuleValue then
			rootModuleValue:Destroy()
		end
		if rootModule then
			rootModuleValue.Value = rootModule
		end
	end
end
