package com.example.licenseclient;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

public class Main {
    public static void main(String[] args) throws Exception {
        String[] lines = Files.readAllLines(Paths.get("license.lic")).toArray(new String[0]);
        String content = lines[0];
        String signature = lines[1];
        // 替换为生成器导出的 Base64 公钥
        String pubKeyStr = new String(Files.readAllBytes(Paths.get("public.key"))); // "MIIBIjANBgkq...";
        byte[] pubBytes = Base64.getDecoder().decode(pubKeyStr);
        PublicKey pubKey = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(pubBytes));
        LicenseManager manager = new LicenseManager();
        manager.loadLicense(content, signature);
        boolean valid = manager.verifyLicense(pubKey);
        System.out.println("License valid: " + valid);
    }
}
