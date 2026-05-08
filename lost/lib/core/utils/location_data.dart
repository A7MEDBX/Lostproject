/// Comprehensive location dataset: Country → State/Province → Cities
class LocationDataService {
  static final Map<String, Map<String, List<String>>> _database = {
    // ── Middle East & North Africa ──────────────────────────────────────────
    'Egypt': {
      'Cairo': ['Cairo', 'Nasr City', 'Maadi', 'Heliopolis', 'New Cairo', 'Zamalek', 'Shubra', 'Ain Shams'],
      'Alexandria': ['Alexandria', 'Smouha', 'Borg El Arab', 'Miami', 'Sidi Bishr'],
      'Giza': ['Giza', '6th of October', 'Dokki', 'Sheikh Zayed', 'Imbaba', 'Mohandessin'],
      'Red Sea': ['Hurghada', 'Safaga', 'Marsa Alam', 'El Gouna'],
      'Dakahlia': ['Mansoura', 'Mit Ghamr', 'Talkha'],
      'Aswan': ['Aswan', 'Edfu', 'Kom Ombo'],
      'Luxor': ['Luxor', 'Esna'],
    },
    'Saudi Arabia': {
      'Riyadh': ['Riyadh', 'Al Kharj', 'Diriyah', 'Al Malaz', 'Al Naseem'],
      'Makkah': ['Makkah', 'Jeddah', 'Taif', 'Al Qunfudhah'],
      'Eastern Province': ['Dammam', 'Khobar', 'Dhahran', 'Jubail', 'Qatif', 'Ahsa'],
      'Madinah': ['Madinah', 'Yanbu'],
      'Aseer': ['Abha', 'Khamis Mushait', 'Bisha'],
    },
    'UAE': {
      'Dubai': ['Dubai', 'Jebel Ali', 'Hatta', 'Deira', 'Bur Dubai'],
      'Abu Dhabi': ['Abu Dhabi', 'Al Ain', 'Ruwais', 'Khalifa City'],
      'Sharjah': ['Sharjah', 'Khor Fakkan', 'Kalba'],
      'Ajman': ['Ajman'],
      'Ras Al Khaimah': ['Ras Al Khaimah'],
    },
    'Kuwait': {
      'Kuwait Governorate': ['Kuwait City', 'Hawalli', 'Salmiya', 'Rumaithiya'],
      'Ahmadi': ['Ahmadi', 'Fahaheel', 'Mangaf'],
      'Jahra': ['Jahra', 'Sulaibikhat'],
    },
    'Qatar': {
      'Doha': ['Doha', 'Lusail', 'Al Wakra', 'Al Rayyan', 'Mesaieed'],
    },
    'Bahrain': {
      'Capital': ['Manama', 'Isa Town'],
      'Northern': ['Muharraq', 'Budaiya'],
      'Southern': ['Riffa', 'Hamad Town'],
    },
    'Oman': {
      'Muscat': ['Muscat', 'Seeb', 'Mutrah', 'Bowsher'],
      'Dhofar': ['Salalah'],
      'Al Batinah': ['Sohar', 'Barka'],
    },
    'Jordan': {
      'Amman': ['Amman', 'Zarqa', 'Russeifa', 'Sahab'],
      'Irbid': ['Irbid', 'Ramtha'],
      'Aqaba': ['Aqaba'],
      'Zarqa': ['Zarqa'],
    },
    'Lebanon': {
      'Beirut': ['Beirut', 'Hamra', 'Achrafieh', 'Verdun'],
      'Mount Lebanon': ['Jounieh', 'Jbeil', 'Byblos', 'Baabda'],
      'North': ['Tripoli', 'Batroun'],
      'South': ['Sidon', 'Tyre'],
    },
    'Iraq': {
      'Baghdad': ['Baghdad', 'Sadr City', 'Kadhimiyah', 'Mansour'],
      'Basra': ['Basra', 'Zubair'],
      'Erbil': ['Erbil', 'Soran'],
      'Sulaymaniyah': ['Sulaymaniyah', 'Halabja'],
    },
    'Yemen': {
      "Sana'a": ["Sana'a", 'Marib'],
      'Aden': ['Aden'],
      'Taiz': ['Taiz'],
    },
    'Libya': {
      'Tripoli': ['Tripoli', 'Tajoura'],
      'Benghazi': ['Benghazi'],
      'Misrata': ['Misrata'],
    },
    'Tunisia': {
      'Tunis': ['Tunis', 'La Marsa', 'Ariana', 'Ben Arous'],
      'Sfax': ['Sfax'],
      'Sousse': ['Sousse', 'Monastir'],
    },
    'Algeria': {
      'Algiers': ['Algiers', 'Bab Ezzouar', 'Hydra', 'Cheraga'],
      'Oran': ['Oran', 'Es Senia'],
      'Constantine': ['Constantine', 'El Khroub'],
      'Annaba': ['Annaba'],
    },
    'Morocco': {
      'Casablanca-Settat': ['Casablanca', 'Settat', 'Mohammedia'],
      "Rabat-Salé": ['Rabat', 'Salé', 'Kenitra'],
      'Fès-Meknès': ['Fès', 'Meknès'],
      'Marrakech-Safi': ['Marrakech', 'Safi'],
      'Tangier-Tétouan': ['Tangier', 'Tétouan', 'Ceuta'],
    },
    'Sudan': {
      'Khartoum': ['Khartoum', 'Omdurman', 'Khartoum North'],
      'Kassala': ['Kassala'],
      'Port Sudan': ['Port Sudan'],
    },

    // ── North America ────────────────────────────────────────────────────────
    'USA': {
      'California': ['Los Angeles', 'San Diego', 'San Francisco', 'San Jose', 'Sacramento', 'Fresno', 'Oakland'],
      'New York': ['New York City', 'Buffalo', 'Rochester', 'Albany', 'Syracuse', 'Yonkers'],
      'Texas': ['Houston', 'San Antonio', 'Dallas', 'Austin', 'Fort Worth', 'El Paso', 'Arlington'],
      'Florida': ['Miami', 'Orlando', 'Tampa', 'Jacksonville', 'Tallahassee', 'St. Petersburg'],
      'Illinois': ['Chicago', 'Aurora', 'Naperville', 'Joliet', 'Springfield', 'Rockford'],
      'Pennsylvania': ['Philadelphia', 'Pittsburgh', 'Allentown', 'Erie'],
      'Ohio': ['Columbus', 'Cleveland', 'Cincinnati', 'Toledo'],
      'Georgia': ['Atlanta', 'Augusta', 'Columbus', 'Savannah'],
      'North Carolina': ['Charlotte', 'Raleigh', 'Greensboro', 'Durham'],
      'Michigan': ['Detroit', 'Grand Rapids', 'Flint', 'Ann Arbor'],
      'Washington': ['Seattle', 'Spokane', 'Tacoma', 'Bellevue'],
      'Arizona': ['Phoenix', 'Tucson', 'Scottsdale', 'Mesa'],
      'Massachusetts': ['Boston', 'Worcester', 'Springfield', 'Cambridge'],
    },
    'Canada': {
      'Ontario': ['Toronto', 'Ottawa', 'Mississauga', 'Hamilton', 'London', 'Brampton'],
      'Quebec': ['Montreal', 'Quebec City', 'Laval', 'Gatineau'],
      'British Columbia': ['Vancouver', 'Surrey', 'Burnaby', 'Victoria'],
      'Alberta': ['Calgary', 'Edmonton', 'Red Deer', 'Lethbridge'],
      'Manitoba': ['Winnipeg', 'Brandon'],
      'Saskatchewan': ['Saskatoon', 'Regina'],
      'Nova Scotia': ['Halifax', 'Sydney'],
    },

    // ── Europe ───────────────────────────────────────────────────────────────
    'UK': {
      'England': ['London', 'Birmingham', 'Manchester', 'Liverpool', 'Leeds', 'Sheffield', 'Bristol', 'Leicester'],
      'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen', 'Dundee', 'Inverness'],
      'Wales': ['Cardiff', 'Swansea', 'Newport', 'Wrexham'],
      'Northern Ireland': ['Belfast', 'Derry', 'Lisburn'],
    },
    'France': {
      'Île-de-France': ['Paris', 'Versailles', 'Boulogne-Billancourt', 'Saint-Denis'],
      'Auvergne-Rhône-Alpes': ['Lyon', 'Grenoble', 'Saint-Étienne'],
      'Provence-Alpes-Côte d\'Azur': ['Marseille', 'Nice', 'Toulon', 'Aix-en-Provence'],
      'Occitanie': ['Toulouse', 'Montpellier'],
      'Nouvelle-Aquitaine': ['Bordeaux', 'Limoges'],
    },
    'Germany': {
      'Bavaria': ['Munich', 'Nuremberg', 'Augsburg', 'Regensburg'],
      'North Rhine-Westphalia': ['Cologne', 'Düsseldorf', 'Dortmund', 'Essen', 'Duisburg'],
      'Berlin': ['Berlin'],
      'Hamburg': ['Hamburg'],
      'Baden-Württemberg': ['Stuttgart', 'Karlsruhe', 'Mannheim', 'Freiburg'],
      'Hesse': ['Frankfurt', 'Wiesbaden', 'Darmstadt'],
    },
    'Italy': {
      'Lombardy': ['Milan', 'Bergamo', 'Brescia', 'Como'],
      'Lazio': ['Rome', 'Latina'],
      'Campania': ['Naples', 'Salerno'],
      'Sicily': ['Palermo', 'Catania', 'Messina'],
      'Veneto': ['Venice', 'Verona', 'Padua'],
      'Tuscany': ['Florence', 'Pisa', 'Siena'],
    },
    'Spain': {
      'Community of Madrid': ['Madrid', 'Alcalá de Henares', 'Getafe'],
      'Catalonia': ['Barcelona', 'Hospitalet de Llobregat', 'Tarragona'],
      'Andalusia': ['Seville', 'Málaga', 'Córdoba', 'Granada'],
      'Valencia': ['Valencia', 'Alicante'],
      'Basque Country': ['Bilbao', 'San Sebastián'],
    },
    'Netherlands': {
      'North Holland': ['Amsterdam', 'Haarlem', 'Zaandam'],
      'South Holland': ['Rotterdam', 'The Hague', 'Delft'],
      'Utrecht': ['Utrecht'],
      'Gelderland': ['Nijmegen', 'Arnhem'],
    },
    'Belgium': {
      'Brussels': ['Brussels'],
      'Flanders': ['Antwerp', 'Ghent', 'Bruges', 'Leuven'],
      'Wallonia': ['Liège', 'Namur', 'Charleroi'],
    },
    'Turkey': {
      'Istanbul': ['Istanbul', 'Kadıköy', 'Beyoğlu', 'Şişli'],
      'Ankara': ['Ankara', 'Çankaya'],
      'Izmir': ['Izmir', 'Konak', 'Karşıyaka'],
      'Antalya': ['Antalya', 'Alanya', 'Kemer'],
      'Bursa': ['Bursa', 'Osmangazi'],
    },
    'Russia': {
      'Moscow': ['Moscow', 'Zelenograd'],
      'Saint Petersburg': ['Saint Petersburg'],
      'Novosibirsk': ['Novosibirsk'],
      'Yekaterinburg': ['Yekaterinburg'],
      'Tatarstan': ['Kazan'],
    },

    // ── South & Southeast Asia ───────────────────────────────────────────────
    'India': {
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane'],
      'Delhi': ['New Delhi', 'Delhi', 'Noida', 'Gurgaon'],
      'Karnataka': ['Bengaluru', 'Mysuru', 'Hubli'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
      'Telangana': ['Hyderabad', 'Warangal'],
      'West Bengal': ['Kolkata', 'Howrah'],
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara'],
      'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi'],
      'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur'],
    },
    'Pakistan': {
      'Punjab': ['Lahore', 'Faisalabad', 'Rawalpindi', 'Gujranwala', 'Multan'],
      'Sindh': ['Karachi', 'Hyderabad', 'Sukkur'],
      'Khyber Pakhtunkhwa': ['Peshawar', 'Mardan', 'Abbottabad'],
      'Islamabad Capital Territory': ['Islamabad'],
    },

    // ── East Asia & Pacific ──────────────────────────────────────────────────
    'China': {
      'Beijing': ['Beijing'],
      'Shanghai': ['Shanghai'],
      'Guangdong': ['Guangzhou', 'Shenzhen', 'Dongguan'],
      'Zhejiang': ['Hangzhou', 'Ningbo', 'Wenzhou'],
      'Sichuan': ['Chengdu'],
      'Hubei': ['Wuhan'],
    },
    'Japan': {
      'Tokyo': ['Tokyo', 'Shinjuku', 'Shibuya', 'Ginza'],
      'Osaka': ['Osaka', 'Sakai', 'Higashiosaka'],
      'Kanagawa': ['Yokohama', 'Kawasaki', 'Sagamihara'],
      'Aichi': ['Nagoya'],
      'Hokkaido': ['Sapporo'],
    },
    'South Korea': {
      'Seoul': ['Seoul', 'Gangnam', 'Hongdae'],
      'Busan': ['Busan'],
      'Incheon': ['Incheon'],
      'Gyeonggi': ['Suwon', 'Goyang', 'Seongnam'],
    },
    'Australia': {
      'New South Wales': ['Sydney', 'Newcastle', 'Wollongong', 'Parramatta'],
      'Victoria': ['Melbourne', 'Geelong', 'Ballarat'],
      'Queensland': ['Brisbane', 'Gold Coast', 'Cairns', 'Townsville'],
      'Western Australia': ['Perth', 'Mandurah', 'Fremantle'],
      'South Australia': ['Adelaide', 'Mount Gambier'],
      'Australian Capital Territory': ['Canberra'],
    },

    // ── Sub-Saharan Africa ───────────────────────────────────────────────────
    'Nigeria': {
      'Lagos': ['Lagos', 'Ikeja', 'Victoria Island', 'Lekki'],
      'Abuja FCT': ['Abuja', 'Gwagwalada'],
      'Kano': ['Kano', 'Fagge'],
      'Rivers': ['Port Harcourt', 'Bonny'],
    },

    // ── South America ────────────────────────────────────────────────────────
    'Brazil': {
      'São Paulo': ['São Paulo', 'Campinas', 'Guarulhos', 'Santo André'],
      'Rio de Janeiro': ['Rio de Janeiro', 'Niterói', 'Duque de Caxias'],
      'Minas Gerais': ['Belo Horizonte', 'Uberlândia'],
      'Bahia': ['Salvador', 'Feira de Santana'],
      'Rio Grande do Sul': ['Porto Alegre', 'Caxias do Sul'],
    },
  };

  /// Get all countries matching the query
  static List<String> getCountries(String query) {
    final keys = _database.keys.toList()..sort();
    if (query.isEmpty) return keys;
    final q = query.toLowerCase();
    return keys.where((c) => c.toLowerCase().contains(q)).toList();
  }

  /// Get all states/provinces for a country matching the query
  static List<String> getStates(String country, String query) {
    if (!_database.containsKey(country)) return [];
    final states = _database[country]!.keys.toList()..sort();
    if (query.isEmpty) return states;
    final q = query.toLowerCase();
    return states.where((s) => s.toLowerCase().contains(q)).toList();
  }

  /// Get cities filtered by country (and optionally state) matching the query
  static List<String> getCities(String country, String state, String query) {
    if (country.isEmpty || !_database.containsKey(country)) return [];

    List<String> cities = [];
    if (state.isNotEmpty && _database[country]!.containsKey(state)) {
      cities = List.from(_database[country]![state]!);
    } else {
      for (var stateCities in _database[country]!.values) {
        cities.addAll(stateCities);
      }
    }
    cities.sort();

    if (query.isEmpty) return cities;
    final q = query.toLowerCase();
    return cities.where((city) => city.toLowerCase().contains(q)).toList();
  }

  /// Helper to get flag emoji for a country
  static String getCountryFlag(String country) {
    const flags = {
      'Egypt': '🇪🇬',
      'Saudi Arabia': '🇸🇦',
      'UAE': '🇦🇪',
      'Kuwait': '🇰🇼',
      'Qatar': '🇶🇦',
      'Bahrain': '🇧🇭',
      'Oman': '🇴🇲',
      'Jordan': '🇯🇴',
      'Lebanon': '🇱🇧',
      'Iraq': '🇮🇶',
      'Yemen': '🇾🇪',
      'Libya': '🇱🇾',
      'Tunisia': '🇹🇳',
      'Algeria': '🇩🇿',
      'Morocco': '🇲🇦',
      'Sudan': '🇸🇩',
      'USA': '🇺🇸',
      'Canada': '🇨🇦',
      'UK': '🇬🇧',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Italy': '🇮🇹',
      'Spain': '🇪🇸',
      'Netherlands': '🇳🇱',
      'Belgium': '🇧🇪',
      'Turkey': '🇹🇷',
      'Russia': '🇷🇺',
      'India': '🇮🇳',
      'Pakistan': '🇵🇰',
      'China': '🇨🇳',
      'Japan': '🇯🇵',
      'South Korea': '🇰🇷',
      'Australia': '🇦🇺',
      'Nigeria': '🇳🇬',
      'Brazil': '🇧🇷',
    };
    return flags[country] ?? '🌍';
  }
}
