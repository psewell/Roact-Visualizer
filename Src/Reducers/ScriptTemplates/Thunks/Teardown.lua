--[[
	Tears down the ScriptTemplates Reducer.
]]

return function()
	return function(store)
		local state = store:getState()
		if state.ScriptTemplates.Root then
			state.ScriptTemplates.Root:Destroy()
		end

		if state.ScriptTemplates.Props then
			state.ScriptTemplates.Props:Destroy()
		end
	end
end
