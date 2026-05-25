import 'package:flutter_riverpod/legacy.dart';
import '../models/user.dart';
import '../services/auth_services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(AuthState());

  Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        final user = User.fromJson(userJson);
        state = state.copyWith(user: user);
        return true;
      }
    } catch (e) {
      // Ignore parsing errors, user will just have to login again
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(email, password);
      if (response.statusCode == 200) {
        final userData = response.data['shop'];
        // Fetch full shop details to get all fields
        final fullDetailsResponse = await _authService.getShopById(
          userData['shop_id'],
        );
        final user = User.fromMap(fullDetailsResponse.data);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', user.toJson());
        
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          state = state.copyWith(isLoading: false, error: data['detail'].toString());
          return;
        }
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.signup(user);
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          state = state.copyWith(isLoading: false, error: data['detail'].toString());
          return;
        }
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    state = AuthState();
  }
}
