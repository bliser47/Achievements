-- [[ AchievementCategoryButton ]] --

function AchievementCategoryButton_OnLoad (button)
    button:EnableMouse(true);
    button:EnableMouseWheel(true);

    local buttonName = button:GetName();

    button.label = getglobal(buttonName .. "Label");
    button.background = getglobal(buttonName.."Background");
end

function AchievementCategoryButton_OnClick (button)
    AchievementFrameCategories_SelectButton(button);
    AchievementFrameCategories_Update();
end