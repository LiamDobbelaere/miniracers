AddCSLuaFile()

ENT.PrintName = "The G"
ENT.Author = "Digaly"
ENT.Information = "Movement keys = control, E = change camera, R = reset"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "sent_miniracer"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:GetMRModel()
    return "models/miniracers/mrcar02.mdl"
end

function ENT:GetMRStats()
    return {
        acceleration = 1400,
        steer = 15000,
        drift = 0.1,
        pitchMin = 50,
        pitchBase = 60,
        pitchVelocityMultiplier = 0.3
    }
end
