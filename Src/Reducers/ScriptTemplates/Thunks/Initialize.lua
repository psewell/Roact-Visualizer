--[[
	Initializes the ScriptTemplates Reducer.
]]

local PluginGuiService = game:GetService("PluginGuiService")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Actions = script.Parent.Parent.Actions
local SetRoot = require(Actions.SetRoot)
local SetProps = require(Actions.SetProps)
local Update = require(Actions.Parent.Thunks.Update)
local SetHasScriptPermission = require(main.Src.Reducers.PluginState.Actions.SetHasScriptPermission)

local main = script:FindFirstAncestor("Roact-Visualizer")
local ScriptTemplates = main.Src.ScriptTemplates

return function()
	return function(store)
		local success, err = pcall(function()
			local root = ScriptTemplates.Root:Clone()
			root.Name = "Tree (Roact Visualizer)"
			root.Parent = PluginGuiService:FindFirstChild("Roact Visualizer")
			store:dispatch(SetRoot({
				Root = root,
			}))

			local props = ScriptTemplates.Props:Clone()
			props.Name = "Props (Roact Visualizer)"
			props.Parent = PluginGuiService:FindFirstChild("Roact Visualizer")
			store:dispatch(SetProps({
				Props = props,
			}))

			store:dispatch(Update())

			store:dispatch(SetHasScriptPermission({
				HasScriptPermission = true,
			}))
		end)

		if not success then
			warn(err)
		end
	end
end
