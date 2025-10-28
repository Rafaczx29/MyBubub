-- =============================================================
-- PREDICTIVE FISHING - TARIK SEBELUM TANDA (!)
-- =============================================================
local ToolSlot = 1         
local BiteDelay = 0.9      -- Dikurangi karena tarik sebelum tanda (!) muncul

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
-- PREDICTIVE FISHING - THE SECRET
-- =============================================================

local function PredictiveFishing()
    print("=== PREDICTIVE FISHING STARTED ===")
    
    EquipToolEvent:FireServer(ToolSlot)
    task.wait(0.2)
    
    while true do
        -- Lempar umpan
        pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
        pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
        
        -- TUNGGU LEBIH SINGKAT - tarik SEBELUM tanda (!) muncul
        task.wait(0.9)  -- Bukan 1.3, tapi 0.9 detik!
        
        -- Tarik ikan (tanda (!) belum muncul tapi ikan sudah bisa ditarik)
        FishingCompletedEvent:FireServer()
        
        -- LANGSUNG lempar lagi tanpa reset delay
        -- Rod tetap equip, ga perlu unequip
        pcall(ChargeRodFunc.InvokeServer, ChargeRodFunc)
        pcall(RequestMinigameFunc.InvokeServer, RequestMinigameFunc, CastingX, CastingY, tick())
        
        -- Tidak ada delay tambahan
    end
end

-- Start
task.spawn(PredictiveFishing)
