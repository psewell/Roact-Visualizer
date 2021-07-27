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

		local newRoot = string.gsub(root.Source, pattern .. "%s*", "", 1) .. "\n"
		local newProps = string.gsub(props.Source, pattern .. "%s*", "", 1) .. "\n"
		if showHelp then
			newRoot = string.gsub(newRoot, "\n*$", "")
			root.Source = string.format("%s\n\n%s", newRoot, ScriptTemplates.RootHelp.Source)
			newProps = string.gsub(newProps, "\n*$", "")
			props.Source = string.format("%s\n\n%s", newProps, ScriptTemplates.PropsHelp.Source)
		else
			root.Source = newRoot
			props.Source = newProps
		end
	end
end
