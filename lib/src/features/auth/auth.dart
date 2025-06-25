/// Barrel file that exports all auth-related components
/// This makes it easier to import auth components from other parts of the app

// Data layer exports
export 'data/auth_repository.dart';
export 'data/auth_state_notifier.dart';
export 'data/user_model.dart';

// Presentation layer exports
export 'presentation/sign_in_screen.dart';
export 'presentation/sign_up_screen.dart';
export 'presentation/profile_setup_screen.dart'; 