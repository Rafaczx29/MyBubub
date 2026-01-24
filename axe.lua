local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "lll HUB | Hatch Speed",
    LoadingTitle = "loading",
    LoadingSubtitle = "by Thanetnat",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Egg Settings")

local HatchSlider = Tab:CreateSlider({
    Name = "Hatch Speed",
    Range = {1, 7}, -- Dikunci maksimal 7x
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(Value)
        -- Mencari folder Stats di ReplicatedStorage
        local Stats = game:GetService("ReplicatedStorage"):FindFirstChild("Stats")
        if Stats then
            local PlayerStats = Stats:FindFirstChild(game.Players.LocalPlayer.Name)
            if PlayerStats and PlayerStats:FindFirstChild("EggStats") then
                local HatchSpeed = PlayerStats.EggStats:FindFirstChild("HatchSpeed")
                if HatchSpeed then
                    HatchSpeed.Value = Value
                end
            end
        end
    end,
})

local SettingTab = Window:CreateTab("Setting", 4483362476)
SettingTab:CreateSection("Close Ui")

SettingTab:CreateButton({
    Name = "Destroy Gui",
    Callback = function()
        Rayfield:Destroy()
    end,
})

Rayfield:LoadConfiguration()
