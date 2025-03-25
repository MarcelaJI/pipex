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
	rm -f output.txt .heredoc_tmp input.txt
}

### PREPARACIÓN ###
cleanup
echo "Hola mundo" > input.txt

### TEST 1: heredoc básico ###
echo -e "${BOLD}🧪 Test 1: heredoc básico (cat | wc -l)${RESET}"
printf "hola\nmundo\nEND\n" | ./pipex here_doc END "cat" "wc -l" output.txt
if grep -q '^2$' output.txt; then
	print_success "heredoc básico correcto (2 líneas)"
else
	print_error "heredoc básico incorrecto"
	cat output.txt
fi
sep
cleanup
echo "Hola mundo" > input.txt

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
cleanup
echo "Hola mundo" > input.txt

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
cleanup
echo "Hola mundo" > input.txt

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
cleanup

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
cleanup
echo "data" > input.txt

### TEST 6: heredoc sin contenido ###
echo -e "${BOLD}🧪 Test 6: heredoc sin contenido${RESET}"
printf "END\n" | ./pipex here_doc END "cat" "wc -l" output.txt
if grep -q '^0$' output.txt; then
	print_success "heredoc vacío manejado correctamente"
else
	print_error "Fallo en heredoc vacío"
	cat output.txt
fi
sep
cleanup

### TEST 7: heredoc con caracteres especiales ###
echo -e "${BOLD}🧪 Test 7: heredoc + tr | wc -c${RESET}"
printf "hola mundo\nEND\n" | ./pipex here_doc END "tr a-z A-Z" "wc -c" output.txt
if [[ $(cat output.txt | tr -d ' ') =~ ^[0-9]+$ ]]; then
	print_success "Heredoc + tr | wc ejecutado correctamente"
else
	print_error "Fallo en heredoc + tr"
	cat output.txt
fi
sep
cleanup

### TEST 8: PATH eliminado y rutas absolutas ###
echo -e "${BOLD}🧪 Test 8: Sin PATH + rutas absolutas${RESET}"
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

### TEST 9: .heredoc_tmp eliminado ###
echo -e "${BOLD}🧪 Test 9: verificación de borrado de .heredoc_tmp${RESET}"
printf "data\nEND\n" | ./pipex here_doc END "cat" "wc" output.txt
if [ ! -f .heredoc_tmp ]; then
	print_success ".heredoc_tmp eliminado correctamente"
else
	print_error ".heredoc_tmp No se eliminó correctamente"
fi
sep
cleanup
