package com.fpoly.dto;

public class LocationDtos {

    public record ProvinceDto(Integer id, String name, String region) {}

    public record WardDto(Integer id, String name, Integer provinceId) {}
}
