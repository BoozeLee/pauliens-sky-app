class CelticData {
  static const Map<String, Map<String, String>> trees = {
    'Birch': {
      'tree': 'Birch', 'deity': 'The Lady', 'element': 'Air',
      'keywords': 'new beginnings, renewal, cleansing, brave pioneering',
      'description': 'The Birch is the first tree of the year — a pioneer that colonizes bare land and makes way for other life.',
    },
    'Rowan': {
      'tree': 'Rowan', 'deity': 'Brigid', 'element': 'Fire',
      'keywords': 'protection, vision, quickening, inspired perception',
      'description': 'The Rowan guards the threshold — its red berries are protective charms against malevolent forces.',
    },
    'Ash': {
      'tree': 'Ash', 'deity': 'Lugh', 'element': 'Water',
      'keywords': 'world tree, interconnection, intuition, adaptability',
      'description': 'The Ash is Yggdrasil — the world tree whose roots reach the underworld and branches the heavens.',
    },
    'Alder': {
      'tree': 'Alder', 'deity': 'Bran', 'element': 'Fire',
      'keywords': 'courage, steadfastness, bridge-building, power',
      'description': 'The Alder bridges land and water, never rotting when submerged — a symbol of enduring strength.',
    },
    'Willow': {
      'tree': 'Willow', 'deity': 'Ceridwen', 'element': 'Water',
      'keywords': 'intuition, dreams, lunar wisdom, emotional depth',
      'description': 'The Willow bends without breaking and grows near water — the tree of moon magic and deep feeling.',
    },
    'Hawthorn': {
      'tree': 'Hawthorn', 'deity': 'The Green Man', 'element': 'Fire',
      'keywords': 'fertility, contrast, sacred boundary, hope',
      'description': 'The Hawthorn guards the boundary between worlds and blooms at Beltane — joy and thorns together.',
    },
    'Oak': {
      'tree': 'Oak', 'deity': 'Dagda', 'element': 'Fire',
      'keywords': 'sovereignty, strength, wisdom, the Druid\'s sacred tree',
      'description': 'The Oak is king of the forest — the Druids\' most sacred tree, a door between the worlds.',
    },
    'Holly': {
      'tree': 'Holly', 'deity': 'The Holly King', 'element': 'Fire',
      'keywords': 'protection, sacrifice, battle, undying life',
      'description': 'The Holly stays green when all others fade — the warrior\'s tree, evergreen and unyielding.',
    },
    'Hazel': {
      'tree': 'Hazel', 'deity': 'Ogma', 'element': 'Air',
      'keywords': 'wisdom, inspiration, poetry, sacred knowledge',
      'description': 'The Hazel drops nuts into the salmon\'s pool — whoever ate the salmon gained all wisdom.',
    },
    'Vine': {
      'tree': 'Vine', 'deity': 'Mabon', 'element': 'Water',
      'keywords': 'harvest, prophecy, emotional intensity, transformation',
      'description': 'The Vine bears prophecy in its fruit — the grape that ferments into divine revelation.',
    },
    'Ivy': {
      'tree': 'Ivy', 'deity': 'The Spiral Goddess', 'element': 'Water',
      'keywords': 'tenacity, the spiral path, labyrinth, inner journey',
      'description': 'Ivy spirals over walls and ancient stone — the soul\'s journey through the labyrinth of self.',
    },
    'Reed': {
      'tree': 'Reed', 'deity': 'The Morrígan', 'element': 'Water',
      'keywords': 'purpose, destiny, ancestral guidance, writing',
      'description': 'The Reed was cut to make the first flute — a voice for the dead, a keeper of memory.',
    },
    'Elder': {
      'tree': 'Elder', 'deity': 'The Crone', 'element': 'Water',
      'keywords': 'endings, regeneration, elder wisdom, the death that heals',
      'description': 'The Elder is the last tree month — the Crone\'s tree, connecting the dying year to its rebirth.',
    },
  };

  static const Map<String, String> ogham = {
    'Birch': 'ᚁ (Beith)', 'Rowan': 'ᚂ (Luis)', 'Ash': 'ᚅ (Nion)',
    'Alder': 'ᚃ (Fearn)', 'Willow': 'ᚄ (Sail)', 'Hawthorn': 'ᚆ (Huath)',
    'Oak': 'ᚇ (Dair)', 'Holly': 'ᚈ (Tinne)', 'Hazel': 'ᚉ (Coll)',
    'Vine': 'ᚊ (Quert)', 'Ivy': 'ᚌ (Gort)', 'Reed': 'ᚍ (Ngetal)',
    'Elder': 'ᚏ (Ruis)',
  };

  static const List<Map<String, String>> animals = [
    {'animal': 'Stag', 'keywords': 'nobility, independence, pride', 'description': 'The stag carries the antlered crown — king of the forest and symbol of the Wild Hunt.'},
    {'animal': 'Cat', 'keywords': 'mystery, magic, independence', 'description': 'The cat moves between worlds, seeing what others cannot in darkness and dawn.'},
    {'animal': 'Snake', 'keywords': 'wisdom, rebirth, primal earth', 'description': 'The snake sheds its skin — Celtic emblem of regeneration and hidden wisdom.'},
    {'animal': 'Fox', 'keywords': 'cunning, adaptability, strategy', 'description': 'The fox navigates forest and field with nimble intelligence and sharp instinct.'},
    {'animal': 'Bull', 'keywords': 'strength, fertility, sovereignty', 'description': 'The great bull of Celtic legend — his power defines the king\'s right to rule.'},
    {'animal': 'Seahorse', 'keywords': 'courage, grace, tenacity', 'description': 'The seahorse navigates turbulent seas — smaller than the storm but equal to it.'},
    {'animal': 'Wren', 'keywords': 'humility, cleverness, resourcefulness', 'description': 'The tiny wren outwitted the eagle and became king of all birds in Celtic lore.'},
    {'animal': 'Horse', 'keywords': 'freedom, travel, sovereignty', 'description': 'Epona\'s horse carries the soul across boundaries, a goddess\'s steed between worlds.'},
    {'animal': 'Salmon', 'keywords': 'wisdom, inspiration, return', 'description': 'The salmon of knowledge swam in Segais Well — eating it granted all wisdom at once.'},
    {'animal': 'Swan', 'keywords': 'love, transformation, soul', 'description': 'Celtic lovers transformed into swans — the bird of the otherworld journey.'},
    {'animal': 'Butterfly', 'keywords': 'transformation, joy, ancestors', 'description': 'Butterflies are the souls of the dead visiting the living, bringing messages of love.'},
    {'animal': 'Wolf', 'keywords': 'loyalty, teaching, the pack', 'description': 'The wolf runs with the Otherworld Hunt — fierce protector and keeper of sacred bonds.'},
    {'animal': 'Crow', 'keywords': 'prophecy, change, cunning', 'description': 'The Morrígan\'s crow brings warning and wisdom from the border of life and death.'},
  ];
}
