import '../services/supabase_config.dart';

class AdminVenueService {
  static final _supabase = SupabaseConfig.client;

  // Get all venues for admin (including inactive ones)
  static Future<Map<String, dynamic>> getVenues({
    int page = 1,
    int limit = 4,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      // Calculate offset for pagination
      final offset = (page - 1) * limit;

      // Build base query
      var query = _supabase.from('venues').select('''
            *,
            owner:user_profiles!venues_owner_id_fkey(
              id,
              full_name,
              email,
              phone,
              company_name
            )
          ''');

      // Apply status filter
      if (statusFilter != null && statusFilter != 'All') {
        query = query.eq('status', statusFilter.toLowerCase());
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,area.ilike.%$searchQuery%',
        );
      }

      // Get total count first (without pagination)
      var countQuery = _supabase.from('venues').select('id');

      if (statusFilter != null && statusFilter != 'All') {
        countQuery = countQuery.eq('status', statusFilter.toLowerCase());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or(
          'name.ilike.%$searchQuery%,description.ilike.%$searchQuery%,address.ilike.%$searchQuery%,city.ilike.%$searchQuery%,area.ilike.%$searchQuery%',
        );
      }

      final countResult = await countQuery;
      final totalCount = countResult.length;

      // Get paginated venues
      final venuesResult = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final venues = List<Map<String, dynamic>>.from(venuesResult);
      final totalPages = (totalCount / limit).ceil();

      return {
        'venues': venues,
        'totalCount': totalCount,
        'totalPages': totalPages,
        'currentPage': page,
      };
    } catch (e) {
      print('❌ Error fetching admin venues: $e');
      throw Exception('Failed to fetch venues: $e');
    }
  }

  // Get venue statistics
  static Future<Map<String, int>> getVenueStats() async {
    try {
      // Get all venues
      final allVenues = await _supabase.from('venues').select('id, status');

      final totalVenues = allVenues.length;
      final activeVenues =
          allVenues.where((v) => v['status'] == 'active').length;
      final maintenanceVenues =
          allVenues.where((v) => v['status'] == 'maintenance').length;
      final inactiveVenues =
          allVenues.where((v) => v['status'] == 'inactive').length;

      return {
        'totalVenues': totalVenues,
        'activeVenues': activeVenues,
        'maintenanceVenues': maintenanceVenues,
        'inactiveVenues': inactiveVenues,
      };
    } catch (e) {
      print('❌ Error fetching venue stats: $e');
      throw Exception('Failed to fetch venue statistics: $e');
    }
  }

  // Update venue status
  static Future<bool> updateVenueStatus(
    String venueId,
    String newStatus, {
    String? maintenanceReason,
    DateTime? maintenanceStart,
    DateTime? maintenanceEnd,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': newStatus.toLowerCase(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add maintenance specific fields if status is maintenance
      if (newStatus.toLowerCase() == 'maintenance') {
        if (maintenanceReason != null) {
          updateData['maintenance_reason'] = maintenanceReason;
        }
        if (maintenanceStart != null) {
          updateData['maintenance_start'] =
              maintenanceStart.toIso8601String().split('T')[0];
        }
        if (maintenanceEnd != null) {
          updateData['maintenance_end'] =
              maintenanceEnd.toIso8601String().split('T')[0];
        }
      } else {
        // Clear maintenance fields for non-maintenance status
        updateData['maintenance_reason'] = null;
        updateData['maintenance_start'] = null;
        updateData['maintenance_end'] = null;
      }

      await _supabase.from('venues').update(updateData).eq('id', venueId);

      print('✅ Venue status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating venue status: $e');
      throw Exception('Failed to update venue status: $e');
    }
  }

  // Delete venue (with all related data)
  static Future<bool> deleteVenue(String venueId) async {
    try {
      print('🚀 Deleting venue...');
      print('🆔 Venue ID: $venueId');

      // First, delete related bookings
      await _supabase.from('bookings').delete().eq('venue_id', venueId);

      // Then delete the venue
      await _supabase.from('venues').delete().eq('id', venueId);

      print('✅ Venue deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting venue: $e');
      throw Exception('Failed to delete venue: $e');
    }
  }

  // Get venue details by ID for admin
  static Future<Map<String, dynamic>?> getVenueDetails(String venueId) async {
    try {
      print('🚀 Fetching venue details for admin...');
      print('🆔 Venue ID: $venueId');

      final response =
          await _supabase
              .from('venues')
              .select('''
            *,
            owner:user_profiles!venues_owner_id_fkey(
              id,
              full_name,
              email,
              phone,
              company_name,
              city,
              address
            )
          ''')
              .eq('id', venueId)
              .single();

      print('✅ Venue details fetched successfully');
      return response;
    } catch (e) {
      print('❌ Error fetching venue details: $e');
      return null;
    }
  }
}
