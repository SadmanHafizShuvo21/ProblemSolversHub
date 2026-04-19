import 'package:get_it/get_it.dart';
import 'package:problem_solvers_hub/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:problem_solvers_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:problem_solvers_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/signup_usecase.dart';
import 'package:problem_solvers_hub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:problem_solvers_hub/features/create/presentation/bloc/create_post_bloc.dart';
import 'package:problem_solvers_hub/features/posts/data/datasources/firebase_posts_datasource.dart';
import 'package:problem_solvers_hub/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:problem_solvers_hub/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // ============= AUTH =============
  // Data sources
  getIt.registerSingleton<FirebaseAuthDatasource>(FirebaseAuthDatasource());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<FirebaseAuthDatasource>()),
  );

  // Use cases
  getIt.registerSingleton<SignupUsecase>(
    SignupUsecase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<LoginUsecase>(LoginUsecase(getIt<AuthRepository>()));

  getIt.registerSingleton<GoogleSigninUsecase>(
    GoogleSigninUsecase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<LogoutUsecase>(
    LogoutUsecase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<GetCurrentUserUsecase>(
    GetCurrentUserUsecase(getIt<AuthRepository>()),
  );

  // Bloc
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      signupUsecase: getIt<SignupUsecase>(),
      loginUsecase: getIt<LoginUsecase>(),
      googleSigninUsecase: getIt<GoogleSigninUsecase>(),
      logoutUsecase: getIt<LogoutUsecase>(),
      getCurrentUserUsecase: getIt<GetCurrentUserUsecase>(),
    ),
  );

  // ============= POSTS =============
  // Data sources
  getIt.registerSingleton<FirebasePostsDatasource>(FirebasePostsDatasource());

  // Repositories
  getIt.registerSingleton<PostsRepository>(
    PostsRepositoryImpl(getIt<FirebasePostsDatasource>()),
  );

  // Use cases
  getIt.registerSingleton<CreatePostUsecase>(
    CreatePostUsecase(getIt<PostsRepository>()),
  );

  // Blocs
  getIt.registerSingleton<CreatePostBloc>(
    CreatePostBloc(
      createPostUsecase: getIt<CreatePostUsecase>(),
      authBloc: getIt<AuthBloc>(),
    ),
  );
}
