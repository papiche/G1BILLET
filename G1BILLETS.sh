#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 1.0
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

## LOAD PERSONAL OR DEFAULT STYLES
[[ -d ${MY_PATH}/_images/_/ ]] \
&& IMAGES="_images" \
|| IMAGES="images"

################################################################################
# Create different king of G1BILLET(s) with $MONTANT DU or TW IPNS + ZENCARD
# ${MY_PATH}/G1BILLETS.sh 5 ticket 2 # MONTANT # STYLE # SECURITE
################################################################################
MONTANT="$1"

### COMMAND LINE MODE (DAEMON IS CALLING ITSELF) ###
if [[ $MONTANT != "daemon" ]]; then

    pidportinuse=$(lsof -i :33102 | tail -n 1 | awk '{print $2}')
    [[ $pidportinuse ]] && kill $pidportinuse && echo "KILLING NOT COLLECTED THREAD $pidportinuse"

    [[ $MONTANT == "" || $MONTANT == "0" ]] && MONTANT="___"

    STYLE="$2"

    DICE="$3"

    SECRET1="$4"
    SECRET2="$5"

    [[ $DICE != ?(-)+([0-9]) ]] && DICE=$(cat $MY_PATH/DICE 2>/dev/null) ## HOW MANY WORDS SECRETS
    [[ $DICE != ?(-)+([0-9]) ]] && DICE=4

    echo "G1BILLET FACTORY MONTANT=$MONTANT DICE=$DICE"
    echo "$STYLE : $MY_PATH/${IMAGES}/$STYLE"

        ## CHECK IF STYLE IS EMAIL => ZENCARD+@ IPFS G1BILLET
        if [[ "${STYLE}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then

            echo "ASTROPORT $STYLE :: ZENCARD+@"
            # echo "PLAYER : $STYLE"
            EMAIL=${STYLE}
            DICE=5

            ## DEFAULT xZSTYLE
            LASTX=$(ls -d ${MY_PATH}/${IMAGES}/x* | tail -n 1)
            STYLE="$(echo ${LASTX} | rev | cut -d '/' -f 1 | rev)"

        fi

    ## STYLE SELECTED: PDF DE 6 BILLETS OR SINGLE
    [[ "${STYLE:0:1}" != "_"  ]] && NBbillets=1 && MONTANT="___" ## NOT DEFAULT (empty or _ style)
    [[ ${STYLE} == "" || ${STYLE} == "_" ]] && NBbillets=6 && STYLE="_" # 6 x G1BILLET v1 = "MLC"

    echo "G1BILLET MAKE $NBbillets - ${STYLE} (${DICE}) - "

    # CHECK IF $STYLE IMAGES EXIST
    IMAGESSTYLE="${IMAGES}/${STYLE}"
    [[ ${STYLE} == "UPlanet" ]] && STYLE="xastro" ## DEFAULT : UPlanet Style
    [[ ! -f ${MY_PATH}/${IMAGES}/${STYLE}/g1.png ]] && ERROR="MISSING ./${IMAGES}/${STYLE}/g1.png - EXIT" && echo $ERROR && exit 1
    [[ ! -f ${MY_PATH}/${IMAGES}/${STYLE}/fond.jpg ]] && ERROR="MISSING ./${IMAGES}/${STYLE}/fond.jpg- EXIT" && echo $ERROR && exit 1
    [[ ! -f ${MY_PATH}/${IMAGES}/${STYLE}/logo.png ]] && ERROR="MISSING ./${IMAGES}/${STYLE}/logo.png- EXIT" && echo $ERROR && exit 1

    # CREATION DE $NBbillets BILLETS DE $MONTANT DU
    boucle=0;
    while [ $boucle -lt $NBbillets ]
    do
        ## THIS IS THE PASS for ZENCARD
        if [[ ${boucle} == 0 ]]; then
            UNIQID=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-5)
            [ $DICE -gt 4 ] && UNIQID=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-7)
            [ $DICE -gt 6 ] && UNIQID=$(${MY_PATH}/diceware.sh 1 | xargs)$(echo "${RANDOM}${RANDOM}" | tail -c-7)
            mkdir -p "${MY_PATH}/tmp/g1billet/${UNIQID}"
        fi
        boucle=$((boucle+1))

        ## ADAPT SECURITY LEVEL
        [[ ${SECRET1} == "" || $boucle -gt 1 ]] && SECRET1="${UNIQID} $(${MY_PATH}/diceware.sh $DICE | xargs)"
        [[ ${SECRET2} == "" || $boucle -gt 1 ]] && SECRET2=$(${MY_PATH}/diceware.sh $DICE | xargs)
        echo "${SECRET1}" "${SECRET2}"
        # CREATION CLEF BILLET
        BILLETPUBKEY=$(python3 ${MY_PATH}/key_create_dunikey.py "${SECRET1}" "${SECRET2}")
        rm -f /tmp/secret.dunikey
        echo "$boucle : $BILLETPUBKEY "

        if [[ $DICE -ge 4 || "${STYLE:0:1}" != "_" ]]; then
            # + ASTRONS ## G1BILLET APP STICKER
            ASTRONS=$(${MY_PATH}/keygen -t ipfs "${SECRET1}" "${SECRET2}")
            echo "/ipns/$ASTRONS" # 12D3Koo style - QRCODE ipfs2g1 verify
        fi
        #######################################################################################################
        # CREATION FICHIER IMAGE BILLET dans ${MY_PATH}/tmp/g1billet/${UNIQID}
        #######################################################################################################
        echo ${MY_PATH}/MAKE_G1BILLET.sh '"'${SECRET1}'"' '"'${SECRET2}'"' "${MONTANT}" "${BILLETPUBKEY}" "${UNIQID}" "${STYLE}" "${ASTRONS}" "${EMAIL}"
        ${MY_PATH}/MAKE_G1BILLET.sh "${SECRET1}" "${SECRET2}" "${MONTANT}" "${BILLETPUBKEY}" "${UNIQID}" "${STYLE}" "${ASTRONS}" "${EMAIL}"
        #######################################################################################################
        #######################################################################################################

    done

    if [[ ${NBbillets} == 1 ]]; then

        # ONE FILE ONLY
        cp ${MY_PATH}/tmp/g1billet/${UNIQID}/*.jpg ${MY_PATH}/tmp/g1billet/${UNIQID}.jpg

        # CLEANING TEMP FILES
        echo rm -Rf ${MY_PATH}/tmp/g1billet/${UNIQID}

        # ALLOWS ANY USER TO DELETE
        chmod 777 ${MY_PATH}/tmp/g1billet/${UNIQID}.jpg
        export ZFILE="${MY_PATH}/tmp/g1billet/${UNIQID}.jpg"

    else

        # MONTAGE DES IMAGES DES BILLETS VERS ${MY_PATH}/tmp/g1billet/${UNIQID}.pdf
        montage ${MY_PATH}/tmp/g1billet/${UNIQID}/*.jpg -tile 2x3 -geometry 964x459 ${MY_PATH}/tmp/g1billet/${UNIQID}.pdf
        # NB!! if "not autorized" then edit /etc/ImageMagick-6/policy.xml and comment
        [[ ! -s ${MY_PATH}/tmp/g1billet/${UNIQID}.pdf ]] && echo "ERROR PDF NOT FOUND - contact - support@qo-op.com" && exit 1
        # <!-- <policy domain="coder" rights="none" pattern="PDF" /> -->

        # CLEANING TEMP FILES
        rm -Rf ${MY_PATH}/tmp/g1billet/${UNIQID}

        # ALLOWS ANY USER TO DELETE
        chmod 777 ${MY_PATH}/tmp/g1billet/${UNIQID}.pdf
        export ZFILE="${MY_PATH}/tmp/g1billet/${UNIQID}.pdf"

    fi

    ###########################################################################
    [[ $XDG_SESSION_TYPE == 'x11' ]] && xdg-open "$ZFILE"
    ###########################################################################
    echo "$ZFILE" # IMPORTANT ## LAST LINE : INFORM DAEMON
    ###########################################################################

else
    ################################################################################
    ################################################################################
    ## MAKE IT A NETWORK MICRO SERVICE -- PORTS : INPUT=33101 OUTPUT=33102
    ############## CLEAN START DAEMON MODE ###
    pidportinuse=$(lsof -i :33101 | tail -n 1 | awk '{print $2}')
    [[ $pidportinuse ]] && echo "KILLING OLD DEAMON 33101 $pidportinuse" && kill -9 $pidportinuse && killall G1BILLETS.sh && exit 1

    pidportinuse=$(lsof -i :33102 | head -n 1 | awk '{print $2}')
    [[ $pidportinuse ]] && kill $pidportinuse && echo "KILLING NOT COLLECTED THREAD $pidportinuse"
    #####################################################################
    myIP=$(hostname -I | awk '{print $1}' | head -n 1)
    isLAN=$(route -n |awk '$1 == "0.0.0.0" {print $2}' | grep -E "/(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])/")
    isBOX=$(cat ${MY_PATH}/♥Box)

    ## WHERE DO CLIENT WILL GET FILE
    if [[ $isLAN ]]; then
        HNAME="http://g1billet.localhost"
    else
        HNAME="http://$(hostname -I | awk '{print $1}' | head -n 1)"
    fi
    RNAME="$HNAME:33102"
    [[ $isBOX != "" ]] && RNAME="$isBOX"

    ## DEFINE RESPONSE LINK
    [[ -s $MY_PATH/.env ]] && source $MY_PATH/.env

    ## AVAILABLE STYLES : CREATING SELECT
    sytle=($(find ${MY_PATH}/${IMAGES}/* -type d | sort | rev | cut -d '/' -f 1 | rev))
    sytlenb=${#sytle[@]}
    OPT=""
    for stname in ${sytle[@]}; do

        pre=${stname:0:1}

        if [[ $pre == "_" ]]; then
            OPT="${OPT}<option value='_'>:: G1BILLET :: (+) ::</option>"
        elif [[ $pre == "x" ]]; then
            OPT="${OPT}<option value='${stname}'>:: ZENCARD+TW :: ${stname} ::</option>"
        elif [[ $(echo ${stname} | grep '@') && -s ~/.zen/Astroport.ONE/tools/VOEUX.print.sh ]]; then
            OPT="${OPT}<option value='${stname}'>:: ZENCARD+@ :: ${stname} ::</option>"
        else
            OPT="${OPT}<option value='${stname}'>:: ZENCARD :: ${stname} ::</option>"
        fi

    done

    ## WELCOME HTTP / HTML PAGE
    HTTPWELLCOME='HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html><html>
<head>
    <meta charset="UTF-8">
    <title>[G1BILLET] HTTP MICRO SERVICE - 33101 - 33102 -</title>
    <meta http-equiv="refresh" content="30; url='$RNAME'" />
    <style>
        #countdown { display: flex; justify-content: center; align-items: center; color: #0e2c4c; font-size: 20px; width: 60px; height: 60px; background-color: #e7d9fc; border-radius: 50%;}
    </style>
</head>
<body>
    <center><h1><a href="'$RNAME'">(♥‿‿♥)</a>.</h1></center>
    <center><div id="countdown"></div></center>
    <script>
    var timeLeft = 30;
var elem = document.getElementById("countdown");
var timerId = setInterval(countdown, 1000);

function countdown() {
    if (timeLeft == -1) {
        clearTimeout(timerId);
        doSomething();
    } else {
        elem.innerHTML = timeLeft + " s";
        timeLeft--;
    }
}
</script>
<center>
<form method="get">
  <br>

  <label for="montant">Montant :</label>
  <select name="montant">
    <option value="0">_</option>
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="5">5</option>
    <option value="10">10</option>
    <option value="20">20</option>
    <option value="50">50</option>
    <option value="100">100</option>
  </select>

  <label for="type">Type :</label>
  <select name="type">
  <option value=''></option>
    '${OPT}'
  </select>

    <label for="dice">Dice :</label>
  <select name="dice">
    <option value="1">1</option>
    <option value="2">2</option>
    <option value="3">3</option>
    <option value="4" selected>4</option>
    <option value="5">5</option>
    <option value="6">6</option>
    <option value="7">7</option>
  </select>
  <br>      <br>
  <button type="submit">Lancer Fabrication</button>
</form>
</center>
</body></html>'

    function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

        #### LOG REDIRECTION
        echo "=================================================="
        echo "G1BILLET x 6   :   $HNAME:33101"
        echo "G1BILLET+ x 6   :   $HNAME:33101/?montant=0&style=_&dice=4"
        echo "ZENCARD    :   $HNAME:33101/?montant=10&style=saubole"
        echo "ZENCARD+TW  :   $HNAME:33101/?montant=0&style=astro${RANDOM}@yopmail.com"
        echo "=================================================="
        echo "LOG  :  tail -f ${MY_PATH}/tmp/G1BILLETS.log"
        echo "=================================================="
        mkdir -p ${MY_PATH}/tmp
        exec 2>&1 >> ${MY_PATH}/tmp/G1BILLETS.log

#####################################################################
   ########### daemon loop
    #####################################################################
    while true; do
        echo "============= ************ =========================="
        echo " STARTING $ME DAEMON READY $(date)"
        echo "============= ************ =========================="

        REQ=$(echo "$HTTPWELLCOME" | nc -l -p 33101 -q 1) ## # WAIT FOR 33101 PORT CONTACT

        MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
        start=`date +%s`

        URL=$(echo "$REQ" | grep '^GET' | cut -d ' ' -f2  | cut -d '?' -f2)
        HOSTP=$(echo "$REQ" | grep '^Host:' | cut -d ' ' -f2  | cut -d '?' -f2)
        HOST=$(echo "$HOSTP" | cut -d ':' -f 1)

        echo "=================================================="
        echo "$ME RUN $(date)"
        echo "=========== %%%%%%%%%%%%%%% =============="
        echo "$REQ"
        echo "=========== %%%%%%%%%%%%%%% =============="
        echo "$URL"
        echo "=================================================="

        ## DECODING RECEIVED URL
        arr=(${URL//[=&]/ })
        # PARAM (x 3) EXTRACT "&param=value"
            ONE=$(urldecode ${arr[0]} | xargs); TWO=$(urldecode ${arr[2]} | xargs); X=$(urldecode ${arr[4]} | xargs);
            MONTANT=$(urldecode ${arr[1]} | xargs); STYLE=$(urldecode ${arr[3]} | xargs); XPARM=$(urldecode ${arr[5]} | xargs);
            echo "DECODED : $ONE=$MONTANT & $TWO=$STYLE & $X=$XPARM"

            [[ $STYLE == "dice" ]] && STYLE="_" && XPARM=$X ## /?montant=0&type=&dice=1

            # EXECUTE COMMAND
    #####################################################################
            echo  ${MY_PATH}/${ME} '"'$MONTANT'"' '"'$STYLE'"' '"'$XPARM'"'
    #####################################################################
            # EXECUTE COMMAND

            LOG=$(${MY_PATH}/${ME} "$MONTANT" "$STYLE" "$XPARM")
            echo "$LOG"
            # EXTRACT VALUES FROM SELF LOG
            IPNS=$(echo "$LOG" | grep '/ipns/')
            [[ $IPNS ]] && echo "TW IPNS : $IPNS"
            CURL=$(echo "$LOG" | grep -w curl)
            [[ $IPNS ]] && echo "LIEN ACTIVATION : $CURL"
            echo "=========" ## LAST LINE INFORMATION
            ZFILE=$(echo "$LOG" | tail -n 1) ### LAST LINE : INFORM DAEMON
            echo $ZFILE
            echo "========="

    ### AUCUN RESULTAT
    if [[ ! -s $ZFILE ]]; then
                (
                echo "HTTP/1.1 200 OK
Access-Control-Allow-Origin: ${myASTROPORT}
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

<h1>ERROR $ZFILE</h1>" | nc -l -p 33102 -q 1 > /dev/null 2>&1 \
                && rm -f "${MY_PATH}/tmp/http.${MOATS}"
                ) &

    else ## FILE IS FOUND

    # PREPARE FILE SENDING
        FILE_NAME="$(basename "${ZFILE}")"
        EXT="${FILE_NAME##*.}"
        BSIZE=$(du -b "${ZFILE}" | awk '{print $1}' | tail -n 1)

    # KILL OLD 33102 - USE IT IF YOU ( publishing )&
        pidportinuse=$(lsof -i :33102 | tail -n 1 | awk '{print $2}')
        [[ $pidportinuse ]] && kill -9 $pidportinuse && echo "KILLING NOT COLLECTED THREAD $pidportinuse"

    # HTTP/1.1 200 OK
    echo 'HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.G1BILLET
Cache-Control: public
Content-Transfer-Encoding: Binary
Content-Length:'${BSIZE}'
Content-Disposition: attachment; filename='${FILE_NAME}'
' > ${MY_PATH}/tmp/http.${MOATS}

        cat ${ZFILE} >> ${MY_PATH}/tmp/http.${MOATS}

        # NETCAT PUBLISH port=33102
        echo "PUBLISHING ${MOATS} : $RNAME"

        if [[ $XDG_SESSION_TYPE != 'x11' ]]; then
            (
                cat ${MY_PATH}/tmp/http.${MOATS} | nc -l -p 33102 -q 1 > /dev/null 2>&1 \
                && rm -f "${MY_PATH}/tmp/http.${MOATS}" \
                && rm -f "${ZFILE}"  \
                && rm -Rf "${ZFILE%.*}" \
                && echo "G1BILLETS FILE CONSUMED"
            ) &
        else
                rm -f "${MY_PATH}/tmp/http.${MOATS}" \
                && rm -f "${ZFILE}" \
                && rm -Rf "${ZFILE%.*}" \
                && echo "G1BILLETS FILE CONSUMED"
        fi

    end=`date +%s`
    dur=`expr $end - $start`
    echo "G1BILLET GENERATION WAS $dur SECONDS"

    fi

    ## EMPTY YESTERDAY TMP FILES
    find ${MY_PATH}/tmp -mtime +1 -exec rm -Rf '{}' \;

    done
    #####################################################################
    ## loop ###############################################################TITLE="${file%.*}"
    #####################################################################

fi

exit 0
