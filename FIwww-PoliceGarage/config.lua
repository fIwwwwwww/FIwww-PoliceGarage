


Config = {}


Config.Ped = {
    model = `s_m_y_cop_01`,
    coords = vec4(457.66, -974.87, 25.7, 150.23),  -- coords of ped
    scenario = 'WORLD_HUMAN_COP_IDLES',
    distance = 2.0, 
    icon = 'fa-solid fa-car',
    label = 'Open PD Garage' -- third eye text
}


Config.JobName = 'police'
Config.Ranks = {

    cadet = 0,-- add your own ranks corresponding with your qbx_jobs
}

Config.Spawn = {
    coords = vec4(436.77, -975.69, 25.7, 90.0), -- where the car spawns
    clearRadius = 3.5
}



-- Caar Categories, Ranks Reqs, Fuel, and pngs

Config.Categories = {
    patrol = {
        label = 'Patrol',
        vehicles = {
            { label = 'police1', model = 'police', requiredRank = 'officer', fuel = 100, image = 'police_interceptor.png' },
        }
    },
    special = {
        label = 'Special Forces',
        vehicles = {
            { label = 'yourcarname', model = 'carsmodel', requiredRank = 'rankreq', fuel = 100, image = 'yourpngname.png' },
        }
    },
    highcmd = {
        label = 'High Command',
        vehicles = {
            { label = 'yourcarname', model = 'carsmodel', requiredRank = 'rankreq', fuel = 100, image = 'yourpngname.png' },
        }
    },
    unmarked = {
        label = 'Unmarked',
        vehicles = {
            { label = 'yourcarname', model = 'carsmodel', requiredRank = 'rankreq', fuel = 100, image = 'yourpngname.png' },
        }
    },
    swat = {
        label = 'SWAT',
        vehicles = {
            { label = 'yourcarname', model = 'carsmodel', requiredRank = 'rankreq', fuel = 100, image = 'yourpngname.png' },
        }
    },
    other = {
        label = 'OTHER',
        vehicles = {
            { label = 'yourcarname', model = 'carsmodel', requiredRank = 'rankreq', fuel = 100, image = 'yourpngname.png' },
        }
    }
}

-- configure according to your server 

Config.Leaders = {
    { title = 'Chief of Police', name = 'B. Hennessy', image = 'chief.png' },
    { title = 'Police Commissioner', name = 'R. Patel', image = 'commissioner.png' },
    { title = 'Police Superintendent', name = 'A. Diaz', image = 'superintendent.png' },
    { title = 'Special Forces Commander', name = 'K. Smith', image = 'special_cmd.png' },
    { title = 'Police Commander', name = 'L. Chen', image = 'commander.png' },
    { title = 'IAA Director', name = 'S. Hart', image = 'iaa.png' }
}


-- Fuel Resource For Cars To Spawn At 100%
Config.FuelResourceName = 'lc-fuel' 

