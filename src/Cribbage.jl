module Cribbage

export scorehand, discardtocrib

import IterTools
import Random: shuffle!
import UUIDs
using  PlayingCards

# Define Custom Exceptions
struct UnexpectedPlayerException <: Exception
    message :: String
end

# Define Custom Types
abstract type Player end
abstract type CribbageGame end
abstract type GameState end

function game(gamestate::GameState)
    return gamestate.game
end

function dealer(gamestate::GameState)::Player
    return gamestate.dealer
end

function name(player::Player)::String
    return player.name
end

function nextplayer(players::Array{Player,1}, player::Player)::Player
    i = findfirst(p -> p === player, players)
    if i == nothing
        throw(UnexpectedPlayerException("$(player) is not one of the players in this game"))
    end
    if i == length(players)
        return players[1]
    else
        return players[i+1]
    end
end

include("Rules.jl")
include("Scoring.jl")
include("TwoPlayer.jl")
include("ThreePlayer.jl")
include("FourPlayer.jl")
include("RandomPlay.jl")
include("SmartPlay.jl")
include("InteractivePlay.jl")


using  .Scoring
using  .Rules
import .TwoPlayer: incrementscore, numplayers, players, reportscore, cardsdealt, cardstocrib, isgameover, rotatedealer
using  .RandomPlay

macro returnifgameover(statesarray)
    return quote
        if isgameover($(esc(statesarray))[end])
            return $(esc(statesarray))
        end
    end
end

function dotheplay(gamestate::GameState, hands::Dict{Player,Array{Card,1}})
    gamestates = Array{typeof(gamestate),1}()
    # loop through the cards
    gameplayers = players(game(gamestate))
    gomap = Dict{Player,Bool}()

    player = dealer(gamestate)
    while any(length(h) > 0 for h in values(hands))
        for p in gameplayers
            gomap[p] = false
        end
        prior::Array{Card,1} = []
        priortotal = 0
        lastcard = nothing
        while !all(values(gomap))
            player = nextplayer(gameplayers, player)
            playerhand = hands[player]
            card = pickcardtoplay(player, tuple(prior...), tuple(playerhand...))
            if ismissing(card)
                gomap[player] = true
                continue
            end
            @assert card in playerhand
            @assert cardvalue(card) + priortotal ≤ 31
            lastcard = card
            gamestate = incrementscore(gamestate, player, scoreplay(prior, card))
            push!(gamestates, gamestate)
            push!(prior, card)
            if isgameover(gamestates[end])
                return gamestates
            end
            priortotal += cardvalue(card)
            hands[player] = setdiff(playerhand, [card])
        end
        total = sum(cardvalue(c) for c in prior)
        if total ≠ 31
            @debug "$(string(lastcard)): last card"
            gamestate = incrementscore(gamestate, player, 1)
            push!(gamestates, gamestate)
            if isgameover(gamestates[end])
                return gamestates
            end
        end
    end
    return gamestates
end

function dotheshow(gamestate::GameState, hands::Dict{Player,Array{Card,1}}, starter::Card, crib::Array{Card,1})
    gamestates = Array{typeof(gamestate),1}()
    # score each hand in order
    gameplayers = players(game(gamestate))
    player = dealer(gamestate)
    while true
        player = nextplayer(gameplayers, player)
        gamestate = incrementscore(gamestate, player, scorehand(hands[player], starter))
        push!(gamestates, gamestate)
        @returnifgameover gamestates
        if player == dealer(gamestate)
            gamestate = incrementscore(gamestate, player, scorehand(crib, starter))
            push!(gamestates, gamestate)
            @returnifgameover gamestates
            break
        end
    end
    return gamestates
end

function playhand(gamestate::GameState)
    gamestates = Array{typeof(gamestate),1}()

    @debug "Building a deck & shuffling"
    deck = createdeck()
    shuffle!(deck)
    crib::Array{Card,1} = []
    n = numplayers(game(gamestate))

    @debug "$(name(dealer(gamestate))) deals a hand"
    hands = deal!(
        deck, cardsdealt(game(gamestate)), numplayers(game(gamestate))
    )
    for i in 1:cardstocrib(game(gamestate))
        push!(crib, pop!(deck))
    end

    @debug "Forming the crib"
    playhands = Dict{Player,Array{Card,1}}()
    showhands = Dict{Player,Array{Card,1}}()
    gameplayers = players(game(gamestate))
    for (player, hand) in zip(gameplayers, hands)
        handcards, cribcards = discardtocrib(player, tuple(hand...))
        @assert handcards ⊊ hand
        @assert cribcards ⊊ hand
        for c in cribcards
            @assert c ∉ handcards
        end
        append!(crib, cribcards)
        playhands[player] = collect(handcards)
        showhands[player] = collect(handcards)
    end

    starter = pop!(deck)
    @debug "The starter card is $(string(starter))"
    gamestate = incrementscore(gamestate, dealer(gamestate), scoreheels(starter))
    push!(gamestates, gamestate)
    @returnifgameover gamestates

    # The play
    append!(gamestates, dotheplay(gamestates[end], playhands))
    @returnifgameover gamestates

    # The Show
    append!(gamestates, dotheshow(gamestates[end], showhands, starter, crib))
    @returnifgameover gamestates

    @debug "Updating the dealer to the next player"
    push!(gamestates, rotatedealer(gamestates[end]))
    return gamestates
end

function playgame(gamestate::T) where T <: GameState
    @info "Playing a game with $(name(dealer(gamestate))) as the current dealer"
    gamestates = Array{T,1}()
    push!(gamestates, gamestate)
    while !isgameover(gamestates[end])
        append!(gamestates, playhand(gamestates[end]))
    end
    @info reportscore(gamestates[end])
    @info "End of game!"
    return gamestates
end

end  # module Cribbage
