
if [ -f "$HOME/alt.conf" ]; then
  export KRB5_CONFIG="$HOME/alt.conf"
elif [ -f "$HOME/krb5.conf" ]; then 
  export KRB5_CONFIG="$HOME/krb5.conf"
else
  export KRB5_CONFIG="/etc/krb5.conf"
fi

