function out = rand_interval(a,b)
    out = a + (b-a) .* rand(size(a));
end