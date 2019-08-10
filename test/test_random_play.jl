module RandomPlayTest

using  Test

import Cribbage
import Cribbage.RandomPlay: RandomPlayer
import Cribbage.TwoPlayer
import Cribbage.ThreePlayer
import Cribbage.FourPlayer

@testset "Random Players" begin
    p₁ = RandomPlayer("one")
    @test p₁.name == "one"
    p₂ = RandomPlayer("two")
    @test p₂.name == "two"
    @test p₁ ≠ p₂
end

@testset "Random Gameplay" begin

    # Logging.with_logger(logger) do
        p₁ = RandomPlayer("player one")
        p₂ = RandomPlayer("player two")
        game = Cribbage.TwoPlayer.TwoPlayerGame(p₁, p₂)
        gamestate = Cribbage.TwoPlayer.TwoPlayerGameState(
            game, rand([p₁, p₂])
        )
        gamestates = Cribbage.playgame(gamestate)

        p₃ = RandomPlayer("player three")
        game = Cribbage.ThreePlayer.ThreePlayerGame(p₁, p₂, p₃)
        gamestate = Cribbage.ThreePlayer.ThreePlayerGameState(
            game, rand([p₁, p₂, p₃])
        )
        gamestates = Cribbage.playgame(gamestate)

        p₄ = RandomPlayer("player four")
        game = Cribbage.FourPlayer.FourPlayerGame(p₁, p₂, p₃, p₄)
        gamestate = Cribbage.FourPlayer.FourPlayerGameState(
            game, rand([p₁, p₂, p₃, p₄])
        )
        gamestates = Cribbage.playgame(gamestate)
    # end

end

end  # module RandomPlayTest
