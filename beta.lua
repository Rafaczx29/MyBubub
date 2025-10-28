--// ULTRA FAST FISH GUI - UNIVERSAL VERSION (WORKING)
local player = game.Players.LocalPlayer
local guiParent = gethui and gethui() or game.CoreGui or player:WaitForChild("PlayerGui")

if guiParent:FindFirstChild("UltraFishUI") then
	guiParent.UltraFishUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraFishUI"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false

-- 🪣 Icon (pojok kanan bawah)
local IconButton = Instance.new("ImageButton")
IconButton.Name = "IconButton"
IconButton.Image = "rbxassetid://11293942965"
IconButton.Size = UDim2.new(0, 60, 0, 60)
IconButton.Position = UDim2.new(1, -75, 1, -80)
IconButton.BackgroundTransparency = 1
IconButton.ZIndex = 10
IconButton.Parent = ScreenGui

-- 🪟 Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 160)
MainFrame.Position = UDim2.new(1, -275, 1, -255)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- 🧠 Judul (RGB)
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ULTRA FAST FISH"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)

task.spawn(function()
	while true do
		for i = 0, 255 do
			Title.TextColor3 = Color3.fromHSV(i/255, 1, 1)
			task.wait(0.02)
		end
	end
end)

-- 🎚️ Bite Delay label
local BiteLabel = Instance.new("TextLabel", MainFrame)
BiteLabel.Text = "Bite Delay:"
BiteLabel.Size = UDim2.new(0, 100, 0, 30)
BiteLabel.Position = UDim2.new(0, 10, 0, 60)
BiteLabel.TextColor3 = Color3.new(1,1,1)
BiteLabel.BackgroundTransparency = 1
BiteLabel.Font = Enum.Font.Gotham
BiteLabel.TextSize = 14

-- 📝 Input Box
local BiteBox = Instance.new("TextBox", MainFrame)
BiteBox.Size = UDim2.new(0, 120, 0, 30)
BiteBox.Position = UDim2.new(0, 110, 0, 60)
BiteBox.PlaceholderText = "Default: 1.0"
BiteBox.Text = ""
BiteBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
BiteBox.TextColor3 = Color3.new(1,1,1)
BiteBox.Font = Enum.Font.Gotham
BiteBox.TextSize = 14
Instance.new("UICorner", BiteBox).CornerRadius = UDim.new(0, 6)

-- ▶️ Start / Stop button
local StartButton = Instance.new("TextButton", MainFrame)
StartButton.Size = UDim2.new(0, 230, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 110)
StartButton.Text = "START"
StartButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
StartButton.TextColor3 = Color3.new(1,1,1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 8)

-- 🧩 Handler
local running = false
local fishThread

IconButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

StartButton.MouseButton1Click:Connect(function()
	if not running then
		running = true
		StartButton.Text = "STOP"
		StartButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

		local ToolSlot = 1
		local BiteDelay = tonumber(BiteBox.Text) or 1.0
		local ChargeTime = 0.0
		local CastingX, CastingY = -1.233184814453125, 0.04706447494934768

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local NetService = ReplicatedStorage:FindFirstChild("Packages", true)
			and ReplicatedStorage.Packages:FindFirstChild("_Index", true)
			and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0", true)
			and ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]:FindFirstChild("net", true)
		if not NetService then return end

		local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
		local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
		local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted")
		local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
		local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs")

		local timestampOffset = 0
		local function GetOptimizedTimestamp() return tick() + timestampOffset end
		local function CalibrateTimestamp() timestampOffset = -0.05 end
		local function EquipFishingRod(slot) EquipToolEvent:FireServer(slot) end
		local function UltraCombinedChargeAndCast()
			local currentTime = GetOptimizedTimestamp()
			local charge_success = pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
			if charge_success then
				local cast_success, cast_result = pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, currentTime)
				if not cast_success then CalibrateTimestamp() end
				return cast_success and (cast_result == true or type(cast_result) == "table")
			end
			return false
		end
		local function UltraFastCastAndReel()
			if UltraCombinedChargeAndCast() then
				local waitStart = tick()
				local actualWait = BiteDelay - 0.05
				while tick() - waitStart < actualWait do task.wait(0.01) end
				FishingCompletedEvent:FireServer()
				task.wait(0.001)
				pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
				EquipToolEvent:FireServer(0)
				return true
			end
			return false
		end
		local function UltraFastAutoFish()
			CalibrateTimestamp()
			EquipFishingRod(ToolSlot)
			task.wait(0.3)
			local failCount, successCount, cycleCount = 0, 0, 0
			while running do
				cycleCount += 1
				if cycleCount % 20 == 0 then CalibrateTimestamp() end
				local success = UltraFastCastAndReel()
				if success then
					successCount += 1
					failCount = 0
				else
					failCount += 1
					successCount = 0
					task.wait(failCount >= 2 and 0.01 or 0.002)
				end
				if successCount >= 10 then
					EquipToolEvent:FireServer(0)
					task.wait(0.05)
					EquipFishingRod(ToolSlot)
					successCount = 0
				end
			end
		end

		fishThread = task.spawn(UltraFastAutoFish)
	else
		running = false
		StartButton.Text = "START"
		StartButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
	end
end)
