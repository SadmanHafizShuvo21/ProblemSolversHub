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
import 'package:problem_solvers_hub/features/posts/data/datasources/firebase_problems_datasource.dart';
import 'package:problem_solvers_hub/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:problem_solvers_hub/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:problem_solvers_hub/features/posts/domain/repositories/posts_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // ============= AUTH =============
  getIt.registerLazySingleton<FirebaseAuthDatasource>(() => FirebaseAuthDatasource());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<FirebaseAuthDatasource>()));
  getIt.registerLazySingleton<SignupUsecase>(() => SignupUsecase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<LoginUsecase>(() => LoginUsecase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GoogleSigninUsecase>(() => GoogleSigninUsecase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUserUsecase>(() => GetCurrentUserUsecase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(
        signupUsecase: getIt<SignupUsecase>(),
        loginUsecase: getIt<LoginUsecase>(),
        googleSigninUsecase: getIt<GoogleSigninUsecase>(),
        logoutUsecase: getIt<LogoutUsecase>(),
        getCurrentUserUsecase: getIt<GetCurrentUserUsecase>(),
      ));

  // ============= POSTS =============
  getIt.registerLazySingleton<FirebasePostsDatasource>(() => FirebasePostsDatasource());
  getIt.registerLazySingleton<FirebaseProblemsDataSource>(() => FirebaseProblemsDataSource());
  getIt.registerLazySingleton<PostsRepository>(() => PostsRepositoryImpl(getIt<FirebasePostsDatasource>()));
  getIt.registerLazySingleton<CreatePostUsecase>(() => CreatePostUsecase(getIt<PostsRepository>()));
  getIt.registerLazySingleton<CreatePostBloc>(() => CreatePostBloc(
        createPostUsecase: getIt<CreatePostUsecase>(),
        authBloc: getIt<AuthBloc>(),
        problemsDataSource: getIt<FirebaseProblemsDataSource>(),
      ));
}
