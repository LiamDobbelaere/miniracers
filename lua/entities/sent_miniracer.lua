AddCSLuaFile()

ENT.PrintName = "Miniracer Test"
ENT.Author = "Digaly"
ENT.Information = "Movement keys = control, E = change camera, R = reset"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = true
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

function ENT:Initialize()
    self.engineSound = CreateSound(self, "ambient/energy/electric_loop.wav")
    self.engineSound:Play()

    if (CLIENT) then return end

    self:SetModel(self:GetMRModel())
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self.stats = self:GetMRStats()
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake() 
        phys:EnableDrag(false)
        --phys:EnableGravity(false)
        phys:SetDamping(1 - self.stats.drift, 0)
        phys:SetAngleDragCoefficient(0)
    end

    self.thinkOnce = false

    self.cam = ents.Create("sent_mrcamera")
    self.cam.target = self;
    self.cam:SetPos(self:GetPos())
    self.cam:Spawn()
    self.cam:Activate()
end 

function ENT:GetMRModel()
    return "models/Gibs/HGIBS.mdl"
end

function ENT:GetMRStats()
    return {
        acceleration = 1000,
        steer = 15000,
        drift = 1,
        pitchMin = 50,
        pitchMax = 200
    }
end

function ENT:OnRemove()
    self.engineSound:Stop()

    if (CLIENT) then return end

    if IsValid(self.cam) then
        self.cam:Remove()
    end

    self:GetCreator():SetViewEntity(NULL)
end

function ENT:Think()
    if (CLIENT) then return end
    
    local forwardNoUp = Vector(self:GetForward().x, 0, self:GetForward().z) 

    if not self.thinkOnce then
        self.cam.player = self:GetCreator()
        self.cam:NextMode()
        self.thinkOnce = true
    end

    local owner = self:GetCreator()
    local inputForward = owner:KeyDown(IN_FORWARD)
    local inputReverse = owner:KeyDown(IN_BACK)
    local inputLeft = owner:KeyDown(IN_MOVELEFT)
    local inputRight = owner:KeyDown(IN_MOVERIGHT)
    local inputCam = owner:KeyPressed(IN_USE)
    local inputReset = owner:KeyPressed(IN_RELOAD)

    if inputCam then
        self.cam:NextMode()
    end
    
    if inputReset then
        local currentAngles = self:GetAngles()
        self:SetAngles(Angle(0, currentAngles.y, 0))
    end

    local phy = self:GetPhysicsObject()

    self.cam.distance = phy:GetVelocity():Length() * 0.5 + 150
    
    if inputForward || inputReverse then
        self.engineSound:ChangePitch(self.stats.pitchMax, 2)
        self.engineSound:ChangeVolume(1, 0.2)
    else
        self.engineSound:ChangePitch(self.stats.pitchMin, 0.5)
        self.engineSound:ChangeVolume(0, 0.2)
    end

    -- Help with going up slopes
    local slopeAdjust = 0
    if self:GetAngles().x < 0 then
        slopeAdjust = self:GetAngles().x * -40
    end

    local accForce = self.stats.acceleration + slopeAdjust
    if (inputForward) then
        phy:ApplyForceCenter(self:GetForward() * accForce * FrameTime())
    elseif (inputReverse) then
        phy:ApplyForceCenter(self:GetForward() * accForce * -0.5 * FrameTime())
    else
        phy:SetVelocity(phy:GetVelocity() * 0.98)
    end

    local avForce = self.stats.steer
    if (inputLeft) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, avForce * FrameTime()))
    elseif (inputRight) then
        phy:AddAngleVelocity(-phy:GetAngleVelocity() + Vector(0, 0, -avForce * FrameTime()))
    else
        phy:AddAngleVelocity(-phy:GetAngleVelocity())
    end

    self:NextThink( CurTime())
	return true
end
