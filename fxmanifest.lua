fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Cayo Perico Airdrops'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}