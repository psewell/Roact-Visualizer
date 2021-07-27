--[[
	Resets a script to its original state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local ScriptTemplates = main.Src.ScriptTemplates
local t = require(main.Packages.t)
local typecheck = t.interface({
	Container = t.literal("RootScripts", "PropsScripts"),
})

local pattern = "%s*%-%-%[%[HELP.*HELP%]%]"

return function(props)
	return function(store)
		assert(typecheck(props))
		local state = store:getState()
		local showHelp = state.Settings.ShowHelp
		local rootScript = state.ScriptTemplates.Root
		local propsScript = state.ScriptTemplates.Props

		local newScript
		if props.Container == "RootScripts" then
			newScript = ScriptTemplates.Root.Source
		else
			newScript = ScriptTemplates.Props.Source
		end

		newScript = string.gsub(newScript, pattern .. "%s*", "", 1) .. "\n"

		if showHelp then
			newScript = string.gsub(newScript, "\n*$", "")
			if props.Container == "RootScripts" then
				rootScript.Source = string.format("%s\n\n%s", newScript, ScriptTemplates.RootHelp.Source)
			else
				propsScript.Source = string.format("%s\n\n%s", newScript, ScriptTemplates.PropsHelp.Source)
			end
		else
			if props.Container == "RootScripts" then
				rootScript.Source = newScript
			else
				propsScript.Source = newScript
			end
		end
	end
end
