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
			local newRoot = string.gsub(root.Source, "\n*$", "")
			root.Source = string.format("%s\n\n%s", newRoot, ScriptTemplates.RootHelp.Source)
			local newProps = string.gsub(props.Source, "\n*$", "")
			props.Source = string.format("%s\n\n%s", newProps, ScriptTemplates.PropsHelp.Source)
		else
			root.Source = string.gsub(root.Source, pattern .. "%s*", "", 1) .. "\n"
			props.Source = string.gsub(props.Source, pattern .. "%s*", "", 1) .. "\n"
		end
	end
end
