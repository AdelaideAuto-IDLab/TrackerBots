function t_new = fix_time(t,delta_time)
    t_new = delta_time*round(t/delta_time);
end