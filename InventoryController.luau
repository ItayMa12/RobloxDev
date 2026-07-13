const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Players = game:GetService("Players")

const Packages = ReplicatedStorage.Packages
const Shared = ReplicatedStorage.Shared

const Modules = Shared.Modules

const Quint = require(Packages.Quint.Quint)

const DataService = require(Packages.DataService:WaitForChild("DataService")).client

const BubbleInfo = require(ReplicatedStorage.Shared.Data.Bubbles)

const Player = Players.LocalPlayer

const BubbleFolder = ReplicatedStorage:WaitForChild("Bubbles")

const PlayerGui = Player.PlayerGui
const MainGuiFolder = PlayerGui:WaitForChild("MainGui")
const MainGui = MainGuiFolder:WaitForChild("InventoryGui")

const MainFrame = MainGui:WaitForChild("MainInventoryFrame")
const ScrollingFrame = MainFrame:WaitForChild("BubblesScroll")
const Template = ScrollingFrame:WaitForChild("Template")

local Inventory = {}

function Inventory._Start()
	DataService:waitForData()
	Inventory:SetInventory()

	DataService:getChangedSignal("bubbles"):Connect(function(BubblesTable)
		Inventory:SetInventory()
	end)
end

function Inventory:SetInventory()
	local function GetBubbleAmount(Name: string)
		local list = {}
		
		for i, bubble in ipairs(DataService:get("bubbles")) do
			local BubbleName = string.split(bubble, "_")
			if BubbleName[1] == Name then
				table.insert(list, Name)
			end
		end
		
		return #list
	end
	
	for i, bubble in ipairs(DataService:get("bubbles")) do
		local Name = string.split(bubble, "_")
		if BubbleFolder:FindFirstChild(Name[1]) and not ScrollingFrame:FindFirstChild(Name[1]) then			
			local BubbleModel = BubbleFolder:FindFirstChild(Name[1])
			local TemplateClone = Template:Clone()
			TemplateClone.Name = Name[1]
			TemplateClone.BubbleImage.Image = BubbleModel:FindFirstChildOfClass("ImageLabel").Image
			
			TemplateClone.AmountText.BubbleAmt.Value = 1
			
			TemplateClone.Visible = true
			Inventory:SetUpHover(TemplateClone, MainGui.HoverFrame, Name[1])
			TemplateClone.Parent = ScrollingFrame
			
		elseif BubbleFolder:FindFirstChild(Name[1]) and ScrollingFrame:FindFirstChild(Name[1]) then
			local Amount = GetBubbleAmount(Name[1])
			
			local BubbleTemplate = ScrollingFrame:FindFirstChild(Name[1])
			BubbleTemplate:WaitForChild("AmountText").BubbleAmt.Value = Amount
			BubbleTemplate.AmountText.Visible = true and Amount >= 1 or false
			BubbleTemplate.AmountText.Text = Amount
		end
	end
end

function Inventory:SetUpHover(Template: Frame, HoverFrame: Frame, BubbleName: string)
	local function FindBubbleChance()
		for i, bubble in ipairs(BubbleInfo) do
			if bubble.name == BubbleName then				
				return bubble.chanceInNumber
			end
		end
	end
	
	local Conn: RBXScriptConnection
	local offset = UDim2.new(0, 15, 0, 10)
	
	Template.MouseEnter:Connect(function()
		local ChanceTemplate = "1/%d"
		Conn = RunService.Heartbeat:Connect(function()
			local Mouse = Player:GetMouse()
			
			HoverFrame.NameLabel.Text = Template.Name
			
			local ChanceNumb = (FindBubbleChance())
			local Chance = string.format(ChanceTemplate, tonumber(ChanceNumb))
			
			HoverFrame.ChanceLabel.Text = Chance
			
			HoverFrame.Visible = true
			HoverFrame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y) + offset
		end)
	end)
	
	Template.MouseLeave:Connect(function()
		if Conn then
			Conn:Disconnect()
			Conn = nil
		end
		HoverFrame.Visible = false
	end)
end

return Inventory
