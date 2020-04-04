AddCSLuaFile()

ENT.PrintName = "PD-44"
ENT.Author = "Digaly"
ENT.Information = "Movement keys = control, E = change camera, R = reset"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "sent_miniracer"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:GetMRModel()
    return "models/miniracers/mrcar04.mdl"
end

function ENT:GetMRStats()
    return {
        acceleration = 1400,
        steer = 15000,
        drift = 0.1,
        pitchMin = 50,
        pitchBase = 80,
        pitchVelocityMultiplier = 1
    }
end
