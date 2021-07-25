--[[
	Updates whether to show the help text in the script templates.
]]

local Actions = script.Parent.Parent.Actions
local SetShowHelp = require(Actions.SetShowHelpAction)
local main = script:FindFirstAncestor("Roact-Visualizer")
local UpdateScriptTemplates = require(main.Src.Reducers.ScriptTemplates.Thunks.Update)

return function(showHelp)
	return function(store)
		local state = store:getState()
		if state.Settings.ShowHelp ~= showHelp then
			store:dispatch(SetShowHelp({
				ShowHelp = showHelp,
			}))

			store:dispatch(UpdateScriptTemplates())
		end
	end
end
