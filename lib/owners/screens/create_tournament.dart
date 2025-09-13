import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../widgets/owner_profile_widget.dart';
import '../services/tournament_service.dart';
import '../../services/auth_service.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentNameController = TextEditingController();
  final _numTeamsController = TextEditingController();
  final _numPlayersController = TextEditingController();
  final _durationController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _prizeController = TextEditingController();
  final _secondPrizeController = TextEditingController();
  final _thirdPrizeController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  XFile? _selectedImageFile; // Store XFile for better cross-platform support
  bool _isLoading = false;

  // Better image conversion method
  Future<String?> _convertImageToBase64(XFile imageFile) async {
    try {
      print('Converting image to base64...');
      
      // Use XFile.readAsBytes() instead of File for better cross-platform support
      final bytes = await imageFile.readAsBytes();
      
      if (bytes.isEmpty) {
        print('Image file is empty');
        return null;
      }
      
      final base64String = base64Encode(bytes);
      print('Successfully converted image to base64, size: ${bytes.length} bytes');
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show dialog to choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: const Text('Choose how you want to add the venue picture:'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _imageFile = File(image.path);
            _selectedImageFile = image; // Store XFile for conversion
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venue picture added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  @override
  void dispose() {
    _tournamentNameController.dispose();
    _numTeamsController.dispose();
    _numPlayersController.dispose();
    _durationController.dispose();
    _entryFeeController.dispose();
    _prizeController.dispose();
    _secondPrizeController.dispose();
    _thirdPrizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
        backgroundColor: Colors.green[700],
        actions: [
          OwnerProfileWidget(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tournament Image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[700]!, width: 2),
                      image:
                          _imageFile != null
                              ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _imageFile == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Venue Picture',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : null,
                  ),
                ),

                const SizedBox(height: 24),

                // Tournament Name
                TextFormField(
                  controller: _tournamentNameController,
                  decoration: InputDecoration(
                    labelText: 'Tournament Name',
                    hintText: 'Enter tournament name',
                    prefixIcon: const Icon(Icons.emoji_events),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[700]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tournament name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Teams and Players Row
                Row(
                  children: [
                    // Number of Teams
                    Expanded(
                      child: TextFormField(
                        controller: _numTeamsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Number of Teams',
                          hintText: 'Enter number of teams',
                          prefixIcon: const Icon(Icons.groups),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Players per Team
                    Expanded(
                      child: TextFormField(
                        controller: _numPlayersController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Players per Team',
                          hintText: 'Enter players per team',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tournament Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Tournament Description',
                    hintText: 'Enter tournament description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[700]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tournament description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Prize and Entry Fee Row
                Row(
                  children: [
                    // First Prize
                    Expanded(
                      child: TextFormField(
                        controller: _prizeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: '🥇 First Prize (৳)',
                          hintText: 'Enter first prize amount',
                          prefixIcon: const Icon(Icons.emoji_events, color: Colors.amber),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Entry Fee
                    Expanded(
                      child: TextFormField(
                        controller: _entryFeeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: 'Entry Fee (৳)',
                          hintText: 'Enter entry fee',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Second and Third Prize Row
                Row(
                  children: [
                    // Second Prize
                    Expanded(
                      child: TextFormField(
                        controller: _secondPrizeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: '🥈 Second Prize (৳)',
                          hintText: 'Enter second prize (optional)',
                          prefixIcon: const Icon(Icons.emoji_events, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Third Prize
                    Expanded(
                      child: TextFormField(
                        controller: _thirdPrizeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: '🥉 Third Prize (৳)',
                          hintText: 'Enter third prize (optional)',
                          prefixIcon: const Icon(Icons.emoji_events, color: Colors.brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date and Time Row
                Row(
                  children: [
                    // Tournament Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tournament Date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? DateFormat(
                                  'dd MMM yyyy',
                                ).format(_selectedDate!)
                                : 'Select Date',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Tournament Time
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Select Time',
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
                  decoration: InputDecoration(
                    labelText: 'Duration (in hours)',
                    hintText: 'e.g., 2.5 for 2 hours 30 minutes',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[700]!),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tournament duration';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Create Button
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select tournament date',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (_selectedTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select tournament time',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                // Get current user
                                final user = AuthService.currentUser;
                                if (user == null) {
                                  throw Exception('User not authenticated');
                                }

                                print('Creating tournament with user: ${user.id}');
                                print('Tournament name: ${_tournamentNameController.text.trim()}');
                                print('Selected date: $_selectedDate');
                                print('Selected time: $_selectedTime');

                                // Get owner's venues first
                                final ownerVenues = await OwnerTournamentService.getOwnerVenues(user.id);
                                if (ownerVenues.isEmpty) {
                                  throw Exception('No venues exist for this owner. Please add a venue first.');
                                }

                                // Prefer an active venue; otherwise fallback to first maintenance venue
                                Map<String, dynamic> selectedVenue = ownerVenues.first;
                                if (ownerVenues.any((v) => v['status'] == 'active')) {
                                  selectedVenue = ownerVenues.firstWhere((v) => v['status'] == 'active');
                                } else {
                                  // All venues non-active; show info banner later
                                  print('DEBUG [OWNER]: No active venues, using first non-active venue for attempt');
                                }

                                // Generate image URL from picked image
                                String? imageUrl;
                                if (_selectedImageFile != null) {
                                  // Convert image to base64 for storage
                                  imageUrl = await _convertImageToBase64(_selectedImageFile!);
                                  print('Converted image to base64, length: ${imageUrl?.length ?? 0}');
                                } else {
                                  // Use default tournament image
                                  imageUrl = 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=800&q=80';
                                  print('Using default image');
                                }

                                // Create tournament using OwnerTournamentService
                                final result = await OwnerTournamentService.createTournament(
                                  name: _tournamentNameController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  venueId: selectedVenue['id'],
                                  organizerId: user.id,
                                  tournamentDate: _selectedDate!,
                                  startTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
                                  durationHours: int.tryParse(_durationController.text) ?? 2,
                                  teamSize: int.tryParse(_numPlayersController.text) ?? 11,
                                  maxTeams: int.tryParse(_numTeamsController.text) ?? 16,
                                  entryFee: double.tryParse(_entryFeeController.text) ?? 0.0,
                                  firstPrize: double.tryParse(_prizeController.text) ?? 0.0,
                                  secondPrize: _secondPrizeController.text.isNotEmpty 
                                      ? double.tryParse(_secondPrizeController.text) 
                                      : null,
                                  thirdPrize: _thirdPrizeController.text.isNotEmpty 
                                      ? double.tryParse(_thirdPrizeController.text) 
                                      : null,
                                  playerFormat: '${_numPlayersController.text}v${_numPlayersController.text}',
                                  imageUrl: imageUrl,
                                );

                                print('Tournament created successfully: $result');

                                setState(() {
                                  _isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tournament created successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.pop(context, true);
                              } catch (e) {
                                print('Tournament creation error: $e');
                                setState(() {
                                  _isLoading = false;
                                });

                                String errorMessage = 'Failed to create tournament';
                                if (e.toString().contains('No venues exist')) {
                                  errorMessage = 'You have no venues yet. Create a venue before creating a tournament.';
                                } else if (e.toString().contains('maintenance')) {
                                  errorMessage = e.toString();
                                } else if (e.toString().contains('venue_id')) {
                                  errorMessage = 'Venue selection error';
                                } else if (e.toString().contains('organizer_id')) {
                                  errorMessage = 'User authentication error';
                                } else if (e.toString().contains('constraint')) {
                                  errorMessage = 'Invalid venue or organizer data';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Create Tournament',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
