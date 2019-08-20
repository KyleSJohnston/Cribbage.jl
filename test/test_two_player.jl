module TwoPlayerTest

using  Test

import Cribbage: CribbageGame, GameState, UnexpectedPlayerException
import Cribbage.RandomPlay: RandomPlayer
using  Cribbage.TwoPlayer

@testset "Test TwoPlayerGame Constructor" begin
    p₁ = RandomPlayer("player one")
    @test_throws AssertionError TwoPlayerGame(p₁, p₁)
    p₂ = RandomPlayer("player two")
    @test_throws AssertionError TwoPlayerGame(p₁, p₂, 42)
    @test isa(TwoPlayerGame(p₁, p₂), CribbageGame)
    @test isa(TwoPlayerGame(p₁, p₂, 61), CribbageGame)
    @test isa(TwoPlayerGame(p₁, p₂, 121), CribbageGame)

end

examplegame = TwoPlayerGame(
    RandomPlayer("1"),
    RandomPlayer("2"),
    121
)
badplayer = RandomPlayer("-1")

@testset "Test TwoPlayerGameState Constructor" begin
    @test_throws AssertionError TwoPlayerGameState(examplegame, badplayer)
    @test_throws AssertionError TwoPlayerGameState(examplegame, examplegame.p₁, -42)
    @test_throws AssertionError TwoPlayerGameState(examplegame, examplegame.p₁, 0, -53)
    @test isa(TwoPlayerGameState(examplegame, examplegame.p₁, 0, 0), GameState)
end


@testset "Test players" begin
    @test length(players(examplegame)) == 2
    for player in players(examplegame)
        @test player ≡ examplegame.p₁ || player ≡ examplegame.p₂
    end
end

@testset "Test incrementscore" begin
    initialstate = TwoPlayerGameState(
        examplegame, examplegame.p₁, 0, 0
    )
    @test_throws UnexpectedPlayerException incrementscore(initialstate, badplayer, 0)
    @test_throws AssertionError incrementscore(initialstate, examplegame.p₁, -5)

    @test incrementscore(initialstate, examplegame.p₁, 0) == initialstate

    newstate = incrementscore(initialstate, examplegame.p₁, 6)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 6
    @test newstate.s₂ == 0

    initialstate = TwoPlayerGameState(
        examplegame, examplegame.p₁, 100, 115
    )
    newstate = incrementscore(initialstate, examplegame.p₂, 8)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 100
    @test newstate.s₂ == 121

end

@testset "Test isgameover" begin

    gs = TwoPlayerGameState(examplegame, examplegame.p₁, 112, 118)
    @test !isgameover(gs)
    gs = TwoPlayerGameState(examplegame, examplegame.p₁, 121, 118)
    @test isgameover(gs)
    gs = TwoPlayerGameState(examplegame, examplegame.p₁, 100, 121)
    @test isgameover(gs)

end

@testset "Test reportscore" begin

    gs = TwoPlayerGameState(examplegame, examplegame.p₁, 121, 118)
    @test isa(reportscore(gs), String)

end

@testset "Test rotatedealer" begin
    initialstate = TwoPlayerGameState(examplegame, examplegame.p₁, 1, 2)
    newstate = rotatedealer(initialstate)
    @test newstate.dealer ≡ examplegame.p₂
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂
    newstate = rotatedealer(newstate)
    @test newstate == initialstate
end

end  # module TwoPlayerTest
