import 'dart:io';

void main() async {
  final directory = Directory('lib');
  final replacements = {
    '0xFF0066FF': '0xFFFF6B00', // Primary (Deep Orange)
    '0xFF1E3A8A': '0xFFD84315', // Darker gradient
    '0xFFEFF6FF': '0xFFFFF3E0', // Light background
    '0x440066FF': '0x44FF6B00', // Opacity variation
    '0x330066FF': '0x33FF6B00', // Opacity variation
  };

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      var newContent = content;
      
      replacements.forEach((oldColor, newColor) {
        newContent = newContent.replaceAll(oldColor, newColor);
      });

      if (content != newContent) {
        await entity.writeAsString(newContent);
        print('Updated: ${entity.path}');
      }
    }
  }
}
