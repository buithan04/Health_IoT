# Contributing to Health IoT

Cảm ơn bạn đã quan tâm đến việc đóng góp cho Health IoT! 🎉

## Quy Tắc Chung

1. **Code of Conduct**: Vui lòng đọc và tuân thủ [Code of Conduct](CODE_OF_CONDUCT.md)
2. **Issue First**: Trước khi bắt đầu làm việc, hãy tạo issue hoặc comment vào issue có sẵn
3. **Small Changes**: Giữ các Pull Request nhỏ và tập trung vào một vấn đề cụ thể

## Quy Trình Contribute

### 1. Fork và Clone

```bash
# Fork repository trên GitHub
# Sau đó clone về máy:
git clone git@github.com:YOUR_USERNAME/Health_IoT.git
cd Health_IoT

# Thêm upstream remote
git remote add upstream git@github.com:buithan04/Health_IoT.git
```

### 2. Tạo Branch

```bash
# Luôn tạo branch mới từ main
git checkout main
git pull upstream main
git checkout -b feature/your-feature-name
```

**Quy Tắc Đặt Tên Branch:**
- `feature/feature-name` - Tính năng mới
- `fix/bug-description` - Sửa bug
- `docs/documentation-update` - Cập nhật documentation
- `refactor/code-improvement` - Refactor code
- `test/test-name` - Thêm tests

### 3. Viết Code

#### Code Style

**Flutter/Dart:**
```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

**Node.js:**
```bash
# Lint code
npm run lint

# Format code
npm run format

# Run tests
npm test
```

#### Commit Messages

Tuân thủ [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: Tính năng mới
- `fix`: Sửa bug
- `docs`: Thay đổi documentation
- `style`: Formatting, missing semi colons, etc
- `refactor`: Refactoring code
- `test`: Thêm hoặc sửa tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(auth): add forgot password functionality

- Implement forgot password endpoint
- Add email service for password reset
- Update UI for password reset flow

Closes #123
```

```bash
fix(chat): resolve message ordering issue

Messages were not displaying in chronological order
due to incorrect timestamp comparison.

Fixes #456
```

### 4. Push và Tạo Pull Request

```bash
# Push branch lên fork của bạn
git push origin feature/your-feature-name

# Tạo Pull Request trên GitHub
```

**Pull Request Template:**
```markdown
## Description
<!-- Mô tả ngắn gọn về changes của bạn -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
<!-- Mô tả cách bạn đã test changes -->

## Checklist:
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
- [ ] All tests passing
```

## Code Review Process

1. Ít nhất 1 reviewer phải approve
2. Tất cả discussions phải được resolve
3. CI/CD checks phải pass
4. Không có merge conflicts

## Development Setup

### Backend
```bash
cd HealthAI_Server
npm install
cp .env.example .env
# Cấu hình .env
npm run dev
```

### Mobile App
```bash
cd doan2
flutter pub get
flutter run
```

### Admin Portal
```bash
cd admin-portal
npm install
cp .env.example .env.local
npm run dev
```

## Testing Guidelines

### Flutter Tests
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/

# Coverage
flutter test --coverage
```

### Backend Tests
```bash
# Unit tests
npm run test:unit

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Coverage
npm run test:coverage
```

## Documentation

- Update README.md nếu thêm features mới
- Add JSDoc/DartDoc comments cho public APIs
- Update API documentation nếu thay đổi endpoints

## Questions?

- Tạo issue với label `question`
- Email: buithan160904@gmail.com
- Discord: [Link nếu có]

## License

Bằng việc contribute, bạn đồng ý rằng contributions của bạn sẽ được licensed dưới MIT License.
