package com.fpoly.model.dto;

public class CompareRow {
    private String specKey;
    private String[] values;

    public CompareRow(String specKey, String[] values) {
        this.specKey = specKey;
        this.values = values;
    }

    public String getSpecKey() { return specKey; }
    public String[] getValues() { return values; }
}