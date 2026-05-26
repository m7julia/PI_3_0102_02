import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationGate {
  /// Raio padrão em metros para considerar "dentro da área"
  static const double raioPermitidoMetros = 50.0;

  /// Retorna a distância em metros entre a posição atual e o GeoPoint da fase
  static double distanciaMetros({
    required Position posicaoAtual,
    required GeoPoint localizacaoFase,
  }) {
    return Geolocator.distanceBetween(
      posicaoAtual.latitude,
      posicaoAtual.longitude,
      localizacaoFase.latitude,
      localizacaoFase.longitude,
    );
  }

  /// Retorna true se o jogador está dentro do raio permitido
  static bool estaDentroDoRaio({
    required Position posicaoAtual,
    required GeoPoint localizacaoFase,
    double raio = raioPermitidoMetros,
  }) {
    return distanciaMetros(
          posicaoAtual: posicaoAtual,
          localizacaoFase: localizacaoFase,
        ) <=
        raio;
  }
}
