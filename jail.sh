#!/bin/sh

##############################################
##											##
##		Por Daniel Garcia					##
##		contato@danielgarciaweb.com			##
##											##
##############################################

ACOMPANHAR=false
ESPACO='---------------------------------'
INSTALAR='--yes --force-yes --quiet debianutils coreutils'
SSHD_CONFIG="/etc/ssh/sshd_config"

APPS="/bin/bash /bin/cp /usr/bin/dircolors /bin/ls /bin/mkdir /bin/mv /bin/rm /bin/rmdir /bin/sh /bin/su /usr/bin/groups /usr/bin/id /usr/bin/rsync /usr/bin/ssh /usr/bin/scp /sbin/unix_chkpwd /bin/date /bin/cat /bin/touch /bin/uname /bin/stty /bin/sleep /bin/grep /bin/less /bin/bunzip2 /bin/grep /bin/fgrep /bin/sed /bin/tar /usr/bin/wget /usr/bin/unzip /bin/dir"

function estado
{
	echo -e '\n\n' $ESPACO '\n\033[1;5m  ' $1 ' \033[m\n' $ESPACO '\n\n'
	if $ACOMPANHAR; then
		echo -e '\n[PAUSA] Pressione enter para continuar, ou Ctrl+C para terminar...\n' 
		read
	fi
}

	echo -e '\033c'
	if [ "$(whoami &2>/dev/null)" != "root" ] && [ "$(id -un &2>/dev/null)" != "root" ] ; then
		echo -e "\033[1;41m \nERRO! Voce precisa ser root para executar! \033[m"
		exit
	fi
	if [ -f /etc/debian_version ]; then
		estado 'Distribuicao Debian encontrada!'
	else
		echo -e "\033[1;41m \nERRO! Apenas a distribuicao Debian e aceita! \033[m"
		exit
	fi

	echo -e "\033[1;41m ATENCAO!!\n\n O instalador ira desinstalar o existente.\n Faca backup de todos seus arquivos e banco de dados antes de continuar! \n\n\n\n Deseja continuar? (s/n) \033[m \c"
	read
	if test "$REPLY" = "s" || test "$REPLY" = "S"; then
		echo -e "\033[1;41m \n\n\n\n Deseja acompanhar o processo de instalacao? (s/n) \033[m \c"
		read
		if test "$REPLY" = "s" || test "$REPLY" = "S"; then
			ACOMPANHAR=true
		fi
		echo -e "\033c"
		
		if ! [ -z "$1" ] ; then
		  CHROOT_USUARIO=$1
		else
			echo -e "\nDigite o login do usuario: \c"
			read CHROOT_USUARIO
		fi
		
		if ! [ -z "$2" ] ; then
			if test "$2" = "padrao"; then
				SHELL=/bin/shell-chroot
			else
				SHELL=$2
			fi
		else
			echo -e "\n\nDigite o diretorio de arquivos binarios para o usuario $CHROOT_USUARIO.\n Ou digite \"padrao\" para o diretorio /bin/shell-chroot \n\n Diretorio bin: \c"
			read SHELL
				if [ "$SHELL" = "padrao" ]; then
					SHELL=/bin/shell-chroot
				fi
		fi
		
		if ! [ -z "$3" ] ; then
		  CAMINHO_USUARIO=$3
		else
		  CAMINHO_USUARIO="/home/usr/$CHROOT_USUARIO"
		fi
	else
		estado 'Finalizado'
		exit
	fi

	estado 'Atualizando o repositorio'
	apt-get update
	estado 'Instalando dependencias'
	apt-get install $INSTALAR

if [ -z "$PATH" ] ; then 
  PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin
fi


if [ -f /etc/debian_version ]; then
	estado 'Distribuicao Debian encontrada!'
	DISTRO=DEBIAN;
else
	echo -e "\033[1;41m \nERRO! Apenas a distribuicao Debian e aceita! \033[m"
	exit
fi

if ( test -f /usr/bin/which ) || ( test -f /bin/which ) || ( test -f /sbin/which ) || ( test -f /usr/sbin/which );
	then estado 'Dependencia which encontrada!'
else
	echo -e "\033[1;41m \nERRO! Dependencia which nao encontrada! \033[m"
	exit 1
fi

if [ 'which chroot' ];
	then estado 'Dependencia chroot encontrada!'
else
	echo -e "\033[1;41m \nERRO! Dependencia chroot nao encontrada! \033[m"
	exit 1
fi

if [ 'which sudo' ];
	then estado 'Dependencia sudo encontrada!'
else
	echo -e "\033[1;41m \nERRO! Dependencia sudo nao encontrada! \033[m"
	exit 1
fi

if [ 'which dirname' ];
	then estado 'Dependencia dirname encontrada!'
else
	echo -e "\033[1;41m \nERRO! Dependencia chroot nao encontrada! \033[m"
	exit 1
fi

if [ 'which awk' ];
	then estado 'Dependencia awk encontrada!'
else
	echo -e "\033[1;41m \nERRO! Dependencia awk nao encontrada! \033[m"
	exit 1
fi

if [ ! -f ${SSHD_CONFIG} ]
then
   echo -e "\033[1;41m \nERRO! Arquivo ${SSHD_CONFIG} nao encontrado!\n Ajuste o caminho do arquivo de configuracao: \n \$SSHD_CONFIG \033[m"
else
  if !(grep -v "^#" ${SSHD_CONFIG} | grep -i sftp-server &> /dev/null); then
    echo -e "\033[1;41m \nERRO! Nenhum servidor sftp instalado! \033[m"
  else SFTP_SERVER=$(grep -v "^#" ${SSHD_CONFIG} | grep -i sftp-server | awk  '{ print $3}')
  fi
fi

APPS="$APPS $SFTP_SERVER"

if ( id $CHROOT_USUARIO > /dev/null 2>&1 ) ; then
{
	echo -e "\033[1;41m ATENCAO!!\n\n O usuario $CHROOT_USUARIO existe!\n\n Deseja modificar o diretorio do usuario e trancar ele no diretorio? (sim/nao): \033[m \c"
	read MODIFICAR_USUARIO
	if [ "$MODIFICAR_USUARIO" != "sim" ]; then
		estado 'Finalizado!'
    exit 1
  fi
}
else
	CRIAR_USUARIO="sim"
fi

if [ -f ${SHELL} ] ; then
	estado 'Arquivo $SHELL existente'
else
	estado 'Criando o arquivo $SHELL!'
	echo '#!/bin/sh' > $SHELL
	echo "`which sudo` `which chroot` $CAMINHO_USUARIO /bin/su - \$USER" \"\$@\" >> $SHELL
	chmod 755 $SHELL
fi

if [ ! -d ${CAMINHO_USUARIO} ]; then
  mkdir -p ${CAMINHO_USUARIO}
  estado "Criando ${CAMINHO_USUARIO}"
fi
cd ${CAMINHO_USUARIO}

DIRETORIOS_TRANCAR="dev etc etc/pam.d bin home sbin usr usr/bin usr/lib"
for diretorio in $DIRETORIOS_TRANCAR ; do
  if [ ! -d "$CAMINHO_USUARIO/$diretorio" ] ; then
    mkdir $CAMINHO_USUARIO/"$diretorio"
    estado "Criando $CAMINHO_USUARIO/$diretorio"
  fi
done
echo

[ -r $CAMINHO_USUARIO/dev/urandom ] || mknod $CAMINHO_USUARIO/dev/urandom c 1 9
[ -r $CAMINHO_USUARIO/dev/null ]    || mknod -m 666 $CAMINHO_USUARIO/dev/null    c 1 3
[ -r $CAMINHO_USUARIO/dev/zero ]    || mknod -m 666 $CAMINHO_USUARIO/dev/zero    c 1 5
[ -r $CAMINHO_USUARIO/dev/tty ]     || mknod -m 666 $CAMINHO_USUARIO/dev/tty     c 5 0 

if [ "$1" != "atualizar" ]; then

estado "Modificando /etc/sudoers"
if grep -i '$CHROOT_USUARIO' /etc/sudoers; then
		echo '- Registros existentes' 
	else
		echo "$CHROOT_USUARIO       ALL=NOPASSWD: `which chroot`, /bin/su - $CHROOT_USUARIO" >> /etc/sudoers
fi

HOME_USR="$CAMINHO_USUARIO/home/$CHROOT_USUARIO"

if [ "$CRIAR_USUARIO" != "sim" ] ; then
estado "Modificando usuario $CHROOT_USUARIO. Copiando arquivos para \"$HOME_USR\""
usermod -d "$HOME_USR" -m -s "$SHELL" $CHROOT_USUARIO && chmod 700 "$HOME_USR"
fi

if [ "$CRIAR_USUARIO" = "sim" ] ; then {
estado "Adicionando usuario \"$CHROOT_USUARIO\" para o sistema"
echo -e "\nDigite uma senha para o usuario, atencao ao confirmar a senha!\n\n"
useradd -m -d "$HOME_USR" -s "$SHELL" $CHROOT_USUARIO && chmod 700 "$HOME_USR"

if !(passwd $CHROOT_USUARIO);
  then estado "As senhas nao sao iguais, tente novamente"
  exit 1;
fi
echo
}
fi

echo "#!/bin/bash" > usr/bin/groups
echo "id -Gn" >> usr/bin/groups
chmod 755 usr/bin/groups

if [ ! -f etc/passwd ] ; then
 grep /etc/passwd -e "^root" > ${CAMINHO_USUARIO}/etc/passwd
fi
if [ ! -f etc/group ] ; then
 grep /etc/group -e "^root" > ${CAMINHO_USUARIO}/etc/group

 grep /etc/group -e "^users" >> ${CAMINHO_USUARIO}/etc/group
fi

estado "Trancando usuario $CHROOT_USUARIO"
grep -e "^$CHROOT_USUARIO:" /etc/passwd | \
 sed -e "s#$CAMINHO_USUARIO##"      \
     -e "s#$SHELL#/bin/bash#"  >> ${CAMINHO_USUARIO}/etc/passwd

grep -e "^$CHROOT_USUARIO:" /etc/group >> ${CAMINHO_USUARIO}/etc/group

grep -e "^$CHROOT_USUARIO:" /etc/shadow >> ${CAMINHO_USUARIO}/etc/shadow
chmod 600 ${CAMINHO_USUARIO}/etc/shadow
#fim do atualizar
fi

estado "Copiando bibliotecas necessarias"

TMPFILE1=`mktemp` &> /dev/null ||  TMPFILE1="${HOME}/ldlist"; if [ -x ${TMPFILE1} ]; then mv ${TMPFILE1} ${TMPFILE1}.bak;fi
TMPFILE2=`mktemp` &> /dev/null ||  TMPFILE2="${HOME}/ldlist2"; if [ -x ${TMPFILE2} ]; then mv ${TMPFILE2} ${TMPFILE2}.bak;fi

for app in $APPS;  do
    if [ -x $app ]; then
        app_path=`dirname $app`
        if ! [ -d .$app_path ]; then
            mkdir -p .$app_path
        fi
		cp -p $app .$app
        ldd $app >> ${TMPFILE1}
    fi
done

for libs in `cat ${TMPFILE1}`; do
   frst_char="`echo $libs | cut -c1`"
   if [ "$frst_char" = "/" ]; then
     echo "$libs" >> ${TMPFILE2}
   fi
done
for lib in `cat ${TMPFILE2}`; do
    mkdir -p .`dirname $lib` > /dev/null 2>&1
    cp $lib .$lib
done

/bin/rm -f ${TMPFILE1}
/bin/rm -f ${TMPFILE2}

cp /usr/lib/libssl.so.0.9.8 /lib/libnss_compat.so.2 /lib/libnsl.so.1 /lib/libnss_files.so.2 /lib/libcap.so.1 /lib/libnss_dns.so.2 ${CAMINHO_USUARIO}/lib/

estado "Copiando arquivos de /etc/pam.d/"
cp /etc/pam.d/* ${CAMINHO_USUARIO}/etc/pam.d/

estado "Copiando modulos PAM"
cp -r /lib/security ${CAMINHO_USUARIO}/lib/

cp -r /etc/security ${CAMINHO_USUARIO}/etc/
cp /etc/login.defs ${CAMINHO_USUARIO}/etc/

if [ -f /etc/DIR_COLORS ] ; then
  cp /etc/DIR_COLORS ${CAMINHO_USUARIO}/etc/
fi 

chown root.root ${CAMINHO_USUARIO}/bin/su
chmod 700 ${CAMINHO_USUARIO}/bin/su

estado 'Finalizado'
exit

