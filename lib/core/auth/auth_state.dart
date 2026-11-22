class TenantMembership {
  const TenantMembership({
    required this.tenantId,
    required this.tenantName,
    required this.role,
    this.farmScope = const [],
  });

  factory TenantMembership.fromJson(Map<String, dynamic> json) {
    return TenantMembership(
      tenantId: json['tenantId'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      role: json['role'] as String? ?? 'WORKER',
      farmScope: (json['farmScope'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }

  final String tenantId;
  final String tenantName;
  final String role;
  final List<String> farmScope;

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'tenantName': tenantName,
        'role': role,
        'farmScope': farmScope,
      };
}

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.accessToken,
    this.tenantId,
    this.email,
    this.phone,
    this.displayName,
    this.platformAdmin = false,
    this.memberships = const [],
  });

  const AuthState.unauthenticated()
      : isAuthenticated = false,
        accessToken = null,
        tenantId = null,
        email = null,
        phone = null,
        displayName = null,
        platformAdmin = false,
        memberships = const [];

  final bool isAuthenticated;
  final String? accessToken;
  final String? tenantId;
  final String? email;
  final String? phone;
  final String? displayName;
  final bool platformAdmin;
  final List<TenantMembership> memberships;

  TenantMembership? get currentMembership {
    for (final membership in memberships) {
      if (membership.tenantId == tenantId) {
        return membership;
      }
    }
    return memberships.isEmpty ? null : memberships.first;
  }

  String get initials {
    final source = (displayName ?? email ?? '').trim();
    if (source.isEmpty) {
      return '?';
    }
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    String? tenantId,
    String? email,
    String? phone,
    String? displayName,
    bool? platformAdmin,
    List<TenantMembership>? memberships,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      tenantId: tenantId ?? this.tenantId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      platformAdmin: platformAdmin ?? this.platformAdmin,
      memberships: memberships ?? this.memberships,
    );
  }
}
