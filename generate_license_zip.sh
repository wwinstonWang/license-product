#!/bin/bash

# 创建临时目录
mkdir -p license-generator/src/main/java/com/example/licensegenerator
mkdir -p license-client/src/main/java/com/example/licenseclient

# ---- License Generator ----
cat > license-generator/pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>license-generator</artifactId>
    <version>1.0-SNAPSHOT</version>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>21</source>
                    <target>21</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 生成 Generator 源码文件
cat > license-generator/src/main/java/com/example/licensegenerator/License.java <<EOF
package com.example.licensegenerator;
import java.time.LocalDate;
public class License {
    private String product;
    private String owner;
    private LocalDate expireDate;
    private String machineCode;
    public License(String product, String owner, LocalDate expireDate, String machineCode) {
        this.product = product;
        this.owner = owner;
        this.expireDate = expireDate;
        this.machineCode = machineCode;
    }
    public String toString() {
        return product + "|" + owner + "|" + expireDate + "|" + machineCode;
    }
}
EOF

cat > license-generator/src/main/java/com/example/licensegenerator/RSAUtils.java <<EOF
package com.example.licensegenerator;
import java.security.*;
import java.util.Base64;
public class RSAUtils {
    public static KeyPair generateKeyPair() throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048);
        return keyGen.generateKeyPair();
    }
    public static String sign(String data, PrivateKey privateKey) throws Exception {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(privateKey);
        signature.update(data.getBytes());
        return Base64.getEncoder().encodeToString(signature.sign());
    }
}
EOF

cat > license-generator/src/main/java/com/example/licensegenerator/LicenseGenerator.java <<EOF
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
            writer.write(license.toString() + "\\n");
            writer.write(signature);
        }
        System.out.println("License generated at " + file.getAbsolutePath());
    }
}
EOF

cat > license-generator/src/main/java/com/example/licensegenerator/Main.java <<EOF
package com.example.licensegenerator;
import java.security.KeyPair;
import java.time.LocalDate;
public class Main {
    public static void main(String[] args) throws Exception {
        KeyPair keyPair = RSAUtils.generateKeyPair();
        LicenseGenerator generator = new LicenseGenerator(keyPair);
        generator.generateLicense("MyProduct", "User123", LocalDate.now().plusDays(30), "MACHINECODE123", "license.lic");
        System.out.println("Public Key (for client verification): " + keyPair.getPublic());
    }
}
EOF

# ---- License Client ----
cat > license-client/pom.xml <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>license-client</artifactId>
    <version>1.0-SNAPSHOT</version>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>21</source>
                    <target>21</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 生成 Client 源码
cat > license-client/src/main/java/com/example/licenseclient/License.java <<EOF
package com.example.licenseclient;
import java.time.LocalDate;
public class License {
    private String product;
    private String owner;
    private LocalDate expireDate;
    private String machineCode;
    public License(String product, String owner, LocalDate expireDate, String machineCode) {
        this.product = product;
        this.owner = owner;
        this.expireDate = expireDate;
        this.machineCode = machineCode;
    }
    public static License fromString(String str) {
        String[] parts = str.split("\\|");
        return new License(parts[0], parts[1], LocalDate.parse(parts[2]), parts[3]);
    }
    public String getMachineCode() { return machineCode; }
    public String toString() { return product + "|" + owner + "|" + expireDate + "|" + machineCode; }
}
EOF

cat > license-client/src/main/java/com/example/licenseclient/MachineCodeUtils.java <<EOF
package com.example.licenseclient;
import java.net.NetworkInterface;
import java.util.Enumeration;
public class MachineCodeUtils {
    public static String getMachineCode() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                byte[] mac = ni.getHardwareAddress();
                if (mac != null) {
                    StringBuilder sb = new StringBuilder();
                    for (byte b : mac) sb.append(String.format("%02X", b));
                    return sb.toString();
                }
            }
        } catch (Exception e) {}
        return "UNKNOWN_MACHINE";
    }
}
EOF

cat > license-client/src/main/java/com/example/licenseclient/RSAUtils.java <<EOF
package com.example.licenseclient;
import java.security.*;
import java.util.Base64;
public class RSAUtils {
    public static boolean verify(String data, String signatureStr, PublicKey publicKey) throws Exception {
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initVerify(publicKey);
        signature.update(data.getBytes());
        byte[] sigBytes = Base64.getDecoder().decode(signatureStr);
        return signature.verify(sigBytes);
    }
}
EOF

cat > license-client/src/main/java/com/example/licenseclient/LicenseManager.java <<EOF
package com.example.licenseclient;
import java.security.PublicKey;
public class LicenseManager {
    private String licenseContent;
    private String signature;
    public void loadLicense(String content, String signature) { this.licenseContent = content; this.signature = signature; }
    public boolean verifyLicense(PublicKey publicKey) throws Exception {
        License license = License.fromString(licenseContent);
        if (!license.getMachineCode().equals(MachineCodeUtils.getMachineCode())) {
            System.err.println("Machine code mismatch!");
            return false;
        }
        return RSAUtils.verify(license.toString(), signature, publicKey);
    }
}
EOF

cat > license-client/src/main/java/com/example/licenseclient/Main.java <<EOF
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
        String pubKeyStr = "MIIBIjANBgkq..."; 
        byte[] pubBytes = Base64.getDecoder().decode(pubKeyStr);
        PublicKey pubKey = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(pubBytes));
        LicenseManager manager = new LicenseManager();
        manager.loadLicense(content, signature);
        boolean valid = manager.verifyLicense(pubKey);
        System.out.println("License valid: " + valid);
    }
}
EOF

# 打包 ZIP
zip -r license-generator.zip license-generator
zip -r license-client.zip license-client

echo "生成完成：license-generator.zip 和 license-client.zip"
