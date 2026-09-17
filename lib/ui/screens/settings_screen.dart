import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_service.dart';
import '../../services/trip_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _upiController;
  late TextEditingController _vehicleController;

  late TextEditingController _baseFareController;
  late TextEditingController _perKmController;
  late TextEditingController _waitingRateController;
  late TextEditingController _minDistanceKmController;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final manager = context.read<TripManager>();
      _nameController = TextEditingController(text: manager.driverProfile.name);
      _upiController = TextEditingController(text: manager.driverProfile.upiId);
      _vehicleController = TextEditingController(text: manager.driverProfile.vehicleNumber);

      _baseFareController = TextEditingController(text: manager.fareConfig.baseFare.toStringAsFixed(2));
      _perKmController = TextEditingController(text: manager.fareConfig.perKmRate.toStringAsFixed(2));
      _waitingRateController = TextEditingController(text: manager.fareConfig.waitingRatePerMin.toStringAsFixed(2));
      _minDistanceKmController = TextEditingController(text: manager.fareConfig.minDistanceKm.toStringAsFixed(1));

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    _vehicleController.dispose();
    _baseFareController.dispose();
    _perKmController.dispose();
    _waitingRateController.dispose();
    _minDistanceKmController.dispose();
    super.dispose();
  }

  void _saveSettings(TripManager manager) async {
    if (_formKey.currentState?.validate() ?? false) {
      final newProfile = manager.driverProfile.copyWith(
        name: _nameController.text.trim(),
        upiId: _upiController.text.trim(),
        vehicleNumber: _vehicleController.text.trim(),
      );

      final newConfig = manager.fareConfig.copyWith(
        baseFare: double.tryParse(_baseFareController.text) ?? manager.fareConfig.baseFare,
        perKmRate: double.tryParse(_perKmController.text) ?? manager.fareConfig.perKmRate,
        waitingRatePerMin: double.tryParse(_waitingRateController.text) ?? manager.fareConfig.waitingRatePerMin,
        minDistanceKm: double.tryParse(_minDistanceKmController.text) ?? manager.fareConfig.minDistanceKm,
      );

      await manager.updateDriverProfile(newProfile);
      await manager.updateFareConfig(newConfig);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.meterGreen,
          ),
        );
      }
    }
  }

  void _confirmResetDemo(BuildContext context, TripManager manager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.meterSurface,
        title: const Text('Reset Demo Data?'),
        content: const Text(
          'This will clear all prototype trips and reset fare rates and driver information to clean competition defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.meterRed),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await manager.resetAllDemoData();
              _nameController.text = manager.driverProfile.name;
              _upiController.text = manager.driverProfile.upiId;
              _vehicleController.text = manager.driverProfile.vehicleNumber;
              _baseFareController.text = manager.fareConfig.baseFare.toStringAsFixed(2);
              _perKmController.text = manager.fareConfig.perKmRate.toStringAsFixed(2);
              _waitingRateController.text = manager.fareConfig.waitingRatePerMin.toStringAsFixed(2);
              _minDistanceKmController.text = manager.fareConfig.minDistanceKm.toStringAsFixed(1);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Demo environment reset to fresh presentation state'),
                    backgroundColor: AppColors.meterGreen,
                  ),
                );
              }
            },
            child: const Text('RESET ALL DATA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Driver Profile
          _buildSectionHeader('DRIVER & VEHICLE IDENTIFIER'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameController,
            label: 'Driver Name',
            icon: Icons.person_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter driver name' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _vehicleController,
            label: 'Auto Registration Number',
            icon: Icons.electric_rickshaw_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter registration number' : null,
          ),
          const SizedBox(height: 24),

          // Section: UPI Payment
          _buildSectionHeader('UPI PAYMENT CONFIGURATION'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _upiController,
            label: 'Payee UPI ID / VPA',
            icon: Icons.qr_code_rounded,
            hint: 'e.g. driver@upi or 9876543210@paytm',
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter UPI ID';
              if (!PaymentService.isValidUpiId(v)) return 'Invalid UPI format (e.g. name@bank or phone@bank)';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Section: Fare Tariff
          _buildSectionHeader('FARE TARIFF CONFIGURATION'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _baseFareController,
            label: 'Base Minimum Fare (₹)',
            icon: Icons.flag_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter base fare';
              final val = double.tryParse(v);
              if (val == null || val <= 0) return 'Base fare must be greater than 0';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _minDistanceKmController,
            label: 'Distance Included in Base Fare (km)',
            icon: Icons.map_rounded,
            hint: '0 for flat base + per-km; e.g. 1.5 or 2.0 for regional tariff',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter included distance (0 for flat)';
              final val = double.tryParse(v);
              if (val == null || val < 0) return 'Distance must be 0 or greater';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _perKmController,
            label: 'Rate per Kilometre (₹/km)',
            icon: Icons.straighten_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter rate per km';
              final val = double.tryParse(v);
              if (val == null || val <= 0) return 'Rate must be greater than 0';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _waitingRateController,
            label: 'Waiting Charge (₹/minute)',
            icon: Icons.hourglass_bottom_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter waiting charge';
              final val = double.tryParse(v);
              if (val == null || val < 0) return 'Waiting charge must be 0 or greater';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Section: Operating Mode
          _buildSectionHeader('METER TRACKING MODE'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.meterCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.meterCardBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.meterAmber,
                  title: const Text('Demo Simulation Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text(
                    'Simulates movement & waiting for competition presentation without driving',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  value: manager.isDemoMode,
                  onChanged: (val) {
                    manager.setDemoMode(val);
                  },
                ),
                const Divider(color: AppColors.meterDivider),
                Row(
                  children: [
                    Icon(
                      manager.isDemoMode ? Icons.science_rounded : Icons.gps_fixed_rounded,
                      size: 16,
                      color: manager.isDemoMode ? AppColors.meterAmber : AppColors.meterGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      manager.isDemoMode ? 'Active Provider: Synthetic GPS Engine' : 'Active Provider: Device Hardware GPS',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Supabase Cloud Sync Status
          _buildSectionHeader('CLOUD SYNCHRONIZATION (SUPABASE)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.meterCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.meterCardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (SupabaseService.isConfigured ? AppColors.meterGreen : AppColors.meterAmber).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        SupabaseService.isConfigured ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: SupabaseService.isConfigured ? AppColors.meterGreen : AppColors.meterAmber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SupabaseService.isConfigured ? 'Supabase Connected' : 'Offline-First Storage Mode',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            SupabaseService.isConfigured
                                ? 'Completed trips sync to remote PostgreSQL automatically'
                                : 'Trips stored locally on device; will sync when cloud endpoint configured',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (manager.unsyncedTripCount > 0) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.meterDivider),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${manager.unsyncedTripCount} trip(s) pending cloud sync',
                        style: const TextStyle(color: AppColors.meterAmber, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: manager.isSyncing
                            ? null
                            : () async {
                                final synced = await manager.syncAllPendingTrips();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(synced > 0 ? '$synced trip(s) synced to cloud!' : 'Cloud endpoint unavailable, kept offline'),
                                      backgroundColor: synced > 0 ? AppColors.meterGreen : AppColors.meterAmber,
                                    ),
                                  );
                                }
                              },
                        child: manager.isSyncing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('SYNC NOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save Settings Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _saveSettings(manager),
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 16),

          // Reset Demo Button
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.meterRed, width: 1.2),
              ),
              onPressed: () => _confirmResetDemo(context, manager),
              icon: const Icon(Icons.restore_rounded, color: AppColors.meterRed, size: 20),
              label: const Text(
                'RESET DEMO (CLEAN STATE)',
                style: TextStyle(color: AppColors.meterRed, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.meterAmber, size: 20),
        filled: true,
        fillColor: AppColors.meterCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.meterCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.meterCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.meterAmber, width: 1.5),
        ),
      ),
    );
  }
}
