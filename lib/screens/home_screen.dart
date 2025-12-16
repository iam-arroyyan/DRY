import 'package:flutter/material.dart';
import '../models/dryer_data.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mini Dryer',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'by ESP32',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey[600]),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: StreamBuilder<DryerData>(
        stream: _firebaseService.getDryerStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final data = snapshot.data ?? DryerData.empty();

          return Column(
            children: [
              Expanded(
                child: _buildMainContent(data),
              ),
              _buildBottomSection(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(DryerData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Temperature & Humidity Display
        _buildGradientText(data),
        const SizedBox(height: 40),

        // Big Toggle Switch
        _buildBigToggle(data),
        const SizedBox(height: 24),

        // Status Text
        Text(
          data.powerOn ? 'Aktif' : 'Nonaktif',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),

        // Status Message
        Text(
          data.message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Status Badge
        _buildStatusBadge(data),
      ],
    );
  }

  Widget _buildGradientText(DryerData data) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: _getGradientColors(data),
      ).createShader(bounds),
      child: Column(
        children: [
          Text(
            '${data.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          Text(
            '${data.humidity.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(DryerData data) {
    if (data.state == 'OVERHEAT') {
      return [Colors.red, Colors.deepOrange];
    } else if (data.state == 'DONE') {
      return [Colors.green, Colors.teal];
    } else if (data.state == 'DRYING') {
      return [Colors.deepOrange, Colors.amber];
    } else {
      return [Colors.grey, Colors.blueGrey];
    }
  }

  Widget _buildBigToggle(DryerData data) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _togglePower(!data.powerOn);
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 140,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: data.powerOn
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: data.powerOn
                    ? Colors.deepOrange.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: data.powerOn ? 68 : 8,
                top: 8,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.deepOrange,
                          ),
                        )
                      : Icon(
                          Icons.power_settings_new,
                          size: 32,
                          color: data.powerOn ? Colors.deepOrange : Colors.grey,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DryerData data) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (data.state) {
      case 'DRYING':
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.deepOrange;
        icon = Icons.whatshot;
        break;
      case 'DONE':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'OVERHEAT':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        icon = Icons.warning;
        break;
      case 'ERROR':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        icon = Icons.error;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        icon = Icons.power_settings_new;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            data.state,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(DryerData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auto Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Stop',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Otomatis berhenti saat kering',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: data.autoMode,
                  onChanged: (value) => _toggleAutoMode(value),
                  activeColor: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Indicators Row
            Row(
              children: [
                Expanded(
                  child: _buildIndicatorChip(
                    'Relay',
                    data.relayOn,
                    Icons.electric_bolt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIndicatorChip(
                    'Buzzer',
                    data.buzzerOn,
                    Icons.volume_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorChip(String label, bool isOn, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOn ? Colors.deepOrange.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOn ? Colors.deepOrange.withValues(alpha: 0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.deepOrange : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 18,
            color: isOn ? Colors.deepOrange : Colors.grey[500],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isOn ? Colors.deepOrange : Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Koneksi Terputus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.deepOrange),
            SizedBox(width: 12),
            Text('Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Target Kelembapan', '≤ 60%'),
            _buildInfoRow('Batas Suhu', '≤ 50°C'),
            const Divider(),
            const Text(
              'Mini Dryer akan otomatis berhenti jika kelembapan mencapai target atau suhu terlalu tinggi.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _togglePower(bool value) async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.setPower(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleAutoMode(bool value) async {
    try {
      await _firebaseService.setAutoMode(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
