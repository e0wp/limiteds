local messanger = game:GetService("Players")

local equippedHeadless = false
local equippedKorblox = false
local headlessLoop = nil
local korbloxLoop = nil
local equippedAccessories = {}
local accessoryLoops = {}


if not api then
    error("API library not found!")
end

local visualstab = api:GetTab("visuals") or api:AddTab("visuals")
local larpgrp = visualstab:AddLeftGroupbox("Larp Limiteds")

local accessories = {
    {name = "Silver King of The Night", type = "hat", id = 439945661},
    {name = "Classic Fedora", type = "hat", id = 1029025},
    {name = "Void Star", type = "hat", id = 1125510},
    {name = "Valkyrie Helm", type = "hat", id = 1365767},
    {name = "Scissors", type = "hat", id = 6550129},
    {name = "Black Iron Horns", type = "hat", id = 628771505},
    {name = "Poisoned Horns of the Toxic Wasteland", type = "hat", id = 1744060292},
    {name = "Frozen Horns of the Frigid Planes", type = "hat", id = 74891470},
    {name = "Fiery Horns of the Netherworld", type = "hat", id = 215718515},
}

local function equipAccessory(itemId, itemName, itemType, enabled)
    if enabled then
        local character = game.Players.LocalPlayer.Character
        if not character then
            api:notify("Character not found")
            return
        end
        
        if accessoryLoops[itemId] then
            accessoryLoops[itemId]:Disconnect()
        end
        
        local success = pcall(function()
            local items = game:GetObjects("rbxassetid://" .. itemId)
            
            if #items == 0 then
                api:notify("Failed to load " .. itemName)
                return
            end
            
            local accessory = nil
            if items[1]:IsA("Accessory") then
                accessory = items[1]
            else
                for _, child in ipairs(items[1]:GetDescendants()) do
                    if child:IsA("Accessory") then
                        accessory = child
                        break
                    end
                end
            end
            
            if not accessory then
                api:notify("No accessory found")
                return
            end
            
            local handle = accessory:FindFirstChild("Handle")
            if not handle then
                api:notify("No Handle")
                return
            end
            
            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
            if not mesh then
                api:notify("No mesh found")
                return
            end
            
            local meshId = mesh.MeshId
            local textureId = mesh.TextureId
            
            local particleEffects = {}
            for _, child in ipairs(handle:GetDescendants()) do
                if child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") or child:IsA("Sparkles") then
                    table.insert(particleEffects, child:Clone())
                end
            end
            
            local attachmentOffset = CFrame.new(0, 0, 0)
            local handleAttachment = handle:FindFirstChildOfClass("Attachment")
            if handleAttachment then
                attachmentOffset = handleAttachment.CFrame:Inverse()
            end
            
            local cachedMeshId = meshId
            local cachedTextureId = textureId
            local cachedOffset = attachmentOffset
            local handleCreated = false
            
            accessoryLoops[itemId] = game:GetService("RunService").RenderStepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local accHandle = head:FindFirstChild(itemName .. "_Handle")
                        
                        if not accHandle then
                            accHandle = Instance.new("Part")
                            accHandle.Name = itemName .. "_Handle"
                            accHandle.Size = Vector3.new(1, 1, 1)
                            accHandle.Transparency = 1
                            accHandle.CanCollide = false
                            accHandle.Massless = true
                            accHandle.Anchored = false
                            accHandle.Parent = head
                            
                            local accMesh = Instance.new("SpecialMesh")
                            accMesh.MeshId = cachedMeshId
                            accMesh.TextureId = cachedTextureId
                            accMesh.Parent = accHandle
                            
                            local weld = Instance.new("Weld")
                            weld.Part0 = head
                            weld.Part1 = accHandle
                            weld.C0 = CFrame.new(0, 0.5, 0) * cachedOffset
                            weld.Parent = accHandle
                            
                            for _, effect in ipairs(particleEffects) do
                                local effectClone = effect:Clone()
                                effectClone.Parent = accHandle
                            end
                            
                            accHandle.Transparency = 0
                            handleCreated = true
                        elseif not handleCreated then
                            local accMesh = accHandle:FindFirstChildOfClass("SpecialMesh")
                            if accMesh then
                                accMesh.MeshId = cachedMeshId
                                accMesh.TextureId = cachedTextureId
                            end
                            accHandle.Transparency = 0
                            handleCreated = true
                        end
                    end
                end
            end)
            
            equippedAccessories[itemId] = true
            api:notify("Equipped " .. itemName)
        end)
        
        if not success then
            api:notify("Error loading " .. itemName)
        end
    else
        if accessoryLoops[itemId] then
            accessoryLoops[itemId]:Disconnect()
            accessoryLoops[itemId] = nil
        end
        
        local char = game.Players.LocalPlayer.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local accHandle = head:FindFirstChild(itemName .. "_Handle")
                if accHandle then
                    accHandle:Destroy()
                end
            end
        end
        
        equippedAccessories[itemId] = nil
        api:notify("Removed " .. itemName)
    end
end

local function equipHeadless(enabled)
    if enabled then
        if headlessLoop then
            headlessLoop:Disconnect()
        end
        
        headlessLoop = game:GetService("RunService").RenderStepped:Connect(function()
            local character = game.Players.LocalPlayer.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    head.Transparency = 1
                    for _, v in pairs(head:GetChildren()) do
                        if v:IsA("Decal") then
                            v.Transparency = 1
                        end
                    end
                end
            end
        end)
        
        equippedHeadless = true
        api:notify("Equipped Headless")
    else
        if headlessLoop then
            headlessLoop:Disconnect()
            headlessLoop = nil
        end
        
        local character = game.Players.LocalPlayer.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                head.Transparency = 0
                for _, v in pairs(head:GetChildren()) do
                    if v:IsA("Decal") then
                        v.Transparency = 0
                    end
                end
            end
        end
        
        equippedHeadless = false
        api:notify("Removed Headless")
    end
end

local function equipKorblox(enabled)
    if enabled then
        if korbloxLoop then
            korbloxLoop:Disconnect()
        end
        
        korbloxLoop = game:GetService("RunService").RenderStepped:Connect(function()
            local character = game.Players.LocalPlayer.Character
            if character then
                local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
                local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
                local rightFoot = character:FindFirstChild("RightFoot")
                
                if rightLowerLeg then
                    rightLowerLeg.MeshId = "902942093"
                    rightLowerLeg.Transparency = 1
                end
                
                if rightUpperLeg then
                    rightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
                    rightUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398"
                end
                
                if rightFoot then
                    rightFoot.MeshId = "902942089"
                    rightFoot.Transparency = 1
                end
            end
        end)
        
        equippedKorblox = true
        api:notify("Equipped Korblox")
    else
        if korbloxLoop then
            korbloxLoop:Disconnect()
            korbloxLoop = nil
        end
        
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local currentHealth = humanoid.Health
                humanoid.Health = 0
                task.wait(0.1)
                game.Players.LocalPlayer.CharacterAdded:Wait()
                task.wait(0.5)
                local newHumanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if newHumanoid then
                    newHumanoid.Health = currentHealth
                end
            end
        end
        
        equippedKorblox = false
        api:notify("Removed Korblox")
    end
end

larpgrp:AddToggle("larp_headless", {
    Text = "Headless",
    Default = false,
    Tooltip = "Equip Headless",
    Callback = function(value)
        equipHeadless(value)
    end
})

larpgrp:AddToggle("larp_korblox", {
    Text = "Korblox",
    Default = false,
    Tooltip = "Equip Korblox Right Leg",
    Callback = function(value)
        equipKorblox(value)
    end
})

for _, item in ipairs(accessories) do
    larpgrp:AddToggle("larp_" .. item.id, {
        Text = item.name,
        Default = false,
        Tooltip = "Equip " .. item.name,
        Callback = function(value)
            equipAccessory(item.id, item.name, item.type, value)
        end
    })
end