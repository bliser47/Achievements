-- [[ Achievement Shield ]] --

function AchievementShield_Desaturate (self)
    self.icon:SetTexCoord(.5, 1, 0, 1);
end

function AchievementShield_Saturate (self)
    self.icon:SetTexCoord(0, .5, 0, 1);
end

function AchievementShield_OnLoad (self)
    local name = self:GetName();
    self.icon = getglobal(name .. "Icon");
    self.points = getglobal(name .. "Points");

    self.Desaturate = AchievementShield_Desaturate;
    self.Saturate = AchievementShield_Saturate;
end