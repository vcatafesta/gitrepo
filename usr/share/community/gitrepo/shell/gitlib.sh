#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# shellcheck shell=bash disable=SC1091,SC2039,SC2166,SC2317,SC2155,SC2034,SC2229,SC2076,SC2199,SC2015
#
#  /usr/share/community/gitrepo/shell/gitlib.sh - lib for gitrepo.sh and buildiso.sh
#  Created: qui 05 set 2024 00:51:12 -04
#  Altered: seg 23 dez 2024 23:28:25 -04
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
declare distro="$(uname -n)"
readonly DEPENDENCIES=('git' 'tput')
readonly organizations=('communitybig' 'biglinux' 'chililinux' 'talesam' 'vcatafesta')
readonly branchs=('testing' 'stable' 'extra')
shopt -s extglob # Habilita o uso de padrões estendidos (extglob)

# Funções auxiliares
conf() {
	read -r -p "$1 [S/n]"
	[[ ${REPLY^} == "" ]] && return 0
	[[ ${REPLY^} == N ]] && return 1 || return 0
}

check_param_org() {
	local value_organization="$1"
	if [[ ! " ${organizations[@]} " =~ " $value_organization " ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-o|--org|--organization' ${RESET};
${INFO}São válidos: ${orange}${organizations[*]}${reset}
${CYAN}ex.: $APP -o communitybig
     $APP --org biglinux
     $APP --organization chililinux${RESET}"
	fi
}

check_param_aur() {
	local value_aur="$1"
	if [[ -z "$value_aur" || "$value_aur" == -* ]]; then
		die "$RED" "Erro fatal: Valor inválido para o parâmetro ${YELLOW}'-a|--aur' ${RESET}
${INFO}O valor do parâmetro está vazio ou é outro/ou próximo parâmetro.
São válidos: Qualquer nome de pacote/string não vazia"
	fi
}

check_valid_token() {
	# Verificar o token
	#echo $TOKEN_RELEASE
	p_log "${cyan}" "Verificando permissões do token GitHub..."
	token_check=$(curl -s -H "Authorization: token $TOKEN_RELEASE" https://api.github.com/user)
	GITHUB_USER_NAME="$(echo "$token_check" | jq -r .login)"
	p_log "$cyan" "Token verificado: ${yellow}$GITHUB_USER_NAME"

	if [[ -z "$(echo "$token_check" | jq .login)" ]]; then
		if ! conf "=>${red}Token inválido ou sem permissões necessárias. Deseja prosseguir mesmo assim?"; then
			die "${red}" "Erro fatal: Token inválido ou sem permissões necessárias."
		fi
	fi
}

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
	#sed -n "/^$ORGANIZATION=/s/.*=//p" "$CFILETOKEN"
	#sed -n "/^$ORGANIZATION=/s/^[^=]*=\(.*\)$/\1/p" "$CFILETOKEN" | head -n 1
	sed -n "/^$ORGANIZATION=/s/.*=//p" "$CFILETOKEN" | awk 'NR==1'
}

get_token_release() {
	declare -g TOKEN_RELEASE
	if [[ ! -r "$CFILETOKEN" ]]; then
    #die "$RED" "Erro: Não foi possível ler o arquivo $CFILETOKEN"
    print_message_and_exit
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

# p_log
p_log() {
	local color="$1"
	local message="$2"
	local died="$3"

	[[ -z "$died" ]] && died=false
	#	echo -e "${color}=> ${message}${RESET}"
	if $died; then
		printf "${CROSS} => ${color}%s\n\033[m" "$message"
	else
		printf "${TICK} => ${color}%s\n\033[m" "$message"
	fi
	# Remover códigos de escape ANSI do log
	clean_log=$(sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\(B//g' <<<"$message")
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${clean_log}" >>"${LOG_FILE}"
}

die() {
	local color="$1"
	local message="$2"
	p_log "$color" "$message" true
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

		: "${COL_NC='\e[0m'}" # No Color
		: "${COL_LIGHT_GREEN='\e[1;32m'}"
		: "${COL_LIGHT_RED='\e[1;31m'}"
		: "${DONE="${COL_LIGHT_GREEN} done!${COL_NC}"}"
		: "${OVER="\\r\\033[K"}"
		: "${DOTPREFIX="  ${black}::${reset} "}"
		: "${TICK="${white}[${green}✓${rst}${white}]${rst}"}"
		: "${CROSS="${white}[${red}✗${rst}${white}]${rst}"}"
		: "${INFO="${white}[${gray}i${rst}${white}]${rst}"}"
	else
		unset_varcolors
	fi
}

unset_varcolors() {
	unset RED GREEN YELLOW BLUE PURPLE CYAN NC RESET BOLD
	unset reset rst bold underline nounderline reverse
	unset black red green yellow blue magenta cyan white gray orange purple violet
	unset light_red light_green light_yellow light_blue light_magenta light_cyan light_white
	unset preto vermelho verde amarelo azul roxo ciano branca cinza laranja roxa violeta
	TICK="${white}[${verde}✓${rst}${white}]${rst}"
	CROSS="${white}[${roxa}✗${rst}${white}]${rst}"
	INFO="${white}[${cinza}i${rst}${white}]${rst}"
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

	p_log "${RED}" "Exclui os branches remotos (exceto $mainbranch e os mais novos com prefixo: testing-, stable-, aur- e extra-) e atualiza o repositório local ${reset}"

	# Confirmar a operação
	read -r -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 2s"
		sleep 2
		return 1
	fi

	p_log "${YELLOW}" "$clean ${RED}checado. ${black}Prosseguindo com a exclusão dos branches remotos e locais ${reset}"
	# Obtém o nome do branch principal
	mainbranch="$(get_main_branch)"
	# Mudar para o branch principal
	git checkout "$mainbranch" >/dev/null 2>&1

	# Atualizar o repositório local para refletir as mudanças remotas
	p_log "${CYAN}" "Atualizando o repositório local para refletir as alterações remotas"
	git fetch --prune

	# Encontrar e ordenar os branches remotos com prefixo testing-, stable- e aur-
	p_log "${CYAN}" "Encontrar os branches remotos com prefixo testing-, stable- e aur-"
	remote_branches=$(git branch -r | grep -E 'origin/(testing-|stable-|aur-|extra-)' | sort)

	# Obter o mais recente de cada prefixo
	latest_testing_branch_remote=$(echo "$remote_branches" | grep 'origin/testing-' | tail -n 1)
	latest_stable_branch_remote=$(echo "$remote_branches" | grep 'origin/stable-' | tail -n 1)
	latest_aur_branch_remote=$(echo "$remote_branches" | grep 'origin/aur-' | tail -n 1)
	latest_extra_branch_remote=$(echo "$remote_branches" | grep 'origin/extra-' | tail -n 1)

	# Criar uma lista de branches remotos a manter
	branches_to_keep_remote="origin/$mainbranch"
	[[ -n "$latest_testing_branch_remote" ]] && branches_to_keep_remote+=" $latest_testing_branch_remote"
	[[ -n "$latest_stable_branch_remote" ]] && branches_to_keep_remote+=" $latest_stable_branch_remote"
	[[ -n "$latest_aur_branch_remote" ]] && branches_to_keep_remote+=" $latest_aur_branch_remote"
	[[ -n "$latest_extra_branch_remote" ]] && branches_to_keep_remote+=" $latest_extra_branch_remote"

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

get_git_last_commit_url() {
	# Obtém a URL do repositório
	repo_url=$(git config --get remote.origin.url | sed 's/.git$//')

	# Obtém o hash do último commit
	commit_hash=$(git log -1 --format="%H")

	# Constrói a URL do commit
	echo "${repo_url}/commit/${commit_hash}"
}

###############################################################################################################################################
create_menu_with_array() {
  local title=$1
  local -a options=("${!2}") # Recebe o array de opções
  local default=${3:-}       # Opção padrão, se fornecida
  local selected=0
  local key

  # Define a opção padrão como selecionada inicialmente
  if [[ -n "$default" ]]; then
    for i in "${!options[@]}"; do
      if [[ "${options[$i]}" == "$default" ]]; then
        selected=$i
        break
      fi
    done
  fi

	tput civis # Esconde o cursor

	while true; do
		tput clear # Limpa a tela
		if $IS_GIT_REPO; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Name      : ${CYAN}$REPO_NAME${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WORKFLOW${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo -e "Branchs        : \n${RED}$(git branch 2>/dev/null)${RESET}"
			git remote -v 2>/dev/null
			echo '---------------------------------------------------------------------------------'
		elif $IS_AUR_PACKAGE; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WORKFLOW${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo '---------------------------------------------------------------------------------'
		elif $IS_BUILD_ISO; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WORKFLOW${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo '---------------------------------------------------------------------------------'
		fi

		if $IS_BUILD_ISO_RESUME; then
      echo -e "Distroname     : ${cyan}$DISTRONAME ${reset}"
      echo -e "Iso-Profiles   : ${cyan}$ISO_PROFILES_REPO ${reset}"
      echo -e "Build dir      : ${cyan}$BUILD_DIR ${reset}"
      echo -e "Edition        : ${cyan}$EDITION ${reset}"
      echo -e "Br Manjaro     : ${cyan}$MANJARO_BRANCH ${reset}"
      echo -e "Br BigLinux    : ${cyan}$BIGLINUX_BRANCH ${reset}"
      echo -e "Br BigCommunity: ${cyan}$BIGCOMMUNITY_BRANCH ${reset}"
      echo -e "Br ChiliLinux  : ${cyan}$CHILILINUX_BRANCH ${reset}"
      echo -e "Kernel         : ${cyan}$KERNEL ${reset}"
			echo '---------------------------------------------------------------------------------'
    fi
		echo -e "${BLUE}${BOLD}$title${NC}\n"

		for i in "${!options[@]}"; do
			if [[ "$i" -eq $selected ]]; then
				if [[ "${options[$i]}" =~ ^(Sair|Voltar)$ ]]; then
          if [[ "$ORGANIZATION" =~ ^(chililinux|vcatafesta)$ ]]; then
  					echo -e "${RED}${BOLD}${reverse}> ${options[$i]}${NC}"
  				else
					  echo -e "${RED}${BOLD}> ${options[$i]}${NC}"
				  fi
				else
          if [[ "$ORGANIZATION" =~ ^(chililinux|vcatafesta)$ ]]; then
  					echo -e "${GREEN}${BOLD}${reverse}> ${options[$i]}${NC}"
  				else
	  				echo -e "${GREEN}${BOLD}> ${options[$i]}${NC}"
	  			fi
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

create_menu() {
	local title=$1
  shift # Avança apenas o título
	#	local options=("$@" "Sair")
	local options=("$@")
	local selected=0
	local key

	tput civis # Esconde o cursor

	while true; do
		tput clear # Limpa a tela
		if $IS_GIT_REPO; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Name      : ${CYAN}$REPO_NAME${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WORKFLOW${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo -e "Branchs        : \n${RED}$(git branch 2>/dev/null)${RESET}"
			git remote -v 2>/dev/null
			echo '---------------------------------------------------------------------------------'
		elif $IS_AUR_PACKAGE; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WORKFLOW${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo '---------------------------------------------------------------------------------'
		elif $IS_BUILD_ISO; then
			echo '---------------------------------------------------------------------------------'
			echo -e "Organization   : ${CYAN}$ORGANIZATION${RESET}"
			echo -e "Repo Workflow  : ${CYAN}$REPO_WOKFLOW${RESET}"
			echo -e "User Name      : ${CYAN}$GITHUB_USER_NAME${RESET}"
			echo -e "Local Path     : ${CYAN}$REPO_PATH${RESET}"
			echo '---------------------------------------------------------------------------------'
		fi

		if $IS_BUILD_ISO_RESUME; then
      echo -e "Distroname     : ${cyan}$DISTRONAME ${reset}"
      echo -e "Edition        : ${cyan}$EDITION ${reset}"
      echo -e "Iso-Profiles   : ${cyan}$ISO_PROFILES_REPO ${reset}"
      echo -e "Br Manjaro     : ${cyan}$MANJARO_BRANCH ${reset}"
      echo -e "Br BigLinux    : ${cyan}$BIGLINUX_BRANCH ${reset}"
      echo -e "Br BigCommunity: ${cyan}$BIGCOMMUNITY_BRANCH ${reset}"
      echo -e "Br ChiliLinux  : ${cyan}$CHILILINUX_BRANCH ${reset}"
      echo -e "Kernel         : ${cyan}$KERNEL ${reset}"
			echo '---------------------------------------------------------------------------------'
    fi
		echo -e "${BLUE}${BOLD}$title${NC}\n"

		for i in "${!options[@]}"; do
			if [[ "$i" -eq $selected ]]; then
				if [[ "${options[$i]}" =~ ^(Sair|Voltar)$ ]]; then
          if [[ "$ORGANIZATION" =~ ^(chililinux|vcatafesta)$ ]]; then
  					echo -e "${RED}${BOLD}${reverse}> ${options[$i]}${NC}"
  				else
					  echo -e "${RED}${BOLD}> ${options[$i]}${NC}"
				  fi
				else
          if [[ "$ORGANIZATION" =~ ^(chililinux|vcatafesta)$ ]]; then
  					echo -e "${GREEN}${BOLD}${reverse}> ${options[$i]}${NC}"
  				else
	  				echo -e "${GREEN}${BOLD}> ${options[$i]}${NC}"
	  			fi
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
		#die "$RED" "Erro: Arquivo PKGBUILD não encontrado."
		echo 'erro2'
	elif pkgname=$(grep -E "^pkgname=" "$pkgbuild_path" | cut -d'=' -f2) && [[ -z "$pkgname" ]]; then
		#die "$RED" "Erro: Nome do pacote não encontrado no PKGBUILD."
		echo 'erro3'
	fi
	echo "$pkgname"
}

update_commit_push() {
	local commit_message
	local mainbranch="$(get_main_branch)"

	if [[ "$USER" == "vcatafesta" ]]; then
		default_commit_message+=": $(date) Vilmar Catafesta (vcatafesta@gmail.com)"
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
		p_log "$GREEN" "Commit realizado com sucesso: ${yellow}$commit_message ${reset}"

		p_log "$CYAN" "Realizando push para o GitHub..."
		if ! git push --set-upstream origin "$mainbranch"; then
			die "$RED" "Erro: 'git push --set-upstream origin ${mainbranch}' - Falha ao realizar push"
		fi
		p_log "$YELLOW" "Commit hash: ${gray}$(get_git_last_commit_url)${reset}"
		p_log "$GREEN" "Commit e push realizados com sucesso. Processo finalizado."
	else
		p_log "$YELLOW" "Não há mudanças para commitar."
	fi
}

create_branch_and_push() {
	local mainbranch="$(get_main_branch)"
	local branch_type="$1"
	declare -g new_branch

	#new_branch="${branch_type}-$(date +%Y-%m-%d_%H-%M)"
	new_branch="${branch_type}-$(date +%Y%m%d_%H%M%S)"
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

get_url_actions() {
	# Requisição para listar as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO_WORKFLOW}/actions/runs")

	# Obter o ID da execução mais recente
	run_id=$(echo "$runs" | jq '.workflow_runs | sort_by(.id) | last | .id')

	if [[ -z "$run_id" ]]; then
		echo "Nenhuma execução encontrada."
		return 1
	fi

	# Construir a URL da action
	action_url="https://github.com/${REPO_WORKFLOW}/actions/runs/$run_id"
	echo "URL da Action: $action_url"
}

# Substitua a URL do remoto pelo valor de teste
get_organization_repo_name() {
	local remote_url
	local repo

	remote_url=$(git remote get-url origin)
	# Remover o prefixo 'https://github.com/' ou 'git@github.com:' e a sufixo '.git'
	repo="${remote_url#*github.com/}" # Remove tudo até 'github.com/'
	repo="${repo%.git}"               # Remove o sufixo '.git'
	echo "$repo"
}

delete_failed_runs() {
	local result
	local clean
	local REPO_WORKFLOW="$(get_organization_repo_name)"

	# Confirmar a operação
	read -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 2s"
		sleep 2
		return 1
	fi

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO_WORKFLOW}/actions/runs")

	#  # Imprimir o JSON bruto para depuração
	#echo "JSON bruto recebido:"
	#echo "$runs" | jq '.'

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
				"https://api.github.com/repos/${REPO_WORKFLOW}/actions/runs/$run_id")

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
	sleep 5
	exit 1
}

debug_json() {
	local result

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${REPO_WORKFLOW}/actions/runs")

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
				"https://api.github.com/repos/${REPO_WORKFLOW}/actions/runs/$run_id")

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

clean_failures_action_jobs_on_remote() {
	local token="$TOKEN_RELEASE"
	local repo
	repo="$(get_organization_repo_name)"
	local failed_jobs

	# Confirmação da operação
	p_log "${RED}" "Apagar todos os jobs de ação com falha do repositório remoto $repo"

	# Confirmar a operação
	read -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 2s"
		sleep 2
		return 1
	fi

	# Obter lista de jobs com falha ou cancelamento
	p_log "${CYAN}" "Obtendo lista de jobs com falhas ou cancelamentos..."
	failed_jobs=$(curl -s -H "Authorization: token $token" \
		"https://api.github.com/repos/$repo/actions/runs?status=failure" |
		jq -r '.workflow_runs[] | select(.conclusion == "failure" or .conclusion == "cancelled") | .id')

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${repo}/actions/runs")

	if [[ -z "$failed_jobs" ]]; then
		p_log "${YELLOW}" "Nenhum job com falha encontrado."
		sleep 5
		# Imprimir o JSON bruto para depuração
		echo "JSON bruto recebido:"
		#echo "$runs" | jq '.' | grep status
		echo "$runs" | jq '.' | grep -E '"(status|conclusion)"'
		exit 0
	fi

	# Deletar cada job com falha
	for run_id in $failed_jobs; do
		p_log "${CYAN}" "Deletando job com falha: $run_id"
		response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE -H "Authorization: token $token" \
			"https://api.github.com/repos/$repo/actions/runs/$run_id")

		if [[ "$response" -eq 204 ]]; then
			p_log "${GREEN}" "Job com falha $run_id deletado com sucesso."
		else
			p_log "${RED}" "Falha ao deletar job com falha $run_id. Código de resposta: $response"
		fi
	done
	sleep 5
	exit 0
}

clean_success_action_jobs_on_remote() {
	local token="$TOKEN_RELEASE"
	local repo
	repo="$(get_organization_repo_name)"
	local failed_jobs

	# Confirmação da operação
	p_log "${RED}" "Apagar todos os jobs de ação com sucesso e falhas do repositório remoto $repo"

	# Confirmar a operação
	read -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 2s"
		sleep 2
		return 1
	fi

	# Obter lista de jobs com falha ou cancelamento
	p_log "${CYAN}" "Obtendo lista de jobs com sucesso ou cancelados..."
	failed_jobs=$(curl -s -H "Authorization: token $token" \
		"https://api.github.com/repos/$repo/actions/runs?status=success" |
		jq -r '.workflow_runs[] | select(.conclusion == "success") | .id')

	# Requisição para listar todas as execuções da workflow
	runs=$(curl -s -X GET \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		"https://api.github.com/repos/${repo}/actions/runs")

	if [[ -z "$failed_jobs" ]]; then
		p_log "${YELLOW}" "Nenhum job encontrado."
		sleep 5
		# Imprimir o JSON bruto para depuração
		echo "JSON bruto recebido:"
		#echo "$runs" | jq '.' | grep status
		echo "$runs" | jq '.' | grep -E '"(status|conclusion)"'
		exit 0
	fi

	# Deletar cada job com falha
	for run_id in $failed_jobs; do
		p_log "${CYAN}" "Deletando job : $run_id"
		response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE -H "Authorization: token $token" \
			"https://api.github.com/repos/$repo/actions/runs/$run_id")

		if [[ "$response" -eq 204 ]]; then
			p_log "${GREEN}" "Job $run_id deletado com sucesso."
		else
			p_log "${RED}" "Falha ao deletar job $run_id. Código de resposta: $response"
		fi
	done
	sleep 5
	exit 0
}

clean_all_tags_on_remote() {
	local token="$TOKEN_RELEASE"
	local repo
	repo="$(get_organization_repo_name)"
	local failed_jobs

	# Confirmação da operação
	p_log "${RED}" "Apagar todas as tag do repositório remoto $repo"

	# Confirmar a operação
	read -p "${PURPLE}Digite --confirm para confirmar: " clean
	if [[ "$clean" != "--confirm" ]]; then
		p_log "${YELLOW}" "Operação cancelada. Retornando ao menu em 2s"
		sleep 2
		return 1
	fi

	p_log "${CYAN}" "Deletando tags..."
  if git tag -l | xargs -n 1 git push --delete origin; then
    git tag -l | xargs git tag -d
    git pull
    git push
    p_log "${GREEN}" "Todas tags deletadas com sucesso."
  else
		p_log "${RED}" "Falha ao deletar tags. Não encontradas"
  fi
	sleep 5
	exit 0
}

replicate() {
  local char=${1:-'#'}
  local nsize=${2:-$(tput cols)}
  local line
  printf -v line "%*s" "$nsize" && echo "${line// /$char}"
}
export -f replicate
