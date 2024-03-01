fx_version "cerulean"
games { "gta5" }

author "gamenew09"
description "A multijob resource intended for use with QBox."
version "0.0.1"

ox_lib 'locale'

lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "@qbx_core/modules/lib.lua",
}

server_scripts {
    "server/main.lua"
}

client_scripts {
    "@qbx_core/modules/playerdata.lua",
    "client/main.lua"
}

files {
    "configs/shared.lua",
    "configs/client.lua",
    "client/**/*.lua",
    "client/*.lua",
    "shared/**/*.lua",
    "shared/*.lua",

    "locales/*.json"
}

dependency 'ox_lib'
dependency 'qbx_core'