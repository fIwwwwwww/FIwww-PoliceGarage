fx_version 'cerulean'
game 'gta5'

name 'fIwww_pdgarage'
author 'fIwww'
description 'pd garage system'
version '1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/img/vehicles/*.png',
    'html/img/leaders/*.png'
}

dependencies {
    'qbx_core',
    'ox_target'
}

lua54 'yes'
