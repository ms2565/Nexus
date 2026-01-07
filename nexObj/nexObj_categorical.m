classdef nexObj_categorical < handle
    properties
        classID = "ctg"
        nexon
        Parent
        Partners
        Children
        dfID_source
        dfID_target
        selectionBus
        pMap
        cfg
        DF
        DF_postOp
        STAT
        Figure
    end
    methods

        function nexObj = nexObj_categorical(nexon, Partner, dfID_source, opFcn)
            nexObj.dfID_source = dfID_source;
            if isempty(Partner)
                nexObj.nexon = nexon;
            else % partner handshake method
                nexObj.Partners.(Partner.classID) = Partner;
                Partner.Partners.(nexObj.classID) = nexObj;
                nexObj.nexon = Partner.nexon;
            end
            % method configuration
            nexObj.cfg.opCfg=[];
            nexObj.cfg.visCfg = nex_generateCfgObj(str2func("nexVisualization_categorical"));            
            % retrieve dataframe
            nexObj.DF = dtsIO_readDF(nexObj.nexon, nexObj.dfID_source, []);
            % compute result
            nexObj.compute();
            % axis control            
            nexObj.DF_postOp =  nex_initAxisPointer_v2(nexObj.DF_postOp);       
            % pooling control
            try
                nexObj.pMap = nexInit_pMap(nexObj.nexon, nexObj.DF_postOp);
            catch e
                disp(getReport(e));
            end
            % selection Busses
            nexObj.selectionBus.categories = nexSelect_categories(nexObj);
            S = nex_returnSelectionMask(nexObj.selectionBus.categories);
            % itemsDict = structfun(@(fieldVal) nexOp_enumerateCategory(nexObj, fieldVal), S,"UniformOutput",false);
            itemsDict = structfun(@(fieldVal) "", S,"UniformOutput",false);
            % itemsDict = nexOp_itemize()
            nexObj.selectionBus.items = buildSelection(nexObj, itemsDict);
            % modify selectionBus heirarchy (arrange selection cascade)
            nexObj.selectionBus.categories.Parent = nexObj.selectionBus.items;
            nexObj.selectionBus.items.Children.sbus = nexObj.selectionBus.categories;
            % draw figure
            nexFigure_categorical(nexObj);
        end

        function reportStats(nexObj, idxSel)            
            % use category selection to group pre-selected DFs into stat metrics
            % leverage comp and opFcns if desired (to get final categories X1, X2,
            % X.., XN)            
            % if isempty(idx_sel)
            %         S = nex_returnSelectionMask(nexObj.nexon.console.BASE.controlPanel.averagingSelection);
            %         idxSel = nex_applySelectionMask(nexObj.nexon.console.BASE.DTS,S);
            %         TF = dtsIO_readTF(nexObj.nexon, nexObj.dfID_source, idxSel);
            % else
            %         TF = dtsIO_readTF(nexObj.nexon, nexObj.dfID_source, idx_sel);
            % end
            % group selections
            % nexObj.STAT = 
            S_categories = nex_returnSelectionMask(nexObj.selectionBus.categories);
            S_items = nex_returnSelectionMask(nexObj.selectionBus.items);
            nexObj.STAT = nexOp_compileSTAT(nexObj.nexon, nexObj.dfID_source, S_categories, S_items, idxSel);
            nexObj.STAT.df = cell2mat(nexObj.STAT.df);
            % visualize result
            % nexObj.visualize();
            nexObj.drawCanvas();
        end

        function drawCanvas(nexObj)
            % nexObj.Figure.panel0.graphics. nexDraw_violin();
            % categories = nexOp_listCategories(nexObj.nexon)';
            % categories = nexObj.selectionBus.categories.selKeys.C1';
            % clear canvas
            if isfield(nexObj.Figure.panel0,"graphics")
                nexDraw_clearViolin(nexObj);
            end
            % draw new canvas
            S_categories = nex_returnSelectionMask(nexObj.selectionBus.categories);
            nexObj.Figure.panel0.graphics.canvas = nexDraw_violin(nexObj.Figure.panel0.tiles.ax, nexObj.STAT, S_categories);
        end

        function visualize(nexObj)
            nexObj.cfg.visCfg.fcn(nexObj, nexObj.cfg.visCfg.entryParams);            
        end

        function compute(nexObj)
            try
                nexObj.DF_postOp = nexObj.cfg.compCfg.fcn(DF, compArgs);
            catch e
                disp(getReport(e));
                nexObj.DF_postOp = nexObj.DF;
            end
            operate(nexObj);
        end

        function operate(nexObj)
            try
                nexObj.DF_postOp = nexObj.cfg.opCfg.fcn(nexObj.DF_postOp);
            catch e
                disp(getReport(e));
            end
        end

        function setAxisPointer(nexObj, src, event, axSel)
            axVal = src.Value;
            nexObj.DF = nex_setAxisPointer(nexObj.DF,axSel, axVal);
            nexObj.updateScope();
        end

    end
end