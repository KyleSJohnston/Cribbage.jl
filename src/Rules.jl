module Rules

import IterTools
import PlayingCards: Card, rankint

export cardvalue, validplays

function cardvalue(rankint::Integer)::Integer
    return min(rankint, 10)
end

function cardvalue(card::Card)::Integer
    return cardvalue(rankint(card))
end

function validhands(cards::Tuple{Vararg{Card}})
    return [ s for s in IterTools.subsets(cards, 4) ]
end

function validplays(prior::Tuple{Vararg{Card}}, cards::Tuple{Vararg{Card}})::Array{Card,1}
    if length(prior) == 0
        priortotal = 0
    else
        priortotal = sum(cardvalue(c) for c in prior)
    end
    return [ c for c in cards if cardvalue(c) ≤ (31-priortotal) ]
end

end  # module Rules
