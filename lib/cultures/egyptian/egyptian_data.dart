class EgyptianData {
  // 36 decans of the Egyptian sky (10° each, starting from 0° Aries)
  static const List<Map<String, String>> decans = [
    // Aries
    {'deity': 'Aries I — Aries Decan 1', 'sign': 'Aries', 'decanNum': '1', 'quality': 'Bold initiator, pioneer spirit', 'mythology': 'Ram of Amun, creative force of spring', 'protector': 'Khnum'},
    {'deity': 'Axis Mundi', 'sign': 'Aries', 'decanNum': '2', 'quality': 'Connecting heaven and earth', 'mythology': 'The cosmic pillar holding sky aloft', 'protector': 'Shu'},
    {'deity': 'Kenmy', 'sign': 'Aries', 'decanNum': '3', 'quality': 'Harvest and abundance', 'mythology': 'Grain god of the Delta', 'protector': 'Osiris'},
    // Taurus
    {'deity': 'Apis Bull', 'sign': 'Taurus', 'decanNum': '1', 'quality': 'Sacred strength, earthly royalty', 'mythology': 'The Apis bull carried the soul of Ptah', 'protector': 'Ptah'},
    {'deity': 'Khont-Khre', 'sign': 'Taurus', 'decanNum': '2', 'quality': 'Sensory gifts, material beauty', 'mythology': 'Lord of earthly pleasures and beauty', 'protector': 'Hathor'},
    {'deity': 'Sat-Hor', 'sign': 'Taurus', 'decanNum': '3', 'quality': 'Daughter of Horus, protection', 'mythology': 'Guardian of the Osirian rite', 'protector': 'Horus'},
    // Gemini
    {'deity': 'Shu & Tefnut', 'sign': 'Gemini', 'decanNum': '1', 'quality': 'Air and moisture, the first twins', 'mythology': 'The primordial pair breathed by Atum', 'protector': 'Atum'},
    {'deity': 'Sia', 'sign': 'Gemini', 'decanNum': '2', 'quality': 'Divine perception, intelligence', 'mythology': 'Personification of the god\'s perception', 'protector': 'Thoth'},
    {'deity': 'Hu', 'sign': 'Gemini', 'decanNum': '3', 'quality': 'Sacred utterance, creative word', 'mythology': 'The first word spoken at creation', 'protector': 'Thoth'},
    // Cancer
    {'deity': 'Khepri', 'sign': 'Cancer', 'decanNum': '1', 'quality': 'Self-creation, transformation', 'mythology': 'The scarab god who rolls the sun at dawn', 'protector': 'Ra'},
    {'deity': 'Mut', 'sign': 'Cancer', 'decanNum': '2', 'quality': 'Divine mother, cosmic protection', 'mythology': 'Mother goddess who holds all things', 'protector': 'Mut'},
    {'deity': 'Neith', 'sign': 'Cancer', 'decanNum': '3', 'quality': 'Weaver of destiny, warrior wisdom', 'mythology': 'The weaver of the cosmos and war goddess', 'protector': 'Neith'},
    // Leo
    {'deity': 'Ra-Harakhty', 'sign': 'Leo', 'decanNum': '1', 'quality': 'Solar majesty, peak power', 'mythology': 'Horus of the horizon, the midday sun', 'protector': 'Ra'},
    {'deity': 'Sekhmet', 'sign': 'Leo', 'decanNum': '2', 'quality': 'Fierce healing, righteous wrath', 'mythology': 'The lioness whose breath caused the desert wind', 'protector': 'Sekhmet'},
    {'deity': 'Bastet', 'sign': 'Leo', 'decanNum': '3', 'quality': 'Playful protection, domestic grace', 'mythology': 'Cat goddess of home, music, and protective love', 'protector': 'Bastet'},
    // Virgo
    {'deity': 'Isis', 'sign': 'Virgo', 'decanNum': '1', 'quality': 'Magic, devotion, cosmic weaving', 'mythology': 'The great mother who gathered Osiris whole', 'protector': 'Isis'},
    {'deity': 'Maat', 'sign': 'Virgo', 'decanNum': '2', 'quality': 'Truth, justice, divine order', 'mythology': 'Her feather weighed against the heart of the dead', 'protector': 'Maat'},
    {'deity': 'Anubis', 'sign': 'Virgo', 'decanNum': '3', 'quality': 'Sacred service, passage-guiding', 'mythology': 'Jackal guardian of the embalming rite', 'protector': 'Anubis'},
    // Libra
    {'deity': 'Thoth', 'sign': 'Libra', 'decanNum': '1', 'quality': 'Wisdom, record-keeping, balance', 'mythology': 'Scribe of the gods, inventor of writing', 'protector': 'Thoth'},
    {'deity': 'Wepwawet', 'sign': 'Libra', 'decanNum': '2', 'quality': 'Path-opening, diplomatic grace', 'mythology': 'The wolf who opens the way for royalty', 'protector': 'Wepwawet'},
    {'deity': 'Sobek', 'sign': 'Libra', 'decanNum': '3', 'quality': 'Fertile power, adaptability', 'mythology': 'Crocodile god of the fertile Nile', 'protector': 'Sobek'},
    // Scorpio
    {'deity': 'Set', 'sign': 'Scorpio', 'decanNum': '1', 'quality': 'Storm, chaos as necessary force', 'mythology': 'Lord of the red land and necessary darkness', 'protector': 'Set'},
    {'deity': 'Serket', 'sign': 'Scorpio', 'decanNum': '2', 'quality': 'Scorpion venom as healing', 'mythology': 'She who heals the sting of scorpion and snake', 'protector': 'Serket'},
    {'deity': 'Selene/Khonsu', 'sign': 'Scorpio', 'decanNum': '3', 'quality': 'Lunar depth, hidden currents', 'mythology': 'Moon god who heals and traverses the night sky', 'protector': 'Khonsu'},
    // Sagittarius
    {'deity': 'Satis', 'sign': 'Sagittarius', 'decanNum': '1', 'quality': 'Inundation, far-reaching aim', 'mythology': 'Goddess who pours the Nile\'s annual flood', 'protector': 'Satis'},
    {'deity': 'Anuket', 'sign': 'Sagittarius', 'decanNum': '2', 'quality': 'Freedom, swift current', 'mythology': 'The rushing cataracts of the Nile', 'protector': 'Anuket'},
    {'deity': 'Heket', 'sign': 'Sagittarius', 'decanNum': '3', 'quality': 'Transformation, new life', 'mythology': 'Frog goddess present at every birth', 'protector': 'Heket'},
    // Capricorn
    {'deity': 'Geb', 'sign': 'Capricorn', 'decanNum': '1', 'quality': 'Earth father, patient endurance', 'mythology': 'The earth god whose laughter causes earthquakes', 'protector': 'Geb'},
    {'deity': 'Aker', 'sign': 'Capricorn', 'decanNum': '2', 'quality': 'Horizon keeper, dual guardian', 'mythology': 'Two lions guarding yesterday and tomorrow', 'protector': 'Aker'},
    {'deity': 'Osiris Risen', 'sign': 'Capricorn', 'decanNum': '3', 'quality': 'Resurrection, kingly patience', 'mythology': 'Osiris as king of the dead who grants eternal life', 'protector': 'Osiris'},
    // Aquarius
    {'deity': 'Hapi', 'sign': 'Aquarius', 'decanNum': '1', 'quality': 'Nile flood, communal abundance', 'mythology': 'The god of the annual Nile inundation', 'protector': 'Hapi'},
    {'deity': 'Nuit', 'sign': 'Aquarius', 'decanNum': '2', 'quality': 'Star body, infinite embrace', 'mythology': 'The sky goddess arched over the earth', 'protector': 'Nut'},
    {'deity': 'Seba', 'sign': 'Aquarius', 'decanNum': '3', 'quality': 'Stars as souls, cosmic vision', 'mythology': 'The star god, spirits of the glorified dead', 'protector': 'Thoth'},
    // Pisces
    {'deity': 'Nun', 'sign': 'Pisces', 'decanNum': '1', 'quality': 'Primordial waters, dissolution', 'mythology': 'The inert void from which Ra first rose', 'protector': 'Nun'},
    {'deity': 'Naunet', 'sign': 'Pisces', 'decanNum': '2', 'quality': 'Feminine void, dreaming depth', 'mythology': 'Consort of Nun, the counterpart abyss', 'protector': 'Naunet'},
    {'deity': 'Nehebkau', 'sign': 'Pisces', 'decanNum': '3', 'quality': 'Serpent of protection, completion', 'mythology': 'The snake who binds the two parts of the soul', 'protector': 'Nehebkau'},
  ];
}
