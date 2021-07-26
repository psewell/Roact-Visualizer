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
		if roactValue == nil then
			roactValue = Instance.new("ObjectValue")
			roactValue.Name = "RoactInstall"
			roactValue.Parent = values
		end
		roactValue.Value = roact
	end
end
