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
        String[] parts = str.split("\|");
        return new License(parts[0], parts[1], LocalDate.parse(parts[2]), parts[3]);
    }
    public String getMachineCode() { return machineCode; }
    public String toString() { return product + "|" + owner + "|" + expireDate + "|" + machineCode; }
}
