#!/bin/bash

# argumentos
ARG1=$1
ARG2=$2
userAgent="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 B1C4-H4CK1NG/1.0.0"

# validando
echo """
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░██████╗░░░███╗░░░█████╗░░░██╗██╗░░░░░░░░
░░██╔══██╗░████║░░██╔══██╗░██╔╝██║░░░░░░░░
░░██████╦╝██╔██║░░██║░░╚═╝██╔╝░██║░░░░░░░░
░░██╔══██╗╚═╝██║░░██║░░██╗███████║░░░░░░░░
░░██████╦╝███████╗╚█████╔╝╚════██║░░░░░░░░
░░╚═════╝░╚══════╝░╚════╝░░░░░░╚═╝v1.0.0░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"""

# validando paramtros
if ! [ -n "$ARG1" ]; then
        echo "[MODO DE USO] ./B1C4.sh <url-alvo/ip-alvo> [--arquivos,--diretorios,--ajuda]"
        exit 0
fi

echo "[1] SCANNER/OSINT COMPLETO"
echo -e "SELECIONE UMA OPCAO PARA O ALVO: \c"
read opcaoEscolhida

echo "[1] DEMORADO (1-2 horas)"
echo "[2] RAPIDO (10-20 minutos)"
echo -e "SELECIONE UM MODO DE EXECUCAO: \c"
read modoExecucao

# setando as variaveis padrão de wordlist
wordlistDiretorio="wordlist_grande_diretorio.txt"
wordlistArquivo="wordlist_grande_arquivo.txt"

# verifica o modo de execução
if [ $modoExecucao == "2" ] || [ $modoExecucao == 2 ]
then
wordlistDiretorio="wordlist_pequena_diretorio.txt"
wordlistArquivo="wordlist_pequena_arquivo.txt"
#wordlistArquivo="wordlist_pequena_arquivo_tray.txt"
fi

# verificando se tem um argumento de scan especifico
tudo=true
soDiretorios=false
soArquivos=false

if [ -n "$ARG2" ]
then
        if [ $ARG2 == '--arquivos' ]
        then
                tudo=false
                soArquivos=true
                soDiretorios=false
        elif [ $ARG2 == '--diretorios' ]
        then
                tudo=false
                soDiretorios=true
                soArquivos=false
        elif [ $ARG2 == '--ajuda' ]
        then
                echo "./B1C4.sh <url-alvo/ip-alvo>
                --arquivos    = Executa Apenas o Brute Force de Arquivos
                --diretorios  = Executa Apenas o Brute Force de Diretórios
                --ajuda       = Exibe o Menu de Ajuda"
        else
                tudo=true
                soDiretorios=true
                soArquivos=true
        fi
fi

##################
#tudo=false
#soDiretorios=false
#soArquivos=false



######################## BUSCANDO E GRAVANDO INFO SERVER ########################
echo "##### BUSCANDO INFO SERVER #####"
INFO_ALVO=$(echo $ARG1 | cut -d ":" -f 2 | sed 's@//@@') # tratando a URL
INFO_IP=$(echo $INFO_IP | cut -d " " -f 1)
INFO_IP=$(host $INFO_ALVO | cut -d " " -f 4)
INFO_SISTEMA="NAO ENCONTRADO"
INFO_SERVIDOR=$(curl -s -I -H "$userAgent" --head $ARG1 | grep -i "server" | cut -d ":" -f 2)
INFO_TECNOLOGIA=$(curl -s -I -H "$userAgent" --head $ARG1 | grep -i "X-Powered-By" | cut -d ":" -f 2)
echo ""

INFO_SISTEMA2=$(echo $INFO_SERVIDOR | sed -e 's/[()]//g' | cut -d " " -f 2)
INFO_SERVIDOR=$(echo $INFO_SERVIDOR | sed -e 's/[()]//g' | cut -d " " -f 1)
INFO_TECNOLOGIA=$(echo $INFO_TECNOLOGIA | sed -e 's/[()]//g')

if [ -n "$INFO_SISTEMA2" ]
then
        INFO_SISTEMA=$(echo $INFO_SISTEMA)
fi




######################## BUSCANDO E GRAVANDO SUBDOMINIO ########################
#echo "##### BUSCANDO SUBDOMINIOS #####"
#echo '' > sub.txt
#for subdominio in $(cat 'wordlist_pequena_subdominio.txt')
#do
#        if host $subdominio.$INFO_ALVO | grep -v -i "NXDOMAIN" | grep -i "$INFO_ALVO"
#        then
#              echo "<tr> <td> $subdominio.$INFO_ALVO </td> </tr>" | grep -i "<tr>" >> sub.txt
#        fi
#done

SUBS="<tr> <td> Nenhum Registro </td> </tr>"
SUBS=$(cat sub.txt | grep -i "<tr>")
SUBS_IP="$SUBS"




######################## BUSCANDO E GRAVANDO LINK ########################
echo "##### BUSCANDO LINKS #####"
curl -s -H "$userAgent" $ARG1 | grep -io -E "href=[\"'](.*)[\"'] " | sort > links.txt # | cut -d "\"" -f 2

echo '' > links2.txt
for link in $(cat links.txt)
do
        echo "<tr> <td> $link </td> </tr>" >> links2.txt
done

LINKS="<tr> <td> Nenhum Registro </td> </tr>"
LINKS=$(cat links2.txt | grep -i "<tr>")




######################## BUSCANDO E GRAVANDO SCRIPTS ########################
echo "##### BUSCANDO SCRIPTS #####"
curl -s  -H "$userAgent" $ARG1 | grep -i "<script" | cut -d "\"" -f 2 | sort > scripts.txt

echo '' > scripts2.txt
for scripts in $(cat scripts.txt)
do
        echo "<tr> <td> $scripts </td> </tr>" >> scripts2.txt
done

SCRIPTS="<tr> <td> Nenhum Registro </td> </tr>"
SCRIPTS=$(cat scripts2.txt | grep -i "<tr>")




######################## BUSCANDO E GRAVANDO DIRETORIOS ########################
if "$tudo" || "$soDiretorios"
then
        echo "##### BUSCANDO DIRETORIOS #####"
        echo '' > dir.txt
        
        for palavra in $(cat $wordlistDiretorio)
        do
                #curl -s -L -H "$userAgent"  $ARG1/$palavra
                resposta=$(curl -s -L -H "$userAgent" -o /dev/null -w "%{http_code}" $ARG1/$palavra)

                # ESSE CARA E TIPO UM DEBUG
                # echo $resposta

                if [ $resposta == "200" ] || [ $resposta == 200 ]
                then
                        echo "<tr> <td> $palavra </td> </tr>" >> dir.txt
                fi
done
fi

DIRS="<tr> <td> Nenhum Registro </td> </tr>"
DIRS=$(cat dir.txt | grep -i "<tr>")





####################### IF DE VERIFICAÇÃO DO FILTRO #######################
if "$tudo" == true || "$soArquivos"
then

        echo "##### BUSCANDO ARQUIVOS #####"
        echo '' > arquivos.txt
        
        for arquivo in $(cat $wordlistArquivo)
        do
                resposta2=$(curl -s -L -H "$userAgent" -o /dev/null -w "%{http_code}" $ARG1/$arquivo)

                # ESSE CARA E TIPO UM DEBUG
                respostaOK=$(echo "$resposta2" | grep -iw "200")

                echo "[$respostaOK] => $arquivo" | grep -iw "200"

                # if [[ $resposta2 == "200" ]] || [[ $resposta2 == 200 ]]; then
                #         echo "<tr> <td> $arquivo </td> </tr>" >> arquivos.txt
                # fi
        done

fi

ARQUIVOS="<tr> <td> Nenhum Registro </td> </tr>"
ARQUIVOS=$(cat arquivos.txt | grep -i "<tr>")


echo "<!doctype html> <html> <head> <meta charset='UTF-8' /> <meta name='viewport' content='width=device-width, initial-scale=1'> <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css' rel='stylesheet' integrity='sha384-KyZXEAg3QhqLMpG8r+8fhAXLRk2vvoC2f3B09zVXn8CA5QIVfZOJ3BCsw2P0p/We' crossorigin='anonymous'> <link href='https://getbootstrap.com/docs/5.1/examples/features/features.css' rel='stylesheet'> <title>W3B R3C0N - B1C4</title> </head> <body class='bg-dark'> <h1 class='text-white text-center mt-5 mb-5'>$INFO_ALVO</h1> <div class='container'> <div class='row'> <!-- INFO / SUBDOMINIO / DNS --> <div class='col-lg-12 text-white'> <div class='container px-2 py-2' id='featured-3'> <div class='row g-4 py-3 row-cols-1 row-cols-lg-3'> <!-- INFO SERVER --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-globe'></i> </div> <h2>Info. do Server</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> <tr> <td><i class='fas fa-globe-americas'></i> IP: $INFO_IP</td> </tr> <tr> <td><i class='fab fa-linux'></i> SISTEMA: $INFO_SISTEMA</td> </tr> <tr> <td><i class='fab fa-linux'></i> SERVIDOR: $INFO_SERVIDOR</td> </tr> <tr> <td><i class='fab fa-php'></i> TECNOLOGIA: $INFO_TECNOLOGIA</td> </tr> </tbody> </table> </p> </div> <!-- DNS 1 --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-server'></i> </div> <h2>Enumeração DNS</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $INFO_SUBDOMINIO </tbody> </table> </p> </div> <!-- DNS 2 --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-network-wired'></i> </div> <h2>Enumeração DNS</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $SUBS </tbody> </table> </p> </div> </div> </div> </div> <!-- LINKS / SCRIPTS --> <div class='col-lg-12 text-white'> <div class='container px-2 py-2' id='featured-2'> <div class='row g-4 py-3 row-cols-1 row-cols-lg-2'> <!-- LINKS --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-external-link-alt'></i> </div> <h2>Links Encontrados</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $LINKS </tbody> </table> </p> </div> <!-- SCRIPTS --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-folder-open'></i> </div> <h2>Scripts Encontrados</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $SCRIPTS </tbody> </table> </p> </div> </div> </div> </div> <!-- DIRETÓRIO / ARQUIVOS --> <div class='col-lg-12 text-white'> <div class='container px-1 py-1' id='featured-2'> <div class='row g-4 py-3 row-cols-1 row-cols-lg-2'> <!-- DIRETÓRIOS --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-folder-open'></i> </div> <h2>Diretórios Encontrados</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $DIRS </table> </p> </div> <!-- ARQUIVOS --> <div class='feature col'> <div class='feature-icon bg-primary bg-gradient'> <i class='fas fa-folder-open'></i> </div> <h2>Arquivos Encontrados</h2> <p> <table class='table table-dark table-striped'> <thead> <tr> <th scope='col'>&nbsp;</th> </tr> </thead> <tbody> $ARQUIVOS </tbody> </table> </p> </div> </div> </div> </div> <!-- VULNERABILIDADES --> <div class='col-lg-12 mt-4'> <p class='text-center'> <a class='btn btn-danger position-relative' data-bs-toggle='collapse' href='#collapseExample' role='button' aria-expanded='false' aria-controls='collapseExample' style='margin-right: 25px;'> CRÍTICO <span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger'> 0 </span> </a> <button class='btn btn-danger position-relative mr-5' type='button' data-bs-toggle='collapse' data-bs-target='#collapseExample' aria-expanded='false' aria-controls='collapseExample' style='margin-right: 25px;'> ALTO <span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger'> 0 </span> </button> <button class='btn btn-warning position-relative' type='button' data-bs-toggle='collapse' data-bs-target='#collapseExample' aria-expanded='false' aria-controls='collapseExample' style='margin-right: 25px;'> MÉDIO <span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning'> 0 </span> </button> <button class='btn btn-primary position-relative' type='button' data-bs-toggle='collapse' data-bs-target='#collapseExample' aria-expanded='false' aria-controls='collapseExample' style='margin-right: 25px;'> BAIXO <span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-primary'> 0 </span> </button> <button class='btn btn-info position-relative' type='button' data-bs-toggle='collapse' data-bs-target='#collapseExample' aria-expanded='false' aria-controls='collapseExample' style='margin-right: 25px;'> INFO <span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-info'> 0 </span> </button> </p> <div class='collapse' id='collapseExample'> <div class='card card-body'> Some placeholder content for the collapse component. This panel is hidden by default but revealed when the user activates the relevant trigger. </div> </div> </div> </div> </div> <script src='https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.bundle.min.js' integrity='sha384-U1DAWAznBHeqEIlVSCgzq+c9gqGAJn5c/t99JyeKa9xxaYpSvHU5awsuZVVFIhvj' crossorigin='anonymous'></script> <script src='https://kit.fontawesome.com/6223243738.js' crossorigin='anonymous'></script> </body> </html>" > "$INFO_ALVO.html"
open "$INFO_ALVO.html"
rm -rf links.txt links2.txt scripts.txt scripts2.txt dir.txt sub.txt arquivos.txt
