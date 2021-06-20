### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 68b185e1-3815-4598-bcb4-c8447462e818
begin
	using Flux, Flux.Data.MNIST, Statistics
	using Flux: onehotbatch, onecold, crossentropy, throttle
	using Base.Iterators: repeated, partition
	using Printf, BSON
	using ImageIO
	using Images
end

# ╔═╡ 4813695f-ab8b-4b8b-9a9a-e60f9fbfd050
begin

base_path=pwd()

file_normal = readdir(base_path *"\\archive (1)\\chest_xray\\test\\NORMAL")
file_pneumonia=readdir(base_path *"\\archive (1)\\chest_xray\\test\\PNEUMONIA"

path_X_test=base_path *"\\archive (1)\\chest_xray\\test\\NORMAL".*file_normal
path_Y_test=base_path *"\\archive (1)\\chest_xray\\test\\PNEUMONIA".*file_pneumonia

x_normal_test= path_X_test
y_pneumonia_test= path_Y_test

	file_normal_train=readdir(base_path*"\\archive (1)\\chest_xray\\train\\NORMAL")
	file_pneumonia_train=readdir(base_path*"\\archive (1)\\chest_xray\\train\\PNEUMONIA")
	
	path_X_normal_train=base_path*"\\archive (1)\\chest_xray\\train\\NORMAL".*file_normal_train
	path_y_pneumonia_train=base_path*"\\archive (1)\\chest_xray\\train\\PNEUMONIA".*file_pneumonia_train
		
   X_train = path_X_normal_train
	Y_train = path_Y_pneumonia_train
	X_test_final=[X_normal_test; Y_pneumonia_test]
		
	X_train_final=[path_X_normal_train; path_Y_pneumonia_train]
	end

# ╔═╡ 10eddd36-a2e4-4d2a-b59d-d94a20d57510
function make_minibatch(X, Y, idxs)
    X_batch = Array{Float32}(undef, size(X[1])..., 1, length(idxs))
    for i in 1:length(idxs)
        X_batch[:, :, :, i] = Float32.(X[idxs[i]])
    end
    Y_batch = onehotbatch(Y[idxs], 0:9)
    return (X_batch, Y_batch)
end

# ╔═╡ 416df414-4c2a-47f5-a18a-eb1e803a5574
test_imgs = base_path.images(:test)

# ╔═╡ e530d997-c9b3-4790-8e02-a6553a8b7957
test_labels = base_path.labels(:test)

# ╔═╡ e013bc20-35ec-444c-925f-508014f0cbd5
typeof(	file_normal_train)

# ╔═╡ 1e259a36-79bd-4099-bce7-1cb22a9ecb1a
size(file_normal_traint[1][1])

# ╔═╡ 8c19fd72-15c4-4d31-857e-14f874414e5c
typeof(	file_pneumonia_train)

# ╔═╡ de641f2e-ec71-45d3-b30e-152c4d4c2545
size(file_pneumonia_train[1][1])

# ╔═╡ bbb7ce39-35c3-4bd4-9be1-31c5d1cac993
@info("Constructing model...")
model = Chain(
    
    Conv((3, 3), 1=>16, pad=(1,1), relu),
    x -> maxpool(x, (2,2)),

    
    Conv((3, 3), 16=>32, pad=(1,1), relu),
    x -> maxpool(x, (2,2)),

    
    Conv((3, 3), 32=>32, pad=(1,1), relu),
    x -> maxpool(x, (2,2)),

    
    x -> reshape(x, :, size(x, 4)),
    Dense(288, 10),

    
    softmax,
)


# ╔═╡ cfde3cee-fa2e-438e-acbe-1d9620e78226
model(train_set[1][1])

# ╔═╡ 46872c91-659b-494e-9146-5418500c680a
function loss(x, y)
    x_aug = x .+ 0.1f0*gpu(randn(eltype(x), size(x)))

    y_hat = model(x_aug)
    return crossentropy(y_hat, y)
end



# ╔═╡ 27eba596-4d8c-40fc-be9d-65c7e70e48ba
accuracy(x, y) = mean(onecold(model(x)) .== onecold(y))

# ╔═╡ 1f7e8484-8fc0-437e-95d7-0001426a9c81
opt = ADAM(0.001)

# ╔═╡ 7a9067bf-a94c-46f2-9e88-629769f0bd49
begin
	@info("Beginning training loop...")
	best_acc = 0.0
	last_improvement = 0
	for epoch_idx in 1:100
	    global best_acc, last_improvement
	   
	    Flux.train!(loss, params(model), train_set, opt)
	
	   
	    acc = accuracy(test_set...)
	    @info(@sprintf("[%d]: Test accuracy: %.4f", epoch_idx, acc))
	    
	    
	    if acc >= 0.999
	        @info(" -> Early-exiting: We reached our target accuracy of 99.9%")
	        break
	    end
	
	    
	    if acc >= best_acc
	        @info(" -> New best accuracy! Saving model out to mnist_conv.bson")
	        BSON.@save "base_path_conv.bson" model epoch_idx acc
	        best_acc = acc
	        last_improvement = epoch_idx
	    end
	
	    
	    if epoch_idx - last_improvement >= 5 && opt.eta > 1e-6
	        opt.eta /= 10.0
	        @warn(" -> Haven't improved in a while, dropping learning rate to $(opt.eta)!")
	
	   
	        last_improvement = epoch_idx
	    end
	
	    if epoch_idx - last_improvement >= 10
	        @warn(" -> We're calling this converged.")
	        break
	    end
	end
end

# ╔═╡ 071c97fd-ec0d-45eb-9777-593bb3213c54
begin
train_set = gpu.(train_set)
test_set = gpu.(test_set)
model = gpu(model)
end

# ╔═╡ fd8bfb71-e1f4-4ccf-b262-419af68e1502
test_set = make_minibatch(test_imgs, test_labels, 1:length(test_imgs))

# ╔═╡ Cell order:
# ╠═68b185e1-3815-4598-bcb4-c8447462e818
# ╠═4813695f-ab8b-4b8b-9a9a-e60f9fbfd050
# ╠═10eddd36-a2e4-4d2a-b59d-d94a20d57510
# ╠═416df414-4c2a-47f5-a18a-eb1e803a5574
# ╠═e530d997-c9b3-4790-8e02-a6553a8b7957
# ╠═fd8bfb71-e1f4-4ccf-b262-419af68e1502
# ╠═e013bc20-35ec-444c-925f-508014f0cbd5
# ╠═1e259a36-79bd-4099-bce7-1cb22a9ecb1a
# ╠═8c19fd72-15c4-4d31-857e-14f874414e5c
# ╠═de641f2e-ec71-45d3-b30e-152c4d4c2545
# ╠═bbb7ce39-35c3-4bd4-9be1-31c5d1cac993
# ╠═071c97fd-ec0d-45eb-9777-593bb3213c54
# ╠═cfde3cee-fa2e-438e-acbe-1d9620e78226
# ╠═46872c91-659b-494e-9146-5418500c680a
# ╠═27eba596-4d8c-40fc-be9d-65c7e70e48ba
# ╠═1f7e8484-8fc0-437e-95d7-0001426a9c81
# ╠═7a9067bf-a94c-46f2-9e88-629769f0bd49
