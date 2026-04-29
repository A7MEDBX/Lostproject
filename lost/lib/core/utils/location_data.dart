class LocationDataService {
  // Structured Dataset: Country -> State/Province -> List of Cities
  static final Map<String, Map<String, List<String>>> _database = {
    "Egypt": {
      "Cairo": ["Cairo", "Nasr City", "Maadi", "Heliopolis", "New Cairo"],
      "Alexandria": ["Alexandria", "Smouha", "Borg El Arab", "Miami"],
      "Giza": ["Giza", "6th of October", "Dokki", "Sheikh Zayed"],
      "Red Sea": ["Hurghada", "Safaga", "Marsa Alam"],
      "Dakahlia": ["Mansoura", "Mit Ghamr", "Talkha"]
    },
    "USA": {
      "California": ["Los Angeles", "San Diego", "San Francisco", "San Jose", "Sacramento"],
      "New York": ["New York City", "Buffalo", "Rochester", "Albany", "Syracuse"],
      "Texas": ["Houston", "San Antonio", "Dallas", "Austin", "Fort Worth"],
      "Florida": ["Miami", "Orlando", "Tampa", "Jacksonville", "Tallahassee"],
      "Illinois": ["Chicago", "Aurora", "Naperville", "Joliet", "Springfield"]
    },
    "UAE": {
      "Dubai": ["Dubai", "Jebel Ali", "Hatta"],
      "Abu Dhabi": ["Abu Dhabi", "Al Ain", "Ruwais"],
      "Sharjah": ["Sharjah", "Khor Fakkan", "Kalba"]
    },
    "UK": {
      "England": ["London", "Birmingham", "Manchester", "Liverpool", "Leeds"],
      "Scotland": ["Edinburgh", "Glasgow", "Aberdeen", "Dundee"],
      "Wales": ["Cardiff", "Swansea", "Newport"]
    },
    "Saudi Arabia": {
      "Riyadh": ["Riyadh", "Al Kharj", "Diriyah"],
      "Makkah": ["Makkah", "Jeddah", "Taif"],
      "Eastern Province": ["Dammam", "Khobar", "Dhahran", "Jubail"]
    }
  };

  /// Get all countries matching the query
  static List<String> getCountries(String query) {
    if (query.isEmpty) {
      return _database.keys.toList();
    }
    final q = query.toLowerCase();
    return _database.keys.where((country) => country.toLowerCase().contains(q)).toList();
  }

  /// Get all states/provinces for a specific country matching the query
  static List<String> getStates(String country, String query) {
    if (!_database.containsKey(country)) return [];
    
    final states = _database[country]!.keys.toList();
    if (query.isEmpty) return states;
    
    final q = query.toLowerCase();
    return states.where((state) => state.toLowerCase().contains(q)).toList();
  }

  /// Get all cities matching the query, filtered by country and optionally state
  static List<String> getCities(String country, String state, String query) {
    if (country.isEmpty || !_database.containsKey(country)) return [];

    List<String> cities = [];
    
    if (state.isNotEmpty && _database[country]!.containsKey(state)) {
      // If state is provided and valid, only return cities in that state
      cities = _database[country]![state]!;
    } else {
      // Otherwise, flatten all cities in the country
      for (var stateCities in _database[country]!.values) {
        cities.addAll(stateCities);
      }
    }

    if (query.isEmpty) return cities;
    
    final q = query.toLowerCase();
    return cities.where((city) => city.toLowerCase().contains(q)).toList();
  }

  /// Helper to get flag emoji for a country (Bonus Feature)
  static String getCountryFlag(String country) {
    switch (country) {
      case "Egypt": return "🇪🇬";
      case "USA": return "🇺🇸";
      case "UAE": return "🇦🇪";
      case "UK": return "🇬🇧";
      case "Saudi Arabia": return "🇸🇦";
      default: return "🌍";
    }
  }
}
