#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# shellcheck shell=bash disable=SC1091,SC2039,SC2166,SC2317,SC2155,SC2034,SC2229,SC2076
#
#  gitrepo.sh - Wrapper git para o BigCommunity
#  Created: qui 05 set 2024 00:51:12 -04
#  Altered: seg 09 set 2024 20:31:51 -04
#
#  Copyright (c) 2024-2024, Tales A. Mendonça <talesam@gmail.com>
#  Copyright (c) 2024-2024, Vilmar Catafesta <vcatafesta@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##############################################################################
# system
declare APP="${0##*/}"
declare APPDESC="Wrapper git para o BigCommunity"
declare VERSION="2.0.1" # Versão do script
declare distro="$(uname -n)"
readonly DEPENDENCIES=('git' 'tput')
readonly organizations=("communitybig" "chililinux" "biglinux" "talesam" "vcatafesta")
readonly branchs=("testing" "stable")

# Funções auxiliares
get() {
	local row="$1"
	local col="$2"
	local prompt="$3"
	local new_value="$4"
	local old_value="$5"
	local color="$branca"

	#  setpos "$row" "$col"
	#  printf "%s" "${RESET}$color"
	read -r -p "${prompt}${color}${reverse}" -e -i "$old_value" "$new_value"
	tput sc # Salva a posição atual do cursor
	echo -e "$RESET"
}

gettokengithub_by_line() {
	#	echo "$(<$CFILETOKEN)"					# pega tudo
	#	sed -n '2p' "$CFILETOKEN"				# pega 2st linha
	sed -n '1p' "$CFILETOKEN" # pega 1st linha
}

gettokengithub_after_key() {
	#	sed -n '2s/.*=//p' "$CFILETOKEN"
	sed -n '1s/.*=//p' "$CFILETOKEN"
}

gettokengithub_by_key() {
	sed -n "/^$ORGANIZATION=/s/.*=//p" "$CFILETOKEN"
}

get_token_release() {
	declare -g TOKEN_RELEASE
	if [[ ! -e "$CFILETOKEN" ]]; then
		die "$RED" "Erro: Não foi possível ler o arquivo $CFILETOKEN"
	fi

	#	TOKEN_RELEASE="$(gettokengithub_by_line)"
	#	TOKEN_RELEASE="$(gettokengithub_after_key)"
	TOKEN_RELEASE="$(gettokengithub_by_key)"

	# Verica se o Token não está vazio
	if [[ -z "$TOKEN_RELEASE" ]]; then
		print_message_and_exit
	fi
}

print_message_and_exit() {
	cat <<-EOF
		${RED}Erro fatal: Não foi possível capturar o TOKEN do Github para a organização ${YELLOW}'${ORGANIZATION}' ${RED}no arquivo ${YELLOW}'${CFILETOKEN}'
		${RESET}O arquivo ${YELLOW}'${CFILETOKEN}' ${RESET}deverá estar no seguinte formato:
		${CYAN}${ORGANIZATION}=ghp_y6EP1EIj0zkXufGMV2TDNHovekLSHw2ylAv3${RESET}

		${YELLOW}=> Foi adicionado uma entrada nesse arquivo, com TOKEN ficticio, faça os ajustes necessários manualmente.${RESET}
	EOF
	echo "${ORGANIZATION}=ghp_y6EP1EIj0zkXufGMV2TDNHovekLSHw2ylAv3" >>"$CFILETOKEN"
	exit 1
}

print_message() {
	local color="$1"
	local message="$2"
	echo -e "${color}${message}${NC}"
	echo ""
}

check_error() {
	local result="$?"
	if [[ "$result" -ne 0 ]]; then
		die "$RED" "Erro: $1"
	fi
}

log_message() {
	# Remover códigos de escape ANSI do log
	clean_log=$(sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\(B//g' <<<"$1")
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $clean_log" >>"${LOG_FILE}"
}

# print_and_log_message
p_log() {
	local color="$1"
	local message="$2"
	# Remover códigos de escape ANSI do log
	clean_log=$(sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\(B//g' <<<"$message")
	echo -e "${color}=> ${message}${RESET}"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${clean_log}" >>"${LOG_FILE}"
}

die() {
	local color="$1"
	local message="$2"
	p_log "$color" "$message"
	checkout_and_exit 1
}

check_repo_is_git() {
	if git rev-parse --is-inside-work-tree >/dev/null 2>&-; then
		echo true
	else
		echo false
	fi
}

debug() {
	whiptail \
		--fb \
		--clear \
		--backtitle "[debug]$0" \
		--title "[debug]$0" \
		--yesno "${*}\n" \
		0 40
	result="$?"
	if ((result)); then
		exit "$result"
	fi
	return "$result"
}

get_repo_name() {
	local repo_path
	local repo_name

	repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
	repo_name=$(basename "$repo_path")
	[[ -z "$repo_name" ]] && repo_name="unknown_repo"
	echo "$repo_name"
}

get_repo_root_path() {
	local repo_path
	repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
	[[ -z "$repo_path" ]] && repo_path="$PWD"
	echo "$repo_path"
}

clean_branchs_deleted_on_remote() {
	local branch

	git fetch --prune 2>/dev/null
	for branch in $(git branch -vv | grep ': gone' | awk '{print $1}'); do
		git branch -d "$branch" 2>/dev/null
	done
}

set_varcolors() {
	# does the terminal support true-color?
	if [[ -n "$(command -v "tput")" ]]; then
		#tput setaf 127 | cat -v  #capturar saida

		: "${RED=$(tput bold)$(tput setaf 196)}"
		: "${GREEN=$(tput bold)$(tput setaf 2)}"
		: "${YELLOW=$(tput bold)$(tput setaf 3)}"
		: "${BLUE=$(tput setaf 4)}"
		: "${PURPLE=$(tput setaf 125)}"
		: "${CYAN=$(tput setaf 6)}"
		: "${NC=$(tput sgr0)}"
		: "${RESET=$(tput sgr0)}"
		: "${BOLD=$(tput bold)}"
		: "${black=$(tput bold)$(tput setaf 0)}"
		: "${reverse=$(tput rev)}"
		: "${branca=${black}$(tput setab 7)}"

		: "${reset=$(tput sgr0)}"
		: "${rst=$(tput sgr0)}"
		: "${bold=$(tput bold)}"
		: "${underline=$(tput smul)}"
		: "${nounderline=$(tput rmul)}"
		: "${reverse=$(tput rev)}"

		: "${black=$(tput bold)$(tput setaf 0)}"
		: "${red=$(tput bold)$(tput setaf 196)}"
		: "${green=$(tput bold)$(tput setaf 2)}"
		: "${yellow=$(tput bold)$(tput setaf 3)}"
		: "${blue=$(tput setaf 27)}"
		: "${magenta=$(tput setaf 5)}"
		: "${cyan=$(tput setaf 6)}"
		: "${white=$(tput setaf 7)}"
		: "${gray=$(tput setaf 8)}"
		: "${light_red=$(tput setaf 9)}"
		: "${light_green=$(tput setaf 10)}"
		: "${light_yellow=$(tput setaf 11)}"
		: "${light_blue=$(tput setaf 12)}"
		: "${light_magenta=$(tput setaf 13)}"
		: "${light_cyan=$(tput setaf 14)}"
		: "${light_white=$(tput setaf 15)}"
		: "${orange=$(tput setaf 202)}"
		: "${purple=$(tput setaf 125)}"
		: "${violet=$(tput setaf 61)}"

		# Definir cores de fundo
		: "${preto=$(tput setab 0)}"
		: "${vermelho=$(tput setab 196)}"
		: "${verde=$(tput setab 2)}"
		: "${amarelo=$(tput setab 3)}"
		: "${azul=$(tput setab 20)}"
		: "${roxo=$(tput setab 5)}"
		: "${ciano=$(tput setab 6)}"
		: "${branca="${black}$(tput setab 7)"}"
		: "${cinza=$(tput setab 8)}"
		: "${laranja=$(tput setab 202)}"
		: "${roxa=$(tput setab 125)}"
		: "${violeta=$(tput setab 61)}"
	else
		unset_varcolors
	fi
}

unset_varcolors() {
	unset RED GREEN YELLOW BLUE PURPLE CYAN NC RESET BOLD black reverse branca
	unset reset rst bold underline nounderline reverse
	unset black red green yellow blue magenta cyan white gray orange purple violet
	unset light_red light_green light_yellow light_blue light_magenta light_cyan light_white
	unset preto vermelho verde amarelo azul roxo ciano branca cinza laranja roxa violeta
}

checkDependencies() {
	local d
	local errorFound=false
	declare -a missing

	for d in "${DEPENDENCIES[@]}"; do
		if [[ -z "$(command -v "$d")" ]]; then
			missing+=("$d")
			errorFound=true
			printf '%s\n' "${RED}ERRO${RESET}: não encontrei o comando ${CYAN}'$d'${RESET}"
		fi
	done
	if $errorFound; then
		echo "${YELLOW}--------------IMPOSSÍVEL CONTINUAR-------------${RESET}"
		echo "Esse script precisa dos comandos listados acima" >&2
		echo "Instale-os e/ou verifique se estão no seu ${CYAN}'PATH' ${RESET}" >&2
		echo "-----------------------------------------------${RESET}"
		die "$RED" "Script abortado..."
	fi
}

get_main_branch() {
	local branch
	# Check if 'main' branch exists
	if git rev-parse --verify origin/main >/dev/null 2>&1; then
		branch="main"
	elif git rev-parse --verify origin/master >/dev/null 2>&1; then
		branch="master"
	fi
	echo "$branch"
}

checkout_and_exit() {
	local exit_status="$1"
	if $IS_GIT_REPO; then
		git checkout "$(get_main_branch)" >/dev/null 2>&-
	fi
	if ! ((exit_status)); then
		p_log "$GREEN" "Processo concluído com sucesso."
	fi
	exit "$exit_status"
}

gclean_branch_remote_and_update_local() {
	local clean
	local mainbranch
	local branch
	local latest_testing_branch_remote
	local latest_stable_branch_remote
	local remote_branches
	local branches_to_keep_remote
	local branch_name

	p_log "${RED}" "Apaga todos os branches remotos (exceto $mainbranch e os mais novos com prefixo testing- e stable-) e atualiza o repositório local"

	# Confirmar a operação
	read -r -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 5s"
		sleep 5
		exit 1
	fi

	p_log "${YELLOW}" "$clean ${RED}checado. ${black}Prosseguindo com a exclusão dos branches remotos (exceto $mainbranch e os mais novos com prefixo testing- e stable-) ${RESET}"
	# Obtém o nome do branch principal
	mainbranch="$(get_main_branch)"
	# Mudar para o branch principal
	git checkout "$mainbranch" >/dev/null 2>&1

	# Atualizar o repositório local para refletir as mudanças remotas
	p_log "${CYAN}" "Atualizando o repositório local para refletir as alterações remotas"
	git fetch --prune

	# Encontrar e ordenar os branches remotos com prefixo testing- e stable-
	p_log "${CYAN}" "Encontrar os branches remotos com prefixo testing- e stable-"
	remote_branches=$(git branch -r | grep -E 'origin/(testing-|stable-)' | sort)

	# Obter o mais recente de cada prefixo
	latest_testing_branch_remote=$(echo "$remote_branches" | grep 'origin/testing-' | tail -n 1)
	latest_stable_branch_remote=$(echo "$remote_branches" | grep 'origin/stable-' | tail -n 1)

	# Criar uma lista de branches remotos a manter
	branches_to_keep_remote="origin/$mainbranch"
	[[ -n "$latest_testing_branch_remote" ]] && branches_to_keep_remote+=" $latest_testing_branch_remote"
	[[ -n "$latest_stable_branch_remote" ]] && branches_to_keep_remote+=" $latest_stable_branch_remote"

	# Excluir branches remotos que não estão na lista de branches a manter
	p_log "${CYAN}" "Excluir todos os branches remotos (exceto $branches_to_keep_remote)"
	for branch in $remote_branches; do
		branch_name=${branch#origin/} # Usa expansão de parâmetro para remover 'origin/'
		if [[ ! " $branches_to_keep_remote " =~ " origin/$branch_name " ]]; then
			git branch -D "$branch_name"
			git push origin --delete "$branch_name"
		fi
	done >/dev/null 2>&1

	# Mudar para o branch principal
	git checkout "$mainbranch" >/dev/null 2>&1

	# Atualizar o repositório local para refletir as mudanças remotas
	p_log "${CYAN}" "Atualizando o repositório local para refletir as alterações remotas"
	git fetch --prune
	git pull origin "$mainbranch"

	# Listar os branches finais para confirmação
	p_log "${CYAN}" "Branches finais:"
	git branch -a
	p_log "${GREEN}" "Branches remotos limpos e repositório local atualizado."
	checkout_and_exit 0
}

# Função para exibir informações de ajuda
sh_usage() {
	set_varcolors
	cat <<-EOF
		${reset}${APP} v${VERSION} - ${APPDESC}${reset}
		${red}Uso: ${reset}$APP ${cyan}[opções]${reset}

		    ${cyan}Opções:${reset}
		      -o|--org|--organization ${orange}<name> ${cyan} # Configura organização de trabalho no Github ${yellow}(default: communitybig)${reset}
		      -c|--commit          ${orange}<message> ${cyan} # Apenas fazer commit/push ${yellow}obrigátorio mensagem do commit ${reset}
		      -b|--build            ${orange}<branch> ${cyan} # Realizar commit/push e gerar pacote ${reset} branch válidos: ${yellow}testing ${cyan}ou ${yellow}stable ${reset}
		      -a|--aur              ${orange}<pacote> ${cyan} # Construir pacote do AUR ${yellow}obrigátorio nome do pacote para construir ${reset}
		      -V|--version                   ${cyan} # Imprime a versão do aplicativo ${reset}
		      -h|--help                      ${cyan} # Mostra este Help ${reset}
	EOF
}

check_param_org() {
	local value_organization="$1"
	if [[ ! " ${organizations[@]} " =~ " $value_organization " ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-o|--organization|--org' ${RESET};
São válidos: ${organizations[*]}
${CYAN}ex.: $APP -o communitybig
     $APP --org talesam
     $APP --organization vcatafesta${RESET}"
	fi
}

check_param_commit() {
	local value_commit="$1"
	if [[ -z "$value_commit" || "$value_commit" == -* ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-c|--commit' ${RESET}
O valor do parâmetro está vazio ou é outro/ou próximo parâmetro.
São válidos: Qualquer string não vazia"
	fi
}

check_param_build() {
	local value_build="$1"
	if [[ ! " ${branchs[@]} " =~ " $value_build " ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-b|--build' ${RESET};
São válidos: ${branchs[*]}"
	fi
}

check_param_aur() {
	local value_aur="$1"
	if [[ -z "$value_aur" || "$value_aur" == -* ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-a|--aur' ${RESET}
O valor do parâmetro está vazio ou é outro/ou próximo parâmetro.
São válidos: Qualquer nome de pacote/string não vazia"
	fi
}

parse_parameters() {
	local param_organization
	local value_organization
	local param_organization_was_supplied=false
	local param_commit_was_supplied=false
	local param_build_was_supplied=false
	local param_aur_was_supplied=false

	while [[ $# -gt 0 ]]; do
		case $1 in
		-o | --org | --organization)
			param_organization="$1"
			value_organization="$2"
			# Teste se o parâmetro foi fornecido e se o valor é válido
			check_param_org "$value_organization"
			param_organization_was_supplied=true
			shift # past argument
			shift # past value
			;;
		-c | --commit)
			param_commit="$1"
			value_commit="$2"
			# Teste se o parâmetro foi fornecido e se o valor é válido
			check_param_commit "$value_commit"
			param_commit_was_supplied=true
			shift # past argument
			shift # past value
			;;
		-b | --build)
			param_build="$1"
			value_build="$2"
			# Teste se o parâmetro foi fornecido e se o valor é válido
			check_param_build "$value_build"
			param_build_was_supplied=true
			shift # past argument
			shift # past value
			;;
		-a | --aur)
			param_aur="$1"
			value_aur="$2"
			# Teste se o parâmetro foi fornecido e se o valor é válido
			check_param_aur "$value_aur"
			param_aur_was_supplied=true
			shift # past argument
			shift # past value
			;;
		*)
			shift # unknown option
			;;
		esac
	done

	if $param_organization_was_supplied; then
		REPO="${value_organization}/build-package" # Repositório que contém os workflows
		ORGANIZATION="${REPO%%/*}"                 # communitybig
	fi

	if $param_build_was_supplied; then
		branch_type="$value_build"
		if $param_commit_was_supplied; then
			default_commit_message="$value_commit"
		else
			die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-c|--commit' ${RESET}
Ao usar o parametro ${YELLOW}'-b|--build' ${reset}é necessário também este parâmetro"
		fi
		Realizar_commit_e_gerar_pacote
	fi

	if $param_commit_was_supplied; then
		default_commit_message="$value_commit"
		Apenas_fazer_commit_push
	fi

	if $param_aur_was_supplied; then
		Construir_pacote_do_AUR "$value_aur"
	fi
}

sh_version() {
	set_varcolors
	cat <<-EOF
		    ${BOLD}${CYAN}${0##*/} v${VERSION}${RESET}
		    ${APPDESC}
		    ${BOLD}${black}Copyright (C) 2024-2024 ${reset}BigCommunity Team${black}

				    Este é um software livre: você é livre para alterá-lo e redistribuí-lo.
				    O $APP é disponibilizado para você sob a ${yellow}Licença MIT${black}, e
				    inclui software de código aberto sob uma variedade de outras licenças.
				    Você pode ler instruções sobre como baixar e criar para você mesmo
				    o código fonte específico usado para criar esta cópia.
				    ${red}Este programa vem com absolutamente NENHUMA garantia.
				    ${RESET}
	EOF
}

get_git_last_commit_url() {
	# Obtém a URL do repositório
	repo_url=$(git config --get remote.origin.url | sed 's/.git$//')

	# Obtém o hash do último commit
	commit_hash=$(git log -1 --format="%H")

	# Constrói a URL do commit
	echo "${repo_url}/commit/${commit_hash}"
}

###############################################################################################################################################
create_menu() {
	local title=$1
	shift
	#	local options=("$@" "Sair")
	local options=("$@")
	local selected=0
	local key

	tput civis # Esconde o cursor

	while true; do
		tput clear # Limpa a tela
		if ! $IS_AUR_PACKAGE; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Name    : ${CYAN}$REPO_NAME${RESET}"
			echo -e "Path         : ${CYAN}$REPO_PATH${RESET}"
			echo -e "Branchs      : ${RED}$(git branch 2>/dev/null)${RESET}"
			git remote -v 2>/dev/null
			echo '---------------------------------------------------------------------------------'
		else
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Path         : ${CYAN}$REPO_PATH${RESET}"
			echo '---------------------------------------------------------------------------------'
		fi
		echo -e "${BLUE}${BOLD}$title${NC}\n"

		for i in "${!options[@]}"; do
			if [[ "$i" -eq $selected ]]; then
				if [[ "${options[$i]}" =~ ^(Sair|Voltar)$ ]]; then
					echo -e "${RED}${BOLD}> ${options[$i]}${NC}"
				else
					echo -e "${GREEN}${BOLD}> ${options[$i]}${NC}"
				fi
			else
				if [[ "${options[$i]}" =~ ^(Sair|Voltar)$ ]]; then
					echo -e "${RED}  ${options[$i]}${NC}"
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
	echo -e "\nVocê selecionou: ${GREEN}${BOLD}${options[$selected]}${NC}"
	MENU_RESULT=${options[$selected]}
	#	return $((selected+1))
}

get_package_name() {
	local pkgbuild_path
	local pkgname

	pkgbuild_path=$(find . -name PKGBUILD -print -quit)
	if [[ -z "$pkgbuild_path" ]]; then
		die "$RED" "Erro: Arquivo PKGBUILD não encontrado."
	fi

	if pkgname=$(grep -E "^pkgname=" "$pkgbuild_path" | cut -d'=' -f2) && [[ -z "$pkgname" ]]; then
		die "$RED" "Erro: Nome do pacote não encontrado no PKGBUILD."
	fi
	echo "$pkgname"
}

update_commit_push() {
	local commit_message
	local mainbranch="$(get_main_branch)"

	if [[ "$USER" == "vcatafesta" ]]; then
		default_commit_message="$(date) Vilmar Catafesta (vcatafesta@gmail.com)"
	else
		[[ -z "$default_commit_message" ]] && default_commit_message=""
	fi
	p_log "$CYAN" "Mudando para o branch ${mainbranch}"
	if ! git checkout "$mainbranch"; then
		die "$RED" "Erro: git checkout ${mainbranch} - Falha ao mudar para o branch ${mainbranch}"
	fi

	p_log "$CYAN" "Atualizando o repositório..."
	if ! git pull; then
		die "$RED" "Erro: git pull - Falha ao atualizar o repositório"
	fi
	p_log "$GREEN" "Repositório atualizado com sucesso"

	if [[ -n "$(git status --short)" ]]; then
		p_log "$CYAN" "Adicionando todas as mudanças..."
		if ! git add --all .; then
			die "$RED" "Erro: git add --all - Falha ao adicionar mudanças"
		fi
		p_log "$GREEN" "Mudanças adicionadas com sucesso"

		if [[ -z "$default_commit_message" ]]; then
			get 10 10 "${orange}=> Digite o comentário para o commit: " commit_message "$default_commit_message"
		else
			commit_message="$default_commit_message"
		fi

		p_log "$CYAN" "Realizando commit..."
		if ! git commit -m "$commit_message"; then
			die "$RED" "Erro: 'git commit -m $commit_message' - Falha ao realizar commit"
		fi
		p_log "$GREEN" "Commit realizado com sucesso: $commit_message"

		p_log "$CYAN" "Realizando push para o GitHub..."
		if ! git push --set-upstream origin "$mainbranch"; then
			die "$RED" "Erro: 'git push --set-upstream origin ${mainbranch}' - Falha ao realizar push"
		fi
		p_log "$YELLOW" "Commit hash: $(get_git_last_commit_url)"
		p_log "$GREEN" "Commit e push realizados com sucesso. Processo finalizado."
	else
		p_log "$YELLOW" "Não há mudanças para commitar."
	fi
}

create_branch_and_push() {
	local mainbranch="$(get_main_branch)"
	local branch_type="$1"
	declare -g new_branch

	new_branch="${branch_type}-$(date +%Y-%m-%d_%H-%M)"
	p_log "$CYAN" "Atualizando o branch main..."

	# Certifique-se de estar no branch main e atualize-o
	if ! git checkout "$mainbranch"; then
		die "$RED" "Falha ao mudar para o branch main"
	fi
	if ! git pull origin "$mainbranch"; then
		die "$RED" "Falha ao atualizar o branch $mainbranch"
	fi
	p_log "$GREEN" "Branch ${mainbranch} atualizado"

	p_log "$CYAN" "Criando e mudando para o novo branch: $new_branch"
	if ! git checkout -b "$new_branch"; then
		die "$RED" "Falha ao criar novo branch"
	fi
	p_log "$GREEN" "Novo branch criado: $new_branch"

	# Realizar o push do novo branch
	p_log "$CYAN" "Realizando push para o GitHub..."
	if ! git push --set-upstream origin "$new_branch"; then
		die "$RED" "Falha ao realizar push"
	fi
	p_log "$GREEN" "Push realizado com sucesso para o branch $new_branch"

	# Voltar para o branch main e fazer push das alterações
	p_log "$CYAN" "Realizando push das alterações no branch main..."
	if ! git checkout "$mainbranch"; then
		die "$RED" "Falha ao mudar para o branch ${mainbranch}"
	fi

	if ! git push origin "$mainbranch"; then
		die "$RED" "Falha ao realizar push do branch ${mainbranch}"
	fi
	p_log "$GREEN" "Push realizado com sucesso para o branch ${mainbranch}"
}

get_url_actionsOLD() {
	# Requisição para listar as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO}/actions/runs")

	# Obter o ID da execução mais recente
	run_id=$(echo "$runs" | jq '.workflow_runs[0].id')

	# Construir a URL da action
	action_url="https://github.com/${REPO}/actions/runs/$run_id"
	echo "URL da Action: $action_url"
}

get_url_actions() {
	# Requisição para listar as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO}/actions/runs")

	# Obter o ID da execução mais recente
	run_id=$(echo "$runs" | jq '.workflow_runs | sort_by(.id) | last | .id')

	if [[ -z "$run_id" ]]; then
		echo "Nenhuma execução encontrada."
		return 1
	fi

	# Construir a URL da action
	action_url="https://github.com/${REPO}/actions/runs/$run_id"
	echo "URL da Action: $action_url"
}

delete_failed_runs() {
	local result

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO}/actions/runs")

	#  # Imprimir o JSON bruto para depuração
	#  echo "JSON bruto recebido:"
	#  echo "$runs" | jq '.'

	# Filtrar as execuções com conclusão de erro
	failed_runs=$(
		echo "$runs" | jq -r '
    .workflow_runs[] |
    select(.conclusion == "failure" or .conclusion == "cancelled" or .conclusion == "error") |
    .id'
	)

	# Se houver execuções com erro
	if [[ -n "$failed_runs" ]]; then
		echo "Executando exclusões para runs com erro..."

		# Loop sobre cada ID de execução com erro e excluí-los
		for run_id in $failed_runs; do
			echo "Excluindo run ID: $run_id"

			response=$(curl -s -X DELETE \
				-H "Accept: application/vnd.github.v3+json" \
				-H "Authorization: token $TOKEN_RELEASE" \
				"https://api.github.com/repos/${REPO}/actions/runs/$run_id")

			result="$?"
			# Verifique a resposta para confirmar a exclusão
			if [[ $result -eq 0 ]]; then
				echo "Run ID $run_id excluído com sucesso."
			else
				echo "Falha ao excluir o run ID $run_id."
			fi
		done
	else
		echo "Nenhuma execução com erro encontrada."
	fi
}

debug_json() {
	local result

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO}/actions/runs")

	# Imprimir o JSON bruto para depuração
	echo "JSON bruto recebido:"
	echo "$runs" | jq '.'

	# Filtrar as execuções com status de erro
	failed_runs=$(
		echo "$runs" | jq -r '
    .workflow_runs[] | 
    select(.status == "failure" or .status == "cancelled" or .status == "error") | 
    .id'
	)

	# Se houver execuções com erro
	if [[ -n "$failed_runs" ]]; then
		echo "Executando exclusões para runs com erro..."

		# Loop sobre cada ID de execução com erro e excluí-los
		for run_id in $failed_runs; do
			echo "Excluindo run ID: $run_id"

			response=$(curl -s -X DELETE \
				-H "Accept: application/vnd.github.v3+json" \
				-H "Authorization: token $TOKEN_RELEASE" \
				"https://api.github.com/repos/${REPO}/actions/runs/$run_id")

			result="$?"
			# Verifique a resposta para confirmar a exclusão
			if [[ "$result" -eq 0 ]]; then
				echo "Run ID $run_id excluído com sucesso."
			else
				echo "Falha ao excluir o run ID $run_id."
			fi
		done
	else
		echo "Nenhuma execução com erro encontrada."
	fi
}

trigger_workflow() {
	local package_name="$1"
	local branch_type="$2"
	local aur_package="$3"
	local data
	local event_type
	local response
	local repo_name

	p_log "$CYAN" "Acionando o workflow de build no GitHub..."

	if [[ -n "$aur_package" ]]; then
		aur_url="https://aur.archlinux.org/${package_name}.git"
		data="{\"event_type\": \"aur-$package_name\", \"client_payload\": { \"package_name\": \"${package_name}\", \"aur_url\": \"${aur_url}\", \"branch_type\": \"aur\", \"build_env\": \"aur\", \"tmate\": true}}"
		event_type="aur-build"
	else
		repo_name=$(git config --get remote.origin.url | sed 's/.*[:/]\([^/]*\/[^.]*\).*/\1/')
		if [[ -z "$repo_name" ]]; then
			die "$RED" "Deu ruim na recuperação da URL do repositório remoto do pacote: $package_name"
		fi
		p_log "$CYAN" "Repositório detectado: $repo_name"
		data="{\"event_type\": \"$package_name\", \"client_payload\": { \"branch\": \"${new_branch}\", \"type\": \"${branch_type}\", \"url\": \"https://github.com/${repo_name}\"}}"
		event_type="package-build"
	fi

	response=$(curl -s -X POST \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		--data "$data" \
		-w "%{http_code}" \
		-o /dev/null \
		"https://api.github.com/repos/${REPO}/dispatches")

	if [[ "$response" != "204" ]]; then
		die "$RED" "Erro '$response' ao acionar o workflow. Código de resposta: $response"
	fi

	p_log "$GREEN" "Workflow de build ($event_type) acionado com sucesso. Código de resposta: $response"
	p_log "$YELLOW" "Por favor, verifique a aba 'Actions' no GitHub para acompanhar o progresso do build."
	p_log "$orange" "Aguardando '2s' para a API acionar a Action e podermos pegar o 'id'."
	sleep 2
	p_log "$RESET" "$(get_url_actions)"
}

sh_configure_environment() {
	# Cores e estilos
	set_varcolors

	#debug
	export PS4='${RED}${0##*/}${GREEN}[$FUNCNAME]${PURPLE}[$LINENO]${RESET}'
	#set -x
	#set -e
	shopt -s extglob

	declare -g REPO="communitybig/build-package" # Repositório que contém os workflows
	declare -g ORGANIZATION="${REPO%%/*}"        # communitybig
	declare -g CFILETOKEN="$HOME/.GITHUB_TOKEN"  # path do arquivo que contem os tokens do github

	declare -g REPO_NAME="$(get_repo_name)"      # Obtém o nome do repositório utilizando a função get_repo_name
	declare -g REPO_PATH="$(get_repo_root_path)" # Obtém o caminho raiz do repositório utilizando a função get_repo_root_path

	# Define o diretório de log, armazenando os logs temporários do repositório
	declare -g LOG_DIR="/tmp/${APP}/${REPO_NAME}"
	declare -g LOG_FILE="${LOG_DIR}/gitrepo.log"
	[[ ! -d "$LOG_DIR" ]] && mkdir -p "$LOG_DIR"

	p_log "$BLUE" "Configurando ambiente"
	declare -g IS_GIT_REPO="$(check_repo_is_git)"
	declare -g IS_AUR_PACKAGE=false

	checkDependencies
	parse_parameters "$@"
	get_token_release # Obtem o TOKEN_RELEASE utilizando a função get_token_release
}

Apenas_fazer_commit_push() {
	if $IS_GIT_REPO; then
		update_commit_push
	else
		die "$RED" "Esta opção só está disponível em repositórios git."
	fi
	checkout_and_exit 0
}

Realizar_commit_e_gerar_pacote() {
	update_commit_push
	create_branch_and_push "$branch_type"
	package_name=$(get_package_name)
	trigger_workflow "$package_name" "$branch_type"
}

Construir_pacote_do_AUR() {
	local aur_package_name="$1"

	IS_AUR_PACKAGE=true

	# Verifica se existe um arquivo PKGBUILD
	if ! $IS_AUR_PACKAGE; then
		PKGBUILD_PATH=$(find "$REPO_PATH" -name PKGBUILD -print -quit)
		if [[ -z "$PKGBUILD_PATH" ]]; then
			die "$RED" "Erro: Nenhum arquivo PKGBUILD foi encontrado no diretório atual ou subdiretórios."
		else
			p_log "$GREEN" "Arquivo PKGBUILD encontrado em: $PKGBUILD_PATH"
			cd "$(dirname "$PKGBUILD_PATH")" || die "$RED" "Erro: não consegui entrar em $PKGBUILD_PATH"
		fi
	fi

	if [[ -z "$aur_package_name" ]]; then
		while true; do
			p_log "$PURPLE" "Digite o nome do pacote AUR (ex: showtime): digite ${YELLOW}SAIR ${PURPLE}para sair"
			read -r aur_package_name
			if [[ "${aur_package_name^^}" == "SAIR" ]]; then
				die "$YELLOW" "Saindo do script. Nenhuma ação foi realizada."
			elif [[ -z "$aur_package_name" ]]; then
				p_log "$RED" "Erro: Nenhum nome de pacote foi inserido."
				continue
			fi
			break
		done
	fi

	if $IS_GIT_REPO; then
		create_branch_and_push "aur"
	fi
	trigger_workflow "$aur_package_name" "aur" "true"
}

## main() { Início do script principal }
########################################

# Verificações iniciais
[[ "$1" = @(-V|--version) ]] && {
	sh_version
	exit $(($# ? 0 : 1))
}
[[ "$1" = @(-h|--help) ]] && {
	sh_usage
	exit $(($# ? 0 : 1))
}

sh_configure_environment "$@"
p_log "$BLUE" "Iniciando processo de gerenciamento de repositório (v${VERSION})"

while true; do
	# Menu principal
	if $IS_GIT_REPO; then
		create_menu "Escolha uma ação:" \
			"Apenas fazer commit/push" \
			"Realizar commit e gerar pacote" \
			"Construir pacote do AUR" \
			"Excluir todos os branchs locais e remoto (exceto main, e os últimos testing e stable)" \
			"Excluir todos os Action jobs com falhas no remoto" \
			"Sair"
	else
		create_menu "Escolha uma ação:" \
			"Construir pacote do AUR" \
			"Sair"
	fi
	ACTION=$MENU_RESULT

	case "$ACTION" in
	"Apenas fazer commit/push")
		Apenas_fazer_commit_push
		;;
	"Realizar commit e gerar pacote")
		if $IS_GIT_REPO; then
			create_menu "Selecione o tipo de branch:" \
				"testing" \
				"stable" \
				"Voltar"
			if [[ $MENU_RESULT == "Voltar" ]]; then
				continue
			fi
			branch_type=$MENU_RESULT
			Realizar_commit_e_gerar_pacote
			break
		else
			die "$RED" "Esta opção só está disponível em repositórios git."
		fi
		;;
	"Construir pacote do AUR")
		Construir_pacote_do_AUR
		break
		;;
	"Excluir todos os branchs locais e remoto (exceto main, e os últimos testing e stable)")
		gclean_branch_remote_and_update_local
		;;
	"Excluir todos os Action jobs com falhas no remoto")
		clean_failures_action_jobs_on_remote
		;;
	"Sair")
		p_log "$YELLOW" "Saindo do script. Nenhuma ação foi realizada."
		checkout_and_exit 1
		;;
	*)
		die "$RED" "Opção inválida selecionada."
		;;
	esac
done

checkout_and_exit 0
