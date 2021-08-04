--[[
	Imports and gets a module from a file.
]]

local StudioService = game:GetService("StudioService")

local main = script:FindFirstAncestor("Roact-Visualizer")
local getAllModules = require(script.Parent.getAllModules)
local Promise = require(main.Packages.Promise)

local function getModuleFromFile()
	return Promise.try(function()
		local file = StudioService:PromptImportFile({"lua"})
		if file then
			local contents = file:GetBinaryContents()
			local name = string.gsub(file.Name, "%.lua$", "")
			local modules = getAllModules()
			for _, module in ipairs(modules) do
				if module.Source == contents and module.Name == name then
					return module, true
				end
			end
			for _, module in ipairs(modules) do
				if module.Name == name then
					return module, false
				end
			end
			return nil, nil
		else
			return nil, nil
		end
	end)
end

return getModuleFromFile
