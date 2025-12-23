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
