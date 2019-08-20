module ScoringTest

import PlayingCards: Card
using  Test

import Cribbage
import Cribbage.Scoring

@testset "Scoring Hands" begin

    hand = parse(Array{Card,1}, "8♣ 7♥ 7♠ 6♦")
    starter = parse(Card, "2♠")

    @test Cribbage.Scoring.scorefifteen(hand, starter) == 8
    @test Cribbage.Scoring.scorepair(hand, starter) == 2
    @test Cribbage.Scoring.scorerun(hand, starter) == 6
    @test Cribbage.Scoring.scoreflush(hand, starter) == 0
    @test Cribbage.Scoring.scorenobs(hand, starter) == 0

    @test Cribbage.Scoring.scorehand(hand, starter) == 16

    # Perfect Hand
    hand = parse(Array{Card,1}, "5♣ 5♥ J♠ 5♦")
    starter = parse(Card, "5♠")

    @test Cribbage.Scoring.scorefifteen(hand, starter) == 16
    @test Cribbage.Scoring.scorepair(hand, starter) == 12
    @test Cribbage.Scoring.scorerun(hand, starter) == 0
    @test Cribbage.Scoring.scoreflush(hand, starter) == 0
    @test Cribbage.Scoring.scorenobs(hand, starter) == 1

    @test Cribbage.Scoring.scorehand(hand, starter) == 29
end

@testset "Scoring Play" begin

    # Scoring the play
    prior = parse(Array{Card,1}, "5♣")
    card = parse(Card, "10♠")
    @test Cribbage.Scoring.scoreplay(prior, card) == 2
    push!(prior, card)

    card = parse(Card, "10♦")
    @test Cribbage.Scoring.scoreplay(prior, card) == 2
    push!(prior, card)

    card = parse(Card, "6♠")
    @test Cribbage.Scoring.scoreplay(prior, card) == 2
    push!(prior, card)

    prior = parse(Array{Card,1}, "9♣ 6♦ 8♥")
    card = parse(Card, "7♣")
    @test Cribbage.Scoring.scoreplay(prior, card) == 4

    # Score the starter card
    @test Cribbage.Scoring.scoreheels(parse(Card, "J♠")) == 2
    @test Cribbage.Scoring.scoreheels(parse(Card, "A♠")) == 0

end;

end  # module ScoringTest
