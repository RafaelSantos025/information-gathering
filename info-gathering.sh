#! /bin/bash

if test `whoami` != root
then
echo "ROOT Permission is necessary"
exit 0
else
echo "∗ User Root !"
fi

DIR=wordlists/
FILE=subdomains.txt
if [ -e "$DIR$FILE" ]
then
echo "∗ Wordlist Exist !"
else
echo "!!! Missing wordlists/subdomains.txt !!!"
exit 0
fi

echo 'Dir-Output: '
read output
mkdir $output

echo 'Digite o Dominio: '
read dominio
while echo "$dominio" | grep -E "http|www" > /dev/null
do
echo "Digite o dominio sem http e www (ex: site.com.br): "
read dominio
done

dig all $dominio > $output/dig.txt
echo "∗ DIG ⊕"

whois $dominio > $output/whois.txt
echo "∗ WHOIS ⊕"

echo "Detectando WAF ..."
wafw00f https://$dominio > $output/waf.txt
echo "<------------------------------------------->" >> $output/waf.txt
sqlmap --identify-waf -u $dominio --answers=follow=y >> $output/waf.txt
echo "∗ WAF ⊕"

echo "Realizando Brute-Force de Subdominios ..."
for word in $( cat wordlists/subdomains.txt )
do
host $word.$dominio >> $output/subdomains.txt
done
echo "∗ SUBDOMAINS ⊕"

echo "Realizando reconhecimento de portas e servicos ... (pode demorar)"
nmap -sS -sV $dominio > $output/nmap.txt
echo "∗ NMAP ⊕"

echo "[!] Information gathering complete [!]"
echo "[*] Arquivos salvos no Dir-Output [*]"


