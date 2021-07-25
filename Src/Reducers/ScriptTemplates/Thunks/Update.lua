--[[
	Updates the ScriptTemplates Reducer.
	Mainly updates whether the help comments are showing.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local ScriptTemplates = main.Src.ScriptTemplates

local pattern = "%-%-%[%[HELP.*HELP%]%]\n*"

return function()
	return function(store)
		local state = store:getState()
		local showHelp = state.Settings.ShowHelp
		local root = state.ScriptTemplates.Root
		local props = state.ScriptTemplates.Props

		if showHelp then
			root.Source = string.format("%s\n\n%s", ScriptTemplates.RootHelp.Source, root.Source)
			props.Source = string.format("%s\n\n%s", ScriptTemplates.PropsHelp.Source, props.Source)
		else
			root.Source = string.gsub(root.Source, pattern, "", 1)
			props.Source = string.gsub(props.Source, pattern, "", 1)
		end
	end
end
