"""
Module defining random play.

This module is the reference implementation for game decisions that should be
    overridden when improving strategy.
"""
module RandomPlay

import PlayingCards: Card

import Cribbage: Player
import Cribbage.Rules: validhands, validplays

export discardtocrib, pickcardtoplay

struct RandomPlayer <: Player
    name :: String
end

"""
    discardtocrib(player, cards)
Divides `cards` into `hand`, `crib`
"""
function discardtocrib(player::Player, cards::Tuple{Vararg{Card}})
    subsets = validhands(cards)
    hand = rand(subsets)
    crib = setdiff(cards, hand)
    @debug "keeping $(string(hand)), discarding $(string(crib))"
    return hand, crib
end

"""
    pickcardtoplay(player, prior, cards)
Returns either
- a card from `cards` to play
- `missing` if there are no cards can be played
"""
function pickcardtoplay(player::Player, prior::Tuple{Vararg{Card}}, cards::Tuple{Vararg{Card}})::Union{Missing,Card}
    possibleplays = validplays(prior, cards)
    if length(possibleplays) == 0
        return missing
    else
        return rand(possibleplays)
    end
end

end  # module RandomPlay
