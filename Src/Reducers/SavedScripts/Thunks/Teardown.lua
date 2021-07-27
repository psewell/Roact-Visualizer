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

local function trim(str)
	local result = string.gsub(str, pattern .. "%s*", "", 1)
	result = string.gsub(result, "%s*", "")
	return result
end

return function()
	return function(store)
		local scriptTemplates = store:getState().ScriptTemplates
		for name, module in pairs(scriptTemplates) do
			local source = module.Source
			source = trim(source)
			local template = trim(ScriptTemplates[name].Source)
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
