--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local license = {}

local mattata = require('mattata')

function license:init(configuration)
    license.arguments = 'license'
    license.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('license').table
    license.help = '/license - View mattata\'s license.'
end

function license:on_message(message)
    local output = io.popen('cat LICENSE'):read('*all')
    if output == 'cat: LICENSE: No such file or directory' then
        return
    end
    return mattata.send_message(
        message.chat.id,
        string.format(
            '<pre>%s</pre>',
            output
        ),
        'html'
    )
end

return license