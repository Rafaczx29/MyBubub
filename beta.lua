-- =============================================================
-- PROPER TIMING FISHING
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 1.2

local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true):FindFirstChild("_Index", true):FindFirstChild("sleitnick_net@0.2.0", true):FindFirstChild("net", true)

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs") 

-- =============================================================
-- FIXED TIMING FISHING
-- =============================================================

local function ProperFishingCycle()
    -- 1. Charge + Cast
    pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
    pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
    
    -- 2. Tunggu tanda (!)
    task.wait(BiteDelay)
    
    -- 3. TARIK IKAN DULU (pastikan ini selesai)
    FishingCompletedEvent:FireServer()
    
    -- 4. Tunggu sebentar biar ikan benar-benar tertarik
    task.wait(0.1)  -- Delay kecil untuk memastikan fishing completed diproses
    
    -- 5. Baru reset dan lempar lagi
    pcall(CancelInputsFunc.InvokeServer, CancelInputsFunc)
    EquipToolEvent:FireServer(0)
    task.wait(0.05)
    EquipToolEvent:FireServer(ToolSlot)
    
    return true
end

-- Start
task.wait(1)
EquipToolEvent:FireServer(ToolSlot)
task.wait(0.5)

while true do
    ProperFishingCycle()
end
