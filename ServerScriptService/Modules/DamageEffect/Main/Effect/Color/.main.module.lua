-- Colors for damaged
local EFFECT_COLORS_NEGATIVE = {
	{
		maxDamage = 1,
		color = Color3.fromRGB (255, 170, 0)
	},
	{
		maxDamage = math.huge,
		color = Color3.fromRGB (255, 0, 0)
	}
}

-- Colors for healing
local EFFECT_COLORS_POSITIVE = {
	{
		maxDamage = 1,
		color = Color3.fromRGB (0, 170, 0),
	},
	{
		maxDamage = math.huge,
		color = Color3.fromRGB (0, 255, 0)
	}
}

local DEF_STROKE_COLOR = Color3.fromRGB(12, 12, 12)

function getColor (damage)
	local colors = damage > 0 and EFFECT_COLORS_POSITIVE or EFFECT_COLORS_NEGATIVE;
	damage = math.abs (damage);
	
	for _,data in pairs (colors) do
		if (damage < data.maxDamage) then
			return {
				color = data.color,
				strokeColor = data.strokeColor or DEF_STROKE_COLOR
			};
		end
	end
end

return getColor;