function flag = check_stringset(in, targets)
% targets: cell

flag = false;
for n = 1:length(targets)
    flag = flag || strcmp(in, targets{n});
end

end