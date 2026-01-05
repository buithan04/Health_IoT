import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_iot/models/patient/reminder_model.dart';
import 'package:health_iot/models/common/appointment_model.dart';

// Import Screens
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/splash_screen.dart';
import '../../presentation/auth/screens/success_screen.dart';
import '../../presentation/auth/screens/forgot_password_screen.dart';
import '../../presentation/auth/screens/otp_verify_screen.dart';
import '../../presentation/auth/screens/create_new_password_screen.dart';
import '../../presentation/shared/full_image_viewer_screen.dart';
import '../../presentation/patient/patient_shell_screen.dart';
import '../../presentation/patient/dashboard/patient_dashboard_screen.dart';
import '../../presentation/patient/statistics/patient_stats_screen.dart';
import '../../presentation/patient/appointments/appointments_screen.dart';
import '../../presentation/patient/profile/profile_screen.dart';
import '../../presentation/patient/appointments/appointment_detail_screen.dart';
import '../../presentation/patient/find_doctor/find_doctor_screen.dart';
import '../../presentation/patient/find_doctor/doctor_detail_screen.dart';
import '../../presentation/patient/appointments/book_appointment_screen.dart';
import '../../presentation/patient/appointments/booking_success_screen.dart';
import '../../presentation/patient/prescriptions/prescriptions_list_screen.dart';
import '../../presentation/patient/prescriptions/prescription_detail_screen.dart';
import '../../presentation/patient/chat/chat_list_screen.dart';
import '../../presentation/shared/chat_detail_screen.dart';
import '../../presentation/patient/reminders/medication_reminders_screen.dart';
import '../../presentation/patient/reminders/add_reminder_screen.dart';
import '../../presentation/patient/notifications/notifications_screen.dart';
import '../../presentation/patient/articles/health_articles_screen.dart';
import '../../presentation/patient/articles/article_detail_screen.dart';
import '../../presentation/patient/profile/personal_info_screen.dart';
import '../../presentation/patient/profile/health_record_screen.dart';
import '../../presentation/patient/profile/settings_screen.dart';
import '../../presentation/patient/profile/change_password_screen.dart';
import '../../presentation/patient/reviews/doctor_reviews_list_screen.dart';
import '../../presentation/patient/reviews/write_review_screen.dart';
import '../../presentation/patient/profile/my_reviews_screen.dart';
import '../../presentation/doctor/doctor_shell_screen.dart';
import '../../presentation/doctor/dashboard/doctor_dashboard_screen.dart';
import '../../presentation/doctor/dashboard/appointment_requests_screen.dart';
import '../../presentation/doctor/dashboard/doctor_notifications_screen.dart';
import '../../presentation/doctor/dashboard/manage_services_screen.dart';
import '../../presentation/doctor/schedule/doctor_schedule_screen.dart';
import '../../presentation/doctor/analytics/doctor_analytics_screen.dart';
import '../../presentation/doctor/profile/doctor_profile_screen.dart';
import '../../presentation/doctor/profile/doctor_reviews_screen.dart';
import '../../presentation/doctor/profile/doctor_settings_screen.dart';
import '../../presentation/doctor/profile/doctor_personal_info_screen.dart';
import '../../presentation/doctor/profile/professional_info_screen.dart';
import '../../presentation/doctor/chat/doctor_chat_list_screen.dart';
import '../../presentation/doctor/Notes/doctor_notes_screen.dart';
import '../../presentation/doctor/patients/patient_list_screen.dart';
import '../../presentation/doctor/patients/patient_record_screen.dart';
import '../../presentation/doctor/patients/doctor_patient_detail_screen.dart';
import '../../presentation/doctor/consultation/consultation_screen.dart';
import '../../presentation/doctor/consultation/doctor_prescription_detail_screen.dart';
import '../../presentation/doctor/schedule/manage_availability_screen.dart';
import '../../presentation/doctor/schedule/doctor_appointment_detail_screen.dart';
import '../../presentation/doctor/patients/patient_stats_detail_screen.dart';

// [QUAN TRỌNG] Import file main để lấy biến navigatorKey
import '../../main.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _patientShellNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _doctorShellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    // [FIX] Sử dụng biến navigatorKey từ main.dart để đồng bộ với Zego
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // AUTH
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
        routes: [
          GoRoute(
            path: 'success',
            builder: (context, state) => SuccessScreen(
              title: 'Đăng ký thành công!',
              message: 'Tài khoản của bạn đã được tạo, vui lòng xác nhận email.',
              buttonText: 'Đến trang Đăng nhập',
              onButtonPressed: () => context.go('/login'),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
        routes: [
          GoRoute(
            path: 'otp-verify',
            builder: (context, state) {
              final email = state.extra as String? ?? '';
              return OtpVerifyScreen(email: email);
            },
          ),
          GoRoute(
            path: 'create-new-password',
            builder: (context, state) {
              final extras = state.extra as Map<String, String>? ?? {};
              return CreateNewPasswordScreen(
                  email: extras['email'] ?? '', otp: extras['otp'] ?? '');
            },
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => SuccessScreen(
              title: 'Thành công!',
              message: 'Mật khẩu đã được đổi. Vui lòng đăng nhập lại.',
              buttonText: 'Về trang Đăng nhập',
              onButtonPressed: () => context.go('/login'),
            ),
          ),
        ],
      ),

      // PATIENT FLOW
      ShellRoute(
        navigatorKey: _patientShellNavigatorKey,
        builder: (context, state, child) => PatientShellScreen(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const PatientDashboardScreen()),
          GoRoute(path: '/statistics', builder: (context, state) => const PatientStatsScreen()),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'details/:appointmentId',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) => AppointmentDetailScreen(
                  appointmentId: state.pathParameters['appointmentId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'personal-info', parentNavigatorKey: navigatorKey, builder: (context, state) => const PersonalInfoScreen()),
              GoRoute(path: 'health-record', parentNavigatorKey: navigatorKey, builder: (context, state) => const HealthRecordScreen()),
              GoRoute(path: 'my-reviews', parentNavigatorKey: navigatorKey, builder: (context, state) => const MyReviewsScreen()),
              GoRoute(
                path: 'settings',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'change-password', parentNavigatorKey: navigatorKey, builder: (context, state) => const ChangePasswordScreen()),
                ],
              ),
            ],
          ),
        ],
      ),

      // OTHER PATIENT ROUTES
      GoRoute(
        path: '/find-doctor',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => const FindDoctorScreen(),
        routes: [
          GoRoute(
            path: 'profile/:doctorId',
            parentNavigatorKey: navigatorKey,
            builder: (context, state) => DoctorDetailScreen(doctorId: state.pathParameters['doctorId']!),
            routes: [
              GoRoute(
                path: 'reviews',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) => DoctorReviewsListScreen(doctorId: state.pathParameters['doctorId']!),
              ),
              GoRoute(
                path: 'book',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) => BookAppointmentScreen(
                  doctorId: state.pathParameters['doctorId']!,
                  source: state.uri.queryParameters['source'],
                  appointmentId: state.uri.queryParameters['appointmentId'],
                ),
              ),
              GoRoute(
                path: 'booking-success',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) {
                  final isReschedule = state.uri.queryParameters['rescheduled'] == 'true';
                  final date = state.uri.queryParameters['date'];
                  final time = state.uri.queryParameters['time'];
                  return BookingSuccessScreen(
                    doctorId: state.pathParameters['doctorId'],
                    isReschedule: isReschedule,
                    dateStr: date,
                    timeStr: time,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/write-review',
        builder: (context, state) => WriteReviewScreen(appointment: state.extra as Appointment),
      ),
      GoRoute(
        path: '/prescriptions',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => const PrescriptionsListScreen(),
        routes: [
          GoRoute(
            path: 'details/:prescriptionId',
            parentNavigatorKey: navigatorKey,
            builder: (context, state) => PrescriptionDetailScreen(prescriptionId: state.pathParameters['prescriptionId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: 'details/:chatId',
            parentNavigatorKey: navigatorKey,
            builder: (context, state) {
              return ChatDetailScreen(
                chatId: state.pathParameters['chatId']!,
                partnerName: state.uri.queryParameters['name'],
                partnerId: state.uri.queryParameters['partnerId'],
                partnerAvatar: state.uri.queryParameters['avatar'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/medication-reminders',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => const MedicationRemindersScreen(),
        routes: [
          GoRoute(path: 'add', parentNavigatorKey: navigatorKey, builder: (context, state) => const AddReminderScreen()),
          GoRoute(path: 'edit', builder: (context, state) => AddReminderScreen(reminder: state.extra as Reminder?)),
        ],
      ),
      GoRoute(path: '/notifications', parentNavigatorKey: navigatorKey, builder: (context, state) => const NotificationsScreen()),
      GoRoute(
        path: '/health-articles',
        builder: (context, state) => const HealthArticlesScreen(),
        routes: [
          GoRoute(
            path: 'read',
            parentNavigatorKey: navigatorKey,
            builder: (context, state) => ArticleDetailScreen(
              url: state.uri.queryParameters['url'] ?? '',
              title: state.uri.queryParameters['title'] ?? 'Đọc báo',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/reschedule-success/:appointmentId',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => SuccessScreen(
          title: 'Yêu cầu đã được gửi!',
          message: 'Lịch hẹn của bạn đã được thay đổi, vui lòng chờ xác nhận.',
          buttonText: 'Xem chi tiết lịch hẹn',
          onButtonPressed: () => context.go('/appointments/details/${state.pathParameters['appointmentId']}'),
          icon: Icons.check_circle_outline_rounded,
        ),
      ),
      GoRoute(
        path: '/image-viewer',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) {
          final imageUrl = state.uri.queryParameters['url'] ?? '';
          return imageUrl.isEmpty ? const Text("Lỗi: Không tìm thấy ảnh.") : FullImageViewerScreen(imageUrl: imageUrl);
        },
      ),

      // DOCTOR FLOW
      ShellRoute(
        navigatorKey: _doctorShellNavigatorKey,
        builder: (context, state, child) => DoctorShellScreen(child: child),
        routes: [
          GoRoute(path: '/doctor/dashboard', builder: (context, state) => const DoctorDashboardScreen()),
          GoRoute(path: '/doctor/schedule', builder: (context, state) => const DoctorScheduleScreen()),
          GoRoute(path: '/doctor/analytics', builder: (context, state) => const DoctorAnalyticsScreen()),
          GoRoute(
            path: '/doctor/profile',
            builder: (context, state) => const DoctorProfileScreen(),
            routes: [
              GoRoute(path: 'reviews', parentNavigatorKey: navigatorKey, builder: (context, state) => const DoctorReviewsScreen()),
              GoRoute(
                path: 'settings',
                parentNavigatorKey: navigatorKey,
                builder: (context, state) => const DoctorSettingsScreen(),
                routes: [
                  GoRoute(path: 'change-password', parentNavigatorKey: navigatorKey, builder: (context, state) => const ChangePasswordScreen()),
                ],
              ),
              GoRoute(path: 'professional-info', parentNavigatorKey: navigatorKey, builder: (context, state) => const ProfessionalInfoScreen()),
              GoRoute(path: 'personal-info', parentNavigatorKey: navigatorKey, builder: (context, state) => const DoctorPersonalInfoScreen()),
            ],
          ),
        ],
      ),

      // OTHER DOCTOR ROUTES
      GoRoute(path: '/doctor/requests', parentNavigatorKey: navigatorKey, builder: (context, state) => const AppointmentRequestsScreen()),
      GoRoute(path: '/doctor/notifications', parentNavigatorKey: navigatorKey, builder: (context, state) => const DoctorNotificationsScreen()),
      GoRoute(path: '/doctor/notes', parentNavigatorKey: navigatorKey, builder: (context, state) => const DoctorNotesScreen()),
      GoRoute(path: '/doctor/list_patient', parentNavigatorKey: navigatorKey, builder: (context, state) => const PatientListScreen()),
      GoRoute(
        path: '/doctor/consultation/:patientId',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) {
          final rawId = state.pathParameters['patientId'] ?? '';
          final cleanIdStr = rawId.replaceAll(RegExp(r'[^0-9]'), '');
          final patientId = int.tryParse(cleanIdStr) ?? 0;
          return ConsultationScreen(patientId: patientId);
        },
      ),
      GoRoute(path: '/doctor/manage_schedule', parentNavigatorKey: navigatorKey, builder: (context, state) => const ManageAvailabilityScreen()),
      GoRoute(
        path: '/doctor/patient-detail-menu',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => DoctorPatientDetailScreen(patientData: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/doctor/services',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => ManageServicesScreen(doctorId: state.extra as String),
      ),
      GoRoute(
        path: '/doctor/appointment-details/:id',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => DoctorAppointmentDetailScreen(appointmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/doctor/prescriptions/:prescriptionId',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => DoctorPrescriptionDetailScreen(prescriptionId: state.pathParameters['prescriptionId']!),
      ),
      GoRoute(
        path: '/doctor/patient-stats/:patientId',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => PatientStatsDetailScreen(patientId: state.pathParameters['patientId']!),
      ),
      GoRoute(
        path: '/doctor/patient-record/:patientId',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => PatientRecordScreen(patientId: state.pathParameters['patientId']!),
      ),
      GoRoute(
        path: '/doctor/chat',
        parentNavigatorKey: navigatorKey,
        builder: (context, state) => const DoctorChatListScreen(),
        routes: [
          GoRoute(
            path: 'details/:chatId',
            parentNavigatorKey: navigatorKey,
            builder: (context, state) {
              return ChatDetailScreen(
                chatId: state.pathParameters['chatId']!,
                partnerName: state.uri.queryParameters['name'],
                partnerId: state.uri.queryParameters['partnerId'],
                partnerAvatar: state.uri.queryParameters['avatar'],
              );
            },
          ),
        ],
      ),
    ],
  );
}