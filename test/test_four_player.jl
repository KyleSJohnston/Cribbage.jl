module FourPlayerTest

using  Test

import Cribbage: CribbageGame, GameState, UnexpectedPlayerException
import Cribbage.RandomPlay: RandomPlayer
using  Cribbage.FourPlayer

@testset "Test FourPlayerGame Constructor" begin
    p₁ = RandomPlayer("player one")
    @test_throws AssertionError FourPlayerGame(p₁, p₁, p₁, p₁)
    p₂ = RandomPlayer("player two")
    @test_throws AssertionError FourPlayerGame(p₁, p₂, p₁, p₂)
    p₃ = RandomPlayer("player three")
    @test_throws AssertionError FourPlayerGame(p₁, p₂, p₃, p₁)
    p₄ = RandomPlayer("player four")
    @test_throws AssertionError FourPlayerGame(p₁, p₂, p₃, p₄, 42)
    @test isa(FourPlayerGame(p₁, p₂, p₃, p₄), CribbageGame)
    @test isa(FourPlayerGame(p₁, p₂, p₃, p₄, 61), CribbageGame)
    @test isa(FourPlayerGame(p₁, p₂, p₃, p₄, 121), CribbageGame)

end

examplegame = FourPlayerGame(
    RandomPlayer("1"),
    RandomPlayer("2"),
    RandomPlayer("3"),
    RandomPlayer("4"),
    121
)
badplayer = RandomPlayer("-1")

@testset "Test FourPlayerGameState Constructor" begin
    @test_throws AssertionError FourPlayerGameState(examplegame, badplayer)
    @test_throws AssertionError FourPlayerGameState(examplegame, examplegame.p₁, -42)
    @test_throws AssertionError FourPlayerGameState(examplegame, examplegame.p₁, 0, -53)
    @test isa(FourPlayerGameState(examplegame, examplegame.p₁, 0, 0), GameState)
end


@testset "Test players" begin
    @test length(players(examplegame)) == 4
    for player in players(examplegame)
        @test(
            player ≡ examplegame.p₁ || player ≡ examplegame.p₂ ||
            player ≡ examplegame.p₃ || player ≡ examplegame.p₄
        )
    end
end

@testset "Test incrementscore" begin
    initialstate = FourPlayerGameState(
        examplegame, examplegame.p₁, 0, 0
    )
    @test_throws UnexpectedPlayerException incrementscore(initialstate, badplayer, 0)
    @test_throws AssertionError incrementscore(initialstate, examplegame.p₁, -5)

    for p in players(initialstate.game)
        @test incrementscore(initialstate, p, 0) == initialstate
    end

    newstate = incrementscore(initialstate, examplegame.p₁, 6)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 6
    @test newstate.s₂ == 0

    newstate = incrementscore(initialstate, examplegame.p₂, 7)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 0
    @test newstate.s₂ == 7

    newstate = incrementscore(initialstate, examplegame.p₃, 5)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 5
    @test newstate.s₂ == 0

    newstate = incrementscore(initialstate, examplegame.p₄, 8)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 0
    @test newstate.s₂ == 8

    initialstate = FourPlayerGameState(
        examplegame, examplegame.p₁, 100, 115
    )
    newstate = incrementscore(initialstate, examplegame.p₂, 8)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 100
    @test newstate.s₂ == 121

end

@testset "Test isgameover" begin

    gs = FourPlayerGameState(examplegame, examplegame.p₁, 112, 118)
    @test !isgameover(gs)
    gs = FourPlayerGameState(examplegame, examplegame.p₁, 121, 118)
    @test isgameover(gs)
    gs = FourPlayerGameState(examplegame, examplegame.p₁, 100, 121)
    @test isgameover(gs)

end

@testset "Test reportscore" begin

    gs = FourPlayerGameState(examplegame, examplegame.p₁, 121, 118)
    @test isa(reportscore(gs), String)

end

@testset "Test rotatedealer" begin
    initialstate = FourPlayerGameState(examplegame, examplegame.p₁, 1, 2)
    newstate = rotatedealer(initialstate)
    @test newstate.dealer ≡ examplegame.p₂
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂

    newstate = rotatedealer(newstate)
    @test newstate.dealer ≡ examplegame.p₃
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂

    newstate = rotatedealer(newstate)
    @test newstate.dealer ≡ examplegame.p₄
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂

    newstate = rotatedealer(newstate)
    @test newstate == initialstate
end

end  # module FourPlayerTest
