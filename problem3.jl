### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ b5e1c7a0-afe0-11eb-305e-d9766837bbba
using Pkg

# ╔═╡ c12eb190-afe0-11eb-170d-4ba49d740d41
Pkg.activate("Project.toml")

# ╔═╡ c12d2af0-afe0-11eb-0bb1-f14d0ea5e898
#domain = [1,2,3,4]
 @enum ColourD one two three four

# ╔═╡ 4b4199b0-b0bd-11eb-39fa-7bc50ab4564e
ColourD

# ╔═╡ c12bcb62-afe0-11eb-05d5-3b63dae23f78
mutable struct CSPVar
name::String
value::Union{Nothing,ColourD}
forbidden_values::Vector{ColourD}
d_restriction_count::Int64
end


# ╔═╡ fb6675d0-b0b4-11eb-14c9-cfcd21f19c4e
rand(setdiff(Set([1,2,3, 4]),
		Set([2,3,4])))

# ╔═╡ c12ba450-afe0-11eb-1568-b1c8baa29c04
struct ColourCSP
vars::Vector{CSPVar}
constraints::Vector{Tuple{CSPVar,CSPVar}}
end


# ╔═╡ f402a040-afe0-11eb-367b-cf9b4475be29
function solvecsp(pb::ColourCSP, all_assignments)
		for cur_var in pb.vars
			if cur_var.d_restriction_count == 4
				return []
			else
				next_val = rand(setdiff(Set([one,two,three,four]),
Set(cur_var.forbidden_values)))
			    println(cur_var.forbidden_values)
				  cur_var.value = next_val
				for cur_constraint in pb.constraints
					if !((cur_constraint[1] == cur_var) || (cur_constraint[2] ==
							cur_var))
						continue
					  else
					if cur_constraint[1] == cur_var
								push!(cur_constraint[2].forbidden_values, next_val)
								cur_constraint[2].d_restriction_count += 1
                    else
                      push!(cur_constraint[1].forbidden_values, next_val)
                       cur_constraint[1].d_restriction_count += 1

		          end
              end
          end
      push!(all_assignments, cur_var.name => next_val)
      end
   end
return all_assignments
end

# ╔═╡ 12a18610-afe1-11eb-1e82-ed9564cb476b
xone = CSPVar("Xone",nothing, [], 0)


# ╔═╡ 1b81b5c0-afe1-11eb-0e03-5bcb442e9045
xtwo = CSPVar("Xtwo", nothing, [], 0)

# ╔═╡ 22bf800e-afe1-11eb-21c2-df33d6264e57
xthree = CSPVar("Xthree", nothing, [two, three, four], 0)


# ╔═╡ 29bce5fe-afe1-11eb-383e-45f013e4db39
xfour = CSPVar("Xfive", nothing, [], 0)

# ╔═╡ 2fcd2cd0-afe1-11eb-3965-9dc868d35014
xfive = CSPVar("Xfive", nothing, [], 0)

# ╔═╡ 45c43100-afe1-11eb-3dd3-5977d722d286
xsix = CSPVar("Xsix", nothing, [], 0)

# ╔═╡ 49021df0-afe1-11eb-3ac7-3f3f693f26b7
xseven = CSPVar("Xseven", nothing, [], 0)


# ╔═╡ 52f9d820-afe1-11eb-2c8d-0d7d241b299e
problem = ColourCSP([xone, xtwo, xthree, xfour, xfive, xsix, xseven], [(xone,xtwo), (xone,xthree), (xone,xfour),
(xone,xfive), (xone,xsix), (xtwo,xfive), (xthree,xfour), (xfour,xfive), (xfour,xsix), (xfive,xsix), (xsix,xseven)])



# ╔═╡ 61484240-afe1-11eb-11ef-637b53d25a03
solvecsp(problem, [])

# ╔═╡ Cell order:
# ╠═b5e1c7a0-afe0-11eb-305e-d9766837bbba
# ╠═c12eb190-afe0-11eb-170d-4ba49d740d41
# ╠═c12d2af0-afe0-11eb-0bb1-f14d0ea5e898
# ╠═4b4199b0-b0bd-11eb-39fa-7bc50ab4564e
# ╠═c12bcb62-afe0-11eb-05d5-3b63dae23f78
# ╠═fb6675d0-b0b4-11eb-14c9-cfcd21f19c4e
# ╠═c12ba450-afe0-11eb-1568-b1c8baa29c04
# ╠═f402a040-afe0-11eb-367b-cf9b4475be29
# ╠═12a18610-afe1-11eb-1e82-ed9564cb476b
# ╠═1b81b5c0-afe1-11eb-0e03-5bcb442e9045
# ╠═22bf800e-afe1-11eb-21c2-df33d6264e57
# ╠═29bce5fe-afe1-11eb-383e-45f013e4db39
# ╠═2fcd2cd0-afe1-11eb-3965-9dc868d35014
# ╠═45c43100-afe1-11eb-3dd3-5977d722d286
# ╠═49021df0-afe1-11eb-3ac7-3f3f693f26b7
# ╠═52f9d820-afe1-11eb-2c8d-0d7d241b299e
# ╠═61484240-afe1-11eb-11ef-637b53d25a03
