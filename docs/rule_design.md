# Rule Design and Knowledge Representation

## 1. Knowledge Acquisition

The expert knowledge encoded in this system was derived from established gym training principles commonly used in strength and conditioning practice. These principles include autoregulation using RPE, performance drop-off between sets, recovery indicators (sleep, HRV, soreness), and training goal differentiation (strength, hypertrophy, endurance).

Rather than modelling numerical optimisation, the system captures *qualitative decision-making* used by coaches, expressed as IF–THEN production rules.

---

## 2. Knowledge Representation Approach

The system uses **rule-based knowledge representation**, implemented as Prolog predicates. Domain concepts such as training goals, fatigue indicators, and recovery states are represented symbolically (e.g., `strength`, `mild`, `normal`).

Rules are grouped into logical categories:
- Load adjustment rules (`load_delta/6`)
- Rest time adjustment rules (`rest_adjust/8`)
- Volume management rules (`volume_adjust/7`)
- Deload detection rules (`deload_flag/6`)
- Technique focus rules (`technique_focus/4`)
- Warm-up modification rules (`warmup_tip/4`)

This modular structure improves readability and supports incremental refinement.

---

## 3. Inference Strategy

The system uses **forward chaining through deterministic rule evaluation**. Given a complete set of inputs, the `recommend/11` predicate validates inputs and then derives each advisory component independently.

Rule priority is controlled using:
- Clause ordering
- Cut operators (`!`) to prevent conflicting rule activation

Fallback rules ensure that every advisory dimension produces a valid output, preventing inference failure.

---

## 4. Rule Priority and Conflict Handling

Conflicting indicators (e.g., good performance but poor recovery) are handled by separating concerns:
- Load progression is based on performance and RPE
- Fatigue indicators influence rest, volume, and deload flags

This reflects real-world coaching practice and avoids overly conservative load reductions.

---

## 5. Design Justification

Prolog was chosen due to its natural support for symbolic reasoning, declarative rules, and explainable inference. The rule-based approach allows the system to justify recommendations in terms of explicit domain knowledge rather than opaque numerical models.

---

## 6. Limitations

The system does not learn from historical data and does not account for individual athlete adaptation over time. All thresholds are fixed and expert-defined. These limitations are discussed further in the evaluation section.
