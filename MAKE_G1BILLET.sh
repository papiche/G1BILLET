#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
# INSTALLER convert et qrencode: sudo apt install imagemagick qrencode
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"
if [ -s "$HOME/.astro/bin/activate" ]; then
    source $HOME/.astro/bin/activate
fi
############################################################################################################################################################
# ${MY_PATH}/G1BILLET_MAKE.sh "nu me ro test" "se cr et" 100 7sn9dKeCNEsHmqm1gMWNREke4YAWtNw8KG1YBSN8CmSh 97968583
############################################################################
export PATH="$HOME/.local/bin:$PATH"

## SEND LOG TO ~/.zen/tmp/_12345.log
exec 2>&1 >> ~/.zen/G1BILLET/tmp/G1BILLETS.log

## LOAD PERSONAL OR DEFAULT STYLES
[[ -d ${MY_PATH}/_images/_/ ]] \
&& IMAGES="_images" \
|| IMAGES="images"

echo "$ME ~~~~~~~~~~~~~~~ @@@@@@ -------"
SECRET1="$1"
echo SECRET1=${SECRET1}
SECRET2="$2"
echo SECRET2=${SECRET2}
MONTANT="$3"
echo MONTANT=${MONTANT}
NOTERIB="$4"
echo NOTERIB=${NOTERIB}
UNIQID="$5"
echo UNIQID=${UNIQID}
STYLE="$6"
echo STYLE=${STYLE}
ASTRONS="$7"
echo ASTRONS=${ASTRONS}
EMAIL="$8"
echo EMAIL=${EMAIL}

if [[ "${SECRET1}" == "" || "$SECRET2" == "" || "$MONTANT" == "" || "$NOTERIB" == "" || "$UNIQID" == "" ]]
then
    echo "ERROR MISSING PARAM"
    exit 1
fi

TAB=(${SECRET1} ${SECRET2})
FULLDICE=${#TAB[@]}

mkdir -p ${MY_PATH}/tmp/g1billet/$UNIQID
BILLETNAME=$(echo ${SECRET1} | sed 's/ /_/g')

IMAGESSTYLE="${IMAGES}/${STYLE}"
[[ ! -d ${MY_PATH}/${IMAGESSTYLE} ]] && IMAGESSTYLE="${IMAGES}/xastro" ## DEFAULT : TOOD CREATE UPlanet Style

# Prepare June logo color
case "$MONTANT" in
    1)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill grey -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    2)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill green -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    5)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill orange -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    10)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill blue -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    20)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill purple -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    50)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill red -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    100)
        convert "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" -fuzz 20% -fill black -opaque '#17b317' "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
    *)
        cp "${MY_PATH}/${IMAGESSTYLE}/fond.jpg" "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"
        ;;
esac

## UPPER RIGHT SIGN (g1.png)
cp "${MY_PATH}/${IMAGESSTYLE}/g1.png" "${MY_PATH}/tmp/g1billet/${UNIQID}/g1.png"

## ♥Box :: ZENCARD or ASTROID

BOTTOM="$(date) :: ♥Box :: _G1BILLET_ :: $(hostname) ::"
XZUID="__________@__________"

## PGP @PASS QRCODE
## NOT G1BILLET v1 : Create EXTRA PGP QR
if [[ "${STYLE:0:1}" != "_" && "${STYLE:0:1}" != "@" && ! "${STYLE}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$  ]]; then

    USALT=$(echo "${SECRET1}" | jq -Rr @uri)
    UPEPPER=$(echo "$SECRET2" | jq -Rr @uri)
    ## SECURED RANDOM salt : pepper GPG SEQUENCE
    s=$(${MY_PATH}/diceware.sh 1 | xargs)
    p=$(${MY_PATH}/diceware.sh 1 | xargs)

    echo "(≖‿‿≖) PGP /?${s}=${USALT}&${p}=${UPEPPER} (PASS=$UNIQID)"
    echo "/?${s}=${USALT}&${p}=${UPEPPER}"  > ${MY_PATH}/tmp/topgp
    echo "/?salt=${USALT}&pepper=${UPEPPER}"  > ${MY_PATH}/tmp/topgp
    cat ${MY_PATH}/tmp/topgp | gpg --symmetric --armor --batch --passphrase "$UNIQID" -o ${MY_PATH}/tmp/gpg.${BILLETNAME}.asc
    rm ${MY_PATH}/tmp/topgp ## CLEANING CACHE

    DISCO="$(cat ${MY_PATH}/tmp/gpg.${BILLETNAME}.asc | tr '-' '~' | tr '\n' '-'  | tr '+' '_' | jq -Rr @uri )"
#    [[ ${STYLE} == "UPlanet" ]] && DISCO="$(cat ${MY_PATH}/tmp/gpg.${BILLETNAME}.asc | tr '-' '&' | tr '\n' '-'  | tr '+' '_' | jq -Rr @uri )" ## & ẑencard = (email/8digit)+4digit ## CALLED FROM VISA.new

    echo "$DISCO"

    ## Put astrologo_nb in QRCode
    cp ${MY_PATH}/${IMAGES}/astrologo_nb.png ${MY_PATH}/tmp/fond.png

    ## MAKE amzqr WITH astro:// LINK
    amzqr -d ${MY_PATH}/tmp \
                -l H \
                -p ${MY_PATH}/tmp/fond.png \
                "$DISCO" \
    || qrencode -s 6 -o "${MY_PATH}/tmp/fond_qrcode.png" "$DISCO"

    ## ADD PLAYER EMAIL
    convert -gravity southeast -pointsize 28 -fill black -draw "text 5,3 \"${EMAIL}\"" ${MY_PATH}/tmp/fond_qrcode.png ${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.ZENCARD.png
    convert ${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.ZENCARD.png -resize 320 ${MY_PATH}/tmp/g1billet/${UNIQID}/320.png

    rm ${MY_PATH}/tmp/gpg.${BILLETNAME}.asc

fi

## TW moa net
TWIMG="TV.png"

# ZENCARD+@ linked to G1BIILET ipns
[[ "${STYLE:0:1}" == "@" ]] \
    && TWIMG="pirate_map.png"

## G1BILLET+ linked to .current PLAYER TW (patch for Linkedin Fred)
[[ "${STYLE:0:1}" == "_" ]] \
    && ASTRONS="" \
    && TWIMG="web_internet.png"

if [[ ${ASTRONS} != "" ]] ; then
    ASTROLINK="${ASTRONS}"
else
    ASTROLINK="https://opencollective.com/uplanet-zero"
    TWIMG="your-own-data-cloud.png"
fi

amzqr "${ASTROLINK}" \
    -l H -p "$MY_PATH/${IMAGES}/${TWIMG}" \
    -c -n QRTWavatar.png \
    -d ${MY_PATH}/tmp/g1billet/${UNIQID}/ \
|| qrencode -s 6 -o "${MY_PATH}/tmp/g1billet/${UNIQID}/QRTWavatar.png" "${ASTROLINK}"

convert ${MY_PATH}/tmp/g1billet/${UNIQID}/QRTWavatar.png \
        -resize 200 ${MY_PATH}/tmp/g1billet/${UNIQID}/TW.${ASTRONS}.png

[[ "${EMAIL}" != ""  ]] && XZUID="${EMAIL}"

        ## ♥Box :: G1BILLET+ :: ZENCARD :: G1(TW)

        # GIBILLET dice > 3 => G1BILLET+
         [[ "${STYLE:0:1}" == "_" ]] \
                && mv ${MY_PATH}/tmp/g1billet/${UNIQID}/TW.${ASTRONS}.png ${MY_PATH}/tmp/g1billet/${UNIQID}/LEFT.png \
                    && BOTTOM="$(date) :: ♥Box :: G1BILLET :: $(hostname) ::"

         [[ "${STYLE:0:1}" != "_" ]] \
                        && mv ${MY_PATH}/tmp/g1billet/${UNIQID}/320.png ${MY_PATH}/tmp/g1billet/${UNIQID}/LEFT.png \
                            && BOTTOM="$(date) :: ♥Box :: ZENCARD :: $(hostname) ::" \
                                    && NOTERIB="${NOTERIB}:ZEN"

        [[ "${STYLE:0:1}" == "x" ]] \
                         && mv ${MY_PATH}/tmp/g1billet/${UNIQID}/TW.${ASTRONS}.png ${MY_PATH}/tmp/g1billet/${UNIQID}/CENTER.png \
                                    && BOTTOM="$(date) :: ♥Box :: ZENCARD+TW :: $(hostname) ::" \
                                    && NOTERIB="${NOTERIB}:ZEN"

        [[ "${STYLE}" == "UPlanet" ]] \
                         && mv ${MY_PATH}/tmp/g1billet/${UNIQID}/TW.${ASTRONS}.png ${MY_PATH}/tmp/g1billet/${UNIQID}/CENTER.png \
                                    && BOTTOM="$(date) :: ♥UPLANET :: MADE-IN-ZEN :: $(hostname) ::" \
                                    && NOTERIB="${NOTERIB}:ZEN"

        if [[ "${STYLE:0:1}" == "@" || "${STYLE}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]] ; then
            #~ ########################## G1Voeu _ G1BILLET  linking ##
                                       ## Astroport.ONE LINKING :: STYLE=EMAIL :: ZENCARD+@
                        # CREATE @PASS (G1G1BILLET+ G1Voeu derivated keys)

                MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
                SRCMAIL=$(cat ~/.zen/game/players/.current/.player 2>/dev/null)
                G1PUB=$(cat ~/.zen/game/players/.current/.g1pub 2>/dev/null)

                #~ ## GET current PLAYER G1PUB
                [[ -d ~/.zen/game/players/${STYLE} ]] \
                    && SRCMAIL=${STYLE} && G1PUB=$(cat ~/.zen/game/players/${STYLE}/.g1pub 2>/dev/null)

                BILLETFULLNAME=$(echo "${SRCMAIL} ${SECRET1} ${SECRET2}" | sed 's/ /_/g') # em@ai.l_dice_words

                #### VOEUX.print.sh G1BILLET+
                echo ~/.zen/Astroport.ONE/tools/VOEUX.print.sh "${BILLETFULLNAME}" "G1BILLET+" "${MOATS}" "${G1PUB}"
                NEWIMAGIC=$(~/.zen/Astroport.ONE/tools/VOEUX.print.sh "${BILLETFULLNAME}" "G1BILLET+" "${MOATS}" "${G1PUB}" | tail -n 1)
                convert ~/.zen/tmp/${MOATS}/START.png -resize 300 ${MY_PATH}/tmp/g1billet/${UNIQID}/LEFT.png

                #~ ## REPLACE fond.jpg WITH moa.jpg from TW "Dession de PLAYER"
                [[ -s ~/.zen/game/players/${SRCMAIL}/moa.jpg ]] \
                    && rm ${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg \
                    && convert ~/.zen/game/players/${SRCMAIL}/moa.jpg  -resize 964x459 -background grey -gravity center -extent 964x459 ${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg

                mv ${MY_PATH}/tmp/g1billet/${UNIQID}/TW.${ASTRONS}.png ${MY_PATH}/tmp/g1billet/${UNIQID}/CENTER.png

                BILLNS=$(ipfs key import ${NOTERIB} -f pem-pkcs8-cleartext ~/.zen/tmp/${MOATS}/G1BILLET+.EXTRA.ipfskey)
                #SIGN & HIDE SECRETS
                #~ NOTERIB="https://ipfs.asycn.io/ipns/$BILLNS"
                XZUID=${SRCMAIL}
                BOTTOM="$(date) :: ♥Box :: ZENCARD+@ :: $(hostname) ::"

            fi

            # ADD ASTROID LINK

# OVERLAY LOGO over FOND (logo.png)
composite -compose Over -dissolve 70% \
"${MY_PATH}/${IMAGESSTYLE}/logo.png" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg" \
"${MY_PATH}/tmp/${BILLETNAME}.jpg"

if [[ "${STYLE:0:1}" != "_" && "${STYLE:0:1}" != "x" && ${MONTANT} != "___" ]]; then
convert -font 'Liberation-Sans' \
-pointsize 40 -fill black -draw 'text 120,50 "'"$XZUID"'"' \
-pointsize 150 -fill black -draw 'text 120,380 "'"$MONTANT"'"' \
-pointsize 20 -fill black -draw 'text 100,85 "'"${NOTERIB}"'"' \
-pointsize 25 -fill black -draw 'text 50,440 "'"$BOTTOM"'"' \
"${MY_PATH}/tmp/${BILLETNAME}.jpg" "${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"
else
convert -font 'Liberation-Sans' \
-pointsize 35 -fill black -draw 'text 120,56 "'"$XZUID"'"' \
-pointsize 22 -fill black -draw 'text 120,85 "'"${NOTERIB}"'"' \
-pointsize 25 -fill grey -draw 'text 50,440 "'"$BOTTOM"'"' \
-pointsize 18 -fill black -annotate 90x90+30+20 "${SECRET1}" \
-pointsize 18 -fill black -annotate 90x90+10+20 "$SECRET2" \
"${MY_PATH}/tmp/${BILLETNAME}.jpg" "${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"
fi

rm -f ${MY_PATH}/tmp/${BILLETNAME}.jpg

## ADD SouthWEST
[[ -s "${MY_PATH}/tmp/g1billet/${UNIQID}/LEFT.png" ]] && \
composite -compose Over -gravity SouthWest -geometry +85+40 \
"${MY_PATH}/tmp/g1billet/${UNIQID}/LEFT.png" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"

## ADD CENTER QRCODE
[[ -s "${MY_PATH}/tmp/g1billet/${UNIQID}/CENTER.png" ]] && \
composite -compose Over -gravity Center -geometry +65+40 \
"${MY_PATH}/tmp/g1billet/${UNIQID}/CENTER.png" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"

# G1PUB QR CODE RIGHT
[[ -s ${HOME}/.zen/Astroport.ONE/images/zenticket.png ]] \
&& amzqr "${NOTERIB}" -l H -p "${HOME}/.zen/Astroport.ONE/images/zenticket.png" -c -n QR.png -d ${MY_PATH}/tmp/g1billet/${UNIQID}/ \
&& convert ${MY_PATH}/tmp/g1billet/${UNIQID}/QR.png -resize 250 ${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.QR.png \
&& rm ${MY_PATH}/tmp/g1billet/${UNIQID}/QR.png \
|| qrencode -s 6 -o "${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.QR.png" "$NOTERIB"

# AJOUT DU G1PUB QRCODE A DROITE DU BILLET
composite -compose Over -gravity SouthEast -geometry +30+40 \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.QR.png" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"

# Add g1.png SIGLE
[[ "${STYLE:0:1}" != "@" && ! "${STYLE}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$  ]] && \
composite -compose Over -dissolve 70% \
"${MY_PATH}/tmp/g1billet/${UNIQID}/g1.png" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg" \
"${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg"

echo "$ME ~~~~~~~~~~~~~~~ @@@@@@ -------"

## BILLET READY in ${MY_PATH}/tmp/g1billet/${UNIQID}/${BILLETNAME}.BILLET.jpg
## NOT TO BE IN FINAL PDF (getting all jpg)
rm "${MY_PATH}/tmp/g1billet/${UNIQID}/fond.jpg"

exit 0

