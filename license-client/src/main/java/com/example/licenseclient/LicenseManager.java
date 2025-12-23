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
