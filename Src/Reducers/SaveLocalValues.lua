--[[
	Saves local values to ServerStorage.
]]

local ServerStorage = game:GetService("ServerStorage")
local LOCAL_KEY = "ROACT-VISUALIZER-VALUES"
local scriptTypes = {
	"RootScripts",
	"PropsScripts",
}

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

		for _, scriptType in ipairs(scriptTypes) do
			local scripts = state.SavedScripts[scriptType]
			if next(scripts) then
				local scriptContainer = values:FindFirstChild(scriptType)
				if scriptContainer == nil then
					scriptContainer = Instance.new("Folder")
					scriptContainer.Name = scriptType
					scriptContainer.Parent = values
				else
					scriptContainer:ClearAllChildren()
				end
				for name, source in pairs(scripts) do
					local module = Instance.new("ModuleScript")
					module.Name = name
					module.Source = source
					module.Parent = scriptContainer
				end
			elseif values:FindFirstChild(scriptType) then
				values[scriptType]:Destroy()
			end
		end
	end
end
