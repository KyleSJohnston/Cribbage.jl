"""
Module to define an interactive player. (Intended for testing purposes.)
"""
module InteractivePlay

import PlayingCards: Card, createdeck

import Cribbage: Player
import Cribbage.RandomPlay: discardtocrib, pickcardtoplay
import Cribbage.SmartPlay: averagescore, DECK
import Cribbage.Rules: cardvalue, validhands, validplays
import Cribbage.Scoring: scorehand, scoreplay

struct InteractivePlayer <: Player
    name :: String
end

function InteractivePlayer()
    return InteractivePlayer(UUIDs.uuid4())
end

function discardtocrib(player::InteractivePlayer, cards::Tuple{Vararg{Card}})
    println("You were dealt: $(string(cards))")
    subsets = validhands(cards)
    others = setdiff(DECK, cards)
    sort!(subsets, by=x -> averagescore(x, others), rev=true)
    for (i, h) in enumerate(subsets)
        if i ≥ 10
            break
        end
        println("[$i] $(string(h))")
    end
    println("Which hand would you like to keep?"); userinput = readline()
    handint = parse(Int, userinput)
    hand = subsets[handint]
    crib = setdiff(cards, hand)
    @debug "keeping $(string(hand)), discarding $(string(crib))"
    return hand, crib
end

function pickcardtoplay(player::InteractivePlayer, prior::Tuple{Vararg{Card}}, cards::Tuple{Vararg{Card}})::Union{Missing,Card}
    if length(prior) == 0
        println("No prior cards")
    else
        println("Prior cards $(sum(cardvalue(c) for c in prior)): $(string(prior))")
    end
    println("You have: $(string(cards))")
    possible_plays = validplays(prior, cards)
    if length(possible_plays) == 0
        println("You have no possible plays.")
        return missing
    end
    if length(prior) == 0
        priorarray = Card[]
    else
        priorarray = collect(prior)
    end
    sort!(possible_plays, by=x -> scoreplay(priorarray, x), rev=true)
    for (i, c) in enumerate(possible_plays)
        if i ≥ 10
            break
        end
        println("[$i] $(string(c))")
    end
    println("Which card would you like to play?"); userinput = readline()
    cardint = parse(Int, userinput)
    return possible_plays[cardint]
end

end  # module InteractivePlay
