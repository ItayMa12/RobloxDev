const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Packages = ReplicatedStorage.Packages
const Shared = ReplicatedStorage.Shared

const Modules = Shared.Modules

const RollTimeModule = require(Modules.RollTimeModule)
const LuckModule = require(Modules.LuckModule)
const Network = require(Shared.Network.Network)
const Quint = require(Packages.Quint.Quint)

const DataService = require(Packages.DataService.DataService).server
const RollModule = require("../Modules/RollModule")

const Defualt_CONFIG = {
	{
		RollTime = 0,
	}
}

local RollService = {}

RollService.__index = RollService

function RollService._Start()
	local self = setmetatable({}, RollService)
	
	self.RollDB = {}
	
	Network:Connect("Roll", function(Player: Player)
		if self.RollDB[Player] then
			return
		else
			local RollTime = RollTimeModule:GetRollTime(Player)
			self.RollDB[Player] = Player
			Network:FireClient(Player, "RollTime", RollTime)
			task.delay(RollTime, function()
				self.RollDB[Player] = nil
			end)
		end
		
		const PlayerLuck = LuckModule:CalculateLuck(Player)
		self:Roll(Player, PlayerLuck)
	end)
	return self
end


function RollService:Roll(Player: Player, Luck: NumberValue)
	local Luck = tonumber(Luck)
	if not Luck or not Player then
		warn("Luck Found?: " .. Luck .. " ,Player Found?: ", Player.Name)
		return
	end
	local RollResult = RollModule:Roll(Luck)
	DataService:update(Player, "bubbles", function(Value)
		table.insert(Value, RollResult)
		return Value
	end)
end

return RollService
