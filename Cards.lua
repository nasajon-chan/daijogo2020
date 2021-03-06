Functions = require('Functions')
Cards = {}

--[[
    The card's cost and effect functions must always return true or false.
    The cost must return true for the card to be played.
    The effect must return true, otherwise the unit could be activated again in the same turn.
    If the effect returns false, the unit fails to activate.

    cardIdeal is the metatable from where all cards get the new and the move functions

]]

function newToken(player)
    player.field[#player.field + 1] = Cards.Token:new()
    print(player.name..' created a 1 point unit token.')
end

Cards.cardIdeal = {
    new = function(self)
        local instance = {
            activated = false,
            move = function( self , origin , destiny )
                Functions.move( self , origin , destiny )
            end,
            reset = function( self )
                self.points = self.originalPoints
                self.activated = false
            end,
            printCard = function( self )
                print('Name: '..self.name)
                print('Points: '..self.points)
                print('Cost: '..self.costText)
                print('Effect: '..self.effectText)
            end,
            checkDeath = function( self )
                if self.points < 1 then
                    if self.name == 'Token' then
                        self:move( self.owner.field , self.owner.tokenBin)
                    else
                        self:reset()
                        self:move( self.owner.field , self.owner.bin )
                    end
                    print(self.name..' was destroyed.')
                end
            end
        }
        for k , v in pairs(self) do
            instance[k] = v
        end
        return instance
    end
}

Cards.cardIdeal.__index = Cards.cardIdeal

Cards.blank = {
    name = '',
    originalPoints = 0,
    points = 0,
    costText = '',
    effectText = '',
    cost = function( player )
    end,
    effect = function( card , player , opponent )
    end
}

 Cards.Token = {
        name = 'Token',
        originalPoints = 1,
        points = 1,
        costText = '',
        effectText = '',
        cost = function( player )
            return true
        end,
        effect = function( card , player , opponent )
            return false
        end
    }

Cards.Clotz = {
    name = 'Clotz',
    originalPoints = 1,
    points = 1,
    
    costText = '',
    effectText = 'Move 1 card from the top of your deck to your bin.',
    cost = function( player )
        return true
    end,
    effect = function( card , player , opponent)
        if #player.deck > 0 then
            Functions.move( player.deck[#player.deck] , player.deck , player.bin )
            print('1 card was sent from the top of your deck to your bin.')
            return true
        else
            return false
        end
    end
}

Cards.Wuru = {
    name = 'Wuru',
    originalPoints = 1,
    points = 1,
    
    costText = '',
    effectText = 'Destroy this unit to give -1 point to an enemy unit.',
    cost = function( player )
        return true
    end,
    effect = function( card , player , opponent )
        card:move( player.field , player.bin )
        if #opponent.field > 0 then
            local target = Functions.pick( opponent.field )
            target.points = target.points - 1
            print(card.name..' was destroyed and '..target.name..' lost 1 point.')
            target:checkDeath()
        end
        return true
    end
}

Cards.Prezu = {
    name = 'Prezu',
    originalPoints = 1,
    points = 1,
     
    costText = '',
    effectText = 'Discard a card to draw a card.',
    cost = function( player )
        return true
    end,
    effect = function( card , player , opponent )
        if #player.hand > 0 then
            print('Discard a card from your hand:')
            local discarded = Functions.pick( player.hand )
            discarded:move( player.hand , player.bin )
            player:drawCards( 1 )
            print('You discarded a card and drew another card.')
            return true
        else
            return false
        end
    end
}

Cards.Preru = {
    name = 'Preru',
    originalPoints = 1,
    points = 1,
    
    costText = '',
    effectText = 'Erase 1 card from your bin to create a 1 point unit token.',
    cost = function( player )
        return true
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 1 , player.bin , player.erased ) == true then
            newToken( player )
            return true
        else
            return false
        end
    end
}

Cards.Pretu = {
    name = 'Pretu',
    originalPoints = 1,
    points = 1,
    
    costText = '',
    effectText = 'Give +1 point to another unit you control.',
    cost = function( player )
        return true
    end,
    effect = function( card , player , opponent )
        if #player.field > 1 then
            while true do
                local target = Functions.pick( player.field )
                if target ~= card then
                    target.points = target.points + 1
                    print(target.name..' gained 1 point.')
                    return true
                end
            end
        else
            return false
        end
    end
}

Cards.Bonky = {
    name = 'Bonky',
    originalPoints = 1,
    points = 1,
    
    costText = 'Erase 1 card from your bin.',
    effectText = 'Destroy this unit to draw 2 cards.',
    cost = function( player )
        return Functions.moveMany( 1 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        card:move( player.field , player.bin )
        player:drawCards( 2 )
        print(card.name..' was destroyed and you drew 2 cards.')
        return true
    end
}

Cards.Wuruku = {
    name = 'Wuruku',
    originalPoints = 1,
    points = 1,
    
    costText = 'Erase 1 card from your bin.',
    effectText = 'Destroy this unit to give -2 points to an enemy unit.',
    cost = function( player )
        return Functions.moveMany( 1 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        card:move( player.field , player.bin )
        if #opponent.field > 0 then
            local target = Functions.pick( opponent.field )
            target.points = target.points - 2
            print(card.name..' was destroyed and '..target.name..' lost 2 points.')
            target:checkDeath()
        end
        return true
    end
}

Cards.Duo = {
    name = 'Duo',
    originalPoints = 2, 
    points = 2,
    
    costText = 'Erase 2 cards from your bin.',
    effectText = 'Erase 2 cards from your bin to draw cards until you have 2 in your hand.',
    cost = function( player )
        return Functions.moveMany( 2 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 2 , player.bin , player.erased ) == true then
            while #player.hand < 2 do -- compra até ter 2 na mão
                player:drawCards( 1 )
            end
            return true
        else
            return false
        end
    end
}

Cards.Raskus = {
    name = 'Raskus',
    originalPoints = 2, 
    points = 2,
    
    costText = 'Erase 2 cards from your bin.',
    effectText = 'Choose: Discard 2 cards then draw 2 cards; Or erase 2 cards from your hand to add 1 card from your bin to your hand.',
    cost = function( player )
        return Functions.moveMany( 2 , player.bin , player.erased ) 
    end,
    effect = function( card , player , opponent )
        if #player.hand >= 2 then
            print('Choose:')
            print('1 - Discard 2 cards then draw 2 cards;')
            print('2 - Erase 2 cards from your hand to add 1 card from your bin to your hand.')
            local opt = tonumber(io.read())
            if not (opt==1 or opt==2) then
                return false
            elseif opt == 1 then
                print('Discard 2 cards from your hand:')
                Functions.moveMany( 2 , player.hand , player.bin )
                player:drawCards( 2 )
                return true
            else
                print('Erase 2 cards from your hand:')
                Functions.moveMany( 2 , player.hand , player.erased )
                print('Add 1 card from your bin to your hand.')
                Functions.pick( player.bin ):move( player.bin , player.hand )
                return true
            end
        end
    end
}

Cards.Sobmos = {
    name = 'Sobmos',
    originalPoints = 1, 
    points = 1,
    
    costText = 'Erase 3 cards from your bin.',
    effectText = 'Choose: Erase 2 cards from your bin to create two 1 point unit tokens; Or destroy any number of tokens you control to gain control over an enemy unit with points equal to the number of destroyed tokens.',
    cost = function( player )
        return Functions.moveMany( 3 , player.bin , player.erased ) 
    end,
    effect = function( card , player , opponent )
        print('Choose:')
        print('1 - Erase 2 cards from your bin to create two 1 point unit tokens')
        print('2 - Destroy any number of tokens you control to gain control over an enemy unit with points equal to or fewer than the number of destroyed tokens.')
        local opt = tonumber(io.read())
        if not (opt==1 or opt==2) then
            return false
        elseif opt == 1 then
            print('Erase 2 cards from your bin:')
            if Functions.moveMany( 2 , player.bin , player.erased ) == true then
                newToken( player )
                newToken( player )
                return true
            else
                return false
            end
        else
            print('Destroy any number of tokens you control:')
            local n = Functions.countTokens( player )
            if n <= 0 then
                print('You control no unit tokens.')
                return false
            else
                Functions.printZone( player.field )
                print('You control '..n..' tokens. How many do you wish to destroy?')
                local opt = tonumber(io.read())
                if opt > 0 and opt <= n then
                    local i = n
                    while i > 0 do
                        local sacrifice = Functions.pick( player.field )
                        if sacrifice.name == 'Token' then
                            sacrifice:move( player.field , player.tokenBin )
                            i = i - 1
                        else
                            print('THAT IS NOT A TOKEN')
                        end
                    end
                    print(n..' unit tokens were destroyed.')
                    local numTargets = 0
                    for i = 1 , #opponent.field do
                        if opponent.field[i].points <= n then
                            numTargets = numTargets + 1
                        end
                    end
                    if numTargets > 0 then
                        while true do
                            print('Gain control over an enemy unit with '..n..' points:')
                            local target = Functions.pick( opponent.field )
                            if target.points <= n then
                                target:move( opponent.field , player.field )
                                print('You gained control over '..target.name..'!')
                                return true
                            else
                                print('THAT UNIT DOES NOT HAVE '..n..' OR FEWER POINTS.')
                            end
                        end
                    else
                        print('There are no valid targets.')
                    end
                else
                end
            end
        end
    end
}

Cards.Sarka = {
    name = 'Sarka',
    originalPoints = 2, 
    points = 2,
    
    costText = 'Erase 2 cards from your bin',
    effectText = 'Erase 2 cards from your bin to give -1 to an enemy unit and +1 to this unit.',
    cost = function( player )
        return Functions.moveMany( 2 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 2 , player.bin , player.erased ) == true then
            if #opponent.field > 0 then
                local target = Functions.pick( opponent.field )
                target.points = target.points - 1
                print(target.name..' got -1 point.')
                target:checkDeath()
            end
            card.points = card.points + 1
            print(card.name..' got +1 point.')
            return true
        end
    end
}

Cards.Tzitunk= {
    name = 'Tzitunk',
    originalPoints = 3, 
    points = 3,
    
    costText = 'Erase 3 cards from your bin.',
    effectText = 'Discard any number of cards, then for each card discarded give -1 point to an enemy unit.',
    cost = function( player )
        return Functions.moveMany( 3 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        local d = 0
        while #player.hand > 0 do
            print('Discard any number of cards:')
            Functions.pick( player.hand ):move( player.hand , player.bin )
            d = d + 1
            print('You have discarded '..d..' card(s). Done?')
            print('1 - Yes')
            print('2 - Discard another card')
            local opt = tonumber(io.read())
            if not (opt == 1 or opt == 2) then
                print('SELECT YES OR DISCARD ANOTHER CARD')
            elseif opt == 1 or #player.hand == 0 then
                while d > 0 do
                    if #opponent.field > 0 then
                        print('Give -1 to an enemy unit. Do this '..d..' more time(s).')
                        local target = Functions.pick( opponent.field )
                        target.points = target.points - 1
                        print(target.name..' got -1 point.')
                        target:checkDeath()
                        d = d - 1
                    else
                        print('There are no enemy units.')
                    end
                end
                return true
            end
        end
    end
}

Cards.Zu = {
    name = 'Zu',
    originalPoints = 4,
    points = 4,
    
    costText = 'Erase 4 cards from your bin.',
    effectText = 'Erase 4 cards from your bin to draw cards until you have 4 in your hand.',
    cost = function( player )
        return Functions.moveMany( 4 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 4 , player.bin , player.erased ) == true then
            while #player.hand < 4 do 
                player:drawCards( 1 )
            end
            return true
        else
            return false
        end
    end
}

Cards.Tu = {
    name = 'Tu',
    originalPoints = 4,
    points = 4,
    
    costText = 'Erase 4 cards from your bin.',
    effectText = 'Erase 4 cards from your bin to distribute +4 points among units you control.',
    cost = function( player )
        return Functions.moveMany( 4 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 4 , player.bin , player.erased ) == true then
            local p = 4
            while p > 0 do
                local target = Functions.pick( player.field )
                target.points = target.points + 1
            end
            return true
        else
            return false
        end
    end
}

Cards.Ru = {
    name = 'Ru',
    originalPoints = 4,
    points = 4,
    
    costText = 'Erase 4 cards from your bin.',
    effectText = 'Erase 4 cards from your bin to create four 1 point unit tokens.',
    cost = function( player )
        return Functions.moveMany( 4 , player.bin , player.erased )
    end,
    effect = function( card , player , opponent )
        if Functions.moveMany( 4 , player.bin , player.erased ) == true then
            for i = 1 , 4 do
                newToken( player )
            end
            return true
        else
            return false
        end
    end
}

Cards.Boom = {
    name = 'Boom',
    originalPoints = 1,
    points = 1,
    
    costText = 'Destroy a unit you control.',
    effectText = 'Destroy this unit to destroy an enemy unit.',
    cost = function( player )
            return Functions.moveMany( 1 , player.field , player.bin )
    end,
    effect = function( card , player , opponent )
        return Functions.moveMany( 1 , opponent.field , opponent.bin )
    end
}

Cards.Treeph = {
    name = 'Treeph',
    originalPoints = 1,
    points = 1,
    
    costText = 'Destroy a unit you control.',
    effectText = "Discard a card to give -X to an enemy unit; X is equal to the card's points",
    cost = function( player )
        return Functions.moveMany( 1 , player.field , player.bin )
    end,
    effect = function( card , player , opponent )
        local discarded = Functions.moveMany( 1 , player.hand , player.bin )
        local target = Functions.pick( opponent.field )
        target.points = target.points - discarded.points
        print(target.name..' got -'..discarded.points..' points.')
        target:checkDeath()
    end
}

Cards.Brum = {
    name = 'Brum',
    originalPoints = 4,
    points = 4,
    
    costText = 'Destroy 2 units you control.',
    effectText = "Choose: ",
    cost = function( player )
        return Functions.moveMany( 2 , player.field , player.bin )
    end,
    effect = function( card , player , opponent )
        
    end
}



return Cards
