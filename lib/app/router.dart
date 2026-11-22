import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/alerts/alerts_page.dart';
import '../features/alerts/tasks_page.dart';
import '../features/alerts/today_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/otp_page.dart';
import '../features/auth/pin_page.dart';
import '../features/billing/subscription_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/finance/costs_page.dart';
import '../features/finance/expense_page.dart';
import '../features/finance/finance_page.dart';
import '../features/finance/revenue_page.dart';
import '../features/feeding/distribution_page.dart';
import '../features/feeding/feeding_page.dart';
import '../features/feeding/feeds_page.dart';
import '../features/feeding/plans_page.dart';
import '../features/feeding/receipt_page.dart';
import '../features/feeding/stock_page.dart';
import '../features/files/exports_page.dart';
import '../features/files/share_page.dart';
import '../features/health/health_page.dart';
import '../features/health/mortality_form_page.dart';
import '../features/health/products_page.dart';
import '../features/health/quarantine_form_page.dart';
import '../features/health/treatment_form_page.dart';
import '../features/health/vaccination_form_page.dart';
import '../features/health/withdrawals_page.dart';
import '../features/herd/animal_detail_page.dart';
import '../features/herd/animal_form_page.dart';
import '../features/herd/animal_status_page.dart';
import '../features/herd/herd_page.dart';
import '../features/herd/lot_close_page.dart';
import '../features/herd/lot_detail_page.dart';
import '../features/herd/lot_form_page.dart';
import '../features/herd/lot_movements_page.dart';
import '../features/herd/lots_page.dart';
import '../features/invitations/invitation_page.dart';
import '../features/members/members_page.dart';
import '../features/notifications/notifications_preferences_page.dart';
import '../features/platform/platform_dashboard_page.dart';
import '../features/production/collection_page.dart';
import '../features/production/egg_stock_page.dart';
import '../features/production/growth_page.dart';
import '../features/production/production_page.dart';
import '../features/production/weighing_page.dart';
import '../features/reproduction/birth_form_page.dart';
import '../features/reproduction/cycle_detail_page.dart';
import '../features/reproduction/diagnosis_form_page.dart';
import '../features/reproduction/heat_form_page.dart';
import '../features/reproduction/mating_form_page.dart';
import '../features/reproduction/reproduction_page.dart';
import '../features/reproduction/weaning_form_page.dart';
import '../features/reports/reports_page.dart';
import '../features/sales/clients_page.dart';
import '../features/sales/payments_page.dart';
import '../features/sales/sale_form_page.dart';
import '../features/sales/sales_page.dart';
import '../features/settings/settings_page.dart';
import '../features/sites/farm_plan_page.dart';
import '../features/sites/sites_page.dart';
import '../features/species/breeds_page.dart';
import '../features/species/species_form_page.dart';
import '../features/species/species_list_page.dart';
import '../features/species/species_plans_page.dart';
import '../features/sync/conflicts_page.dart';
import '../features/tenant/select_tenant_page.dart';
import '../shared/widgets/app_shell.dart';

const _publicRoutes = {'/login', '/otp', '/invitation'};

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref.listen<AuthState>(authControllerProvider, (_, next) => authNotifier.value = next);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authenticated = ref.read(authControllerProvider).isAuthenticated;
      final isPublic = _publicRoutes.contains(state.matchedLocation);
      if (!authenticated) {
        return isPublic ? null : '/login';
      }
      if (state.matchedLocation == '/login' || state.matchedLocation == '/otp') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpPage(
          challengeId: state.uri.queryParameters['challenge'],
          destination: state.uri.queryParameters['destination'],
        ),
      ),
      GoRoute(
        path: '/invitation',
        builder: (context, state) =>
            InvitationPage(token: state.uri.queryParameters['token']),
      ),
      GoRoute(
        path: '/select-tenant',
        builder: (context, state) => const SelectTenantPage(),
      ),
      GoRoute(
        path: '/members',
        builder: (context, state) => const MembersPage(),
      ),
      GoRoute(
        path: '/pin',
        builder: (context, state) => const PinPage(),
      ),
      GoRoute(
        path: '/species/new',
        builder: (context, state) => const SpeciesFormPage(),
      ),
      GoRoute(
        path: '/species/:id/edit',
        builder: (context, state) =>
            SpeciesFormPage(speciesId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/species/:id/breeds',
        builder: (context, state) =>
            BreedsPage(speciesId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/species/:id/plans',
        builder: (context, state) =>
            SpeciesPlansPage(speciesId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/herd/new',
        builder: (context, state) => const AnimalFormPage(),
      ),
      GoRoute(
        path: '/herd/:id/edit',
        builder: (context, state) =>
            AnimalFormPage(animalId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/herd/:id/status',
        builder: (context, state) =>
            AnimalStatusPage(animalId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/herd/:id',
        builder: (context, state) =>
            AnimalDetailPage(animalId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/lots/new',
        builder: (context, state) => const LotFormPage(),
      ),
      GoRoute(
        path: '/lots/:id/edit',
        builder: (context, state) =>
            LotFormPage(lotId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/lots/:id/movements',
        builder: (context, state) =>
            LotMovementsPage(lotId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/lots/:id/close',
        builder: (context, state) =>
            LotClosePage(lotId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/lots/:id',
        builder: (context, state) =>
            LotDetailPage(lotId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/reproduction/heats',
        builder: (context, state) => const HeatFormPage(),
      ),
      GoRoute(
        path: '/reproduction/matings',
        builder: (context, state) => const MatingFormPage(),
      ),
      GoRoute(
        path: '/reproduction/diagnoses',
        builder: (context, state) => DiagnosisFormPage(
          cycleId: state.uri.queryParameters['cycle'],
        ),
      ),
      GoRoute(
        path: '/reproduction/births',
        builder: (context, state) => BirthFormPage(
          cycleId: state.uri.queryParameters['cycle'],
        ),
      ),
      GoRoute(
        path: '/reproduction/weanings',
        builder: (context, state) => WeaningFormPage(
          cycleId: state.uri.queryParameters['cycle'],
          litterId: state.uri.queryParameters['litter'],
        ),
      ),
      GoRoute(
        path: '/reproduction/cycles/:id',
        builder: (context, state) =>
            CycleDetailPage(cycleId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/health/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/health/vaccinations',
        builder: (context, state) => const VaccinationFormPage(),
      ),
      GoRoute(
        path: '/health/treatments',
        builder: (context, state) => const TreatmentFormPage(),
      ),
      GoRoute(
        path: '/health/withdrawals',
        builder: (context, state) => const WithdrawalsPage(),
      ),
      GoRoute(
        path: '/health/mortalities',
        builder: (context, state) => const MortalityFormPage(),
      ),
      GoRoute(
        path: '/health/quarantines',
        builder: (context, state) => const QuarantineFormPage(),
      ),
      GoRoute(
        path: '/feeding/feeds',
        builder: (context, state) => const FeedsPage(),
      ),
      GoRoute(
        path: '/feeding/receipts',
        builder: (context, state) => const ReceiptPage(),
      ),
      GoRoute(
        path: '/feeding/distributions',
        builder: (context, state) => const DistributionPage(),
      ),
      GoRoute(
        path: '/feeding/stocks',
        builder: (context, state) => const StockPage(),
      ),
      GoRoute(
        path: '/feeding/plans',
        builder: (context, state) => const FeedingPlansPage(),
      ),
      GoRoute(
        path: '/production/weighings',
        builder: (context, state) => const WeighingPage(),
      ),
      GoRoute(
        path: '/production/growth',
        builder: (context, state) => const GrowthPage(),
      ),
      GoRoute(
        path: '/production/collections',
        builder: (context, state) => const CollectionPage(),
      ),
      GoRoute(
        path: '/production/egg-stocks',
        builder: (context, state) => const EggStockPage(),
      ),
      GoRoute(
        path: '/sales/new',
        builder: (context, state) => const SaleFormPage(),
      ),
      GoRoute(
        path: '/sales/payments',
        builder: (context, state) => const PaymentsPage(),
      ),
      GoRoute(
        path: '/sales/clients',
        builder: (context, state) => const ClientsPage(),
      ),
      GoRoute(
        path: '/finance/expenses',
        builder: (context, state) => const ExpensePage(),
      ),
      GoRoute(
        path: '/finance/revenues',
        builder: (context, state) => const RevenuePage(),
      ),
      GoRoute(
        path: '/finance/costs',
        builder: (context, state) => const CostsPage(),
      ),
      GoRoute(
        path: '/files/exports',
        builder: (context, state) => const ExportsPage(),
      ),
      GoRoute(
        path: '/files/share',
        builder: (context, state) => SharePage(
          exportJobId: state.uri.queryParameters['export'],
          attachmentId: state.uri.queryParameters['attachment'],
          entityType: state.uri.queryParameters['entityType'],
          entityId: state.uri.queryParameters['entityId'],
        ),
      ),
      GoRoute(
        path: '/notifications/preferences',
        builder: (context, state) => const NotificationPreferencesPage(),
      ),
      GoRoute(
        path: '/alerts/today',
        builder: (context, state) => const TodayPage(),
      ),      GoRoute(
        path: '/alerts/tasks',
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: '/sync/conflicts',
        builder: (context, state) => const ConflictsPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/herd', builder: (context, state) => const HerdPage()),
          GoRoute(
            path: '/reproduction',
            builder: (context, state) => const ReproductionPage(),
          ),
          GoRoute(path: '/health', builder: (context, state) => const HealthPage()),
          GoRoute(path: '/feeding', builder: (context, state) => const FeedingPage()),
          GoRoute(path: '/production', builder: (context, state) => const ProductionPage()),
          GoRoute(path: '/species', builder: (context, state) => const SpeciesListPage()),
          GoRoute(path: '/lots', builder: (context, state) => const LotsPage()),
          GoRoute(path: '/sites', builder: (context, state) => const SitesPage()),
          GoRoute(path: '/sites/plan', builder: (context, state) => const FarmPlanPage()),
          GoRoute(path: '/sales', builder: (context, state) => const SalesPage()),
          GoRoute(path: '/finance', builder: (context, state) => const FinancePage()),
          GoRoute(path: '/alerts', builder: (context, state) => const AlertsPage()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          GoRoute(path: '/settings/subscription', builder: (context, state) => const SubscriptionPage()),
          GoRoute(path: '/platform', builder: (context, state) => const PlatformDashboardPage()),
        ],
      ),
    ],
  );
});
