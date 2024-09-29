#!/bin/sh

<< COMMAND
1. 將需要新增的 domain 放在 domains.txt 中，以換行分開
2. cd 進入 /iOS-WebClip-Script/ 中，直接執行 ./V1.sh
3. 若出現 zsh: permission denied: ./V1.sh ，須先執行 chmod +x V1.sh
4. 簽署完畢後會直接批次放在 /Signed 中
COMMAND

# 移除 .txt 中不合法的符號 ex. "\r"
cat domains.txt | tr -d '\r' > domainsClean.txt

# 取得所有 domain 陣列
NEW_DOMAINS=`cat domainsClean.txt`

# 用來簽署的開發者證書
SIGN_CERT="Apple Development: cer name (XXXXXXXXXX)"

# 本機是否有 SIGN_CERT 此開發者證書
HAS_CERT='security find-identity -v -p codesigning | grep -q "$SIGN_CERT"'

# 刪除前次的檔案
rm -f Signed/*.mobileconfig

# 生成亂數 ID function
function randomID() {
	# https://www.gushiciku.cn/pl/2d4T/zh-tw
	min=$1
    max=$2
    mid=$(($max-$min+1))
    num=$(($RANDOM+$max))       # 隨機數+範圍上限, 然後取餘
    randnum=$(($num%$mid+$min)) # 隨機數包含上下限邊界數值
    echo $randnum
}

INDEX=0

# 判斷本機是否有 $SIGN_CERT 開發憑證
if eval $HAS_CERT; then
	echo "================== 開始簽署..."
	# 批次處理
	for domain in ${NEW_DOMAINS[@]}
	do

		#生成亂數ID 給 PayloadIdentifier, PayloadUUID
		webClipUUID=$(randomID 100000000000 999999999999)
		configIdentifier1=$(randomID 100000000000 999999999999)
		configIdentifier2=$(randomID 100000000000 999999999999)
		configUUID=$(randomID 100000000000 999999999999)

		#未簽署檔名
		profileName=ShineLive$domain.mobileconfig

		#取代 domainName, UUID...
		sed -e '
		s/DOMAIN_NAME/'$domain'/g; 
		s/WEBCLIP_UUID/'$webClipUUID'/g; 
		s/CONFIG_IDENTIFIER_1/'$configIdentifier1'/g;
		s/CONFIG_IDENTIFIER_2/'$configIdentifier2'/g;
		s/CONFIG_UUID/'$configUUID'/g' Templete.mobileconfig > $profileName

		#簽署後存放於 /Signed/
		#https://osxdominion.wordpress.com/2015/04/21/signing-mobileconfig-profiles-with-keychain-certificates/
		#security -v find-identity -p codesigning
		/usr/bin/security cms -S -N "$SIGN_CERT" -i $profileName -o "Signed/$profileName"

		#刪除未簽署檔案
		rm -f $profileName

		INDEX=$(expr $INDEX + 1)

		echo $domain
	done

	rm -f domainsClean.txt

	echo "================== 簽署完成..."
	echo "================== 總共產出了$INDEX 個"
else
	echo "ERROR: 確認本機是否有 $SIGN_CERT 開發憑證"
	security find-identity -p codesigning -v
fi
