#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# shellcheck shell=bash disable=SC1091,SC2039,SC2166,SC2317,SC2155,SC2034,SC2229,SC2076,SC2199,SC2015
#
#  gitrepo.sh - Wrapper git para o BigCommunity
#  Created: ter 10 set 2024 11:02:02 -04
#  Altered: ter 10 set 2024 21:22:54 -04
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
declare APPDESC="Wrapper para construção de ISO BigCommunity"
declare VERSION="1.1.0" # Versão do script
LIBRARY=${LIBRARY:-"$PWD"}
source "$LIBRARY"/lib.sh

# Função para exibir informações de ajuda
sh_usage() {
	cat <<-EOF
    ${reset}${APP} v${VERSION} - ${APPDESC}${reset}
    ${red}Uso: ${reset}$APP ${cyan}[opções]${reset}

        ${cyan}Opções:${reset}
          -o|--org|--organization ${orange}<name> ${cyan} # Configura organização de trabalho no Github ${yellow}(default: talesam)${reset}
          -n|--nocolor                   ${cyan} # Suprime a impressão de cores ${reset}
          -V|--version                   ${cyan} # Imprime a versão do aplicativo ${reset}
          -h|--help                      ${cyan} # Mostra este Help ${reset}
	EOF
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
		-n | --nocolor)
			unset_varcolors
			shift # past argument
			;;
		-o | --org | --organization)
			param_organization="$1"
			value_organization="$2"
			# Teste se o parâmetro foi fornecido e se o valor é válido
			check_param_org "$value_organization"
			param_organization_was_supplied=true
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
	get_token_release # Obtem o TOKEN_RELEASE utilizando a função get_token_release
}

sh_configure_environment() {
	#debug
	export PS4='${RED}${0##*/}${GREEN}[$FUNCNAME]${PURPLE}[$LINENO]${RESET}'
	#set -x
	#set -e

	declare -g REPO="talesam/build-package" 			# Repositório que contém os workflows
	declare -g ORGANIZATION="${REPO%%/*}"         # talesam
	declare -g CFILETOKEN="$HOME/.GITHUB_TOKEN"   # path do arquivo que contem os tokens do github

	declare -g REPO_NAME="$(get_repo_name)"      # Obtém o nome do repositório utilizando a função get_repo_name
	declare -g REPO_PATH="$(get_repo_root_path)" # Obtém o caminho raiz do repositório utilizando a função get_repo_root_path

	# Define o diretório de log, armazenando os logs temporários do repositório
	declare -g LOG_DIR="/tmp/${APP}/${REPO_NAME}"
	declare -g LOG_FILE="${LOG_DIR}/${APP}.log"
	[[ ! -d "$LOG_DIR" ]] && mkdir -p "$LOG_DIR"

	p_log "$BLUE" "Configurando ambiente"
	declare -g IS_GIT_REPO=false
	declare -g IS_BUILD_ISO=true
	declare -g IS_AUR_PACKAGE=false

	checkDependencies
	parse_parameters "$@"
}

# Função para disparar o workflow
trigger_workflow() {
	local current_datetime=$(date "+%Y-%m-%d_%H-%M")
	local event_type="ISO-${EDITION^^}"
	local tmate_option=$([ "$TMATE" == "sim" ] && echo "true" || echo "false")
	local data="{\"event_type\": \"$event_type\", \"client_payload\": { \"edition\": \"$EDITION\", \"manjaro_branch\": \"$MANJARO_BRANCH\", \"community_branch\": \"$COMMUNITY_BRANCH\", \"biglinux_branch\": \"$BIGLINUX_BRANCH\", \"kernel\": \"$KERNEL\", \"release_tag\": \"$current_datetime\", \"tmate\": $tmate_option}}"

	p_log "${CYAN}" "Disparando workflow para $event_type${NC}"
	response=$(curl -s -X POST \
		-H "Accept: application/vnd.github.v3+json" \
		-H "Authorization: token $TOKEN_RELEASE" \
		--data "$data" \
		-w "%{http_code}" \
		-o /dev/null \
		"https://api.github.com/repos/${REPO}/dispatches")

	if [ "$response" != "204" ]; then
		die "{RED}" "Erro ao acionar o workflow. Código de resposta: $response${NC}"
	fi

	p_log "${GREEN}" "Workflow de build da ISO $event_type acionado com sucesso.${NC}"
	p_log "${YELLOW}" "Por favor, verifique a aba 'Actions' no GitHub para acompanhar o progresso do build.${NC}"
	if [ "$TMATE" == "sim" ]; then
		p_log "${YELLOW}" "A sessão TMATE será ativada. Fique atento às informações de conexão nos logs do GitHub Actions.${NC}"
	fi

	checkout_and_exit 0
}

## main() { Início do script principal }
########################################
# Verificações iniciais

# Cores e estilos
nocolor=false
set_varcolors
# Loop através de todos os parâmetros ($@)
for arg in "$@"; do
	if [[ "$arg" = @(-n|--nocolor) ]]; then
		nocolor=true
		[[ "$nocolor" == "true" ]] && unset_varcolors || set_varcolors
	elif [[ "$arg" = @(-V|--version) ]]; then
		sh_version
		exit $(($# ? 0 : 1))
	elif [[ "$arg" = @(-h|--help) ]]; then
		sh_usage
		exit $(($# ? 0 : 1))
	fi
done

sh_configure_environment "$@"
p_log "${BLUE}" "${BOLD}Construção de ISO BigCommunity (versão $VERSION)${NC}\n"

while true; do
	create_menu \
		"Escolha uma opção de branch para o Manjaro:" \
		"Stable" \
		"Testing" \
		"Unstable" \
		"Sair"

	if [[ $MENU_RESULT == "Sair" ]]; then
		die "${RED}" "Construção da ISO cancelada.${NC}"
	fi
	MANJARO_BRANCH=${MENU_RESULT,,} # Converte para minúsculas

	create_menu \
		"Escolha uma opção de branch para o Community:" \
		"Stable" \
		"Testing" \
		"Voltar"
	if [[ $MENU_RESULT == "Voltar" ]]; then
		continue
	fi

	COMMUNITY_BRANCH=${MENU_RESULT,,}

	create_menu \
		"Escolha uma opção para o branch BigLinux:" \
		"Stable" \
		"Testing" \
		"Voltar"
	if [[ $MENU_RESULT == "Voltar" ]]; then
		continue
	fi
	BIGLINUX_BRANCH=${MENU_RESULT,,}

	create_menu \
		"Escolha a versão do kernel:" \
		"LTS" \
		"Latest" \
		"OldLTS" \
		"Voltar"
	if [[ $MENU_RESULT == "Voltar" ]]; then
		continue
	fi
	KERNEL=${MENU_RESULT,,}

	create_menu \
		"Escolha a edição:" \
		"Cinnamon" \
		"Cosmic" \
		"Deepin" \
		"Gnome" \
		"KDE" \
		"XFCE" \
		"Wmaker" \
		"Voltar"
	if [[ $MENU_RESULT == "Voltar" ]]; then
		continue
	fi
	EDITION=${MENU_RESULT,,}

	create_menu \
		"Ativar sessão de debug TMATE?" \
		"Sim" \
		"Não" \
		"Voltar"
	if [[ $MENU_RESULT == "Voltar" ]]; then
		continue
	fi
	TMATE=${MENU_RESULT,,}

	# Confirmar as escolhas
	echo -e "\n${cyan}Resumo das escolhas:${rst}"
	echo "Manjaro Branch  : ${orange}$MANJARO_BRANCH ${rst}"
	echo "Community Branch: ${orange}$COMMUNITY_BRANCH ${rst}"
	echo "BigLinux Branch : ${orange}$BIGLINUX_BRANCH ${rst}"
	echo "Kernel          : ${orange}$KERNEL ${rst}"
	echo "Edition         : ${orange}$EDITION ${rst}"
	echo "Release Tag     : ${orange}$(date "+%Y-%m-%d_%H-%M") ${rst}"
	echo "TMATE Debug     : ${orange}$TMATE ${rst}"
	echo

	if conf "${YELLOW}Deseja prosseguir com a construção da ISO?"; then
		trigger_workflow
	else
		die "${RED}" "Construção da ISO cancelada."
	fi
done