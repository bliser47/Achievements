Achievements.InitializeAchievements = function()

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
                singleEvents = {"PLAYER_ENTERING_WORLD"},
                events = {"PLAYER_LEVEL_UP"},
                objective = function()
                    return UnitLevel("player") > 9
                end
            }
        }
    });


    Achievements.addAchievement({
        category = ACHIEVEMENT_CATEGORY_GENERAL,
        name = "Level 20",
        description = "Reach level 20.",
        points = 10,
        texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_20",
        key = "level20",
        criterias = {
            {
                key = "level20c1",
                singleEvents = {"PLAYER_ENTERING_WORLD"},
                events = {"PLAYER_LEVEL_UP"},
                objective = function()
                    return UnitLevel("player") > 19
                end
            }
        }
    });

    Achievements.addAchievement({
        category = ACHIEVEMENT_CATEGORY_GENERAL,
        name = "Level 30",
        description = "Reach level 30.",
        points = 10,
        texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_30",
        key = "level30",
        criterias = {
            {
                key = "level30c1",
                singleEvents = {"PLAYER_ENTERING_WORLD"},
                events = {"PLAYER_LEVEL_UP"},
                objective = function()
                    return UnitLevel("player") > 29
                end
            }
        }
    });

    Achievements.addAchievement({
        category = ACHIEVEMENT_CATEGORY_GENERAL,
        name = "Level 40",
        description = "Reach level 40.",
        points = 10,
        texture = "Interface\\Addons\\Achievements\\icons\\achievement_level_40",
        key = "level40",
        criterias = {
            {
                key = "level40c1",
                singleEvents = {"PLAYER_ENTERING_WORLD"},
                events = {"PLAYER_LEVEL_UP"},
                objective = function()
                    return UnitLevel("player") > 39
                end
            }
        }
    });

end