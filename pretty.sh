#!/usr/bin/env bash

if [ $# -lt 1 ]; then                                   # daca s-a dat mai putin de 1 argument, lt = less than, $# = nr argumente
    echo "Usage: $0 input.html [output.html]" >&2       # trimite mesajul ca eroare, $0 = pretty.sh
    exit 1                                              
fi

INPUT="$1"                      # INPUT = primul argument = input.html
OUT="${2:-/dev/stdout}"         # OUT = al doile argument (daca exista), /dev/stdout = iesirea standard (terminalul)

if [ ! -f "$INPUT" ]; then                      # daca fisierul INPUT  nu exista
    echo "File not found: $INPUT" >&2           
    exit 2                                      
fi

indent=0        # nivel de identare

self_closing_tags="area base br col embed hr img input link meta param source track wbr"

while IFS= read -r line; do              # var line = fiecare linie (IFS = pastreaza spatiile) 

    # mapfile = comanda bash - citeste mai multe linii si le pune intr-un array
    # -t elimina newline
    # pune in array ul parts tagurile si textul dintre ele
    # grep = cauta text folosind regex
    # -o = afiseaza doar ce se potriveste nu toata linia
    # -P = permite expresii regulate mai avansate
    # <<< "$line" = trimite line catre grep
    # || true = in caz ca grep da eroare se continua scriptul

    mapfile -t parts < <(grep -oP "<[^>]+>|[^<]+" <<< "$line" || true)

    for part in "${parts[@]}"; do

        # pastram textul original, doar eliminam spatiile de inceput si sfarsit si newline ul
        trimmed=$(echo "$part" | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')

        if [ -z "$trimmed" ]; then              # daca sirul e gol
            continue
        fi

        if [[ $trimmed == \<* ]]; then          # daca incepe cu <, adica este tag

            first_two="${trimmed:0:2}"
            last_char="${trimmed: -1}"
            last_two="${trimmed: -2}"

            tag_name=$(echo "$trimmed" | sed -E 's/^<\/?([a-zA-Z0-9]+).*$/\1/')         # numele tagului ex: img, p

            # verificam daca tagul e self-closing
            is_self_closing=false
            for t in $self_closing_tags; do
                if [ "$tag_name" = "$t" ]; then
                    is_self_closing=true
                    break
                fi
            done

            # daca e tag de inchidere, scadem indent
            if [ "$first_two" = "</" ]; then
                if [ "$indent" -gt 0 ]; then
                    indent=$((indent-1))
                fi
            fi

            # printam tagul la nivel curent
            printf "%*s%s\n" $((indent*4)) "" "$trimmed"

            # daca e tag de deschidere, creștem indent
            if [ "$first_two" != "</" ] && [ "$is_self_closing" = false ] && [ "$last_char" != "/" ] && [ "$last_two" != " />" ]; then
                indent=$((indent+1))
            fi

        else
            # este text intre taguri - il pastram integral
            if [ -n "$trimmed" ]; then          # -n = non-empty = stringul nu e gol
                printf "%*s%s\n" $(((indent)*4)) "" "$trimmed"
            fi
        fi
    done
done < "$INPUT" > "$OUT"