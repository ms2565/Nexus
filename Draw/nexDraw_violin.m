function V = nexDraw_violin(ax, STAT,  S_categories)
    
    categories = cellfun(@(f) S_categories.(f), fieldnames(S_categories));
    categories = strrep(categories(~strcmp(categories,"None")),"--","_")';
    [X, xTicks, xLabels] = nexStat_binSTAT(STAT, categories);
    % DRAWING    
    switch class(STAT.df)
        case 'cell'
            Y = cell2mat(STAT.df);
        otherwise
            Y = STAT.df;
    end    
    V.v = violinplot(ax, X, Y, GroupByColor=X);
    colorAx_green(ax);
    % axList = [ax];
    axList= [ax];
    gapOffset = 15;
    ax.XRuler.TickLabelGapOffset=0;
    for i = 1:size(xTicks,1)
        xTick = xTicks{i,1};        
        if ~isempty(xTick)
            ax_i = axes('Position',ax.Position,"Visible","off");
            ax_i.Parent = ax.Parent;
            ax_i.Visible="on";
            ax_i.Box="off";
            ax_i.YTick=[];
            axList = [axList, ax_i];
            ax_i.XTick = xTick;
            ax_i.XTickLabel = xLabels{i};           
            ax_i.XRuler.TickLabelGapOffset = gapOffset;
            colorAx_green(ax_i);
            gapOffset = gapOffset+20;
        end
    end    
    uistack(ax,"top");
    linkaxes(axList);
    V.axList=axList;
    % for i =2:length(axList)
    %     ax_i = axList(i);
    %     ax_i.Box="off";
    %     ax_i.Color
    % end
    % recursively build a nested violin plot, given selections
    % tierID = sprintf("C%d",tier);
    % categoryID = S_categories.(tierID);
    % items = S_items.(tierID);
    % % numItems = length(unique(STAT.(strrep(categoryID,"--","_")))); % relative to tier
    % numItems = length(items);
    % if tier==1
    %     xStep = 15;
    %     numFolds=1;        
    % elseif tier > maxTiers
    % else        
    %     numFolds = length(xTick{end-1,1});
    %     xStep = xTick(1) / (numItems);        
    % end
    % 
    % %% FORMAT LAYOUT
    % % xtick spacing (split by items)
    % xTick_new = [xStep-(xStep/2) : xStep : xStep*numFolds*numItems];
    % categories = [categories; strrep(categoryID,"--","_")];


    %% RECURSE
    % V = nexDraw_violin(ax, STAT, SS, floor(xStep/numItems), tier+1, {xTick; xTick_new});
    %% BASE CASE
    % BINNING
    % X = nexStat_binSTAT(STAT, xTick, categories); % assign bins from all possible category combos
    
end