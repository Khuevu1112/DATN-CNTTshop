package com.fpoly.dto;

public class FeeDetails {
    private String name;
    private int fee;
    private int insurance_fee;
    private boolean delivery;

    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public int getFee() { return fee; }
    public void setFee(int fee) { this.fee = fee; }
    
    public int getInsurance_fee() { return insurance_fee; }
    public void setInsurance_fee(int insurance_fee) { this.insurance_fee = insurance_fee; }
    
    public boolean isDelivery() { return delivery; }
    public void setDelivery(boolean delivery) { this.delivery = delivery; }
}