/// Parses raw model labels like "Strawberry___Leaf_scorch" or
/// "Tomato___Early_blight" (the common PlantVillage-dataset format) into a
/// readable crop name + condition name, and looks up generic symptoms /
/// recommended actions by keyword — so it works for ANY label your model
/// outputs, not just a couple of hardcoded exact strings.
class DiseaseDisplay {
  final String crop;
  final String condition;
  final bool isHealthy;
  DiseaseDisplay({required this.crop, required this.condition, required this.isHealthy});
}

DiseaseDisplay parseDiseaseLabel(String rawLabel) {
  final parts = rawLabel.split('___');
  final crop = (parts.isNotEmpty ? parts[0] : rawLabel).replaceAll('_', ' ').trim();
  final condition =
      (parts.length > 1 ? parts[1] : rawLabel).replaceAll('_', ' ').trim();
  final isHealthy = condition.toLowerCase().contains('healthy');
  return DiseaseDisplay(crop: crop, condition: condition, isHealthy: isHealthy);
}

/// Returns {'cause': String?, 'symptoms': List<String>, 'actions': List<String>}
Map<String, dynamic> lookupDiseaseInfo(String condition) {
  final c = condition.toLowerCase();

  if (c.contains('healthy')) {
    return {
      'cause': null,
      'symptoms': ['No visible signs of disease'],
      'actions': ['Keep monitoring weekly', 'Maintain regular watering & fertilizing'],
    };
  }
  if (c.contains('blight')) {
    return {
      'cause': 'Fungal or bacterial blight',
      'symptoms': [
        'Dark brown or black lesions on leaves',
        'Lesions may show concentric rings',
        'Rapid wilting or leaf death in severe cases',
      ],
      'actions': [
        'Apply an appropriate fungicide (e.g. chlorothalonil)',
        'Remove and destroy infected leaves',
        'Avoid overhead watering; improve airflow',
      ],
    };
  }
  if (c.contains('rust')) {
    return {
      'cause': 'Rust fungus',
      'symptoms': [
        'Orange, yellow, or reddish-brown pustules on leaves',
        'Pustules often appear on the underside of leaves',
      ],
      'actions': [
        'Apply a rust-specific fungicide',
        'Remove heavily infected leaves',
        'Avoid wetting foliage when watering',
      ],
    };
  }
  if (c.contains('scorch')) {
    return {
      'cause': 'Fungal leaf scorch or environmental stress',
      'symptoms': [
        'Browning or scorched-looking leaf edges',
        'Small dark spots that may merge together',
        'Premature leaf drop',
      ],
      'actions': [
        'Remove affected leaves',
        'Ensure adequate but not excessive watering',
        'Apply fungicide if a fungal cause is confirmed',
      ],
    };
  }
  if (c.contains('spot')) {
    return {
      'cause': 'Leaf spot fungus or bacteria',
      'symptoms': [
        'Small circular spots, often with a yellow halo',
        'Spots may merge as the disease progresses',
      ],
      'actions': [
        'Remove infected leaves',
        'Apply a copper-based or other appropriate fungicide',
        'Water at the base, not on the foliage',
      ],
    };
  }
  if (c.contains('mildew') || c.contains('mold') || c.contains('mould')) {
    return {
      'cause': 'Powdery or downy mildew fungus',
      'symptoms': ['White or gray powdery coating on leaves', 'Leaf curling or yellowing'],
      'actions': [
        'Apply a mildew-specific fungicide',
        'Improve air circulation around plants',
        'Avoid overhead watering',
      ],
    };
  }
  if (c.contains('virus') || c.contains('mosaic') || c.contains('curl')) {
    return {
      'cause': 'Viral infection',
      'symptoms': ['Mottled yellow-green mosaic pattern on leaves', 'Stunted or distorted growth'],
      'actions': [
        'Remove and destroy infected plants (no cure exists)',
        'Control insect vectors such as aphids or whiteflies',
        'Use certified disease-free seeds/seedlings next season',
      ],
    };
  }
  if (c.contains('bacterial')) {
    return {
      'cause': 'Bacterial pathogen',
      'symptoms': ['Water-soaked spots that turn brown or black', 'Yellow halo around lesions'],
      'actions': [
        'Apply a copper-based bactericide',
        'Remove infected plant material',
        'Avoid working with plants while they are wet',
      ],
    };
  }

  // Fallback for any label that doesn't match a known keyword.
  return {
    'cause': null,
    'symptoms': ['General leaf discoloration or lesions detected'],
    'actions': [
      'Consult a local agronomist for a precise diagnosis',
      'Isolate affected plants where possible',
    ],
  };
}