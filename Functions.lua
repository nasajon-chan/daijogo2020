Functions = {}

-- These functions are needed for Cards.lua

Functions.find = function( where ,what )
    for k,v in pairs(where) do
        if v == what then
        return k
        end
    end
end

Functions.shuffle = function(a)
	local c = #a
	for i = 1, c do
		local ndx0 = math.random( 1, c )
		a[ ndx0 ], a[ i ] = a[ i ], a[ ndx0 ]
	end
	return a
end

Functions.move = function( what , origin , destiny )
    destiny[#destiny+1] = what
    local j = Functions.find( origin , what)
    if j then
        while j <= #origin do
            origin[j] = origin[j+1]
            j = j+1
        end
    else print('J É NIL') -- debugger
    end
end

Functions.drawCards = function( player , n )
    for i = 1 , n do
        Functions.move( player.deck[#player.deck] , player.deck , player.hand )
    end
    print(player.name..' drew '..n..' cards.')
end

Functions.printZone = function( zone )
    local i = 1
    print("#","Name           ","Points") --name tem 15 caracteres
    while i <= #zone do
        print(i,zone[i].name,zone[i].points)
        i = i+1
    end
end

Functions.printCard = function( card )
    print('Name: '..card.name)
    print('Points: '..card.points)
    print('Cost: '..card.costText)
    print('Effect: '..card.effectText)
end

Functions.pick = function( where ) -- escolhe um elemento de uma tabela
    while true do
        Functions.printZone( where)
        print('Pick one:')
        local opt = tonumber(io.read())
        if opt ~= nil then
            if opt > 0 and opt <= #where then
                return where[opt]
            end
        end
    end
end

Functions.newPlayer = function()
    player = {
        name = '',
        points = 0,
        deck = {},
        hand = {},
        field = {},
        bin = {},
        erased = {},
        tokenBin = {}
    }
    return player
end

Functions.newToken = function( player )
    local token = {
        name = 'Token',
        originalPoints = 1,
        points = 1,
        activated = false,
        costText = '',
        effectText = '',
        cost = function( player )
            return true
        end,
        effect = function( card , player , opponent )
            return
        end
    }
    player.field[#player.field + 1] = token
    print(player.name..' created a 1 point unit token.')
end

Functions.resetCard = function( card )
    card.points = card.originalPoints
    card.activated = false
end

Functions.checkDeath = function( card , player )
    if card.points < 1 then
        if card.name == 'Token' then
            Functions.move( card , player.field , player.tokenBin)
        else
            Functions.resetCard( card )
            Functions.move( card , player.field , player.bin )
        end
        print(card.name..' was destroyed.')
    end
end

Functions.moveMany = function( n , origin , destiny )
    if #origin >= n then
        while n > 0 do
            print('Erase '..n..' card(s) from your bin:')
            Functions.move( Functions.pick( origin ) , origin , destiny )
            n = n - 1
            return true
        end
    end
end

Functions.updatePoints = function( player )
    player.points = 0 -- resets points so they wont accumulate
    for i = 1 , #player.field do
        player.points = player.points + player.field[i].points
    end
end

Functions.playCard = function( player , card )
    Functions.printCard( card )
    print('PLAY CARD?')
    print('0 - RETURN')
    print('1 - PLAY')
    local opt = tonumber(io.read())
    if not (opt == 1) then 
        return 
    else
        if card.cost( player ) == true then
            Functions.move( card , player.hand , player.field )
            Functions.updatePoints( player )
            print(player.name..' PLAYED '..card.name)
            return
        else
            print('YOU CANNOT PAY THE COST')
        end
    end
end

Functions.abstractToConcrete = function(card,b) -- cria uma instância concreta da carta abstrata
    for k,v in pairs(card) do
        b[k] = v
    end
    return b
end

return Functions
