--[[
	Loads local values from ServerStorage.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local ServerStorage = game:GetService("ServerStorage")
local LOCAL_KEY = "ROACT-VISUALIZER-VALUES"

local SetRoactInstall = require(main.Src.Reducers.PluginState.Actions.SetRoactInstall)

return function(plugin)
	return function(store)
		local values = ServerStorage:FindFirstChild(LOCAL_KEY)
		if values == nil then
			return
		end

		local roactInstall = values:FindFirstChild("RoactInstall")
		if roactInstall and roactInstall.Value then
			local roact = roactInstall.Value
			if roact.Parent ~= nil and roact:IsA("ModuleScript") then
				store:dispatch(SetRoactInstall({
					RoactInstall = roact,
				}))
			end
		end
	end
end