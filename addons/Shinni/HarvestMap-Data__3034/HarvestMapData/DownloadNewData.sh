#!/bin/bash
# HarvestMapData/DownloadNewData.sh
# - Original script for OS X by (C) 2018 @mojo66 <eso@mojo66.de>
# - Modified for Linux use by @myxlmynx <myxlmynx@posteo.de>, Icipher
#   Linux users: change "basedir_linux" to your ESO "live" directory
#------------------------------------------------------------------------------


basedir=$(realpath ../..)
savedvardir="${basedir}/SavedVariables"
addondir="${basedir}/AddOns/HarvestMapData"
emptyfile="${addondir}/Main/emptyTable.lua"

# check if everything exists
if [[ ! -e "${addondir}" ]]; then echo "ERROR: ${addondir} does not exist, re-install this AddOn and try again...";exit 1;fi

# iterate over the different zones
for zone in AD EP DC DLC NF; do

    fn=HarvestMap${zone}.lua
    echo "Working on ${fn}..."

    svfn1=${savedvardir}/${fn}
    svfn2=${svfn1}~

    # if saved var file exists, create backup...
    if [[ -e ${svfn1} ]]; then
        mv -f "${svfn1}" "${svfn2}"
    # ...else, use empty table to create a placeholder
    else
        name=Harvest${zone}_SavedVars
        echo -n "${name}" | cat - "${emptyfile}" > "${svfn2}"
    fi
    # download data
    curl -f -# -d @"${svfn2}" -o "${addondir}/Modules/HarvestMap${zone}/${fn}" "http://harvestmap.binaryvector.net:8081"

done