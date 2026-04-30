class ChineseData {
  static const List<String> stems = [
    'Jiǎ (甲)', 'Yǐ (乙)', 'Bǐng (丙)', 'Dīng (丁)', 'Wù (戊)',
    'Jǐ (己)', 'Gēng (庚)', 'Xīn (辛)', 'Rén (壬)', 'Guǐ (癸)',
  ];

  static const List<String> branches = [
    'Zǐ (子)', 'Chǒu (丑)', 'Yín (寅)', 'Mǎo (卯)', 'Chén (辰)', 'Sì (巳)',
    'Wǔ (午)', 'Wèi (未)', 'Shēn (申)', 'Yǒu (酉)', 'Xū (戌)', 'Hài (亥)',
  ];

  static const List<String> elements = ['Wood', 'Fire', 'Earth', 'Metal', 'Water'];

  static const List<Map<String, dynamic>> animals = [
    {
      'name': 'Rat', 'chinese': '鼠',
      'keywords': 'resourceful, quick-witted, adaptable',
      'description': 'The Rat opens the cycle — quick, charming, and a master of turning scarcity into opportunity.',
      'compatible': ['Dragon', 'Monkey', 'Ox'],
      'luckyColors': ['Blue', 'Gold', 'Green'],
    },
    {
      'name': 'Ox', 'chinese': '牛',
      'keywords': 'diligent, dependable, patient',
      'description': 'The Ox carries life forward with quiet strength, unwavering reliability, and careful judgment.',
      'compatible': ['Rat', 'Snake', 'Rooster'],
      'luckyColors': ['White', 'Yellow', 'Green'],
    },
    {
      'name': 'Tiger', 'chinese': '虎',
      'keywords': 'courageous, magnetic, unpredictable',
      'description': 'The Tiger commands respect and loves a challenge — bold, generous, and intensely alive.',
      'compatible': ['Horse', 'Dog', 'Pig'],
      'luckyColors': ['Blue', 'Grey', 'Orange'],
    },
    {
      'name': 'Rabbit', 'chinese': '兔',
      'keywords': 'gentle, intuitive, gracious',
      'description': 'The Rabbit moves through the world with elegance, sensing nuance that others miss.',
      'compatible': ['Sheep', 'Pig', 'Dog'],
      'luckyColors': ['Red', 'Pink', 'Purple'],
    },
    {
      'name': 'Dragon', 'chinese': '龍',
      'keywords': 'majestic, inspired, visionary',
      'description': 'The Dragon is the only mythic animal — rare, auspicious, and born to lead with fire.',
      'compatible': ['Rat', 'Monkey', 'Rooster'],
      'luckyColors': ['Gold', 'Silver', 'Grey'],
    },
    {
      'name': 'Snake', 'chinese': '蛇',
      'keywords': 'wise, perceptive, enigmatic',
      'description': 'The Snake trusts its deep instincts and reveals itself only to those it deems worthy.',
      'compatible': ['Ox', 'Rooster', 'Monkey'],
      'luckyColors': ['Black', 'Red', 'Yellow'],
    },
    {
      'name': 'Horse', 'chinese': '馬',
      'keywords': 'free-spirited, energetic, passionate',
      'description': 'The Horse gallops toward adventure, allergic to confinement and naturally charismatic.',
      'compatible': ['Tiger', 'Dog', 'Sheep'],
      'luckyColors': ['Yellow', 'Green', 'Red'],
    },
    {
      'name': 'Sheep', 'chinese': '羊',
      'keywords': 'artistic, empathetic, gentle',
      'description': 'The Sheep creates beauty from within, offering warmth and a refined aesthetic sense.',
      'compatible': ['Rabbit', 'Horse', 'Pig'],
      'luckyColors': ['Brown', 'Red', 'Purple'],
    },
    {
      'name': 'Monkey', 'chinese': '猴',
      'keywords': 'clever, inventive, mischievous',
      'description': 'The Monkey delights in wit, improvisations, and solving problems with unexpected flair.',
      'compatible': ['Rat', 'Dragon', 'Snake'],
      'luckyColors': ['White', 'Blue', 'Gold'],
    },
    {
      'name': 'Rooster', 'chinese': '雞',
      'keywords': 'meticulous, observant, courageous',
      'description': 'The Rooster watches carefully and speaks clearly — loyal to truth and unafraid of conflict.',
      'compatible': ['Ox', 'Snake', 'Dragon'],
      'luckyColors': ['Gold', 'Brown', 'Yellow'],
    },
    {
      'name': 'Dog', 'chinese': '狗',
      'keywords': 'loyal, honest, protective',
      'description': 'The Dog stands watch — faithful, principled, and quick to defend what it loves.',
      'compatible': ['Tiger', 'Horse', 'Rabbit'],
      'luckyColors': ['Red', 'Green', 'Purple'],
    },
    {
      'name': 'Pig', 'chinese': '豬',
      'keywords': 'sincere, generous, diligent',
      'description': 'The Pig closes the cycle with wholehearted generosity, sincerity, and a love of pleasure.',
      'compatible': ['Tiger', 'Rabbit', 'Sheep'],
      'luckyColors': ['Yellow', 'Grey', 'Brown'],
    },
  ];
}
