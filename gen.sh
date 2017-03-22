#!/bin/sh

# Files needed
pwd=`pwd`
. $pwd/unifi-api.sh

# Generation settings
time=$(( 12 * 60 ))
amount=15
note="TEST"

# Generate vouchers
unifi_login
voucherID=`unifi_create_voucher $time $amount $note`
unifi_get_vouchers $voucherID > vouchers.tmp
unifi_logout

vouchers=`awk -F"[,:]" '{for(i=1;i<=NF;i++){if($i~/code\042/){print $(i+1)} } }' vouchers.tmp | sed 's/\"//g'`

# Build HTML
if [ -e vouchers.html ]; then
  echo "Removing old vouchers."
  rm vouchers.html
fi

cat <<EOF >> vouchers.html
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="style.css" />
    <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet">
  </head>
  <body>
EOF

for password in $vouchers
do
    password=`echo $password | sed 's/.\{5\}/& /g'`
    cat <<EOF >> vouchers.html
<div class="voucher">
  <img class="background-image" src="background-image.png" alt="A background image that should contain all the information about the voucher except the password">
  <span class="password">$password</span>
</div>
EOF
done

echo "</body></html>" >> vouchers.html

# Remove tmp
if [ -e vouchers.tmp ]; then
  echo "Removing vouchers tmp file."
  rm vouchers.tmp
fi
