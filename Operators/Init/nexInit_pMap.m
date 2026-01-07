function pMap = nexInit_pMap(nexon, DF)
    % for each ax, preload a pool map object (try to use pre-existing
    % functions by the prototype: poolMap_<ax>.m
    axFields = fieldnames(DF.ax);
    for i = 1:length(axFields)
        axField = axFields{i};
        % temporary conditionals 
        if strcmp(axField,'t')
            axField = "time";
            % Map = derive_pMap_time(nexon, DF);
            events = dtsIO_listEvents(nexon);
            Map = map_events2time(events);
            mapID = "event";
        elseif strcmp(axField,'f')
            axField = "freqs";
            bands = nexon.console.BASE.params.bands;
            Map = map_bands2freqs(bands);
            mapID = "band";
        elseif strcmp(axField, "chans")
            regMap = nexon.console.NPXLS.shanks.shank1.regMap;
            Map = map_regions2chans(regMap);
            mapID = "region";
        end
        prototype = str2func(sprintf("nexObj_poolMap_%s",axField));
        pMap.(axField) = prototype(Map, [], axField, mapID);
    end
end