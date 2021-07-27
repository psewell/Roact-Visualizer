--[[
	Autosaves the current scripts, if they have been modified.
]]

local pattern = "%s*%-%-%[%[HELP.*HELP%]%]"

local main = script:FindFirstAncestor("Roact-Visualizer")
local SaveScript = require(main.Src.Reducers.SavedScripts.Actions.SaveScript)
local ScriptTemplates = main.Src.ScriptTemplates

local containers = {
	Props = "PropsScripts",
	Root = "RootScripts",
}

return function()
	return function(store)
		local scriptTemplates = store:getState().ScriptTemplates
		for name, module in pairs(scriptTemplates) do
			local source = module.Source
			source = string.gsub(source, pattern .. "%s*", "", 1)
			local template = string.gsub(ScriptTemplates[name].Source, pattern .. "%s*", "", 1)
			local container = containers[name]
			if source ~= template then
				store:dispatch(SaveScript({
					Name = "AutoSave",
					Container = container,
					Script = module,
				}))
			end
		end
	end
end
