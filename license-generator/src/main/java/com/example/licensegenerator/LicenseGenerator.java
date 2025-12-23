package com.example.licensegenerator;
import java.io.File;
import java.io.FileWriter;
import java.security.KeyPair;
import java.time.LocalDate;
public class LicenseGenerator {
    private KeyPair keyPair;
    public LicenseGenerator(KeyPair keyPair) { this.keyPair = keyPair; }
    public void generateLicense(String product, String owner, LocalDate expireDate, String machineCode, String filePath) throws Exception {
        License license = new License(product, owner, expireDate, machineCode);
        String signature = RSAUtils.sign(license.toString(), keyPair.getPrivate());
        File file = new File(filePath);
        try (FileWriter writer = new FileWriter(file)) {
            writer.write(license + "\n");
            writer.write(signature);
        }
        System.out.println("License generated at " + file.getAbsolutePath());
    }
}
