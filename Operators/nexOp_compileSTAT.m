function STAT = nexOp_compileSTAT(nexon, dfID, S_categories, S_items, idxSel)
    % for each DF in DF_col, use dim selection (bus) to slice coordinate of
    % interest and arrange a multi-factoral column-wise grouping/labeling
    % for downstream analysis/visualization
    % extract grouping columns (for every selection that is not empty)
    % for each category (use items)

    if isempty(idxSel)
            S = nex_returnSelectionMask(nexon.console.BASE.controlPanel.averagingSelection);
            idxSel = nex_applySelectionMask(nexon.console.BASE.DTS,S);
            TF = dtsIO_readTF(nexon, dfID, idxSel);
    else
            TF = dtsIO_readTF(nexon, dfID, idxSel);
    end

    categories = fieldnames(S_categories);
    categories_ax = [];
    % sessionLabel and var
    Y = []; % container for category items (across all selected samples)
    categoryProps = []; % list of applicable categories
    selMatch = ones(size(idxSel(idxSel==1)));
    for i = 1:length(categories)
        category = categories{i};
        categoryID = S_categories.(category);
        if ~contains(categoryID, "ax") && (~strcmp(categoryID,"None"))
            TF_category = dtsIO_readTF_category(nexon, categoryID, idxSel);
            Y = [Y, TF_category];
            categoryProps = [categoryProps; strrep(categoryID,"--","_")];
            selMatch = [selMatch & ismember(TF_category, S_items.(category))];
        end
    end
    Y = array2table(Y, 'VariableNames', categoryProps);
    Y = Y(selMatch,:); % filter by intersection of all category selections
    TF = TF(selMatch); % filter selected data as well
    % parallel parsing
    SS = outerjoinStructs(S_categories, S_items);
    keep = convertCharsToStrings(fieldnames(SS)); keep = keep(contains(keep, "ax"));
    SS_ax = rmfield(SS, setdiff(fieldnames(SS), keep));
    
    M = cell(size(TF));
    % tic
    for i = 1:height(Y)
        DF =TF{i};
        Y_i = Y(i,:);
        sample = nexStat_breakoutSample(DF, Y_i, SS_ax);
        M{i} = sample;
    end
    % toc
    % % ax
    % for i = 1:length(categories_ax)
    %     category = categories_ax(i);
    %     categoryID = S_categories.(category);
    %     categoryID = split(categoryID,"--"); categoryID = categoryID(2);
    %     % 
    % end
    STAT = cat(1, M{:});
    % STAT = [];
end