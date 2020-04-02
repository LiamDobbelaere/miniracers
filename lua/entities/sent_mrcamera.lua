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
    self.mode = 2
end

function ENT:Think()
    if (CLIENT) then return end
    
    local phys = self:GetPhysicsObject()
    if IsValid(self.target) then
        if self.mode == 0 then
            phys:SetVelocity(((self.target:GetPos() + Vector(0, 0, self.distance)) - self:GetPos()) * 5)
        end
    end
end

function ENT:NextMode()
    self.mode = self.mode + 1

    if self.mode > 2 then
        self.mode = 0
    end

    if self.mode == 0 then
        self:SetParent(nil)
        self:SetPos(self.target:GetPos() + Vector(0, 0, self.distance))
        self:SetAngles(Angle(90, 0, 0))
        self.player:SetViewEntity(self)
    elseif self.mode == 1 then
        self:SetPos(self.target:GetPos() + Vector(0, 0, 5))
        self:SetAngles(self.target:GetAngles())
        self:SetParent(self.target)
        self.player:SetViewEntity(self)
    elseif self.mode == 2 then  
        self.player:SetViewEntity(nil)
    end
end
