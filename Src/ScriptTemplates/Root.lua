local Roact = script.Roact
local component = script.component

return function(props)
	return Roact.createElement(component, props)
end