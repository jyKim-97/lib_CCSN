function idx = bool2ind(bool_array)
% convert boolean array to index set based on TRUE value
% bool_array: 1D array
L = length(bool_array);

idx = [];
search_end = false;
for n = 1:L
    if bool_array(n) && ~search_end
        idx(end+1,:) = [n, -1];
        search_end = true;
    elseif ~bool_array(n) && search_end
        idx(end,2) = n-1;
        search_end = false;
    end
end

end