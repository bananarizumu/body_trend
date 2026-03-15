# Project Rules

## Project Overview
This project is a Flutter application for Android-first development.
The app reads health data from Health Connect and visualizes body trends with statistical aggregation.

### Current Scope
- Platform: Flutter
- Initial target: Android only
- Data source: Health Connect
- Supported metrics:
    - Weight
    - Body fat percentage
    - Calorie intake

### Main Goal
The app should help users understand their real physical trends by smoothing daily fluctuations and measurement noise.
Instead of relying only on raw daily values, the app should provide aggregated views for selected time ranges.

## Functional Requirements
- Read data from Health Connect
- Support selectable aggregation periods:
    - 1 day
    - 1 week
    - 1 month
    - extensible for future periods
- For each metric, calculate and visualize:
    - Average
    - Median
    - Maximum
    - Minimum
- Present results in charts and summary views
- Handle noisy or inconsistent daily measurements appropriately
- Prioritize accuracy and interpretability over flashy UI

## Architecture
Use **Clean Architecture**.

### Core Principles
- Separate responsibilities clearly by layer
- Keep business logic independent from UI and framework details
- Prefer testable, replaceable components
- Follow existing naming conventions and project patterns first
- Do not introduce large-scale refactors unless explicitly requested

### Recommended Layers
#### Presentation
Responsible for:
- UI
- screen state
- user interaction handling
- state management

Flutter side should use:
- Riverpod for state management

Typical components:
- Pages / Screens
- Widgets
- Controllers / Notifiers / Providers
- UI state models

#### Domain
Responsible for:
- business rules
- use cases
- domain entities
- repository contracts

Typical components:
- Entities
- UseCases
- Repository interfaces

Rules:
- Domain layer must not depend on Flutter UI details
- Domain layer should not depend on external SDK implementations directly

#### Data
Responsible for:
- repository implementations
- Health Connect access
- local storage if added later
- DTO / mapper handling

Typical components:
- Repository implementations
- Data sources
- DTOs
- Mappers

Rules:
- Data layer implements repository interfaces defined in Domain
- External APIs / SDKs must stay inside this layer

## Platform-Specific Rules
### Flutter
- Use Riverpod
- Structure features with Clean Architecture
- Keep UI logic out of widgets as much as possible
- Put aggregation/statistical logic in Domain or a clearly testable layer
- Do not mix data-source logic directly into presentation code

Suggested direction:
- `features/<feature_name>/presentation`
- `features/<feature_name>/domain`
- `features/<feature_name>/data`

### Android Native
If Android-native code is required for platform integration:
- Use ViewModel + Repository
- Use Retrofit only where network access is actually needed
- Keep platform channel / plugin integration isolated and minimal
- Do not move business rules into Android framework classes

Note:
- Since the current project is Android-first and Health Connect-based, native Android integration may be added where necessary
- Prefer keeping app-level business logic in shared Flutter/Dart code when reasonable

## Implementation Policy
- First, read the existing implementation before making changes
- Respect existing naming conventions
- Keep changes minimal and scoped
- Explain the reason for the change
- Explain the impact range of the change
- Suggest relevant test cases
- Prefer incremental improvements over broad restructuring

## Commands
Run these when relevant:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
./gradlew test
./gradlew lintDebug