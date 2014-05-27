#!/bin/bash

##############################################
##											##
##		Por Daniel Garcia					##
##		contato@danielgarciaweb.com			##
##											##
##############################################

ACOMPANHAR=false
ESPACO='---------------------------------'
INSTALAR='--yes --force-yes --quiet build-essential libxslt1-dev libvorbis-dev libmp3lame-dev'

REPOSITORIO=("deb http://www.debian-multimedia.org squeeze main non-free" "deb ftp://ftp.debian-multimedia.org squeeze main non-free" "deb http://www.debian-multimedia.org stable main non-free" "deb ftp://ftp.debian-multimedia.org stable main non-free")

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
	estado 'Conferindo o repositorio'
	if grep -i 'debian-multimedia.org' /etc/apt/sources.list; then
		echo '- Registros existentes' 
	else
		for item in "${REPOSITORIO[@]}"; do
			echo $item >> /etc/apt/sources.list
			echo -e "Inserido: $item >> /etc/apt/sources.list"
		done
		echo -e "\n-> Registros adicionados no repositorio" 
	fi
	estado 'Atualizando o repositorio'
	apt-get update
	estado 'Removendo o Ices e LibShout'
	if cd /usr/local/src/ices-0.4; then
		make clean
		make uninstall
	fi
	cd /usr/local/src
	rm -rf ./ices-0.4
	if cd /usr/local/src/libshout-2.2.2; then
		make clean
		make uninstall
	fi
	cd /usr/local/src
	rm -rf ./libshout-2.2.2
	apt-get remove --purge $INSTALAR
	apt-get clean --purge $INSTALAR
	apt-get autoclean --purge $INSTALAR
	estado 'Baixando o Ices e LibShout'
	cd /usr/local/src
	rm ices-0.4.tar.gz
	rm libshout-2.2.2.tar.gz
	wget http://downloads.us.xiph.org/releases/ices/ices-0.4.tar.gz
	wget http://downloads.us.xiph.org/releases/libshout/libshout-2.2.2.tar.gz
	estado 'Instalando dependencias'
	apt-get install $INSTALAR
	estado 'Descompactando o Ices e LibShout'
	tar -xvf ices-0.4.tar.gz
	tar -xvf libshout-2.2.2.tar.gz
	estado 'Configurando o LibShout'
	cd libshout-2.2.2
	./configure
	estado 'Instalando o LibShout'
	make
	make install
	estado 'Configurando o Ices'
	cd /usr/local/src
	cd ices-0.4
	./configure
	estado 'Instalando o Ices'
	make
	make install
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