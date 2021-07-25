--[[
	Updates the ScriptTemplates Reducer.
	Mainly updates whether the help comments are showing.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local ScriptTemplates = main.Src.ScriptTemplates

local pattern = "%s*%-%-%[%[HELP.*HELP%]%]"

return function()
	return function(store)
		local state = store:getState()
		local showHelp = state.Settings.ShowHelp
		local root = state.ScriptTemplates.Root
		local props = state.ScriptTemplates.Props

		if showHelp then
			root.Source = string.format("%s\n\n%s", root.Source, ScriptTemplates.RootHelp.Source)
			props.Source = string.format("%s\n\n%s", props.Source, ScriptTemplates.PropsHelp.Source)
		else
			root.Source = string.gsub(root.Source, pattern, "", 1)
			props.Source = string.gsub(props.Source, pattern, "", 1)
		end
	end
end
