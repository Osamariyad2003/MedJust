import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:med_just/core/local/cachekeys.dart';
import 'package:med_just/core/local/secure_helper.dart';
import 'package:med_just/features/sidebar/data/repo/sidebar_repo.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:med_just/features/sidebar/presentation/bloc/sidebar_state.dart';

class SideBarBloc extends Bloc<SideBarEvent, SideBarStates> {
  final SidebarRepo repository;
  String? imagePath;
  String? name;

  SideBarBloc(this.repository) : super(SideBarIntitalState()) {
    on<SelectMenuEvent>((event, emit) {
      emit(MenuSelectedState(event.selectedMenu));
    });

    on<LoadUserData>((event, emit) async {
      await _fetchUserData(emit);
    });
    on<SignOutEvent>((event, emit) async {
      try {
        await repository.signOut();
        // Clear any cached user data if necessary
        await SecureStorageService().deleteAuthToken();
        final userBox = Hive.box('userBox');
        userBox.put('isLoggedIn', false);
        userBox.delete('yearId');
        emit(SignOutSuccessState());
      } catch (error) {
        emit(SignOutErrorState(error.toString()));
      }
    });
  }

  void _loadUserData() {
    add(LoadUserData(imagePath ?? "", name ?? "Ahmad"));
  }

  Future<void> _fetchUserData(Emitter<SideBarStates> emit) async {
    emit(LoadUserDataState());

    try {
      var uid = await SecureStorageService().getAuthToken(
        Cachekeys.cachedUserId,
      );
      if (uid == null) {
        print("User token not found. Please log in again.");
        return;
      }

      final userData = await repository.getHeader(uid: uid);
      imagePath = userData?.path ?? "";
      name = userData?.name ?? "Ahmad";

      emit(SuccessUserDataState(name ?? "Ahmad", imagePath ?? ""));
    } catch (error) {
      print(error.toString());
    }
  }
}
