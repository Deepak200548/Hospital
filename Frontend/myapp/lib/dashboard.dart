import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ClinicHomeScreen extends StatefulWidget {
  const ClinicHomeScreen({super.key});

  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedBottomNavIndex = 0;
  String _selectedFilter = 'All';
  String _selectedLocation = 'Current Location';
  String _selectedTiming = 'Any Time';
  bool _isAvailableOnly = false;
  double _proximityRange = 5.0;

  final List<Map<String, dynamic>> _clinics = [
    {
      'name': 'MedCare General Clinic',
      'type': 'General Medicine',
      'rating': 4.8,
      'distance': 1.2,
      'address': '123 Health Street, Medical District',
      'isOpen': true,
      'nextAvailable': '2:30 PM',
      'image': 'assets/clinic1.jpg',
      'specialties': ['General', 'Cardiology'],
      'phone': '+1 234-567-8901',
    },
    {
      'name': 'Dental Care Plus',
      'type': 'Dental',
      'rating': 4.6,
      'distance': 2.1,
      'address': '456 Smile Avenue, Downtown',
      'isOpen': false,
      'nextAvailable': 'Tomorrow 9:00 AM',
      'image': 'assets/clinic2.jpg',
      'specialties': ['Dental', 'Orthodontics'],
      'phone': '+1 234-567-8902',
    },
    {
      'name': 'Eye Vision Center',
      'type': 'Ophthalmology',
      'rating': 4.9,
      'distance': 0.8,
      'address': '789 Vision Boulevard, Central',
      'isOpen': true,
      'nextAvailable': '4:15 PM',
      'image': 'assets/clinic3.jpg',
      'specialties': ['Ophthalmology', 'Optometry'],
      'phone': '+1 234-567-8903',
    },
    {
      'name': 'Pediatric Health Hub',
      'type': 'Pediatrics',
      'rating': 4.7,
      'distance': 3.5,
      'address': '321 Kids Lane, Family District',
      'isOpen': true,
      'nextAvailable': '1:45 PM',
      'image': 'assets/clinic4.jpg',
      'specialties': ['Pediatrics', 'Immunization'],
      'phone': '+1 234-567-8904',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredClinics {
    List<Map<String, dynamic>> filtered = _clinics;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((clinic) => clinic['type'] == _selectedFilter).toList();
    }

    if (_isAvailableOnly) {
      filtered = filtered.where((clinic) => clinic['isOpen'] == true).toList();
    }

    filtered = filtered.where((clinic) => clinic['distance'] <= _proximityRange).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildCurrentPage(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedBottomNavIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildAppointmentsPage();
      case 2:
        return _buildNotificationsPage();
      case 3:
        return _buildMessagesPage();
      case 4:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildSearchAndFilters(),
        _buildQuickStats(),
        _buildClinicsList(),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Hello, John! 👋",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      "Find clinics near you",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF2D3748),
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7643),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search clinics, doctors...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF718096)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.tune, color: Color(0xFFFF7643)),
                    onPressed: _showFiltersBottomSheet,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            // Quick Filters
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickFilter('All', _selectedFilter == 'All'),
                  _buildQuickFilter('General Medicine', _selectedFilter == 'General Medicine'),
                  _buildQuickFilter('Dental', _selectedFilter == 'Dental'),
                  _buildQuickFilter('Pediatrics', _selectedFilter == 'Pediatrics'),
                  _buildQuickFilter('Ophthalmology', _selectedFilter == 'Ophthalmology'),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilter(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFFFF7643).withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? Color(0xFFFF7643) : Color(0xFF718096),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? Color(0xFFFF7643) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF7643).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem("Available Now", "${filteredClinics.where((c) => c['isOpen']).length}", Icons.access_time),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem("Within ${_proximityRange}km", "${filteredClinics.length}", Icons.location_on),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildClinicsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= filteredClinics.length) return null;
          final clinic = filteredClinics[index];
          return _buildClinicCard(clinic);
        },
        childCount: filteredClinics.length,
      ),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showClinicDetails(clinic),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getClinicIcon(clinic['type']),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                clinic['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: clinic['isOpen'] ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                clinic['isOpen'] ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          clinic['type'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    clinic['rating'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.location_on, color: Color(0xFF718096), size: 16),
                  SizedBox(width: 4),
                  Text(
                    "${clinic['distance']} km away",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Next: ${clinic['nextAvailable']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFF7643),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                clinic['address'],
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Appointments",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildAppointmentCard("Dr. Smith", "MedCare General", "Today, 2:30 PM", "Confirmed", true),
                _buildAppointmentCard("Dr. Johnson", "Dental Care Plus", "Tomorrow, 9:00 AM", "Pending", false),
                _buildAppointmentCard("Dr. Brown", "Eye Vision Center", "Dec 15, 4:15 PM", "Completed", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildNotificationCard("Appointment Reminder", "Your appointment with Dr. Smith is in 2 hours", "2 hours ago", true),
                _buildNotificationCard("Booking Confirmed", "Your appointment has been confirmed for tomorrow", "1 day ago", false),
                _buildNotificationCard("Health Tip", "Remember to take your medications on time", "2 days ago", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Messages",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7643),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMessageCard("AI Health Assistant", "How can I help you today?", "Active now", true, true),
                _buildMessageCard("MedCare General", "Your test results are ready", "5 min ago", true, false),
                _buildMessageCard("Dental Care Plus", "Appointment confirmed for tomorrow", "1 hour ago", false, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFFF7643),
                  child: Text(
                    "JD",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  "john.doe@email.com",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption("Medical Records", Icons.folder_outlined),
                _buildProfileOption("Insurance Info", Icons.security_outlined),
                _buildProfileOption("Emergency Contacts", Icons.contact_phone_outlined),
                _buildProfileOption("Settings", Icons.settings_outlined),
                _buildProfileOption("Help & Support", Icons.help_outline),
                _buildProfileOption("Privacy Policy", Icons.privacy_tip_outlined),
                _buildProfileOption("Sign Out", Icons.logout, isDestructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(String doctor, String clinic, String time, String status, bool isUpcoming) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  doctor,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isUpcoming ? Color(0xFFFF7643).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isUpcoming ? Color(0xFFFF7643) : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            clinic,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String message, String time, bool isUnread) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread ? Color(0xFFFF7643).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnread ? Border.all(color: Color(0xFFFF7643).withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7643),
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String sender, String message, String time, bool isUnread, bool isBot) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread ? Color(0xFFFF7643).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnread ? Border.all(color: Color(0xFFFF7643).withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: isBot ? LinearGradient(
                colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
              ) : null,
              color: isBot ? null : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBot ? Icons.smart_toy : Icons.local_hospital,
              color: isBot ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sender,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF7643),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : Color(0xFFFF7643).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Color(0xFFFF7643),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Color(0xFF2D3748),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF718096),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
     child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildBottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '',
                index: 0,
              ),
            ),
            Expanded(
              child: _buildBottomNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: '',
                index: 1,
              ),
            ),
            Expanded(
              child: _buildBottomNavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: '',
                index: 2,
              ),
            ),
            Expanded(
              child: _buildBottomNavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: '',
                index: 3,
              ),
            ),
            Expanded(
              child: _buildBottomNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '',
                index: 4,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedBottomNavIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFF7643).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Color(0xFFFF7643) : Color(0xFF718096),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Color(0xFFFF7643) : Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getClinicIcon(String type) {
    switch (type.toLowerCase()) {
      case 'general medicine':
        return Icons.local_hospital;
      case 'dental':
        return Icons.medical_services;
      case 'pediatrics':
        return Icons.child_care;
      case 'ophthalmology':
        return Icons.visibility;
      default:
        return Icons.local_hospital;
    }
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Filter Clinics",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 24),
                
                // Specialty Filter
                Text(
                  "Specialty",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', 'General Medicine', 'Dental', 'Pediatrics', 'Ophthalmology', 'Cardiology']
                      .map((specialty) => FilterChip(
                            label: Text(specialty),
                            selected: _selectedFilter == specialty,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedFilter = selected ? specialty : 'All';
                              });
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: Color(0xFFFF7643).withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: _selectedFilter == specialty ? Color(0xFFFF7643) : Color(0xFF718096),
                              fontWeight: _selectedFilter == specialty ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: _selectedFilter == specialty ? Color(0xFFFF7643) : Colors.grey[300]!,
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 24),
                
                // Proximity Filter
                Text(
                  "Distance: ${_proximityRange.toInt()} km",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Color(0xFFFF7643),
                    inactiveTrackColor: Color(0xFFFF7643).withOpacity(0.2),
                    thumbColor: Color(0xFFFF7643),
                    overlayColor: Color(0xFFFF7643).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _proximityRange,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: "${_proximityRange.toInt()} km",
                    onChanged: (value) {
                      setModalState(() {
                        _proximityRange = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 24),
                
                // Availability Filter
                Row(
                  children: [
                    Text(
                      "Available Now Only",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Spacer(),
                    Switch(
                      value: _isAvailableOnly,
                      onChanged: (value) {
                        setModalState(() {
                          _isAvailableOnly = value;
                        });
                      },
                      activeColor: Color(0xFFFF7643),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Location Filter
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      icon: Icon(Icons.keyboard_arrow_down),
                      items: [
                        'Current Location',
                        'Downtown',
                        'Medical District', 
                        'Central',
                        'Family District'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setModalState(() {
                          _selectedLocation = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                
                Spacer(),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Apply filters
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Color(0xFFFF7643).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Clinic Header
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7643), Color(0xFFFF9A56)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getClinicIcon(clinic['type']),
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          clinic['type'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF718096),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              clinic['rating'].toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Quick Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard("Distance", "${clinic['distance']} km", Icons.location_on),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard("Status", clinic['isOpen'] ? "Open" : "Closed", 
                        clinic['isOpen'] ? Icons.access_time : Icons.schedule),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard("Next Slot", clinic['nextAvailable'], Icons.event_available),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Address
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFFF7643)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        clinic['address'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // Phone
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Color(0xFFFF7643)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        clinic['phone'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Call",
                        style: TextStyle(
                          color: Color(0xFFFF7643),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Specialties
              Text(
                "Specialties",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (clinic['specialties'] as List<String>)
                    .map((specialty) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF7643).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              color: Color(0xFFFF7643),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              
              Spacer(),
              
              // Book Appointment Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Booking appointment at ${clinic['name']}"),
                        backgroundColor: Color(0xFFFF7643),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7643),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Color(0xFFFF7643).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Book Appointment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFFFF7643), size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  }