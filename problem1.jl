### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 7bc88700-b000-11eb-0302-89ce5dfe6e20
using Pkg

# ╔═╡ ab9cd3d7-5490-4e5d-a5f4-0be85c5bcd2b
Pkg.add("DataStructures")

# ╔═╡ 02e055c7-d1aa-4a33-8d39-d93816e4f959
using DataStructures

# ╔═╡ 83fb292e-23f7-4c4e-b685-75c457e7a12b
struct State
	name::String
	position::Int64
	number_of_dirt::Vector{Int}
end

# ╔═╡ 1534e8ee-ed5f-4ead-8e0f-090ccebe2269
struct Action
	name::String
	cost::Int64
end

# ╔═╡ 07ddc62a-b941-49e8-91ac-2d39dcb8c436
action1 = Action("movewest", 3)

# ╔═╡ 48f37c66-1908-4e2a-b77b-0686556ace56
action2 = Action("moveeast", 3)

# ╔═╡ 9fad5628-a7d1-417c-a078-a00ee3a19186
action3 = Action("remain", 1)

# ╔═╡ 20d8d5e1-4f8b-4ea8-942e-dcdd953c73f8
action4 = Action("collect", 5)

# ╔═╡ 70740ca2-f361-41da-af94-12f2ce745652
st1 = State("State1", 1, [1, 3, 2, 1])

# ╔═╡ 47228049-648a-4895-a7f5-5893bbeae3ed
st2 = State("State2", 2, [1, 3, 2, 1])

# ╔═╡ 48088da2-ad5b-490b-99df-c318ee427913


# ╔═╡ 7ee35196-2578-433f-a52a-78ef7bddd2ab
st3 = State("State3", 3, [1, 3, 2, 1])

# ╔═╡ 3bd1b3bc-b011-4a08-8208-76834ea6d787
st4 = State("State4r", 4, [1, 3, 2, 1])

# ╔═╡ 36e65be3-c104-4790-ab57-57740a6f6863
st5 = State("State5", 1, [0, 3, 2, 1])

# ╔═╡ 1cd8cbc5-9885-4f0e-aab1-fee4e398e018
st6 = State("State6", 2, [0, 3, 2, 1])

# ╔═╡ cc192893-54d4-4a85-95ea-217006df0b55
st7 = State("State7", 3, [0, 3, 2, 1])

# ╔═╡ 212021b5-3480-49fe-8682-6852e00c0d13
st8 = State("State8", 4, [0, 3, 2, 1])

# ╔═╡ 9598248c-3d3e-46d4-9a0b-3a84a0823fc0
st9 = State("State9", 4, [0, 3, 2, 0])

# ╔═╡ 98b223ef-89a6-4425-bbec-805867c21fe1
Transition_Mod = Dict()

# ╔═╡ b7cd3ea9-dec5-4fdb-aa9a-868a8a48ef56
push!(Transition_Mod, st1 => [(action2, st2), (action1, st1), (action3, st1), (action4, st5)])

# ╔═╡ 2090e0a1-9c47-4ebe-8282-6f61c10b0015
push!(Transition_Mod, st2 => [(action2, st3), (action1, st1), (action3, st2)])

# ╔═╡ 46841b1b-f8f2-4d2b-8e1c-2986a8c40086
push!(Transition_Mod, st3 => [(action2, st4), (action1, st2), (action3, st3)])

# ╔═╡ 858424cb-ebe3-4363-9c1a-0370689db1a1
push!(Transition_Mod, st4 => [(action2, st4), (action1, st3), (action3, st4)])

# ╔═╡ 70ff28a4-34af-4fc2-ae07-dadbfe35bf5c
push!(Transition_Mod, st5 => [( action1, st5), (action2, st6), (action3, st5)])

# ╔═╡ e8a05ca5-857e-458f-a248-92a173321ed5
push!(Transition_Mod, st6 => [( action1, st5), (action2, st7), (action3, st6)])

# ╔═╡ 1b2a8067-6e06-4402-88ac-a1215fd85f0a
push!(Transition_Mod, st7 => [( action1, st6), (action2, st8), (action3, st7)])

# ╔═╡ 71a079e0-b4e7-4450-ab11-30a9be19da7e
push!(Transition_Mod, st8 => [( action1, st7), (action2, st8), (action3, st8), (action4, st9)])

# ╔═╡ a1cad0c5-1e86-42b1-8467-a4d49f2627a9
Transition_Mod

# ╔═╡ 8d2dbed7-2e3e-4604-b999-6c47821d4d5b
function create_result(trans_model, ancestors, initial_state, goal_state)
	
	result = []
	explorer = goal_state
		while !(explorer == initial_state)
				current_state_ancestor = ancestors[explorer]
				related_transitions = trans_model[current_state_ancestor]
			for single_trans in related_transitions
				if single_trans[2] == explorer
					push!(result, single_trans[1])
					break
				else
					continue
				end
			end
				explorer = current_state_ancestor
		end
	return result
end

# ╔═╡ 38e2b751-3942-44b9-bee8-d2f26989854e
function bfs_search(initial_state, transition_model, goal_states)
		result = []
		all_candidates = Queue{State}()
		explored = []
		ancestors = Dict{State, State}()
		first_state = true
		enqueue!(all_candidates, initial_state)
		parent = initial_state
	while true
      	 	if isempty(all_candidates)
				return []
			else
					current_state = dequeue!(all_candidates)
					
					push!(explored, current_state)
					candidates = transition_model[current_state]
				for single_candidate in candidates
					if !(single_candidate[2] in explored)
							push!(ancestors, single_candidate[2] => current_state)
						if (single_candidate[2] in goal_states)
								return create_result(transition_model, ancestors,
										initial_state, single_candidate[2])
						else
								enqueue!(all_candidates, single_candidate[2])
						end
					end
				end
			end
		end
end

# ╔═╡ 51890660-9917-4060-a92a-52955928e721
function heuristic(cell)
	
	sum = 0
	for i in 1:length(cell)
		sum += cell[i]
	end
  return sum
end

# ╔═╡ b7022920-b04b-11eb-37a1-778c27d29c26
cell = [1, 3, 2, 1]

# ╔═╡ afd5c3f0-b04b-11eb-38d0-ffabfcc1cd0b
heuristic(cell)

# ╔═╡ c57b9be7-f1b7-476f-8cea-f3dc6af2eecf
function goal_test(current_state::State)
  return ! (current_state.number_of_dirt[1]==0 || current_state.number_of_dirt[4]==0)
end

# ╔═╡ 030f50e8-7d3b-48a1-9366-3836d3bfebc1
function add_to_pqueue_ucs(queue::PriorityQueue{State, Int64}, state::State,
cost::Int64)
	enqueue!(queue, state, cost)
	return queue
end

# ╔═╡ 322f8029-54e7-4652-b8c9-4e432312f6bf
function add_to_stack(stack::Stack{State}, state::State, cost::Int64)
	push!(stack, state)
	return stack
end

# ╔═╡ 2c35e7cd-fc18-4a84-a777-3b2b30e223d8
function remove_from_queue(queue::Queue{State})
removed = dequeue!(queue)
		return (removed, queue)
end

# ╔═╡ 2e8f4a2b-6559-4229-8f2a-c1adb7a6a2b9
function remove_from_stack(stack::Stack{State})
	removed = pop!(stack)
	return (removed, stack)
end

# ╔═╡ 50526add-584f-4988-a6a5-066bd4d55e21
function remove_from_pqueue_ucs(queue::PriorityQueue{State, Int64})
	removed = dequeue!(queue)
	return (removed, queue)
end

# ╔═╡ 44d2e930-b04f-11eb-0912-8d6721b16056
function astar_search(initial_state, transition_dict, goal_state, all_candidates,
		add_candidate, remove_candidate)
		explored = []
		ancestors = Dict{State, State}()
	     total_cost = 0
		the_candidates = add_candidate(all_candidates, initial_state, 0)
		parent = initial_state
	
	
	while true
		if isempty(the_candidates)
			return []
		else
			(t1, t2) = remove_candidate(the_candidates)
			 current_state = t1
			 the_candidates = t2
				
			 push!(explored, current_state)
             candidates = transition_dict[current_state]
			 for single_candidate in candidates
			   println(the_candidates)
			
				  if !(single_candidate[2] in explored)
					   push!(ancestors, single_candidate[2] => current_state)
					
					
					if (single_candidate[2] in  goal_state)
							return create_result(transition_dict, ancestors,
							  initial_state, single_candidate[2])
					  else
					 
							the_candidates = add_candidate(the_candidates,
							single_candidate[2], single_candidate[1].cost + heuristic(single_candidate[2].number_of_dirt))
					
					end
				  end
				
			  end
         end
     end
	println(the_candidates)
end

# ╔═╡ 44d24cee-b04f-11eb-2ef0-e32ff9afebcc


# ╔═╡ 594ac5f7-6b90-4a31-97d9-2514f57c5e13
astar_search(st3, Transition_Mod,[st4],PriorityQueue{State,Int64}(Base.Order.Reverse), add_to_pqueue_ucs, remove_from_pqueue_ucs)

# ╔═╡ Cell order:
# ╠═7bc88700-b000-11eb-0302-89ce5dfe6e20
# ╠═ab9cd3d7-5490-4e5d-a5f4-0be85c5bcd2b
# ╠═02e055c7-d1aa-4a33-8d39-d93816e4f959
# ╠═83fb292e-23f7-4c4e-b685-75c457e7a12b
# ╠═1534e8ee-ed5f-4ead-8e0f-090ccebe2269
# ╠═07ddc62a-b941-49e8-91ac-2d39dcb8c436
# ╠═48f37c66-1908-4e2a-b77b-0686556ace56
# ╠═9fad5628-a7d1-417c-a078-a00ee3a19186
# ╠═20d8d5e1-4f8b-4ea8-942e-dcdd953c73f8
# ╠═70740ca2-f361-41da-af94-12f2ce745652
# ╠═47228049-648a-4895-a7f5-5893bbeae3ed
# ╠═48088da2-ad5b-490b-99df-c318ee427913
# ╠═7ee35196-2578-433f-a52a-78ef7bddd2ab
# ╠═3bd1b3bc-b011-4a08-8208-76834ea6d787
# ╠═36e65be3-c104-4790-ab57-57740a6f6863
# ╠═1cd8cbc5-9885-4f0e-aab1-fee4e398e018
# ╠═cc192893-54d4-4a85-95ea-217006df0b55
# ╠═212021b5-3480-49fe-8682-6852e00c0d13
# ╠═9598248c-3d3e-46d4-9a0b-3a84a0823fc0
# ╠═98b223ef-89a6-4425-bbec-805867c21fe1
# ╠═b7cd3ea9-dec5-4fdb-aa9a-868a8a48ef56
# ╠═2090e0a1-9c47-4ebe-8282-6f61c10b0015
# ╠═46841b1b-f8f2-4d2b-8e1c-2986a8c40086
# ╠═858424cb-ebe3-4363-9c1a-0370689db1a1
# ╠═70ff28a4-34af-4fc2-ae07-dadbfe35bf5c
# ╠═e8a05ca5-857e-458f-a248-92a173321ed5
# ╠═1b2a8067-6e06-4402-88ac-a1215fd85f0a
# ╠═71a079e0-b4e7-4450-ab11-30a9be19da7e
# ╠═a1cad0c5-1e86-42b1-8467-a4d49f2627a9
# ╠═8d2dbed7-2e3e-4604-b999-6c47821d4d5b
# ╠═38e2b751-3942-44b9-bee8-d2f26989854e
# ╠═51890660-9917-4060-a92a-52955928e721
# ╠═b7022920-b04b-11eb-37a1-778c27d29c26
# ╠═afd5c3f0-b04b-11eb-38d0-ffabfcc1cd0b
# ╠═c57b9be7-f1b7-476f-8cea-f3dc6af2eecf
# ╠═030f50e8-7d3b-48a1-9366-3836d3bfebc1
# ╠═322f8029-54e7-4652-b8c9-4e432312f6bf
# ╠═2c35e7cd-fc18-4a84-a777-3b2b30e223d8
# ╠═2e8f4a2b-6559-4229-8f2a-c1adb7a6a2b9
# ╠═50526add-584f-4988-a6a5-066bd4d55e21
# ╠═44d2e930-b04f-11eb-0912-8d6721b16056
# ╠═44d24cee-b04f-11eb-2ef0-e32ff9afebcc
# ╠═594ac5f7-6b90-4a31-97d9-2514f57c5e13
