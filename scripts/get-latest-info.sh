#!/bin/bash
set -e

TEMPDIR="$(mktemp -d)"

echo "Downloading latest configurations..."

DOWNLOAD_LINK_GEOIP="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
DOWNLOAD_LINK_GEOSITE="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

download_geoip() {
    echo "Starting Download GEOIP: ${DOWNLOAD_LINK_GEOIP}"
    if ! curl --progress-bar -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.new" "$DOWNLOAD_LINK_GEOIP"; then
        echo 'error: Download failed! Please check your network or try again.'
    fi
    # if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOIP.sha256sum"; then
    #     echo 'error: Download failed! Please check your network or try again.'
    # fi
    # SUM="$(sha256sum ${TEMPDIR}/geoip.dat.new | sed 's/ .*//')"
    # CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geoip.dat.sha256sum.new)"
    # if [[ "$SUM" != "$CHECKSUM" ]]; then
    #     echo 'error: Check failed! Please check your network or try again.'
    # fi
}

download_geosite() {
    echo "Starting Download GEOSITE: ${DOWNLOAD_LINK_GEOSITE}"
    if ! curl --progress-bar -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.new" "$DOWNLOAD_LINK_GEOSITE"; then
        echo 'error: Download failed! Please check your network or try again.'
    fi
    # if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOSITE.sha256sum"; then
    #     echo 'error: Download failed! Please check your network or try again.'
    # fi
    # SUM="$(sha256sum ${TEMPDIR}/geosite.dat.new | sed 's/ .*//')"
    # CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geosite.dat.sha256sum.new)"
    # if [[ "$SUM" != "$CHECKSUM" ]]; then
    #     echo 'error: Check failed! Please check your network or try again.'
    # fi
}

rename_new() {
    for DAT in 'geoip' 'geosite'; do
        mv "${TEMPDIR}/$DAT.dat.new" "${WORKDIR}/$DAT.dat"
        # rm "${TEMPDIR}/$DAT.dat.new"
        # rm "${TEMPDIR}/$DAT.dat.sha256sum.new"
    done
}

main(){
    download_geoip
    download_geosite
    rename_new
}

main

echo "Cleaning up..."
rm -r "$TEMPDIR"