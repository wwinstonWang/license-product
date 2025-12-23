package com.example.licensegenerator;

import java.io.FileWriter;
import java.security.KeyPair;
import java.time.LocalDate;
import java.util.Base64;

public class Main {
    public static void main(String[] args) throws Exception {
        KeyPair keyPair = RSAUtils.generateKeyPair();
        LicenseGenerator generator = new LicenseGenerator(keyPair);

        String machineCode = "MACHINECODE123";
        generator.generateLicense("MyProduct", "User123", LocalDate.now().plusDays(30), machineCode, "license.lic");
        System.out.println("License generated. Public key for client verification: " + keyPair.getPublic());
        System.out.println("Machine code used: " + machineCode);

        // 导出公钥
        String pubKeyBase64 = Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());
        try (FileWriter writer = new FileWriter("public.key")) {
            writer.write(pubKeyBase64);
        }
        System.out.println("Public key saved to public.key");
    }
}
