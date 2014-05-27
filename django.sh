#!/bin/bash

##############################################
##											##
##		Por Daniel Garcia					##
##		contato@danielgarciaweb.com			##
##											##
##############################################

if test "$1" == ""; then
	echo '[USO] novoprojeto.sh nome_do_projeto'
	exit
fi

ACOMPANHAR=false
QUEBRA='---------------------------------'
INSTALAR='--yes --force-yes --quiet python python-virtualenv nginx python-flup'
NOME_PROJETO=$1

function estado
{
	echo -e '\n\n' $QUEBRA '\n\033[1;5m  ' $1 ' \033[m\n' $QUEBRA '\n\n'
	if $ACOMPANHAR; then
		echo -e '[PAUSA] Pressione enter para continuar, ou Ctrl+C para terminar...\n' 
		read
	fi
}

function instalar
{
	estado 'Atualizando informacoes do repositorio'
	sudo apt-get update
	estado 'Instalando dependencias'
	sudo apt-get install $INSTALAR
	estado 'Configurando o ambiente virtual (python-virtualenv) em ./'$NOME_PROJETO
	virtualenv --distribute --unzip-setuptools $NOME_PROJETO
	if ! grep /$NOME_PROJETO/manage.py ~/.bashrc;
	then
		estado 'Adicionando o alias $VIRTUAL_ENV/'$NOME_PROJETO'/manage.py em ~/.bashrc'
		echo "alias manage='python "$VIRTUAL_ENV"/"$NOME_PROJETO"/manage.py'" >> ~/.bashrc
	fi
	source ~/.bashrc
	estado 'Ativando o ambiente virtual'
	cd $NOME_PROJETO
	source bin/activate
	estado 'Iniciando projeto Django em ./'$NOME_PROJETO
	django-admin startproject $NOME_PROJETO
	estado 'Instalando Django no ambiente virtual'
	pip install django==1.4.1
}

if test "$2" != "-s"; then
	echo -e "\033[1;41m ATENCAO!!\n\n O instalador ira sobrescrever a configuracao o existente.\n Faca backup de todos seus arquivos antes de continuar! \n\n\n\n Deseja continuar? (s/n) \033[m \c"
	read
	if test "$REPLY" = "s" || test "$REPLY" = "S"; then
		echo -e "\033[1;41m \n\n\n\n Deseja acompanhar o processo de configuracao? (s/n) \033[m \c"
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