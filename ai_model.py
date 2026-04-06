import re

import numpy as np
from sklearn.ensemble import RandomForestClassifier


def build_training_data():
    samples = [
        ([0, 0, 0, 0, 0], 0),
        ([1, 0, 0, 4, 3], 0),
        ([1, 1, 0, 4, 6], 1),
        ([2, 0, 0, 8, 8], 1),
        ([1, 0, 1, 4, 7], 1),
        ([2, 1, 0, 8, 12], 1),
        ([2, 1, 1, 8, 15], 2),
        ([3, 1, 1, 12, 20], 2),
        ([3, 2, 1, 16, 24], 2),
        ([4, 2, 2, 20, 32], 2),
        ([0, 1, 0, 0, 5], 1),
        ([0, 0, 2, 0, 8], 2),
    ]

    features = np.array([sample[0] for sample in samples])
    labels = np.array([sample[1] for sample in samples])
    return features, labels


def read_variable_data():
    rows = []
    try:
        with open("data.txt") as file:
            for line in file:
                values = list(map(int, line.split()))
                if len(values) == 2:
                    rows.append(values)
    except OSError:
        return []

    return rows


def read_report():
    try:
        with open("report.txt") as file:
            return file.read()
    except OSError:
        return ""


def extract_memory_saved(report_text):
    match = re.search(r"Memory saved:\s*(\d+)", report_text)
    return int(match.group(1)) if match else 0


def build_feature_vector(rows, report_text):
    total_variables = len(rows)
    unused_count = sum(1 for used, _ in rows if used == 0)
    duplicate_count = sum(1 for _, duplicate in rows if duplicate == 1)
    uninitialized_count = report_text.count("Used before initialization:")
    memory_saved = extract_memory_saved(report_text)
    weighted_score = unused_count * 3 + duplicate_count * 4 + uninitialized_count * 5 + memory_saved // 2

    return np.array(
        [[unused_count, duplicate_count, uninitialized_count, memory_saved, weighted_score]]
    ), {
        "total_variables": total_variables,
        "unused_count": unused_count,
        "duplicate_count": duplicate_count,
        "uninitialized_count": uninitialized_count,
        "memory_saved": memory_saved,
        "weighted_score": weighted_score,
    }


def label_from_prediction(prediction):
    if prediction == 0:
        return "Low"
    if prediction == 1:
        return "Medium"
    return "High"


def priority_from_label(label):
    if label == "Low":
        return "Low priority cleanup"
    if label == "Medium":
        return "Recommended optimization pass"
    return "Immediate attention recommended"


def quality_score(stats):
    penalty = (
        stats["unused_count"] * 10
        + stats["duplicate_count"] * 15
        + stats["uninitialized_count"] * 20
        + min(stats["memory_saved"], 40)
    )
    return max(0, 100 - penalty)


def main():
    rows = read_variable_data()
    report_text = read_report()

    with open("report.txt", "a") as report:
        report.write("\n--- AI Severity Assessment ---\n")

        if not rows or not report_text:
            report.write("• AI assessment skipped because analysis data is incomplete\n")
            return

        training_x, training_y = build_training_data()
        model = RandomForestClassifier(n_estimators=50, random_state=42)
        model.fit(training_x, training_y)

        feature_vector, stats = build_feature_vector(rows, report_text)
        prediction = int(model.predict(feature_vector)[0])
        probabilities = model.predict_proba(feature_vector)[0]

        risk_label = label_from_prediction(prediction)
        confidence = max(probabilities) * 100
        quality = quality_score(stats)

        report.write(f"• Risk Level: {risk_label}\n")
        report.write(f"• Optimization Priority: {priority_from_label(risk_label)}\n")
        report.write(f"• Estimated Quality Score: {quality}/100\n")
        report.write(f"• Model Confidence: {confidence:.1f}%\n")
        report.write(
            "• AI Features Used: "
            f"unused={stats['unused_count']}, "
            f"duplicate={stats['duplicate_count']}, "
            f"use-before-init={stats['uninitialized_count']}, "
            f"memory-saved={stats['memory_saved']} bytes\n"
        )


if __name__ == "__main__":
    main()
