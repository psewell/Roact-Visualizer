--[[
	Loads local values from ServerStorage.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local ServerStorage = game:GetService("ServerStorage")
local LOCAL_KEY = "ROACT-VISUALIZER-VALUES"
local scriptTypes = {
	"RootScripts",
	"PropsScripts",
}

local SetRoactInstall = require(main.Src.Reducers.PluginState.Actions.SetRoactInstall)
local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local SaveScript = require(main.Src.Reducers.SavedScripts.Actions.SaveScript)

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

		local rootModule = values:FindFirstChild("RootModule")
		if rootModule and rootModule.Value then
			local root = rootModule.Value
			if root.Parent ~= nil and root:IsA("ModuleScript") then
				store:dispatch(SetRootModule({
					RootModule = root,
				}))
			end
		end

		for _, scriptType in ipairs(scriptTypes) do
			if values:FindFirstChild(scriptType) then
				for _, module in ipairs(values[scriptType]:GetChildren()) do
					store:dispatch(SaveScript({
						Name = module.Name,
						Container = scriptType,
						Script = module,
					}))
				end
			end
		end
	end
end
