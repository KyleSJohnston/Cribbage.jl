"""
Module specifying the scoring rules in cribbage
"""
module Scoring

import IterTools
using  PlayingCards

import Cribbage.Rules: cardvalue

export scorehand, scoreheels, scoreplay

"""
    scorefifteen(hand, starter)
Computes the score for 15s in `hand` + `starter`
"""
function scorefifteen(hand::Array{Card,1}, starter::Card)::Integer
    total = 0
    cards = [ hand..., starter ]
    for subset in IterTools.subsets(cards)
        if length(subset) == 0
            continue
        end
        subsetvalue = sum(cardvalue(c) for c in subset)
        if subsetvalue == 15
            subsetstring = join([string(c) for c in subset], ", ")
            @debug "$(string(subset)): fifteen"
            total += 2
        end
    end
    return total
end

"""
    scorepair(hand, starter)
Computes the score for pairs in `hand` + `starter`
"""
function scorepair(hand::Array{Card,1}, starter::Card)::Integer
    total = 0
    cards = [ hand..., starter ]
    for (c1, c2) in IterTools.subsets(cards, 2)
        if rankint(c1) == rankint(c2)
            @debug "$(string(c1)), $(string(c2)): pair"
            total += 2
        end
    end
    return total
end

"""
    isrun(cards)
Returns true if `cards` represents a run of three or more
"""
function isrun(cards::Array{Card,1})::Bool
    @assert(length(cards) ≥ 3, "a run requires three or more cards")
    ranks = [ rankint(c) for c in cards ]
    sort!(ranks)
    for (r1, r2) in zip(ranks[1:end-1], ranks[2:end])
        if r1+1 ≠ r2
            return false
        end
    end
    return true
end

"""
    newrun(existing, new)
Returns true if the run represented by `new` is not a subset of a run in `existing`
"""
function newrun(existing, new)
    for run in existing
        if new ⊆ run
            return false
        end
    end
    return true
end

"""
    scorerun(hand, starter)
Computes the score for runs in `hand` + `starter`
"""
function scorerun(hand::Array{Card,1}, starter::Card)::Integer
    total = 0
    runs = []
    cards = [ hand..., starter ]
    for k in length(cards):-1:3
        # Start with the largest possible run so that subsets are excluded
        for subset in IterTools.subsets(cards, k)
            if isrun(subset) && newrun(runs, subset)
                @debug "$(string(subset)): run of $(string(k))"
                push!(runs, subset)
            end
        end
    end
    if length(runs) == 0
        return 0
    else
        return sum([length(run) for run in runs])
    end
end

"""
    scoreflush(hand, starter)
Computes the score for a flush in `hand` + `starter`
"""
function scoreflush(hand::Array{Card,1}, starter::Card)::Integer
    expectedsuit = suitint(hand[1])
    for i in 2:length(hand)
        if suitint(hand[i]) ≠ expectedsuit
            return 0
        end
    end
    if suitint(starter) == expectedsuit
        return 5
    else
        return 4
    end
end

"""
    scorenobs(hand, starter)
Computes the score for having a Jack of the same suit as `starter`
"""
function scorenobs(hand::Array{Card,1}, starter::Card)::Integer
    expectedcard = Card(suit(starter), "J")
    if expectedcard ∈ hand
        @debug "$(string(expectedcard)): nobs"
        return 1
    else
        return 0
    end
end

"""
    scorehand(hand, starter)
Computes the total score for having `hand` + `starter`
"""
function scorehand(hand::Array{Card,1}, starter::Card)
    @assert(length(hand) == 4, "cribbage hands must include exactly 4 cards")
    return (
        scorefifteen(hand, starter) +
        scorepair(hand, starter) +
        scorerun(hand, starter) +
        scoreflush(hand, starter) +
        scorenobs(hand, starter)
    )
end

"""
    scoreheels(starter)
Computes the score for having the `starter` be a Jack
"""
function scoreheels(starter::Card)
    if rank(starter) == "J"
        @debug "$(string(starter)): heels"
        return 2
    else
        return 0
    end
end

"""
    scoreplay(prior, card)
Computes the score earned by playing `card` after `prior` during the play
"""
function scoreplay(prior::Array{Card,1}, card::Card)
    if length(prior) == 0
        return 0
    end
    score = 0
    priortotal = sum(cardvalue(c) for c in prior)
    newtotal = priortotal + cardvalue(card)
    # score for total value
    if newtotal == 15
        @debug "$(priortotal) + $(string(card)): fifteen"
        score += 2
    elseif newtotal == 31
        @debug "$(priortotal) + $(string(card)): thirtyone"
        score += 2
    end

    # score for pairs
    cardrank = rankint(card)
    if rankint(prior[end]) == cardrank
        if length(prior) ≥ 2 && rankint(prior[end-1]) == cardrank
            if length(prior) ≥ 3 && rankint(prior[end-2]) == cardrank
                @debug "$(string(prior[end-2])), $(string(prior[end-1])), $(string(prior[end])), $(string(card)): double pair"
                score += 12
            else
                @debug "$(string(prior[end-1])), $(string(prior[end])), $(string(card)): triplet"
                score += 6
            end
        else
            @debug "$(string(prior[end])), $(string(card)): pair"
            score += 2
        end
    end

    # score for runs
    combined = [ prior..., card ]
    if length(combined) ≥ 5 && isrun(combined[end-4:end])
        @debug "$(string(combined)): run of 5"
        score += 5
    elseif length(combined) ≥ 4 && isrun(combined[end-3:end])
        @debug "$(string(combined)): run of 4"
        score += 4
    elseif length(combined) ≥ 3 && isrun(combined[end-2:end])
        @debug "$(string(combined)): run of 3"
        score += 3
    end

    return score
end

end  # module Scoring
