#!/usr/bin/env  bash
# Author - IRVING ST.  AK (comandre-ex)
export DEBIAN_FRONTEND=noninteractive

# Bold colors
color_bold_default='\e[1;39m'
color_bold_black='\e[1;30m'
color_bold_red='\e[1;31m'
color_bold_green='\e[1;32m'
color_bold_yellow='\e[1;33m'
color_bold_blue='\e[1;34m'
color_bold_magenta='\e[1;35m'
color_bold_cyan='\e[1;36m'
color_bold_gray='\e[1;90m'
color_bold_white='\e[1;97m'

# EndColour
endColour="\033[0m\e[0m"

trap ctrl_c INT  

function  ctrl_c (){
    echo -e "\n\t${color_bold_red}Exiting...${endColour}"
    rm  *tmp > /dev/null  2>&1
    tput cnorm; exit 1
} 2>/dev/null

function dependencias(){
      tput civis
      clear;dependencies=(curl gobuster subfinder amass dnsrecon)
      echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Comprobando programas necesarios.${endColour}\n" 
      sleep 3  

      for  programas in "${dependencies[@]}";do
            echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} herramienta${endColour} ${color_bold_white}(${endColour} ${color_bold_red}$programas${endColour} ${color_bold_white})${endColour}\n"

            test  -f  /usr/bin/$programas


            if  [[ "$(echo $?)" == "0" ]]; then 
                 echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour}${color_bold_white} Herramienta Instalada en el sistema.${endColour}\n"
                 sleep 3.5; clear
            else 
                 echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}x${endColour}${color_bold_yellow})${endColour}\n"
                 echo -e "\n\n${color_bold_yellow}[${endColour}${color_bold_magenta}+${endColour}${color_bold_yellow}]${endColour}${color_bold_white} Instalando Herramienta${endColour} ${color_bold_red} $programas ${endColour}\n"
                 apt  install  $programas -y  > /dev/null  2>&1
            fi; sleep 1.5

      done
}

function  helpPanel(){
    echo  -e "\n\n\t${color_bold_black}Author${endColour}${color_yellow}:${endColour}${color_bold_black}IRVING ST${endColour}${color_yellow}(${endColour}${color_bold_black}ak${endColour}${color_yellow})${endColour}${color_bold_black} Comandre-ex${endColour}\n"   
    echo  -e "\t\t${color_bold_black}-t${endColour}${color_yellow})${endColour} ${color_bold_black} set domain target${endColour}"
    echo  -e "\t\t${color_bold_black}-h${endColour}${color_yellow})${endColour} ${color_bold_black} helpPanel${endColour}"
}

function enumerationSubdomains(){	 
      echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando enumeracion de ${endColoour} ${color_bold_red}SUBDOMINIOS${endColour} ${color_bold_white}del dominio${endCoolur}"
      amass  enum  -brute  -passive  -d ${target} -o Subdomains${target}Amass.tmp  > /dev/null
      gobuster vhost -u  https://${target} -t  200 -w  /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-110000.txt --no-error --no-progress    > sub${target}Gobuster.tmp 2>/dev/null
      curl --silent  -X  GET  https://www.dnsdb.io/en-us/search?q=target |  grep  -oE "(\w+\.)+${target}" -i > dnsdb${target}.tmp
      subfinder -d ${target} -t 200 > SubFinder${target}.tmp &>/dev/null
      dnsrecon  -d  ${target} --threads 200 | grep -A 1000 "DNSSEC" |  grep  -v -i -E "DNSSEC|Records" |  tr -d  "NS|TXT|SOA|MX|[*]"  > dnsrecon${target}.tmp

      echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando ataque  de ${endColoour} ${color_bold_red} TRANSFERENCIA DE  ZONA ${endColour}"	

      ObatainIP=$(dig  +short -t A ${target})
      dig @$ObatainIP  ${target} axfr | grep -o -E '[a-zA-Z0-9.-]+\.'"${target}"'' > zoneTransfer.tmp

      cat Subdomains${target}Amass.tmp > Subdomains${target}.txt
      cat dnsdb${target}.tmp >> Subdomains${target}.txt
      cat SubFinder${target}.tmp >> Subdomains${target}.txt
      cat sub${target}Gobuster.tmp | awk  '{print $2}' FS=' '   >> Subdomains${target}.txt
      cat dnsrecon${target}.tmp   | cut -f 4 -d " " >> Subdomains${target}.txt
      cat  zoneTransfer.tmp  >> Subdomains${target}.txt
      echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white}Enumeracion de ${endColour} ${color_bold_red}SUBDOMINIOS${endColour} ${color_bold_white}Terminada.${endColour}\n"
      sleep 2.5; clear
      echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Inciando Enumeracion  de${endColour} ${color_bold_red} PAGINAS WEB${endColour} ${color_bold_white}del dominio${endColour}\n"
      cat  Subdomains${target}.txt |  httprobe  > WebPages${target}.txt
      rm  *tmp  > /dev/null 2>&1 
      echo -e "\n\n${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white}Enumeracion de ${endColour} ${color_bold_red}SUBDOMINIOS Y PAGINAS WEB${endColour} ${color_bold_white}Terminada.${endColour}\n"
}

function enumerationASN(){
    echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando enumeracion de ${endColoour} ${color_bold_red} SISTEMAS  AUTONMOMOS ${endColour} ${color_bold_white} del dominio${endCoolur}"	
    for i in {1..10};do
        ObtainIp=$(dig  +short -t A ${target})
        whois -h whois.cymru.com " -v $ObtainIp " | tr  -d  ' ' | awk '{print $1}' FS='|'  >>  ASN${target}.txt
    done
    # enum asn: amass  intel --asn <asn>
    echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} enumeracion de ${endColoour} ${color_bold_red} SISTEMAS  AUTONMOMOS ${endColour} ${color_bold_white} Terminada. ${endCoolur}"	    
}

function enumerationWHOIS(){
    echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando enumeracion ${endColoour} ${color_bold_red} WHOIS ${endColour} ${color_bold_white}del dominio${endCoolur}"

    whois ${target} |  grep  -E  -o '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' > whois${target}.txt
    whois ${target} |  grep -E -o  '\b[0-9]{3}[-.]?[0-9]{3}[-.]?[0-9]{4}\b' >>  whois${target}.txt
}

function enumerationMAILS(){
    echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando enumeracion ${endColoour} ${color_bold_red} CORREOS ELECTRONICOS CON  THEHARVESTER  ${endColour}"   
    theharvester -d ${target} -b google -l 500 -f resultados.html > /dev/null
    grep -E -o "\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b" resultados.html >> mails${target}.txt
    rm  resultados.html > /dev/null 2>&1

    registros=$(dig +short MX ${target} | sort -n)
    if [ -z "$registros" ]; then
        :
        exit 1
    fi
    for registro in $registros; do
        servidor=$(echo $registro | cut -d " " -f 2)
        echo -e "\n\n  ${color_bold_yellow}(${endColour}${color_bold_magenta}v${endColour}${color_bold_yellow})${endColour} ${color_bold_white} Iniciando enumeracion ${endColoour} ${color_bold_red} CORREOS EN EL SERVIDOR DE  CORREO ${endColour} ${color_bold_white} $servidor ${endCoolur}"
        
        smtp-user-enum -M VRFY -U users.txt -t $servidor -p 25 >> resultados-$servidor.txt
        grep -E -o "\b[a-zA-Z0-9._%+-]+@${target}\b" resultados-$servidor.txt | sort | uniq >> mails${target}.txt
        rm resultados-$servidor.txt > /dev/null 2>&1
    done
    
    rm usuarios.txt

}

function enumerationSitesWeb(){
    echo  ""
}



# Main  menu 
declare -i parameter_counter=0;  while  getopts ":t:h:" args; do  
      case  $args  in
         t) target=$OPTARG; let  parameter_counter+=2 ;;
         h) helpPanel ;;
      esac  
done

if [[ $parameter_counter -eq  0 ]];then  
      helpPanel
else
      dependencias 2>/dev/null
      #enumerationSubdomains  2>/dev/null
      #enumerationASN
      #enumerationWHOIS
      enumerationMAILS
fi
