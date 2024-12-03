#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# shellcheck shell=bash disable=SC1091,SC2039,SC2166
#
#  t
#  Created: 2024/12/03 - 10:58
#  Altered: 2024/12/03 - 10:58
#
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
#export LANGUAGE=pt_BR
export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=t

# Definir a variável de controle para restaurar a formatação original
reset=$(tput sgr0)

# Definir os estilos de texto como variáveis
bold=$(tput bold)
underline=$(tput smul)   # Início do sublinhado
nounderline=$(tput rmul) # Fim do sublinhado
reverse=$(tput rev)      # Inverte as cores de fundo e texto

# Definir as cores ANSI como variáveis
black=$(tput bold)$(tput setaf 0)
red=$(tput bold)$(tput setaf 196)
green=$(tput bold)$(tput setaf 2)
yellow=$(tput bold)$(tput setaf 3)
blue=$(tput setaf 4)
pink=$(tput setaf 5)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
gray=$(tput setaf 8)
orange=$(tput setaf 202)
purple=$(tput setaf 125)
violet=$(tput setaf 61)
light_red=$(tput setaf 9)
light_green=$(tput setaf 10)
light_yellow=$(tput setaf 11)
light_blue=$(tput setaf 12)
light_magenta=$(tput setaf 13)
light_cyan=$(tput setaf 14)
bright_white=$(tput setaf 15)

#debug
export PS4='${red}${0##*/}${green}[$FUNCNAME]${pink}[$LINENO]${reset}'
#set -x
#set -e
shopt -s extglob

#system
declare APP="${0##*/}"
declare _VERSION_="1.0.0-20241203"
declare distro="$(uname -n)"
declare DEPENDENCIES=(tput)
source /usr/share/fetch/core.sh

MostraErro() {
  echo "erro: ${red}$1${reset} => comando: ${cyan}'$2'${reset} => result=${yellow}$3${reset}"
}
trap 'MostraErro "$APP[$FUNCNAME][$LINENO]" "$BASH_COMMAND" "$?"; exit 1' ERR

declare -AG ApiProfiles=(
  # GitHub Repositories
  [https://github.com/communitybig/iso-profiles]='https://api.github.com/repos/communitybig/iso-profiles/contents/'
  [https://github.com/biglinux/iso-profiles]='https://api.github.com/repos/biglinux/iso-profiles/contents/'
  [https://github.com/chililinux/iso-profiles]='https://api.github.com/repos/chililinux/iso-profiles/contents/'
  [https://github.com/chililinux/manjaro-iso-profiles]='https://api.github.com/repos/chililinux/manjaro-iso-profiles/contents/'
  [https://github.com/talesam/iso-profiles]='https://api.github.com/repos/talesam/iso-profiles/contents/'
  [https://github.com/vcatafesta/iso-profiles]='https://api.github.com/repos/vcatafesta/iso-profiles/contents/'
  # GitLab Repositories
  [https://gitlab.manjaro.org/profiles-and-settings/iso-profiles.git]='https://gitlab.manjaro.org/api/v4/projects/profiles-and-settings%2Fiso-profiles/repository/tree'
)

die() {
  echo "$2"
  exit
}

get_edition() {
  local repo="$1"
  local dir="$2"
  local api_url="${ApiProfiles[$repo]}"
  local response

  # Verifica se o repositório existe no array
  if [[ -z "$api_url" ]]; then
    die "${red}" "Erro: Repositório não encontrado no array: $repo ${reset}"
  fi

  # Se for GitHub, faz a requisição
  if [[ "$api_url" == *"github"* ]]; then
    # Faz a requisição para o GitHub
    response=$(curl -sL "${api_url}${dir}")

    # Verifica se a resposta está vazia ou se ocorreu erro
    if [[ -z "$response" || "$response" == *"404 Not Found"* ]]; then
      die "${red}" "Erro: Problema ao acessar o diretório: $dir ${reset}"
    fi

    # Processamento para GitHub
    mapfile -t subdirs < <(
      echo "$response" | \
      jq -r '.[] | select(.type == "dir") | .name'
    )
  elif [[ "$api_url" == *"gitlab"* ]]; then
    # Faz a requisição para o GitLab (sem o diretório)
    response=$(curl -sL "${api_url}?path=${dir}")

    # Verifica se a resposta está vazia ou se ocorreu erro
    if [[ -z "$response" || "$response" == *"404 Not Found"* ]]; then
      die "${red}" "Erro: Problema ao acessar o repositório: $repo ${reset}"
    fi

    # Processamento para GitLab
    # Filtra os diretórios e pega o nome de cada um, excluindo os indesejados
    mapfile -t subdirs < <(
      echo "$response" | \
      jq -r '.[] | select(.type == "tree") | .name' | \
      grep -vE '^(shared|grub|temp_repo|.github)$'
    )
  else
    die "${red}" "Erro: Repositório desconhecido ${reset}"
  fi

  # Adiciona a opção "Voltar"
  subdirs+=("Voltar")
  echo "${subdirs[@]}"
}

get_edition 'https://gitlab.manjaro.org/profiles-and-settings/iso-profiles.git' manjaro
