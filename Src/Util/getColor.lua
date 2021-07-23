--[[
	Provides simple shorthand for StudioStyle enums.
]]

local function getColor(colorFunc)
	return colorFunc(Enum.StudioStyleGuideColor, Enum.StudioStyleGuideModifier)
end

return getColor
