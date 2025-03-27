#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

print_success() {
	echo -e "${GREEN}✅ $1${RESET}"
}

print_error() {
	echo -e "${RED}❌ $1${RESET}"
}

sep() {
	echo -e "${BOLD}----------------------------${RESET}"
}

cleanup() {
	rm -f input.txt output.txt err.txt
}

### PREPARACIÓN ###
cleanup
echo "Hola mundo" > input.txt

### TEST 1: cat | wc -l ###
echo -e "${BOLD}🧪 Test 1: cat | wc -l${RESET}"
./pipex input.txt "cat" "wc -l" output.txt
if grep -q '^1$' output.txt; then
	print_success "cat | wc -l ejecutado correctamente"
else
	print_error "Fallo en cat | wc -l"
	cat output.txt
fi
sep

### TEST 2: comando inválido ###
echo -e "${BOLD}🧪 Test 2: comando inválido${RESET}"
./pipex input.txt "zzzz" "wc" output.txt 2> err.txt
if grep -q "Command not found: zzzz" err.txt; then
	print_success "Comando inválido correctamente detectado"
else
	print_error "No se detectó comando inválido"
	cat err.txt
fi
sep

### TEST 3: comando vacío ###
echo -e "${BOLD}🧪 Test 3: comando vacío${RESET}"
./pipex input.txt "" "wc" output.txt 2> err.txt
if grep -q "Command not found:" err.txt; then
	print_success "Comando vacío correctamente detectado"
else
	print_error "No se detectó comando vacío"
	cat err.txt
fi
sep

### TEST 4: archivo inexistente ###
echo -e "${BOLD}🧪 Test 4: archivo inexistente${RESET}"
./pipex nofile.txt "cat" "wc" output.txt 2> err.txt
if grep -q "No such file or directory" err.txt; then
	print_success "Archivo de entrada inexistente correctamente detectado"
else
	print_error "Fallo al detectar archivo inexistente"
	cat err.txt
fi
sep

### TEST 5: output sin permisos ###
echo -e "${BOLD}🧪 Test 5: archivo de salida sin permisos${RESET}"
echo "data" > input.txt
touch output.txt
chmod 000 output.txt
./pipex input.txt "cat" "wc" output.txt 2> err.txt
chmod 644 output.txt
if grep -q "Permission denied" err.txt; then
	print_success "Permisos denegados correctamente detectados"
else
	print_error "No se detectó error de permisos"
	cat err.txt
fi
sep

### TEST 6: sin PATH y usando rutas absolutas ###
echo -e "${BOLD}🧪 Test 6: sin PATH + rutas absolutas${RESET}"
echo "hola mundo" > input.txt
unset PATH
./pipex input.txt "/bin/cat" "/usr/bin/wc -w" output.txt
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
if [[ $(cat output.txt) == "2" ]]; then
	print_success "Ejecutado correctamente sin PATH"
else
	print_error "Fallo al ejecutar con rutas absolutas sin PATH"
	cat output.txt
fi
sep

cleanup
