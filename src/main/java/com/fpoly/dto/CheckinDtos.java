package com.fpoly.dto;

public class CheckinDtos {

    public record CheckinStatusDto(
            boolean checkedInToday, int currentStreak, int nextRewardSilver, int[] weekRewards
    ) {}

    public record CheckinResultDto(int streak, int rewardSilver) {}
}
