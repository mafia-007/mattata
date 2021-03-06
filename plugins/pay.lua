--[[
    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local pay = {}
local mattata = require('mattata')
local redis = require('mattata-redis')

function pay:init()
    pay.commands = mattata.commands(self.info.username)
    :command('pay')
    :command('bal')
    :command('balance').table
    pay.help = '/pay <amount> - Sends the replied-to user the given amount of mattacoins. Use /balance (or /bal) to view your current balance.'
end

function pay.set_balance(user_id, new_balance)
    redis:set(
        'balance:' .. user_id,
        new_balance
    )
end

function pay.get_balance(user_id)
    local balance = redis:get('balance:' .. user_id)
    if not balance
    then
        balance = 0
    end
    return balance
end

function pay:on_message(message, configuration, language)
    if not message.reply
    then
        if message.text:match('^[/!#]bal')
        then
            local balance = pay.get_balance(message.from.id)
            return mattata.send_reply(
                message,
                string.format(
                    language['pay']['1'],
                    balance
                )
            )
        end
        return mattata.send_reply(
            message,
            language['pay']['2']
        )
    end
    local input = mattata.input(message.text)
    if not input
    then
        return mattata.send_reply(
            message,
            string.format(
                language['pay']['3'],
                message.reply.from.first_name
            )
        )
    elseif tonumber(input) == nil
    or tonumber(input) < 0
    then
        return mattata.send_reply(
            message,
            language['pay']['4']
        )
    elseif message.reply.from.id == message.from.id
    then
        return mattata.send_reply(
            message,
            language['pay']['5']
        )
    end
    local current_user_balance = pay.get_balance(message.from.id)
    local current_recipient_balance = pay.get_balance(message.reply.from.id)
    local new_user_balance = tonumber(current_user_balance) - tonumber(input)
    local new_recipient_balance = tonumber(current_recipient_balance) + tonumber(input)
    if new_user_balance < 0
    then
        return mattata.send_reply(
            message,
            language['pay']['6']
        )
    end
    pay.set_balance(
        message.from.id,
        new_user_balance
    )
    pay.set_balance(
        message.reply.from.id,
        new_recipient_balance
    )
    return mattata.send_reply(
        message,
        string.format(
            language['pay']['7'],
            input,
            message.reply.from.first_name,
            new_user_balance
        )
    )
end

return pay