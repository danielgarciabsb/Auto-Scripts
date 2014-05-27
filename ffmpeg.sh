#!/bin/bash

##############################################
##											##
##		Por Daniel Garcia					##
##		contato@danielgarciaweb.com			##
##											##
##############################################

ACOMPANHAR=false
ESPACO='---------------------------------'
INSTALAR='--yes --force-yes --quiet ffmpeg'

function estado
{
	echo -e '\n\n' $ESPACO '\n\033[1;5m  ' $1 ' \033[m\n' $ESPACO '\n\n'
	if $ACOMPANHAR; then
		echo -e '[PAUSA] Pressione enter para continuar, ou Ctrl+C para terminar...\n' 
		read
	fi
}

function instalar
{
	estado 'Atualizando o repositorio'
	apt-get update
	estado 'Removendo o FFmpeg'
	apt-get autoremove --purge $INSTALAR
	apt-get remove --purge $INSTALAR
	apt-get clean --purge $INSTALAR
	apt-get autoclean --purge $INSTALAR
	estado 'Instalando o FFmpeg'
	apt-get install $INSTALAR
}

echo -e '\033c'
if [ "$(whoami &2>/dev/null)" != "root" ] && [ "$(id -un &2>/dev/null)" != "root" ] ; then
	echo -e "\033[1;41m \nERRO! Voce precisa ser root para executar! \033[m"
	exit
fi
if test "$1" != "-s"; then
	echo -e "\033[1;41m ATENCAO!!\n\n O instalador ira desinstalar o existente.\n Faca backup de todos seus arquivos e banco de dados antes de continuar! \n\n\n\n Deseja continuar? (s/n) \033[m \c"
	read
	if test "$REPLY" = "s" || test "$REPLY" = "S"; then
		echo -e "\033[1;41m \n\n\n\n Deseja acompanhar o processo de instalacao? (s/n) \033[m \c"
		read
		if test "$REPLY" = "s" || test "$REPLY" = "S"; then
			ACOMPANHAR=true
		fi
		instalar
	fi
else
	instalar
fi

estado 'Finalizado'