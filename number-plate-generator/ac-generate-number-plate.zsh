#!/bin/zsh

setopt BRACE_CCL BSD_ECHO EXTENDED_GLOB MULTIBYTE NO_CASE_GLOB NO_CSH_JUNKIE_LOOPS NO_MATCH \
    NUMERIC_GLOB_SORT RC_EXPAND_PARAM RC_QUOTES RCS RE_MATCH_PCRE SHORT_LOOPS

zmodload -i zsh/mathfunc

# args:
# description: Generate new number plate in SKIN_FOLDER
# package: AC Utils
# version: 0.4
# -m/mode=eu (value)           - mode (eu/us/ca/gb/jp)
# -c/country (value)           - country/state; random if omitted
# -p/postfix (value)           - two last letters; KS if omitted (in europe mode)
# -r/prefix (value)            - two first letters; AC if omitted (in europe mode)
# -n/number (value)            - desired number; random if omitted
# -t/text (value)              - text; "[prefix] [number] [postfix]" if omitted
# -f/format=dds (value)        - output format
# --diff-name=Plate_D (value)  - diffuse map name
# --nm-name=Plate_NM (value)   - normal map name
# skin folder (array)

## zsharg (5):
__argv=()ARG_MODE=eu;ARG_FORMAT=dds;ARG_DIFF_NAME=Plate_D;ARG_NM_NAME=Plate_NM;ARGV_SKIN_FOLDER=();arg=$1;while [[ $# > 0 ]];do if [[ ! $__args_skip && ${arg[1]} == "-" ]];then case $arg in
--version);echo -e "ac-generate-number-plate.zsh (AC Utils) 0.4.5\nNo Copyright.\nLicense CC0v1+: CC0 Universal version 1.0 or later.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law.\n\nWritten by x4fab.";exit 0;;
-h|--help);echo -e 'Usage: '${0:t}" [OPTION]... [SKIN_FOLDER]... \nGenerate new number plate in SKIN_FOLDER\n\nMandatory arguments to long options are mandatory for short options too.\n  -m, --mode=VALUE           mode (eu/us/ca/gb/jp); eu if omitted\n  -c, --country=VALUE        country/state; random if omitted\n  -p, --postfix=VALUE        two last letters; KS if omitted (in europe mode)\n  -r, --prefix=VALUE         two first letters; AC if omitted (in europe mode)\n  -n, --number=VALUE         desired number; random if omitted\n  -t, --text=VALUE           text; \"[prefix] [number] [postfix]\" if omitted\n  -f, --format=VALUE         output format; dds if omitted\n      --diff-name=VALUE      diffuse map name; Plate_D if omitted\n      --nm-name=VALUE        normal map name; Plate_NM if omitted\n      --help     display this help and exit\n      --version  output version information and exit";exit 0;;
-m|--mode);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_MODE=$2;shift;;-m*);ARG_MODE=${arg:2};;--mode=*);ARG_MODE=${arg#*=};;
-c|--country);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_COUNTRY=$2;shift;;-c*);ARG_COUNTRY=${arg:2};;--country=*);ARG_COUNTRY=${arg#*=};;
-p|--postfix);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_POSTFIX=$2;shift;;-p*);ARG_POSTFIX=${arg:2};;--postfix=*);ARG_POSTFIX=${arg#*=};;
-r|--prefix);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_PREFIX=$2;shift;;-r*);ARG_PREFIX=${arg:2};;--prefix=*);ARG_PREFIX=${arg#*=};;
-n|--number);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_NUMBER=$2;shift;;-n*);ARG_NUMBER=${arg:2};;--number=*);ARG_NUMBER=${arg#*=};;
-t|--text);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_TEXT=$2;shift;;-t*);ARG_TEXT=${arg:2};;--text=*);ARG_TEXT=${arg#*=};;
-f|--format);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_FORMAT=$2;shift;;-f*);ARG_FORMAT=${arg:2};;--format=*);ARG_FORMAT=${arg#*=};;
-<1-0>|--diff-name);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_DIFF_NAME=$2;shift;;-<1-0>*);ARG_DIFF_NAME=${arg:2};;--diff-name=*);ARG_DIFF_NAME=${arg#*=};;
-<1-0>|--nm-name);if [[ $# == 1 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_NM_NAME=$2;shift;;-<1-0>*);ARG_NM_NAME=${arg:2};;--nm-name=*);ARG_NM_NAME=${arg#*=};;
--);__args_skip=1;;-?*);echo "${0:t}: unknown option -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;;
esac;else __argv+=($arg);fi;shift;arg=$1;done;unset __args_skip;ARGV_SKIN_FOLDER+=( ${__argv[1,-1]} );
## zsharg (end)

SRC_DIR=${0:h}/res

function convert(){
    /bin/convert $@
}

function composite(){
    /bin/composite $@
}

function pos_sum(){
    x1=${1%[-+]*}; x2=${2%[-+]*}
    x=$[ x1 + x2 ]; y=$[ ${1:${#x1}} + ${2:${#x2}} ]
    (( $x >= 0 )) && echo -n "+"; echo -n $x
    (( $y >= 0 )) && echo -n "+"; echo $y
}

function pos_sub(){
    x1=${1%[-+]*}; x2=${2%[-+]*}
    x=$[ x1 - x2 ]; y=$[ ${1:${#x1}} - ${2:${#x2}} ]
    (( $x >= 0 )) && echo -n "+"; echo -n $x
    (( $y >= 0 )) && echo -n "+"; echo $y
}

function random_number(){
    min=$1
    max=$2
    echo $[ (min + rand48() * (1 + max - min))|0 ]
}

CHARACTERS=( {A-Z0-9} )
function random_text(){
    value=
    while [[ $#value < $1 ]]; do
        value="$value${CHARACTERS[ $[ (1 + rand48() * $#CHARACTERS)|0 ] ]}"
    done
    echo $value
}

function fill_zeros(){
    value=$2
    while [[ $#value < $1 ]]; do
        value="0$value"
    done
    echo $value
}

function generate(){
    MODE_FOLDER="$SRC_DIR/background/$ARG_MODE"
    if [[ ! -d $MODE_FOLDER ]]; then
        echo "${0:t}: mode isn't available -- $ARG_MODE" 1>&2
        echo "Available modes:" 1>&2
        for n in $SRC_DIR/background/*(/F); do echo "  ${n:t}" 1>&2; done
        exit 1
    fi

    if [[ -z $ARG_COUNTRY || $ARG_COUNTRY =~ '[*]' ]]; then
        QUERY=${${ARG_COUNTRY:-*}//\*/[a-z-]##}.png
        temp_list=( $MODE_FOLDER/$~QUERY )
        temp_i=$[ (rand48() * $#temp_list + 1)|0 ]
        BACKGROUND=${temp_list[$temp_i]}
    else
        BACKGROUND="$MODE_FOLDER/$ARG_COUNTRY.png"
    fi

    if [[ ! -f $BACKGROUND ]]; then
        echo "${0:t}: country isn't available -- $ARG_COUNTRY" 1>&2
        echo "Available counties:" 1>&2
        for n in $MODE_FOLDER/[a-z-]##.png; do echo "  ${${n:t}:0:-4}" 1>&2; done
        exit 1
    fi

    COUNTRY=${${BACKGROUND:t}:0:-4}
    NM_BACKGROUND="${BACKGROUND:0:-4}_nm.png"
    if [[ ! -f $NM_BACKGROUND ]]; then
        NM_BACKGROUND=$MODE_FOLDER/_nm.png
    fi

     if [[ -z $ARG_TEXT ]]; then
        if [[ -z $ARG_NUMBER ]]; then
            TEXT_NUMBER=$[ (rand48() * 1000)|0 ]
        else
            TEXT_NUMBER=$ARG_NUMBER
        fi

        if [[ $#TEXT_NUMBER == 1 ]]; then
            TEXT_NUMBER="00$TEXT_NUMBER"
        elif [[ $#TEXT_NUMBER == 2 ]]; then
            TEXT_NUMBER="0$TEXT_NUMBER"
        fi
    fi

    BEVEL_LIGHT=203x30
    BEVEL_BLUR=0x5
    BEVEL_CONTRAST=8
    BEVEL_OFFSET=+1+0

    TEXT_COLOR="#473e29"
    TEXT_POS=+0+0
    TEXT_SIZE=210
    TEXT_GRAVITY="center"
    TEXT_LINE_SPACING=0
    FONT="$SRC_DIR/font/default.ttf"

    if [[ ! -z $ARG_TEXT ]]; then
        TEXT=$ARG_TEXT
    fi

    local -a TEXT_COMMANDS
    TEXT_COMMANDS=()
    if [[ $ARG_MODE == "eu" ]]; then
        SIZE=1024x256
        TEXT_SPACING=45
        TEXT_KERNING=-4
        TEXT_POS=+162+14
        TEXT_GRAVITY="west"

        # [[ $COUNTRY == "gb" ]] && FONT_ID="uk"
        [[ -z $ARG_TEXT ]] && TEXT="${ARG_PREFIX:-AC} $( fill_zeros 3 ${ARG_NUMBER:-$( random_number 0 999 )} ) ${ARG_POSTFIX:-KS}"
    elif [[ $ARG_MODE == "gb" ]]; then
        SIZE=512x392
        TEXT_SPACING=140
        TEXT_KERNING=-8
        FONT="$SRC_DIR/font/uk.ttf"
        TEXT_POS=+0+1
        TEXT_LINE_SPACING=49

        [[ -z $ARG_TEXT ]] && TEXT="$( fill_zeros 4 ${ARG_PREFIX:-$( random_text 4 )} )\n$( fill_zeros 3 ${ARG_NUMBER:-$( random_text 3 )} )" ||
            TEXT="${TEXT:0:4}\n${TEXT:4:7}"
    elif [[ $ARG_MODE == "ca" ]]; then
        SIZE=1024x540
        TEXT_COLOR="#041589"
        TEXT_SPACING=140
        TEXT_KERNING=-23
        TEXT_POS=+0+1
        TEXT_SIZE=320

        [[ -z $ARG_TEXT ]] && TEXT="$( fill_zeros 4 ${ARG_PREFIX:-$( random_text 4 )} ) $( fill_zeros 3 ${ARG_NUMBER:-$( random_text 3 )} )"
    elif [[ $ARG_MODE == "us" ]]; then
        SIZE=1024x540
        TEXT_COLOR="#041589"
        TEXT_SPACING=140
        TEXT_KERNING=-23
        TEXT_POS=+0+1
        TEXT_SIZE=240
        FONT="$SRC_DIR/font/usa.ttf"

        [[ -z $ARG_TEXT ]] && TEXT="$( fill_zeros 4 ${ARG_PREFIX:-$( random_text 4 )} ) $( fill_zeros 3 ${ARG_NUMBER:-$( random_text 3 )} )"
    elif [[ $ARG_MODE == "jp" ]]; then
        SIZE=1024x512
        TEXT_COLOR="#31503b"

        tmp_number=$( fill_zeros 4 ${ARG_NUMBER:-$( random_number 0 9999 )})
        tmp_special_dash=false
        if [[ ${tmp_number[1]} != 0 ]]; then
            NUMBER_TEXT="${tmp_number:0:2} ${tmp_number:2:4}"
            tmp_special_dash=true
        elif [[ ${tmp_number[2]} != 0 ]]; then
            NUMBER_TEXT="·${tmp_number[2]} ${tmp_number:2:4}"
        else
            NUMBER_TEXT="·· ·${tmp_number[4]}"
        fi

        HIRAGANA_TEXT=${ARG_PREFIX[1]}
        if [[ -z $HIRAGANA_TEXT ]]; then
            HIRAGANA_VALUES="さすせそたちつてとなにぬねのはひふほまみむめもやゆよらりるろ"
            HIRAGANA_TEXT=${HIRAGANA_VALUES[ $[ (1 + rand48()*$#HIRAGANA_VALUES )|0 ] ]}
        fi

        PREFECTURE_TEXT=${ARG_PREFIX:1}
        if [[ -z $PREFECTURE_TEXT ]]; then
            PREFECTURE_VALUES=( "豊橋" "三河" "秋田" "青森" "八戸" "千葉" "野田" "愛媛" "福井" "福岡" "筑豊" "福島" "岐阜" "飛騨" 
                "群馬" "福山" "広島" "旭川" "函館" "北見" "釧路" "室蘭" "帯広" "札幌" "姫路" "神戸" "水戸" "土浦" "石川" "岩手" "香川" 
                "相模" "湘南" "川崎" "横浜" "高知" "熊本" "京都" "三重" "宮城" "宮崎" "松本" "長野" "奈良" "長岡" "新潟" "大分" "岡山" 
                "和泉" "大阪" "佐賀" "熊谷" "大宮" "所沢" "滋賀" "島根" "浜松" "沼津" "静岡" "徳島" "足立" "多摩" "練馬" "品川" "鳥取" 
                "富山" "庄内" "山形" "山口" "山梨"   )
            PREFECTURE_TEXT=${PREFECTURE_VALUES[ $[ (1 + rand48()*$#PREFECTURE_VALUES )|0 ] ]}
        fi

        VEHICLE_TEXT=${ARG_POSTFIX:-$VEHICLE_GENERATED}
        if [[ -z $VEHICLE_TEXT ]]; then
            VEHICLE_VALUES=( 34 500 580 302 336 330 )
            VEHICLE_TEXT=${VEHICLE_VALUES[ $[ (1 + rand48()*$#VEHICLE_VALUES )|0 ] ]}
            VEHICLE_GENERATED=$VEHICLE_TEXT
        fi

        TEXT_COMMANDS=(
            -font "$SRC_DIR/font/japan.ttf" -pointsize 350
            -kerning 35 -gravity "east"
            -annotate "$( pos_sub +485+96 $BEVEL_OFFSET )" "${NUMBER_TEXT:0:2}"
        )

        TEXT_COMMANDS+=(
            -gravity "west"
            -annotate "$( pos_sub +632+96 $BEVEL_OFFSET )" "${NUMBER_TEXT:3:5}"
        )

        [[ $tmp_special_dash == true ]] && TEXT_COMMANDS+=(
            -gravity "center"
            -annotate "$( pos_sub +78+66 $BEVEL_OFFSET )" "\\-"
        )

        TEXT_COMMANDS+=(
            -font "$SRC_DIR/font/usa.ttf"
            -pointsize 122
            -interword-spacing 35
            -kerning 10 -gravity "northwest"
            -annotate "$( pos_sub +583+35 $BEVEL_OFFSET )" "$VEHICLE_TEXT"
        )

        TEXT_COMMANDS+=(
            -font "$SRC_DIR/font/japan-special.ttf"
            -pointsize 138
            -interword-spacing 35
            -kerning 25 -gravity "northeast"
            -annotate "$( pos_sub +503+9 $BEVEL_OFFSET )" "$PREFECTURE_TEXT"
        )

        TEXT_COMMANDS+=(
            -pointsize 138
            -interword-spacing 35
            -kerning 25 -gravity "center"
            -annotate "$( pos_sub -390+86 $BEVEL_OFFSET )" "$HIRAGANA_TEXT"
        )
    else
        echo "${0:t}: mode parameters missing -- $ARG_MODE" 1>&2
        exit 2
    fi

    [[ $#TEXT_COMMANDS == 0 ]] && TEXT_COMMANDS=(
        -font "$FONT" -pointsize "$TEXT_SIZE"
        -kerning "$TEXT_KERNING" -interword-spacing "$TEXT_SPACING"
        -interline-spacing "$TEXT_LINE_SPACING" -gravity "$TEXT_GRAVITY"
        -annotate "$( pos_sub $TEXT_POS $BEVEL_OFFSET )" "$TEXT"
    )

    [[ ! -z $ARG_DIFF_NAME ]] && convert \( \
            \( \
                -size $SIZE xc:white -fill black \
                $TEXT_COMMANDS \
                -shade $BEVEL_LIGHT \
                -blur $BEVEL_BLUR -level $BEVEL_CONTRAST%,$[ 100 - BEVEL_CONTRAST ]% \
            \) -compose Overlay \
            $BACKGROUND -composite \
        \) -compose Over  \
        \( \
            xc:transparent -fill $TEXT_COLOR \
            $TEXT_COMMANDS \
        \) -geometry $BEVEL_OFFSET -composite \
        -alpha Off $1/$ARG_DIFF_NAME.$ARG_FORMAT

    local -a TEXT_COMMANDS_X2
    TEXT_COMMANDS_X2=()

    local multiplyNext
    for n in $TEXT_COMMANDS; do
        if [[ $multiplyNext == 1 ]]; then
            TEXT_COMMANDS_X2+=( $[ n*2 ] )
            multiplyNext=0
        elif [[ $multiplyNext == 2 ]]; then
            TEXT_COMMANDS_X2+=( $( pos_sum $n $n ) )
            multiplyNext=0
        else
            TEXT_COMMANDS_X2+=( $n )

            if [[ $n == "-pointsize" || 
                    $n == "-kerning" || 
                    $n == "-interword-spacing" || 
                    $n == "-interline-spacing" ]]; then
                multiplyNext=1
            elif [[ $n == "-annotate" ]]; then
                multiplyNext=2
            fi
        fi
    done

    [[ ! -z $ARG_NM_NAME ]] && convert $NM_BACKGROUND \
        \( \
            \( \
                -alpha Off \( \
                    \( \
                        -size $SIZE xc:black -fill white \
                        $TEXT_COMMANDS \
                        -gamma 2 +level 0,1000 -white-threshold 999 \
                        -morphology Distance Chebyshev:1,1000  \
                        -shade 180x30 -auto-level \
                    \) \( \
                        xc:black -fill white \
                        $TEXT_COMMANDS \
                        -gamma 2 +level 0,1000 -white-threshold 999 \
                        -morphology Distance Chebyshev:1,1000 \
                        -shade 90x30 -auto-level \
                    \) -background "#0000ff" \
                    -channel RG -combine \
                \) \
                \( \
                    +clone -blur 14x10 \
                        -channel r -level 40%,60% +level 45%,55% +channel \
                        -channel g -level 40%,60% +level 45%,55% +channel \
                \) \
                -compose Overlay -composite \
            \) \
            \( \
                -size $SIZE xc:"#8080ff" \( \
                    -size $SIZE xc:black -fill white -resize 200% \
                    $TEXT_COMMANDS_X2 \
                    -gamma 2 +level 0,1000 -white-threshold 999 \
                    -morphology Distance Euclidean:1,1000 -auto-level \
                    -threshold 6% -resize 50% \
                \) \
                -alpha Off -compose CopyOpacity -composite \
            \) -compose Over -composite \
        \) -compose Overlay -composite \
        -alpha Off $1/$ARG_NM_NAME.$ARG_FORMAT
}

for n in $ARGV_SKIN_FOLDER; do
    generate $n
done

exit 0
