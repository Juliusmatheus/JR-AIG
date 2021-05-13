### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ bdbff2b2-b3e8-11eb-300a-f7b7f7c312ea
function argmax(seq::T, fn::Function) where {T <: Vector}
    local best_element = seq[1];
    local best_score = fn(best_element);
    for element in seq
        element_score = fn(element);
        if (element_score > best_score)
            best_element = element;
            best_score = element_score;
        end
    end
return best_element;
end


# ╔═╡ 3254adac-5b3a-4262-91de-9717c8e4ea80
function if_(boolean_expression::Bool, answer5::Any, answer6::Any)
    if (boolean_expression)
        return answer5;
    else
        return answer6;
    end
end



# ╔═╡ deec1ed4-a1ff-4d8e-805b-d964bd143120
abstract type AbstractGame end;

# ╔═╡ df86f3cd-c9e1-447c-a2a7-ffc05018590b
struct Game <: AbstractGame
    initial::String
    nodes::Dict
    utilities::Dict
function Game()
        return new("R", Dict([
            Pair("R", Dict("R5"=>"S",  "R6"=>"T",  "R7"=>"U")),
            Pair("S", Dict("S5"=>"S5", "S6"=>"S6", "S7"=>"S3")),
            Pair("T", Dict("T5"=>"T5", "T6"=>"T6", "T7"=>"T3")),
            Pair("U", Dict("U5"=>"U5", "U6"=>"U6", "U7"=>"U3")),
            ]), Dict([
                Pair("S5", 4),Pair("S6", 13),Pair("S7", 9),
                Pair("T5", 3),Pair("T6", 5),Pair("T7", 7),
                Pair("U5", 15),Pair("U6", 6),Pair("U7", 3),
                ]));
    end
end


# ╔═╡ 8c6ddc10-58f4-4d07-9048-135e56e8fa39
function actions(game::Game, state::String)
    return collect(keys(get(game.nodes, state, Dict())));
end


# ╔═╡ 8a642b12-6a66-41c2-8209-5766ce604455
function result(game::Game, state::String, move::String)
    return game.nodes[state][move];
end


# ╔═╡ 41184804-d48c-4dcb-8c1a-a9d8acf468e2
function utility(game::Game, state::String, player::String)
    if (player == "MAX")
        return game.utilities[state];
    else
        return -game.utilities[state];
    end
end


# ╔═╡ 602aaab8-8b80-426d-b381-35a9a2bd4326
function terminal_test(game::Game, state::String)
    return !(state in ["R", "S", "T", "U"]);
end


# ╔═╡ f3f77dbb-651d-421e-aa0e-b63095e6c02c
function to_move(game::Game, state::String)
    return if_((state in ["S", "T", "U"]), "MIN", "MAX");
end



# ╔═╡ c89e8d68-2b58-491b-88b6-f54516ff68fa
function minimax(state::String, game::T; u::Int64=5, cutoff_test_fn::Union{Nothing, Function}=nothing, evaluation_fn::Union{Nothing, Function}=nothing) where {T <: AbstractGame}
    local player::String = to_move(game, state);
    if (typeof(cutoff_test_fn) <: Nothing)
        cutoff_test_fn = (function(state::String, depth::Int64; dvar::Int64=d, relevant_game::AbstractGame=game)
                            return ((depth > dvar) || terminal_test(relevant_game, state));
                        end);
    end
    if (typeof(evaluation_fn) <: Nothing)
        evaluation_fn = (function(state::String, ; relevant_game::AbstractGame=game, relevant_player::String=player)
                            return utility(relevant_game, state, relevant_player);
                        end);
    end
    return argmax(actions(game, state),
                    (function(action::String,; relevant_game::AbstractGame=game, relevant_state::String=state, relevant_player::String=player, cutoff_test::Function=cutoff_test_fn, eval_fn::Function=evaluation_fn)
                        return min_value(relevant_game, relevant_player, cutoff_test, eval_fn, result(relevant_game, relevant_state, action), -Inf64, Inf64, 0);
                    end));
end


# ╔═╡ 4432b099-cc63-47ab-b182-fca270f75fa5
function player(game::T, state::String) where {T <: AbstractGame}
    return minimax(state, game);
end


# ╔═╡ 8f702f15-92cd-4483-9431-02a9eb3410fc
function play_game(game::T, players::Vararg{Function}) where {T <: AbstractGame}
    state = game.initial;
    while (true)
        for player in players
            move = player(game, state);
            state = result(game, state, move);
            if (terminal_test(game, state))
                return utility(game, state, to_move(game, game.initial));
            end
        end
    end
end


game = Game()
player1 = player
player2 = player
println(play_game(game, player1, player2))


# ╔═╡ c4ad4703-c272-4db1-b0ef-3eb5315f5485
function max_value(game::T, player::String, cutoff_test_fn::Function, evaluation_fn::Function, state::String, alpha::Number, beta::Number, depth::Int64) where {T <: AbstractGame}
    if (cutoff_test_fn(state, depth))
        return evaluation_fn(state);
    end
    local value::Float64 = -Inf64;
    for action in actions(game, state)
        value = max(value, min_value(game, player, cutoff_test_fn, evaluation_fn, result(game, state, action), alpha, beta, depth + 1));
        if (value >= beta)
            return value;
        end
        alpha = max(alpha, value);
    end
    return value;
end


# ╔═╡ cb3ca4db-f1ab-4569-b8ae-0d9312efaa6a

function min_value(game::T, player::String, cutoff_test_fn::Function, evaluation_fn::Function, state::String, alpha::Number, beta::Number, depth::Int64) where {T <: AbstractGame}
    if (cutoff_test_fn(state, depth))
        return evaluation_fn(state);
    end
    local value::Float64 = Inf64;
    for action in actions(game, state)
        value = min(value, max_value(game, player, cutoff_test_fn, evaluation_fn, result(game, state, action), alpha, beta, depth + 1));
        if (value >= alpha)
            return value;
        end
        beta = min(alpha, value);
    end
    return value;
end



# ╔═╡ Cell order:
# ╠═bdbff2b2-b3e8-11eb-300a-f7b7f7c312ea
# ╠═3254adac-5b3a-4262-91de-9717c8e4ea80
# ╠═deec1ed4-a1ff-4d8e-805b-d964bd143120
# ╠═df86f3cd-c9e1-447c-a2a7-ffc05018590b
# ╠═8c6ddc10-58f4-4d07-9048-135e56e8fa39
# ╠═8a642b12-6a66-41c2-8209-5766ce604455
# ╠═41184804-d48c-4dcb-8c1a-a9d8acf468e2
# ╠═602aaab8-8b80-426d-b381-35a9a2bd4326
# ╠═f3f77dbb-651d-421e-aa0e-b63095e6c02c
# ╠═c4ad4703-c272-4db1-b0ef-3eb5315f5485
# ╠═cb3ca4db-f1ab-4569-b8ae-0d9312efaa6a
# ╠═c89e8d68-2b58-491b-88b6-f54516ff68fa
# ╠═4432b099-cc63-47ab-b182-fca270f75fa5
# ╠═8f702f15-92cd-4483-9431-02a9eb3410fc
