copy /Y ..\Main.swf
call "D:\Resource\AdobeAIRSDK 4.0 Beta\bin\adt" -package -target ipa-test -provisioning-profile ../../AdobeAIRDevelopmentProfile.mobileprovision -storetype pkcs12 -keystore ../../AdobeAIRDevelopment.p12 -storepass cameo Family-v1.0.0704.ipa Main-app-ios.xml -extdir "C:/github/flashCommon/ane/iOS" Main.swf Default.png Default@2x.png Default-568h@2x.png icons data