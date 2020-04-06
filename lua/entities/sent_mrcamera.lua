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
    self.mode = 3 -- Start in player pov

    self.forceFirstPerson = false
end

function ENT:Think()
    if (CLIENT) then return end
    
    local phys = self:GetPhysicsObject()
    if IsValid(self.target) then
        local traceToTarget = util.QuickTrace(self:GetTopDownCamPos(), self.target:GetPos() - self:GetTopDownCamPos(), self)
        local canSeeTarget = traceToTarget.Entity == self.target

        if not canSeeTarget && self.mode == 0 then
            self.forceFirstPerson = true
            self.mode = 1
            self:InitializeMode()
        end

        if canSeeTarget && self.forceFirstPerson && self.mode == 1 then
            self.forceFirstPerson = false
            self.mode = 0
            self:InitializeMode()
        end

        if self.mode == 0 then
            phys:SetVelocity((self:GetTopDownCamPos() - self:GetPos()) * 5)
        end
    end
end

function ENT:NextMode()
    self.mode = self.mode + 1

    if self.mode > 3 then
        self.mode = 0
    end
    
    self.forceFirstPerson = false

    self:InitializeMode()
end

function ENT:InitializeMode()
    self:SetParent(nil)

    if self.mode == 0 then
        -- Top-down
        self:SetPos(self:GetTopDownCamPos())
        self:SetAngles(Angle(90, 0, 0))
        self.player:SetViewEntity(self)
    elseif self.mode == 1 then
        -- First-person
        self:SetPos(self.target:LocalToWorld(Vector(-3, 0, 4)))
        self:SetAngles(self.target:GetAngles())
        self:SetParent(self.target)
        self.player:SetViewEntity(self)
    elseif self.mode == 2 then
        -- Third-person
        self:SetPos(self.target:LocalToWorld(Vector(-25, 0, 8)))
        self:SetAngles(self.target:GetAngles())
        self:SetParent(self.target)
        self.player:SetViewEntity(self)
    elseif self.mode == 3 then
        -- No camera
        self.player:SetViewEntity(nil)
    end
end

function ENT:GetTopDownCamPos()
    return self.target:GetPos() + Vector(0, 0, self.distance)
end