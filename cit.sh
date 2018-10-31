#!/bin/bash
getHelp () {
	echo '		 ________   ___   _________   
		|\   ____\ |\  \ |\___   ___\ 
		\ \  \___| \ \  \\|___ \  \_| 
		 \ \  \     \ \  \    \ \  \  
		  \ \  \____ \ \  \    \ \  \ 
		   \ \_______\\ \__\    \ \__\
		    \|_______| \|__|     \|__|'
	
	echo -e "\n***Bienvenido a la ayuda de CIT***\nPara utilizar CIT debes tener instalado convert y tesseract."
	echo -e "\nPara utilizar CIT simplemente ejecuta el archivo y espera las peticiones, \nen la primera te pedira la ruta en la cual estan los archivos que deseas convertir."
	echo -e "En la segunda deberas ingresar el tipo de archivo que deseas que sean convertidos.\nRecuerda separar los tipos de archivos por punto y coma ';' y no ponerles el punto 'jpg;png'."
	echo -e "\nAl finalizar tus archivos convertidos quedaran en la carpeta TU_DIRECTORIO/tifs/"
	echo -e "\n\nPara apoyar visita el repositorio en https://github.com/MilanDroid/CIT"
	exit 1                   
}

getParams () {
	read -p "Ruta en la que se encuentran los archivos: " -r
	if [ $REPLY == null ]
	then
		echo -e "Debe proporcionar una ruta."
		echo -e "[\e[5m....\e[25m] Saliendo..."
		sleep 2
	    exit 1
	else
		echo -e "Ruta: $REPLY\n"
		route="$REPLY"
		directory=$route/txt
	fi

	read -p "Escribe la extension de los archivos que deseas convertir (jpg, png, jpeg): " -r
	if [ $REPLY == null ]
	then
		echo -e "Debe proporcionar una extension valida."
		echo -e "[\e[5m....\e[25m] Saliendo..."
		sleep 2
	    exit 1
	else
		echo -e "Tipo de archivos: $REPLY\n"
		ext=(${REPLY//;/ })
	fi
}

checkRoute () {
	if [ ! -d "$route" ]
	then
		echo -e "[ \e[31mERROR\e[0m ] El directorio $route no existe..."
		exit 1
	else
		#Llenando el array con los elementos encontrados en la ruta otorgada
		IFS=!
		files=(`find $route -printf %f!`)
	fi
}

createDirectory () {
	if [ ! -d "$directory" ]
	then
		mkdir $directory || exit 1
		echo -e "[ \e[32mok\e[0m ] Directio $directory creado, aqui se guardaran los resultados"
	else
		read -p "El directorio $directory ya existe, desea eliminarlo y continuar con el proceso. Y/N?" -n 1 -r
		echo # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			echo -e "[\e[5m....\e[25m] Saliendo..."
			sleep 2
		    exit 1
		else
			echo -e "Eliminando directorio..."
			sleep 1
			sudo rm -rf "$directory/" || exit 1
			echo -e "[ \e[32mok\e[0m ] Directorio $directory/ eliminado"
			echo -e "Creando directorio..."
			sleep 1
			mkdir $directory || exit 1
			echo -e "[ \e[32mok\e[0m ] Directio $directory/ creado, aqui se guardaran los resultados"
			sleep 1
		fi
	fi

	if [ ! -d "$directory/tifs" ]
	then
		mkdir "$directory/tifs" || exit 1
	else
		read -p "El directorio $directory/tifs/ ya existe, desea eliminarlo y continuar con el proceso. Y/N?" -n 1 -r
		echo # (optional) move to a new line
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			echo -e "[\e[5m....\e[25m] Saliendo..."
			sleep 2
		    exit 1
		else
			echo -e "Eliminando directorio..."
			sleep 1
			sudo rm -rf "$directory/tifs/" || exit 1
			echo -e "[ \e[32mok\e[0m ] Directorio $directory/tifs/ eliminado"
			echo -e "Creando directorio..."
			sleep 1
			mkdir "$directory/tifs" || exit 1
		fi
	fi
}

convertFile () {
	alertError=0

	echo -e "Realizando conversion de $1 ..."
	convert "$route/$1" "$directory/tifs/${1%.*}.tif" || alertError=1
	tesseract "$directory/tifs/${1%.*}.tif" "$directory/${1%.*}" || alertError=2

	if [[ $alertError == 0 ]]; then
		echo -e "[ \e[32mok\e[0m ] Archivo saliente => $directory/${1%.*}.txt\n"
		let count++
	elif [[ $alerError == 1 ]]; then
		echo -e "[ \e[31mERROR\e[0m ] Error generando el archivo .tif ...\n"
		let countError++
	elif [[ $alerError == 2 ]]; then
		echo -e "[ \e[31mERROR\e[0m ] Error generando el archivo .txt ...\n"
		let countError++
	fi
}

getFiles () {
	count=0
	countError=0

	for i in ${!files[@]}
	do
		if [[ "${ext[@]}" =~ "${files[$i]##*.}" ]]
		then
		   	convertFile "${files[$i]}"
		fi
	done

	echo -e "\nEliminando archivos temporales en $directory/tifs/...\n"
	sudo rm -rf "$directory/tifs/" || exit 1
	echo -e "\e[32mCorrectos\e[0m: $count  \e[31mErrores\e[0m: $countError"
	echo -e "\nFinalizado, para ver los archivos ingresar a $directory/..."
	unset ALL_PROXY
}

while getopts ':h' option; do
	case "$option" in
	    h) 	getHelp
	    	;;
	   \?) 	printf "[ \e[31mERROR\e[0m ] Error: Option: '-%s$OPTARG' does not exist.">&2
			echo -e "\n\nTo get help use: '-h'"
	    	exit 1
	    	;;
	esac
done

getParams
checkRoute
createDirectory
getFiles
