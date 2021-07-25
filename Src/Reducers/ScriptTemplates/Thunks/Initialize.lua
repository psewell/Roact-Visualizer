--[[
	Initializes the ScriptTemplates Reducer.
]]

local PluginGuiService = game:GetService("PluginGuiService")

local Actions = script.Parent.Parent.Actions
local SetRoot = require(Actions.SetRoot)
local SetProps = require(Actions.SetProps)

local main = script:FindFirstAncestor("Roact-Visualizer")
local ScriptTemplates = main.Src.ScriptTemplates

return function()
	return function(store)
		local root = ScriptTemplates.Root:Clone()
		root.Name = "Root (Roact Visualizer)"
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
	end
end
