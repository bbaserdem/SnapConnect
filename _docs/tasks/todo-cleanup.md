# Code Cleanup & Refactoring Tasks

**Created:** `2024-12-19`  
**Status:** `In Progress`  
**Priority:** `High - Technical Debt Reduction`

## 🔥 **CRITICAL PRIORITY (Fix Immediately)**

### 1. Remove Debugging Code from Production
- **File:** `lib/src/features/auth/data/auth_repository.dart` (lines 174-175)
- **Issue:** `print()` statements left in production code
- **Action:** Remove or make conditional for debug builds only
- **Effort:** 5 minutes

### 2. Clean Up Empty Directories
- **Files:** 
  - `lib/src/common/widgets/` (empty)
  - `lib/src/common/utils/` (empty)  
  - `lib/src/config/` (empty)
- **Issue:** Empty directories clutter project structure
- **Action:** Remove empty directories or populate with initial files
- **Effort:** 10 minutes

## 🚨 **HIGH PRIORITY (Fix This Sprint)**

### 3. Extract Reusable UI Components
- **File:** `lib/src/features/camera/presentation/camera_screen.dart`
- **Issue:** Repeated container styling for camera controls (3+ duplications)
- **Action:** Create reusable `CameraControlButton` widget
- **Location:** `lib/src/common/widgets/camera_control_button.dart`
- **Effort:** 30 minutes

### 4. Create Constants File for Magic Numbers
- **Files:** Multiple files with hardcoded values
- **Issue:** Magic numbers scattered throughout codebase
- **Action:** Create `lib/src/config/constants.dart` with:
  - UI dimensions (button sizes, spacing)
  - Animation durations
  - List item counts
- **Effort:** 20 minutes

### 5. Standardize Error Handling Patterns
- **File:** `lib/src/features/auth/data/auth_repository.dart`
- **Issue:** Inconsistent error handling (mixed Exception types, logging patterns)
- **Action:** 
  - Create consistent error handling utility
  - Standardize all auth repository methods
  - Add proper error logging strategy
- **Effort:** 45 minutes

## 📊 **MEDIUM PRIORITY (Next Sprint)**

### 6. Consolidate Theme Configuration
- **File:** `lib/src/app/theme.dart`
- **Issue:** 
  - Unused private color constants
  - Duplicated theme configuration between light/dark
  - Inconsistent color usage
- **Action:**
  - Remove unused color constants
  - Extract common theme elements
  - Create theme constants for spacing/sizing
- **Effort:** 25 minutes

### 7. Add Loading States to Screens
- **Files:** Auth screens and main screens
- **Issue:** Missing loading indicators during async operations
- **Action:** Add proper loading states with Riverpod
- **Effort:** 1 hour

### 8. Improve Form State Management
- **Files:** `sign_in_screen.dart`, `sign_up_screen.dart`, `profile_setup_screen.dart`
- **Issue:** Basic form handling, could be more robust
- **Action:** Consider extracting form validation logic to utilities
- **Effort:** 1 hour

## 🔧 **LOW PRIORITY (Future Improvements)**

### 9. Enhanced Documentation
- **Files:** Complex methods throughout codebase
- **Issue:** Some methods need more detailed JSDoc comments
- **Action:** Add comprehensive documentation for:
  - Auth repository methods
  - Complex UI components
  - State management patterns
- **Effort:** 2 hours

### 10. Add Unit Tests
- **Files:** Core business logic (auth, validation)
- **Issue:** No unit tests for critical business logic
- **Action:** Add tests for:
  - Auth repository methods
  - Validation utilities
  - User model operations
- **Effort:** 4 hours

### 11. Extract Validation Logic
- **Files:** Auth screens
- **Issue:** Validation logic mixed with UI code
- **Action:** Create `lib/src/common/utils/validators.dart`
- **Effort:** 30 minutes

## 📋 **IMPLEMENTATION CHECKLIST**

### Phase 1: Critical Fixes (30 minutes)
- [x] Remove print statements from auth_repository.dart
- [x] Clean up empty directories
- [x] Create constants.dart file
- [x] Extract CameraControlButton widget

### Phase 2: High Priority (2 hours)
- [x] Standardize error handling patterns
- [x] Consolidate theme configuration
- [ ] Add loading states to auth screens

### Phase 3: Medium Priority (3 hours)
- [ ] Improve form state management
- [ ] Add comprehensive error logging
- [ ] Extract validation utilities

### Phase 4: Future Improvements (6+ hours)
- [ ] Enhanced documentation
- [ ] Unit test coverage
- [ ] Advanced form handling
- [ ] Performance optimizations

## 🎯 **EXPECTED OUTCOMES**

After completing these tasks:
- **Code Quality Score:** 7.5/10 → 9.0/10
- **Maintainability:** Significantly improved
- **Developer Experience:** Enhanced with better error messages
- **Performance:** Reduced bundle size and improved loading times
- **Test Coverage:** Foundation for reliable testing

## 📝 **NOTES**

- All changes should maintain backward compatibility
- Test thoroughly after each major refactoring
- Update documentation as changes are made
- Consider impact on existing features before implementing

## 📁 **RELEVANT FILES**

### Created Files:
- `lib/src/config/constants.dart` - Centralized constants for UI dimensions, animations, and app-specific values
- `lib/src/common/widgets/camera_control_button.dart` - Reusable camera control button widget
- `lib/src/common/widgets/camera_filter_button.dart` - Reusable camera filter button widget
- `lib/src/common/utils/error_handler.dart` - Standardized error handling utility

### Modified Files:
- `lib/src/features/auth/data/auth_repository.dart` - Updated to use standardized error handling and constants
- `lib/src/features/camera/presentation/camera_screen.dart` - Refactored to use reusable widgets and constants
- `_docs/tasks/todo-cleanup.md` - This task tracking file

### Removed:
- Empty directories: `lib/src/common/widgets/`, `lib/src/common/utils/`, `lib/src/config/`
- Redundant `_handleAuthException` method from auth repository 