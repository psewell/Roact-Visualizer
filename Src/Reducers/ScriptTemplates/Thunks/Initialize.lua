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
		local showHelp = store:getState().Settings.ShowHelp

		local root = ScriptTemplates.Root:Clone()
		root.Name = "Root (Roact Visualizer)"
		if showHelp then
			root.Source = string.format("%s\n\n%s", root.Source, ScriptTemplates.RootHelp.Source)
		end
		root.Parent = PluginGuiService:FindFirstChild("Roact Visualizer")
		store:dispatch(SetRoot({
			Root = root,
		}))

		local props = ScriptTemplates.Props:Clone()
		props.Name = "Props (Roact Visualizer)"
		if showHelp then
			props.Source = string.format("%s\n\n%s", props.Source, ScriptTemplates.PropsHelp.Source)
		end
		props.Parent = PluginGuiService:FindFirstChild("Roact Visualizer")
		store:dispatch(SetProps({
			Props = props,
		}))
	end
end
