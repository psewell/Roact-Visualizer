--[[
	A helper function to get text size,
	because the TextService API is legit unusable
]]

local TextService = game:GetService("TextService")
local GetBestScale = require(game.ReplicatedStorage.Packages.GetBestScale)
local GetBestScale = require(game.ReplicatedStorage.Packages.GetBestScale)

local t = require(script.Parent.t)
local typecheck = t.strictInterface({
	Text = t.string,
	Font = t.enum(Enum.Font),
	TextSize = t.number,
	MaxWidth = t.optional(t.number),
	WidthScaled = t.optional(t.boolean),
	Scaled = t.optional(t.boolean),
})

return function(props)
	assert(typecheck(props))
	local maxWidth = props.MaxWidth or 100000
	local frameSize = Vector2.new(maxWidth, 100000)
	local size = TextService:GetTextSize(
		props.Text:gsub("%b<>", ""),
		props.TextSize,
		props.Font,
		frameSize
	)
	if props.WidthScaled then
		return size * GetBestScale()
	elseif props.Scaled then
		return size * GetBestScale()
	else
		return size
	end
end
