module ThreePlayerTest

using  Test

import Cribbage: CribbageGame, GameState, UnexpectedPlayerException
import Cribbage.RandomPlay: RandomPlayer
using  Cribbage.ThreePlayer

@testset "Test ThreePlayerGame Constructor" begin
    p₁ = RandomPlayer("player one")
    @test_throws AssertionError ThreePlayerGame(p₁, p₁, p₁)
    p₂ = RandomPlayer("player two")
    @test_throws AssertionError ThreePlayerGame(p₁, p₂, p₁)
    p₃ = RandomPlayer("player three")
    @test_throws AssertionError ThreePlayerGame(p₁, p₂, p₃, 42)
    @test isa(ThreePlayerGame(p₁, p₂, p₃), CribbageGame)
    @test isa(ThreePlayerGame(p₁, p₂, p₃, 61), CribbageGame)
    @test isa(ThreePlayerGame(p₁, p₂, p₃, 121), CribbageGame)

end

examplegame = ThreePlayerGame(
    RandomPlayer("1"),
    RandomPlayer("2"),
    RandomPlayer("3"),
    121
)
badplayer = RandomPlayer("-1")

@testset "Test ThreePlayerGameState Constructor" begin
    @test_throws AssertionError ThreePlayerGameState(examplegame, badplayer)
    @test_throws AssertionError ThreePlayerGameState(examplegame, examplegame.p₁, -42)
    @test_throws AssertionError ThreePlayerGameState(examplegame, examplegame.p₁, 0, -53)
    @test isa(ThreePlayerGameState(examplegame, examplegame.p₁, 0, 0), GameState)
end


@testset "Test players" begin
    @test length(players(examplegame)) == 3
    for player in players(examplegame)
        @test player ≡ examplegame.p₁ || player ≡ examplegame.p₂ || player ≡ examplegame.p₃
    end
end

@testset "Test incrementscore" begin
    initialstate = ThreePlayerGameState(
        examplegame, examplegame.p₁, 0, 0, 0
    )
    @test_throws UnexpectedPlayerException incrementscore(initialstate, badplayer, 0)
    @test_throws AssertionError incrementscore(initialstate, examplegame.p₁, -5)

    @test incrementscore(initialstate, examplegame.p₁, 0) == initialstate

    newstate = incrementscore(initialstate, examplegame.p₁, 6)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 6
    @test newstate.s₂ == 0
    @test newstate.s₃ == 0

    initialstate = ThreePlayerGameState(
        examplegame, examplegame.p₁, 100, 115, 98
    )
    newstate = incrementscore(initialstate, examplegame.p₂, 8)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 100
    @test newstate.s₂ == 121
    @test newstate.s₃ == 98

    newstate = incrementscore(initialstate, examplegame.p₃, 25)
    @test newstate.dealer ≡ initialstate.dealer
    @test newstate.s₁ == 100
    @test newstate.s₂ == 115
    @test newstate.s₃ == 121


end

@testset "Test isgameover" begin

    @test !isgameover(ThreePlayerGameState(examplegame, examplegame.p₁, 112, 118, 102))
    @test isgameover(ThreePlayerGameState(examplegame, examplegame.p₁, 121, 118, 95))
    @test isgameover(ThreePlayerGameState(examplegame, examplegame.p₁, 100, 121, 118))
    @test isgameover(ThreePlayerGameState(examplegame, examplegame.p₁, 57, 118, 121))

end

@testset "Test reportscore" begin

    gs = ThreePlayerGameState(examplegame, examplegame.p₁, 121, 118, 115)
    @test isa(reportscore(gs), String)

end

@testset "Test rotatedealer" begin
    initialstate = ThreePlayerGameState(examplegame, examplegame.p₁, 1, 2, 3)
    newstate = rotatedealer(initialstate)
    @test newstate.dealer ≡ examplegame.p₂
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂
    @test newstate.s₃ == initialstate.s₃

    newstate = rotatedealer(newstate)
    @test newstate.dealer ≡ examplegame.p₃
    @test newstate.s₁ == initialstate.s₁
    @test newstate.s₂ == initialstate.s₂
    @test newstate.s₃ == initialstate.s₃

    newstate = rotatedealer(newstate)
    @test newstate == initialstate
end


end  # module ThreePlayerTest
