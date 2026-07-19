package com.example.demo.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public final class GradePassEvaluator {

    private static final BigDecimal PASS_THRESHOLD = new BigDecimal("5");

    private GradePassEvaluator() {}

    public static String evaluatePass(BigDecimal average, List<BigDecimal> componentScores, double attendancePercent) {
        BigDecimal resolvedAverage = average != null ? average : BigDecimal.ZERO;

        boolean totalOk = resolvedAverage.compareTo(PASS_THRESHOLD) > 0;
        boolean noZeroComponent = hasValidComponentScores(componentScores);
        boolean attendanceOk = attendancePercent >= 80.0;

        return totalOk && noZeroComponent && attendanceOk ? "Passed" : "Not Passed";
    }

    public static BigDecimal calculateWeightedAverage(List<BigDecimal> scores, List<BigDecimal> weights) {
        if (scores.isEmpty() || scores.size() != weights.size()) {
            return BigDecimal.ZERO;
        }

        BigDecimal weightedSum = BigDecimal.ZERO;
        BigDecimal totalWeight = BigDecimal.ZERO;

        for (int i = 0; i < scores.size(); i++) {
            BigDecimal score = scores.get(i);
            BigDecimal weight = weights.get(i);
            if (score == null || weight == null) {
                continue;
            }
            weightedSum = weightedSum.add(score.multiply(weight));
            totalWeight = totalWeight.add(weight);
        }

        if (totalWeight.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }

        return weightedSum.divide(totalWeight, 2, RoundingMode.HALF_UP);
    }

    private static boolean hasValidComponentScores(List<BigDecimal> componentScores) {
        if (componentScores == null || componentScores.isEmpty()) {
            return false;
        }
        return componentScores.stream()
                .allMatch(score -> score != null && score.compareTo(BigDecimal.ZERO) > 0);
    }
}
