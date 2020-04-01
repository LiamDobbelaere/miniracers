AddCSLuaFile()

ENT.PrintName = "Miniracer Test"
ENT.Author = "Digaly"
ENT.Information = "Use movement keys to control"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 25)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self.engineSound = CreateSound(self, "ambient/energy/electric_loop.wav")
    self.engineSound:Play()

    if (CLIENT) then return end

    self:SetModel("models/miniracers/mrcar01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake() 
        --phys:EnableDrag(false)
        --phys:EnableGravity(false)
        --phys:SetDamping(0, 0)
        --phys:SetAngleDragCoefficient(0)
    end

    self.cam = ents.Create("sent_mrcamera")
    self.cam.target = self;
    self.cam:SetPos(self:GetPos())
    self.cam:Spawn()
    self.cam:Activate()
end

function ENT:OnRemove()
    self.engineSound:Stop()

    if (CLIENT) then return end
    self:GetCreator():SetViewEntity(NULL)
end

function ENT:Think()
    if (CLIENT) then return end
    
    local owner = self:GetCreator()
    local inputForward = owner:KeyDown(IN_FORWARD)
    local inputReverse = owner:KeyDown(IN_BACK)
    local inputLeft = owner:KeyDown(IN_MOVELEFT)
    local inputRight = owner:KeyDown(IN_MOVERIGHT)

    owner:SetViewEntity(self.cam)

    local phy = self:GetPhysicsObject()

    self.cam.distance = phy:GetVelocity():Length() * 0.5 + 150
    
    if inputForward || inputReverse then
        self.engineSound:ChangePitch(200, 2)
        self.engineSound:ChangeVolume(1, 0.2)
    else
        self.engineSound:ChangePitch(50, 0.5)
        self.engineSound:ChangeVolume(0, 0.2)
    end

    local accForce = 100
    if (inputForward) then
        phy:ApplyForceCenter(self:GetForward() * accForce)
    elseif (inputReverse) then
        phy:ApplyForceCenter(self:GetForward() * accForce * -0.5)
    elseif (phy:GetVelocity():Length() < 0) then
        --phy:ApplyForceCenter(self:GetForward() * accForce * -0.5)
    end


    local avForce = 300 --phy:GetVelocity():Length() * 1.5
    if (inputLeft) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, avForce))
    elseif (inputRight) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, -avForce))
    else
        phy:AddAngleVelocity(-phy:GetAngleVelocity())
    end
end
