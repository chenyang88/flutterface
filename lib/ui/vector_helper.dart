import 'dart:math';

class VectorHelper {
  /// 判断两个向量是否相似
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

void main() {
  final vector1 = <double>[1, 2, 3];
  final vector2 = <double>[2, 3, 4];

  final similarity = VectorHelper.cosineSimilarity(vector1, vector2);
  print('Cosine Similarity: $similarity');
}
