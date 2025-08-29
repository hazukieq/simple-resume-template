#!/bin/bash

######## EXECUTE PART ########
# $# arguments
# $? last cmd executed result
# $@ get all args in array form
# $* get all args in string form
NAME=template
TEXFILE=$NAME.tex
TARGET=附件索引页.tex
TMPFILE=tmp.txt
SORTFILE=tmp_sorted.txt
BAKFILE=$NAME.tex.bak
ARCHIVEFILE=附件汇总清单.csv
function mainDo(){
    echo "">"$TMPFILE"
    echo "">"$ARCHIVEFILE"

    cat "$TEXFILE"|grep -v "%.*"|grep "\.*pic{.*}{.*}{.*}"|sed "s/\s*//g"|sed -r "s/\\\.*pic\{.*\}\{(.*)\}\{(.*)\}/\2 \\\item\\\litem\{\1\}\{\2\}/g">>"$TMPFILE"
    cat "$TEXFILE"|grep -v "%.*"|grep "\.*pic{.*}{.*}{.*}"|sed "s/\s*//g"|sed -r "s/\\\.*pic\{.*\}\{(.*)\}\{(.*)\}/\1, \2/g">>"$ARCHIVEFILE"
    
    sed -i '/^[[:space:]]*$/d' "$TMPFILE"
    sed -i '/^[[:space:]]*$/d' "$ARCHIVEFILE"
}

function itemsRsort(){
    #逆序,最迟年份排在前面
    sort -t ',' -k 2,2 "$ARCHIVEFILE" -o "$ARCHIVEFILE"
    sort -t ' ' -k 1,1r "$TMPFILE"|sed 's/.*\s//g' >"$SORTFILE"
    
    sed -i "\$a \\\\\begin\{pitem\}" "$SORTFILE"
    sed -i "1i \\\\\end\{pitem\}" "$SORTFILE"
}

function itemsSort(){
    sort -t ',' -k 2,2r "$ARCHIVEFILE" -o "$ARCHIVEFILE"
    sort -t ' ' -k 1,1 "$TMPFILE"|sed 's/.*\s//g' >"$SORTFILE"

    sed -i "\$a \\\\\begin\{pitem\}" "$SORTFILE"
    sed -i "1i \\\\\end\{pitem\}" "$SORTFILE"
}

function itemsNsort(){
    tac "$TMPFILE"|while read -r line;do
	echo "$line"|sed 's/.*\s//g' >> "$SORTFILE"
    done

    sed -i "\$a \\\\\begin\{pitem\}" "$SORTFILE"
    sed -i "1i \\\\\end\{pitem\}" "$SORTFILE"
}

function clearInserts(){
    sed -i -n '/^%/p' "$TARGET"
}

function deleteInserteds(){
    cp "$TEXFILE" "$BAKFILE"
}

function cleanAlls(){
    rm "$TMPFILE"
    rm "$SORTFILE"
}
key="-v"
function chainExecute(){
    deleteInserteds
    mainDo
    if [[ "$key" == "-r" ]];then
	itemsRsort
    elif [[ "$key" == "-v" ]];then
	itemsSort
    else
	itemsNsort
    fi

    tac "$SORTFILE">>"$TARGET"
    cleanAlls
}

function updateConst(){
    BAKFILE="$1.bak"
    TEXFILE="$1"
    TARGET="$2"
    echo "input: $TEXFILE"
    echo "output: $TARGET"
}

if [[ $# -eq 2 ]];then
    updateConst "$1" "$2"
    clearInserts
    chainExecute
elif [[ $# -eq 3 ]];then
    if [[ "$3" == "-d" ]];then
	echo "deleteInserteds.."
	clearInserts
	deleteInserteds
    elif [[ "$3" == "-r" ]];then
	key="$3"
	echo "do reverse sort..."
	updateConst "$1" "$2"
	clearInserts
	chainExecute
    elif [[ "$3" == "-n" ]];then
	key=""
	echo "do not sort,just insert by raw..."
	updateConst "$1" "$2"
	clearInserts
	chainExecute
    fi
fi
######## EXECUTE PART ########
