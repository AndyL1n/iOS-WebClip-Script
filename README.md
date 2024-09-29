# iOS-WebClip-Script


## iOS WebClip 大量包版腳本

此腳本可以產出大量不同 domain 搭載 iOS WebClip mobileconfig 的腳本

### 使用方法
1. 將需要新增的 domain 放在 `domains.txt` 中，以換行分開
2. cd 進入 `/iOS-WebClip-Script/` 中，直接執行 `./V1.sh`
3. 若出現 `zsh: permission denied: ./V1.sh` ，須先執行 `chmod +x V1.sh`
4. 簽署完畢後會直接批次放在 `/iOS-WebClip-Script/Signed` 中

```
cd /iOS-WebClip-Script

./V1.sh
```

### 變更方式
此腳本是更改未簽署的 WebClip `Templete.mobileconfig` 中的 `URL`, `UUID`...等等，來達成產出不同 ID 和 URL，並手動簽署。  
若之後需要使用不同的 URL domain 或圖片，需使用 Apple Configurator 產出一個搭載 WebClip 的未簽署描述檔 `mobileconfig`，並更名為 `Templete.mobileconfig` 替換。  

### 可參考資料
* [Signing .mobileconfig Profiles With Keychain Certificates](https://osxdominion.wordpress.com/2015/04/21/signing-mobileconfig-profiles-with-keychain-certificates/)
