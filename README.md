📘 Gym Expert System — COM6008 Knowledge-Based Systems in AI

A Prolog-based expert system that provides gym training recommendations between sets, based on performance, fatigue indicators, sleep quality, soreness, recovery metrics, and training goals.

This project is part of the COM6008: Knowledge-Based Systems in AI coursework at Buckinghamshire New University.

🚀 Features

✔ Expert knowledge encoded as ~24 symbolic rules
✔ Supports strength, hypertrophy, and endurance training goals
✔ Provides recommendations for:

Rest period (seconds)

Load adjustment (increase / hold / decrease with %)

Volume modification

Deload warnings

Technique focus

Warm-up changes

✔ Includes an interactive advisory mode and automated test cases

🧠 How It Works

The expert system uses production rules (IF–THEN) to reason about training decisions based on:

Performance metrics

Reps achieved vs target

Rate of Perceived Exertion (RPE)

Performance drop-off between sets (%)

Readiness & recovery indicators

Muscle soreness

Sleep duration

Sleep quality

Heart Rate Variability (HRV)

Subjective recovery state

Training goal

Strength

Hypertrophy

Endurance

Each advisory component (rest, load, volume, etc.) is inferred independently and then combined into a structured recommendation.

🧩 System Design

Knowledge is represented symbolically using Prolog predicates

Rule priority is controlled through clause ordering and cut operators

Default fallback rules ensure the system always returns advice

Conflicting indicators (e.g. good performance but poor recovery) are handled through separation of concerns rather than numerical optimisation

This design prioritises explainability and transparency over statistical learning.

📁 Project Structure

Gym-Expert-System-COM6008-CW1/
├── src/
│   └── gym_expert.pl
├── tests/
│   └── test_cases.pl
├── README.md

▶️ How to Run

Install SWI-Prolog
https://www.swi-prolog.org

Set the working directory:

working_directory(_, 'D:/uni/uni-project/Gym-Expert-System-COM6008-CW1').


Load the expert system:

[src/gym_expert].


Run a sample recommendation:

recommend(strength, 5, 5, 8, 10, mild, 7.5, ok, normal, medium, Advice).


Run automated tests:

[tests/test_cases].
run_tests.

🧪 Testing

The system includes an automated Prolog test harness that evaluates:

Typical training scenarios

Boundary conditions (e.g. RPE thresholds)

Conflicting indicators

Extreme fatigue and deload cases

All tests execute successfully, demonstrating consistent rule behaviour.

👤 Author

Harry and Siyan
Buckinghamshire New University
COM6008 – Knowledge-Based Systems in AI