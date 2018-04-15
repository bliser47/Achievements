Achievements.addAchievement({
    category = ACHIEVEMENT_CATEGORY_GENERAL,
    name = "Level 10",
    description = "Reach level 10.",
    points = 10,
    texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_10",
    key = "level10",
    criterias = {
        {
            key = "level10c1",
            events = {"CHAT_MSG_TEXT_EMOTE"},
            objective = function(_, text, source)
                return string.find(text,"dance") and source == UnitName("player")
            end
        }
    }
});

Achievements.addAchievement({
    category = ACHIEVEMENT_CATEGORY_GENERAL,
    name = "Level 20",
    description = "Reach level 20.",
    points = 10,
    texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_20"
});

Achievements.addAchievement({
    category = ACHIEVEMENT_CATEGORY_GENERAL,
    name = "Level 30",
    description = "Reach level 30.",
    points = 10,
    texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_30"
});

Achievements.addAchievement({
    category = ACHIEVEMENT_CATEGORY_GENERAL,
    name = "Level 40",
    description = "Reach level 40.",
    points = 10,
    texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_40"
});