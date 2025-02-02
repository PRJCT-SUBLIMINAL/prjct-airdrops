Config = {}

Config.Debug = false
Config.TargetDebug = false
Config.TestCommand = false

Config.NotifPosition = 'center-left'

Config.AirDropTimer = { min = 15, max = 30 } -- How long until the airdrop happens when within the polyzone (in minutes)

Config.FlightTime = { min = 12, max = 22 } -- How long the plane will fly for before crashing (in seconds)

-- Models
Config.LoadModels = {
    "ex_prop_adv_case_sm",
    "streamer216",
    "s_m_m_pilot_02"
}

Config.CrateModel = "ex_prop_adv_case_sm"
Config.PlaneModel = "streamer216"
Config.PilotModel = "s_m_m_pilot_02"

-- Stash Settings
Config.StashWeight = 50000
Config.StashSlots = 1

Config.CrateAmount = { min = 5, max = 8 }

-- Possible Rewards
Config.Rewards = {

    -- Jewellery

    { item = 'silver_ring',         amount = { min = 50 , max = 80 } },

    { item = 'gold_ring',           amount = { min = 50 , max = 80 } },

    { item = 'ruby_ring',           amount = { min = 50 , max = 80 } },

    { item = 'emerald_ring',        amount = { min = 50 , max = 80 } },

    { item = 'sapphire_ring',       amount = { min = 50 , max = 80 } },

    { item = 'diamond_ring',        amount = { min = 50 , max = 80 } },

    { item = 'silver_necklace',     amount = { min = 50 , max = 80 } },

    { item = 'gold_necklace',       amount = { min = 50 , max = 80 } },

    { item = 'ruby_necklace',       amount = { min = 50 , max = 80 } },

    { item = 'emerald_necklace',    amount = { min = 50 , max = 80 } },

    { item = 'sapphire_necklace',   amount = { min = 50 , max = 80 } },

    { item = 'diamond_necklace',    amount = { min = 50 , max = 80 } },
    
    { item = 'silver_earrings',     amount = { min = 50 , max = 80 } },

    { item = 'gold_earrings',       amount = { min = 50 , max = 80 } },

    { item = 'ruby_earrings',       amount = { min = 50 , max = 80 } },

    { item = 'emerald_earrings',    amount = { min = 50 , max = 80 } },

    { item = 'sapphire_earrings',   amount = { min = 50 , max = 80 } },

    { item = 'diamond_earrings',    amount = { min = 50 , max = 80 } },


    -- Rare items

    { item = 'money',               amount = { min = 10000, max = 50000 } },

    { item = 'black_money',         amount = { min = 50000, max = 100000 } },

    { item = 'warehouse_locator',   amount = { min = 1, max = 1 } },

    { item = 'usb_drive',           amount = { min = 1, max = 1 } },

    { item = 'ammonium_nitrate',    amount = { min = 1, max = 1 } },

    { item = 'armour',              amount = { min = 1, max = 3 } },

}
