import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main(){
  runApp(const CustomerChurnApp());
}

class CustomerChurnApp extends StatelessWidget{
  const CustomerChurnApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:"Customer Churn AI",
      debugShowCheckedModeBanner: false,
      theme:ThemeData(
        colorScheme:ColorScheme.fromSeed(
          seedColor:Colors.blue ,
        ),
        useMaterial3:true ,
      ),
      home:const HomePage(),
      
    );
  }
}
class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  double? churnProbability;
  double? retentionProbability;
  String? riskLevel;
  String? status;
  String? summary;
  String? recommendedAction;
  bool isLoading = false;


  String gender = "Female" ;
  bool seniorCitizen = false ;
  String partner = 'Yes';
  String dependents = 'No';
  final TextEditingController tenureController = TextEditingController();
  String phoneService = 'Yes';
  String multipleLines = 'No';
  String internetService = 'Fiber optic';
  String onlineSecurity = 'No';
  String onlineBackup = 'No';
  String deviceProtection = 'No';
  String techSupport = 'No';
  String streamingTV = 'No';
  String streamingMovies = 'No';
  String contract = 'Month-to-month';
  String paperlessBilling = 'Yes';
  String paymentMethod = 'Electronic check';
  final TextEditingController monthlyChargesController =
    TextEditingController();

  final TextEditingController totalChargesController =
    TextEditingController();


  Widget buildDropdown({
  required String label,
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

    Map<String, dynamic> buildCustomerData() {

      final tenure = int.tryParse(tenureController.text.trim());
      final monthlyCharges =
          double.tryParse(monthlyChargesController.text.trim());
      final totalCharges =
          double.tryParse(totalChargesController.text.trim());

      if (tenure == null ||
          monthlyCharges == null ||
          totalCharges == null) {
        throw Exception(
          'Please enter valid numbers for Tenure, Monthly Charges, and Total Charges.',
        );
      }
      if (tenure < 0 ||
          monthlyCharges < 0 ||
          totalCharges < 0) {
        throw Exception(
          'Tenure and charges cannot be negative.',
        );
      }
      
        return {
      'gender': gender,
      'SeniorCitizen': seniorCitizen ? 1 : 0,
      'Partner': partner,
      'Dependents': dependents,
      'tenure': tenure,
      'PhoneService': phoneService,
      'MultipleLines': multipleLines,
      'InternetService': internetService,
      'OnlineSecurity': onlineSecurity,
      'OnlineBackup': onlineBackup,
      'DeviceProtection': deviceProtection,
      'TechSupport': techSupport,
      'StreamingTV': streamingTV,
      'StreamingMovies': streamingMovies,
      'Contract': contract,
      'PaperlessBilling': paperlessBilling,
      'PaymentMethod': paymentMethod,
      'MonthlyCharges': monthlyCharges,
      'TotalCharges': totalCharges,
    };
  }
      
      void resetCustomerForm() {
        setState(() {
          gender = 'Female';
          seniorCitizen = false;
          partner = 'No';
          dependents = 'No';
          tenureController.clear();
          phoneService = 'Yes';
          multipleLines = 'No';
          internetService = 'Fiber optic';
          onlineSecurity = 'No';
          onlineBackup = 'No';
          deviceProtection = 'No';
          techSupport = 'No';
          streamingTV = 'No';
          streamingMovies = 'No';
          contract = 'Month-to-month';
          paperlessBilling = 'Yes';
          paymentMethod = 'Electronic check';
          monthlyChargesController.clear();
          totalChargesController.clear();
        });
      }

      
      Future<void> predict() async {
        setState(() {
          isLoading = true;
        });

        try {
          final customerData = buildCustomerData();

       final response = await http.post(
            Uri.parse('http://127.0.0.1:8000/predict'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(customerData),
          );

          if (response.statusCode != 200) {
            throw Exception('API error: ${response.statusCode}');
          }

          final data = jsonDecode(response.body);

          final newChurnProbability =
              (data['churn_probability'] as num).toDouble();
          final newRetentionProbability =
              (data['retention_probability'] as num).toDouble();
          final newRiskLevel = data['risk_level'] as String;
          final newStatus = data['status'] as String;
          final newSummary = data['summary'] as String;
          final newRecommendedAction =
              data['recommended_action'] as String;

          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                onAnalyzeAnother: resetCustomerForm,
                churnProbability: newChurnProbability,
                retentionProbability: newRetentionProbability,
                riskLevel: newRiskLevel,
                status: newStatus,
                summary: newSummary,
                recommendedAction: newRecommendedAction,
              ),
            ),
          );
        } catch (e) {
          debugPrint('Prediction error: $e');

          if (mounted) {
            final errorMessage = e.toString();

            final message = errorMessage.contains(
              'Please enter valid numbers',
            )
                ? 'Please enter valid numbers in all required fields.'
                : errorMessage.contains('cannot be negative')
                    ? 'Tenure and charges cannot be negative.'
                    : 'Unable to analyze the customer. Please check your data and API connection.';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }


      Widget buildSectionTitle({
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 26,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }


      
  @override
  Widget build(BuildContext contet){
    return Scaffold(
      appBar:AppBar(
        title:const Text("customer analysis "),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 16),
                    buildSectionTitle(
                        icon: Icons.person_outline,
                        title: 'Customer Information',
                        subtitle: 'Basic details about the customer',
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              gender = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Senior Citizen'),
                        subtitle: Text(
                          seniorCitizen ? 'Yes' : 'No',
                        ),
                        value: seniorCitizen,
                        onChanged: (value) {
                          setState(() {
                            seniorCitizen = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      buildDropdown(
                        label: 'Partner',
                        value: partner,
                        items: const [
                          'Yes',
                          'No',
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              partner = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      buildDropdown(
                        label: 'Dependents',
                        value: dependents,
                        items: const [
                          'Yes',
                          'No',
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              dependents = value;
                            });
                          }
                        },
                      ),
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSectionTitle(
                                icon: Icons.receipt_long_outlined,
                                title: 'Contract & Billing',
                                subtitle: 'Subscription and billing information',
                              ),

                              const SizedBox(height: 16),

                              TextField(
                                controller: tenureController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Tenure (months)',
                                  hintText: 'Example: 24',
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Contract',
                                value: contract,
                                items: const [
                                  'Month-to-month',
                                  'One year',
                                  'Two year',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      contract = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              TextField(
                                controller: monthlyChargesController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Monthly Charges',
                                  hintText: 'Example: 80.0',
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextField(
                                controller: totalChargesController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Total Charges',
                                  hintText: 'Example: 400.0',
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Paperless Billing',
                                value: paperlessBilling,
                                items: const [
                                  'Yes',
                                  'No',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      paperlessBilling = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),
                              
                              buildDropdown(

                                label: 'Payment Method',
                                value: paymentMethod,
                                items: const [
                                  'Electronic check',
                                  'Mailed check',
                                  'Bank transfer (automatic)',
                                  'Credit card (automatic)',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      paymentMethod = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSectionTitle(
                                icon: Icons.wifi_outlined,
                                title: 'Services',
                                subtitle: 'Services and features used by the customer',
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Phone Service',
                                value: phoneService,
                                items: const [
                                  'Yes',
                                  'No',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      phoneService = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Multiple Lines',
                                value: multipleLines,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No phone service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      multipleLines = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Internet Service',
                                value: internetService,
                                items: const [
                                  'DSL',
                                  'Fiber optic',
                                  'No',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      internetService = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Online Security',
                                value: onlineSecurity,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      onlineSecurity = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Online Backup',
                                value: onlineBackup,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      onlineBackup = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Device Protection',
                                value: deviceProtection,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      deviceProtection = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Tech Support',
                                value: techSupport,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      techSupport = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Streaming TV',
                                value: streamingTV,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      streamingTV = value;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 16),

                              buildDropdown(
                                label: 'Streaming Movies',
                                value: streamingMovies,
                                items: const [
                                  'Yes',
                                  'No',
                                  'No internet service',
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      streamingMovies = value;
                                    });
                                  }
                                },
                              ),
                              ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : predict,
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Predict Churn'),
                            ),
                          ),
                              ],
                             ),
                           ),
                          ),
                          ]  
                          ), 
                          ),
                         );
                        }
                       }


class ResultPage extends StatelessWidget {
  final double churnProbability;
  final double retentionProbability;
  final String riskLevel;
  final String status;
  final String summary;
  final String recommendedAction;
  final VoidCallback onAnalyzeAnother;

  const ResultPage({
    super.key,
    required this.churnProbability,
    required this.retentionProbability,
    required this.riskLevel,
    required this.status,
    required this.summary,
    required this.recommendedAction,
    required this.onAnalyzeAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Churn Analysis Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Churn Analysis',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Churn Probability',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      '${churnProbability.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (churnProbability / 100).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          riskLevel.toLowerCase() == 'high'
                              ? Colors.red
                              : riskLevel.toLowerCase() == 'medium'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Estimated likelihood that this customer will leave.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.trending_down,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Churn'),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${churnProbability.toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Retention'),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${retentionProbability.toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: riskLevel.toLowerCase() == 'high'
                            ? Colors.red.shade100
                            : riskLevel.toLowerCase() == 'medium'
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Risk Level: ${riskLevel.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: riskLevel.toLowerCase() == 'high'
                              ? Colors.red.shade900
                              : riskLevel.toLowerCase() == 'medium'
                                  ? Colors.orange.shade900
                                  : Colors.green.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status == 'likely_to_churn'
                          ? 'Likely to Churn'
                          : 'More Likely to Stay',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(summary),

            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade800,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Recommended Action',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recommendedAction,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(recommendedAction),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Edit Customer Information'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),
            
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                onAnalyzeAnother();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Analyze Another Customer'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
            ),
          ),

          ],
        ),
      ),
    );
  }
}
