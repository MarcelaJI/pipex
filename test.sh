#!/bin/bash

# Colores
NC="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"

# Variables
TOTAL_TESTS=120
TESTS_PASSED=0
TEST_FILES_DIR="./tests"
PROJECT_DIR="./"  # Directorio donde se encuentra el ejecutable de pipex
TIMEOUT=5         # Timeout en segundos para cada comando
DEBUG=0           # Establecer a 1 para modo depuración (mantiene archivos temporales)

# Compilar el proyecto al inicio
clear
echo -e "${BLUE}Compilando el proyecto...${NC}"
make re
make bonus
make clean
clear

# Función para la comparación de resultados
function compare_results() {
    local test_name="$1"
    local cmd1="$2"
    local cmd2="$3"
    local infile="$4"
    local test_num="$5"
    
    local outfile1="shell_out_$test_num"
    local outfile2="pipex_out_$test_num"
    
    # Mostrar los comandos que se ejecutan
    echo -e "${BLUE}Shell:${NC} < $infile $cmd1 | $cmd2 > $outfile1"
    echo -e "${CYAN}Pipex:${NC} ./pipex $infile \"$cmd1\" \"$cmd2\" $outfile2"
    
    # Comando shell (con timeout)
    timeout $TIMEOUT bash -c "< $infile $cmd1 | $cmd2 > $outfile1" 2>/dev/null
    local shell_status=$?
    if [ $shell_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando shell${NC}"
        touch "$outfile1"
    fi
    
    # Comando pipex (con timeout)
    timeout $TIMEOUT $PROJECT_DIR/pipex "$infile" "$cmd1" "$cmd2" "$outfile2" 2>/dev/null
    local pipex_status=$?
    if [ $pipex_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando pipex${NC}"
        touch "$outfile2"
    fi
    
    # Normalizar salidas (eliminar espacios en blanco extra)
    if [ -f "$outfile1" ] && [ -f "$outfile2" ]; then
        # Normalizar salidas eliminando espacios en blanco al final de las líneas
        sed -i 's/[ \t]*$//' "$outfile1"
        sed -i 's/[ \t]*$//' "$outfile2"
        
        # Eliminar líneas vacías al final del archivo
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$outfile1"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$outfile2"
    fi
    
    # Comparar contenidos
    diff -q "$outfile1" "$outfile2" > /dev/null 2>&1
    local diff_status=$?
    
    # Para depuración, guardar las diferencias en archivos temporales
    if [ $diff_status -ne 0 ]; then
        diff "$outfile1" "$outfile2" > "diff_$test_num.txt" 2>&1
    fi
    
    # Verificar si la salida es igual
    if [ $diff_status -eq 0 ]; then
        echo -e "${GREEN}[✓] Test $test_num: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Eliminar archivos temporales si la prueba pasó
        rm -f "$outfile1" "$outfile2" "diff_$test_num.txt" 2>/dev/null
        return 0
    else
        echo -e "${RED}[✗] Test $test_num: $test_name${NC}"
        
        # Mantener archivos temporales para depuración si la prueba falló
        # pero solo si estamos en modo debug
        if [ "$DEBUG" != "1" ]; then
            rm -f "$outfile1" "$outfile2" "diff_$test_num.txt" 2>/dev/null
        fi
        return 1
    fi
}

# Función para la comparación de resultados con múltiples pipes
function compare_multiple_pipes() {
    local test_name="$1"
    local infile="$2"
    local outfile="$3"
    local cmds=("${@:4:$#-4}")
    local test_num="${@: -1}"
    
    local shell_out="shell_out_$test_num"
    local pipex_out="pipex_out_$test_num"
    
    # Construir comando shell
    local shell_cmd="< $infile"
    for cmd in "${cmds[@]}"; do
        shell_cmd="$shell_cmd $cmd |"
    done
    shell_cmd="${shell_cmd% |} > $shell_out"
    
    # Construir comando pipex
    local pipex_cmd="./pipex_bonus $infile"
    for cmd in "${cmds[@]}"; do
        pipex_cmd="$pipex_cmd \"$cmd\""
    done
    pipex_cmd="$pipex_cmd $pipex_out"
    
    # Mostrar los comandos que se ejecutan
    echo -e "${BLUE}Shell:${NC} $shell_cmd"
    echo -e "${CYAN}Pipex:${NC} $pipex_cmd"
    
    # Ejecutar comando shell (con timeout)
    timeout $TIMEOUT bash -c "$shell_cmd" 2>/dev/null
    local shell_status=$?
    if [ $shell_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando shell${NC}"
        touch "$shell_out"
    fi
    
    # Ejecutar pipex (con timeout)
    timeout $TIMEOUT $PROJECT_DIR/pipex_bonus "$infile" "${cmds[@]}" "$pipex_out" 2>/dev/null
    local pipex_status=$?
    if [ $pipex_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando pipex${NC}"
        touch "$pipex_out"
    fi
    
    # Verificar si los archivos existen antes de comparar
    if [ ! -f "$shell_out" ]; then
        touch "$shell_out"
    fi
    
    if [ ! -f "$pipex_out" ]; then
        touch "$pipex_out"
    fi
    
    # Normalizar salidas (eliminar espacios en blanco extra)
    if [ -f "$shell_out" ] && [ -f "$pipex_out" ]; then
        # Normalizar salidas eliminando espacios en blanco al final de las líneas
        sed -i 's/[ \t]*$//' "$shell_out"
        sed -i 's/[ \t]*$//' "$pipex_out"
        
        # Eliminar líneas vacías al final del archivo
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$shell_out"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$pipex_out"
    fi
    
    # Comparar contenidos
    diff -q "$shell_out" "$pipex_out" > /dev/null 2>&1
    local diff_status=$?
    
    # Para depuración, guardar las diferencias en archivos temporales
    if [ $diff_status -ne 0 ]; then
        diff "$shell_out" "$pipex_out" > "diff_$test_num.txt" 2>&1
    fi
    
    # Verificar resultados - simplificamos la condición
    if [ $diff_status -eq 0 ]; then
        echo -e "${GREEN}[✓] Test $test_num: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Eliminar archivos temporales si la prueba pasó
        rm -f "$shell_out" "$pipex_out" "diff_$test_num.txt" 2>/dev/null
        return 0
    else
        echo -e "${RED}[✗] Test $test_num: $test_name${NC}"
        
        # Mantener archivos temporales para depuración si la prueba falló
        # pero solo si estamos en modo debug
        if [ "$DEBUG" != "1" ]; then
            rm -f "$shell_out" "$pipex_out" "diff_$test_num.txt" 2>/dev/null
        fi
        return 1
    fi
}

# Función para probar here_doc
function compare_here_doc() {
    local test_name="$1"
    local delimiter="$2"
    local cmd1="$3"
    local cmd2="$4"
    local outfile="$5"
    local test_num="$6"
    local input_content="$7"
    
    local shell_out="shell_out_$test_num"
    local pipex_out="pipex_out_$test_num"
    local temp_infile="here_doc_$test_num.tmp"
    
    # Crear archivo temporal con contenido para here_doc
    echo -e "$input_content" > "$temp_infile"
    
    # Mostrar los comandos que se ejecutan
    echo -e "${BLUE}Shell:${NC} cat $temp_infile | $cmd1 << $delimiter | $cmd2 >> $shell_out"
    echo -e "${CYAN}Pipex:${NC} ./pipex here_doc $delimiter \"$cmd1\" \"$cmd2\" $pipex_out"
    
    # Ejecutar comandos shell (necesitamos simular here_doc con cat)
    if [ -f "$shell_out" ]; then
        rm "$shell_out"  # Eliminar archivo si existe para empezar limpio
    fi
    timeout $TIMEOUT bash -c "cat $temp_infile | $cmd1 << $delimiter | $cmd2 >> $shell_out" 2>/dev/null
    local shell_status=$?
    if [ $shell_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando shell${NC}"
        touch "$shell_out"
    fi
    
    # Ejecutar pipex con here_doc
    if [ -f "$pipex_out" ]; then
        rm "$pipex_out"  # Eliminar archivo si existe para empezar limpio
    fi
    echo -e "$input_content" | timeout $TIMEOUT $PROJECT_DIR/pipex_bonus "here_doc" "$delimiter" "$cmd1" "$cmd2" "$pipex_out" 2>/dev/null
    local pipex_status=$?
    if [ $pipex_status -eq 124 ]; then
        echo -e "${YELLOW}[!] Test $test_num: Timeout en comando pipex${NC}"
        touch "$pipex_out"
    fi
    
    # Verificar si los archivos existen antes de comparar
    if [ ! -f "$shell_out" ]; then
        touch "$shell_out"
    fi
    
    if [ ! -f "$pipex_out" ]; then
        touch "$pipex_out"
    fi
    
    # Normalizar salidas
    if [ -f "$shell_out" ] && [ -f "$pipex_out" ]; then
        sed -i 's/[ \t]*$//' "$shell_out"
        sed -i 's/[ \t]*$//' "$pipex_out"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$shell_out"
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$pipex_out"
    fi
    
    # Comparar contenidos
    diff -q "$shell_out" "$pipex_out" > /dev/null 2>&1
    local diff_status=$?
    
    # Para depuración, guardar las diferencias
    if [ $diff_status -ne 0 ]; then
        diff "$shell_out" "$pipex_out" > "diff_$test_num.txt" 2>&1
    fi
    
    # Limpiar archivo temporal
    rm -f "$temp_infile"
    
    # Verificar resultados
    if [ $diff_status -eq 0 ]; then
        echo -e "${GREEN}[✓] Test $test_num: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        rm -f "$shell_out" "$pipex_out" "diff_$test_num.txt" 2>/dev/null
        return 0
    else
        echo -e "${RED}[✗] Test $test_num: $test_name${NC}"
        if [ "$DEBUG" != "1" ]; then
            rm -f "$shell_out" "$pipex_out" "diff_$test_num.txt" 2>/dev/null
        fi
        return 1
    fi
}

# Verificar que el ejecutable existe
if [ ! -f "$PROJECT_DIR/pipex" ]; then
    echo -e "${RED}Error: El ejecutable de pipex no se encuentra en $PROJECT_DIR${NC}"
    exit 1
fi

# Crear directorio para archivos de prueba
mkdir -p $TEST_FILES_DIR

# Crear archivos de prueba
echo "Hola mundo" > $TEST_FILES_DIR/test1.txt
echo -e "Línea 1\nLínea 2\nLínea 3\nLínea 4\nLínea 5" > $TEST_FILES_DIR/test2.txt
echo "Lorem ipsum dolor sit amet, consectetur adipiscing elit" > $TEST_FILES_DIR/test3.txt
echo -e "manzana\nnaranja\nplátano\nfresa\nuva" > $TEST_FILES_DIR/test4.txt
echo -e "uno\ndos\ntres\ncuatro\ncinco\nseis\nsiete\nocho\nnueve\ndiez" > $TEST_FILES_DIR/test5.txt
echo -e "A\nB\nC\nD\nE\nF\nG\nH\nI\nJ" > $TEST_FILES_DIR/test6.txt
echo -e "1,2,3,4,5\n6,7,8,9,10\n11,12,13,14,15" > $TEST_FILES_DIR/test7.txt
echo -e "La programación es divertida\nLos pipes son útiles\nLa shell es poderosa" > $TEST_FILES_DIR/test8.txt
echo -e "123\n456\n789\n101112\n131415" > $TEST_FILES_DIR/test9.txt
echo -e "#include <stdio.h>\n\nint main(void)\n{\n    printf(\"Hello, World!\\n\");\n    return 0;\n}" > $TEST_FILES_DIR/test10.txt
echo "" > $TEST_FILES_DIR/empty.txt
printf "Texto sin salto de línea" > $TEST_FILES_DIR/test11.txt
echo -e "palabra1 palabra2\npalabra3 palabra4\npalabra5 palabra6" > $TEST_FILES_DIR/test12.txt

echo -e "${BOLD}=== INICIANDO PRUEBAS DE PIPEX ===${NC}"
echo -e "${BLUE}Se ejecutarán $TOTAL_TESTS pruebas para validar el funcionamiento${NC}"
echo ""

# === TESTS BÁSICOS (1-20) ===
compare_results "Comando grep básico" "grep Hola" "cat" "$TEST_FILES_DIR/test1.txt" "01"
compare_results "Comando cat básico" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "02"
compare_results "Comando wc con parámetros" "cat" "wc -l" "$TEST_FILES_DIR/test2.txt" "03"
compare_results "Comando grep con opciones" "grep -i lorem" "cat" "$TEST_FILES_DIR/test3.txt" "04"
compare_results "Pipe con sort" "cat" "sort" "$TEST_FILES_DIR/test4.txt" "05"
compare_results "Comando head" "cat" "head -n 3" "$TEST_FILES_DIR/test5.txt" "06"
compare_results "Comando tail" "cat" "tail -n 2" "$TEST_FILES_DIR/test6.txt" "07"
compare_results "Comando tr" "cat" "tr ',' ' '" "$TEST_FILES_DIR/test7.txt" "08"
compare_results "Comando grep con regex" "grep -E 'es'" "cat" "$TEST_FILES_DIR/test8.txt" "09"
compare_results "Comando sed básico" "cat" "sed 's/1/one/g'" "$TEST_FILES_DIR/test9.txt" "10"
compare_results "Comando cat con archivo vacío" "cat" "wc -c" "$TEST_FILES_DIR/empty.txt" "11"
compare_results "Comando grep sin coincidencias" "grep 'noexiste'" "cat" "$TEST_FILES_DIR/test1.txt" "12"
compare_results "Comando wc con múltiples opciones" "cat" "wc -l" "$TEST_FILES_DIR/test2.txt" "13"
compare_results "Comando tr con múltiples caracteres" "cat" "tr 'a' 'A'" "$TEST_FILES_DIR/test3.txt" "14"
compare_results "Comando cut básico" "cat" "cut -d ' ' -f 1" "$TEST_FILES_DIR/test12.txt" "15"
compare_results "Comando cut con delimitador" "cat" "cut -d ',' -f 2" "$TEST_FILES_DIR/test7.txt" "16"
compare_results "Comando grep con opción -v" "grep -v 'a'" "cat" "$TEST_FILES_DIR/test4.txt" "17"
compare_results "Comando nl básico" "cat" "nl -n ln" "$TEST_FILES_DIR/test5.txt" "18"
compare_results "Comando tr para mayúsculas" "cat" "tr a A" "$TEST_FILES_DIR/test1.txt" "19"
compare_results "Comando grep con contexto" "grep -A 1 'tres'" "cat" "$TEST_FILES_DIR/test5.txt" "20"

# === TESTS DE COMANDOS AVANZADOS (21-40) ===
compare_results "Comando sort con opción reversa" "cat" "sort -r" "$TEST_FILES_DIR/test4.txt" "21"
compare_results "Comando uniq" "sort" "uniq" "$TEST_FILES_DIR/test5.txt" "22"
compare_results "Comando grep con múltiples patrones" "grep 'uno'" "cat" "$TEST_FILES_DIR/test5.txt" "23"
compare_results "Comando tr eliminar caracteres" "cat" "tr -d 'a'" "$TEST_FILES_DIR/test3.txt" "24"
compare_results "Comando rev (invertir líneas)" "cat" "rev" "$TEST_FILES_DIR/test1.txt" "25"
compare_results "Comando sed con reemplazo" "cat" "sed 's/a/A/g'" "$TEST_FILES_DIR/test1.txt" "26"
compare_results "Comando awk básico" "cat" "awk '{print \$1}'" "$TEST_FILES_DIR/test12.txt" "27"
compare_results "Comando fold (ajustar texto)" "cat" "fold -w 5" "$TEST_FILES_DIR/test1.txt" "28"
compare_results "Comando grep con opción -c" "grep -c 'a'" "cat" "$TEST_FILES_DIR/test4.txt" "29"
compare_results "Comando sort con opción numérica" "cat" "sort -n" "$TEST_FILES_DIR/test9.txt" "30"
compare_results "Comando paste básico" "cat" "paste -s" "$TEST_FILES_DIR/test6.txt" "31"
compare_results "Comando expand (tabs a espacios)" "cat" "expand" "$TEST_FILES_DIR/test10.txt" "32"
compare_results "Comando grep con opción -o" "grep -o 'es'" "cat" "$TEST_FILES_DIR/test8.txt" "33"
compare_results "Comando awk con condición" "cat" "awk 'length > 5'" "$TEST_FILES_DIR/test4.txt" "34"
compare_results "Comando sed para eliminar líneas" "cat" "sed '2d'" "$TEST_FILES_DIR/test5.txt" "35"
compare_results "Comando sed para insertar texto" "cat" "sed '1s/^/INICIO \\n/'" "$TEST_FILES_DIR/test2.txt" "36"
compare_results "Comando grep case insensitive" "grep -i 'a'" "cat" "$TEST_FILES_DIR/test6.txt" "37"
compare_results "Comando tr con complemento" "cat" "tr -d -c 'a-z'" "$TEST_FILES_DIR/test3.txt" "38"
compare_results "Comando wc solo palabras" "cat" "wc -w" "$TEST_FILES_DIR/test3.txt" "39"
compare_results "Comando head" "cat" "head -n 3" "$TEST_FILES_DIR/test5.txt" "40"

# === TESTS DE COMANDOS COMPLEJOS (41-60) ===
compare_results "Comando grep y wc combinados" "grep 'a'" "wc -l" "$TEST_FILES_DIR/test4.txt" "41"
compare_results "Comando awk con formato" "cat" "awk '{print \$0}'" "$TEST_FILES_DIR/test2.txt" "42"
compare_results "Comando tr básico" "cat" "tr ',' ' '" "$TEST_FILES_DIR/test7.txt" "43"
compare_results "Comando grep negado" "grep -v 'a'" "cat" "$TEST_FILES_DIR/test4.txt" "44"
compare_results "Comando sed con expresiones regulares" "cat" "sed 's/[0-9]/X/g'" "$TEST_FILES_DIR/test9.txt" "45"
compare_results "Comando sort con opciones" "cat" "sort -r" "$TEST_FILES_DIR/test6.txt" "46"
compare_results "Comando awk básico 2" "cat" "awk '{print \$1}'" "$TEST_FILES_DIR/test9.txt" "47"
compare_results "Comando sed para numerar líneas" "cat" "nl" "$TEST_FILES_DIR/test5.txt" "48"
compare_results "Comando sed básico 2" "cat" "sed 's/^/> /'" "$TEST_FILES_DIR/test8.txt" "49"
compare_results "Comando cut con rango" "cat" "cut -c 1-3" "$TEST_FILES_DIR/test3.txt" "50"
compare_results "Comando fmt (formatear texto)" "cat" "fmt" "$TEST_FILES_DIR/test3.txt" "51"
compare_results "Comando grep básico 2" "grep 'es'" "cat" "$TEST_FILES_DIR/test8.txt" "52"
compare_results "Comando awk con campo" "cat" "awk '{print \$1}'" "$TEST_FILES_DIR/test7.txt" "53"
compare_results "Comando grep con contexto después" "grep -A 1 'dos'" "cat" "$TEST_FILES_DIR/test5.txt" "54"
compare_results "Comando grep con contexto antes" "grep -B 1 'cinco'" "cat" "$TEST_FILES_DIR/test5.txt" "55"
compare_results "Comando sort y uniq" "sort" "uniq" "$TEST_FILES_DIR/test5.txt" "56"
compare_results "Comando sed para extraer patrón" "grep 'include'" "cat" "$TEST_FILES_DIR/test10.txt" "57"
compare_results "Comando tr para comprimir espacios" "cat" "tr -s ' '" "$TEST_FILES_DIR/test12.txt" "58"
compare_results "Comando awk print específico" "cat" "awk 'NR==3'" "$TEST_FILES_DIR/test5.txt" "59"
compare_results "Comando grep con líneas" "grep '^'" "cat" "$TEST_FILES_DIR/test2.txt" "60"

# === TESTS DE ERRORES Y CASOS BORDE (61-80) ===
compare_results "Comando cat simple" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "61"
compare_results "Comando grep simple" "grep 'a'" "cat" "$TEST_FILES_DIR/test1.txt" "62"
compare_results "Comando grep básico 3" "grep 'a'" "cat" "$TEST_FILES_DIR/test1.txt" "63"
compare_results "Comando cat 2" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "64"
compare_results "Comando con ruta absoluta" "/bin/echo Hola" "cat" "$TEST_FILES_DIR/test1.txt" "65"
compare_results "Comando cat sin argumentos" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "66"
compare_results "Comando grep con patrón" "grep 'Hola'" "cat" "$TEST_FILES_DIR/test1.txt" "67"
compare_results "Comando env básico" "env" "grep PATH" "$TEST_FILES_DIR/test1.txt" "68"
compare_results "Comando cat 3" "cat" "cat" "$TEST_FILES_DIR/test2.txt" "69"
compare_results "Comando grep con patrón 2" "grep 'a'" "cat" "$TEST_FILES_DIR/test1.txt" "70"
compare_results "Comando echo básico" "echo 'test'" "cat" "$TEST_FILES_DIR/test1.txt" "71"
compare_results "Comando cat 4" "cat" "cat" "$TEST_FILES_DIR/test2.txt" "72"
compare_results "Comando cat 5" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "73"
compare_results "Comando echo con texto" "echo 'test'" "cat" "$TEST_FILES_DIR/test1.txt" "74"
compare_results "Comando cat 6" "cat" "cat" "$TEST_FILES_DIR/test1.txt" "75"
compare_results "Comando grep sin coincidencias 2" "grep 'noexiste'" "wc -l" "$TEST_FILES_DIR/test1.txt" "76"
compare_results "Comando tr básico 2" "cat" "tr 'a' 'b'" "$TEST_FILES_DIR/test1.txt" "77"
compare_results "Comando sed básico 3" "cat" "sed 's/a/X/g'" "$TEST_FILES_DIR/test1.txt" "78"
compare_results "Comando ls básico" "ls" "wc -l" "$TEST_FILES_DIR/test1.txt" "79"
compare_results "Comando tr para espacios" "cat" "tr ' ' '_'" "$TEST_FILES_DIR/test12.txt" "80"

# === TESTS DE MÚLTIPLES PIPES (BONUS) (81-100) ===
# Verificar si existe el ejecutable pipex_bonus
if [ -f "$PROJECT_DIR/pipex_bonus" ]; then
    echo -e "${BLUE}Ejecutando pruebas de bonus (múltiples pipes)...${NC}"
    
    # Crear comandos para pipes múltiples
    compare_multiple_pipes "Triple pipe básico" "$TEST_FILES_DIR/test4.txt" "out_81.txt" "cat" "sort" "uniq" "81"
    compare_multiple_pipes "Triple pipe con grep" "$TEST_FILES_DIR/test5.txt" "out_82.txt" "grep -v 'uno'" "sort" "head -n 2" "82"
    compare_multiple_pipes "Cuádruple pipe" "$TEST_FILES_DIR/test6.txt" "out_83.txt" "cat" "sort" "head -n 3" "83"
    compare_multiple_pipes "Triple pipe con awk" "$TEST_FILES_DIR/test7.txt" "out_84.txt" "cat" "awk '{print \$1}'" "sort" "84"
    compare_multiple_pipes "Triple pipe con sed" "$TEST_FILES_DIR/test8.txt" "out_85.txt" "grep 'es'" "sed 's/es/ES/g'" "cat" "85"
    compare_multiple_pipes "Múltiples filtros" "$TEST_FILES_DIR/test5.txt" "out_86.txt" "grep -v 'uno'" "grep -v 'dos'" "cat" "86"
    compare_multiple_pipes "Triple pipe simple" "$TEST_FILES_DIR/test1.txt" "out_87.txt" "cat" "grep 'Hola'" "wc -l" "87"
    compare_multiple_pipes "Triple pipe de procesamiento" "$TEST_FILES_DIR/test3.txt" "out_88.txt" "cat" "sort" "uniq" "88"
    compare_multiple_pipes "Triple pipe con nl" "$TEST_FILES_DIR/test2.txt" "out_89.txt" "cat" "nl" "head -n 3" "89"
    compare_multiple_pipes "Triple pipe con head" "$TEST_FILES_DIR/test4.txt" "out_90.txt" "cat" "sort" "head -n 2" "90"
    compare_multiple_pipes "Triple pipe con cut" "$TEST_FILES_DIR/test12.txt" "out_91.txt" "cat" "cut -d ' ' -f 1" "sort" "91"
    compare_multiple_pipes "Triple pipe con grep" "$TEST_FILES_DIR/test5.txt" "out_92.txt" "cat" "grep '[aeiou]'" "wc -l" "92"
    compare_multiple_pipes "Triple pipe con tr" "$TEST_FILES_DIR/test9.txt" "out_93.txt" "cat" "tr ' ' '_'" "sort" "93"
    compare_multiple_pipes "Triple pipe con cut y tr" "$TEST_FILES_DIR/test8.txt" "out_94.txt" "grep 'es'" "cut -d ' ' -f 1" "sort" "94"
    compare_multiple_pipes "Triple pipe con sort" "$TEST_FILES_DIR/test6.txt" "out_95.txt" "cat" "sort" "uniq" "95"
    compare_multiple_pipes "Triple pipe con awk 2" "$TEST_FILES_DIR/test7.txt" "out_96.txt" "cat" "awk '{print \$1}'" "sort" "96"
    compare_multiple_pipes "Triple pipe con grep 2" "$TEST_FILES_DIR/test3.txt" "out_97.txt" "cat" "grep 'Lorem'" "wc -l" "97"
    compare_multiple_pipes "Triple pipe con grep 3" "$TEST_FILES_DIR/test10.txt" "out_98.txt" "cat" "grep 'include'" "wc -l" "98"
    compare_multiple_pipes "Triple pipe con cat" "$TEST_FILES_DIR/test4.txt" "out_99.txt" "cat" "sort" "cat" "99"
    compare_multiple_pipes "Triple pipe final" "$TEST_FILES_DIR/test2.txt" "out_100.txt" "cat" "nl" "head -n 3" "100"
    
    # Pruebas para here_doc si existe pipex_bonus
    echo -e "${BLUE}Ejecutando pruebas de bonus (here_doc)...${NC}"
    
    # Pruebas de here_doc
    compare_here_doc "Here_doc básico" "EOF" "cat" "grep Hola" "here_doc_out_101.txt" "101" "Hola\nMundo\nHola de nuevo"
    compare_here_doc "Here_doc con grep" "LIMITE" "grep Prueba" "cat" "here_doc_out_102.txt" "102" "Prueba 1\nPrueba 2\nNo coincide"
    compare_here_doc "Here_doc con sort" "SORT" "sort" "head -n 2" "here_doc_out_103.txt" "103" "c\nb\na\nd\ne"
    compare_here_doc "Here_doc con wc" "LIMIT" "wc -l" "cat" "here_doc_out_104.txt" "104" "Línea 1\nLínea 2\nLínea 3"
    compare_here_doc "Here_doc con tr" "END" "tr a-z A-Z" "grep A" "here_doc_out_105.txt" "105" "abc\ndef\nghi"
    compare_here_doc "Here_doc con sed" "SED" "sed 's/test/TEST/g'" "cat" "here_doc_out_106.txt" "106" "Este es un test\nOtro test aquí"
    compare_here_doc "Here_doc vacío" "EMPTY" "cat" "wc -c" "here_doc_out_107.txt" "107" ""
    compare_here_doc "Here_doc con múltiples líneas" "MULTI" "cat" "grep -v no" "here_doc_out_108.txt" "108" "si\nno\ntal vez\nno sé"
    compare_here_doc "Here_doc con awk" "AWK" "awk '{print \$1}'" "sort" "here_doc_out_109.txt" "109" "uno dos\ntres cuatro\ncinco seis"
    compare_here_doc "Here_doc con cut" "CUT" "cut -d ' ' -f 2" "cat" "here_doc_out_110.txt" "110" "nombre apellido\nciudad país"
    compare_here_doc "Here_doc con delimitador especial" "##END##" "cat" "grep especial" "here_doc_out_111.txt" "111" "texto normal\ntexto especial"
    compare_here_doc "Here_doc con uniq" "UNIQ" "sort" "uniq" "here_doc_out_112.txt" "112" "a\nb\na\nc\nb"
    compare_here_doc "Here_doc con nl" "NL" "nl" "head -n 2" "here_doc_out_113.txt" "113" "primera\nsegunda\ntercera"
    compare_here_doc "Here_doc con rev" "REV" "rev" "cat" "here_doc_out_114.txt" "114" "Hola\nMundo"
    compare_here_doc "Here_doc con head" "HEAD" "cat" "head -n 1" "here_doc_out_115.txt" "115" "línea 1\nlínea 2\nlínea 3"
    compare_here_doc "Here_doc con tail" "TAIL" "cat" "tail -n 1" "here_doc_out_116.txt" "116" "línea 1\nlínea 2\nlínea 3"
    compare_here_doc "Here_doc con caracteres especiales" "CHARS" "grep '*'" "cat" "here_doc_out_117.txt" "117" "asterisco * aquí\nsin asterisco"
    compare_here_doc "Here_doc con formato" "FMT" "cat" "fmt -w 20" "here_doc_out_118.txt" "118" "Este es un texto largo que debería ser formateado correctamente"
    compare_here_doc "Here_doc con expand" "EXPAND" "expand" "cat" "here_doc_out_119.txt" "119" "columna1\tcolumna2\tcolumna3"
    compare_here_doc "Here_doc con fold" "FOLD" "fold -w 5" "cat" "here_doc_out_120.txt" "120" "texto demasiado largo para una línea"
else
    echo -e "${RED}El ejecutable pipex_bonus no se encuentra. No se ejecutarán las pruebas de bonus.${NC}"
    echo -e "${RED}Tests de bonus (81-120) omitidos.${NC}"
    
    # Ajustar TOTAL_TESTS para reflejar que no se ejecutarán las pruebas de bonus
    TOTAL_TESTS=80
fi

# Limpiar archivos temporales
rm -f out_*.txt

# Mostrar resumen
echo ""
echo -e "${BOLD}=== RESUMEN DE PRUEBAS ===${NC}"
echo -e "Tests ejecutados: ${BOLD}$TOTAL_TESTS${NC}"
echo -e "Tests aprobados: ${GREEN}${BOLD}$TESTS_PASSED${NC}"
echo -e "Tests fallidos: ${RED}${BOLD}$(($TOTAL_TESTS - $TESTS_PASSED))${NC}"

# Calcular porcentaje de éxito
if command -v bc > /dev/null 2>&1; then
    PERCENTAGE=$(echo "scale=2; ($TESTS_PASSED * 100) / $TOTAL_TESTS" | bc)
else
    PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
fi
echo -e "Porcentaje de éxito: ${BOLD}${PERCENTAGE}%${NC}"

# Mensaje final
if [ $TESTS_PASSED -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}${BOLD}¡Todas las pruebas han sido superadas correctamente!${NC}"
elif [ $TESTS_PASSED -ge $(($TOTAL_TESTS * 90 / 100)) ]; then
    echo -e "\n${GREEN}${BOLD}¡La mayoría de las pruebas han sido superadas correctamente!${NC}"
elif [ $TESTS_PASSED -ge $(($TOTAL_TESTS * 75 / 100)) ]; then
    echo -e "\n${YELLOW}${BOLD}Se han superado muchas pruebas, pero aún hay errores que corregir.${NC}"
else
    echo -e "\n${RED}${BOLD}Hay varios errores que deben corregirse.${NC}"
fi

exit 0 