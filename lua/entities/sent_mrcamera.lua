AddCSLuaFile()

ENT.PrintName = "Miniracers Camera"
ENT.Author = "Digaly"
ENT.Information = "Don't breathe this"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 25)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Draw()
    
end

function ENT:Initialize()
    if (CLIENT) then return end

    self:SetModel("models/dav0r/camera.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_NONE)
    self:GetPhysicsObject():EnableGravity(false)
    self:DrawShadow(false)

    self.distance = 100
end

function ENT:Think()
    if (CLIENT) then return end
    
    local phys = self:GetPhysicsObject()
    if IsValid(self.target) then
        phys:SetVelocity(((self.target:GetPos() + Vector(0, 0, self.distance)) - self:GetPos()) * 5)
        self:SetAngles(Angle(90, 0, 0))
    end
end
