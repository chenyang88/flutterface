import 'dart:math';

class VectorHelper {
  static double cosineSimilarity(List<double> a, List<double> b) {
    assert(a.length == b.length);

    var dotProduct = 0.0;
    var normA = 0.0;
    var normB = 0.0;

    for (var i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += pow(a[i], 2);
      normB += pow(b[i], 2);
    }

    normA = sqrt(normA);
    normB = sqrt(normB);

    return dotProduct / (normA * normB);
  }
}
