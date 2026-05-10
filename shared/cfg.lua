dnj = {}

dnj.snpc = { -- start npc
    model = 'g_m_y_armgoon_02', 
    coords = vector4(890.6212, -2221.4646, 29.5096, 354.4688),
    scenario = 'WORLD_HUMAN_SMOKING'
}

dnj.rq = 'dnj_illegalscuba' -- required item
dnj.scuba = 250 
dnj.cldown = 20 * 60 

dnj.props = {
    'm23_1_prop_m31_roostercrate_02a',
  --  'bzzz_scrap_plate_b',
   -- 'bzzz_scrap_samwheel_b',
  --  'bzzz_scrap_something_b',
   -- 'bzzz_scrap_spring_b'
}

dnj.msn = {
    [1] = {
        boatnpc = {
            model = 's_m_y_dockwork_01',
            coords = vector4(-2109.1663, -547.1514, 1.7351, 228.7074)
        },
        boatst = { -- boat spawn
            price = 500,
            model = 'seashark',
            spawn = vector4(-2119.1716, -568.6818, 0.8481, 118.7409)
        },
        lootlocs = {
            vector3(-2287.2473, -641.6087, -10.7334),
            vector3(-2315.7400, -655.5555, -15.3041),
            vector3(-2286.9214, -657.0595, -9.4578),
            vector3(-2274.8157, -667.1661, -11.8379),
        },
        rwr = {
            items = {
                --[['dnj_ductape',
                'dnj_gunpowder',
                'dnj_chestplate',
                'dnj_kevlarfiber',
                'dnj_pistolbarrel2',
                'dnj_pistolbody',
                'dnj_pistolmagazine',
                'dnj_pistolpercurssor',
                'dnj_riflebarrel2',
                'dnj_riflebody',
                'dnj_riflemagazine',
                'dnj_riflestock',
                'dnj_rope',
                'dnj_smgbarrel',
                'dnj_smgbody',
                'dnj_spring',
                'dnj_steel',
                'dnj_velcro']]
            },
            min = 1,
            max = 3
        }
    },

    [2] = {
        boatnpc = {
            model = 's_m_y_dockwork_01',
            coords = vector4(3859.5496, 4459.0386, 0.8349, 91.9256)
        },
        boatst = {
            price = 500,
            model = 'seashark',
            spawn = vector4(3861.1079, 4452.8687, -0.4753, 271.6729)
        },
        lootlocs = {
            vector3(3963.7510, 4501.7437, -13.7086),
            vector3(3895.8984, 4567.9907, -10.7643),
            vector3(3877.5334, 4547.8945, -10.8255),
            vector3(3917.1401, 4567.1943, -8.6994),
        },
        rwr = {
            items = {
                --[[]'dnj_ductape',
                'dnj_gunpowder',
                'dnj_chestplate',
                'dnj_kevlarfiber',
                'dnj_pistolbarrel2',
                'dnj_pistolbody',
                'dnj_pistolmagazine',
                'dnj_pistolpercurssor',
                'dnj_riflebarrel2',
                'dnj_riflebody',
                'dnj_riflemagazine',
                'dnj_riflestock',
                'dnj_rope',
                'dnj_smgbarrel',
                'dnj_smgbody',
                'dnj_spring',
                'dnj_steel',
                'dnj_velcro']]
            },
            min = 1,
            max = 3
        }
    },
}

dnj.scubamask = {
    male = {
        drawable = 36, -- 36
        texture = 0
    },
    female = {
        drawable = 36, -- 36
        texture = 0
    }
}