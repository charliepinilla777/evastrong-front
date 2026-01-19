import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/payment_provider.dart';
import '../widgets/pricing_cards.dart';

class PaymentsScreen extends StatefulWidget {
  final String jwtToken;

  const PaymentsScreen({
    Key? key,
    required this.jwtToken,
  }) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedCurrency = 'COP'; // 'COP' | 'USD'
  String selectedPeriod = 'monthly'; // 'monthly' | 'annual'

  @override
  void initState() {
    super.initState();
    // Obtener suscripción actual al cargar
    Future.microtask(() {
      context.read<PaymentProvider>().setJwtToken(widget.jwtToken);
      context.read<PaymentProvider>().fetchSubscription();
    });
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
          onPayPalPressed: () {
            _handlePayPalPayment(context, 'basic', selectedPeriod);
          },
          onMercadoPagoPressed: () {
            _handleMercadoPagoPayment(
              context,
              'basic',
              selectedPeriod,
              selectedCurrency,
            );
          },
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
                onPayPalPressed: () {
                  _handlePayPalPayment(context, 'premium', selectedPeriod);
                },
                onMercadoPagoPressed: () {
                  _handleMercadoPagoPayment(
                    context,
                    'premium',
                    selectedPeriod,
                    selectedCurrency,
                  );
                },
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
      final url = Uri.parse(result['approvalLink']);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        // Guardar el orderId para capturar después
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abre PayPal para completar el pago'),
              backgroundColor: Colors.blue,
            ),
          );
        }
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
