import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/tournament_service.dart';

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
    
    // Initialize controllers with current tournament data from database
    _nameController = TextEditingController(text: widget.tournament['name'] ?? '');
    _sportController = TextEditingController(text: widget.tournament['sport'] ?? 'Football');
    _teamSizeController = TextEditingController(text: widget.tournament['player_format'] ?? widget.tournament['teamSize'] ?? '11v11');
    _feeController = TextEditingController(text: (widget.tournament['entry_fee'] ?? widget.tournament['fee'] ?? '0').toString().replaceAll('৳', '').trim());
    _venueController = TextEditingController(text: widget.tournament['venue'] ?? '');
    _maxTeamsController = TextEditingController(text: (widget.tournament['max_teams'] ?? widget.tournament['maxTeams'] ?? '16').toString());
    _durationController = TextEditingController(text: widget.tournament['duration_hours'] != null 
        ? '${widget.tournament['duration_hours']} hours' 
        : widget.tournament['duration'] ?? '2 hours');
    _firstPrizeController = TextEditingController(text: (widget.tournament['first_prize'] ?? widget.tournament['firstPrize'] ?? '0').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _secondPrizeController = TextEditingController(text: (widget.tournament['second_prize'] ?? widget.tournament['secondPrize'] ?? '0').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _thirdPrizeController = TextEditingController(text: (widget.tournament['third_prize'] ?? widget.tournament['thirdPrize'] ?? '0').toString().replaceAll('৳', '').replaceAll(',', '').trim());
    _organizerController = TextEditingController(text: widget.tournament['organizer'] ?? '');
    _phoneController = TextEditingController(text: widget.tournament['phone'] ?? '');
    _emailController = TextEditingController(text: widget.tournament['email'] ?? '');

    // Initialize date and time - handle both database format and dummy format
    try {
      if (widget.tournament['date'] is DateTime) {
        // Old dummy data format
        final tournamentDate = widget.tournament['date'] as DateTime;
        _selectedDate = tournamentDate;
        _selectedTime = TimeOfDay.fromDateTime(tournamentDate);
      } else if (widget.tournament['tournament_date'] != null) {
        // New database format
        final tournamentDate = DateTime.parse(widget.tournament['tournament_date']);
        _selectedDate = tournamentDate;
        
        if (widget.tournament['start_time'] != null) {
          final timeParts = widget.tournament['start_time'].split(':');
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        } else {
          _selectedTime = TimeOfDay.fromDateTime(tournamentDate);
        }
      } else {
        // Default values
        _selectedDate = DateTime.now().add(const Duration(days: 7));
        _selectedTime = const TimeOfDay(hour: 10, minute: 0);
      }
    } catch (e) {
      // Fallback to default values
      _selectedDate = DateTime.now().add(const Duration(days: 7));
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    }
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
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
      // Get tournament ID
      final tournamentId = widget.tournament['id'];
      if (tournamentId == null) {
        throw Exception('Tournament ID not found');
      }

      // Prepare update data
      final updateData = {
        'name': _nameController.text.trim(),
        'player_format': _teamSizeController.text.trim(),
        'entry_fee': int.tryParse(_feeController.text.trim()) ?? 0,
        'max_teams': int.tryParse(_maxTeamsController.text.trim()) ?? 16,
        'duration_hours': int.tryParse(_durationController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 2,
        'first_prize': int.tryParse(_firstPrizeController.text.trim()) ?? 0,
        'second_prize': int.tryParse(_secondPrizeController.text.trim()) ?? 0,
        'third_prize': int.tryParse(_thirdPrizeController.text.trim()) ?? 0,
        'tournament_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'start_time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      };

      // Add description if it exists
      if (widget.tournament['description'] != null) {
        updateData['description'] = widget.tournament['description'];
      }

      // Update tournament in database
      await OwnerTournamentService.updateTournament(tournamentId, updateData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate successful update
      }
    } catch (e) {
      print('Error updating tournament: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update tournament: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tournament'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tournament Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tournament Name',
                          prefixIcon: Icon(Icons.sports_soccer),
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
                      
                      Row(
                        children: [
                          // Team Size
                          Expanded(
                            child: TextFormField(
                              controller: _teamSizeController,
                              decoration: const InputDecoration(
                                labelText: 'Team Format',
                                prefixIcon: Icon(Icons.group),
                                border: OutlineInputBorder(),
                                hintText: 'e.g., 11v11, 7v7',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter team format';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Entry Fee
                          Expanded(
                            child: TextFormField(
                              controller: _feeController,
                              decoration: const InputDecoration(
                                labelText: 'Entry Fee (৳)',
                                prefixIcon: Icon(Icons.monetization_on),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter entry fee';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Max Teams
                          Expanded(
                            child: TextFormField(
                              controller: _maxTeamsController,
                              decoration: const InputDecoration(
                                labelText: 'Max Teams',
                                prefixIcon: Icon(Icons.groups),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter max teams';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Duration
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                prefixIcon: Icon(Icons.timer),
                                border: OutlineInputBorder(),
                                hintText: 'e.g., 2 hours',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter duration';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date and Time Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
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
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Prize Money Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prize Money',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // First Prize
                      TextFormField(
                        controller: _firstPrizeController,
                        decoration: const InputDecoration(
                          labelText: '1st Prize (৳)',
                          prefixIcon: Icon(Icons.emoji_events, color: Colors.amber),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter first prize amount';
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
                              decoration: const InputDecoration(
                                labelText: '2nd Prize (৳)',
                                prefixIcon: Icon(Icons.emoji_events, color: Colors.grey),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Third Prize
                          Expanded(
                            child: TextFormField(
                              controller: _thirdPrizeController,
                              decoration: const InputDecoration(
                                labelText: '3rd Prize (৳)',
                                prefixIcon: Icon(Icons.emoji_events, color: Colors.brown),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Updating Tournament...'),
                        ],
                      )
                    : const Text(
                        'Update Tournament',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
