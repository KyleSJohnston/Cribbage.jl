"""
Tests of Cribbage
"""
module CribbageTest

import Logging
import PlayingCards: Card
using  Test

import Cribbage: dotheshow, nextplayer, name, Player, UnexpectedPlayerException
import Cribbage.RandomPlay: RandomPlayer
import Cribbage.TwoPlayer: TwoPlayerGame, TwoPlayerGameState

logger = Logging.ConsoleLogger(stderr, Logging.Warn)
Logging.with_logger(logger) do

@testset "Test nextplayer" begin
    playerarray::Array{Player,1} = [
        RandomPlayer("One"), RandomPlayer("Two"), RandomPlayer("Three"),
        RandomPlayer("Four"), RandomPlayer("Five"),
    ]
    @test nextplayer(playerarray, playerarray[2]) ≡ playerarray[3]
    @test nextplayer(playerarray, playerarray[5]) ≡ playerarray[1]
    @test_throws UnexpectedPlayerException nextplayer(playerarray, RandomPlayer("Six"))
end

@testset "Test dotheplay" begin
    # TODO: add tests
end

@testset "Test dotheshow" begin

    examplegame = TwoPlayerGame(
        RandomPlayer("one"), RandomPlayer("two")
    )
    initialstate = TwoPlayerGameState(
        examplegame, examplegame.p₁, 0, 0
    )

    hands = Dict{Player,Array{Card,1}}(
        examplegame.p₁ => [ Card("4♣"), Card("8♦"), Card("7♥"), Card("A♣") ],
        examplegame.p₂ => [ Card("10♣"), Card("Q♦"), Card("5♥"), Card("9♠") ]
    )
    starter = Card("K♣")
    crib = [ Card("3♣"), Card("6♦"), Card("2♥"), Card("2♠") ]

    gamestates = dotheshow(initialstate, hands, starter, crib)

    @test length(gamestates) == 3
    for gs in gamestates
        @test gs.dealer ≡ initialstate.dealer
    end

    @test gamestates[1].s₁ == 0
    @test gamestates[1].s₂ == 6

    @test gamestates[2].s₁ == 4
    @test gamestates[2].s₂ == 6

    @test gamestates[3].s₁ == 10
    @test gamestates[3].s₂ == 6


    initialstate = TwoPlayerGameState(
        examplegame, examplegame.p₁, 109, 117
    )
    gamestates = dotheshow(initialstate, hands, starter, crib)

    @test length(gamestates) == 1
    @test gamestates[1].dealer ≡ initialstate.dealer
    @test gamestates[1].s₁ == 109
    @test gamestates[1].s₂ == 121
end

@testset "Test playhand" begin
    # TODO: add tests
end

@testset "Test playgame" begin
    # TODO: add tests
end

tests = [
    "test_scoring", "test_rules", "test_random_play", "test_smart_play",
    "test_two_player", "test_three_player", "test_four_player"
]
for t in tests
    include("$(t).jl")
end

end  # (logging) do

end
