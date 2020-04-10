AddCSLuaFile()

ENT.PrintName = "Race Checkpoint"
ENT.Author = "Digaly"
ENT.Information = "Don't breathe this"
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
    if (CLIENT) then return end

    self:SetModel("models/miniracers/mr_racemarker.mdl")
    self:SetSkin(1)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake() 
    end
end 

function ENT:OnRemove()
    if (CLIENT) then return end

    if IsValid(self.race) then
        self.race:Remove()
    end
end


function ENT:Think()
    if (CLIENT) then return end

    if not IsValid(self.race) then
        return
    end

    local racers = ents.FindInSphere(self:GetPos() + self:GetForward() * 35 , 30)
    for k, v in pairs(racers) do
        if IsValid(v) && string.match(v:GetClass(), "sent_miniracer") then
            if not self.race.passedCheckpoint[v:GetOwnerName()] then
                self:EmitSound("buttons/button17.wav")                
                self.race.passedCheckpoint[v:GetOwnerName()] = true
            end
        end
    end


    local currentAngles = self:GetAngles()
    self:SetAngles(Angle(0, currentAngles.y, 0))

    self:NextThink(CurTime())
	return true
end
