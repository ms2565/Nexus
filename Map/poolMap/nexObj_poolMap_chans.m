classdef nexObj_poolMap_chans < nexObj_poolMap
    methods
        function pMap = nexObj_poolMap_chans(Map, source, axID, mapID)
                pMap = pMap@nexObj_poolMap(Map, source, axID, mapID);
        end
        function getBinEdges(pMap)
        end
    end
end