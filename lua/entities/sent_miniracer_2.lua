AddCSLuaFile()

ENT.PrintName = "Miniracer The G"
ENT.Author = "Digaly"
ENT.Information = "Movement keys = control, E = change camera, R = reset"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "sent_miniracer"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:GetMRModel()
    return "models/miniracers/mrcar02.mdl"
end