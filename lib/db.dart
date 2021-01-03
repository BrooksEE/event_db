library db;
import 'package:intl/intl.dart';

// <class 'django.contrib.auth.models.User'>
class MyUser {
  int id;
  DateTime last_login;
  String username;
  String first_name;
  String last_name;
  String email;
  bool is_active;
  DateTime date_joined;

  MyUser.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    last_login = j['last_login'] == null ? null : DateTime.parse(j['last_login']);
    username = j['username'];
    first_name = j['first_name'];
    last_name = j['last_name'];
    email = j['email'];
    is_active = j['is_active'];
    date_joined = j['date_joined'] == null ? null : DateTime.parse(j['date_joined']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'last_login' : last_login.toString(),
      'username' : username,
      'first_name' : first_name,
      'last_name' : last_name,
      'email' : email,
      'is_active' : is_active,
      'date_joined' : date_joined.toString(),
    };
  }


String get name => "$first_name $last_name";
  
  String toString() {
    return "${id}: ${email}";
  }
}

// <class 'entity.models.Entity'>
class Entity {
  int id;
  String name;
  String info_email;

  Entity.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    name = j['name'];
    info_email = j['info_email'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name' : name,
      'info_email' : info_email,
    };
  }

}

// <class 'host.models.Host'>
class Host {
  int id;
  int entity_id;
  Entity entity;
  String key;
  String name;
  String short_name;
  String email_sender;
  String email_info;
  String email_cc;
  String email_support;
  String http;
  String https;
  String redirect_domain;
  String google_analytics;
  String facebook_app_secret;
  String facebook_page;
  String facebook_pageid;
  String default_state;
  String default_country;
  final String TIMEZONE_AFRICA_ABIDJAN = "Africa/Abidjan";
  final String TIMEZONE_AFRICA_ACCRA = "Africa/Accra";
  final String TIMEZONE_AFRICA_ADDIS_ABABA = "Africa/Addis_Ababa";
  final String TIMEZONE_AFRICA_ALGIERS = "Africa/Algiers";
  final String TIMEZONE_AFRICA_ASMARA = "Africa/Asmara";
  final String TIMEZONE_AFRICA_ASMERA = "Africa/Asmera";
  final String TIMEZONE_AFRICA_BAMAKO = "Africa/Bamako";
  final String TIMEZONE_AFRICA_BANGUI = "Africa/Bangui";
  final String TIMEZONE_AFRICA_BANJUL = "Africa/Banjul";
  final String TIMEZONE_AFRICA_BISSAU = "Africa/Bissau";
  final String TIMEZONE_AFRICA_BLANTYRE = "Africa/Blantyre";
  final String TIMEZONE_AFRICA_BRAZZAVILLE = "Africa/Brazzaville";
  final String TIMEZONE_AFRICA_BUJUMBURA = "Africa/Bujumbura";
  final String TIMEZONE_AFRICA_CAIRO = "Africa/Cairo";
  final String TIMEZONE_AFRICA_CASABLANCA = "Africa/Casablanca";
  final String TIMEZONE_AFRICA_CEUTA = "Africa/Ceuta";
  final String TIMEZONE_AFRICA_CONAKRY = "Africa/Conakry";
  final String TIMEZONE_AFRICA_DAKAR = "Africa/Dakar";
  final String TIMEZONE_AFRICA_DAR_ES_SALAAM = "Africa/Dar_es_Salaam";
  final String TIMEZONE_AFRICA_DJIBOUTI = "Africa/Djibouti";
  final String TIMEZONE_AFRICA_DOUALA = "Africa/Douala";
  final String TIMEZONE_AFRICA_EL_AAIUN = "Africa/El_Aaiun";
  final String TIMEZONE_AFRICA_FREETOWN = "Africa/Freetown";
  final String TIMEZONE_AFRICA_GABORONE = "Africa/Gaborone";
  final String TIMEZONE_AFRICA_HARARE = "Africa/Harare";
  final String TIMEZONE_AFRICA_JOHANNESBURG = "Africa/Johannesburg";
  final String TIMEZONE_AFRICA_JUBA = "Africa/Juba";
  final String TIMEZONE_AFRICA_KAMPALA = "Africa/Kampala";
  final String TIMEZONE_AFRICA_KHARTOUM = "Africa/Khartoum";
  final String TIMEZONE_AFRICA_KIGALI = "Africa/Kigali";
  final String TIMEZONE_AFRICA_KINSHASA = "Africa/Kinshasa";
  final String TIMEZONE_AFRICA_LAGOS = "Africa/Lagos";
  final String TIMEZONE_AFRICA_LIBREVILLE = "Africa/Libreville";
  final String TIMEZONE_AFRICA_LOME = "Africa/Lome";
  final String TIMEZONE_AFRICA_LUANDA = "Africa/Luanda";
  final String TIMEZONE_AFRICA_LUBUMBASHI = "Africa/Lubumbashi";
  final String TIMEZONE_AFRICA_LUSAKA = "Africa/Lusaka";
  final String TIMEZONE_AFRICA_MALABO = "Africa/Malabo";
  final String TIMEZONE_AFRICA_MAPUTO = "Africa/Maputo";
  final String TIMEZONE_AFRICA_MASERU = "Africa/Maseru";
  final String TIMEZONE_AFRICA_MBABANE = "Africa/Mbabane";
  final String TIMEZONE_AFRICA_MOGADISHU = "Africa/Mogadishu";
  final String TIMEZONE_AFRICA_MONROVIA = "Africa/Monrovia";
  final String TIMEZONE_AFRICA_NAIROBI = "Africa/Nairobi";
  final String TIMEZONE_AFRICA_NDJAMENA = "Africa/Ndjamena";
  final String TIMEZONE_AFRICA_NIAMEY = "Africa/Niamey";
  final String TIMEZONE_AFRICA_NOUAKCHOTT = "Africa/Nouakchott";
  final String TIMEZONE_AFRICA_OUAGADOUGOU = "Africa/Ouagadougou";
  final String TIMEZONE_AFRICA_PORTO_NOVO = "Africa/Porto-Novo";
  final String TIMEZONE_AFRICA_SAO_TOME = "Africa/Sao_Tome";
  final String TIMEZONE_AFRICA_TIMBUKTU = "Africa/Timbuktu";
  final String TIMEZONE_AFRICA_TRIPOLI = "Africa/Tripoli";
  final String TIMEZONE_AFRICA_TUNIS = "Africa/Tunis";
  final String TIMEZONE_AFRICA_WINDHOEK = "Africa/Windhoek";
  final String TIMEZONE_AMERICA_ADAK = "America/Adak";
  final String TIMEZONE_AMERICA_ANCHORAGE = "America/Anchorage";
  final String TIMEZONE_AMERICA_ANGUILLA = "America/Anguilla";
  final String TIMEZONE_AMERICA_ANTIGUA = "America/Antigua";
  final String TIMEZONE_AMERICA_ARAGUAINA = "America/Araguaina";
  final String TIMEZONE_AMERICA_ARGENTINA_BUENOS_AIRES = "America/Argentina/Buenos_Aires";
  final String TIMEZONE_AMERICA_ARGENTINA_CATAMARCA = "America/Argentina/Catamarca";
  final String TIMEZONE_AMERICA_ARGENTINA_COMODRIVADAVIA = "America/Argentina/ComodRivadavia";
  final String TIMEZONE_AMERICA_ARGENTINA_CORDOBA = "America/Argentina/Cordoba";
  final String TIMEZONE_AMERICA_ARGENTINA_JUJUY = "America/Argentina/Jujuy";
  final String TIMEZONE_AMERICA_ARGENTINA_LA_RIOJA = "America/Argentina/La_Rioja";
  final String TIMEZONE_AMERICA_ARGENTINA_MENDOZA = "America/Argentina/Mendoza";
  final String TIMEZONE_AMERICA_ARGENTINA_RIO_GALLEGOS = "America/Argentina/Rio_Gallegos";
  final String TIMEZONE_AMERICA_ARGENTINA_SALTA = "America/Argentina/Salta";
  final String TIMEZONE_AMERICA_ARGENTINA_SAN_JUAN = "America/Argentina/San_Juan";
  final String TIMEZONE_AMERICA_ARGENTINA_SAN_LUIS = "America/Argentina/San_Luis";
  final String TIMEZONE_AMERICA_ARGENTINA_TUCUMAN = "America/Argentina/Tucuman";
  final String TIMEZONE_AMERICA_ARGENTINA_USHUAIA = "America/Argentina/Ushuaia";
  final String TIMEZONE_AMERICA_ARUBA = "America/Aruba";
  final String TIMEZONE_AMERICA_ASUNCION = "America/Asuncion";
  final String TIMEZONE_AMERICA_ATIKOKAN = "America/Atikokan";
  final String TIMEZONE_AMERICA_ATKA = "America/Atka";
  final String TIMEZONE_AMERICA_BAHIA = "America/Bahia";
  final String TIMEZONE_AMERICA_BAHIA_BANDERAS = "America/Bahia_Banderas";
  final String TIMEZONE_AMERICA_BARBADOS = "America/Barbados";
  final String TIMEZONE_AMERICA_BELEM = "America/Belem";
  final String TIMEZONE_AMERICA_BELIZE = "America/Belize";
  final String TIMEZONE_AMERICA_BLANC_SABLON = "America/Blanc-Sablon";
  final String TIMEZONE_AMERICA_BOA_VISTA = "America/Boa_Vista";
  final String TIMEZONE_AMERICA_BOGOTA = "America/Bogota";
  final String TIMEZONE_AMERICA_BOISE = "America/Boise";
  final String TIMEZONE_AMERICA_BUENOS_AIRES = "America/Buenos_Aires";
  final String TIMEZONE_AMERICA_CAMBRIDGE_BAY = "America/Cambridge_Bay";
  final String TIMEZONE_AMERICA_CAMPO_GRANDE = "America/Campo_Grande";
  final String TIMEZONE_AMERICA_CANCUN = "America/Cancun";
  final String TIMEZONE_AMERICA_CARACAS = "America/Caracas";
  final String TIMEZONE_AMERICA_CATAMARCA = "America/Catamarca";
  final String TIMEZONE_AMERICA_CAYENNE = "America/Cayenne";
  final String TIMEZONE_AMERICA_CAYMAN = "America/Cayman";
  final String TIMEZONE_AMERICA_CHICAGO = "America/Chicago";
  final String TIMEZONE_AMERICA_CHIHUAHUA = "America/Chihuahua";
  final String TIMEZONE_AMERICA_CORAL_HARBOUR = "America/Coral_Harbour";
  final String TIMEZONE_AMERICA_CORDOBA = "America/Cordoba";
  final String TIMEZONE_AMERICA_COSTA_RICA = "America/Costa_Rica";
  final String TIMEZONE_AMERICA_CRESTON = "America/Creston";
  final String TIMEZONE_AMERICA_CUIABA = "America/Cuiaba";
  final String TIMEZONE_AMERICA_CURACAO = "America/Curacao";
  final String TIMEZONE_AMERICA_DANMARKSHAVN = "America/Danmarkshavn";
  final String TIMEZONE_AMERICA_DAWSON = "America/Dawson";
  final String TIMEZONE_AMERICA_DAWSON_CREEK = "America/Dawson_Creek";
  final String TIMEZONE_AMERICA_DENVER = "America/Denver";
  final String TIMEZONE_AMERICA_DETROIT = "America/Detroit";
  final String TIMEZONE_AMERICA_DOMINICA = "America/Dominica";
  final String TIMEZONE_AMERICA_EDMONTON = "America/Edmonton";
  final String TIMEZONE_AMERICA_EIRUNEPE = "America/Eirunepe";
  final String TIMEZONE_AMERICA_EL_SALVADOR = "America/El_Salvador";
  final String TIMEZONE_AMERICA_ENSENADA = "America/Ensenada";
  final String TIMEZONE_AMERICA_FORT_NELSON = "America/Fort_Nelson";
  final String TIMEZONE_AMERICA_FORT_WAYNE = "America/Fort_Wayne";
  final String TIMEZONE_AMERICA_FORTALEZA = "America/Fortaleza";
  final String TIMEZONE_AMERICA_GLACE_BAY = "America/Glace_Bay";
  final String TIMEZONE_AMERICA_GODTHAB = "America/Godthab";
  final String TIMEZONE_AMERICA_GOOSE_BAY = "America/Goose_Bay";
  final String TIMEZONE_AMERICA_GRAND_TURK = "America/Grand_Turk";
  final String TIMEZONE_AMERICA_GRENADA = "America/Grenada";
  final String TIMEZONE_AMERICA_GUADELOUPE = "America/Guadeloupe";
  final String TIMEZONE_AMERICA_GUATEMALA = "America/Guatemala";
  final String TIMEZONE_AMERICA_GUAYAQUIL = "America/Guayaquil";
  final String TIMEZONE_AMERICA_GUYANA = "America/Guyana";
  final String TIMEZONE_AMERICA_HALIFAX = "America/Halifax";
  final String TIMEZONE_AMERICA_HAVANA = "America/Havana";
  final String TIMEZONE_AMERICA_HERMOSILLO = "America/Hermosillo";
  final String TIMEZONE_AMERICA_INDIANA_INDIANAPOLIS = "America/Indiana/Indianapolis";
  final String TIMEZONE_AMERICA_INDIANA_KNOX = "America/Indiana/Knox";
  final String TIMEZONE_AMERICA_INDIANA_MARENGO = "America/Indiana/Marengo";
  final String TIMEZONE_AMERICA_INDIANA_PETERSBURG = "America/Indiana/Petersburg";
  final String TIMEZONE_AMERICA_INDIANA_TELL_CITY = "America/Indiana/Tell_City";
  final String TIMEZONE_AMERICA_INDIANA_VEVAY = "America/Indiana/Vevay";
  final String TIMEZONE_AMERICA_INDIANA_VINCENNES = "America/Indiana/Vincennes";
  final String TIMEZONE_AMERICA_INDIANA_WINAMAC = "America/Indiana/Winamac";
  final String TIMEZONE_AMERICA_INDIANAPOLIS = "America/Indianapolis";
  final String TIMEZONE_AMERICA_INUVIK = "America/Inuvik";
  final String TIMEZONE_AMERICA_IQALUIT = "America/Iqaluit";
  final String TIMEZONE_AMERICA_JAMAICA = "America/Jamaica";
  final String TIMEZONE_AMERICA_JUJUY = "America/Jujuy";
  final String TIMEZONE_AMERICA_JUNEAU = "America/Juneau";
  final String TIMEZONE_AMERICA_KENTUCKY_LOUISVILLE = "America/Kentucky/Louisville";
  final String TIMEZONE_AMERICA_KENTUCKY_MONTICELLO = "America/Kentucky/Monticello";
  final String TIMEZONE_AMERICA_KNOX_IN = "America/Knox_IN";
  final String TIMEZONE_AMERICA_KRALENDIJK = "America/Kralendijk";
  final String TIMEZONE_AMERICA_LA_PAZ = "America/La_Paz";
  final String TIMEZONE_AMERICA_LIMA = "America/Lima";
  final String TIMEZONE_AMERICA_LOS_ANGELES = "America/Los_Angeles";
  final String TIMEZONE_AMERICA_LOUISVILLE = "America/Louisville";
  final String TIMEZONE_AMERICA_LOWER_PRINCES = "America/Lower_Princes";
  final String TIMEZONE_AMERICA_MACEIO = "America/Maceio";
  final String TIMEZONE_AMERICA_MANAGUA = "America/Managua";
  final String TIMEZONE_AMERICA_MANAUS = "America/Manaus";
  final String TIMEZONE_AMERICA_MARIGOT = "America/Marigot";
  final String TIMEZONE_AMERICA_MARTINIQUE = "America/Martinique";
  final String TIMEZONE_AMERICA_MATAMOROS = "America/Matamoros";
  final String TIMEZONE_AMERICA_MAZATLAN = "America/Mazatlan";
  final String TIMEZONE_AMERICA_MENDOZA = "America/Mendoza";
  final String TIMEZONE_AMERICA_MENOMINEE = "America/Menominee";
  final String TIMEZONE_AMERICA_MERIDA = "America/Merida";
  final String TIMEZONE_AMERICA_METLAKATLA = "America/Metlakatla";
  final String TIMEZONE_AMERICA_MEXICO_CITY = "America/Mexico_City";
  final String TIMEZONE_AMERICA_MIQUELON = "America/Miquelon";
  final String TIMEZONE_AMERICA_MONCTON = "America/Moncton";
  final String TIMEZONE_AMERICA_MONTERREY = "America/Monterrey";
  final String TIMEZONE_AMERICA_MONTEVIDEO = "America/Montevideo";
  final String TIMEZONE_AMERICA_MONTREAL = "America/Montreal";
  final String TIMEZONE_AMERICA_MONTSERRAT = "America/Montserrat";
  final String TIMEZONE_AMERICA_NASSAU = "America/Nassau";
  final String TIMEZONE_AMERICA_NEW_YORK = "America/New_York";
  final String TIMEZONE_AMERICA_NIPIGON = "America/Nipigon";
  final String TIMEZONE_AMERICA_NOME = "America/Nome";
  final String TIMEZONE_AMERICA_NORONHA = "America/Noronha";
  final String TIMEZONE_AMERICA_NORTH_DAKOTA_BEULAH = "America/North_Dakota/Beulah";
  final String TIMEZONE_AMERICA_NORTH_DAKOTA_CENTER = "America/North_Dakota/Center";
  final String TIMEZONE_AMERICA_NORTH_DAKOTA_NEW_SALEM = "America/North_Dakota/New_Salem";
  final String TIMEZONE_AMERICA_OJINAGA = "America/Ojinaga";
  final String TIMEZONE_AMERICA_PANAMA = "America/Panama";
  final String TIMEZONE_AMERICA_PANGNIRTUNG = "America/Pangnirtung";
  final String TIMEZONE_AMERICA_PARAMARIBO = "America/Paramaribo";
  final String TIMEZONE_AMERICA_PHOENIX = "America/Phoenix";
  final String TIMEZONE_AMERICA_PORT_AU_PRINCE = "America/Port-au-Prince";
  final String TIMEZONE_AMERICA_PORT_OF_SPAIN = "America/Port_of_Spain";
  final String TIMEZONE_AMERICA_PORTO_ACRE = "America/Porto_Acre";
  final String TIMEZONE_AMERICA_PORTO_VELHO = "America/Porto_Velho";
  final String TIMEZONE_AMERICA_PUERTO_RICO = "America/Puerto_Rico";
  final String TIMEZONE_AMERICA_PUNTA_ARENAS = "America/Punta_Arenas";
  final String TIMEZONE_AMERICA_RAINY_RIVER = "America/Rainy_River";
  final String TIMEZONE_AMERICA_RANKIN_INLET = "America/Rankin_Inlet";
  final String TIMEZONE_AMERICA_RECIFE = "America/Recife";
  final String TIMEZONE_AMERICA_REGINA = "America/Regina";
  final String TIMEZONE_AMERICA_RESOLUTE = "America/Resolute";
  final String TIMEZONE_AMERICA_RIO_BRANCO = "America/Rio_Branco";
  final String TIMEZONE_AMERICA_ROSARIO = "America/Rosario";
  final String TIMEZONE_AMERICA_SANTA_ISABEL = "America/Santa_Isabel";
  final String TIMEZONE_AMERICA_SANTAREM = "America/Santarem";
  final String TIMEZONE_AMERICA_SANTIAGO = "America/Santiago";
  final String TIMEZONE_AMERICA_SANTO_DOMINGO = "America/Santo_Domingo";
  final String TIMEZONE_AMERICA_SAO_PAULO = "America/Sao_Paulo";
  final String TIMEZONE_AMERICA_SCORESBYSUND = "America/Scoresbysund";
  final String TIMEZONE_AMERICA_SHIPROCK = "America/Shiprock";
  final String TIMEZONE_AMERICA_SITKA = "America/Sitka";
  final String TIMEZONE_AMERICA_ST_BARTHELEMY = "America/St_Barthelemy";
  final String TIMEZONE_AMERICA_ST_JOHNS = "America/St_Johns";
  final String TIMEZONE_AMERICA_ST_KITTS = "America/St_Kitts";
  final String TIMEZONE_AMERICA_ST_LUCIA = "America/St_Lucia";
  final String TIMEZONE_AMERICA_ST_THOMAS = "America/St_Thomas";
  final String TIMEZONE_AMERICA_ST_VINCENT = "America/St_Vincent";
  final String TIMEZONE_AMERICA_SWIFT_CURRENT = "America/Swift_Current";
  final String TIMEZONE_AMERICA_TEGUCIGALPA = "America/Tegucigalpa";
  final String TIMEZONE_AMERICA_THULE = "America/Thule";
  final String TIMEZONE_AMERICA_THUNDER_BAY = "America/Thunder_Bay";
  final String TIMEZONE_AMERICA_TIJUANA = "America/Tijuana";
  final String TIMEZONE_AMERICA_TORONTO = "America/Toronto";
  final String TIMEZONE_AMERICA_TORTOLA = "America/Tortola";
  final String TIMEZONE_AMERICA_VANCOUVER = "America/Vancouver";
  final String TIMEZONE_AMERICA_VIRGIN = "America/Virgin";
  final String TIMEZONE_AMERICA_WHITEHORSE = "America/Whitehorse";
  final String TIMEZONE_AMERICA_WINNIPEG = "America/Winnipeg";
  final String TIMEZONE_AMERICA_YAKUTAT = "America/Yakutat";
  final String TIMEZONE_AMERICA_YELLOWKNIFE = "America/Yellowknife";
  final String TIMEZONE_ANTARCTICA_CASEY = "Antarctica/Casey";
  final String TIMEZONE_ANTARCTICA_DAVIS = "Antarctica/Davis";
  final String TIMEZONE_ANTARCTICA_DUMONTDURVILLE = "Antarctica/DumontDUrville";
  final String TIMEZONE_ANTARCTICA_MACQUARIE = "Antarctica/Macquarie";
  final String TIMEZONE_ANTARCTICA_MAWSON = "Antarctica/Mawson";
  final String TIMEZONE_ANTARCTICA_MCMURDO = "Antarctica/McMurdo";
  final String TIMEZONE_ANTARCTICA_PALMER = "Antarctica/Palmer";
  final String TIMEZONE_ANTARCTICA_ROTHERA = "Antarctica/Rothera";
  final String TIMEZONE_ANTARCTICA_SOUTH_POLE = "Antarctica/South_Pole";
  final String TIMEZONE_ANTARCTICA_SYOWA = "Antarctica/Syowa";
  final String TIMEZONE_ANTARCTICA_TROLL = "Antarctica/Troll";
  final String TIMEZONE_ANTARCTICA_VOSTOK = "Antarctica/Vostok";
  final String TIMEZONE_ARCTIC_LONGYEARBYEN = "Arctic/Longyearbyen";
  final String TIMEZONE_ASIA_ADEN = "Asia/Aden";
  final String TIMEZONE_ASIA_ALMATY = "Asia/Almaty";
  final String TIMEZONE_ASIA_AMMAN = "Asia/Amman";
  final String TIMEZONE_ASIA_ANADYR = "Asia/Anadyr";
  final String TIMEZONE_ASIA_AQTAU = "Asia/Aqtau";
  final String TIMEZONE_ASIA_AQTOBE = "Asia/Aqtobe";
  final String TIMEZONE_ASIA_ASHGABAT = "Asia/Ashgabat";
  final String TIMEZONE_ASIA_ASHKHABAD = "Asia/Ashkhabad";
  final String TIMEZONE_ASIA_ATYRAU = "Asia/Atyrau";
  final String TIMEZONE_ASIA_BAGHDAD = "Asia/Baghdad";
  final String TIMEZONE_ASIA_BAHRAIN = "Asia/Bahrain";
  final String TIMEZONE_ASIA_BAKU = "Asia/Baku";
  final String TIMEZONE_ASIA_BANGKOK = "Asia/Bangkok";
  final String TIMEZONE_ASIA_BARNAUL = "Asia/Barnaul";
  final String TIMEZONE_ASIA_BEIRUT = "Asia/Beirut";
  final String TIMEZONE_ASIA_BISHKEK = "Asia/Bishkek";
  final String TIMEZONE_ASIA_BRUNEI = "Asia/Brunei";
  final String TIMEZONE_ASIA_CALCUTTA = "Asia/Calcutta";
  final String TIMEZONE_ASIA_CHITA = "Asia/Chita";
  final String TIMEZONE_ASIA_CHOIBALSAN = "Asia/Choibalsan";
  final String TIMEZONE_ASIA_CHONGQING = "Asia/Chongqing";
  final String TIMEZONE_ASIA_CHUNGKING = "Asia/Chungking";
  final String TIMEZONE_ASIA_COLOMBO = "Asia/Colombo";
  final String TIMEZONE_ASIA_DACCA = "Asia/Dacca";
  final String TIMEZONE_ASIA_DAMASCUS = "Asia/Damascus";
  final String TIMEZONE_ASIA_DHAKA = "Asia/Dhaka";
  final String TIMEZONE_ASIA_DILI = "Asia/Dili";
  final String TIMEZONE_ASIA_DUBAI = "Asia/Dubai";
  final String TIMEZONE_ASIA_DUSHANBE = "Asia/Dushanbe";
  final String TIMEZONE_ASIA_FAMAGUSTA = "Asia/Famagusta";
  final String TIMEZONE_ASIA_GAZA = "Asia/Gaza";
  final String TIMEZONE_ASIA_HARBIN = "Asia/Harbin";
  final String TIMEZONE_ASIA_HEBRON = "Asia/Hebron";
  final String TIMEZONE_ASIA_HO_CHI_MINH = "Asia/Ho_Chi_Minh";
  final String TIMEZONE_ASIA_HONG_KONG = "Asia/Hong_Kong";
  final String TIMEZONE_ASIA_HOVD = "Asia/Hovd";
  final String TIMEZONE_ASIA_IRKUTSK = "Asia/Irkutsk";
  final String TIMEZONE_ASIA_ISTANBUL = "Asia/Istanbul";
  final String TIMEZONE_ASIA_JAKARTA = "Asia/Jakarta";
  final String TIMEZONE_ASIA_JAYAPURA = "Asia/Jayapura";
  final String TIMEZONE_ASIA_JERUSALEM = "Asia/Jerusalem";
  final String TIMEZONE_ASIA_KABUL = "Asia/Kabul";
  final String TIMEZONE_ASIA_KAMCHATKA = "Asia/Kamchatka";
  final String TIMEZONE_ASIA_KARACHI = "Asia/Karachi";
  final String TIMEZONE_ASIA_KASHGAR = "Asia/Kashgar";
  final String TIMEZONE_ASIA_KATHMANDU = "Asia/Kathmandu";
  final String TIMEZONE_ASIA_KATMANDU = "Asia/Katmandu";
  final String TIMEZONE_ASIA_KHANDYGA = "Asia/Khandyga";
  final String TIMEZONE_ASIA_KOLKATA = "Asia/Kolkata";
  final String TIMEZONE_ASIA_KRASNOYARSK = "Asia/Krasnoyarsk";
  final String TIMEZONE_ASIA_KUALA_LUMPUR = "Asia/Kuala_Lumpur";
  final String TIMEZONE_ASIA_KUCHING = "Asia/Kuching";
  final String TIMEZONE_ASIA_KUWAIT = "Asia/Kuwait";
  final String TIMEZONE_ASIA_MACAO = "Asia/Macao";
  final String TIMEZONE_ASIA_MACAU = "Asia/Macau";
  final String TIMEZONE_ASIA_MAGADAN = "Asia/Magadan";
  final String TIMEZONE_ASIA_MAKASSAR = "Asia/Makassar";
  final String TIMEZONE_ASIA_MANILA = "Asia/Manila";
  final String TIMEZONE_ASIA_MUSCAT = "Asia/Muscat";
  final String TIMEZONE_ASIA_NICOSIA = "Asia/Nicosia";
  final String TIMEZONE_ASIA_NOVOKUZNETSK = "Asia/Novokuznetsk";
  final String TIMEZONE_ASIA_NOVOSIBIRSK = "Asia/Novosibirsk";
  final String TIMEZONE_ASIA_OMSK = "Asia/Omsk";
  final String TIMEZONE_ASIA_ORAL = "Asia/Oral";
  final String TIMEZONE_ASIA_PHNOM_PENH = "Asia/Phnom_Penh";
  final String TIMEZONE_ASIA_PONTIANAK = "Asia/Pontianak";
  final String TIMEZONE_ASIA_PYONGYANG = "Asia/Pyongyang";
  final String TIMEZONE_ASIA_QATAR = "Asia/Qatar";
  final String TIMEZONE_ASIA_QOSTANAY = "Asia/Qostanay";
  final String TIMEZONE_ASIA_QYZYLORDA = "Asia/Qyzylorda";
  final String TIMEZONE_ASIA_RANGOON = "Asia/Rangoon";
  final String TIMEZONE_ASIA_RIYADH = "Asia/Riyadh";
  final String TIMEZONE_ASIA_SAIGON = "Asia/Saigon";
  final String TIMEZONE_ASIA_SAKHALIN = "Asia/Sakhalin";
  final String TIMEZONE_ASIA_SAMARKAND = "Asia/Samarkand";
  final String TIMEZONE_ASIA_SEOUL = "Asia/Seoul";
  final String TIMEZONE_ASIA_SHANGHAI = "Asia/Shanghai";
  final String TIMEZONE_ASIA_SINGAPORE = "Asia/Singapore";
  final String TIMEZONE_ASIA_SREDNEKOLYMSK = "Asia/Srednekolymsk";
  final String TIMEZONE_ASIA_TAIPEI = "Asia/Taipei";
  final String TIMEZONE_ASIA_TASHKENT = "Asia/Tashkent";
  final String TIMEZONE_ASIA_TBILISI = "Asia/Tbilisi";
  final String TIMEZONE_ASIA_TEHRAN = "Asia/Tehran";
  final String TIMEZONE_ASIA_TEL_AVIV = "Asia/Tel_Aviv";
  final String TIMEZONE_ASIA_THIMBU = "Asia/Thimbu";
  final String TIMEZONE_ASIA_THIMPHU = "Asia/Thimphu";
  final String TIMEZONE_ASIA_TOKYO = "Asia/Tokyo";
  final String TIMEZONE_ASIA_TOMSK = "Asia/Tomsk";
  final String TIMEZONE_ASIA_UJUNG_PANDANG = "Asia/Ujung_Pandang";
  final String TIMEZONE_ASIA_ULAANBAATAR = "Asia/Ulaanbaatar";
  final String TIMEZONE_ASIA_ULAN_BATOR = "Asia/Ulan_Bator";
  final String TIMEZONE_ASIA_URUMQI = "Asia/Urumqi";
  final String TIMEZONE_ASIA_UST_NERA = "Asia/Ust-Nera";
  final String TIMEZONE_ASIA_VIENTIANE = "Asia/Vientiane";
  final String TIMEZONE_ASIA_VLADIVOSTOK = "Asia/Vladivostok";
  final String TIMEZONE_ASIA_YAKUTSK = "Asia/Yakutsk";
  final String TIMEZONE_ASIA_YANGON = "Asia/Yangon";
  final String TIMEZONE_ASIA_YEKATERINBURG = "Asia/Yekaterinburg";
  final String TIMEZONE_ASIA_YEREVAN = "Asia/Yerevan";
  final String TIMEZONE_ATLANTIC_AZORES = "Atlantic/Azores";
  final String TIMEZONE_ATLANTIC_BERMUDA = "Atlantic/Bermuda";
  final String TIMEZONE_ATLANTIC_CANARY = "Atlantic/Canary";
  final String TIMEZONE_ATLANTIC_CAPE_VERDE = "Atlantic/Cape_Verde";
  final String TIMEZONE_ATLANTIC_FAEROE = "Atlantic/Faeroe";
  final String TIMEZONE_ATLANTIC_FAROE = "Atlantic/Faroe";
  final String TIMEZONE_ATLANTIC_JAN_MAYEN = "Atlantic/Jan_Mayen";
  final String TIMEZONE_ATLANTIC_MADEIRA = "Atlantic/Madeira";
  final String TIMEZONE_ATLANTIC_REYKJAVIK = "Atlantic/Reykjavik";
  final String TIMEZONE_ATLANTIC_SOUTH_GEORGIA = "Atlantic/South_Georgia";
  final String TIMEZONE_ATLANTIC_ST_HELENA = "Atlantic/St_Helena";
  final String TIMEZONE_ATLANTIC_STANLEY = "Atlantic/Stanley";
  final String TIMEZONE_AUSTRALIA_ACT = "Australia/ACT";
  final String TIMEZONE_AUSTRALIA_ADELAIDE = "Australia/Adelaide";
  final String TIMEZONE_AUSTRALIA_BRISBANE = "Australia/Brisbane";
  final String TIMEZONE_AUSTRALIA_BROKEN_HILL = "Australia/Broken_Hill";
  final String TIMEZONE_AUSTRALIA_CANBERRA = "Australia/Canberra";
  final String TIMEZONE_AUSTRALIA_CURRIE = "Australia/Currie";
  final String TIMEZONE_AUSTRALIA_DARWIN = "Australia/Darwin";
  final String TIMEZONE_AUSTRALIA_EUCLA = "Australia/Eucla";
  final String TIMEZONE_AUSTRALIA_HOBART = "Australia/Hobart";
  final String TIMEZONE_AUSTRALIA_LHI = "Australia/LHI";
  final String TIMEZONE_AUSTRALIA_LINDEMAN = "Australia/Lindeman";
  final String TIMEZONE_AUSTRALIA_LORD_HOWE = "Australia/Lord_Howe";
  final String TIMEZONE_AUSTRALIA_MELBOURNE = "Australia/Melbourne";
  final String TIMEZONE_AUSTRALIA_NSW = "Australia/NSW";
  final String TIMEZONE_AUSTRALIA_NORTH = "Australia/North";
  final String TIMEZONE_AUSTRALIA_PERTH = "Australia/Perth";
  final String TIMEZONE_AUSTRALIA_QUEENSLAND = "Australia/Queensland";
  final String TIMEZONE_AUSTRALIA_SOUTH = "Australia/South";
  final String TIMEZONE_AUSTRALIA_SYDNEY = "Australia/Sydney";
  final String TIMEZONE_AUSTRALIA_TASMANIA = "Australia/Tasmania";
  final String TIMEZONE_AUSTRALIA_VICTORIA = "Australia/Victoria";
  final String TIMEZONE_AUSTRALIA_WEST = "Australia/West";
  final String TIMEZONE_AUSTRALIA_YANCOWINNA = "Australia/Yancowinna";
  final String TIMEZONE_BRAZIL_ACRE = "Brazil/Acre";
  final String TIMEZONE_BRAZIL_DENORONHA = "Brazil/DeNoronha";
  final String TIMEZONE_BRAZIL_EAST = "Brazil/East";
  final String TIMEZONE_BRAZIL_WEST = "Brazil/West";
  final String TIMEZONE_CET = "CET";
  final String TIMEZONE_CST6CDT = "CST6CDT";
  final String TIMEZONE_CANADA_ATLANTIC = "Canada/Atlantic";
  final String TIMEZONE_CANADA_CENTRAL = "Canada/Central";
  final String TIMEZONE_CANADA_EASTERN = "Canada/Eastern";
  final String TIMEZONE_CANADA_MOUNTAIN = "Canada/Mountain";
  final String TIMEZONE_CANADA_NEWFOUNDLAND = "Canada/Newfoundland";
  final String TIMEZONE_CANADA_PACIFIC = "Canada/Pacific";
  final String TIMEZONE_CANADA_SASKATCHEWAN = "Canada/Saskatchewan";
  final String TIMEZONE_CANADA_YUKON = "Canada/Yukon";
  final String TIMEZONE_CHILE_CONTINENTAL = "Chile/Continental";
  final String TIMEZONE_CHILE_EASTERISLAND = "Chile/EasterIsland";
  final String TIMEZONE_CUBA = "Cuba";
  final String TIMEZONE_EET = "EET";
  final String TIMEZONE_EST = "EST";
  final String TIMEZONE_EST5EDT = "EST5EDT";
  final String TIMEZONE_EGYPT = "Egypt";
  final String TIMEZONE_EIRE = "Eire";
  final String TIMEZONE_ETC_GMT = "Etc/GMT";
  final String TIMEZONE_ETC_GMTP0 = "Etc/GMT+0";
  final String TIMEZONE_ETC_GMTP1 = "Etc/GMT+1";
  final String TIMEZONE_ETC_GMTP10 = "Etc/GMT+10";
  final String TIMEZONE_ETC_GMTP11 = "Etc/GMT+11";
  final String TIMEZONE_ETC_GMTP12 = "Etc/GMT+12";
  final String TIMEZONE_ETC_GMTP2 = "Etc/GMT+2";
  final String TIMEZONE_ETC_GMTP3 = "Etc/GMT+3";
  final String TIMEZONE_ETC_GMTP4 = "Etc/GMT+4";
  final String TIMEZONE_ETC_GMTP5 = "Etc/GMT+5";
  final String TIMEZONE_ETC_GMTP6 = "Etc/GMT+6";
  final String TIMEZONE_ETC_GMTP7 = "Etc/GMT+7";
  final String TIMEZONE_ETC_GMTP8 = "Etc/GMT+8";
  final String TIMEZONE_ETC_GMTP9 = "Etc/GMT+9";
  final String TIMEZONE_ETC_GMT_0 = "Etc/GMT-0";
  final String TIMEZONE_ETC_GMT_1 = "Etc/GMT-1";
  final String TIMEZONE_ETC_GMT_10 = "Etc/GMT-10";
  final String TIMEZONE_ETC_GMT_11 = "Etc/GMT-11";
  final String TIMEZONE_ETC_GMT_12 = "Etc/GMT-12";
  final String TIMEZONE_ETC_GMT_13 = "Etc/GMT-13";
  final String TIMEZONE_ETC_GMT_14 = "Etc/GMT-14";
  final String TIMEZONE_ETC_GMT_2 = "Etc/GMT-2";
  final String TIMEZONE_ETC_GMT_3 = "Etc/GMT-3";
  final String TIMEZONE_ETC_GMT_4 = "Etc/GMT-4";
  final String TIMEZONE_ETC_GMT_5 = "Etc/GMT-5";
  final String TIMEZONE_ETC_GMT_6 = "Etc/GMT-6";
  final String TIMEZONE_ETC_GMT_7 = "Etc/GMT-7";
  final String TIMEZONE_ETC_GMT_8 = "Etc/GMT-8";
  final String TIMEZONE_ETC_GMT_9 = "Etc/GMT-9";
  final String TIMEZONE_ETC_GMT0 = "Etc/GMT0";
  final String TIMEZONE_ETC_GREENWICH = "Etc/Greenwich";
  final String TIMEZONE_ETC_UCT = "Etc/UCT";
  final String TIMEZONE_ETC_UTC = "Etc/UTC";
  final String TIMEZONE_ETC_UNIVERSAL = "Etc/Universal";
  final String TIMEZONE_ETC_ZULU = "Etc/Zulu";
  final String TIMEZONE_EUROPE_AMSTERDAM = "Europe/Amsterdam";
  final String TIMEZONE_EUROPE_ANDORRA = "Europe/Andorra";
  final String TIMEZONE_EUROPE_ASTRAKHAN = "Europe/Astrakhan";
  final String TIMEZONE_EUROPE_ATHENS = "Europe/Athens";
  final String TIMEZONE_EUROPE_BELFAST = "Europe/Belfast";
  final String TIMEZONE_EUROPE_BELGRADE = "Europe/Belgrade";
  final String TIMEZONE_EUROPE_BERLIN = "Europe/Berlin";
  final String TIMEZONE_EUROPE_BRATISLAVA = "Europe/Bratislava";
  final String TIMEZONE_EUROPE_BRUSSELS = "Europe/Brussels";
  final String TIMEZONE_EUROPE_BUCHAREST = "Europe/Bucharest";
  final String TIMEZONE_EUROPE_BUDAPEST = "Europe/Budapest";
  final String TIMEZONE_EUROPE_BUSINGEN = "Europe/Busingen";
  final String TIMEZONE_EUROPE_CHISINAU = "Europe/Chisinau";
  final String TIMEZONE_EUROPE_COPENHAGEN = "Europe/Copenhagen";
  final String TIMEZONE_EUROPE_DUBLIN = "Europe/Dublin";
  final String TIMEZONE_EUROPE_GIBRALTAR = "Europe/Gibraltar";
  final String TIMEZONE_EUROPE_GUERNSEY = "Europe/Guernsey";
  final String TIMEZONE_EUROPE_HELSINKI = "Europe/Helsinki";
  final String TIMEZONE_EUROPE_ISLE_OF_MAN = "Europe/Isle_of_Man";
  final String TIMEZONE_EUROPE_ISTANBUL = "Europe/Istanbul";
  final String TIMEZONE_EUROPE_JERSEY = "Europe/Jersey";
  final String TIMEZONE_EUROPE_KALININGRAD = "Europe/Kaliningrad";
  final String TIMEZONE_EUROPE_KIEV = "Europe/Kiev";
  final String TIMEZONE_EUROPE_KIROV = "Europe/Kirov";
  final String TIMEZONE_EUROPE_LISBON = "Europe/Lisbon";
  final String TIMEZONE_EUROPE_LJUBLJANA = "Europe/Ljubljana";
  final String TIMEZONE_EUROPE_LONDON = "Europe/London";
  final String TIMEZONE_EUROPE_LUXEMBOURG = "Europe/Luxembourg";
  final String TIMEZONE_EUROPE_MADRID = "Europe/Madrid";
  final String TIMEZONE_EUROPE_MALTA = "Europe/Malta";
  final String TIMEZONE_EUROPE_MARIEHAMN = "Europe/Mariehamn";
  final String TIMEZONE_EUROPE_MINSK = "Europe/Minsk";
  final String TIMEZONE_EUROPE_MONACO = "Europe/Monaco";
  final String TIMEZONE_EUROPE_MOSCOW = "Europe/Moscow";
  final String TIMEZONE_EUROPE_NICOSIA = "Europe/Nicosia";
  final String TIMEZONE_EUROPE_OSLO = "Europe/Oslo";
  final String TIMEZONE_EUROPE_PARIS = "Europe/Paris";
  final String TIMEZONE_EUROPE_PODGORICA = "Europe/Podgorica";
  final String TIMEZONE_EUROPE_PRAGUE = "Europe/Prague";
  final String TIMEZONE_EUROPE_RIGA = "Europe/Riga";
  final String TIMEZONE_EUROPE_ROME = "Europe/Rome";
  final String TIMEZONE_EUROPE_SAMARA = "Europe/Samara";
  final String TIMEZONE_EUROPE_SAN_MARINO = "Europe/San_Marino";
  final String TIMEZONE_EUROPE_SARAJEVO = "Europe/Sarajevo";
  final String TIMEZONE_EUROPE_SARATOV = "Europe/Saratov";
  final String TIMEZONE_EUROPE_SIMFEROPOL = "Europe/Simferopol";
  final String TIMEZONE_EUROPE_SKOPJE = "Europe/Skopje";
  final String TIMEZONE_EUROPE_SOFIA = "Europe/Sofia";
  final String TIMEZONE_EUROPE_STOCKHOLM = "Europe/Stockholm";
  final String TIMEZONE_EUROPE_TALLINN = "Europe/Tallinn";
  final String TIMEZONE_EUROPE_TIRANE = "Europe/Tirane";
  final String TIMEZONE_EUROPE_TIRASPOL = "Europe/Tiraspol";
  final String TIMEZONE_EUROPE_ULYANOVSK = "Europe/Ulyanovsk";
  final String TIMEZONE_EUROPE_UZHGOROD = "Europe/Uzhgorod";
  final String TIMEZONE_EUROPE_VADUZ = "Europe/Vaduz";
  final String TIMEZONE_EUROPE_VATICAN = "Europe/Vatican";
  final String TIMEZONE_EUROPE_VIENNA = "Europe/Vienna";
  final String TIMEZONE_EUROPE_VILNIUS = "Europe/Vilnius";
  final String TIMEZONE_EUROPE_VOLGOGRAD = "Europe/Volgograd";
  final String TIMEZONE_EUROPE_WARSAW = "Europe/Warsaw";
  final String TIMEZONE_EUROPE_ZAGREB = "Europe/Zagreb";
  final String TIMEZONE_EUROPE_ZAPOROZHYE = "Europe/Zaporozhye";
  final String TIMEZONE_EUROPE_ZURICH = "Europe/Zurich";
  final String TIMEZONE_GB = "GB";
  final String TIMEZONE_GB_EIRE = "GB-Eire";
  final String TIMEZONE_GMT = "GMT";
  final String TIMEZONE_GMTP0 = "GMT+0";
  final String TIMEZONE_GMT_0 = "GMT-0";
  final String TIMEZONE_GMT0 = "GMT0";
  final String TIMEZONE_GREENWICH = "Greenwich";
  final String TIMEZONE_HST = "HST";
  final String TIMEZONE_HONGKONG = "Hongkong";
  final String TIMEZONE_ICELAND = "Iceland";
  final String TIMEZONE_INDIAN_ANTANANARIVO = "Indian/Antananarivo";
  final String TIMEZONE_INDIAN_CHAGOS = "Indian/Chagos";
  final String TIMEZONE_INDIAN_CHRISTMAS = "Indian/Christmas";
  final String TIMEZONE_INDIAN_COCOS = "Indian/Cocos";
  final String TIMEZONE_INDIAN_COMORO = "Indian/Comoro";
  final String TIMEZONE_INDIAN_KERGUELEN = "Indian/Kerguelen";
  final String TIMEZONE_INDIAN_MAHE = "Indian/Mahe";
  final String TIMEZONE_INDIAN_MALDIVES = "Indian/Maldives";
  final String TIMEZONE_INDIAN_MAURITIUS = "Indian/Mauritius";
  final String TIMEZONE_INDIAN_MAYOTTE = "Indian/Mayotte";
  final String TIMEZONE_INDIAN_REUNION = "Indian/Reunion";
  final String TIMEZONE_IRAN = "Iran";
  final String TIMEZONE_ISRAEL = "Israel";
  final String TIMEZONE_JAMAICA = "Jamaica";
  final String TIMEZONE_JAPAN = "Japan";
  final String TIMEZONE_KWAJALEIN = "Kwajalein";
  final String TIMEZONE_LIBYA = "Libya";
  final String TIMEZONE_MET = "MET";
  final String TIMEZONE_MST = "MST";
  final String TIMEZONE_MST7MDT = "MST7MDT";
  final String TIMEZONE_MEXICO_BAJANORTE = "Mexico/BajaNorte";
  final String TIMEZONE_MEXICO_BAJASUR = "Mexico/BajaSur";
  final String TIMEZONE_MEXICO_GENERAL = "Mexico/General";
  final String TIMEZONE_NZ = "NZ";
  final String TIMEZONE_NZ_CHAT = "NZ-CHAT";
  final String TIMEZONE_NAVAJO = "Navajo";
  final String TIMEZONE_PRC = "PRC";
  final String TIMEZONE_PST8PDT = "PST8PDT";
  final String TIMEZONE_PACIFIC_APIA = "Pacific/Apia";
  final String TIMEZONE_PACIFIC_AUCKLAND = "Pacific/Auckland";
  final String TIMEZONE_PACIFIC_BOUGAINVILLE = "Pacific/Bougainville";
  final String TIMEZONE_PACIFIC_CHATHAM = "Pacific/Chatham";
  final String TIMEZONE_PACIFIC_CHUUK = "Pacific/Chuuk";
  final String TIMEZONE_PACIFIC_EASTER = "Pacific/Easter";
  final String TIMEZONE_PACIFIC_EFATE = "Pacific/Efate";
  final String TIMEZONE_PACIFIC_ENDERBURY = "Pacific/Enderbury";
  final String TIMEZONE_PACIFIC_FAKAOFO = "Pacific/Fakaofo";
  final String TIMEZONE_PACIFIC_FIJI = "Pacific/Fiji";
  final String TIMEZONE_PACIFIC_FUNAFUTI = "Pacific/Funafuti";
  final String TIMEZONE_PACIFIC_GALAPAGOS = "Pacific/Galapagos";
  final String TIMEZONE_PACIFIC_GAMBIER = "Pacific/Gambier";
  final String TIMEZONE_PACIFIC_GUADALCANAL = "Pacific/Guadalcanal";
  final String TIMEZONE_PACIFIC_GUAM = "Pacific/Guam";
  final String TIMEZONE_PACIFIC_HONOLULU = "Pacific/Honolulu";
  final String TIMEZONE_PACIFIC_JOHNSTON = "Pacific/Johnston";
  final String TIMEZONE_PACIFIC_KIRITIMATI = "Pacific/Kiritimati";
  final String TIMEZONE_PACIFIC_KOSRAE = "Pacific/Kosrae";
  final String TIMEZONE_PACIFIC_KWAJALEIN = "Pacific/Kwajalein";
  final String TIMEZONE_PACIFIC_MAJURO = "Pacific/Majuro";
  final String TIMEZONE_PACIFIC_MARQUESAS = "Pacific/Marquesas";
  final String TIMEZONE_PACIFIC_MIDWAY = "Pacific/Midway";
  final String TIMEZONE_PACIFIC_NAURU = "Pacific/Nauru";
  final String TIMEZONE_PACIFIC_NIUE = "Pacific/Niue";
  final String TIMEZONE_PACIFIC_NORFOLK = "Pacific/Norfolk";
  final String TIMEZONE_PACIFIC_NOUMEA = "Pacific/Noumea";
  final String TIMEZONE_PACIFIC_PAGO_PAGO = "Pacific/Pago_Pago";
  final String TIMEZONE_PACIFIC_PALAU = "Pacific/Palau";
  final String TIMEZONE_PACIFIC_PITCAIRN = "Pacific/Pitcairn";
  final String TIMEZONE_PACIFIC_POHNPEI = "Pacific/Pohnpei";
  final String TIMEZONE_PACIFIC_PONAPE = "Pacific/Ponape";
  final String TIMEZONE_PACIFIC_PORT_MORESBY = "Pacific/Port_Moresby";
  final String TIMEZONE_PACIFIC_RAROTONGA = "Pacific/Rarotonga";
  final String TIMEZONE_PACIFIC_SAIPAN = "Pacific/Saipan";
  final String TIMEZONE_PACIFIC_SAMOA = "Pacific/Samoa";
  final String TIMEZONE_PACIFIC_TAHITI = "Pacific/Tahiti";
  final String TIMEZONE_PACIFIC_TARAWA = "Pacific/Tarawa";
  final String TIMEZONE_PACIFIC_TONGATAPU = "Pacific/Tongatapu";
  final String TIMEZONE_PACIFIC_TRUK = "Pacific/Truk";
  final String TIMEZONE_PACIFIC_WAKE = "Pacific/Wake";
  final String TIMEZONE_PACIFIC_WALLIS = "Pacific/Wallis";
  final String TIMEZONE_PACIFIC_YAP = "Pacific/Yap";
  final String TIMEZONE_POLAND = "Poland";
  final String TIMEZONE_PORTUGAL = "Portugal";
  final String TIMEZONE_ROC = "ROC";
  final String TIMEZONE_ROK = "ROK";
  final String TIMEZONE_SINGAPORE = "Singapore";
  final String TIMEZONE_TURKEY = "Turkey";
  final String TIMEZONE_UCT = "UCT";
  final String TIMEZONE_US_ALASKA = "US/Alaska";
  final String TIMEZONE_US_ALEUTIAN = "US/Aleutian";
  final String TIMEZONE_US_ARIZONA = "US/Arizona";
  final String TIMEZONE_US_CENTRAL = "US/Central";
  final String TIMEZONE_US_EAST_INDIANA = "US/East-Indiana";
  final String TIMEZONE_US_EASTERN = "US/Eastern";
  final String TIMEZONE_US_HAWAII = "US/Hawaii";
  final String TIMEZONE_US_INDIANA_STARKE = "US/Indiana-Starke";
  final String TIMEZONE_US_MICHIGAN = "US/Michigan";
  final String TIMEZONE_US_MOUNTAIN = "US/Mountain";
  final String TIMEZONE_US_PACIFIC = "US/Pacific";
  final String TIMEZONE_US_SAMOA = "US/Samoa";
  final String TIMEZONE_UTC = "UTC";
  final String TIMEZONE_UNIVERSAL = "Universal";
  final String TIMEZONE_W_SU = "W-SU";
  final String TIMEZONE_WET = "WET";
  final String TIMEZONE_ZULU = "Zulu";
  String get timezoneString {
    if(timezone == TIMEZONE_AFRICA_ABIDJAN) return 'Africa/Abidjan';
    if(timezone == TIMEZONE_AFRICA_ACCRA) return 'Africa/Accra';
    if(timezone == TIMEZONE_AFRICA_ADDIS_ABABA) return 'Africa/Addis_Ababa';
    if(timezone == TIMEZONE_AFRICA_ALGIERS) return 'Africa/Algiers';
    if(timezone == TIMEZONE_AFRICA_ASMARA) return 'Africa/Asmara';
    if(timezone == TIMEZONE_AFRICA_ASMERA) return 'Africa/Asmera';
    if(timezone == TIMEZONE_AFRICA_BAMAKO) return 'Africa/Bamako';
    if(timezone == TIMEZONE_AFRICA_BANGUI) return 'Africa/Bangui';
    if(timezone == TIMEZONE_AFRICA_BANJUL) return 'Africa/Banjul';
    if(timezone == TIMEZONE_AFRICA_BISSAU) return 'Africa/Bissau';
    if(timezone == TIMEZONE_AFRICA_BLANTYRE) return 'Africa/Blantyre';
    if(timezone == TIMEZONE_AFRICA_BRAZZAVILLE) return 'Africa/Brazzaville';
    if(timezone == TIMEZONE_AFRICA_BUJUMBURA) return 'Africa/Bujumbura';
    if(timezone == TIMEZONE_AFRICA_CAIRO) return 'Africa/Cairo';
    if(timezone == TIMEZONE_AFRICA_CASABLANCA) return 'Africa/Casablanca';
    if(timezone == TIMEZONE_AFRICA_CEUTA) return 'Africa/Ceuta';
    if(timezone == TIMEZONE_AFRICA_CONAKRY) return 'Africa/Conakry';
    if(timezone == TIMEZONE_AFRICA_DAKAR) return 'Africa/Dakar';
    if(timezone == TIMEZONE_AFRICA_DAR_ES_SALAAM) return 'Africa/Dar_es_Salaam';
    if(timezone == TIMEZONE_AFRICA_DJIBOUTI) return 'Africa/Djibouti';
    if(timezone == TIMEZONE_AFRICA_DOUALA) return 'Africa/Douala';
    if(timezone == TIMEZONE_AFRICA_EL_AAIUN) return 'Africa/El_Aaiun';
    if(timezone == TIMEZONE_AFRICA_FREETOWN) return 'Africa/Freetown';
    if(timezone == TIMEZONE_AFRICA_GABORONE) return 'Africa/Gaborone';
    if(timezone == TIMEZONE_AFRICA_HARARE) return 'Africa/Harare';
    if(timezone == TIMEZONE_AFRICA_JOHANNESBURG) return 'Africa/Johannesburg';
    if(timezone == TIMEZONE_AFRICA_JUBA) return 'Africa/Juba';
    if(timezone == TIMEZONE_AFRICA_KAMPALA) return 'Africa/Kampala';
    if(timezone == TIMEZONE_AFRICA_KHARTOUM) return 'Africa/Khartoum';
    if(timezone == TIMEZONE_AFRICA_KIGALI) return 'Africa/Kigali';
    if(timezone == TIMEZONE_AFRICA_KINSHASA) return 'Africa/Kinshasa';
    if(timezone == TIMEZONE_AFRICA_LAGOS) return 'Africa/Lagos';
    if(timezone == TIMEZONE_AFRICA_LIBREVILLE) return 'Africa/Libreville';
    if(timezone == TIMEZONE_AFRICA_LOME) return 'Africa/Lome';
    if(timezone == TIMEZONE_AFRICA_LUANDA) return 'Africa/Luanda';
    if(timezone == TIMEZONE_AFRICA_LUBUMBASHI) return 'Africa/Lubumbashi';
    if(timezone == TIMEZONE_AFRICA_LUSAKA) return 'Africa/Lusaka';
    if(timezone == TIMEZONE_AFRICA_MALABO) return 'Africa/Malabo';
    if(timezone == TIMEZONE_AFRICA_MAPUTO) return 'Africa/Maputo';
    if(timezone == TIMEZONE_AFRICA_MASERU) return 'Africa/Maseru';
    if(timezone == TIMEZONE_AFRICA_MBABANE) return 'Africa/Mbabane';
    if(timezone == TIMEZONE_AFRICA_MOGADISHU) return 'Africa/Mogadishu';
    if(timezone == TIMEZONE_AFRICA_MONROVIA) return 'Africa/Monrovia';
    if(timezone == TIMEZONE_AFRICA_NAIROBI) return 'Africa/Nairobi';
    if(timezone == TIMEZONE_AFRICA_NDJAMENA) return 'Africa/Ndjamena';
    if(timezone == TIMEZONE_AFRICA_NIAMEY) return 'Africa/Niamey';
    if(timezone == TIMEZONE_AFRICA_NOUAKCHOTT) return 'Africa/Nouakchott';
    if(timezone == TIMEZONE_AFRICA_OUAGADOUGOU) return 'Africa/Ouagadougou';
    if(timezone == TIMEZONE_AFRICA_PORTO_NOVO) return 'Africa/Porto-Novo';
    if(timezone == TIMEZONE_AFRICA_SAO_TOME) return 'Africa/Sao_Tome';
    if(timezone == TIMEZONE_AFRICA_TIMBUKTU) return 'Africa/Timbuktu';
    if(timezone == TIMEZONE_AFRICA_TRIPOLI) return 'Africa/Tripoli';
    if(timezone == TIMEZONE_AFRICA_TUNIS) return 'Africa/Tunis';
    if(timezone == TIMEZONE_AFRICA_WINDHOEK) return 'Africa/Windhoek';
    if(timezone == TIMEZONE_AMERICA_ADAK) return 'America/Adak';
    if(timezone == TIMEZONE_AMERICA_ANCHORAGE) return 'America/Anchorage';
    if(timezone == TIMEZONE_AMERICA_ANGUILLA) return 'America/Anguilla';
    if(timezone == TIMEZONE_AMERICA_ANTIGUA) return 'America/Antigua';
    if(timezone == TIMEZONE_AMERICA_ARAGUAINA) return 'America/Araguaina';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_BUENOS_AIRES) return 'America/Argentina/Buenos_Aires';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_CATAMARCA) return 'America/Argentina/Catamarca';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_COMODRIVADAVIA) return 'America/Argentina/ComodRivadavia';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_CORDOBA) return 'America/Argentina/Cordoba';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_JUJUY) return 'America/Argentina/Jujuy';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_LA_RIOJA) return 'America/Argentina/La_Rioja';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_MENDOZA) return 'America/Argentina/Mendoza';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_RIO_GALLEGOS) return 'America/Argentina/Rio_Gallegos';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_SALTA) return 'America/Argentina/Salta';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_SAN_JUAN) return 'America/Argentina/San_Juan';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_SAN_LUIS) return 'America/Argentina/San_Luis';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_TUCUMAN) return 'America/Argentina/Tucuman';
    if(timezone == TIMEZONE_AMERICA_ARGENTINA_USHUAIA) return 'America/Argentina/Ushuaia';
    if(timezone == TIMEZONE_AMERICA_ARUBA) return 'America/Aruba';
    if(timezone == TIMEZONE_AMERICA_ASUNCION) return 'America/Asuncion';
    if(timezone == TIMEZONE_AMERICA_ATIKOKAN) return 'America/Atikokan';
    if(timezone == TIMEZONE_AMERICA_ATKA) return 'America/Atka';
    if(timezone == TIMEZONE_AMERICA_BAHIA) return 'America/Bahia';
    if(timezone == TIMEZONE_AMERICA_BAHIA_BANDERAS) return 'America/Bahia_Banderas';
    if(timezone == TIMEZONE_AMERICA_BARBADOS) return 'America/Barbados';
    if(timezone == TIMEZONE_AMERICA_BELEM) return 'America/Belem';
    if(timezone == TIMEZONE_AMERICA_BELIZE) return 'America/Belize';
    if(timezone == TIMEZONE_AMERICA_BLANC_SABLON) return 'America/Blanc-Sablon';
    if(timezone == TIMEZONE_AMERICA_BOA_VISTA) return 'America/Boa_Vista';
    if(timezone == TIMEZONE_AMERICA_BOGOTA) return 'America/Bogota';
    if(timezone == TIMEZONE_AMERICA_BOISE) return 'America/Boise';
    if(timezone == TIMEZONE_AMERICA_BUENOS_AIRES) return 'America/Buenos_Aires';
    if(timezone == TIMEZONE_AMERICA_CAMBRIDGE_BAY) return 'America/Cambridge_Bay';
    if(timezone == TIMEZONE_AMERICA_CAMPO_GRANDE) return 'America/Campo_Grande';
    if(timezone == TIMEZONE_AMERICA_CANCUN) return 'America/Cancun';
    if(timezone == TIMEZONE_AMERICA_CARACAS) return 'America/Caracas';
    if(timezone == TIMEZONE_AMERICA_CATAMARCA) return 'America/Catamarca';
    if(timezone == TIMEZONE_AMERICA_CAYENNE) return 'America/Cayenne';
    if(timezone == TIMEZONE_AMERICA_CAYMAN) return 'America/Cayman';
    if(timezone == TIMEZONE_AMERICA_CHICAGO) return 'America/Chicago';
    if(timezone == TIMEZONE_AMERICA_CHIHUAHUA) return 'America/Chihuahua';
    if(timezone == TIMEZONE_AMERICA_CORAL_HARBOUR) return 'America/Coral_Harbour';
    if(timezone == TIMEZONE_AMERICA_CORDOBA) return 'America/Cordoba';
    if(timezone == TIMEZONE_AMERICA_COSTA_RICA) return 'America/Costa_Rica';
    if(timezone == TIMEZONE_AMERICA_CRESTON) return 'America/Creston';
    if(timezone == TIMEZONE_AMERICA_CUIABA) return 'America/Cuiaba';
    if(timezone == TIMEZONE_AMERICA_CURACAO) return 'America/Curacao';
    if(timezone == TIMEZONE_AMERICA_DANMARKSHAVN) return 'America/Danmarkshavn';
    if(timezone == TIMEZONE_AMERICA_DAWSON) return 'America/Dawson';
    if(timezone == TIMEZONE_AMERICA_DAWSON_CREEK) return 'America/Dawson_Creek';
    if(timezone == TIMEZONE_AMERICA_DENVER) return 'America/Denver';
    if(timezone == TIMEZONE_AMERICA_DETROIT) return 'America/Detroit';
    if(timezone == TIMEZONE_AMERICA_DOMINICA) return 'America/Dominica';
    if(timezone == TIMEZONE_AMERICA_EDMONTON) return 'America/Edmonton';
    if(timezone == TIMEZONE_AMERICA_EIRUNEPE) return 'America/Eirunepe';
    if(timezone == TIMEZONE_AMERICA_EL_SALVADOR) return 'America/El_Salvador';
    if(timezone == TIMEZONE_AMERICA_ENSENADA) return 'America/Ensenada';
    if(timezone == TIMEZONE_AMERICA_FORT_NELSON) return 'America/Fort_Nelson';
    if(timezone == TIMEZONE_AMERICA_FORT_WAYNE) return 'America/Fort_Wayne';
    if(timezone == TIMEZONE_AMERICA_FORTALEZA) return 'America/Fortaleza';
    if(timezone == TIMEZONE_AMERICA_GLACE_BAY) return 'America/Glace_Bay';
    if(timezone == TIMEZONE_AMERICA_GODTHAB) return 'America/Godthab';
    if(timezone == TIMEZONE_AMERICA_GOOSE_BAY) return 'America/Goose_Bay';
    if(timezone == TIMEZONE_AMERICA_GRAND_TURK) return 'America/Grand_Turk';
    if(timezone == TIMEZONE_AMERICA_GRENADA) return 'America/Grenada';
    if(timezone == TIMEZONE_AMERICA_GUADELOUPE) return 'America/Guadeloupe';
    if(timezone == TIMEZONE_AMERICA_GUATEMALA) return 'America/Guatemala';
    if(timezone == TIMEZONE_AMERICA_GUAYAQUIL) return 'America/Guayaquil';
    if(timezone == TIMEZONE_AMERICA_GUYANA) return 'America/Guyana';
    if(timezone == TIMEZONE_AMERICA_HALIFAX) return 'America/Halifax';
    if(timezone == TIMEZONE_AMERICA_HAVANA) return 'America/Havana';
    if(timezone == TIMEZONE_AMERICA_HERMOSILLO) return 'America/Hermosillo';
    if(timezone == TIMEZONE_AMERICA_INDIANA_INDIANAPOLIS) return 'America/Indiana/Indianapolis';
    if(timezone == TIMEZONE_AMERICA_INDIANA_KNOX) return 'America/Indiana/Knox';
    if(timezone == TIMEZONE_AMERICA_INDIANA_MARENGO) return 'America/Indiana/Marengo';
    if(timezone == TIMEZONE_AMERICA_INDIANA_PETERSBURG) return 'America/Indiana/Petersburg';
    if(timezone == TIMEZONE_AMERICA_INDIANA_TELL_CITY) return 'America/Indiana/Tell_City';
    if(timezone == TIMEZONE_AMERICA_INDIANA_VEVAY) return 'America/Indiana/Vevay';
    if(timezone == TIMEZONE_AMERICA_INDIANA_VINCENNES) return 'America/Indiana/Vincennes';
    if(timezone == TIMEZONE_AMERICA_INDIANA_WINAMAC) return 'America/Indiana/Winamac';
    if(timezone == TIMEZONE_AMERICA_INDIANAPOLIS) return 'America/Indianapolis';
    if(timezone == TIMEZONE_AMERICA_INUVIK) return 'America/Inuvik';
    if(timezone == TIMEZONE_AMERICA_IQALUIT) return 'America/Iqaluit';
    if(timezone == TIMEZONE_AMERICA_JAMAICA) return 'America/Jamaica';
    if(timezone == TIMEZONE_AMERICA_JUJUY) return 'America/Jujuy';
    if(timezone == TIMEZONE_AMERICA_JUNEAU) return 'America/Juneau';
    if(timezone == TIMEZONE_AMERICA_KENTUCKY_LOUISVILLE) return 'America/Kentucky/Louisville';
    if(timezone == TIMEZONE_AMERICA_KENTUCKY_MONTICELLO) return 'America/Kentucky/Monticello';
    if(timezone == TIMEZONE_AMERICA_KNOX_IN) return 'America/Knox_IN';
    if(timezone == TIMEZONE_AMERICA_KRALENDIJK) return 'America/Kralendijk';
    if(timezone == TIMEZONE_AMERICA_LA_PAZ) return 'America/La_Paz';
    if(timezone == TIMEZONE_AMERICA_LIMA) return 'America/Lima';
    if(timezone == TIMEZONE_AMERICA_LOS_ANGELES) return 'America/Los_Angeles';
    if(timezone == TIMEZONE_AMERICA_LOUISVILLE) return 'America/Louisville';
    if(timezone == TIMEZONE_AMERICA_LOWER_PRINCES) return 'America/Lower_Princes';
    if(timezone == TIMEZONE_AMERICA_MACEIO) return 'America/Maceio';
    if(timezone == TIMEZONE_AMERICA_MANAGUA) return 'America/Managua';
    if(timezone == TIMEZONE_AMERICA_MANAUS) return 'America/Manaus';
    if(timezone == TIMEZONE_AMERICA_MARIGOT) return 'America/Marigot';
    if(timezone == TIMEZONE_AMERICA_MARTINIQUE) return 'America/Martinique';
    if(timezone == TIMEZONE_AMERICA_MATAMOROS) return 'America/Matamoros';
    if(timezone == TIMEZONE_AMERICA_MAZATLAN) return 'America/Mazatlan';
    if(timezone == TIMEZONE_AMERICA_MENDOZA) return 'America/Mendoza';
    if(timezone == TIMEZONE_AMERICA_MENOMINEE) return 'America/Menominee';
    if(timezone == TIMEZONE_AMERICA_MERIDA) return 'America/Merida';
    if(timezone == TIMEZONE_AMERICA_METLAKATLA) return 'America/Metlakatla';
    if(timezone == TIMEZONE_AMERICA_MEXICO_CITY) return 'America/Mexico_City';
    if(timezone == TIMEZONE_AMERICA_MIQUELON) return 'America/Miquelon';
    if(timezone == TIMEZONE_AMERICA_MONCTON) return 'America/Moncton';
    if(timezone == TIMEZONE_AMERICA_MONTERREY) return 'America/Monterrey';
    if(timezone == TIMEZONE_AMERICA_MONTEVIDEO) return 'America/Montevideo';
    if(timezone == TIMEZONE_AMERICA_MONTREAL) return 'America/Montreal';
    if(timezone == TIMEZONE_AMERICA_MONTSERRAT) return 'America/Montserrat';
    if(timezone == TIMEZONE_AMERICA_NASSAU) return 'America/Nassau';
    if(timezone == TIMEZONE_AMERICA_NEW_YORK) return 'America/New_York';
    if(timezone == TIMEZONE_AMERICA_NIPIGON) return 'America/Nipigon';
    if(timezone == TIMEZONE_AMERICA_NOME) return 'America/Nome';
    if(timezone == TIMEZONE_AMERICA_NORONHA) return 'America/Noronha';
    if(timezone == TIMEZONE_AMERICA_NORTH_DAKOTA_BEULAH) return 'America/North_Dakota/Beulah';
    if(timezone == TIMEZONE_AMERICA_NORTH_DAKOTA_CENTER) return 'America/North_Dakota/Center';
    if(timezone == TIMEZONE_AMERICA_NORTH_DAKOTA_NEW_SALEM) return 'America/North_Dakota/New_Salem';
    if(timezone == TIMEZONE_AMERICA_OJINAGA) return 'America/Ojinaga';
    if(timezone == TIMEZONE_AMERICA_PANAMA) return 'America/Panama';
    if(timezone == TIMEZONE_AMERICA_PANGNIRTUNG) return 'America/Pangnirtung';
    if(timezone == TIMEZONE_AMERICA_PARAMARIBO) return 'America/Paramaribo';
    if(timezone == TIMEZONE_AMERICA_PHOENIX) return 'America/Phoenix';
    if(timezone == TIMEZONE_AMERICA_PORT_AU_PRINCE) return 'America/Port-au-Prince';
    if(timezone == TIMEZONE_AMERICA_PORT_OF_SPAIN) return 'America/Port_of_Spain';
    if(timezone == TIMEZONE_AMERICA_PORTO_ACRE) return 'America/Porto_Acre';
    if(timezone == TIMEZONE_AMERICA_PORTO_VELHO) return 'America/Porto_Velho';
    if(timezone == TIMEZONE_AMERICA_PUERTO_RICO) return 'America/Puerto_Rico';
    if(timezone == TIMEZONE_AMERICA_PUNTA_ARENAS) return 'America/Punta_Arenas';
    if(timezone == TIMEZONE_AMERICA_RAINY_RIVER) return 'America/Rainy_River';
    if(timezone == TIMEZONE_AMERICA_RANKIN_INLET) return 'America/Rankin_Inlet';
    if(timezone == TIMEZONE_AMERICA_RECIFE) return 'America/Recife';
    if(timezone == TIMEZONE_AMERICA_REGINA) return 'America/Regina';
    if(timezone == TIMEZONE_AMERICA_RESOLUTE) return 'America/Resolute';
    if(timezone == TIMEZONE_AMERICA_RIO_BRANCO) return 'America/Rio_Branco';
    if(timezone == TIMEZONE_AMERICA_ROSARIO) return 'America/Rosario';
    if(timezone == TIMEZONE_AMERICA_SANTA_ISABEL) return 'America/Santa_Isabel';
    if(timezone == TIMEZONE_AMERICA_SANTAREM) return 'America/Santarem';
    if(timezone == TIMEZONE_AMERICA_SANTIAGO) return 'America/Santiago';
    if(timezone == TIMEZONE_AMERICA_SANTO_DOMINGO) return 'America/Santo_Domingo';
    if(timezone == TIMEZONE_AMERICA_SAO_PAULO) return 'America/Sao_Paulo';
    if(timezone == TIMEZONE_AMERICA_SCORESBYSUND) return 'America/Scoresbysund';
    if(timezone == TIMEZONE_AMERICA_SHIPROCK) return 'America/Shiprock';
    if(timezone == TIMEZONE_AMERICA_SITKA) return 'America/Sitka';
    if(timezone == TIMEZONE_AMERICA_ST_BARTHELEMY) return 'America/St_Barthelemy';
    if(timezone == TIMEZONE_AMERICA_ST_JOHNS) return 'America/St_Johns';
    if(timezone == TIMEZONE_AMERICA_ST_KITTS) return 'America/St_Kitts';
    if(timezone == TIMEZONE_AMERICA_ST_LUCIA) return 'America/St_Lucia';
    if(timezone == TIMEZONE_AMERICA_ST_THOMAS) return 'America/St_Thomas';
    if(timezone == TIMEZONE_AMERICA_ST_VINCENT) return 'America/St_Vincent';
    if(timezone == TIMEZONE_AMERICA_SWIFT_CURRENT) return 'America/Swift_Current';
    if(timezone == TIMEZONE_AMERICA_TEGUCIGALPA) return 'America/Tegucigalpa';
    if(timezone == TIMEZONE_AMERICA_THULE) return 'America/Thule';
    if(timezone == TIMEZONE_AMERICA_THUNDER_BAY) return 'America/Thunder_Bay';
    if(timezone == TIMEZONE_AMERICA_TIJUANA) return 'America/Tijuana';
    if(timezone == TIMEZONE_AMERICA_TORONTO) return 'America/Toronto';
    if(timezone == TIMEZONE_AMERICA_TORTOLA) return 'America/Tortola';
    if(timezone == TIMEZONE_AMERICA_VANCOUVER) return 'America/Vancouver';
    if(timezone == TIMEZONE_AMERICA_VIRGIN) return 'America/Virgin';
    if(timezone == TIMEZONE_AMERICA_WHITEHORSE) return 'America/Whitehorse';
    if(timezone == TIMEZONE_AMERICA_WINNIPEG) return 'America/Winnipeg';
    if(timezone == TIMEZONE_AMERICA_YAKUTAT) return 'America/Yakutat';
    if(timezone == TIMEZONE_AMERICA_YELLOWKNIFE) return 'America/Yellowknife';
    if(timezone == TIMEZONE_ANTARCTICA_CASEY) return 'Antarctica/Casey';
    if(timezone == TIMEZONE_ANTARCTICA_DAVIS) return 'Antarctica/Davis';
    if(timezone == TIMEZONE_ANTARCTICA_DUMONTDURVILLE) return 'Antarctica/DumontDUrville';
    if(timezone == TIMEZONE_ANTARCTICA_MACQUARIE) return 'Antarctica/Macquarie';
    if(timezone == TIMEZONE_ANTARCTICA_MAWSON) return 'Antarctica/Mawson';
    if(timezone == TIMEZONE_ANTARCTICA_MCMURDO) return 'Antarctica/McMurdo';
    if(timezone == TIMEZONE_ANTARCTICA_PALMER) return 'Antarctica/Palmer';
    if(timezone == TIMEZONE_ANTARCTICA_ROTHERA) return 'Antarctica/Rothera';
    if(timezone == TIMEZONE_ANTARCTICA_SOUTH_POLE) return 'Antarctica/South_Pole';
    if(timezone == TIMEZONE_ANTARCTICA_SYOWA) return 'Antarctica/Syowa';
    if(timezone == TIMEZONE_ANTARCTICA_TROLL) return 'Antarctica/Troll';
    if(timezone == TIMEZONE_ANTARCTICA_VOSTOK) return 'Antarctica/Vostok';
    if(timezone == TIMEZONE_ARCTIC_LONGYEARBYEN) return 'Arctic/Longyearbyen';
    if(timezone == TIMEZONE_ASIA_ADEN) return 'Asia/Aden';
    if(timezone == TIMEZONE_ASIA_ALMATY) return 'Asia/Almaty';
    if(timezone == TIMEZONE_ASIA_AMMAN) return 'Asia/Amman';
    if(timezone == TIMEZONE_ASIA_ANADYR) return 'Asia/Anadyr';
    if(timezone == TIMEZONE_ASIA_AQTAU) return 'Asia/Aqtau';
    if(timezone == TIMEZONE_ASIA_AQTOBE) return 'Asia/Aqtobe';
    if(timezone == TIMEZONE_ASIA_ASHGABAT) return 'Asia/Ashgabat';
    if(timezone == TIMEZONE_ASIA_ASHKHABAD) return 'Asia/Ashkhabad';
    if(timezone == TIMEZONE_ASIA_ATYRAU) return 'Asia/Atyrau';
    if(timezone == TIMEZONE_ASIA_BAGHDAD) return 'Asia/Baghdad';
    if(timezone == TIMEZONE_ASIA_BAHRAIN) return 'Asia/Bahrain';
    if(timezone == TIMEZONE_ASIA_BAKU) return 'Asia/Baku';
    if(timezone == TIMEZONE_ASIA_BANGKOK) return 'Asia/Bangkok';
    if(timezone == TIMEZONE_ASIA_BARNAUL) return 'Asia/Barnaul';
    if(timezone == TIMEZONE_ASIA_BEIRUT) return 'Asia/Beirut';
    if(timezone == TIMEZONE_ASIA_BISHKEK) return 'Asia/Bishkek';
    if(timezone == TIMEZONE_ASIA_BRUNEI) return 'Asia/Brunei';
    if(timezone == TIMEZONE_ASIA_CALCUTTA) return 'Asia/Calcutta';
    if(timezone == TIMEZONE_ASIA_CHITA) return 'Asia/Chita';
    if(timezone == TIMEZONE_ASIA_CHOIBALSAN) return 'Asia/Choibalsan';
    if(timezone == TIMEZONE_ASIA_CHONGQING) return 'Asia/Chongqing';
    if(timezone == TIMEZONE_ASIA_CHUNGKING) return 'Asia/Chungking';
    if(timezone == TIMEZONE_ASIA_COLOMBO) return 'Asia/Colombo';
    if(timezone == TIMEZONE_ASIA_DACCA) return 'Asia/Dacca';
    if(timezone == TIMEZONE_ASIA_DAMASCUS) return 'Asia/Damascus';
    if(timezone == TIMEZONE_ASIA_DHAKA) return 'Asia/Dhaka';
    if(timezone == TIMEZONE_ASIA_DILI) return 'Asia/Dili';
    if(timezone == TIMEZONE_ASIA_DUBAI) return 'Asia/Dubai';
    if(timezone == TIMEZONE_ASIA_DUSHANBE) return 'Asia/Dushanbe';
    if(timezone == TIMEZONE_ASIA_FAMAGUSTA) return 'Asia/Famagusta';
    if(timezone == TIMEZONE_ASIA_GAZA) return 'Asia/Gaza';
    if(timezone == TIMEZONE_ASIA_HARBIN) return 'Asia/Harbin';
    if(timezone == TIMEZONE_ASIA_HEBRON) return 'Asia/Hebron';
    if(timezone == TIMEZONE_ASIA_HO_CHI_MINH) return 'Asia/Ho_Chi_Minh';
    if(timezone == TIMEZONE_ASIA_HONG_KONG) return 'Asia/Hong_Kong';
    if(timezone == TIMEZONE_ASIA_HOVD) return 'Asia/Hovd';
    if(timezone == TIMEZONE_ASIA_IRKUTSK) return 'Asia/Irkutsk';
    if(timezone == TIMEZONE_ASIA_ISTANBUL) return 'Asia/Istanbul';
    if(timezone == TIMEZONE_ASIA_JAKARTA) return 'Asia/Jakarta';
    if(timezone == TIMEZONE_ASIA_JAYAPURA) return 'Asia/Jayapura';
    if(timezone == TIMEZONE_ASIA_JERUSALEM) return 'Asia/Jerusalem';
    if(timezone == TIMEZONE_ASIA_KABUL) return 'Asia/Kabul';
    if(timezone == TIMEZONE_ASIA_KAMCHATKA) return 'Asia/Kamchatka';
    if(timezone == TIMEZONE_ASIA_KARACHI) return 'Asia/Karachi';
    if(timezone == TIMEZONE_ASIA_KASHGAR) return 'Asia/Kashgar';
    if(timezone == TIMEZONE_ASIA_KATHMANDU) return 'Asia/Kathmandu';
    if(timezone == TIMEZONE_ASIA_KATMANDU) return 'Asia/Katmandu';
    if(timezone == TIMEZONE_ASIA_KHANDYGA) return 'Asia/Khandyga';
    if(timezone == TIMEZONE_ASIA_KOLKATA) return 'Asia/Kolkata';
    if(timezone == TIMEZONE_ASIA_KRASNOYARSK) return 'Asia/Krasnoyarsk';
    if(timezone == TIMEZONE_ASIA_KUALA_LUMPUR) return 'Asia/Kuala_Lumpur';
    if(timezone == TIMEZONE_ASIA_KUCHING) return 'Asia/Kuching';
    if(timezone == TIMEZONE_ASIA_KUWAIT) return 'Asia/Kuwait';
    if(timezone == TIMEZONE_ASIA_MACAO) return 'Asia/Macao';
    if(timezone == TIMEZONE_ASIA_MACAU) return 'Asia/Macau';
    if(timezone == TIMEZONE_ASIA_MAGADAN) return 'Asia/Magadan';
    if(timezone == TIMEZONE_ASIA_MAKASSAR) return 'Asia/Makassar';
    if(timezone == TIMEZONE_ASIA_MANILA) return 'Asia/Manila';
    if(timezone == TIMEZONE_ASIA_MUSCAT) return 'Asia/Muscat';
    if(timezone == TIMEZONE_ASIA_NICOSIA) return 'Asia/Nicosia';
    if(timezone == TIMEZONE_ASIA_NOVOKUZNETSK) return 'Asia/Novokuznetsk';
    if(timezone == TIMEZONE_ASIA_NOVOSIBIRSK) return 'Asia/Novosibirsk';
    if(timezone == TIMEZONE_ASIA_OMSK) return 'Asia/Omsk';
    if(timezone == TIMEZONE_ASIA_ORAL) return 'Asia/Oral';
    if(timezone == TIMEZONE_ASIA_PHNOM_PENH) return 'Asia/Phnom_Penh';
    if(timezone == TIMEZONE_ASIA_PONTIANAK) return 'Asia/Pontianak';
    if(timezone == TIMEZONE_ASIA_PYONGYANG) return 'Asia/Pyongyang';
    if(timezone == TIMEZONE_ASIA_QATAR) return 'Asia/Qatar';
    if(timezone == TIMEZONE_ASIA_QOSTANAY) return 'Asia/Qostanay';
    if(timezone == TIMEZONE_ASIA_QYZYLORDA) return 'Asia/Qyzylorda';
    if(timezone == TIMEZONE_ASIA_RANGOON) return 'Asia/Rangoon';
    if(timezone == TIMEZONE_ASIA_RIYADH) return 'Asia/Riyadh';
    if(timezone == TIMEZONE_ASIA_SAIGON) return 'Asia/Saigon';
    if(timezone == TIMEZONE_ASIA_SAKHALIN) return 'Asia/Sakhalin';
    if(timezone == TIMEZONE_ASIA_SAMARKAND) return 'Asia/Samarkand';
    if(timezone == TIMEZONE_ASIA_SEOUL) return 'Asia/Seoul';
    if(timezone == TIMEZONE_ASIA_SHANGHAI) return 'Asia/Shanghai';
    if(timezone == TIMEZONE_ASIA_SINGAPORE) return 'Asia/Singapore';
    if(timezone == TIMEZONE_ASIA_SREDNEKOLYMSK) return 'Asia/Srednekolymsk';
    if(timezone == TIMEZONE_ASIA_TAIPEI) return 'Asia/Taipei';
    if(timezone == TIMEZONE_ASIA_TASHKENT) return 'Asia/Tashkent';
    if(timezone == TIMEZONE_ASIA_TBILISI) return 'Asia/Tbilisi';
    if(timezone == TIMEZONE_ASIA_TEHRAN) return 'Asia/Tehran';
    if(timezone == TIMEZONE_ASIA_TEL_AVIV) return 'Asia/Tel_Aviv';
    if(timezone == TIMEZONE_ASIA_THIMBU) return 'Asia/Thimbu';
    if(timezone == TIMEZONE_ASIA_THIMPHU) return 'Asia/Thimphu';
    if(timezone == TIMEZONE_ASIA_TOKYO) return 'Asia/Tokyo';
    if(timezone == TIMEZONE_ASIA_TOMSK) return 'Asia/Tomsk';
    if(timezone == TIMEZONE_ASIA_UJUNG_PANDANG) return 'Asia/Ujung_Pandang';
    if(timezone == TIMEZONE_ASIA_ULAANBAATAR) return 'Asia/Ulaanbaatar';
    if(timezone == TIMEZONE_ASIA_ULAN_BATOR) return 'Asia/Ulan_Bator';
    if(timezone == TIMEZONE_ASIA_URUMQI) return 'Asia/Urumqi';
    if(timezone == TIMEZONE_ASIA_UST_NERA) return 'Asia/Ust-Nera';
    if(timezone == TIMEZONE_ASIA_VIENTIANE) return 'Asia/Vientiane';
    if(timezone == TIMEZONE_ASIA_VLADIVOSTOK) return 'Asia/Vladivostok';
    if(timezone == TIMEZONE_ASIA_YAKUTSK) return 'Asia/Yakutsk';
    if(timezone == TIMEZONE_ASIA_YANGON) return 'Asia/Yangon';
    if(timezone == TIMEZONE_ASIA_YEKATERINBURG) return 'Asia/Yekaterinburg';
    if(timezone == TIMEZONE_ASIA_YEREVAN) return 'Asia/Yerevan';
    if(timezone == TIMEZONE_ATLANTIC_AZORES) return 'Atlantic/Azores';
    if(timezone == TIMEZONE_ATLANTIC_BERMUDA) return 'Atlantic/Bermuda';
    if(timezone == TIMEZONE_ATLANTIC_CANARY) return 'Atlantic/Canary';
    if(timezone == TIMEZONE_ATLANTIC_CAPE_VERDE) return 'Atlantic/Cape_Verde';
    if(timezone == TIMEZONE_ATLANTIC_FAEROE) return 'Atlantic/Faeroe';
    if(timezone == TIMEZONE_ATLANTIC_FAROE) return 'Atlantic/Faroe';
    if(timezone == TIMEZONE_ATLANTIC_JAN_MAYEN) return 'Atlantic/Jan_Mayen';
    if(timezone == TIMEZONE_ATLANTIC_MADEIRA) return 'Atlantic/Madeira';
    if(timezone == TIMEZONE_ATLANTIC_REYKJAVIK) return 'Atlantic/Reykjavik';
    if(timezone == TIMEZONE_ATLANTIC_SOUTH_GEORGIA) return 'Atlantic/South_Georgia';
    if(timezone == TIMEZONE_ATLANTIC_ST_HELENA) return 'Atlantic/St_Helena';
    if(timezone == TIMEZONE_ATLANTIC_STANLEY) return 'Atlantic/Stanley';
    if(timezone == TIMEZONE_AUSTRALIA_ACT) return 'Australia/ACT';
    if(timezone == TIMEZONE_AUSTRALIA_ADELAIDE) return 'Australia/Adelaide';
    if(timezone == TIMEZONE_AUSTRALIA_BRISBANE) return 'Australia/Brisbane';
    if(timezone == TIMEZONE_AUSTRALIA_BROKEN_HILL) return 'Australia/Broken_Hill';
    if(timezone == TIMEZONE_AUSTRALIA_CANBERRA) return 'Australia/Canberra';
    if(timezone == TIMEZONE_AUSTRALIA_CURRIE) return 'Australia/Currie';
    if(timezone == TIMEZONE_AUSTRALIA_DARWIN) return 'Australia/Darwin';
    if(timezone == TIMEZONE_AUSTRALIA_EUCLA) return 'Australia/Eucla';
    if(timezone == TIMEZONE_AUSTRALIA_HOBART) return 'Australia/Hobart';
    if(timezone == TIMEZONE_AUSTRALIA_LHI) return 'Australia/LHI';
    if(timezone == TIMEZONE_AUSTRALIA_LINDEMAN) return 'Australia/Lindeman';
    if(timezone == TIMEZONE_AUSTRALIA_LORD_HOWE) return 'Australia/Lord_Howe';
    if(timezone == TIMEZONE_AUSTRALIA_MELBOURNE) return 'Australia/Melbourne';
    if(timezone == TIMEZONE_AUSTRALIA_NSW) return 'Australia/NSW';
    if(timezone == TIMEZONE_AUSTRALIA_NORTH) return 'Australia/North';
    if(timezone == TIMEZONE_AUSTRALIA_PERTH) return 'Australia/Perth';
    if(timezone == TIMEZONE_AUSTRALIA_QUEENSLAND) return 'Australia/Queensland';
    if(timezone == TIMEZONE_AUSTRALIA_SOUTH) return 'Australia/South';
    if(timezone == TIMEZONE_AUSTRALIA_SYDNEY) return 'Australia/Sydney';
    if(timezone == TIMEZONE_AUSTRALIA_TASMANIA) return 'Australia/Tasmania';
    if(timezone == TIMEZONE_AUSTRALIA_VICTORIA) return 'Australia/Victoria';
    if(timezone == TIMEZONE_AUSTRALIA_WEST) return 'Australia/West';
    if(timezone == TIMEZONE_AUSTRALIA_YANCOWINNA) return 'Australia/Yancowinna';
    if(timezone == TIMEZONE_BRAZIL_ACRE) return 'Brazil/Acre';
    if(timezone == TIMEZONE_BRAZIL_DENORONHA) return 'Brazil/DeNoronha';
    if(timezone == TIMEZONE_BRAZIL_EAST) return 'Brazil/East';
    if(timezone == TIMEZONE_BRAZIL_WEST) return 'Brazil/West';
    if(timezone == TIMEZONE_CET) return 'CET';
    if(timezone == TIMEZONE_CST6CDT) return 'CST6CDT';
    if(timezone == TIMEZONE_CANADA_ATLANTIC) return 'Canada/Atlantic';
    if(timezone == TIMEZONE_CANADA_CENTRAL) return 'Canada/Central';
    if(timezone == TIMEZONE_CANADA_EASTERN) return 'Canada/Eastern';
    if(timezone == TIMEZONE_CANADA_MOUNTAIN) return 'Canada/Mountain';
    if(timezone == TIMEZONE_CANADA_NEWFOUNDLAND) return 'Canada/Newfoundland';
    if(timezone == TIMEZONE_CANADA_PACIFIC) return 'Canada/Pacific';
    if(timezone == TIMEZONE_CANADA_SASKATCHEWAN) return 'Canada/Saskatchewan';
    if(timezone == TIMEZONE_CANADA_YUKON) return 'Canada/Yukon';
    if(timezone == TIMEZONE_CHILE_CONTINENTAL) return 'Chile/Continental';
    if(timezone == TIMEZONE_CHILE_EASTERISLAND) return 'Chile/EasterIsland';
    if(timezone == TIMEZONE_CUBA) return 'Cuba';
    if(timezone == TIMEZONE_EET) return 'EET';
    if(timezone == TIMEZONE_EST) return 'EST';
    if(timezone == TIMEZONE_EST5EDT) return 'EST5EDT';
    if(timezone == TIMEZONE_EGYPT) return 'Egypt';
    if(timezone == TIMEZONE_EIRE) return 'Eire';
    if(timezone == TIMEZONE_ETC_GMT) return 'Etc/GMT';
    if(timezone == TIMEZONE_ETC_GMTP0) return 'Etc/GMT+0';
    if(timezone == TIMEZONE_ETC_GMTP1) return 'Etc/GMT+1';
    if(timezone == TIMEZONE_ETC_GMTP10) return 'Etc/GMT+10';
    if(timezone == TIMEZONE_ETC_GMTP11) return 'Etc/GMT+11';
    if(timezone == TIMEZONE_ETC_GMTP12) return 'Etc/GMT+12';
    if(timezone == TIMEZONE_ETC_GMTP2) return 'Etc/GMT+2';
    if(timezone == TIMEZONE_ETC_GMTP3) return 'Etc/GMT+3';
    if(timezone == TIMEZONE_ETC_GMTP4) return 'Etc/GMT+4';
    if(timezone == TIMEZONE_ETC_GMTP5) return 'Etc/GMT+5';
    if(timezone == TIMEZONE_ETC_GMTP6) return 'Etc/GMT+6';
    if(timezone == TIMEZONE_ETC_GMTP7) return 'Etc/GMT+7';
    if(timezone == TIMEZONE_ETC_GMTP8) return 'Etc/GMT+8';
    if(timezone == TIMEZONE_ETC_GMTP9) return 'Etc/GMT+9';
    if(timezone == TIMEZONE_ETC_GMT_0) return 'Etc/GMT-0';
    if(timezone == TIMEZONE_ETC_GMT_1) return 'Etc/GMT-1';
    if(timezone == TIMEZONE_ETC_GMT_10) return 'Etc/GMT-10';
    if(timezone == TIMEZONE_ETC_GMT_11) return 'Etc/GMT-11';
    if(timezone == TIMEZONE_ETC_GMT_12) return 'Etc/GMT-12';
    if(timezone == TIMEZONE_ETC_GMT_13) return 'Etc/GMT-13';
    if(timezone == TIMEZONE_ETC_GMT_14) return 'Etc/GMT-14';
    if(timezone == TIMEZONE_ETC_GMT_2) return 'Etc/GMT-2';
    if(timezone == TIMEZONE_ETC_GMT_3) return 'Etc/GMT-3';
    if(timezone == TIMEZONE_ETC_GMT_4) return 'Etc/GMT-4';
    if(timezone == TIMEZONE_ETC_GMT_5) return 'Etc/GMT-5';
    if(timezone == TIMEZONE_ETC_GMT_6) return 'Etc/GMT-6';
    if(timezone == TIMEZONE_ETC_GMT_7) return 'Etc/GMT-7';
    if(timezone == TIMEZONE_ETC_GMT_8) return 'Etc/GMT-8';
    if(timezone == TIMEZONE_ETC_GMT_9) return 'Etc/GMT-9';
    if(timezone == TIMEZONE_ETC_GMT0) return 'Etc/GMT0';
    if(timezone == TIMEZONE_ETC_GREENWICH) return 'Etc/Greenwich';
    if(timezone == TIMEZONE_ETC_UCT) return 'Etc/UCT';
    if(timezone == TIMEZONE_ETC_UTC) return 'Etc/UTC';
    if(timezone == TIMEZONE_ETC_UNIVERSAL) return 'Etc/Universal';
    if(timezone == TIMEZONE_ETC_ZULU) return 'Etc/Zulu';
    if(timezone == TIMEZONE_EUROPE_AMSTERDAM) return 'Europe/Amsterdam';
    if(timezone == TIMEZONE_EUROPE_ANDORRA) return 'Europe/Andorra';
    if(timezone == TIMEZONE_EUROPE_ASTRAKHAN) return 'Europe/Astrakhan';
    if(timezone == TIMEZONE_EUROPE_ATHENS) return 'Europe/Athens';
    if(timezone == TIMEZONE_EUROPE_BELFAST) return 'Europe/Belfast';
    if(timezone == TIMEZONE_EUROPE_BELGRADE) return 'Europe/Belgrade';
    if(timezone == TIMEZONE_EUROPE_BERLIN) return 'Europe/Berlin';
    if(timezone == TIMEZONE_EUROPE_BRATISLAVA) return 'Europe/Bratislava';
    if(timezone == TIMEZONE_EUROPE_BRUSSELS) return 'Europe/Brussels';
    if(timezone == TIMEZONE_EUROPE_BUCHAREST) return 'Europe/Bucharest';
    if(timezone == TIMEZONE_EUROPE_BUDAPEST) return 'Europe/Budapest';
    if(timezone == TIMEZONE_EUROPE_BUSINGEN) return 'Europe/Busingen';
    if(timezone == TIMEZONE_EUROPE_CHISINAU) return 'Europe/Chisinau';
    if(timezone == TIMEZONE_EUROPE_COPENHAGEN) return 'Europe/Copenhagen';
    if(timezone == TIMEZONE_EUROPE_DUBLIN) return 'Europe/Dublin';
    if(timezone == TIMEZONE_EUROPE_GIBRALTAR) return 'Europe/Gibraltar';
    if(timezone == TIMEZONE_EUROPE_GUERNSEY) return 'Europe/Guernsey';
    if(timezone == TIMEZONE_EUROPE_HELSINKI) return 'Europe/Helsinki';
    if(timezone == TIMEZONE_EUROPE_ISLE_OF_MAN) return 'Europe/Isle_of_Man';
    if(timezone == TIMEZONE_EUROPE_ISTANBUL) return 'Europe/Istanbul';
    if(timezone == TIMEZONE_EUROPE_JERSEY) return 'Europe/Jersey';
    if(timezone == TIMEZONE_EUROPE_KALININGRAD) return 'Europe/Kaliningrad';
    if(timezone == TIMEZONE_EUROPE_KIEV) return 'Europe/Kiev';
    if(timezone == TIMEZONE_EUROPE_KIROV) return 'Europe/Kirov';
    if(timezone == TIMEZONE_EUROPE_LISBON) return 'Europe/Lisbon';
    if(timezone == TIMEZONE_EUROPE_LJUBLJANA) return 'Europe/Ljubljana';
    if(timezone == TIMEZONE_EUROPE_LONDON) return 'Europe/London';
    if(timezone == TIMEZONE_EUROPE_LUXEMBOURG) return 'Europe/Luxembourg';
    if(timezone == TIMEZONE_EUROPE_MADRID) return 'Europe/Madrid';
    if(timezone == TIMEZONE_EUROPE_MALTA) return 'Europe/Malta';
    if(timezone == TIMEZONE_EUROPE_MARIEHAMN) return 'Europe/Mariehamn';
    if(timezone == TIMEZONE_EUROPE_MINSK) return 'Europe/Minsk';
    if(timezone == TIMEZONE_EUROPE_MONACO) return 'Europe/Monaco';
    if(timezone == TIMEZONE_EUROPE_MOSCOW) return 'Europe/Moscow';
    if(timezone == TIMEZONE_EUROPE_NICOSIA) return 'Europe/Nicosia';
    if(timezone == TIMEZONE_EUROPE_OSLO) return 'Europe/Oslo';
    if(timezone == TIMEZONE_EUROPE_PARIS) return 'Europe/Paris';
    if(timezone == TIMEZONE_EUROPE_PODGORICA) return 'Europe/Podgorica';
    if(timezone == TIMEZONE_EUROPE_PRAGUE) return 'Europe/Prague';
    if(timezone == TIMEZONE_EUROPE_RIGA) return 'Europe/Riga';
    if(timezone == TIMEZONE_EUROPE_ROME) return 'Europe/Rome';
    if(timezone == TIMEZONE_EUROPE_SAMARA) return 'Europe/Samara';
    if(timezone == TIMEZONE_EUROPE_SAN_MARINO) return 'Europe/San_Marino';
    if(timezone == TIMEZONE_EUROPE_SARAJEVO) return 'Europe/Sarajevo';
    if(timezone == TIMEZONE_EUROPE_SARATOV) return 'Europe/Saratov';
    if(timezone == TIMEZONE_EUROPE_SIMFEROPOL) return 'Europe/Simferopol';
    if(timezone == TIMEZONE_EUROPE_SKOPJE) return 'Europe/Skopje';
    if(timezone == TIMEZONE_EUROPE_SOFIA) return 'Europe/Sofia';
    if(timezone == TIMEZONE_EUROPE_STOCKHOLM) return 'Europe/Stockholm';
    if(timezone == TIMEZONE_EUROPE_TALLINN) return 'Europe/Tallinn';
    if(timezone == TIMEZONE_EUROPE_TIRANE) return 'Europe/Tirane';
    if(timezone == TIMEZONE_EUROPE_TIRASPOL) return 'Europe/Tiraspol';
    if(timezone == TIMEZONE_EUROPE_ULYANOVSK) return 'Europe/Ulyanovsk';
    if(timezone == TIMEZONE_EUROPE_UZHGOROD) return 'Europe/Uzhgorod';
    if(timezone == TIMEZONE_EUROPE_VADUZ) return 'Europe/Vaduz';
    if(timezone == TIMEZONE_EUROPE_VATICAN) return 'Europe/Vatican';
    if(timezone == TIMEZONE_EUROPE_VIENNA) return 'Europe/Vienna';
    if(timezone == TIMEZONE_EUROPE_VILNIUS) return 'Europe/Vilnius';
    if(timezone == TIMEZONE_EUROPE_VOLGOGRAD) return 'Europe/Volgograd';
    if(timezone == TIMEZONE_EUROPE_WARSAW) return 'Europe/Warsaw';
    if(timezone == TIMEZONE_EUROPE_ZAGREB) return 'Europe/Zagreb';
    if(timezone == TIMEZONE_EUROPE_ZAPOROZHYE) return 'Europe/Zaporozhye';
    if(timezone == TIMEZONE_EUROPE_ZURICH) return 'Europe/Zurich';
    if(timezone == TIMEZONE_GB) return 'GB';
    if(timezone == TIMEZONE_GB_EIRE) return 'GB-Eire';
    if(timezone == TIMEZONE_GMT) return 'GMT';
    if(timezone == TIMEZONE_GMTP0) return 'GMT+0';
    if(timezone == TIMEZONE_GMT_0) return 'GMT-0';
    if(timezone == TIMEZONE_GMT0) return 'GMT0';
    if(timezone == TIMEZONE_GREENWICH) return 'Greenwich';
    if(timezone == TIMEZONE_HST) return 'HST';
    if(timezone == TIMEZONE_HONGKONG) return 'Hongkong';
    if(timezone == TIMEZONE_ICELAND) return 'Iceland';
    if(timezone == TIMEZONE_INDIAN_ANTANANARIVO) return 'Indian/Antananarivo';
    if(timezone == TIMEZONE_INDIAN_CHAGOS) return 'Indian/Chagos';
    if(timezone == TIMEZONE_INDIAN_CHRISTMAS) return 'Indian/Christmas';
    if(timezone == TIMEZONE_INDIAN_COCOS) return 'Indian/Cocos';
    if(timezone == TIMEZONE_INDIAN_COMORO) return 'Indian/Comoro';
    if(timezone == TIMEZONE_INDIAN_KERGUELEN) return 'Indian/Kerguelen';
    if(timezone == TIMEZONE_INDIAN_MAHE) return 'Indian/Mahe';
    if(timezone == TIMEZONE_INDIAN_MALDIVES) return 'Indian/Maldives';
    if(timezone == TIMEZONE_INDIAN_MAURITIUS) return 'Indian/Mauritius';
    if(timezone == TIMEZONE_INDIAN_MAYOTTE) return 'Indian/Mayotte';
    if(timezone == TIMEZONE_INDIAN_REUNION) return 'Indian/Reunion';
    if(timezone == TIMEZONE_IRAN) return 'Iran';
    if(timezone == TIMEZONE_ISRAEL) return 'Israel';
    if(timezone == TIMEZONE_JAMAICA) return 'Jamaica';
    if(timezone == TIMEZONE_JAPAN) return 'Japan';
    if(timezone == TIMEZONE_KWAJALEIN) return 'Kwajalein';
    if(timezone == TIMEZONE_LIBYA) return 'Libya';
    if(timezone == TIMEZONE_MET) return 'MET';
    if(timezone == TIMEZONE_MST) return 'MST';
    if(timezone == TIMEZONE_MST7MDT) return 'MST7MDT';
    if(timezone == TIMEZONE_MEXICO_BAJANORTE) return 'Mexico/BajaNorte';
    if(timezone == TIMEZONE_MEXICO_BAJASUR) return 'Mexico/BajaSur';
    if(timezone == TIMEZONE_MEXICO_GENERAL) return 'Mexico/General';
    if(timezone == TIMEZONE_NZ) return 'NZ';
    if(timezone == TIMEZONE_NZ_CHAT) return 'NZ-CHAT';
    if(timezone == TIMEZONE_NAVAJO) return 'Navajo';
    if(timezone == TIMEZONE_PRC) return 'PRC';
    if(timezone == TIMEZONE_PST8PDT) return 'PST8PDT';
    if(timezone == TIMEZONE_PACIFIC_APIA) return 'Pacific/Apia';
    if(timezone == TIMEZONE_PACIFIC_AUCKLAND) return 'Pacific/Auckland';
    if(timezone == TIMEZONE_PACIFIC_BOUGAINVILLE) return 'Pacific/Bougainville';
    if(timezone == TIMEZONE_PACIFIC_CHATHAM) return 'Pacific/Chatham';
    if(timezone == TIMEZONE_PACIFIC_CHUUK) return 'Pacific/Chuuk';
    if(timezone == TIMEZONE_PACIFIC_EASTER) return 'Pacific/Easter';
    if(timezone == TIMEZONE_PACIFIC_EFATE) return 'Pacific/Efate';
    if(timezone == TIMEZONE_PACIFIC_ENDERBURY) return 'Pacific/Enderbury';
    if(timezone == TIMEZONE_PACIFIC_FAKAOFO) return 'Pacific/Fakaofo';
    if(timezone == TIMEZONE_PACIFIC_FIJI) return 'Pacific/Fiji';
    if(timezone == TIMEZONE_PACIFIC_FUNAFUTI) return 'Pacific/Funafuti';
    if(timezone == TIMEZONE_PACIFIC_GALAPAGOS) return 'Pacific/Galapagos';
    if(timezone == TIMEZONE_PACIFIC_GAMBIER) return 'Pacific/Gambier';
    if(timezone == TIMEZONE_PACIFIC_GUADALCANAL) return 'Pacific/Guadalcanal';
    if(timezone == TIMEZONE_PACIFIC_GUAM) return 'Pacific/Guam';
    if(timezone == TIMEZONE_PACIFIC_HONOLULU) return 'Pacific/Honolulu';
    if(timezone == TIMEZONE_PACIFIC_JOHNSTON) return 'Pacific/Johnston';
    if(timezone == TIMEZONE_PACIFIC_KIRITIMATI) return 'Pacific/Kiritimati';
    if(timezone == TIMEZONE_PACIFIC_KOSRAE) return 'Pacific/Kosrae';
    if(timezone == TIMEZONE_PACIFIC_KWAJALEIN) return 'Pacific/Kwajalein';
    if(timezone == TIMEZONE_PACIFIC_MAJURO) return 'Pacific/Majuro';
    if(timezone == TIMEZONE_PACIFIC_MARQUESAS) return 'Pacific/Marquesas';
    if(timezone == TIMEZONE_PACIFIC_MIDWAY) return 'Pacific/Midway';
    if(timezone == TIMEZONE_PACIFIC_NAURU) return 'Pacific/Nauru';
    if(timezone == TIMEZONE_PACIFIC_NIUE) return 'Pacific/Niue';
    if(timezone == TIMEZONE_PACIFIC_NORFOLK) return 'Pacific/Norfolk';
    if(timezone == TIMEZONE_PACIFIC_NOUMEA) return 'Pacific/Noumea';
    if(timezone == TIMEZONE_PACIFIC_PAGO_PAGO) return 'Pacific/Pago_Pago';
    if(timezone == TIMEZONE_PACIFIC_PALAU) return 'Pacific/Palau';
    if(timezone == TIMEZONE_PACIFIC_PITCAIRN) return 'Pacific/Pitcairn';
    if(timezone == TIMEZONE_PACIFIC_POHNPEI) return 'Pacific/Pohnpei';
    if(timezone == TIMEZONE_PACIFIC_PONAPE) return 'Pacific/Ponape';
    if(timezone == TIMEZONE_PACIFIC_PORT_MORESBY) return 'Pacific/Port_Moresby';
    if(timezone == TIMEZONE_PACIFIC_RAROTONGA) return 'Pacific/Rarotonga';
    if(timezone == TIMEZONE_PACIFIC_SAIPAN) return 'Pacific/Saipan';
    if(timezone == TIMEZONE_PACIFIC_SAMOA) return 'Pacific/Samoa';
    if(timezone == TIMEZONE_PACIFIC_TAHITI) return 'Pacific/Tahiti';
    if(timezone == TIMEZONE_PACIFIC_TARAWA) return 'Pacific/Tarawa';
    if(timezone == TIMEZONE_PACIFIC_TONGATAPU) return 'Pacific/Tongatapu';
    if(timezone == TIMEZONE_PACIFIC_TRUK) return 'Pacific/Truk';
    if(timezone == TIMEZONE_PACIFIC_WAKE) return 'Pacific/Wake';
    if(timezone == TIMEZONE_PACIFIC_WALLIS) return 'Pacific/Wallis';
    if(timezone == TIMEZONE_PACIFIC_YAP) return 'Pacific/Yap';
    if(timezone == TIMEZONE_POLAND) return 'Poland';
    if(timezone == TIMEZONE_PORTUGAL) return 'Portugal';
    if(timezone == TIMEZONE_ROC) return 'ROC';
    if(timezone == TIMEZONE_ROK) return 'ROK';
    if(timezone == TIMEZONE_SINGAPORE) return 'Singapore';
    if(timezone == TIMEZONE_TURKEY) return 'Turkey';
    if(timezone == TIMEZONE_UCT) return 'UCT';
    if(timezone == TIMEZONE_US_ALASKA) return 'US/Alaska';
    if(timezone == TIMEZONE_US_ALEUTIAN) return 'US/Aleutian';
    if(timezone == TIMEZONE_US_ARIZONA) return 'US/Arizona';
    if(timezone == TIMEZONE_US_CENTRAL) return 'US/Central';
    if(timezone == TIMEZONE_US_EAST_INDIANA) return 'US/East-Indiana';
    if(timezone == TIMEZONE_US_EASTERN) return 'US/Eastern';
    if(timezone == TIMEZONE_US_HAWAII) return 'US/Hawaii';
    if(timezone == TIMEZONE_US_INDIANA_STARKE) return 'US/Indiana-Starke';
    if(timezone == TIMEZONE_US_MICHIGAN) return 'US/Michigan';
    if(timezone == TIMEZONE_US_MOUNTAIN) return 'US/Mountain';
    if(timezone == TIMEZONE_US_PACIFIC) return 'US/Pacific';
    if(timezone == TIMEZONE_US_SAMOA) return 'US/Samoa';
    if(timezone == TIMEZONE_UTC) return 'UTC';
    if(timezone == TIMEZONE_UNIVERSAL) return 'Universal';
    if(timezone == TIMEZONE_W_SU) return 'W-SU';
    if(timezone == TIMEZONE_WET) return 'WET';
    if(timezone == TIMEZONE_ZULU) return 'Zulu';
    return '?';
  }

  String timezone;
  int parent_id;
  Host parent;
  int admin_group_id;
  // Group admin_group;
  String location;
  String location_short;
  bool recaptcha;
  bool active;
  String languages;
  String site_suffix;

  Host.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    entity_id = j['entity_id'];
    entity = (j['entity'] == null) ? null : Entity.fromJson(j['entity']);
    key = j['key'];
    name = j['name'];
    short_name = j['short_name'];
    email_sender = j['email_sender'];
    email_info = j['email_info'];
    email_cc = j['email_cc'];
    email_support = j['email_support'];
    http = j['http'];
    https = j['https'];
    redirect_domain = j['redirect_domain'];
    google_analytics = j['google_analytics'];
    facebook_app_secret = j['facebook_app_secret'];
    facebook_page = j['facebook_page'];
    facebook_pageid = j['facebook_pageid'];
    default_state = j['default_state'];
    default_country = j['default_country'];
    timezone = j['timezone'];
    parent_id = j['parent_id'];
    parent = (j['parent'] == null) ? null : Host.fromJson(j['parent']);
    admin_group_id = j['admin_group_id'];
    location = j['location'];
    location_short = j['location_short'];
    recaptcha = j['recaptcha'];
    active = j['active'];
    languages = j['languages'];
    site_suffix = j['site_suffix'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'entity_id' : entity_id,
      'entity' : entity == null ? null : entity.toJson(),
      'key' : key,
      'name' : name,
      'short_name' : short_name,
      'email_sender' : email_sender,
      'email_info' : email_info,
      'email_cc' : email_cc,
      'email_support' : email_support,
      'http' : http,
      'https' : https,
      'redirect_domain' : redirect_domain,
      'google_analytics' : google_analytics,
      'facebook_app_secret' : facebook_app_secret,
      'facebook_page' : facebook_page,
      'facebook_pageid' : facebook_pageid,
      'default_state' : default_state,
      'default_country' : default_country,
      'timezone' : timezone,
      'parent_id' : parent_id,
      'parent' : parent == null ? null : parent.toJson(),
      'admin_group_id' : admin_group_id,
      'location' : location,
      'location_short' : location_short,
      'recaptcha' : recaptcha,
      'active' : active,
      'languages' : languages,
      'site_suffix' : site_suffix,
    };
  }

}

// <class 'event.models.RaceSeries'>
class RaceSeries {
  int id;
  int host_id;
  Host host;
  String name;
  String short;
  int current_id;
  Race current;
  int last_id;
  Race last;
  String cart_icon;

  RaceSeries.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    host_id = j['host_id'];
    host = (j['host'] == null) ? null : Host.fromJson(j['host']);
    name = j['name'];
    short = j['short'];
    current_id = j['current_id'];
    current = (j['current'] == null) ? null : Race.fromJson(j['current']);
    last_id = j['last_id'];
    last = (j['last'] == null) ? null : Race.fromJson(j['last']);
    cart_icon = j['cart_icon'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'host_id' : host_id,
      'host' : host == null ? null : host.toJson(),
      'name' : name,
      'short' : short,
      'current_id' : current_id,
      'current' : current == null ? null : current.toJson(),
      'last_id' : last_id,
      'last' : last == null ? null : last.toJson(),
      'cart_icon' : cart_icon,
    };
  }

}

// <class 'event.models.Race'>
class Race {
  int id;
  int series_id;
  RaceSeries series;
  String name;
  String short_name;
  String full_name;
  String desc;
  DateTime date;
  final int STATUS_ACTIVE = 0;
  final int STATUS_TBA = 1;
  final int STATUS_ARCHIVED = 2;
  final int STATUS_COACHING = 3;
  final int STATUS_OYO = 4;
  String get statusString {
    if(status == STATUS_ACTIVE) return 'Active';
    if(status == STATUS_TBA) return 'TBA';
    if(status == STATUS_ARCHIVED) return 'Archived';
    if(status == STATUS_COACHING) return 'Coaching';
    if(status == STATUS_OYO) return 'OYO';
    return '?';
  }

  int status;
  bool hide_date;
  String time;
  String tagline;
  DateTime registration_opens;
  DateTime cost_change1;
  DateTime cost_change2;
  DateTime cost_change3;
  DateTime cost_change4;
  DateTime cost_change5;
  DateTime registration_closes;
  String waiver;
  bool volunteer_closed;
  String volunteer_closed_message;
  String volunteer_waiver;
  double sales_tax_rate;
  String facebook_eventid;
  double facebook_discount;
  int lookup_id;
  double reg_fee;
  String reg_fee_name;
  String reg_fee_desc;
  double reg_fees_percent;
  String medical_email;
  String vendor_waiver;
  int mapp_id;
  // Mapp mapp;
  bool confirm_email;
  int klass_id;
  // Klass klass;
  String url_app_data;

  Race.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    series_id = j['series_id'];
    series = (j['series'] == null) ? null : RaceSeries.fromJson(j['series']);
    name = j['name'];
    short_name = j['short_name'];
    full_name = j['full_name'];
    desc = j['desc'];
    date = j['date'] == null ? null : DateTime.parse(j['date']);
    status = j['status'];
    hide_date = j['hide_date'];
    time = j['time'];
    tagline = j['tagline'];
    registration_opens = j['registration_opens'] == null ? null : DateTime.parse(j['registration_opens']);
    cost_change1 = j['cost_change1'] == null ? null : DateTime.parse(j['cost_change1']);
    cost_change2 = j['cost_change2'] == null ? null : DateTime.parse(j['cost_change2']);
    cost_change3 = j['cost_change3'] == null ? null : DateTime.parse(j['cost_change3']);
    cost_change4 = j['cost_change4'] == null ? null : DateTime.parse(j['cost_change4']);
    cost_change5 = j['cost_change5'] == null ? null : DateTime.parse(j['cost_change5']);
    registration_closes = j['registration_closes'] == null ? null : DateTime.parse(j['registration_closes']);
    waiver = j['waiver'];
    volunteer_closed = j['volunteer_closed'];
    volunteer_closed_message = j['volunteer_closed_message'];
    volunteer_waiver = j['volunteer_waiver'];
    sales_tax_rate = j['sales_tax_rate'];
    facebook_eventid = j['facebook_eventid'];
    facebook_discount = j['facebook_discount'];
    lookup_id = j['lookup_id'];
    reg_fee = j['reg_fee'];
    reg_fee_name = j['reg_fee_name'];
    reg_fee_desc = j['reg_fee_desc'];
    reg_fees_percent = j['reg_fees_percent'];
    medical_email = j['medical_email'];
    vendor_waiver = j['vendor_waiver'];
    mapp_id = j['mapp_id'];
    confirm_email = j['confirm_email'];
    klass_id = j['klass_id'];
    url_app_data = j['url_app_data'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'series_id' : series_id,
      'series' : series == null ? null : series.toJson(),
      'name' : name,
      'short_name' : short_name,
      'full_name' : full_name,
      'desc' : desc,
      'date' : date.toString(),
      'status' : status,
      'hide_date' : hide_date,
      'time' : time,
      'tagline' : tagline,
      'registration_opens' : registration_opens.toString(),
      'cost_change1' : cost_change1.toString(),
      'cost_change2' : cost_change2.toString(),
      'cost_change3' : cost_change3.toString(),
      'cost_change4' : cost_change4.toString(),
      'cost_change5' : cost_change5.toString(),
      'registration_closes' : registration_closes.toString(),
      'waiver' : waiver,
      'volunteer_closed' : volunteer_closed,
      'volunteer_closed_message' : volunteer_closed_message,
      'volunteer_waiver' : volunteer_waiver,
      'sales_tax_rate' : sales_tax_rate,
      'facebook_eventid' : facebook_eventid,
      'facebook_discount' : facebook_discount,
      'lookup_id' : lookup_id,
      'reg_fee' : reg_fee,
      'reg_fee_name' : reg_fee_name,
      'reg_fee_desc' : reg_fee_desc,
      'reg_fees_percent' : reg_fees_percent,
      'medical_email' : medical_email,
      'vendor_waiver' : vendor_waiver,
      'mapp_id' : mapp_id,
      'confirm_email' : confirm_email,
      'klass_id' : klass_id,
      'url_app_data' : url_app_data,
    };
  }


bool get isOYO => status == STATUS_OYO;
  String get getName => "${series?.name}${name.isEmpty ? '' : ' ' + name}";
}

// <class 'event.models.Event'>
class Event {
  int id;
  String name;
  String abbrev;
  double dist_miles;

  Event.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    name = j['name'];
    abbrev = j['abbrev'];
    dist_miles = j['dist_miles'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name' : name,
      'abbrev' : abbrev,
      'dist_miles' : dist_miles,
    };
  }

}

// <class 'event.models.RaceEvent'>
class RaceEvent {
  int id;
  int race_id;
  Race race;
  int event_id;
  Event event;
  int state;
  String name;
  int order;
  final int TYPE_RUNNING = 1;
  final int TYPE_CYCLING = 2;
  String get typeString {
    if(type == TYPE_RUNNING) return 'Running';
    if(type == TYPE_CYCLING) return 'Cycling';
    return '?';
  }

  int type;
  String start_time;
  int cap;
  int num_reg;
  int bib_start;
  int bib_max;
  bool sold_out;
  bool waitlist_when_soldout;
  Amount cost0;
  Amount cost1;
  Amount cost2;
  Amount cost3;
  Amount cost4;
  Amount cost5;
  int youth_age;
  Amount youth_cost0;
  Amount youth_cost1;
  Amount youth_cost2;
  Amount youth_cost3;
  Amount youth_cost4;
  Amount youth_cost5;
  String waiver;
  String cert_number;
  int finish_count;
  int finish_count_male;
  int finish_count_female;
  bool no_facebook_discount;
  final int DIST_UNITS_MILES = 0;
  final int DIST_UNITS_KM = 1;
  String get dist_unitsString {
    if(dist_units == DIST_UNITS_MILES) return 'miles';
    if(dist_units == DIST_UNITS_KM) return 'km';
    return '?';
  }

  int dist_units;
  final int PACE_UNITS_MIN_MILE = 0;
  final int PACE_UNITS_MPH = 1;
  String get pace_unitsString {
    if(pace_units == PACE_UNITS_MIN_MILE) return 'min/mile';
    if(pace_units == PACE_UNITS_MPH) return 'mph';
    return '?';
  }

  int pace_units;
  int group_number;
  String help_text;
  String parking_address;
  int path_id;
  // Path path;
  DateTime date;

  RaceEvent.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    race_id = j['race_id'];
    race = (j['race'] == null) ? null : Race.fromJson(j['race']);
    event_id = j['event_id'];
    event = (j['event'] == null) ? null : Event.fromJson(j['event']);
    state = j['state'];
    name = j['name'];
    order = j['order'];
    type = j['type'];
    start_time = j['start_time'];
    cap = j['cap'];
    num_reg = j['num_reg'];
    bib_start = j['bib_start'];
    bib_max = j['bib_max'];
    sold_out = j['sold_out'];
    waitlist_when_soldout = j['waitlist_when_soldout'];
    cost0 = Amount.fromDouble(j['cost0'], 'USD');
    cost1 = Amount.fromDouble(j['cost1'], 'USD');
    cost2 = Amount.fromDouble(j['cost2'], 'USD');
    cost3 = Amount.fromDouble(j['cost3'], 'USD');
    cost4 = Amount.fromDouble(j['cost4'], 'USD');
    cost5 = Amount.fromDouble(j['cost5'], 'USD');
    youth_age = j['youth_age'];
    youth_cost0 = Amount.fromDouble(j['youth_cost0'], 'USD');
    youth_cost1 = Amount.fromDouble(j['youth_cost1'], 'USD');
    youth_cost2 = Amount.fromDouble(j['youth_cost2'], 'USD');
    youth_cost3 = Amount.fromDouble(j['youth_cost3'], 'USD');
    youth_cost4 = Amount.fromDouble(j['youth_cost4'], 'USD');
    youth_cost5 = Amount.fromDouble(j['youth_cost5'], 'USD');
    waiver = j['waiver'];
    cert_number = j['cert_number'];
    finish_count = j['finish_count'];
    finish_count_male = j['finish_count_male'];
    finish_count_female = j['finish_count_female'];
    no_facebook_discount = j['no_facebook_discount'];
    dist_units = j['dist_units'];
    pace_units = j['pace_units'];
    group_number = j['group_number'];
    help_text = j['help_text'];
    parking_address = j['parking_address'];
    path_id = j['path_id'];
    date = j['date'] == null ? null : DateTime.parse(j['date']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'race_id' : race_id,
      'race' : race == null ? null : race.toJson(),
      'event_id' : event_id,
      'event' : event == null ? null : event.toJson(),
      'state' : state,
      'name' : name,
      'order' : order,
      'type' : type,
      'start_time' : start_time,
      'cap' : cap,
      'num_reg' : num_reg,
      'bib_start' : bib_start,
      'bib_max' : bib_max,
      'sold_out' : sold_out,
      'waitlist_when_soldout' : waitlist_when_soldout,
      'cost0' : cost0,
      'cost1' : cost1,
      'cost2' : cost2,
      'cost3' : cost3,
      'cost4' : cost4,
      'cost5' : cost5,
      'youth_age' : youth_age,
      'youth_cost0' : youth_cost0,
      'youth_cost1' : youth_cost1,
      'youth_cost2' : youth_cost2,
      'youth_cost3' : youth_cost3,
      'youth_cost4' : youth_cost4,
      'youth_cost5' : youth_cost5,
      'waiver' : waiver,
      'cert_number' : cert_number,
      'finish_count' : finish_count,
      'finish_count_male' : finish_count_male,
      'finish_count_female' : finish_count_female,
      'no_facebook_discount' : no_facebook_discount,
      'dist_units' : dist_units,
      'pace_units' : pace_units,
      'group_number' : group_number,
      'help_text' : help_text,
      'parking_address' : parking_address,
      'path_id' : path_id,
      'date' : date.toString(),
    };
  }

}

// <class 'event.models.Wave'>
class Wave {
  int id;
  int race_event_id;
  RaceEvent race_event;
  String name;
  int max_number;
  int order;
  String bus_instructions;
  String notes;
  double start_time;

  Wave.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    race_event_id = j['race_event_id'];
    race_event = (j['race_event'] == null) ? null : RaceEvent.fromJson(j['race_event']);
    name = j['name'];
    max_number = j['max_number'];
    order = j['order'];
    bus_instructions = j['bus_instructions'];
    notes = j['notes'];
    start_time = j['start_time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'race_event_id' : race_event_id,
      'race_event' : race_event == null ? null : race_event.toJson(),
      'name' : name,
      'max_number' : max_number,
      'order' : order,
      'bus_instructions' : bus_instructions,
      'notes' : notes,
      'start_time' : start_time,
    };
  }

}

// <class 'event.models.Participant'>
class Participant {
  int id;
  int line_item_id;
  // LineItem line_item;
  int race_event_id;
  RaceEvent race_event;
  String firstname;
  String lastname;
  String email;
  String phone;
  String address;
  String city;
  String state;
  String country;
  String zip;
  String gender;
  DateTime birthday;
  double lat;
  double lon;
  int age;
  int bib;
  String emergencyname;
  String emergencyphone;
  int wave_id;
  Wave wave;
  bool withdrawn;
  bool checkedin;
  DateTime checkedin_date;
  int withdrawn_line_item_id;
  // LineItem withdrawn_line_item;
  String external_id;
  int user_id;
  MyUser user;
  String slug;
  DateTime timestamp;
  String referer;
  bool hide_results;
  String tag;
  final int STATUS_SIGNED_UP = 0;
  final int STATUS_BIB_CHECKED = 1;
  final int STATUS_RUNNING = 2;
  final int STATUS_FINISHED = 3;
  final int STATUS_VERIFIED = 4;
  final int STATUS_DNF = 5;
  final int STATUS_DQ = 6;
  final int STATUS_DNS = 7;
  String get statusString {
    if(status == STATUS_SIGNED_UP) return 'Signed Up';
    if(status == STATUS_BIB_CHECKED) return 'Bib Checked';
    if(status == STATUS_RUNNING) return 'Running';
    if(status == STATUS_FINISHED) return 'Finished';
    if(status == STATUS_VERIFIED) return 'Verified';
    if(status == STATUS_DNF) return 'DNF';
    if(status == STATUS_DQ) return 'DQ';
    if(status == STATUS_DNS) return 'DNS';
    return '?';
  }

  int status;

  Participant.fromJson(Map<String, dynamic> j) {
    id = j['id'];
    line_item_id = j['line_item_id'];
    race_event_id = j['race_event_id'];
    race_event = (j['race_event'] == null) ? null : RaceEvent.fromJson(j['race_event']);
    firstname = j['firstname'];
    lastname = j['lastname'];
    email = j['email'];
    phone = j['phone'];
    address = j['address'];
    city = j['city'];
    state = j['state'];
    country = j['country'];
    zip = j['zip'];
    gender = j['gender'];
    birthday = j['birthday'] == null ? null : DateTime.parse(j['birthday']);
    lat = j['lat'];
    lon = j['lon'];
    age = j['age'];
    bib = j['bib'];
    emergencyname = j['emergencyname'];
    emergencyphone = j['emergencyphone'];
    wave_id = j['wave_id'];
    wave = (j['wave'] == null) ? null : Wave.fromJson(j['wave']);
    withdrawn = j['withdrawn'];
    checkedin = j['checkedin'];
    checkedin_date = j['checkedin_date'] == null ? null : DateTime.parse(j['checkedin_date']);
    withdrawn_line_item_id = j['withdrawn_line_item_id'];
    external_id = j['external_id'];
    user_id = j['user_id'];
    user = (j['user'] == null) ? null : MyUser.fromJson(j['user']);
    slug = j['slug'];
    timestamp = j['timestamp'] == null ? null : DateTime.parse(j['timestamp']);
    referer = j['referer'];
    hide_results = j['hide_results'];
    tag = j['tag'];
    status = j['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'line_item_id' : line_item_id,
      'race_event_id' : race_event_id,
      'race_event' : race_event == null ? null : race_event.toJson(),
      'firstname' : firstname,
      'lastname' : lastname,
      'email' : email,
      'phone' : phone,
      'address' : address,
      'city' : city,
      'state' : state,
      'country' : country,
      'zip' : zip,
      'gender' : gender,
      'birthday' : birthday.toString(),
      'lat' : lat,
      'lon' : lon,
      'age' : age,
      'bib' : bib,
      'emergencyname' : emergencyname,
      'emergencyphone' : emergencyphone,
      'wave_id' : wave_id,
      'wave' : wave == null ? null : wave.toJson(),
      'withdrawn' : withdrawn,
      'checkedin' : checkedin,
      'checkedin_date' : checkedin_date.toString(),
      'withdrawn_line_item_id' : withdrawn_line_item_id,
      'external_id' : external_id,
      'user_id' : user_id,
      'user' : user == null ? null : user.toJson(),
      'slug' : slug,
      'timestamp' : timestamp.toString(),
      'referer' : referer,
      'hide_results' : hide_results,
      'tag' : tag,
      'status' : status,
    };
  }


int tagt;
  String get name => "${firstname} ${lastname}";

}

class Amount {
int amt;
  String currency;
  Amount(this.amt, this.currency);
  Amount.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    amt = json['amt'];
  }
  Amount.fromDouble(double x, String currency) {
    this.currency = currency;
    if(x == null) {
      amt = 0;
    } else if(currency == 'USD') {
      amt = (x*100).round();
    } else {
      amt = x.toInt();
    }
  }

  Map<String, dynamic> toJson() {
    return { "amt": amt, "currency": currency };
  }

  String display({int qty: 1, bool bare: false}) {
    int amt_ = amt * qty;
    if('USD' == this.currency) {
      double x = amt_/100.0;
      if(bare) {
        return "${NumberFormat("####0.00", "en_US").format(x)}";
      } else {
        return "\$${NumberFormat("#,##0.00", "en_US").format(x)}";
      }
    } else {
      return "${amt_}";
    }
  }

  String toString() {
    return display();
  }
}

