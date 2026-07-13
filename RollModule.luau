const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Packages = ReplicatedStorage.Packages
const Shared = ReplicatedStorage.Shared

const Modules = Shared.Modules

const Elements = require(Modules.Parent.Data.Elements)
const Bubbles = require(Modules.Parent.Data.Bubbles)
const Rng = require(Packages.Rng.Rng)

local RollModule = {}

function RollModule:Roll(Luck: NumberValue)
	local rng = Random.new()

	local BubbleName = "bubble" .. "_" .. "element"
	local ElementC

	local Bubbleroll = rng:NextNumber()

	for _, bubble in ipairs(Bubbles) do
		if Bubbleroll <= bubble.chance * Luck then
			BubbleName = string.gsub(BubbleName, "bubble", bubble.name)
			BubbleName = string.gsub(BubbleName, "element", self:RollElement(Luck).name)
			return BubbleName
		end
	end
	return nil
end

function RollModule:RollElement(Luck: NumberValue)
	local rng = Random.new()
	local ElementRoll = rng:NextNumber()
		
	for _, element in ipairs(Elements) do
		if ElementRoll <= element.chance * Luck then
			return element
		end
	end
end

return RollModule
