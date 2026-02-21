#!/usr/bin/env bash

# Cores e estilos
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
nc='\033[0m' # No Color
bold='\033[1m'

# Versão do script
version="1.3.0"

# Variáveis globais
repoDir="/home/big/Docker/RepoCommunity/html"
repositories=("testing" "stable" "extra")

# Funções auxiliares
printMessage() {
	local color=$1
	local message=$2
	echo -e "${color}${message}${nc}"
	echo ""
}

checkError() {
	if [ $? -ne 0 ]; then
		printMessage "$red" "Erro: $1"
		echo ""
		exit 1
	fi
}

createMenu() {
	local title=$1
	local isMainMenu=$2 # Novo parâmetro: true para menu principal, false para submenus
	shift 2
	local exitOption="Sair"
	[ "$isMainMenu" != "true" ] && exitOption="Voltar"
	local options=("$@" "$exitOption")
	local selected=0
	local key

	tput civis # Esconde o cursor

	while true; do
		tput clear # Limpa a tela
		echo -e "${blue}${bold}$title${nc}\n"

		for i in "${!options[@]}"; do
			if [ $i -eq $selected ]; then
				if [ "${options[$i]}" == "$exitOption" ]; then
					echo -e "${red}${bold}> ${options[$i]}${nc}"
				else
					echo -e "${green}${bold}> ${options[$i]}${nc}"
				fi
			else
				if [ "${options[$i]}" == "$exitOption" ]; then
					echo -e "${red}  ${options[$i]}${nc}"
				else
					echo "  ${options[$i]}"
				fi
			fi
		done

		read -rsn1 key
		case "$key" in
		A)
			((selected--))
			[ $selected -lt 0 ] && selected=$((${#options[@]} - 1))
			;;
		B)
			((selected++))
			[ $selected -eq ${#options[@]} ] && selected=0
			;;
		'') break ;;
		esac
	done

	tput cnorm # Mostra o cursor novamente
	echo -e "\nVocê selecionou: ${green}${bold}${options[$selected]}${nc}"
	MENU_RESULT=${options[$selected]}
}

removePackage() {
	printMessage "$cyan" "Removendo pacote..."

	local packages=()
	for repo in "${repositories[@]}"; do
		while IFS= read -r -d '' file; do
			packages+=("$repo/$(basename "$file")")
		done < <(find "$repoDir/$repo/x86_64" -name "*.pkg.tar.zst" -print0)
	done

	if [ ${#packages[@]} -eq 0 ]; then
		printMessage "$yellow" "Nenhum pacote encontrado."
		return
	fi

	createMenu "Selecione o pacote para remover:" "${packages[@]}"
	local selected_package=$MENU_RESULT

	if [ "$selected_package" != "Sair" ]; then
		local repo=$(echo "$selected_package" | cut -d'/' -f1)
		local package=$(echo "$selected_package" | cut -d'/' -f2)
		local base_name="${package%.pkg.tar.zst}"

		read -p "Tem certeza que deseja remover $package? (s/n): " confirm
		if [[ $confirm =~ ^[Ss]$ ]]; then
			rm -f "$repoDir/$repo/x86_64/$base_name"*
			printMessage "$green" "Pacote $package removido com sucesso do repositório $repo."
			syncDatabase "$repo"
		else
			printMessage "$yellow" "Remoção cancelada."
		fi
	fi
}

movePackage() {
	# Primeiro, escolher o repositório de origem
	createMenu "Selecione o repositório de origem:" "false" "${repositories[@]}"
	local sourceRepo=$MENU_RESULT

	if [ "$sourceRepo" == "Voltar" ]; then
		return
	fi

	# Listar pacotes do repositório selecionado
	local packages=()
	while IFS= read -r -d '' file; do
		packages+=("$(basename "$file" | sed 's/\(.*\)-.*/\1/')")
	done < <(find "$repoDir/$sourceRepo/x86_64" -name "*.pkg.tar.zst" -print0 | sort -z)

	if [ ${#packages[@]} -eq 0 ]; then
		printMessage "$yellow" "Nenhum pacote encontrado em $sourceRepo."
		return
	fi

	# Escolher o pacote para mover
	createMenu "Selecione o pacote para mover:" "false" "${packages[@]}"
	local selectedPackage=$MENU_RESULT

	if [ "$selectedPackage" == "Voltar" ]; then
		return
	fi

	# Escolher o repositório de destino
	local otherRepos=($(echo "${repositories[@]}" | tr ' ' '\n' | grep -v "^$sourceRepo$"))
	createMenu "Selecione o repositório de destino:" "false" "${otherRepos[@]}"
	local targetRepo=$MENU_RESULT

	if [ "$targetRepo" == "Voltar" ]; then
		return
	fi

	# Confirmar a movimentação
	read -p "$(echo -e ${yellow}"Confirma mover $selectedPackage de $sourceRepo para $targetRepo? (s/n): "${nc})" confirm
	if [[ $confirm =~ ^[Ss]$ ]]; then
		# Verificar versão mais antiga no destino
		if ls "$repoDir/$targetRepo/x86_64/$selectedPackage"*.pkg.tar.zst 1>/dev/null 2>&1; then
			local oldVersion=$(ls "$repoDir/$targetRepo/x86_64/$selectedPackage"*.pkg.tar.zst | head -n1)
			local newVersion="$repoDir/$sourceRepo/x86_64/$selectedPackage"*.pkg.tar.zst

			# Comparar versões
			if [ "$(vercmp "$(pacman -Q --file "$newVersion" | awk '{print $2}')" "$(pacman -Q --file "$oldVersion" | awk '{print $2}')")" -gt 0 ]; then
				printMessage "$yellow" "Versão mais antiga encontrada em $targetRepo. Removendo..."
				rm -f "$repoDir/$targetRepo/x86_64/$selectedPackage"*
			else
				printMessage "$red" "Versão no destino é mais nova ou igual. Operação cancelada."
				return
			fi
		fi

		# Mover o pacote
		mv "$repoDir/$sourceRepo/x86_64/$selectedPackage"* "$repoDir/$targetRepo/x86_64/"

		# Sincronizar os repositórios afetados
		syncDatabase "$sourceRepo" "$targetRepo"

		printMessage "$green" "Pacote movido com sucesso!"
	else
		printMessage "$yellow" "Operação cancelada."
	fi
}

syncDatabase() {
	local repos_to_sync=()

	# Se receber dois argumentos, são os repositórios afetados pela movimentação
	if [ ! -z "$1" ] && [ ! -z "$2" ]; then
		printMessage "$cyan" "Sincronizando repositórios $1 e $2..."
		repos_to_sync=("$1" "$2")
	# Se receber "all", sincroniza todos
	elif [ "$1" == "all" ]; then
		repos_to_sync=("${repositories[@]}")
	# Se receber um repositório, pergunta se quer sincronizar
	elif [ ! -z "$1" ]; then
		local menu_options=("Atualizar Repositório: $1")
		createMenu "O seguinte repositório foi alterado:" "false" "${menu_options[@]}"

		if [ "$MENU_RESULT" == "Voltar" ]; then
			return
		else
			repos_to_sync=("$1")
		fi
	fi

	for repo in "${repos_to_sync[@]}"; do
		printMessage "$cyan" "Sincronizando o banco de dados do repositório $repo..."

		cd "$repoDir/$repo/x86_64" || exit 1

		# Remover os bancos de dados existentes
		rm -f "community-$repo.db.tar.gz" "community-$repo.files.tar.gz"
		rm -f "community-$repo.db" "community-$repo.files"

		# Recriar o banco de dados com os pacotes presentes
		repo-add -n -R "community-$repo.db.tar.gz" *.pkg.tar.zst
		checkError "Falha na sincronização do banco de dados de $repo"

		# Remover arquivos .sig e .md5 órfãos
		for file in *.sig *.md5; do
			baseName=${file%.*}
			if [ ! -f "${baseName}" ]; then
				echo "Removendo arquivo órfão: $file"
				rm -f "$file"
			fi
		done

		printMessage "$green" "Sincronização do banco de dados de $repo concluída com sucesso!"
	done
}

cleanOldPackages() {
	local repo=$1
	printMessage "$yellow" "Verificando pacotes no repositório $repo..."

	cd "$repoDir/$repo/x86_64" || exit 1

	local packagesToRemove=()

	for pkg in *.pkg.tar.zst; do
		local pkgBase=$(echo "$pkg" | sed 's/-[^-]*-[^-]*-[^-]*.pkg.tar.zst//')
		local versions=($(ls ${pkgBase}-*.pkg.tar.zst | sort -V))

		if [ ${#versions[@]} -gt 1 ]; then
			local newest=${versions[-1]}
			for old in "${versions[@]}"; do
				if [ "$old" != "$newest" ]; then
					packagesToRemove+=("$old")
				fi
			done
		fi
	done

	if [ ${#packagesToRemove[@]} -eq 0 ]; then
		printMessage "$blue" "Não há pacotes antigos para remover em $repo."
		return
	fi

	echo "Os seguintes pacotes serão removidos do repositório $repo:"
	printf '%s\n' "${packagesToRemove[@]}"

	read -p "Deseja prosseguir com a remoção? (s/n): " confirm
	if [[ $confirm =~ ^[Ss]$ ]]; then
		for pkg in "${packagesToRemove[@]}"; do
			echo "Removendo pacote antigo: $pkg"
			rm -f "$pkg" "${pkg}.sig" "${pkg}.md5"
		done
		printMessage "$green" "Limpeza de pacotes antigos em $repo concluída com sucesso!"
	else
		printMessage "$yellow" "Operação de limpeza cancelada para $repo."
	fi
}

comparePackages() {
	printMessage "$cyan" "Comparando pacotes entre repositórios..."

	declare -A packageMap

	for repo in "${repositories[@]}"; do
		while IFS= read -r -d '' file; do
			local pkgname=$(basename "$file" | sed 's/-[^-]*-[^-]*-[^-]*.pkg.tar.zst//')
			local version=$(pacman -Q --file "$file" | awk '{print $2}')

			if [[ -z ${packageMap[$pkgname]} ]]; then
				packageMap[$pkgname]="$repo:$version"
			else
				packageMap[$pkgname]="${packageMap[$pkgname]} $repo:$version"
			fi
		done < <(find "$repoDir/$repo/x86_64" -name "*.pkg.tar.zst" -print0)
	done

	for pkgname in "${!packageMap[@]}"; do
		local versions=(${packageMap[$pkgname]})
		if [ ${#versions[@]} -gt 1 ]; then
			echo -e "\n${yellow}Pacote ${blue}${bold}${pkgname}${nc}${yellow} encontrado em múltiplos repositórios:${nc}"
			local repos_with_package=()
			for version in "${versions[@]}"; do
				local repo=${version%:*}
				local ver=${version#*:}
				echo -e "${cyan}${bold}$repo${nc}: ${green}$ver${nc}"
				repos_with_package+=("$repo")
			done

			echo -e "\n${white}${bold}Ações disponíveis:${nc}"
			echo -e "${yellow}  k${nc} - ${white}${bold}Keep (manter)${nc}: Não faz alterações, mantém o pacote em todos os repositórios."
			echo -e "${yellow}  m${nc} - ${white}${bold}Move (mover)${nc}: Move o pacote de um repositório para outro."
			echo -e "${yellow}  r${nc} - ${white}${bold}Remove (remover)${nc}: Remove o pacote de um repositório específico."
			echo ""

			local action=""
			while [[ ! "$action" =~ ^[kmr]$ ]]; do
				read -p "$(echo -e ${yellow}"Escolha uma ação (k/m/r): "${nc})" action
			done

			case $action in
			k)
				printMessage "$green" "Mantendo todas as versões do pacote $pkgname."
				;;
			m)
				echo -e "${white}${bold}Escolha o repositório de origem:${nc}"
				createMenu "Selecione o repositório de origem:" "false" "${repos_with_package[@]}"
				local sourceRepo=$MENU_RESULT
				if [ "$sourceRepo" != "Voltar" ]; then
					local otherRepos=($(echo "${repositories[@]}" | tr ' ' '\n' | grep -v "^$sourceRepo$"))
					echo -e "${white}${bold}Escolha o repositório de destino:${nc}"
					createMenu "Selecione o repositório de destino:" "false" "${otherRepos[@]}"
					local targetRepo=$MENU_RESULT
					if [ "$targetRepo" != "Sair" ]; then
						read -p "$(echo -e ${yellow}"Confirma mover $pkgname de $sourceRepo para $targetRepo? (s/n): "${nc})" confirm
						if [[ $confirm =~ ^[Ss]$ ]]; then
							printMessage "$yellow" "Movendo $pkgname de $sourceRepo para $targetRepo"
							mv "$repoDir/$sourceRepo/x86_64/$pkgname"* "$repoDir/$targetRepo/x86_64/"
							syncDatabase "$sourceRepo" "$targetRepo"
						else
							printMessage "$yellow" "Operação cancelada para $pkgname."
						fi
					fi
				fi
				;;
			r)
				echo -e "${white}${bold}Escolha o repositório de onde remover o pacote $pkgname:${nc}"
				createMenu "Selecione o repositório:" "false" "${repos_with_package[@]}"
				local removeRepo=$MENU_RESULT
				if [ "$removeRepo" != "Voltar" ]; then
					read -p "$(echo -e ${yellow}"Confirma remover ${blue}${bold}${pkgname}${nc} ${yellow}de $removeRepo? (s/n): "${nc})" confirm
					if [[ $confirm =~ ^[Ss]$ ]]; then
						printMessage "$yellow" "Removendo $pkgname de $removeRepo"
						rm -f "$repoDir/$removeRepo/x86_64/$pkgname"*
						syncDatabase "$removeRepo"
					else
						printMessage "$yellow" "Operação cancelada para $pkgname."
					fi
				fi
				;;
			esac
			echo ""
		fi
	done

	printMessage "$green" "Comparação de pacotes concluída!"
}

# Verifica pacotes que tem em um repo e não tem no outro
checkExclusivePackages() {
	printMessage "$cyan" "Verificando pacotes exclusivos em cada repositório..."

	declare -A packageMap

	# Primeiro, vamos mapear todos os pacotes e seus repositórios
	for repo in "${repositories[@]}"; do
		while IFS= read -r -d '' file; do
			local pkgname=$(basename "$file" | sed 's/-[^-]*-[^-]*-[^-]*.pkg.tar.zst//')
			if [[ -z ${packageMap[$pkgname]} ]]; then
				packageMap[$pkgname]="$repo"
			else
				packageMap[$pkgname]="${packageMap[$pkgname]} $repo"
			fi
		done < <(find "$repoDir/$repo/x86_64" -name "*.pkg.tar.zst" -print0)
	done

	# Agora vamos criar arrays para cada repositório
	declare -A exclusivePackages
	for repo in "${repositories[@]}"; do
		exclusivePackages[$repo]=""
	done

	# Verificar pacotes exclusivos
	for pkgname in "${!packageMap[@]}"; do
		local repos=(${packageMap[$pkgname]})
		if [ ${#repos[@]} -eq 1 ]; then
			exclusivePackages[${repos[0]}]+="$pkgname "
		fi
	done

	# Mostrar resultados para cada repositório
	for repo in "${repositories[@]}"; do
		local exclusive=(${exclusivePackages[$repo]})
		echo -e "\n${yellow}Pacotes exclusivos do repositório ${blue}${bold}$repo${nc}${yellow}:${nc}"

		if [ -z "${exclusivePackages[$repo]}" ]; then
			echo -e "${purple}Nenhum pacote exclusivo encontrado.${nc}"
		else
			local count=0
			for pkg in ${exclusivePackages[$repo]}; do
				local version=$(pacman -Q --file "$repoDir/$repo/x86_64/$pkg"*.pkg.tar.zst 2>/dev/null | awk '{print $2}')
				echo -e "${green}${bold}$pkg${nc} - ${cyan}versão: $version${nc}"
				((count++))
			done
			echo -e "\n${yellow}Total de pacotes exclusivos em $repo: ${green}$count${nc}"
		fi
	done

	echo -e "\n${yellow}Deseja realizar alguma ação com os pacotes exclusivos?${nc}"
	echo -e "${white}${bold}Ações disponíveis:${nc}"
	echo -e "${yellow}  m${nc} - ${white}${bold}Mover pacote${nc}: Move um pacote exclusivo para outro repositório"
	echo -e "${yellow}  r${nc} - ${white}${bold}Remover pacote${nc}: Remove um pacote exclusivo"
	echo -e "${yellow}  n${nc} - ${white}${bold}Nenhuma ação${nc}: Volta ao menu principal"
	echo ""

	local action=""
	while [[ ! "$action" =~ ^[mrn]$ ]]; do
		read -p "$(echo -e ${yellow}"Escolha uma ação (m/r/n): "${nc})" action
	done

	case $action in
	m)
		# Criar lista de todos os pacotes exclusivos
		local allExclusivePackages=()
		for repo in "${repositories[@]}"; do
			for pkg in ${exclusivePackages[$repo]}; do
				allExclusivePackages+=("$repo/$pkg")
			done
		done

		if [ ${#allExclusivePackages[@]} -eq 0 ]; then
			printMessage "$yellow" "Não há pacotes exclusivos para mover."
			return
		fi

		createMenu "Selecione o pacote para mover:" "${allExclusivePackages[@]}"
		local selected=$MENU_RESULT

		if [ "$selected" != "Sair" ]; then
			local sourceRepo=$(echo "$selected" | cut -d'/' -f1)
			local pkgname=$(echo "$selected" | cut -d'/' -f2)

			local otherRepos=($(echo "${repositories[@]}" | tr ' ' '\n' | grep -v "^$sourceRepo$"))
			createMenu "Selecione o repositório de destino:" "${otherRepos[@]}"
			local targetRepo=$MENU_RESULT

			if [ "$targetRepo" != "Sair" ]; then
				read -p "$(echo -e ${yellow}"Confirma mover $pkgname de $sourceRepo para $targetRepo? (s/n): "${nc})" confirm
				if [[ $confirm =~ ^[Ss]$ ]]; then
					# Verificar se existe versão antiga no repositório de destino
					if ls "$repoDir/$targetRepo/x86_64/$pkgname"*.pkg.tar.zst 1>/dev/null 2>&1; then
						local oldVersion=$(ls "$repoDir/$targetRepo/x86_64/$pkgname"*.pkg.tar.zst | head -n1)
						local newVersion="$repoDir/$sourceRepo/x86_64/$pkgname"*.pkg.tar.zst

						# Comparar versões
						if [ "$(vercmp "$(pacman -Q --file "$newVersion" | awk '{print $2}')" "$(pacman -Q --file "$oldVersion" | awk '{print $2}')")" -gt 0 ]; then
							printMessage "$yellow" "Versão mais antiga encontrada em $targetRepo. Removendo..."
							rm -f "$repoDir/$targetRepo/x86_64/$pkgname"*
						else
							printMessage "$red" "Versão no destino é mais nova ou igual. Operação cancelada."
							return
						fi
					fi

					mv "$repoDir/$sourceRepo/x86_64/$pkgname"* "$repoDir/$targetRepo/x86_64/"
					syncDatabase "$sourceRepo" "$targetRepo"
					printMessage "$green" "Pacote movido com sucesso!"
				fi
			fi
		fi
		;;
	r)
		local allExclusivePackages=()
		for repo in "${repositories[@]}"; do
			for pkg in ${exclusivePackages[$repo]}; do
				allExclusivePackages+=("$repo/$pkg")
			done
		done

		if [ ${#allExclusivePackages[@]} -eq 0 ]; then
			printMessage "$yellow" "Não há pacotes exclusivos para remover."
			return
		fi

		createMenu "Selecione o pacote para remover:" "${allExclusivePackages[@]}"
		local selected=$MENU_RESULT

		if [ "$selected" != "Sair" ]; then
			local repo=$(echo "$selected" | cut -d'/' -f1)
			local pkgname=$(echo "$selected" | cut -d'/' -f2)

			read -p "$(echo -e ${yellow}"Confirma remover $pkgname de $repo? (s/n): "${nc})" confirm
			if [[ $confirm =~ ^[Ss]$ ]]; then
				rm -f "$repoDir/$repo/x86_64/$pkgname"*
				syncDatabase "$repo"
				printMessage "$green" "Pacote removido com sucesso!"
			fi
		fi
		;;
	n)
		printMessage "$yellow" "Retornando ao menu principal..."
		;;
	esac
}

# Menu principal
while true; do
	printMessage "$blue" "Script de Gerenciamento de Repositório no Servidor (versão $version)"

	createMenu "Escolha uma ação:" "true" \
		"Sincronizar bancos de dados" \
		"Limpar pacotes antigos" \
		"Comparar pacotes" \
		"Verificar pacotes exclusivos" \
		"Remover pacote" \
		"Mover pacote"
	ACTION=$MENU_RESULT

	case "$ACTION" in
	"Sincronizar bancos de dados")
		createMenu "Selecione o repositório para sincronizar:" "false" "${repositories[@]}" "Todos"
		if [ "$MENU_RESULT" != "Voltar" ]; then
			if [ "$MENU_RESULT" == "Todos" ]; then
				syncDatabase "all"
			else
				syncDatabase "$MENU_RESULT"
			fi
		fi
		;;
	"Limpar pacotes antigos")
		for repo in "${repositories[@]}"; do
			cleanOldPackages "$repo"
		done
		;;
	"Comparar pacotes")
		comparePackages
		;;
	"Verificar pacotes exclusivos")
		checkExclusivePackages
		;;
	"Remover pacote")
		removePackage
		;;
	"Mover pacote")
		movePackage
		;;
	"Sair")
		exit 0
		;;
	*)
		printMessage "$red" "Opção inválida selecionada."
		;;
	esac

	echo ""
	read -p "Pressione [Enter] para voltar ao menu principal..."
done
