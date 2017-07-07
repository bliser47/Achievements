-- [[ Achievement Icon ]] --

function AchievementIcon_Desaturate (self)
    self.bling:SetVertexColor(.6, .6, .6, 1);
    self.frame:SetVertexColor(.75, .75, .75, 1);
    self.texture:SetVertexColor(.55, .55, .55, 1);
end

function AchievementIcon_Saturate (self)
    self.bling:SetVertexColor(1, 1, 1, 1);
    self.frame:SetVertexColor(1, 1, 1, 1);
    self.texture:SetVertexColor(1, 1, 1, 1);
end

function AchievementIcon_OnLoad (self)
    local name = self:GetName();
    self.bling = getglobal(name .. "Bling");
    self.texture = getglobal(name .. "Texture");
    self.frame = getglobal(name .. "Overlay");

    self.Desaturate = AchievementIcon_Desaturate;
    self.Saturate = AchievementIcon_Saturate;
end