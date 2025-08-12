import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditTournamentPage extends StatefulWidget {
  final Map<String, dynamic> tournament;

  const EditTournamentPage({
    Key? key,
    required this.tournament,
  }) : super(key: key);

  @override
  State<EditTournamentPage> createState() => _EditTournamentPageState();
}

class _EditTournamentPageState extends State<EditTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _sportController;
  late TextEditingController _teamSizeController;
  late TextEditingController _feeController;
  late TextEditingController _venueController;
  late TextEditingController _maxTeamsController;
  late TextEditingController _durationController;
  late TextEditingController _firstPrizeController;
  late TextEditingController _secondPrizeController;
  late TextEditingController _thirdPrizeController;
  late TextEditingController _organizerController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current tournament data
    _nameController = TextEditingController(text: widget.tournament['name'] ?? '');
    _sportController = TextEditingController(text: widget.tournament['sport'] ?? '');
    _teamSizeController = TextEditingController(text: widget.tournament['teamSize'] ?? '');
    _feeController = TextEditingController(text: (widget.tournament['fee'] ?? '').toString().replaceAll('৳', '').trim());
    _venueController = TextEditingController(text: widget.tournament['venue'] ?? '');
    _maxTeamsController = TextEditingController(text: widget.tournament['maxTeams'] ?? '');
    _durationController = TextEditingController(text: widget.tournament['duration'] ?? '');
    _firstPrizeController = TextEditingController(text: (widget.tournament['firstPrize'] ?? '').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _secondPrizeController = TextEditingController(text: (widget.tournament['secondPrize'] ?? '').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _thirdPrizeController = TextEditingController(text: (widget.tournament['thirdPrize'] ?? '').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _organizerController = TextEditingController(text: widget.tournament['organizer'] ?? '');
    _phoneController = TextEditingController(text: widget.tournament['phone'] ?? '');
    _emailController = TextEditingController(text: widget.tournament['email'] ?? '');

    // Initialize date and time
    final tournamentDate = widget.tournament['date'] as DateTime;
    _selectedDate = tournamentDate;
    _selectedTime = TimeOfDay.fromDateTime(tournamentDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _teamSizeController.dispose();
    _feeController.dispose();
    _venueController.dispose();
    _maxTeamsController.dispose();
    _durationController.dispose();
    _firstPrizeController.dispose();
    _secondPrizeController.dispose();
    _thirdPrizeController.dispose();
    _organizerController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you would normally update the tournament in your backend/database
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update tournament: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tournament'),
        backgroundColor: Colors.green[700],
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updateTournament,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating tournament...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tournament Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tournament Name',
                        prefixIcon: Icon(Icons.emoji_events),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter tournament name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sport Type
                    TextFormField(
                      controller: _sportController,
                      decoration: const InputDecoration(
                        labelText: 'Sport Type',
                        prefixIcon: Icon(Icons.sports_soccer),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter sport type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Venue
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'Venue',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter venue';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Date & Time Section
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Date
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tournament Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Time
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Duration
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        prefixIcon: Icon(Icons.timer),
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 1 Day, 2 Days',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter duration';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Team Information Section
                    const Text(
                      'Team Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Team Size
                        Expanded(
                          child: TextFormField(
                            controller: _teamSizeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Team Size',
                              prefixIcon: Icon(Icons.people),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Max Teams
                        Expanded(
                          child: TextFormField(
                            controller: _maxTeamsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Teams',
                              prefixIcon: Icon(Icons.groups),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Registration Fee
                    TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Registration Fee (৳)',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter registration fee';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Prize Information Section
                    const Text(
                      'Prize Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Prize
                    TextFormField(
                      controller: _firstPrizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'First Prize (৳)',
                        prefixIcon: Icon(Icons.emoji_events, color: Colors.amber),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter first prize';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Second Prize
                        Expanded(
                          child: TextFormField(
                            controller: _secondPrizeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Second Prize (৳)',
                              prefixIcon: Icon(Icons.emoji_events, color: Colors.grey),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Third Prize
                        Expanded(
                          child: TextFormField(
                            controller: _thirdPrizeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Third Prize (৳)',
                              prefixIcon: Icon(Icons.emoji_events, color: Colors.brown),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contact Information Section
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Organizer
                    TextFormField(
                      controller: _organizerController,
                      decoration: const InputDecoration(
                        labelText: 'Organizer',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter organizer name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Phone
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Email
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _updateTournament,
                            icon: const Icon(Icons.save),
                            label: const Text('Update Tournament'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
