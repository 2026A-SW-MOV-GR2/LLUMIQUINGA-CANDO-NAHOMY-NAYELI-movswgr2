/// Simple UUID v4 generator — evita dependencia externa en el examen
class Uuid {
  const Uuid();

  String v4() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = now ^ (now >> 16);
    // Formato: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    String hex(int n, int len) =>
        n.toRadixString(16).padLeft(len, '0').substring(0, len);
    final a = rand & 0xFFFFFFFF;
    final b = (rand >> 32) & 0xFFFF;
    final c = 0x4000 | ((rand >> 48) & 0x0FFF);
    final d = 0x8000 | ((rand >> 60) & 0x3FFF);
    final e = DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFFFFFF;
    return '${hex(a, 8)}-${hex(b, 4)}-${hex(c, 4)}-${hex(d, 4)}-${hex(e, 12)}';
  }
}
