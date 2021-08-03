local Roact = script.Roact
local component = require(script.module)

return function(props)
	return Roact.createElement(component, props)
end