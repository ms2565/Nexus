function var = dtsIO_readVar(nexon, varID, idxSel)
    var = nexon.console.BASE.DTS.(varID);
    var = var(idxSel);
end