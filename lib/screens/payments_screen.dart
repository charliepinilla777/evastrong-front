import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/payment_provider.dart';
import '../widgets/pricing_cards.dart';

class PaymentsScreen extends StatefulWidget {
  final String jwtToken;

  const PaymentsScreen({
    super.key,
    required this.jwtToken,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedCurrency = 'COP'; // 'COP' | 'USD'
  String selectedPeriod = 'monthly'; // 'monthly' | 'annual'
  String? _pendingPayPalOrderId;   // orderId guardado para capturar tras volver de PayPal
  String? _pendingWompiReference;  // reference guardada para verificar tras volver de Wompi

  @override
  void initState() {
    super.initState();
    _initializePayments();
  }

  Future<void> _initializePayments() async {
    try {
      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.setJwtToken(widget.jwtToken);
      await paymentProvider.fetchSubscription();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar suscripción: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  const SizedBox(height: 16),
                  Text(
                    'Elige tu plan perfecto',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acceso a entrenamientos ilimitados y contenido exclusivo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Selectores de Moneda y Período
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moneda',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedCurrency,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'COP',
                                  child: Text('💰 Pesos Colombianos (COP)'),
                                ),
                                DropdownMenuItem(
                                  value: 'USD',
                                  child: Text('💵 Dólares (USD)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrency = value ?? 'COP';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Período',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedPeriod,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Mensual'),
                                ),
                                DropdownMenuItem(
                                  value: 'annual',
                                  child: Text('Anual'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedPeriod = value ?? 'monthly';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (paymentProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              paymentProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: paymentProvider.clearError,
                          ),
                        ],
                      ),
                    ),
                  if (paymentProvider.error != null)
                    const SizedBox(height: 16),

                  // Tarjetas de Precio
                  _buildPricingCards(context, paymentProvider),

                  const SizedBox(height: 32),

                  // Botón para confirmar pago PayPal pendiente
                  if (_pendingPayPalOrderId != null)
                    _buildConfirmPayPalButton(context, paymentProvider),

                  if (_pendingPayPalOrderId != null)
                    const SizedBox(height: 32),

                  // Botón para confirmar pago Wompi pendiente
                  if (_pendingWompiReference != null)
                    _buildConfirmWompiButton(context, paymentProvider),

                  if (_pendingWompiReference != null)
                    const SizedBox(height: 32),

                  // Suscripción Actual
                  if (paymentProvider.hasActiveSubscription)
                    _buildCurrentSubscription(context, paymentProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPricingCards(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) {
    final currentPlan = paymentProvider.currentPlan;

    return Column(
      children: [
        // Plan Basic
        PricingCard(
          plan: 'basic',
          title: 'Plan Basic',
          price: selectedCurrency == 'COP'
              ? (selectedPeriod == 'monthly' ? '39.900' : '399.900')
              : (selectedPeriod == 'monthly' ? '9.99' : '99.99'),
          currency: selectedCurrency,
          period: selectedPeriod == 'monthly' ? 'mes' : 'año',
          features: [
            'Acceso a 50+ entrenamientos',
            'Seguimiento de progreso',
            'Comunidad exclusiva',
            'Soporte por email',
          ],
          isSelected: currentPlan == 'basic',
          onPayPalPressed: () => _handlePayPalPayment(context, 'basic', selectedPeriod),
          onMercadoPagoPressed: () => _handleMercadoPagoPayment(context, 'basic', selectedPeriod, selectedCurrency),
          onWompiPressed: () => _handleWompiPayment(context, 'basic', selectedPeriod),
        ),
        const SizedBox(height: 24),

        // Plan Premium
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -12,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Más Popular',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              PricingCard(
                plan: 'premium',
                title: 'Plan Premium',
                price: selectedCurrency == 'COP'
                    ? (selectedPeriod == 'monthly' ? '79.900' : '799.900')
                    : (selectedPeriod == 'monthly' ? '19.99' : '199.99'),
                currency: selectedCurrency,
                period: selectedPeriod == 'monthly' ? 'mes' : 'año',
                features: [
                  'Acceso a 500+ entrenamientos',
                  'Seguimiento avanzado de progreso',
                  'Clases en vivo semanales',
                  'Planes personalizados',
                  'Soporte prioritario 24/7',
                  'Acceso a contenido exclusivo',
                ],
                isSelected: currentPlan == 'premium',
                onPayPalPressed: () => _handlePayPalPayment(context, 'premium', selectedPeriod),
                onMercadoPagoPressed: () => _handleMercadoPagoPayment(context, 'premium', selectedPeriod, selectedCurrency),
                onWompiPressed: () => _handleWompiPayment(context, 'premium', selectedPeriod),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSubscription(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Text(
                  'Suscripción Activa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Plan: ${paymentProvider.currentPlan?.toUpperCase()}',
              style: const TextStyle(fontSize: 14),
            ),
            if (paymentProvider.subscriptionEndDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Vencimiento: ${paymentProvider.subscriptionEndDate}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPayPalButton(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Pago PayPal pendiente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Si ya completaste el pago en PayPal, toca el botón para confirmar tu suscripción.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: paymentProvider.isLoading
                      ? null
                      : () => _confirmPayPalCapture(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: paymentProvider.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Ya completé el pago'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() => _pendingPayPalOrderId = null);
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayPalCapture(BuildContext context) async {
    if (_pendingPayPalOrderId == null) return;
    final paymentProvider = context.read<PaymentProvider>();

    final result = await paymentProvider.capturePayPalOrder(
      orderId: _pendingPayPalOrderId!,
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      setState(() => _pendingPayPalOrderId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Suscripción activada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handlePayPalPayment(
    BuildContext context,
    String plan,
    String period,
  ) async {
    final paymentProvider = context.read<PaymentProvider>();

    final result = await paymentProvider.createPayPalOrder(
      plan: plan,
      period: period,
    );

    if (result != null && result['approvalLink'] != null) {
      // Guardar el orderId para capturar cuando el usuario vuelva
      setState(() => _pendingPayPalOrderId = result['orderId']);

      final url = Uri.parse(result['approvalLink']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa el pago en PayPal y regresa aquí para confirmarlo'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildConfirmWompiButton(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Pago Wompi pendiente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Si ya completaste el pago en Wompi (PSE, Nequi, tarjeta), toca el botón para verificar tu suscripcion.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: paymentProvider.isLoading
                      ? null
                      : () => _confirmWompiPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                  ),
                  child: paymentProvider.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verificar pago'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _pendingWompiReference = null),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmWompiPayment(BuildContext context) async {
    if (_pendingWompiReference == null) return;
    final paymentProvider = context.read<PaymentProvider>();

    final result = await paymentProvider.verifyWompiTransaction(
      reference: _pendingWompiReference!,
    );

    if (!mounted) return;

    if (result != null && result['status'] == 'APPROVED') {
      setState(() => _pendingWompiReference = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Suscripcion activada exitosamente con Wompi!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result != null && result['status'] == 'PENDING') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El pago aun esta en proceso. Intenta en unos segundos.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El pago no fue aprobado. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _pendingWompiReference = null);
    }
  }

  Future<void> _handleWompiPayment(
    BuildContext context,
    String plan,
    String period,
  ) async {
    final paymentProvider = context.read<PaymentProvider>();

    final result = await paymentProvider.createWompiSession(
      plan: plan,
      period: period,
    );

    if (result != null && result['checkoutUrl'] != null) {
      setState(() => _pendingWompiReference = result['reference']);

      final url = Uri.parse(result['checkoutUrl']);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa el pago en Wompi (PSE, Nequi, tarjeta) y regresa aqui para verificarlo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleMercadoPagoPayment(
    BuildContext context,
    String plan,
    String period,
    String currency,
  ) async {
    final paymentProvider = context.read<PaymentProvider>();

    final result = await paymentProvider.createMercadoPagoPreference(
      plan: plan,
      period: period,
      currency: currency,
    );

    if (result != null && result['initPoint'] != null) {
      final url = Uri.parse(result['initPoint']);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abre Mercado Pago para completar el pago'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    }
  }
}
