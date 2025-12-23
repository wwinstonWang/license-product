package com.example.licenseclient;
import java.net.NetworkInterface;
import java.util.Enumeration;
public class MachineCodeUtils {
    /**
     * 获取当前机器码（MAC 地址为主，若失败返回 UNKNOWN_MACHINE）
     */
    public static String getMachineCode() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface ni = interfaces.nextElement();
                if (ni.isLoopback() || ni.isVirtual() || !ni.isUp()) continue;
                byte[] mac = ni.getHardwareAddress();
                if (mac != null && mac.length > 0) {
                    StringBuilder sb = new StringBuilder();
                    for (byte b : mac) sb.append(String.format("%02X", b));
                    return sb.toString();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "UNKNOWN_MACHINE";
    }

    /**
     * 获取最终机器码
     * 如果客户提供 machineCode 则使用客户提供
     * 否则自动获取当前机器码
     */
    public static String resolveMachineCode(String providedMachineCode) {
        if (providedMachineCode != null && !providedMachineCode.isEmpty()) {
            return providedMachineCode;
        }
        return getMachineCode();
    }
}
