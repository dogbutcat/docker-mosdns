#!/bin/bash
set -e

TEMPDIR="$(mktemp -d)"

echo "Downloading latest data..."

# RESOLVE_URL=${RESOLVE_URL:-"github.com"}
# DEFAULT_DNS=${DEFAULT_DNS:-"1.1.1.1"}
# IP=""

DOWNLOAD_LINK_GEOIP=${DOWNLOAD_LINK_GEOIP:-"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"}
DOWNLOAD_LINK_GEOSITE=${DOWNLOAD_LINK_GEOSITE:-"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"}

# resolve_ip(){
#     echo "Starting Resolving "${RESOLVE_URL}" Using DNS "${DEFAULT_DNS}
#     IP=$(dig +short ${RESOLVE_URL} @${DEFAULT_DNS})
#     echo "${RESOLVE_DNS} IP: "${IP}
# }

download_geoip() {
    echo "Starting Download GEOIP: ${DOWNLOAD_LINK_GEOIP}"
    if ! curl --progress-bar -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.new" "$DOWNLOAD_LINK_GEOIP"; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 0
    fi
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOIP.sha256sum"; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 0
    fi
    SUM="$(sha256sum ${TEMPDIR}/geoip.dat.new | sed 's/ .*//')"
    CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geoip.dat.sha256sum.new)"
    if [[ "$SUM" != "$CHECKSUM" ]]; then
        echo 'error: Checksum failed! Please check your network or try again.'
        exit 0
    fi
}

download_geosite() {
    echo "Starting Download GEOSITE: ${DOWNLOAD_LINK_GEOSITE}"
    if ! curl --progress-bar -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.new" "$DOWNLOAD_LINK_GEOSITE"; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 0
    fi
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOSITE.sha256sum"; then
        echo 'error: Download failed! Please check your network or try again.'
        exit 0
    fi
    SUM="$(sha256sum ${TEMPDIR}/geosite.dat.new | sed 's/ .*//')"
    CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geosite.dat.sha256sum.new)"
    if [[ "$SUM" != "$CHECKSUM" ]]; then
        echo 'error: Checksum failed! Please check your network or try again.'
        exit 0
    fi
}

rename_new() {
    for DAT in 'geoip' 'geosite'; do
        mv "${TEMPDIR}/$DAT.dat.new" "${WORKDIR}/data/$DAT.dat"
        # rm "${TEMPDIR}/$DAT.dat.new"
        rm "${TEMPDIR}/$DAT.dat.sha256sum.new"
    done
}

check_data(){
    SAME_FLAG=1
    for DAT in 'geoip' 'geosite'; do
        case $DAT in
            'geoip') REMOTE_SUM=$(curl -L -s -H 'Cache-Control: no-cache' $DOWNLOAD_LINK_GEOIP.sha256sum | sed 's/ .*//')
            ;;
            'geosite') REMOTE_SUM=$(curl -L -s -H 'Cache-Control: no-cache' $DOWNLOAD_LINK_GEOSITE.sha256sum | sed 's/ .*//')
            ;;
        esac
        LOCAL_SUM=$(sha256sum "${WORKDIR}/data/$DAT.dat"| sed 's/ .*//')
        echo
        echo $(echo $DAT | tr 'a-z' 'A-Z'):
        echo -e "  REMOTE_SUM: "$REMOTE_SUM
        echo -e "   LOCAL_SUM: "$LOCAL_SUM
        if [[ $REMOTE_SUM != $LOCAL_SUM ]]; then
            SAME_FLAG=0
            break;
        fi
    done
    if [[ $SAME_FLAG != 1 ]]; then
        # echo "do download stuff..."
        download_geoip
        download_geosite
        rename_new
    else
        echo
        echo "Local data already latest version"
    fi
}

main(){
    check_data
}

main

echo "Cleaning up..."
rm -r "$TEMPDIR"
exit 0
