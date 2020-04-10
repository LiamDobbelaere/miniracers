AddCSLuaFile()

ENT.PrintName = "AI Marker"
ENT.Author = "Digaly"
ENT.Information = "Use this to guide the AI"
ENT.Category = "Miniracers"

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Editable = false
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
    if (CLIENT) then 
        if  LocalPlayer():GetActiveWeapon():GetClass() != 'weapon_physgun'
            and LocalPlayer():GetActiveWeapon():GetClass() != 'gmod_tool'
        then
            notification.AddLegacy("Equip physics gun or tool gun!", NOTIFY_GENERIC, 4)
            surface.PlaySound( "buttons/button11.wav" )
        end

        return 
    end

    self:SetModel("models/props_junk/PopCan01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(255, 255, 0, 255))

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then 
        phys:Wake()
        phys:EnableGravity(false)
    end
end 

function ENT:Think()
    self:SetAngles(Angle(0, 0, 0))
end

function ENT:Draw()    
    if  LocalPlayer():GetActiveWeapon():GetClass() != 'weapon_physgun'
        and LocalPlayer():GetActiveWeapon():GetClass() != 'gmod_tool'
    then
        return
    end

    local groundTrace = util.QuickTrace(self:GetPos(), self:GetPos() - (self:GetPos() + Vector(0, 0, 1) * 1000), { self })

    self:DrawModel()

    if groundTrace.Hit then
        local oldPos = self:GetPos()
        self:SetModel('models/props_junk/TrafficCone001a.mdl')
        self:SetPos(groundTrace.HitPos)
        self:SetupBones()
        self:DrawModel()
        
        self:SetPos(oldPos) 
        self:SetupBones()
        self:SetModel("models/props_junk/PopCan01a.mdl")
    end
end

