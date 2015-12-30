#!/bin/zsh

setopt BRACE_CCL BSD_ECHO EXTENDED_GLOB MULTIBYTE NO_CASE_GLOB NO_CSH_JUNKIE_LOOPS NO_MATCH \
    NUMERIC_GLOB_SORT RC_EXPAND_PARAM RC_QUOTES RCS RE_MATCH_PCRE SHORT_LOOPS

zmodload -i zsh/mathfunc

# args:
# description: Generate new number plate in SKIN_FOLDER
# -t/text (value)       - text; "[prefix] [number] [postfix]" if omitted
# -n/number (value)     - desired number; random if omitted
# -p/postfix=KS (value) - two last letters
# -r/prefix=AC (value)  - two first letters
# -c/country (value)    - country; random if omitted
# skin folder (array)

## zsharg (251):
__argv=()ARG_POSTFIX=KS;ARG_PREFIX=AC;ARGV_SKIN_FOLDER=();arg=$1;while [[ $# > 0 ]];do if [[ ! $__args_skip && ${arg[1]} == "-" ]];then case $arg in
--version);echo -e "ac-generate-number-plate.zsh 0.0.251\nNo Copyright.\nLicense CC0v1+: CC0 Universal version 1.0 or later.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law.\n\nWritten by x4fab.";exit 0;;
-h|--help);echo -e 'Usage: '${0:t}" [OPTION]... [SKIN_FOLDER]... \nGenerate new number plate in SKIN_FOLDER\n\nMandatory arguments to long options are mandatory for short options too.\n  -t, --text=VALUE           text; \"[prefix] [number] [postfix]\" if omitted\n  -n, --number=VALUE         desired number; random if omitted\n  -p, --postfix=VALUE        two last letters; KS if omitted\n  -r, --prefix=VALUE         two first letters; AC if omitted\n  -c, --country=VALUE        country; random if omitted\n      --help     display this help and exit\n      --version  output version information and exit";exit 0;;
-t|--text);if [[ $# == 0 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_TEXT=$1;shift;;-t*);ARG_TEXT=${arg:2};;--text=*);ARG_TEXT=${arg:6};;
-n|--number);if [[ $# == 0 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_NUMBER=$1;shift;;-n*);ARG_NUMBER=${arg:2};;--number=*);ARG_NUMBER=${arg:6};;
-p|--postfix);if [[ $# == 0 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_POSTFIX=$1;shift;;-p*);ARG_POSTFIX=${arg:2};;--postfix=*);ARG_POSTFIX=${arg:6};;
-r|--prefix);if [[ $# == 0 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_PREFIX=$1;shift;;-r*);ARG_PREFIX=${arg:2};;--prefix=*);ARG_PREFIX=${arg:6};;
-c|--country);if [[ $# == 0 ]];then;echo "${0:t}: option requires an argument -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;fi;ARG_COUNTRY=$1;shift;;-c*);ARG_COUNTRY=${arg:2};;--country=*);ARG_COUNTRY=${arg:6};;
--);__args_skip=1;;-?*);echo "${0:t}: unknown option -- ${arg/(-|)-/}" 1>&2;echo "Try '${0:t} --help' for more information." 1>&2;exit 1;;
esac;else __argv+=($arg);fi;shift;arg=$1;done;unset __args_skip;ARGV_SKIN_FOLDER+=( ${__argv[1,-1]} );
## zsharg (end)

SRC_DIR=${0:h}/src

function convert(){
    /bin/convert $@
}

function composite(){
    /bin/composite $@
}

function pos_sum(){
    x1=${1%[-+]*}; x2=${2%[-+]*}
    x=$[ x1 + x2 ]; y=$[ ${1:${#x1}} + ${2:${#x2}} ]
    (( $x > 0 )) && echo -n "+"; echo -n $x
    (( $y > 0 )) && echo -n "+"; echo $y
}

function pos_sub(){
    x1=${1%[-+]*}; x2=${2%[-+]*}
    x=$[ x1 - x2 ]; y=$[ ${1:${#x1}} - ${2:${#x2}} ]
    (( $x > 0 )) && echo -n "+"; echo -n $x
    (( $y > 0 )) && echo -n "+"; echo $y
}

function generate(){
    if [[ -z $ARG_COUNTRY ]]; then
        temp_list=( $SRC_DIR/country/*.png )
        temp_i=$[ (rand48() * $#temp_list + 1)|0 ]
        BACKGROUND=${temp_list[$temp_i]}
    else
        BACKGROUND="$SRC_DIR/country/$ARG_COUNTRY.png"
    fi

    SIZE=1024x256
    FONT="$SRC_DIR/LicensePlate.ttf"

    if [[ ! -f $BACKGROUND ]]; then
        echo "${0:t}: country isn't available -- $ARG_COUNTRY" 1>&2
        echo "Available counties:" 1>&2
        for n in $SRC_DIR/country/*.png; do echo "  ${${n:t}:0:-4}" 1>&2; done
        exit 1
    fi

    NM_BACKGROUND="$SRC_DIR/nm_background.png"

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

        TEXT="$ARG_PREFIX $TEXT_NUMBER $ARG_POSTFIX"
    else
        TEXT=$ARG_TEXT
    fi

    TEXT_COLOR="#473e29"
    TEXT_SPACING=45
    TEXT_KERNING=-4
    TEXT_POS=+162+215
    TEXT_SIZE=210

    BEVEL_LIGHT=203x30
    BEVEL_BLUR=0x5
    BEVEL_CONTRAST=8
    BEVEL_OFFSET=+1+0

    _TEXT_POS=$( pos_sub $TEXT_POS $BEVEL_OFFSET ) 
    convert \( \
            \( \
                -size $SIZE xc:white \
                -font $FONT -pointsize $TEXT_SIZE -fill black \
                -kerning $TEXT_KERNING -interword-spacing $TEXT_SPACING \
                -annotate $_TEXT_POS $TEXT \
                -shade $BEVEL_LIGHT \
                -blur $BEVEL_BLUR -level $BEVEL_CONTRAST%,$[ 100 - BEVEL_CONTRAST ]% \
            \) -compose Overlay \
            $BACKGROUND -composite \
        \) -compose Over  \
        \( \
            xc:transparent -fill $TEXT_COLOR -annotate $_TEXT_POS $TEXT \
        \) -geometry $BEVEL_OFFSET -composite \
        -alpha Off $1/Plate_D.dds

    convert $NM_BACKGROUND \
        \( \
            \( \
                -alpha Off \( \
                    \( \
                        -size $SIZE xc:black \
                        -font $FONT -pointsize $TEXT_SIZE -fill white \
                        -kerning $TEXT_KERNING -interword-spacing $TEXT_SPACING \
                        -annotate $_TEXT_POS $TEXT \
                        -gamma 2 +level 0,1000 -white-threshold 999 \
                        -morphology Distance Chebyshev:1,1000  \
                        -shade 180x30 -auto-level \
                    \) \( \
                        xc:black -fill white \
                        -annotate $_TEXT_POS $TEXT \
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
                    -size $SIZE xc:black -resize 200% -pointsize $[TEXT_SIZE*2] \
                    -kerning $[TEXT_KERNING*2] -interword-spacing $[TEXT_SPACING*2] \
                    -fill white -annotate $( pos_sum $_TEXT_POS $_TEXT_POS ) $TEXT \
                    -gamma 2 +level 0,1000 -white-threshold 999 \
                    -morphology Distance Euclidean:1,1000 -auto-level \
                    -threshold 6% -resize 50% \
                \) \
                -alpha Off -compose CopyOpacity -composite \
            \) -compose Over -composite \
        \) -compose Overlay -composite \
        -alpha Off $1/Plate_NM.dds
}

for n in $ARGV_SKIN_FOLDER; do
    generate $n
done
