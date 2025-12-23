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
