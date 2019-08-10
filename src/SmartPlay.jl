module SmartPlay

import PlayingCards: Card, createdeck

import Cribbage: Player
import Cribbage.RandomPlay: discardtocrib, pickcardtoplay
import Cribbage.Rules: validhands, validplays
import Cribbage.Scoring: scorehand, scoreplay

struct SmartPlayer <: Player
    name :: String
end

function SmartPlayer()
    return SmartPlayer(UUIDs.uuid4())
end

function averagescore(cards::Tuple{Vararg{Card}}, others::Array{Card,1})
    cards = collect(cards)
    scores = Int8[]
    for starter in others
        push!(scores, scorehand(cards, starter))
    end
    return sum(scores) / length(scores)
end

DECK = createdeck()

function discardtocrib(player::SmartPlayer, cards::Tuple{Vararg{Card}})
    subsets = validhands(cards)
    others = setdiff(DECK, cards)
    sort!(subsets, by=x -> averagescore(x, others), rev=true)
    hand = subsets[1]
    crib = setdiff(cards, hand)
    @debug "keeping $(string(hand)), discarding $(string(crib))"
    return hand, crib
end

function pickcardtoplay(player::SmartPlayer, prior::Tuple{Vararg{Card}}, cards::Tuple{Vararg{Card}})::Union{Missing,Card}
    possible_plays = validplays(prior, cards)
    if length(possible_plays) == 0
        return missing
    end
    if length(prior) == 0
        priorarray = Card[]
    else
        priorarray = collect(prior)
    end
    sort!(possible_plays, by=x -> scoreplay(priorarray, x), rev=true)
    return possible_plays[1]
end

end  # module SmartPlay
