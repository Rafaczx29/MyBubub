-- 🎣 AUTO FISH FAST TURBO (PARALLEL MODE)
-- by GPT-5

-- ⚙️ CONFIG
local ToolSlot = 1
local BiteDelay = 1.0
local CastingX, CastingY = -1.233184814453125, 0.04706447494934768

-- ⚙️ SERVICE SETUP
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true)
    and ReplicatedStorage.Packages:FindFirstChild("_Index", true)
    and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0", true)
    and ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]:FindFirstChild("net", true)

if not NetService then
    warn("❌ NetService tidak ditemukan.")
    return
end

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs")

-- ⚙️ CORE FUNCTIONS
local function EquipRod(slot)
    EquipToolEvent:FireServer(slot)
    task.wait(0.01)
end

local function ChargeRod()
    local ok = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    return ok
end

local function CastAndReel()
    local currentTime = tick()
    local args = {CastingX, CastingY, currentTime}
    local success, result = pcall(function()
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)
    if success and (result == true or type(result) == "table") then
        task.wait(BiteDelay)
        FishingCompletedEvent:FireServer()
        task.wait(0.003)
        pcall(function() CancelInputsFunc:InvokeServer() end)
        EquipRod(ToolSlot)
        return true
    end
    return false
end

-- 🧠 COUNTER SYSTEM
local fishCount, lastTime, rate = 0, tick(), 0
task.spawn(function()
    while task.wait(1) do
        local now = tick()
        local diff = now - lastTime
        if diff >= 1 then
            rate = fishCount / diff
            fishCount = 0
            lastTime = now
        end
    end
end)

-- 🎨 UI SETUP
local gui = Instance.new("ScreenGui", gethui and gethui() or game.CoreGui)
gui.Name = "AutoFishTurboUI"
gui.ResetOnSpawn = false

local icon = Instance.new("ImageButton", gui)
icon.Size = UDim2.new(0, 60, 0, 60)
icon.Position = UDim2.new(1, -70, 1, -80)
icon.Image = "rbxassetid://7072718362"
icon.BackgroundTransparency = 1
icon.ZIndex = 10

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 180)
frame.Position = UDim2.new(0.75, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.15
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🎣 Auto Fish Turbo"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1

task.spawn(function()
    while true do
        local t = tick() * 2
        title.TextColor3 = Color3.fromRGB(
            math.floor((math.sin(t) * 127) + 128),
            math.floor((math.sin(t + 2) * 127) + 128),
            math.floor((math.sin(t + 4) * 127) + 128)
        )
        task.wait(0.05)
    end
end)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Text = "Status: Idle"

local statsLabel = Instance.new("TextLabel", frame)
statsLabel.Size = UDim2.new(1, -20, 0, 25)
statsLabel.Position = UDim2.new(0, 10, 0, 65)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 13
statsLabel.TextColor3 = Color3.fromRGB(150, 220, 150)
statsLabel.Text = "Rate: 0/s | Fish: 0"

task.spawn(function()
    while task.wait(0.5) do
        statsLabel.Text = string.format("Rate: %.1f/s | Fish: %d", rate, fishCount)
    end
end)

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(0, 230, 0, 30)
delayBox.Position = UDim2.new(0.5, -115, 0, 95)
delayBox.PlaceholderText = "Bite Delay (ex: 1.0)"
delayBox.Text = tostring(BiteDelay)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 13
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delayBox.BorderSizePixel = 0
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 8)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 230, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -115, 1, -50)
toggleBtn.Text = "▶️ Start Auto Fish"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- 🖱️ ICON TOGGLE
icon.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- 🚀 MAIN LOGIC
local running, turbo = false, false

toggleBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        turbo = false
        status.Text = "Status: Idle"
        toggleBtn.Text = "▶️ Start Auto Fish"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    else
        running = true
        turbo = true
        status.Text = "Status: Turbo Mode"
        toggleBtn.Text = "⏸️ Stop Auto Fish"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        task.spawn(function()
            EquipRod(ToolSlot)
            while running do
                BiteDelay = tonumber(delayBox.Text) or 1.0
                if turbo then
                    for i = 1, 2 do
                        task.spawn(function()
                            if ChargeRod() then
                                if CastAndReel() then
                                    fishCount += 1
                                end
                            end
                        end)
                        task.wait(0.1)
                    end
                else
                    if ChargeRod() then
                        if CastAndReel() then
                            fishCount += 1
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)
