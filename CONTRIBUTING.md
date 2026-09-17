# Contributing to AutoMeter

Thank you for your interest in AutoMeter! We welcome contributions to make smart, transparent fare metering accessible to auto-rickshaw drivers worldwide.

## How to Contribute

1. **Fork the Repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/AutoMeter.git
   cd AutoMeter
   ```
3. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run Automated Tests**:
   ```bash
   flutter test
   ```
   Ensure all 10 tests pass before submitting changes.
5. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```
6. **Commit & Push**:
   ```bash
   git commit -m "feat: describe your change"
   git push origin feature/my-new-feature
   ```
7. **Open a Pull Request** describing your changes and testing results.

## Code Standards
- Keep `FareEngine` pure and completely decoupled from Flutter UI widgets (for future embedded C++/MicroPython portability).
- Always ensure offline recovery states are updated via `StorageService`.
- Follow standard Dart style conventions (`dart analyze`).
