local HttpService = game:GetService("HttpService")

local function generateId()
	return HttpService:GenerateGUID(false)
end

return generateId
