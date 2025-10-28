-- 🎣 Fast Fish Optimized (Non-blocking + Parallel Attempts + UI)
-- Keep core RPC logic intact. Toggle start/stop, BiteDelay, and Threads.

local ToolSlot = 1
local DefaultBiteDelay = 1.0
local DefaultThreads = 1
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

local player = game.Players.LocalPlayer
local guiParent = gethui and gethui() or game.CoreGui

-- UI
local screen = Instance.new("ScreenGui", guiParent)
screen.Name = "FastFishOptimizedUI"
screen.ResetOnSpawn = false

local icon = Instance.new("ImageButton", screen)
icon.Size = UDim2.new(0, 70, 0, 70)
icon.Position = UDim2.new(1, -90, 1, -100)
icon.AnchorPoint = Vector2.new(1, 1)
icon.Image = "rbxassetid://7072718362"
icon.BackgroundTransparency = 1
icon.AutoButtonColor = true

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 320, 0, 170)
frame.Position = UDim2.new(0.65, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "🎣 Fast Fish (Optimized)"
title.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0,12,0,40)
status.Size = UDim2.new(0.6, -12, 0, 20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Text = "Status: Idle"

local counterLabel = Instance.new("TextLabel", frame)
counterLabel.Position = UDim2.new(0.62, 0, 0, 40)
counterLabel.Size = UDim2.new(0.38, -12, 0, 20)
counterLabel.BackgroundTransparency = 1
counterLabel.Font = Enum.Font.Gotham
counterLabel.TextSize = 13
counterLabel.TextColor3 = Color3.fromRGB(200,200,200)
counterLabel.Text = "Bites: 0"

local biteLabel = Instance.new("TextLabel", frame)
biteLabel.Position = UDim2.new(0, 12, 0, 66)
biteLabel.Size = UDim2.new(0, 120, 0, 20)
biteLabel.BackgroundTransparency = 1
biteLabel.Font = Enum.Font.Gotham
biteLabel.TextSize = 13
biteLabel.TextColor3 = Color3.fromRGB(200,200,200)
biteLabel.Text = "BiteDelay (s):"

local biteBox = Instance.new("TextBox", frame)
biteBox.Position = UDim2.new(0, 140, 0, 64)
biteBox.Size = UDim2.new(0, 160, 0, 24)
biteBox.BackgroundColor3 = Color3.fromRGB(38,38,38)
biteBox.TextColor3 = Color3.fromRGB(230,230,230)
biteBox.Font = Enum.Font.Gotham
biteBox.TextSize = 14
biteBox.Text = tostring(DefaultBiteDelay)
biteBox.ClearTextOnFocus = false
Instance.new("UICorner", biteBox).CornerRadius = UDim.new(0,6)

local threadLabel = Instance.new("TextLabel", frame)
threadLabel.Position = UDim2.new(0, 12, 0, 96)
threadLabel.Size = UDim2.new(0, 120, 0, 20)
threadLabel.BackgroundTransparency = 1
threadLabel.Font = Enum.Font.Gotham
threadLabel.TextSize = 13
threadLabel.TextColor3 = Color3.fromRGB(200,200,200)
threadLabel.Text = "Threads:"

local threadBox = Instance.new("TextBox", frame)
threadBox.Position = UDim2.new(0, 140, 0, 94)
threadBox.Size = UDim2.new(0, 160, 0, 24)
threadBox.BackgroundColor3 = Color3.fromRGB(38,38,38)
threadBox.TextColor3 = Color3.fromRGB(230,230,230)
threadBox.Font = Enum.Font.Gotham
threadBox.TextSize = 14
threadBox.Text = tostring(DefaultThreads)
threadBox.ClearTextOnFocus = false
Instance.new("UICorner", threadBox).CornerRadius = UDim.new(0,6)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Position = UDim2.new(0.5, -110, 1, -46)
toggleBtn.Size = UDim2.new(0, 220, 0, 36)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,160,80)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Text = "▶ Start"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

-- RGB title effect
task.spawn(function()
	while title.Parent do
		local t = tick() * 2
		title.TextColor3 = Color3.new((math.sin(t)*0.5+0.5),(math.sin(t+2)*0.5+0.5),(math.sin(t+4)*0.5+0.5))
		task.wait(0.05)
	end
end)

icon.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local running = false
local bites = 0

local function EquipRod(slot)
    pcall(function() EquipToolEvent:FireServer(slot) end)
    task.wait(0.01)
end

local function ChargeRod()
    local ok = pcall(function() return ChargeRodFunc:InvokeServer() end)
    return ok
end

local function tryCastOnce(biteDelay)
    local ok, res = pcall(function()
        return RequestMinigameFunc:InvokeServer(CastingX, CastingY, tick())
    end)
    if ok and (res == true or type(res) == "table") then
        task.wait(biteDelay)
        pcall(function() FishingCompletedEvent:FireServer() end)
        task.wait(0.005)
        pcall(function() CancelInputsFunc:InvokeServer() end)
        pcall(function() EquipRod(ToolSlot) end)
        bites = bites + 1
        counterLabel.Text = "Bites: "..bites
        return true
    end
    return false
end

local function startFishingLoop()
    local threads = math.clamp(tonumber(threadBox.Text) or DefaultThreads, 1, 6)
    local biteDelay = tonumber(biteBox.Text) or DefaultBiteDelay
    EquipRod(ToolSlot)
    task.wait(0.05)
    status.Text = "Status: Running..."
    running = true

    -- master controller loop: spawn worker coroutines as threads
    while running do
        if not running then break end
        -- attempt charge once (cheap) before spawning workers
        local charged = ChargeRod()
        if charged then
            local workers = {}
            for t = 1, threads do
                workers[t] = task.spawn(function()
                    -- each worker will attempt a cast; if succeeds, it reports via tryCastOnce
                    tryCastOnce(biteDelay)
                end)
            end
            -- small throttle so we don't overload server with too many requests per frame
            task.wait(0.02)
        else
            task.wait(0.03)
        end
    end
    status.Text = "Status: Idle"
end

toggleBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        toggleBtn.Text = "▶ Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40,160,80)
    else
        bites = 0
        counterLabel.Text = "Bites: 0"
        toggleBtn.Text = "⏸ Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
        task.spawn(startFishingLoop)
    end
end)
