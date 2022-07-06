impactTypes = {
	check,
	init,
	save,
	ac,
	damage,
	attack
}

strain = {
	body = {
		[2] = {
			textres = "strainlevel_body_2",
            impact = {
                check = {
                    filters = { "strength", "dexterity" },
                    type = "disadvantage"
                },
				init = {
					type = "disadvantage"
				}
            },
		},
		[6] = {
			textres = "strainlevel_body_6",
            impact = {
                save = {
                    filters = { "strength", "dexterity" },
                    type = "disadvantage"
                },
			}
		}
	},
	mind = {
		[2] = {
			textres = "strainlevel_mind_2",
            impact = {
                check = {
                    filters = { "wisdom", "charisma" },
                    type = "disadvantage"
                }
            }
		},
		[6] = {
			textres = "strainlevel_mind_6",
            impact = {
                save = {
                    filters = { "wisdom", "charisma" },
                    type = "disadvantage"
                }
            }
		},
		[8] = {
			textres = "strainlevel_mind_8",
            impact = {
                ac = {
                    type = "modifier",
					value = -5
                }
            }
		},
	},
	soul = {
		[2] = {
			textres = "strainlevel_soul_2",
			impact = {
				check = {
					filters = { "tool" },
					type = "proficiency"
				},
				attack = {
					filters = { "weapon" },
					type = "proficiency"
				}
			}
		},
		[6] = {
			textres = "strainlevel_soul_6",
			impact = {
				save = {
					filteres = { "death" },
					type = "disadvantage"
				}
			}
		}
	}
}