package com.fpoly.dto;

public class ShippingFeeResponse {
    private boolean success;
    private String message;
    private FeeDetails fee;

    // Getters and Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public FeeDetails getFee() { return fee; }
    public void setFee(FeeDetails fee) { this.fee = fee; }
}