fx_version 'cerulean' -- Required version
game 'gta5'

author 'iamDippi'
description 'Porch Pirate Heist - Drive around and steal packages from porches'
version '1.0.0'

-- What to load on the server side
server_scripts {
    'server/porch_pirate_server.lua', -- Server-side code
}

-- What to load on the client side
client_scripts {
    'client/porch_pirate_client.lua', -- Client-side code
}

-- Add the HTML and images
files {
    'html/images/stolen_package.png'
}

-- Dependencies (make sure these resources are available)
dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib',
    'qbx_core' -- This is required if you're using qb-core or qbx framework
}
